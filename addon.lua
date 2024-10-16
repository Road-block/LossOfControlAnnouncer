-- AddOn Template v1.0.0
local ns = select(2, ...)

ns.AceAddon = LibStub('AceAddon-3.0')
ns.AceConfig = LibStub('AceConfig-3.0')
ns.AceConfigDialog = LibStub('AceConfigDialog-3.0')
ns.AceDB = LibStub('AceDB-3.0')
ns.AceDBOptions = LibStub('AceDBOptions-3.0')

ns.addon = ns.AceAddon:NewAddon(
    ns.LOCALE['ADDON_NAME'],
    'AceConsole-3.0',
    'AceEvent-3.0')

-- Alias the print/printf methods for convenience.
function ns.print(...)
  ns.addon:Print(...)
end

function ns.printf(...)
  ns.addon:Printf(...)
end
