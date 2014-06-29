--
-- lua-Spore : <http://fperrad.github.com/lua-Spore/>
--

_ENV = nil
local m = {}

function m:call (req)
  -- If you use https, it is necessary to
  -- luasec supports the proxy connection
  if self.proxy then
    req.proxy = self.proxy
  end
end

return m
--
-- Copyright (c) 2014 kyary
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
