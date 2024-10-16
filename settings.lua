-- AddOn Template v1.0.0
local ns = select(2, ...)

local _SCHEMA_VERSION = 3

local _DEFAULT_GLOBAL_VALUES = {
}

local _DEFAULT_PROFILE_VALUES = {
  settings = {
    enabled = true,    
    show_loaded_message = true,
    arena = {
      enabled = true,
      announce_channel = ns.player_control.ANNOUNCE_CHANNEL_PARTY,
      announce_text = ns.LOCALE['DEFAULT_ANNOUNCE_TEXT'],
      effect_types = {
        charm = true,
        confuse = true,
        disarm = true,
        fear = true,
        pacify = true,
        root = true,
        school_interrupt = true,
        silence = true,
        stun = true,
      },
    },
    battleground = {
      enabled = true,
      announce_channel = ns.player_control.ANNOUNCE_CHANNEL_SAY,
      announce_text = ns.LOCALE['DEFAULT_ANNOUNCE_TEXT'],
      effect_types = {
        charm = true,
        confuse = true,
        disarm = false,
        fear = true,
        pacify = true,
        root = true,
        school_interrupt = true,
        silence = true,
        stun = true,
      },
    },
    raid = {
      enabled = true,
      announce_channel = ns.player_control.ANNOUNCE_CHANNEL_SAY,
      announce_text = ns.LOCALE['DEFAULT_ANNOUNCE_TEXT'],
      effect_types = {
        charm = true,
        confuse = true,
        disarm = false,
        fear = true,
        pacify = true,
        root = true,
        school_interrupt = true,
        silence = true,
        stun = true,
      },
    },
    dungeon = {
      enabled = true,
      announce_channel = ns.player_control.ANNOUNCE_CHANNEL_SAY,
      announce_text = ns.LOCALE['DEFAULT_ANNOUNCE_TEXT'],
      effect_types = {
        charm = true,
        confuse = true,
        disarm = false,
        fear = true,
        pacify = true,
        root = true,
        school_interrupt = true,
        silence = true,
        stun = true,
      },
    },
    world_raid = {
      enabled = true,
      announce_channel = ns.player_control.ANNOUNCE_CHANNEL_RAID,
      announce_text = ns.LOCALE['DEFAULT_ANNOUNCE_TEXT'],
      effect_types = {
        charm = true,
        confuse = true,
        disarm = false,
        fear = true,
        pacify = true,
        root = true,
        school_interrupt = true,
        silence = true,
        stun = true,
      },
    },
    world_party = {
      enabled = true,
      announce_channel = ns.player_control.ANNOUNCE_CHANNEL_PARTY,
      announce_text = ns.LOCALE['DEFAULT_ANNOUNCE_TEXT'],
      effect_types = {
        charm = true,
        confuse = true,
        disarm = false,
        fear = true,
        pacify = true,
        root = true,
        school_interrupt = true,
        silence = true,
        stun = true,
      },
    },
    world_solo = {
      enabled = false,
      announce_channel = ns.player_control.ANNOUNCE_CHANNEL_PRINT,
      announce_text = ns.LOCALE['DEFAULT_ANNOUNCE_TEXT'],
      effect_types = {
        charm = true,
        confuse = true,
        disarm = true,
        fear = true,
        pacify = true,
        root = true,
        school_interrupt = true,
        silence = true,
        stun = true,
      },
    },
  },
}

