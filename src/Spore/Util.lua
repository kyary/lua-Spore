local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local table = require 'table'
local os = require 'os'
local io = require 'io'
local mime = require 'mime'
local crypto = require 'crypto'
local digest = crypto.digest or crypto.evp.digest
local hmac = crypto.hmac

_ENV = nil
local m = {}

local function splitIterator(value, pattern, start)
  if pattern then
    return string.find(value, pattern, start)
  else
    if start > string.len(value) then
      return nil
    else
      return start+1, start
    end
  end
end

m.split = function(value, pattern)
  if type(value) ~= "string" then return {} end
  local values = {}
  local start = 1
  local start_pattern, end_pattern = splitIterator(value, pattern, start)

  while start_pattern do
    table.insert(
      values,
      string.sub(value, start, start_pattern - 1)
    )
    start = end_pattern + 1
    start_pattern, end_pattern = splitIterator(value, pattern, start)
  end

  if start <= string.len(value) then
    table.insert(values, string.sub(value, start))
  end

  return values
end

m.join = function (array, seps)
  local r = ""
  for idx,v in ipairs(array) do
    r = (r .. v .. (idx < #array and seps or ""))
  end
  return r
end

m.escape = function (s)
  return string.gsub(s, '[^-._~%w]', function(c)
    return string.format('%%%02X', string.byte(c))
  end)
end

m.unescape = function (s)
  return string.gsub(s, "%%(%X%X)", function(hex)
    return string.char(base.tonumber(hex, 16))
  end)
end

m.query_params_to_string = function (params)
  local items = {};
  local escape = m.escape
  local sorted_keys = {}

  for k,v in pairs(params) do
    table.insert(sorted_keys, k)
  end
  table.sort(sorted_keys, function (a, b)
    return b > a
  end)

  for idx, name in ipairs(sorted_keys) do
    local value = params[name]
    local ename = escape(name)
    local result = ename
    if type(value) == 'table' then
      local vals = {}
      for idx,item in ipairs(value) do
        table.insert(vals, escape(item))
      end
      table.sort(vals, function (a, b)
        return b < a
      end)
      result = (ename .. '=' .. m.join(vals, '&' .. ename .. '='))
    elseif value then
      result = (ename .. '=' .. escape(value))
    end
    table.insert(items, result)
  end
  return m.join(items, '&')
end

m.pathname = function (path)
  local pos = path:find('?')
  return pos and path:sub(1, pos) or path
end

m.chop = function (str)
  local l = #str
  local cnt = 0
  while true do
    local ch = str:char(l)
    if ch == '\r' or c == '\n' then
      l = (l - 1)
    else
      break
    end
    cnt = (cnt + 1)
    if cnt > #str then
      assert(false, "too much check:" .. cnt)
    end
  end
  return str:sub(1, l)
end

m.date = {
  iso8601 = function ()
    return os.date("!%Y-%m-%dT%TZ")
  end,
  rfc822 = function ()
    return os.date("%a, %d %b %y %T %z")
  end,
  unixTimestamp = function ()
    return tostring(os.time())
  end,
}

return m
