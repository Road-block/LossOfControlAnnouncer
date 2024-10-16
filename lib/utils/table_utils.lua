-- AddOn Template v1.0.0
local ns = select(2, ...)
ns.utils = ns.utils or {}

function ns.utils.table_size(t)
  local num_entries = 0
  for _, _ in pairs(t) do
    num_entries = num_entries + 1
  end
  return num_entries
end

function ns.utils.deep_copy(t)
  local new_t = {}
  for k, v in pairs(t) do
    if type(v) == 'table' then
      new_t[k] = ns.utils.deep_copy(v)
    else
      new_t[k] = v
    end
  end
  return new_t
end

function ns.utils.invert_map(map)
  local inverted_map = {}
  for k, v in pairs(map) do
    assert(inverted_map[v] == nil, 'Cannot invert map with non-unique values')
    inverted_map[v] = k
  end
  return inverted_map
end

function ns.utils.map_from_arrays(key_array, value_array)
  assert(
      #key_array == #value_array,
      'key_array and value_array must be the same length: ' ..
          tostring(#key_array) .. ' vs ' .. tostring(#value_array))
  local map = {}
  for i, v in ipairs(key_array) do
    map[v] = value_array[i]
  end
  return map
end

function ns.utils.union(t1, t2)
  local union = {}
  for k, v in pairs(t1) do
    union[k] = v
  end
  for k, v in pairs(t2) do
    assert(
        not union[k], 'Cannot create union of tables with overlapping key sets')
    union[k] = v
  end
  return union
end

function ns.utils.get_optional_value(t, key, default_value)
  if t and t[key] ~= nil then
    return t[key]
  else
    return default_value
  end
end

-- Returns the first key where t[key] == val.
function ns.utils.find_key_of_value(t, val)
  for k, v in pairs(t) do
    if v == val then
      return k
    end
  end
  return nil
end

local function _descending_sort_fn(a, b)
  return b < a
end

local function _pairs_sorted_by_keys(t, descending)
  local keys = {}
  for k, _ in pairs(t) do table.insert(keys, k) end
  table.sort(keys, descending and _descending_sort_fn or nil)
  local i = 0
  local iterator = function()
    i = i + 1
    local k = keys[i]
    if k == nil then
      return nil
    end
    return k, t[k]
  end
  return iterator, t, nil
end

function ns.utils.pairs_sorted_by_keys_asc(t)
  return _pairs_sorted_by_keys(t, --[[ descending= ]] false)
end

function ns.utils.pairs_sorted_by_keys_desc(t)
  return _pairs_sorted_by_keys(t, --[[ descending= ]] true)
end
