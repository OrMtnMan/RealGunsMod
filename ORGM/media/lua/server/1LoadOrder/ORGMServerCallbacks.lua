--[[- Callback Functions.

All events are hooked in `ORGMServerEvents.lua` and call these functions.

It is unlikely that you will need to call any of these functions manually.

@module ORGM.Server.Callbacks
@author Fenris_Wolf
@release v3.09
@copyright 2018 **File:** server/1LoadOrder/ORGMServerCallbacks.lua

]]
local ORGM = ORGM
local Server = ORGM.Server
local Callbacks = ORGM.Server.Callbacks
local CommandHandler = ORGM.Server.CommandHandler
local table = table
local tostring = tostring
local ipairs = ipairs
local pairs = pairs
local isServer = isServer

require 'Items/SuburbsDistributions'
require 'Items/Distributions'

local RemoveTable = {
    "Pistol", "Shotgun", "Sawnoff", "VarmintRifle", "HuntingRifle",
    "Bullets9mm", "ShotgunShells", "223Bullets", "308Bullets",
    "BulletsBox", "ShotgunShellsBox", "223Box", "308Box",
    "HuntingRifleExtraClip", "IronSight", "x2Scope", "x4Scope", "x8Scope",
    "AmmoStraps", "Sling", "FiberglassStock", "RecoilPad", "Laser",
    "RedDot", "ChokeTubeFull", "ChokeTubeImproved"
}

--[[- Removes vanilla firearms and ammo from the Distributions tables.

Triggered on the OnPostDistributionMerge event if ORGM.Settings.RemoveBaseFirearms is true

]]
Callbacks.removeBaseFirearms = function()
    if not ORGM.Settings.RemoveBaseFirearms then return end

    for roomName, room in pairs(SuburbsDistributions) do
        ORGM.log(ORGM.VERBOSE, "Spawn: Removing Distributions for " .. tostring(roomName))
        if room.items ~= nil then
            local index=1
            while index <= #room.items do
                local thisItem = room.items[index]
                local removed = false
                for _, removeItem in ipairs(RemoveTable) do
                    if thisItem == removeItem or thisItem == "Base." .. removeItem then
                        ORGM.log(ORGM.VERBOSE, "Spawn: Removing  " .. tostring(thisItem))
                        table.remove(room.items, index)
                        table.remove(room.items, index)
                        removed = true
                        break
                    end
                end
                if not removed then
                    index = index + 1
                end
            end
        else
            for containerName, container in pairs(room) do
                if container.items ~= nil then
                    ORGM.log(ORGM.VERBOSE, "Spawn: Removing from " .. tostring(containerName))
                    local index=1
                    while index <= #container.items do
                        local thisItem = container.items[index]
                        local removed = false
                        for _, removeItem in ipairs(RemoveTable) do
                            if thisItem == removeItem or thisItem == "Base." .. removeItem then
                                ORGM.log(ORGM.VERBOSE, "Spawn: Removing  " .. tostring(thisItem))
                                table.remove(container.items, index)
                                table.remove(container.items, index)
                                removed = true
                                break
                            end
                        end
                        if not removed then
                            index = index + 1
                        end
                    end
                end
            end
        end
    end
end


--[[- Loads any compatibility patches.

Triggered on the OnDistributionMerge event.

]]
Callbacks.loadPatches = function()
    -- nothing to do here
    ORGM.log(ORGM.INFO, "All server compatibility patches injected")
end

--[[- Calls functions that need to be checked when onKeyPressed is triggered.

]]
Callbacks.keyPress = function(key)
    Server.itemBindingHandler(key)
end


Callbacks.onFillContainer = Server.Spawn.fillContainer

--[[- Handles command requests from the clients in MP.

Triggered by the OnClientCommand event.

If the module name is 'orgm'
and the `ORGM.Server.CommandHandler` has a function with the name that
matches the command string argument, it calls that function.

@tparam string module name of the command module.
@tparam string command name of the command to run.
@tparam IsoPlayer player player that sent the command.
@tparam variable args data to be passed onto the command call.

]]
Callbacks.clientCommand = function(module, command, player, args)
    --print("Server got command: "..tostring(module)..":"..tostring(command).." - " ..tostring(isServer()))
    if not isServer() then return end
    if module ~= "orgm" then return end
    ORGM.log(ORGM.INFO, "Server got ClientCommand "..tostring(command))
    if CommandHandler[command] then CommandHandler[command](player, args) end
end