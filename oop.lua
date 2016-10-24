--[[ oop.lua - lua object oriented pornography ]]--

--[[
     Prototype-based style of object-oriented programming can be failry naturally implemented in Lua
     by means of using the `__index` metamethod.

     setprototype()
     setcowprototype()
                      copy-on-write


     setconstructor()
     getconstructor()

     getprototype()
     prototypes()
     unsetprototype()

     memberpairs()
--]]
do


local NIL = {}  -- to be used as a unique key and as a definitely empty table

local function newindex(_t, _k, _v)  -- the handler for __newindex event being set up by setprototype()
  local t, mt, tt = _t, nil, nil
  local exist, is_nil = false, false
  while true do  -- look for the key along the prototype chain
    mt = getmetatable(t)
    if not mt then break end
    tt = rawget(mt, NIL)  -- tracking table of niled members
    if tt and rawget(tt, _k) then
      exist = true
      is_nil = true
      break
    end
    t = rawget(mt, "__index")  -- the next sub-object in the chain
    if not t then break end
    if rawget(t, _k) ~= nil then
      exist = true
      break
    end
  end
  if exist then
    rawset(t, _k, _v)
    if is_nil then
      if _v ~= nil then  -- remove the restored member from the table of niled ones
        rawset(tt, _k, nil)
      end
    else
      if _v == nil then  -- add niled member into the tracking table
        mt = getmetatable(t)
        if mt then
          tt = rawget(mt, NIL)
          if tt then
            rawset(tt, _k, true)
          else
            rawset(mt, "__newindex", newindex)
            rawset(mt, NIL, setmetatable({ [_k] = true }, { __mode = "k" }))
          end
        else
          mt = { __newindex = newindex, [NIL] = setmetatable({ [_k] = true }, { __mode = "k" }) }
          mt.__metatable = mt  -- protect metatable
          setmetatable(t, mt)
        end
      end
    end
  else
    rawset(_t, _k, _v)
  end
end


--[[ Niled elements are tracked properly:
     on new assignment they will appear in the proper sub-object within the prototype chain. --]]
function setprototype(_self, _prototype)
  if type(_prototype) ~= "table" then
    error("'setprototype' argument must be a table", 2)
  end

  local mt = getmetatable(_self)
  if mt then
    rawset(mt, "__index", _prototype)
    rawset(mt, "__newindex", newindex)
    -- Nilifying existing members of the most outer sub-object cannot be tracked without
    -- involving an intermediary proxy table, since the __newindex event happens only for absent keys.
    -- So, we don't set up a tracking table of niled members for it.
    -- if not rawget(mt, NIL) then rawset(mt, NIL, setmetatable({}, { __mode = "k" })) end
  else
    mt = { __index = _prototype, __newindex = newindex }
    -- See above.
    -- mt[NIL] = setmetatable({}, { __mode = "k" })
    mt.__metatable = mt  -- protect metatable
    setmetatable(_self, mt)
  end

  return _self
end

function setcowprototype(_self, _prototype)
  if type(_prototype) ~= "table" then
    error("'setcowprototype' argument must be a table", 2)
  end

  local mt = getmetatable(_self)
  if mt then
    rawset(mt, "__index", _prototype)
  else
    mt = { __index = _prototype }
    mt.__metatable = mt  -- protect metatable
    setmetatable(_self, mt)
  end

  return _self
end

function getprototype(_object)
  return rawget(getmetatable(_object) or NIL, "__index")
end

function prototypes(_object)
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

function unsetprototype(_object)
  local mt, prototype = getmetatable(_object), nil
  if mt then
    prototype = rawget(mt, "__index")
    rawset(mt, "__index", nil)
    if rawget(mt, "__newindex") == newindex then
      rawset(mt, "__newindex", nil)
    end
  end

  return prototype
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
  return rawget(getmetatable(_object) or NIL, "constructor")
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


end