local function _make_situation_args(
    settings_key,
    include_battleground,
    include_raid,
    include_party,
    include_yell_say)
  local disabled_fn = function()
    local settings = ns.config.db.profile.values.settings
    return not settings[settings_key].enabled
  end
  local announce_channel_sorting = {}
  local announce_channel_values = {
    [ns.player_control.ANNOUNCE_CHANNEL_SYSTEM] =
        ns.LOCALE['ANNOUNCE_CHANNEL_SYSTEM'],
    [ns.player_control.ANNOUNCE_CHANNEL_PRINT] =
        ns.LOCALE['ANNOUNCE_CHANNEL_PRINT'],
  }
  if include_battleground then
    table.insert(
        announce_channel_sorting,
        ns.player_control.ANNOUNCE_CHANNEL_BATTLEGROUND)
    announce_channel_values[ns.player_control.ANNOUNCE_CHANNEL_BATTLEGROUND] =
        ns.LOCALE['ANNOUNCE_CHANNEL_BATTLEGROUND']
  end
  if include_raid then
    table.insert(
        announce_channel_sorting,
        ns.player_control.ANNOUNCE_CHANNEL_RAID)
    announce_channel_values[ns.player_control.ANNOUNCE_CHANNEL_RAID] =
        ns.LOCALE['ANNOUNCE_CHANNEL_RAID']
  end
  if include_party then
    table.insert(
        announce_channel_sorting,
        ns.player_control.ANNOUNCE_CHANNEL_PARTY)
    announce_channel_values[ns.player_control.ANNOUNCE_CHANNEL_PARTY] =
        ns.LOCALE['ANNOUNCE_CHANNEL_PARTY']
  end
  -- SendChatMessage is partially hw event protected:
  --   - "CHANNEL" is protected
  --   - "SAY", "YELL" are protected while outside of instances/raids
  -- https://wowpedia.fandom.com/wiki/Patch_8.2.5/API_changes
  -- https://twitter.com/deadlybossmods/status/1176685822223011842
  if include_yell_say then
    table.insert(
        announce_channel_sorting,
        ns.player_control.ANNOUNCE_CHANNEL_YELL)
    announce_channel_values[ns.player_control.ANNOUNCE_CHANNEL_YELL] =
        ns.LOCALE['ANNOUNCE_CHANNEL_YELL']
    table.insert(
        announce_channel_sorting,
        ns.player_control.ANNOUNCE_CHANNEL_SAY)
    announce_channel_values[ns.player_control.ANNOUNCE_CHANNEL_SAY] =
        ns.LOCALE['ANNOUNCE_CHANNEL_SAY']
  end
  table.insert(
        announce_channel_sorting,
        ns.player_control.ANNOUNCE_CHANNEL_SYSTEM)
  table.insert(
        announce_channel_sorting,
        ns.player_control.ANNOUNCE_CHANNEL_PRINT)
  return {
    enabled = {
      order = 1,
      type = 'toggle',
      width = 'full',
      name = ns.LOCALE['SITUATION_ENABLED'],
      desc = ns.LOCALE['SITUATION_ENABLED_DESC'],
    },
    announce_channel = {
      order = 2,
      type = 'select',
      style = 'dropdown',
      disabled = disabled_fn,
      name = ns.LOCALE['ANNOUNCE_CHANNEL'],
      desc = ns.LOCALE['ANNOUNCE_CHANNEL_DESC'],
      sorting = announce_channel_sorting,
      values = announce_channel_values,
    },
    announce_text = {
      order = 3,
      type = 'input',
      width = 'full',
      disabled = disabled_fn,
      name = ns.LOCALE['ANNOUNCE_TEXT'],
      desc = ns.LOCALE['ANNOUNCE_TEXT_DESC'],
    },
    test_announcement = {
      order = 3,
      type = 'execute',
      disabled = disabled_fn,
      name = ns.LOCALE['TEST_ANNOUNCEMENT'],
      desc = ns.LOCALE['TEST_ANNOUNCEMENT_DESC'],
      func = ns.player_control.test_announcement,
    },
    effect_types = {
      order = 4,
      type = 'group',
      inline = true,
      disabled = disabled_fn,
      name = ns.LOCALE['EFFECT_TYPES'],
      args = {
        desc = {
          order = 1,
          type = 'description',
          name = ns.LOCALE['EFFECT_TYPES_DESC'],
        },
        charm = {
          order = 2,
          type = 'toggle',
          name = ns.LOCALE['EFFECT_TYPE_CHARM'],
          desc = ns.LOCALE['EFFECT_TYPE_CHARM_DESC'],
        },
        confuse = {
          order = 3,
          type = 'toggle',
          name = ns.LOCALE['EFFECT_TYPE_CONFUSE'],
          desc = ns.LOCALE['EFFECT_TYPE_CONFUSE_DESC'],
        },
        disarm = {
          order = 4,
          type = 'toggle',
          name = ns.LOCALE['EFFECT_TYPE_DISARM'],
          desc = ns.LOCALE['EFFECT_TYPE_DISARM_DESC'],
        },
        fear = {
          order = 5,
          type = 'toggle',
          name = ns.LOCALE['EFFECT_TYPE_FEAR'],
          desc = ns.LOCALE['EFFECT_TYPE_FEAR_DESC'],
        },
        pacify = {
          order = 6,
          type = 'toggle',
          name = ns.LOCALE['EFFECT_TYPE_PACIFY'],
          desc = ns.LOCALE['EFFECT_TYPE_PACIFY_DESC'],
        },
        root = {
          order = 7,
          type = 'toggle',
          name = ns.LOCALE['EFFECT_TYPE_ROOT'],
          desc = ns.LOCALE['EFFECT_TYPE_ROOT_DESC'],
        },
        school_interrupt = {
          order = 8,
          type = 'toggle',
          name = ns.LOCALE['EFFECT_TYPE_SCHOOL_INTERRUPT'],
          desc = ns.LOCALE['EFFECT_TYPE_SCHOOL_INTERRUPT_DESC'],
        },
        silence = {
          type = 'toggle',
          order = 9,
          name = ns.LOCALE['EFFECT_TYPE_SILENCE'],
          desc = ns.LOCALE['EFFECT_TYPE_SILENCE_DESC'],
        },
        stun = {
          order = 10,
          type = 'toggle',
          name = ns.LOCALE['EFFECT_TYPE_STUN'],
          desc = ns.LOCALE['EFFECT_TYPE_STUN_DESC'],
        },
      },
    },
  }
