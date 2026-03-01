local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local PLACE_ID = game.PlaceId

local function onPlayerRemoved(player)
    if player == LocalPlayer then
        print("Attempting to rejoin...")
        
        TeleportService:Teleport(PLACE_ID, LocalPlayer)
    end
end

Players.PlayerRemoving:Connect(onPlayerRemoved)

local connection
connection = game:GetService("RunService").Heartbeat:Connect(function()
    if not Players.LocalPlayer then
        print("Disconnecting heartbeat check.")
        if connection then
            connection:Disconnect()
        end
    end
end)

print("re-join script is now active.")
