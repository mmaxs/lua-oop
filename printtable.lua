--{michaelus{


function printtable (_table, _prefix1, _prefix2)
  if not _prefix1 then
    _prefix1 = ""
  end
  if not _prefix2 then
    _prefix2 = _prefix1
  end

  local function tostring_(_value)
    local type_  = type(_value)
    local env, meta
    if type_ == "userdata" then
      env, meta = debug.getfenv(_value), debug.getmetatable(_value)
      return tostring(_value)..
                                ", environment"..(string.match(tostring(env)..(not rawequal(env, _G) and "*" or ""), "(: .*)") or ": nil")..
                                ", meta"..(meta and tostring(meta) or "table: nil")
    elseif type_ == "thread" then
      env = debug.getfenv(_value)
      return tostring(_value)..
                                ", environment"..(string.match(tostring(env)..(not rawequal(env, _G) and "*" or ""), "(: .*)") or ": nil")
    elseif type_ == "function" then
      env = debug.getfenv(_value)
      return tostring(_value)..
                                ", environment"..(string.match(tostring(env)..(not rawequal(env, _G) and "*" or ""), "(: .*)") or ": nil")
    elseif type_ == "table" then
      meta = debug.getmetatable(_value)
      return tostring(_value)..
                                ", meta"..(meta and tostring(meta) or "table: nil")
    elseif type_ == "boolean" then
      return "boolean: "..tostring(_value)
    end
    return tostring(_value)
  end

  io.write(_prefix1, tostring_(_table), "\n")
  if type(_table) ~= "table" then return end

  local pair_types = {
    "string/userdata",
    "string/thread",
    "string/function",
    "string/table",
    "string/other",
    "number/any",
    "other/any",
  }

  local table_info = {}
  for _, pair_type in ipairs(pair_types) do
    table_info[pair_type] = {}
  end

  for key, val in pairs(_table) do
    local key_type = type(key)
    local pair_type = key_type.."/"..type(val)
    if table_info[pair_type] then
      table.insert(table_info[pair_type], key)
    else
      if key_type == "number" then
        table.insert(table_info["number/any"], key)
      elseif key_type == "string" then
        table.insert(table_info["string/other"], key)
      else
        table.insert(table_info["other/any"], key)
      end
    end
  end

  local function printpairs_(_pair_type)
    local table_keys = table_info[_pair_type]
    if table_keys then
      io.write(_prefix2, "  ", _pair_type, ": {\n")
      table.sort(table_keys)
      for _, key in ipairs(table_keys) do
          io.write(_prefix2, "    ", tostring_(key), "\t ", tostring_(rawget(_table, key)), "\n")
      end
      io.write(_prefix2, "  }\n")
    end
  end

  io.write(_prefix2, "{\n")
  for _, pair_type in ipairs(pair_types) do
    if #table_info[pair_type] > 0 then printpairs_(pair_type) end
  end
  io.write(_prefix2, "}\n")
end


--}michaelus}
