--{michaelus{
--[[ oop.lua - lua object oriented pornography ]]--
--[[
      Niled elements are tracked properly:
      on new assignment they will appear in the proper sub-object within the prototype chain.

      Nilifying existent elements of the most outer sub-object cannot be tracked without
      involving an intermediary proxy table, since the __newindex event happens only for absent keys.
      So, we don't set up a tracking table of niled elements for it.
--]]
do


local NIL = {}  -- some unique key


function setprototype(_self, _prototype)
  if type(_prototype) ~= "table" then
    error("'setprototype' argument must be a table", 2)
  end

  local function newindex(_t, _k, _v)
    local t, mt, exist, is_nil = _t, nil, false, false
    while true do  -- look for the key along the prototype chain
      mt = getmetatable(t)
      if not mt then break end
      if rawget(rawget(mt, NIL) or {}, _k) then  -- firstly peek into the tracking table for the niled elements of the current sub-object
        exist = true
        is_nil = true
        break
      end
      t = rawget(mt, "__index")  -- the next sub-object in the chain
      if not t then break end
      if rawget(t, _k) then
        exist = true
        break
      end
    end
    if exist then
      if is_nil then
        if _v ~= nil then
          rawset(t, _k, _v)
          rawset(rawget(mt, NIL), _k, nil)
        end
      else
        rawset(t, _k, _v)
        if _v == nil then
          mt = getmetatable(t)
          if mt then
            t = rawget(mt, NIL)  -- tracking table
            if t then
              rawset(t, _k, true)
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

  local mt = getmetatable(_self)
  if mt then
    rawset(mt, "__index", _prototype)
    rawset(mt, "__newindex", newindex)
    -- if not rawget(mt, NIL) then rawset(mt, NIL, setmetatable({}, { __mode = "k" })) end
  else
    mt = { __index = _prototype, __newindex = newindex }
    -- mt[NIL] = setmetatable({}, { __mode = "k" })
    mt.__metatable = mt  -- protect metatable
    setmetatable(_self, mt)
  end

  return _self
end

function setweakprototype(_self, _prototype)
  if type(_prototype) ~= "table" then
    error("'setweakprototype' argument must be a table", 2)
  end

  local function newindex(_t, _k, _v)
    local t = rawget(getmetatable(_t), "__index")  -- the next sub-object in the chain
    if t and t[_k] ~= nil then  -- a regular indexing access that checks
                                -- if the key exists within the prototype chain
      t[_k] = _v  -- a regular assignment causing the __newindex metamethod
                  -- when the key is not present in that sub-object
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


end
--}michaelus}
