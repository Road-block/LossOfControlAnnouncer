-- AddOn Template v1.0.0
local ns = select(2, ...)
ns.utils = ns.utils or {}

local _DEFAULT_ESCAPE_CHAR = '%'

function ns.utils.unescape(str, vals, escape_char)
  escape_char = escape_char or _DEFAULT_ESCAPE_CHAR
  local unescaped_str = ''
  local i = 1
  local str_len = str:len()
  while i <= str_len do
    local c = str:sub(i, i)
    if c == escape_char and i < str_len then
      i = i + 1
      c = str:sub(i, i)
      if c == escape_char then
        unescaped_str = unescaped_str .. escape_char
      elseif vals[c] ~= nil then
        unescaped_str = unescaped_str .. vals[c]
      else
        unescaped_str = unescaped_str .. escape_char
        i = i - 1
      end
    else
      unescaped_str = unescaped_str .. c
    end
    i = i + 1
  end
  return unescaped_str
end

ns.utils.FontColorString = ns.utils.create_enum({
  TITLE = 'ffffd200',
})

function ns.utils.color_string(font_color_string, str)
  return '|c' .. font_color_string .. str .. '|r'
end
