--{michaelus{
--[[ oop.lua - lua object oriented pornography ]]--


function setprototype(_self, _prototype)
  if type(_prototype) ~= "table" then
    error("'setprototype' argument must be a table", 2)
  end

  local function newindex(_t, _k, _v)
    if _t[_k] ~= nil then  -- a regular indexing access that trigger the __index metamethod
                           -- to check if the key exists within the prototype chain
      rawget(getmetatable(_t), "__index")[_k] = _v  -- a regular assignment for the next sub-object in the chain
                                                    -- causing the __newindex metamethod if the key is not present in that sub-object
    else
      rawset(_t, _k, _v)
    end
  end

  local mt = getmetatable(_self)
  if mt then
    rawset(mt, "__index", _prototype)
    rawset(mt, "__newindex", newindex)
  else
    mt = { __index = _prototype, __newindex = newindex }
    mt.__metatable = mt  -- protect metatable
    setmetatable(_self, mt)
  end

  return _self
end

function getprototype(_object)
  return rawget(getmetatable(_object) or {}, "__index")
end

function prototypechain(_object)
  local level, mt = 0, getmetatable(_object)

  local function nextprototype()
    local prototype = nil
    if mt then
      level = level + 1
      prototype = rawget(mt, "__index")
      mt = getmetatable(prototype)
    end
    return prototype and level, prototype
  end

  return nextprototype
end


function setconstructor(_self, _function)
  if type(_function) ~= "function" then
    error("'setconstructor' argument must be a function", 2)
  end

  local mt = getmetatable(_self)
  if mt then
    rawset(mt, "constructor", _function)
  else
    mt = { constructor = _function }
    mt.__metatable = mt  -- protect metatable
    setmetatable(_self, mt)
  end

  return _self
end

function getconstructor(_object)
  return rawget(getmetatable(_object) or {}, "constructor")
end


function memberpairs(_object)
  local k, t = nil, _object

  local function nextmemberpair()
    local v = nil
    k, v = next(t, k)
    if k == nil then
      local mt = getmetatable(t)
      t = mt and rawget(mt, "__index")
      if t then k, v = next(t) end
    end
    return k, v, t
  end

  return nextmemberpair
end


--}michaelus}
