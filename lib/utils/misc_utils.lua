-- AddOn Template v1.0.0
local ns = select(2, ...)
ns.utils = ns.utils or  {}

function ns.utils.to_string(obj)
  local t = type(obj)
  if t == 'string' then
    return '"' .. obj .. '"'
  elseif t == 'table' then
    local str = '{'
    for k, v in pairs(obj) do
      if str ~= '{' then
        str = str .. ', '
      end
      str = str .. ns.utils.to_string(k) .. ': ' .. ns.utils.to_string(v)
    end
    str = str .. '}'
    return str
  else
    return tostring(obj)
  end
end

-- This hash function assumes 64-bit floating numbers.
local _MAX_INT_BITS = 52
local _EXPONENT = 127

local _HASH_PRIME = 31
local _HASH_MOD = 2 ^ _MAX_INT_BITS
local _LOG_2 = math.log(2)

function ns.utils.hash_add_int_value(hash, value)
  return (_HASH_PRIME * hash + value) % _HASH_MOD
end

function ns.utils.hash(obj)
  local obj_type = type(obj)
  if obj_type == 'boolean' then
    return obj and 1231 or 1237
  elseif obj_type == 'number' then
    if ns.utils.is_integer(obj) then
      if obj < 0 then
        -- 16777447 is the first prime greater than 2^24
        return ns.utils.hash_add_int_value(16777447, -obj)
      else
        return ns.utils.hash_add_int_value(1291, obj)
      end
    elseif not ns.utils.is_finite(obj) then
      return 1283
    end
    local hash
    if obj < 0 then
      hash = 1277
      obj = -obj
    elseif obj > 0 then
      hash = 1279
    else
      return 0
    end
    local exponent = obj ~= 0 and math.floor(math.log(obj) / _LOG_2) or 0
    hash = ns.utils.hash_add_int_value(hash, _EXPONENT + exponent)
    hash = ns.utils.hash_add_int_value(
        hash, math.floor(obj * (2^(_MAX_INT_BITS - exponent))))
    return hash
  elseif obj_type == 'string' then
    local hash = 1249
    for _, c in ipairs({obj:byte(1, -1)}) do
      hash = ns.utils.hash_add_int_value(hash, c)
    end
    return hash
  elseif obj_type == 'table' then
    local hash = 1259
    for k, v in ns.utils.pairs_sorted_by_keys_asc(obj) do
      hash = ns.utils.hash_add_int_value(hash, ns.utils.hash(k))
      hash = ns.utils.hash_add_int_value(hash, ns.utils.hash(v))
    end
    return hash
  end
  error('Cannot hash unsupported type: ' .. obj_type)
end
