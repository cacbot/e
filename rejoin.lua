local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local PlaceId = game.PlaceId
local RejoinDelay = 1
local isRejoining = false

local function AttemptRejoin()
    if isRejoining then return end
    isRejoining = true

    local success, err = pcall(function()
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end)

    if not success then
        warn("Rejoin failed: " .. tostring(err))
    end

    task.wait(RejoinDelay)
    isRejoining = false
end

local function OnPlayerRemoving(player)
    if player == LocalPlayer then
        print("Player removed. Rejoining...")
        AttemptRejoin()
    end
end

local function OnHeartbeat()
    if LocalPlayer and LocalPlayer.Parent then return end
    if not isRejoining then
        print("Heartbeat detected disconnect. Rejoining...")
        AttemptRejoin()
    end
end

if LocalPlayer then
    Players.PlayerRemoving:Connect(OnPlayerRemoving)
    RunService.Heartbeat:Connect(OnHeartbeat)
    print("Script loaded.")
else
    spawn(function()
        while not LocalPlayer do task.wait() end
        Players.PlayerRemoving:Connect(OnPlayerRemoving)
        RunService.Heartbeat:Connect(OnHeartbeat)
    end)
end
