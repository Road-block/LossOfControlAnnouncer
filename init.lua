-- AddOn Template v1.0.0
local ns = select(2, ...)

function ns.addon:OnInitialize()
  ns.config.init()

  ns.commands.register_aliases('loca')

  ns.commands.register_handler(
      {},
      --[[ args_usage_text= ]] nil,  -- Root command handlers never take args.
      --[[ help_text= ]] ns.LOCALE['ROOT_COMMAND_HELP_TEXT'],
      function(cmd)
        ns.config.show_options()
      end)

  if ns.debug then
    ns.debug.on_initialize()
  end

  if ns.config.db.profile.values.settings.show_loaded_message then
    ns.print(ns.LOCALE['LOADED'])
  end
end

function ns.addon:OnEnable()
  ns.addon:RegisterEvent(
      'LOSS_OF_CONTROL_ADDED', ns.player_control.on_loss_of_control_added)

  if ns.debug then
    ns.debug.on_enable()
  end
end

function ns.addon:OnDisable()
  if ns.debug then
    ns.debug.on_disable()
  end

  ns.addon:UnregisterEvent('LOSS_OF_CONTROL_ADDED')
end
