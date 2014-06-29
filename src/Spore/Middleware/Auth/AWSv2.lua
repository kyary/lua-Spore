--
-- lua-Spore : <http://fperrad.github.com/lua-Spore/>
--

--[[
    See http://docs.amazonwebservices.com/AmazonS3/latest/dev/index.html?RESTAuthentication.html
]]

local pairs = pairs
local tostring = tostring
local table = require 'table'
local os = require 'os'
local mime = require 'mime'
local crypto = require 'crypto'
local digest = crypto.digest or crypto.evp.digest
local hmac = crypto.hmac
local request = require 'Spore.Protocols'.request
local util = require 'Spore.Util'
require 'Spore'.early_validate = false

_ENV = nil
local m = {}

function m:call (req)

  local function string_to_sign(self, req)
    local env = req.env
    local parts = {
      env.REQUEST_METHOD,
      env.SERVER_NAME:lower(),
      util.pathname(env.PATH_INFO),
      util.query_params_to_string(env.spore.params),
    }
    local str = util.join(parts, '\n')
    print('str2sign:', '['.. str .. ']')
    return str
  end

  local function signature(self, req)
    return (mime.b64(hmac.digest('sha256', string_to_sign(self, req), self.aws_secret_key, true)))
  end

  local function sign(self, req, timestamp)
    local params = req.env.spore.params
    local query = req.env.QUERY_STRING or ''
print(query)
    local a = util.split(query, "=")
    local k,v = a[1], a[2]
print(k, v)
    if k and v then
      params[k] = v
    end
    params.Version = "2014-05-01"

    params.Timestamp = timestamp
    params.SignatureVersion = '2'
    params.SignatureMethod = 'HmacSHA256'
    params.AWSAccessKeyId = self.aws_access_key

    if self.sessionToken then
      params.SecurityToken = self.sessionToken;
    end

    params.Signature = signature(self, req);

    local payload = util.query_params_to_string(params)
    req.env.spore.payload = payload
    -- req.source = ltn12.source.string(payload)
    -- req.headers['content-length'] = payload:len()
    -- req.headers['content-type'] = req.headers['content-type'] or 'application/x-www-form-urlencoded'
  end

  local env = req.env
  local spore = env.spore

  if self.region then
    env.SERVER_NAME = self.region .. '.' .. env.SERVER_NAME
  end
  if self.service then
    env.SERVER_NAME = self.service .. '.' .. env.SERVER_NAME
  end

  req:finalize()
  if spore.authentication and self.aws_access_key and self.aws_secret_key then
    sign(self, req, util.date.iso8601())
  end

  return request(req)
end

return m

--
-- Copyright (c) 2011-2012 Francois Perrad
-- Copyright (c) 2011 LogicEditor.com: Alexander Gladysh, Vladimir Fedin
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
