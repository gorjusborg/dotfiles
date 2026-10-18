#!/usr/bin/env bb
;; keepass sync helper -- see README.md for the process.
;;
;;   ./kpsync.bb status [db ...]                 list sources, their age, and whether they match latest/
;;   ./kpsync.bb collect <machine> <file.kdbx>   copy a machine's database into sources/<machine>/
;;   ./kpsync.bb merge <db> [merge options]      archive latest/<db>.kdbx, then merge every
;;                                             sources/*/<db>.kdbx that differs into it;
;;                                             --plan only prints the steps
;;   ./kpsync.bb deliver <machine> <db> [dest]   copy latest/<db>.kdbx to dest (if given) and
;;                                             record it in sources/<machine>/
;;   ./kpsync.bb completion                      print a bash completion script:
;;                                             source <(kpsync.bb completion), with kpsync.bb on your PATH
;;
;; Merge options are passed to keepassxc-cli merge, e.g. --yubikey <slot> -s.
;; Without any, -s (same credentials for both files) is used.
;;
;; The keepass folder (holding latest/, sources/ and archive/) is, in order:
;; --dir <folder> before the command, $KEEPASS_SYNC_DIR, or the current
;; directory. So it can be installed anywhere on the PATH and run from inside
;; the keepass folder, or from anywhere with KEEPASS_SYNC_DIR set.
;;
;; Example: laptop has changes; phone gets the file copied by hand.
;;
;;   ./kpsync.bb collect laptop ~/path/to/personal.kdbx
;;   ./kpsync.bb merge personal --yubikey <slot> -s
;;   ./kpsync.bb deliver laptop personal ~/path/to/personal.kdbx
;;   ./kpsync.bb deliver phone personal  # after copying the file to the phone
;;   ./kpsync.bb status                  # repeat deliver until all sources match

(require '[babashka.fs :as fs]
         '[babashka.process :as p]
         '[clojure.string :as str])

(def usage "usage: kpsync.bb [--dir <folder>] <command> ...

  The keepass folder is --dir, else $KEEPASS_SYNC_DIR, else the current directory.

  kpsync.bb status [db ...]                 list sources, their age, and whether they match latest/
  kpsync.bb collect <machine> <file.kdbx>   copy a machine's database into sources/<machine>/
  kpsync.bb merge <db> [merge options]      archive latest/<db>.kdbx, then merge every
                                          sources/*/<db>.kdbx that differs into it;
                                          --plan only prints the steps
  kpsync.bb deliver <machine> <db> [dest]   copy latest/<db>.kdbx to dest (if given) and
                                          record it in sources/<machine>/
  kpsync.bb completion                      print a bash completion script:
                                          source <(kpsync.bb completion), with kpsync.bb on your PATH

example: laptop has changes; phone gets the file copied by hand.

  ./kpsync.bb collect laptop ~/path/to/personal.kdbx
  ./kpsync.bb merge personal --yubikey <slot> -s
  ./kpsync.bb deliver laptop personal ~/path/to/personal.kdbx
  ./kpsync.bb deliver phone personal  # after copying the file to the phone
  ./kpsync.bb status                  # repeat deliver until all sources match")

;; The keepass folder: --dir <folder> before the command, else
;; $KEEPASS_SYNC_DIR, else the current directory.
(def dir-option? (= "--dir" (first *command-line-args*)))
(def args (if dir-option? (drop 2 *command-line-args*) *command-line-args*))
(def root (-> (or (when dir-option? (second *command-line-args*))
                  (not-empty (System/getenv "KEEPASS_SYNC_DIR"))
                  (fs/cwd))
              fs/absolutize
              fs/normalize))

(defn path [& parts] (str (apply fs/path root parts)))

(defn die [& msg]
  (binding [*out* *err*] (println (apply str "error: " msg)))
  (System/exit 1))

(defn fail []
  (binding [*out* *err*] (println usage))
  (System/exit 1))

