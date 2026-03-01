local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local PlaceId = game.PlaceId
local RejoinDelay = 1 

local function AttemptRejoin()
    print("Attempting to rejoin...")
    
    local success, err = pcall(function()
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end)

    if not success then
        warn("Rejoin failed: " .. tostring(err))
    else
        print("Rejoin command sent successfully.")
    end
end

Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        print("Player removed from server. Rejoining...")
        task.wait(RejoinDelay)
        AttemptRejoin()
    end
end)

RunService.Heartbeat:Connect(function()
    if not LocalPlayer or not LocalPlayer.Parent then
        print("Heartbeat detected disconnection. Rejoining...")
        AttemptRejoin()
    end
end)

print("Auto-Rejoin Script Loaded. Monitoring active.")
