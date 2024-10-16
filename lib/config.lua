-- AddOn Template v1.0.0
local ns = select(2, ...)
ns.config = ns.config or {}

-- The default schema version should always be 0 to ensure that schema_version
-- is always written.
ns.config.DEFAULT_SCHEMA_VERSION = 0

ns.config.db = nil

local _schema_version = nil
local _default_global_values = nil
local _default_profile_values = nil
local _upgrade_global_values_fn = nil
local _upgrade_profile_values_fn = nil
local _options_tabs = nil

local _options_panel = nil

function ns.config.configure(
    schema_version,
    default_global_values,
    default_profile_values,
    upgrade_global_values_fn,
    upgrade_profile_values_fn,
    options_tabs)  -- A "Profiles" tab will be appended automatically
  _schema_version = schema_version
  _default_global_values = default_global_values
  _default_profile_values = default_profile_values
  _upgrade_global_values_fn = upgrade_global_values_fn
  _upgrade_profile_values_fn = upgrade_profile_values_fn
  _options_tabs = options_tabs
end

-- Should be called after ns.config.configure.
function ns.config.add_debug_option(add_debug_option_fn)
  add_debug_option_fn(
      _options_tabs, _default_global_values, _default_profile_values)
end

local function _getter(t, info)
  for i = 1, #info - 1 do
    t = t[info[i]]
  end
  return t[info[#info]]
end

local function _setter(t, info, value)
  for i = 1, #info - 1 do
    t = t[info[i]]
  end
  t[info[#info]] = value
end

function ns.config.global_getter(info)
  return _getter(ns.config.db.global.values, info)
end

function ns.config.global_setter(info, value)
  _setter(ns.config.db.global.values, info, value)
end

function ns.config.profile_getter(info)
  return _getter(ns.config.db.profile.values, info)
end

function ns.config.profile_setter(info, value)
  _setter(ns.config.db.profile.values, info, value)
end

local function _make_default_values()
  return {
    global = {
      schema_version = ns.config.DEFAULT_SCHEMA_VERSION,
      values = _default_global_values,
    },
    profile = {
      schema_version = ns.config.DEFAULT_SCHEMA_VERSION,
      values = _default_profile_values,
    },
  }
end

local function _set_values_table(root, key, values_table)
  root[key] = {}
  for k, v in pairs(values_table) do
    if type(v) == 'table' then
      _set_values_table(root[key], k, v)
    else
      root[key][k] = v
    end
  end
end

local function _remove_values_table(root, key)
  local values_table = {}
  for k, v in pairs(root[key]) do
    if type(v) == 'table' then
      values_table[k] = _remove_values_table(root[key], k)
    else
      values_table[k] = v
      root[key][k] = nil
    end
  end
  root[key] = nil
  return values_table
end

local function _upgrade_profile_values(db)
  -- AceDB does weird metatable things to the db, so we can't just set a db
  -- value to a table of values. Instead, we have to add/remove each value one
  -- at a time.
  local old_profile_values = _remove_values_table(db.profile, 'values')
  local new_profile_values = _upgrade_profile_values_fn(
      db.profile.schema_version, old_profile_values)
  _set_values_table(db.profile, 'values', new_profile_values)
  db.profile.schema_version = _schema_version
end

local function _upgrade_values(db)
  -- AceDB does weird metatable things to the db, so we can't just set a db
  -- value to a table of values. Instead, we have to add/remove each value one
  -- at a time.
  local old_global_values = _remove_values_table(db.global, 'values')
  local new_global_values = _upgrade_global_values_fn(
      db.global.schema_version, old_global_values)
  _set_values_table(db.global, 'values', new_global_values)
  db.global.schema_version = _schema_version
  _upgrade_profile_values(db)
end

local function _on_profile_changed(event, db, profile)
  _upgrade_profile_values(ns.config.db)
end

local function _make_options()
  return {
    type = 'group',
    childGroups = 'tab',
    args = _options_tabs, -- The "Profiles" tab is added in ns.config.init()
  }
end

function ns.config.init()
  -- Initialize the database.
  ns.config.db = ns.AceDB:New(
      ns.addon.baseName .. 'DB',
      _make_default_values(),
      --[[ defaultProfile ]] true)
  _upgrade_values(ns.config.db)
  ns.config.db.RegisterCallback(
      --[[ self= ]] {},  -- Only used if the 3rd parameter is a string
      'OnProfileChanged',
      _on_profile_changed)
  ns.config.db.RegisterCallback(
      --[[ self= ]] {},  -- Only used if the 3rd parameter is a string
      'OnProfileCopied',
      _on_profile_changed)
  ns.config.db.RegisterCallback(
      --[[ self= ]] {},  -- Only used if the 3rd parameter is a string
      'OnProfileReset',
      _on_profile_changed)

  -- Set up the UI for configuring values in the database.
  local options = _make_options()
  options.args.profiles =
      ns.AceDBOptions:GetOptionsTable(ns.config.db)
  options.args.profiles.order = -1  -- Make the profiles tab last
  ns.AceConfig:RegisterOptionsTable(ns.addon.name, options)
  _options_panel = ns.AceConfigDialog:AddToBlizOptions(ns.addon.name)
end

function ns.config.replace_values_table(root, key, new_values_table)
  if root[key] then
    _remove_values_table(root, key)
  end
  if new_values_table then
    _set_values_table(root, key, new_values_table)
  end
end

function ns.config.show_options()
  -- Call InterfaceOptionsFrame_OpenToCategory twice to work around a bug:
  -- https://www.wowinterface.com/forums/showthread.php?t=54599
  InterfaceOptionsFrame_OpenToCategory(_options_panel)
  InterfaceOptionsFrame_OpenToCategory(_options_panel)
end
