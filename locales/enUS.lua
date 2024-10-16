-- AddOn Template v1.0.0
local _addon_basename, ns = ...

local L = ns.AceLocale:NewLocale(
    _addon_basename,
    'enUS',
    --[[ isDefault= ]] true,
    --[[ silent= ]] false)

if L then

local _ADDON_NAME = 'Loss of Control Announcer'
L['ADDON_NAME'] = _ADDON_NAME

L['LOADED'] = _ADDON_NAME .. ' loaded'

-- Used by lib/commands
L['COMMANDS_HELP_TEXT'] = 'Commands:'
L['COMMAND_ALIASES_HELP_FN'] = function(aliases) return 'Aliases: ' .. aliases end
L['COMMANDS_USAGE'] = 'Usage:'
L['COMMAND_NOT_FOUND_FN'] = function(command, help_command)
  return 'Command not found: ' .. command .. '\nTry using ' .. help_command
end
L['HELP_COMMAND'] = 'help'
L['HELP_HELP_TEXT'] =
    'Prints the help for the specified command. If no command is specified, the help for all commands is printed.'
L['HELP_ARGS_USAGE_TEXT'] = '[<command>]'

-- Commands:
L['ROOT_COMMAND_HELP_TEXT'] = 'Opens the options menu.'

-- Options Menu:
L['SETTINGS_TAB'] = 'Settings'

L['ENABLED'] = 'Enable announcements'
L['ENABLED_DESC'] = 'If unchecked, disables all announcements'

L['SHOW_LOADED_MESSAGE'] = 'Show "loaded" message'
L['SHOW_LOADED_MESSAGE_DESC'] = 'Shows the "loaded" message when the addon is loaded'

L['TEST_ANNOUNCEMENT'] = 'Test Announcement'
L['TEST_ANNOUNCEMENT_DESC'] = 'Click to test your announcement settings'

L['SITUATION_ARENA'] = 'Arena'
L['SITUATION_BATTLEGROUND'] = 'Battleground'
L['SITUATION_RAID'] = 'Raid'
L['SITUATION_DUNGEON'] = 'Dungeon'
L['SITUATION_WORLD_RAID'] = 'World (raid)'
L['SITUATION_WORLD_PARTY'] = 'World (party)'
L['SITUATION_WORLD_SOLO'] = 'World (solo)'

L['SITUATION_ENABLED'] = 'Enabled'
L['SITUATION_ENABLED_DESC'] = 'Toggles announcements while in this type of instance/group'

L['ANNOUNCE_CHANNEL'] = 'Announce Channel'
L['ANNOUNCE_CHANNEL_DESC'] = 'The channel in which to announce loss of control effects\n\n"Yell" and "Say" are only allowed in instances (due to technical limitations of the Blizzard API)'
L['ANNOUNCE_CHANNEL_BATTLEGROUND'] = 'Battleground'
L['ANNOUNCE_CHANNEL_RAID'] = 'Raid'
L['ANNOUNCE_CHANNEL_PARTY'] = 'Party'
L['ANNOUNCE_CHANNEL_YELL'] = 'Yell'
L['ANNOUNCE_CHANNEL_SAY'] = 'Say'
L['ANNOUNCE_CHANNEL_SYSTEM'] = 'System'
L['ANNOUNCE_CHANNEL_PRINT'] = 'Print'

L['ANNOUNCE_TEXT'] = 'Announce Text'
L['ANNOUNCE_TEXT_DESC'] = 'The text to announce\n\n%e: Effect text (e.g., "Stunned")\n%t: Time remaining (in seconds)\n%p: Player name\n%%: Literal percent sign'
L['DEFAULT_ANNOUNCE_TEXT'] = '%e for %t seconds'

L['EFFECT_TYPES'] = 'Effect Types'
L['EFFECT_TYPES_DESC'] = 'Choose the types of effects to announce.\n\nIt is highly encouraged to create different settings profiles (using the Profiles tab above) for various roles (e.g., "Physical Melee DPS", "Caster DPS", "Healer", etc.). That way only effect types that matter are announced (e.g., no one cares if a physical melee dps is silenced or if a caster/healer is disarmed).'
L['EFFECT_TYPE_CHARM'] = 'Charm/Possess'
L['EFFECT_TYPE_CHARM_DESC'] = 'Completely under the control of someone else'
L['EFFECT_TYPE_CONFUSE'] = 'Confuse'
L['EFFECT_TYPE_CONFUSE_DESC'] = 'Complete loss of control and walking in random directions'
L['EFFECT_TYPE_DISARM'] = 'Disarm'
L['EFFECT_TYPE_DISARM_DESC'] = 'Unable to make attacks with weapons'
L['EFFECT_TYPE_FEAR'] = 'Fear'
L['EFFECT_TYPE_FEAR_DESC'] = 'Complete loss of control and running in random directions'
L['EFFECT_TYPE_PACIFY'] = 'Pacify'
L['EFFECT_TYPE_PACIFY_DESC'] = 'Unable to attack'
L['EFFECT_TYPE_ROOT'] = 'Root'
L['EFFECT_TYPE_ROOT_DESC'] = 'Unable to move'
L['EFFECT_TYPE_SCHOOL_INTERRUPT'] = 'School Interrupt'
L['EFFECT_TYPE_SCHOOL_INTERRUPT_DESC'] = 'Unable to cast spells from a particular school'
L['EFFECT_TYPE_SILENCE'] = 'Silence'
L['EFFECT_TYPE_SILENCE_DESC'] = 'Unable to cast spells'
L['EFFECT_TYPE_STUN'] = 'Sleep/Stun'
L['EFFECT_TYPE_STUN_DESC'] = 'Complete loss of control and standing still'

L['ERROR_UNKNOWN_LOC_TYPE_FN'] = function(loc_data)
  return 'You found a Loss of Control Effect Type that\'s not supported! ' ..
      'Please leave a comment on the CurseForge page for this addon!\n' ..
      'https://www.curseforge.com/wow/addons/loss-of-control-announcer\n' ..
      '(Include the following info: "locType: ' .. loc_data.locType ..
      ', spellID: ' .. tostring(loc_data.spellID)
end

L['EFFECT_MESSAGE_SCHOOL_INTERRUPT_FN'] = function(school)
  return 'Locked out of ' .. school .. ' spells'
end
L['EFFECT_MESSAGE_SCHOOL_UNKNOWN'] = 'Unknown School'
L['EFFECT_MESSAGE_TIME_REMAINING_UNKNOWN'] = 'Unknown'

L['TEST_LOC_DATA_DISPLAY_TEXT'] = 'Stunned'

end
