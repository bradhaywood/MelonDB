--[[ CLASS SYSTEM ]]--

class = {}

local function new(self, o, imp)
  local metaclass = {}
  local base = {
    children = {},
    parent = {}
  }
  
  if (imp ~= nil) then
    base.__implementation = imp
  end

  -- this is freaking disgusting
  local getName = function()
    for k, v in pairs(_G) do
      if (v == metaclass) then
        return k
      end
    end
  end
  
  local args = {
    Initialize = function() end,
    __base = base,
    __name = getName()
  }

  if (o ~= nil) then
    for k, v in pairs(o) do
      args[k] = v
    end
  end

  base.__index = base
  
  metaclass = setmetatable(args, {
    __index = base,
    __call = function(cls, ...)
      local me = {}
      setmetatable(me, cls)
      cls.__index = cls
      cls.Initialize(me, ...)
      return me
    end
  })
  base.__class = metaclass
  local self = metaclass
  return metaclass
end

function class:new(o, t)
  return new(self, o, t)
end

local function _check_imp(imp, cls)
  for k,v in pairs(imp) do
    assert(cls[k] ~= nil, "Implementation expects property '" .. k .. "'")
    assert(imp[k] == type(cls[k]), "Expecting '" .. k .. "' to be a " .. imp[k])
  end

  return true
end

function class:extends(par, args)
  local cls = class:new(args)
  cls.parent = par

  for k, v in pairs(par) do
    if (args ~= nil and args[k] ~= nil) then
      cls[k] = args[k]
    else
      cls[k] = v
    end
  end

  if (cls.parent.__base.__implementation ~= nil and args ~= nil) then
    _check_imp(cls.parent.__base.__implementation, cls)
  end

  cls.__init = function(self, ...)
    return cls.parent.Initialize(self, ...)
  end
  table.insert(cls.parent.children, cls)
  return cls
end

function class:implements(t, o)
  _check_imp(t, o)
  return class:new(o, t)
end

--[[ UTIL ]]--

function join(t, delimiter)
  local len = #t
  if len == 0 then
    return ""
  end
  local string = t[1]
  for i = 2, len do
    string = string .. delimiter .. t[i]
  end
  return string
end

function split(str, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  local i=1
  for str in string.gmatch(str, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end
  return t
end

function string:split(sep)
  return split(self, sep)
end

--[[ INTERFACE ]]--

Type = {
  string = "string",
  int = "number",
  table = "table",
  bool = "boolean",
  func = "function"
}

function interface(params)
  return params
end

function tablelen(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
