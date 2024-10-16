local ns = select(2, ...)
ns.player_control = ns.player_control or {}

ns.player_control.ANNOUNCE_CHANNEL_BATTLEGROUND = 'INSTANCE_CHAT'
ns.player_control.ANNOUNCE_CHANNEL_RAID = 'RAID'
ns.player_control.ANNOUNCE_CHANNEL_PARTY = 'PARTY'
ns.player_control.ANNOUNCE_CHANNEL_YELL = 'YELL'
ns.player_control.ANNOUNCE_CHANNEL_SAY = 'SAY'
ns.player_control.ANNOUNCE_CHANNEL_SYSTEM = 'SYSTEM'
ns.player_control.ANNOUNCE_CHANNEL_PRINT = 'PRINT'

local _TEST_LOC_DATA = {
  locType = 'STUN_MECHANIC',
  displayText = ns.LOCALE['TEST_LOC_DATA_DISPLAY_TEXT'],
  timeRemaining = 5,
}

local function _get_situation_settings()
  local settings = ns.config.db.profile.values.settings
  local _, instance_type = IsInInstance()
  if instance_type == 'arena' then
    return settings.arena
  elseif instance_type == 'pvp' then
    return settings.battleground
  elseif instance_type == 'raid' then
    return settings.raid
  elseif instance_type == 'party' then
    return settings.dungeon
  else
    if IsInRaid() then
      return settings.world_raid
    elseif IsInGroup() then
      return settings.world_party
    else
      return settings.world_solo
    end
  end
end

local function _should_announce(situation_settings, loc_data)
  -- Effect types listed here:
  -- https://authors.curseforge.com/forums/world-of-warcraft/general-chat/lua-code-discussion/226080-stunned
  -- https://github.com/RagedUnicorn/wow-classic-gearmenu/blob/master/code/GM_CombatQueue.lua#L129-L141
  -- https://wago.io/DWAQHFVqh
  -- https://www.curseforge.com/wow/addons/d4hp/issues/5
  if loc_data.locType == 'CHARM' or loc_data.locType == 'POSSESS' then
    return situation_settings.effect_types.charm
  elseif loc_data.locType == 'CONFUSE' then
    return situation_settings.effect_types.confuse
  elseif loc_data.locType == 'DISARM' then
    return situation_settings.effect_types.disarm
  elseif loc_data.locType == 'FEAR' or loc_data.locType == 'FEAR_MECHANIC' then
    return situation_settings.effect_types.fear
  elseif loc_data.locType == 'PACIFY' then
    return situation_settings.effect_types.pacify
  elseif loc_data.locType == 'PACIFYSILENCE' then
    return situation_settings.effect_types.pacify or
        situation_settings.effect_types.silence
  elseif loc_data.locType == 'ROOT' then
    return situation_settings.effect_types.root
  elseif loc_data.locType == 'SCHOOL_INTERRUPT' then
    return situation_settings.effect_types.school_interrupt
  elseif loc_data.locType == 'SILENCE' then
    return situation_settings.effect_types.silence
  elseif loc_data.locType == 'STUN' or loc_data.locType == 'STUN_MECHANIC' then
    return situation_settings.effect_types.stun
  else
    ns.print(ns.LOCALE['ERROR_UNKNOWN_LOC_TYPE_FN'](loc_data))
    return false
  end
end

local function _get_school_text(school)
  if school then
    return GetSchoolString(school)
  else
    return ns.LOCALE['EFFECT_MESSAGE_SCHOOL_UNKNOWN']
  end
end

local function _get_effect_text(loc_data)
  if loc_data.locType == 'SCHOOL_INTERRUPT' then
    local school_text = _get_school_text(loc_data.lockoutSchool)
    return ns.LOCALE['EFFECT_MESSAGE_SCHOOL_INTERRUPT_FN'](school_text)
  else
    return loc_data.displayText
  end
end

local function _get_time_remaining_text(loc_data)
  -- From the documentation:
  -- https://wowpedia.fandom.com/wiki/API_C_LossOfControl.GetActiveLossOfControlData
  -- Loss of Control debuffs that are applied only while standing in an Area of
  -- Effect may not include a startTime, timeRemaining nor duration in the table
  -- returned.
  if loc_data.timeRemaining then
    local rounded_to_one_decimal =
        math.floor(loc_data.timeRemaining * 10 + 0.5) / 10
    return tostring(rounded_to_one_decimal)
  else
    return ns.LOCALE['EFFECT_MESSAGE_TIME_REMAINING_UNKNOWN']
  end
end

local function _get_message(situation_settings, loc_data)
  return ns.utils.unescape(
      situation_settings.announce_text,
      {
        e = _get_effect_text(loc_data),
        t = _get_time_remaining_text(loc_data),
        p = UnitName('player'),
      })
end

local function _announce(situation_settings, loc_data)
  local message = _get_message(situation_settings, loc_data)
  if situation_settings.announce_channel ==
      ns.player_control.ANNOUNCE_CHANNEL_SYSTEM then  
    SendSystemMessage(message)
  elseif situation_settings.announce_channel ==
      ns.player_control.ANNOUNCE_CHANNEL_PRINT then
    ns.print(message)
  else
    SendChatMessage(message, situation_settings.announce_channel)
  end
end

function ns.player_control.on_loss_of_control_added(event, ...)
  if ns.debug then
    ns.debug.debug_loc_event(event, ...)
  end
  if not ns.config.db.profile.values.settings.enabled then
    return
  end
  local situation_settings = _get_situation_settings()
  if not situation_settings.enabled then
    return
  end
  local loc_data_count = C_LossOfControl.GetActiveLossOfControlDataCount()
  local max_time_remaining_loc_data = nil
  for i = 1, loc_data_count do
    local loc_data = C_LossOfControl.GetActiveLossOfControlData(i)
    if _should_announce(situation_settings, loc_data) and
        (not max_time_remaining_loc_data or
         not loc_data.timeRemaining or  -- Assume timeRemaining is infinite
         loc_data.timeRemaining > max_time_remaining_loc_data.timeRemaining)
        then
      max_time_remaining_loc_data = loc_data
    end
  end
  if not max_time_remaining_loc_data then
    return
  end
  _announce(situation_settings, max_time_remaining_loc_data)
end

function ns.player_control.test_announcement(info)
  local situation_settings = ns.config.db.profile.values.settings[info[2]]
  _announce(situation_settings, _TEST_LOC_DATA)
end
