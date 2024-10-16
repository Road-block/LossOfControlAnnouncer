-- AddOn Template v1.0.0
local ns = select(2, ...)
ns.utils = ns.utils or {}

function ns.utils.create_enum(enum, superclass)
  local inverse = {}
  local mt = {_inverse = inverse}
  local superclass_mt = nil
  if superclass then
    superclass_mt = getmetatable(superclass)
    assert(
        superclass_mt and superclass_mt._inverse,
        'Cannot create enum where superclass is not an enum')
    mt.__index = superclass
    setmetatable(inverse, {__index = superclass_mt._inverse})
  end
  local e = {}
  for k, v in pairs(enum) do
    assert(type(k) == 'string', 'Enum keys must be strings')
    assert(
        not superclass or superclass[k] == nil,
        'Cannot create enum where keys collide with superclass\'s keys')
    assert(mt._inverse[v] == nil, 'Cannot create enum with non-unique values')
    assert(
        not superclass or superclass_mt._inverse[v] == nil,
        'Cannot create enum where values collide with superclass\'s values')
    e[k] = v
    mt._inverse[v] = k
  end
  return setmetatable(e, mt)
end

function ns.utils.get_enum_name(enum, value)
  return getmetatable(enum)._inverse[value]
end

function ns.utils.create_class_inherited_from(superclass)
  local subclass = {}
  if not superclass then
    return subclass
  end
  return setmetatable(subclass, {__index = superclass})
end

local _SUPERCLASS_MISMATCH_ERROR =
    'Cannot create an instance where the superclasses of superclass_instance' ..
        ' and subclass do not match'

function ns.utils.create_instance(subclass, superclass_instance)
  local subclass_mt = getmetatable(subclass)
  local superclass_instance_mt = getmetatable(superclass_instance)
  if subclass_mt then
    assert(
        superclass_instance_mt and
            superclass_instance_mt.__index == subclass_mt.__index,
        _SUPERCLASS_MISMATCH_ERROR)
  else
    assert(not superclass_instance_mt, _SUPERCLASS_MISMATCH_ERROR)
  end
  return setmetatable(superclass_instance, {__index = subclass})
end

-- If called on a class, this will return its superclass.
function ns.utils.get_class(obj)
  local mt = getmetatable(obj)
  return mt and mt.__index or nil
end

function ns.utils.is_instance_of(obj, class)
  while true do
    local mt = getmetatable(obj)
    if not mt or not mt.__index then
      return false
    end
    if mt.__index == class then
      return true
    end
    obj = mt.__index
  end
end

function ns.utils.pairs_with_inheritance(obj)
  local inheritance_hierarchy = {obj}
  while true do
    local obj_mt = getmetatable(obj)
    if not obj_mt or not obj_mt.__index then
      break
    end
    table.insert(inheritance_hierarchy, obj_mt.__index)
    obj = obj_mt.__index
  end
  local i = 1
  local keys = {}
  local iterator = function(t, k)
    while true do
      while true do
        local new_k, new_v = next(inheritance_hierarchy[i], k)
        if new_k == nil then
          break
        elseif not keys[new_k] then
          keys[new_k] = true
          return new_k, new_v
        end
        k = new_k
      end
      i = i + 1
      if i > #inheritance_hierarchy then
        return nil
      end
      k = nil
    end
  end
  return iterator, obj, nil
end