(defn db-name [s] (str/replace s #"\.kdbx$" ""))

(defn same?
  "Whether two files have identical contents (like cmp -s)."
  [a b]
  (and (fs/exists? a) (fs/exists? b)
       (java.util.Arrays/equals (fs/read-all-bytes a) (fs/read-all-bytes b))))

(defn copy-file
  "Copy src to dest, creating dest's folder and keeping src's
  permissions and modification time (like cp -p)."
  [src dest]
  (let [dest (if (fs/directory? dest) (fs/path dest (fs/file-name src)) dest)]
    (fs/create-dirs (fs/parent (fs/absolutize dest)))
    (fs/copy src dest {:replace-existing true :copy-attributes true})))

(defn sources
  ([] (sources "*.kdbx"))
  ([pattern] (sort (map str (fs/glob (path "sources") (str "*/" pattern))))))

(defn rel [p] (str (fs/relativize root (fs/absolutize p))))

(defn modified
  "A file's last-modified date and its age in whole days."
  [f]
  (let [instant (.toInstant (fs/last-modified-time f))]
    {:date (java.time.LocalDate/ofInstant instant (java.time.ZoneId/systemDefault))
     :days (.toDays (java.time.Duration/between instant (java.time.Instant/now)))}))

(defn status
  "Print each database in sources/ as a tree of the machines that have it:

    personal.kdbx  2026-10-16
      laptop     differs  2025-03-22   574d
      phone      matches  2026-10-16     1d

  With database names, only those databases are shown."
  [dbs]
  (let [wanted (set (map #(str (db-name %) ".kdbx") dbs))
        srcs (cond->> (sources)
               (seq wanted) (filter #(wanted (str (fs/file-name %)))))
        ;; sort by name without .kdbx, so work comes before work-old
        by-db (into (sorted-map-by #(compare (db-name %1) (db-name %2)))
                    (concat (for [db wanted] [db []]) ; asked for, even without sources
                            (group-by #(str (fs/file-name %)) srcs)))
        machine-of #(str (fs/file-name (fs/parent %)))
        ;; line up root dates with the machine dates below them
        date-col (max (+ 13 (apply max 0 (map (comp count machine-of) srcs)))
                      (+ 2 (apply max 0 (map count (keys by-db)))))
        width (- date-col 13)
        differing (atom 0)]
    (if (empty? by-db)
      (println "no databases in sources/")
      (do
        (doseq [[db db-srcs] by-db
                :let [latest (path "latest" db)
                      in-latest? (fs/exists? latest)
                      db-srcs (sort-by (comp str/lower-case machine-of) db-srcs)]]
          (println (format (str "%-" date-col "s%s") db (if in-latest?
                                                         (:date (modified latest))
                                                         "not in latest/")))
          (when (empty? db-srcs) (println "  no sources"))
          (doseq [src db-srcs
                  :let [{:keys [date days]} (modified src)
                        matches? (and in-latest? (same? src latest))]]
            (when-not matches? (swap! differing inc))
            (println (format (str "  %-" width "s  %-7s  %s  %4dd")
                             (machine-of src) (if matches? "matches" "differs") date days))))
        (println)
        (cond
          (empty? srcs) (println "no sources for these databases")
          (zero? @differing) (println "all sources match latest/")
          :else
          (println @differing "of" (count srcs) "sources differ from latest/"))))))

(defn collect [machine file]
  (when-not (fs/exists? file) (die "no such file: " file))
  (let [dest (path "sources" machine (fs/file-name file))]
    (copy-file file dest)
    (println "collected" file "->" (rel dest))))

(defn merge-db
  "With --plan, only print what would be done: no passwords, nothing written.
  With --dry-run (passed on to keepassxc-cli), latest/ is not saved, so no
  archive copy is made."
  [db args]
  (let [target (path "latest" (str db ".kdbx"))
        plan? (some #{"--plan"} args)
        opts (remove #{"--plan"} args)
        dry-run? (some #{"-d" "--dry-run"} opts)
        opts (if (seq (remove #{"-d" "--dry-run"} opts)) opts (cons "-s" opts))]
    (when-not (fs/exists? target) (die "no such file: " (rel target)))
    (let [{pending false, unchanged true} (group-by #(same? % target) (sources (str db ".kdbx")))]
      (doseq [src unchanged]
        (println (if plan? "would skip" "skipping") (rel src) (str "(same as " (rel target) ")")))
      (if (empty? pending)
        (println (str "nothing to merge: every sources/*/" db ".kdbx matches " (rel target)))
        (let [stamp (.format (java.time.LocalDateTime/now)
                             (java.time.format.DateTimeFormatter/ofPattern "yyyy-MM-dd-HHmmss"))
              archived (path "archive" (str db "." stamp ".kdbx"))]
          (when (fs/exists? archived) (die "already exists: " (rel archived)))
          (cond
            plan? (println "would archive" (rel target) "->" (rel archived))
            dry-run? (println "dry run: not archiving, latest/ will not be saved")
            :else (do (copy-file target archived)
                      (println "archived" (rel target) "->" (rel archived))))
          (doseq [src pending]
            (if plan?
              (println "would merge" (rel src) (str "(" (:date (modified src)) ")") "with:\n "
                       (str/join " " (concat ["keepassxc-cli" "merge"] opts [(rel target) (rel src)])))
              (do
                (println "merging" (rel src))
                (let [{:keys [exit]} (apply p/shell {:continue true}
                                            "keepassxc-cli" "merge" (concat opts [target src]))]
                  (when-not (zero? exit)
                    (die "merge of " (rel src) " failed"
                         (when-not dry-run?
                           (str "; to undo, copy " (rel archived) " back to " (rel target)))))))))
          (when-not (or plan? dry-run?)
            (println (str "done. deliver " (rel target)
                          " to each machine, then run: kpsync.bb deliver <machine> " db))))))))

(defn deliver-db [machine db dest]
  (let [latest (path "latest" (str db ".kdbx"))
        record (path "sources" machine (str db ".kdbx"))]
    (when-not (fs/exists? latest) (die "no such file: " (rel latest)))
    (when dest
      (copy-file latest dest)
      (println "copied" (rel latest) "->" dest))
    (copy-file latest record)
    (println "recorded" (rel record) "as delivered")))

(defn names
  "Print machine or database names, one per line. Used by tab completion, so
  it follows --dir and KEEPASS_SYNC_DIR like every other command."
  [kind]
  (let [sources-dir (path "sources")
        latest-dir (path "latest")]
    (run! println
          (sort (case kind
                  "machines" (when (fs/directory? sources-dir)
                               (for [d (fs/list-dir sources-dir)
                                     :when (and (fs/directory? d) (not (fs/hidden? d)))]
                                 (str (fs/file-name d))))
                  "databases" (when (fs/directory? latest-dir)
                                (map #(db-name (str (fs/file-name %))) (fs/glob latest-dir "*.kdbx")))
                  nil)))))

(defn completion
  "Print a bash completion script. Machine and database names come from
  kpsync.bb itself (the names command) each time you press tab."
  []
  (println "# bash completion for kpsync.bb; load it with:  source <(kpsync.bb completion)
# Machine and database names are asked of kpsync.bb itself, so --dir and
# KEEPASS_SYNC_DIR work here too.
_kpsync_bb() {
    local cur=${COMP_WORDS[COMP_CWORD]} prev=${COMP_WORDS[COMP_CWORD-1]}
    local cmd=(\"${COMP_WORDS[0]/#\\~/$HOME}\") off=0 words=()
    [[ $prev == --dir ]] && return # folder name
    if [[ ${COMP_WORDS[1]} == --dir ]] && ((COMP_CWORD > 2)); then
        cmd+=(--dir \"${COMP_WORDS[2]/#\\~/$HOME}\")
        off=2
    fi
    case $((COMP_CWORD - off)):${COMP_WORDS[off + 1]} in
        1:*) words=(status collect merge deliver completion)
             ((off)) || words+=(--dir) ;;
        2:collect | 2:deliver) words=($(\"${cmd[@]}\" names machines 2>/dev/null)) ;;
        2:merge | 3:deliver | *:status) words=($(\"${cmd[@]}\" names databases 2>/dev/null)) ;;
        *:merge)
            case $prev in
                -k | --key-file | --key-file-from) return ;; # file name
                -y | --yubikey | --yubikey-from) words=(1 2) ;;
                *) words=(--plan --dry-run -s --same-credentials --yubikey --yubikey-from
                          --key-file --key-file-from --no-password --no-password-from --quiet) ;;
            esac ;;
        *) return ;; # file name (collect's file, deliver's dest)
    esac
    COMPREPLY=($(compgen -W \"${words[*]}\" -- \"$cur\"))
}
complete -o default -F _kpsync_bb kpsync.bb ./kpsync.bb"))

(let [[cmd & args] args
      n (count args)]
  (when (and dir-option? (< (count *command-line-args*) 2)) (fail))
  (when (contains? #{"status" "collect" "merge" "deliver"} cmd)
    (when-not (fs/directory? (path "latest"))
      (die "no latest/ folder in " root "; use --dir <folder> or set KEEPASS_SYNC_DIR")))
  (case cmd
    "status" (status args)
    "completion" (completion)
    "names" (if (= n 1) (names (first args)) (fail))
    "collect" (if (= n 2) (apply collect args) (fail))
    "merge" (if (>= n 1) (merge-db (db-name (first args)) (rest args)) (fail))
    "deliver" (if (<= 2 n 3)
                (deliver-db (first args) (db-name (second args)) (nth args 2 nil))
                (fail))
    (fail)))
