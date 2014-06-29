--
-- lua-Spore : <http://fperrad.github.com/lua-Spore/>
--

local ltn12 = require('ltn12')
local io    = require('io')

_ENV = nil
local m = {}

local function fsize (file)
  local current = file:seek()
  local size = file:seek("end")
  file:seek("set", current)
  return size
end

function m:call (req)

  local input_file, output_file

  if self.input then
    input_file = io.open(self.input, "rb")
    local length = fsize(source)
    req.source = ltn12.source.file(input_file)
    req.headers['content-length'] = length
    req.headers['content-type'] = req.headers['content-type'] or 'application/x-www-form-urlencoded'
    if req.method == 'POST' and not req.headers['content-length'] then
      req.headers['content-length'] = 0
    end
  end

  if self.output then
    output_file = io.open(self.output, "wb")
    req.sink = ltn12.sink.file(output_file)
  end

  return function(res)
      if input_file then input_file:close() end
      if output_file then output_file:close() end
      return res
    end
end

return m
--
-- Copyright (c) 2014 kyary
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
