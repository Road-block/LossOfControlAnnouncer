-- AddOn Template v1.0.0
local ns = select(2, ...)
ns.commands = ns.commands or {}

-- _subcommand_def = {
--   [<subcommand>] = <subcommand_info>
--   ...
-- }
-- subcommand_info is one of the following:
--   Subcommand:
--     [<subcommand>] = {
--       def = <subcommand_def>,  -- Another table of subcommand_info
--     }
--   Handler:
--     [<subcommand>] = {
--       fn = <handler>,
--       help_text = <help_text>,
--       args_usage_text = nil | <args_usage_text>,
--     }
local _subcommand_def = {}
local _root_handler_info = nil

local _aliases = {}

local function _print_aliases_help_text()
  ns.print(ns.LOCALE['COMMANDS_HELP_TEXT'])
  if #_aliases > 1 then
    print(ns.LOCALE['COMMAND_ALIASES_HELP_FN'](
        '|c' .. ns.utils.FontColorString.TITLE .. '/' ..
            table.concat(
                _aliases,
                '|r, |c' .. ns.utils.FontColorString.TITLE .. '/') ..
            '|r'))
  end
end

local function _print_subcommand_help_text(subcommand_info, cmd)
  local usage_text = '/' .. _aliases[1] .. ' ' .. table.concat(cmd, ' ')
  if subcommand_info.args_usage_text then
    usage_text = usage_text .. ' ' .. subcommand_info.args_usage_text
  end
  print(
      ns.utils.color_string(ns.utils.FontColorString.TITLE, usage_text) ..
          ' - ' .. subcommand_info.help_text)
end

local function _print_all_help_text(subcommand_def, cmd)
  if not cmd then
    cmd = {}
    _print_aliases_help_text()
    if _root_handler_info then
      _print_subcommand_help_text(_root_handler_info, cmd)
    end
  end
  for subcommand, info in ns.utils.pairs_sorted_by_keys_asc(subcommand_def) do
    local new_cmd = {unpack(cmd)}
    table.insert(new_cmd, subcommand)
    if info.fn then
      _print_subcommand_help_text(info, new_cmd)
    else
      _print_all_help_text(info.def, new_cmd)
    end
  end
end

function ns.commands.print_help(cmd)
  local def = _subcommand_def
  local info
  for _, subcommand in ipairs(cmd) do
    info = def[subcommand]
    def = info.def
  end
  ns.print(ns.LOCALE['COMMANDS_USAGE'])
  _print_subcommand_help_text(info, cmd)
end

local function _print_command_not_found_help_text(cmd)
  local prefix = '/' .. _aliases[1] .. ' '
  ns.print(ns.LOCALE['COMMAND_NOT_FOUND_FN'](
      ns.utils.color_string(
          ns.utils.FontColorString.TITLE,
          prefix .. table.concat(cmd, ' ')),
      ns.utils.color_string(
          ns.utils.FontColorString.TITLE,
          prefix .. ns.LOCALE['HELP_COMMAND'])))
end

local function _help_handler(cmd, args)
  if #args == 0 then
    _print_all_help_text(_subcommand_def)
    return
  end
  local def = _subcommand_def
  local new_cmd = {}
  for _, subcommand in ipairs(args) do
    table.insert(new_cmd, subcommand)
    local info = def[subcommand]
    if not info then
      _print_command_not_found_help_text(new_cmd)
      return
    end
    if info.fn then
      _print_subcommand_help_text(info, new_cmd)
      return
    end
    def = info.def
  end
  _print_command_not_found_help_text(new_cmd)
end

-- Register a 'help' subcommand in both English and the user's language.
_subcommand_def['help'] = {
  fn = _help_handler,
  help_text = ns.LOCALE['HELP_HELP_TEXT'],
  args_usage_text = ns.LOCALE['HELP_ARGS_USAGE_TEXT']
}
_subcommand_def[ns.LOCALE['HELP_COMMAND']] = _subcommand_def['help']

local function _parse_arg(arg_string, pos)
  local arg, new_pos = ns.addon:GetArgs(arg_string, --[[ numArgs= ]] 1, pos)
  -- GetArgs returns 1e9 when there are no more args
  return arg, new_pos ~= 1e9 and new_pos or nil
end

local function _parse_remaining_args(arg_string, pos)
  local args = {}
  local arg
  while pos do
    arg, pos = _parse_arg(arg_string, pos)
    if arg ~= nil then
      table.insert(args, arg)
    end
  end
  return args
end

local function _on_command(arg_string)
  local def = _subcommand_def
  local cmd = {}
  local pos = 1
  local arg
  while pos do
    arg, pos = _parse_arg(arg_string, pos)
    -- If there are no args left, then either they were trying to invoke the
    -- root handler (which never takes any args), or the command was unfinished
    -- (in which case stop iterating).
    if not arg then
      if #cmd == 0 and _root_handler_info then
        _root_handler_info.fn(cmd, {})
        return
      else
        break
      end
    end
    table.insert(cmd, arg)
    local subcommand_info = def[arg]
    -- If it's an unknown subcommand, print an error.
    if not subcommand_info then
      _print_command_not_found_help_text(cmd)
      return
    end
    -- If it's a handler, call the function.
    if subcommand_info.fn then
      subcommand_info.fn(cmd, _parse_remaining_args(arg_string, pos))
      return
    end
    -- Otherwise it's a subcommand, so keep going.
    def = subcommand_info.def
  end
  _print_command_not_found_help_text(cmd)
end

-- The first alias registered will be used in help messages.
function ns.commands.register_aliases(...)
  for _, alias in ipairs({...}) do
    table.insert(_aliases, alias)
    ns.addon:RegisterChatCommand(alias, _on_command)
  end
end

-- args_usage_text can be nil for any handlers that don't take any args.
-- Use command_def={} for the root handler. Note that the root handler never
-- takes any args (otherwise we could never have any additional handlers).
function ns.commands.register_handler(
    command_def, args_usage_text, help_text, handler)
  assert(
      #_aliases > 0,
      'Must register command aliases before registering command handlers')
  local error_prefix =
      'Command handler already registered for "/' .. _aliases[1]
  if not command_def or #command_def == 0 then
    assert(not _root_handler_info, error_prefix .. '"')
    assert(
        not args_usage_text,
        'Root command handlers cannot expect any arguments,' ..
            ' so args_usage_text should be nil')
    _root_handler_info = {
      fn = handler,
      help_text = help_text,
    }
    return
  end
  local def = _subcommand_def
  for i = 1, #command_def - 1 do
    local subcommand = command_def[i]
    local subcommand_info = def[subcommand]
    if subcommand_info then
      def = subcommand_info.def
      assert(
          def,
          error_prefix .. ' ' .. table.concat(command_def, ' ', 1, i) .. '"')
    else
      local new_def = {}
      def[subcommand] = {def = new_def}
      def = new_def
    end
  end
  local last_subcommand = command_def[#command_def]
  assert(
      not def[last_subcommand],
      error_prefix .. ' ' .. table.concat(command_def, ' ') .. '"')
  def[last_subcommand] = {
    fn = handler,
    help_text = help_text,
    args_usage_text = args_usage_text,
  }
end