end

local _OPTIONS_TABS = {
  settings = {
    order = 1,
    type = 'group',
    childGroups = 'tree',
    name = ns.LOCALE['SETTINGS_TAB'],
    args = {
      enabled = {
        order = 1,
        type = 'toggle',
        width = 'full',
        name = ns.LOCALE['ENABLED'],
        desc = ns.LOCALE['ENABLED_DESC'],
      },
      show_loaded_message = {
        order = 2,        
        type = 'toggle',
        width = 'full',
        name = ns.LOCALE['SHOW_LOADED_MESSAGE'],
        desc = ns.LOCALE['SHOW_LOADED_MESSAGE_DESC'],
      },
      arena = {
        order = 3,        
        type = 'group',
        name = ns.LOCALE['SITUATION_ARENA'],
        args = _make_situation_args(
          --[[ settings_key= ]] 'arena',
          --[[ include_battleground= ]] false,
          --[[ include_raid= ]] false,
          --[[ include_party= ]] true,
          --[[ include_yell_say= ]] true),
      },
      battleground = {
        order = 4,
        type = 'group',
        name = ns.LOCALE['SITUATION_BATTLEGROUND'],
        args = _make_situation_args(
          --[[ settings_key= ]] 'battleground',
          --[[ include_battleground= ]] true,
          --[[ include_raid= ]] false,
          --[[ include_party ]] true,
          --[[ include_yell_say= ]] true),
      },
      raid = {
        order = 5,
        type = 'group',
        name = ns.LOCALE['SITUATION_RAID'],
        args = _make_situation_args(
          --[[ settings_key= ]] 'raid',
          --[[ include_battleground= ]] false,
          --[[ include_raid= ]] true,
          --[[ include_party ]] true,
          --[[ include_yell_say= ]] true),
      },
      dungeon = {
        order = 6,
        type = 'group',
        name = ns.LOCALE['SITUATION_DUNGEON'],
        args = _make_situation_args(
          --[[ settings_key= ]] 'dungeon',
          --[[ include_battleground= ]] false,
          --[[ include_raid= ]] false,
          --[[ include_party ]] true,
          --[[ include_yell_say= ]] true),
      },
      world_raid = {
        order = 7,
        type = 'group',
        name = ns.LOCALE['SITUATION_WORLD_RAID'],
        args = _make_situation_args(
          --[[ settings_key= ]] 'world_raid',
          --[[ include_battleground= ]] false,
          --[[ include_raid= ]] true,
          --[[ include_party ]] true,
          --[[ include_yell_say= ]] false),
      },
      world_party = {
        order = 8,
        type = 'group',
        name = ns.LOCALE['SITUATION_WORLD_PARTY'],
        args = _make_situation_args(
          --[[ settings_key= ]] 'world_party',
          --[[ include_battleground= ]] false,
          --[[ include_raid= ]] false,
          --[[ include_party ]] true,
          --[[ include_yell_say= ]] false),
      },
      world_solo = {
        order = 9,
        type = 'group',
        name = ns.LOCALE['SITUATION_WORLD_SOLO'],
        args = _make_situation_args(
          --[[ settings_key= ]] 'world_solo',
          --[[ include_battleground= ]] false,
          --[[ include_raid= ]] false,
          --[[ include_party ]] false,
          --[[ include_yell_say= ]] false),
      },
    },
    get = ns.config.profile_getter,
    set = ns.config.profile_setter,
  },
}

-- Copied from ns.config._set_values_table (v1.1.0), but modified to leave the
-- root table intact and simply overwrite values from values_table (as opposed 
-- to replacing everything in the root table with the values from values_table).
local function _add_values_table(root, key, values_table)
  root[key] = root[key] or {}
  for k, v in pairs(values_table) do
    if type(v) == 'table' then
      _add_values_table(root[key], k, v)
    else
      root[key][k] = v
    end
  end
end

-- Copied verbatim from ns.config (v1.1.0).
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

-- Fix old versions (v1.0.3 and earlier) of ns.config which used to store values
-- in ns.config.db.<global|profile>.settings instead of
-- ns.config.db.<global|profile>.values.
local function _fix_old_settings(db_key, old_values)
  local db = ns.config.db[db_key]
  if not db.settings then
    return
  end
  -- Remove the old "settings" table from the db.
  local old_settings = _remove_values_table(db, 'settings')
  -- Overwrite values in old_values with ones from old_settings.
  _add_values_table({old_values}, 1, old_settings)
  return
