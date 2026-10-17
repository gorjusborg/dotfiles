require("brandon.core.options")
require("brandon.core.keymaps")
require("brandon.core.abbrev")

vim.filetype.add({
  extension = {
    bb = "clojure",
  },
	filename = {
		["Jenkinsfile"] = "groovy",
	},
	pattern = {
		["Jenkinsfile.*"] = "groovy",
		[".*%.Jenkinsfile"] = "groovy",
	},
})
