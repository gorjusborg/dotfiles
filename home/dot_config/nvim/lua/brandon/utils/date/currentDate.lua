local function currentDate()
  local dfields = os.date("*t")
  local date = string.format("%04d-%02d-%02d", dfields.year, dfields.month, dfields.day)
  return date
end

return currentDate