end

local function _upgrade_global_values(old_schema_version, old_global_values)
  assert(
      old_schema_version >= ns.config.DEFAULT_SCHEMA_VERSION and
          old_schema_version <= _SCHEMA_VERSION,
      'Invalid global values database schema version: ' ..
          tostring(old_schema_version))
  _fix_old_settings('global', old_global_values)
  if old_schema_version == ns.config.DEFAULT_SCHEMA_VERSION then
    return _DEFAULT_GLOBAL_VALUES
  elseif old_schema_version == _SCHEMA_VERSION then
    return old_global_values
  end
  local new_global_values = ns.utils.deep_copy(old_global_values)
  for schema_version = old_schema_version, _SCHEMA_VERSION - 1 do
    if schema_version == 1 then
      -- Nothing to upgrade
    elseif schema_version == 2 then
      -- Nothing to upgrade
    else
      error(
          'No handler to upgrade global values database from schema ' ..
          tostring(schema_version) .. ' to ' .. tostring(schema_version + 1))
    end
  end
  return new_global_values
end

local function _upgrade_profile_values(old_schema_version, old_profile_values)
  assert(
      old_schema_version >= ns.config.DEFAULT_SCHEMA_VERSION and
          old_schema_version <= _SCHEMA_VERSION,
      'Invalid profile values database schema version: ' ..
          tostring(old_schema_version))
  _fix_old_settings('profile', old_profile_values)
  if old_schema_version == ns.config.DEFAULT_SCHEMA_VERSION then
    return _DEFAULT_PROFILE_VALUES
  elseif old_schema_version == _SCHEMA_VERSION then
    return old_profile_values
  end
  local new_profile_values = ns.utils.deep_copy(old_profile_values)
  for schema_version = old_schema_version, _SCHEMA_VERSION - 1 do
    if schema_version == 1 then
      -- settings.enabled was added.
      new_profile_values.settings.enabled =
          _DEFAULT_PROFILE_VALUES.settings.enabled

      -- settings.debug was removed.
      new_profile_values.settings.debug = nil

      -- settings.effect_types was replaced by
      -- settings.<situation>.effect_types, so it's better to use the defaults
      -- rather than try to infer what the user intended for each situation.
      new_profile_values.settings.effect_types = nil
      new_profile_values.settings.arena =
          ns.utils.deep_copy(_DEFAULT_PROFILE_VALUES.settings.arena)
      new_profile_values.settings.battleground =
          ns.utils.deep_copy(_DEFAULT_PROFILE_VALUES.settings.battleground)
      new_profile_values.settings.raid =
          ns.utils.deep_copy(_DEFAULT_PROFILE_VALUES.settings.raid)
      new_profile_values.settings.dungeon =
          ns.utils.deep_copy(_DEFAULT_PROFILE_VALUES.settings.dungeon)
      new_profile_values.settings.world_raid =
          ns.utils.deep_copy(_DEFAULT_PROFILE_VALUES.settings.world_raid)
      new_profile_values.settings.world_party =
          ns.utils.deep_copy(_DEFAULT_PROFILE_VALUES.settings.world_party)
      new_profile_values.settings.world_solo =
          ns.utils.deep_copy(_DEFAULT_PROFILE_VALUES.settings.world_solo)

      -- settings.announce_channels was replaced by
      -- settings.<situation>.announce_channel, so it's better to use the
      -- defaults rather than try to infer what the user intended for each
      -- situation.
      new_profile_values.settings.announce_channels = nil
    elseif schema_version == 2 then
      -- The ns.player_control.ANNOUNCE_CHANNEL_BATTLEGROUND value for
      -- settings.battleground.announce_channel was changed from 'BATTLEGROUND'
      -- to 'INSTANCE_CHAT'.
      if new_profile_values.settings.battleground.announce_channel ==
          'BATTLEGROUND' then
        new_profile_values.settings.battleground.announce_channel =
            ns.player_control.ANNOUNCE_CHANNEL_BATTLEGROUND
      end
    else
      error(
          'No handler to upgrade profile values database from schema ' ..
          tostring(schema_version) .. ' to ' .. tostring(schema_version + 1))
    end
  end
  return new_profile_values
end

ns.config.configure(
    _SCHEMA_VERSION,
    _DEFAULT_GLOBAL_VALUES,
    _DEFAULT_PROFILE_VALUES,
    _upgrade_global_values,
    _upgrade_profile_values,
    _OPTIONS_TABS)
