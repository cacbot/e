local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local placeId = game.PlaceId

local REJOIN_DELAY = 1.8
local MAX_ATTEMPTS = 5

local attemptCount = 0
local isRejoining = false
local connectionLost = false

local function notify(message, color)
    color = color or Color3.fromRGB(220, 220, 100)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Rejoin",
            Text = message,
            Duration = 6,
            Icon = ""
        })
    end)
    warn("[Rejoin] " .. message)
end

local function canAttemptRejoin()
    if isRejoining then
        return false
    end
    if attemptCount >= MAX_ATTEMPTS then
        notify("Max rejoin attempts reached (" .. MAX_ATTEMPTS .. "). Stopping.", Color3.fromRGB(255, 80, 80))
        return false
    end
    return true
end

local function tryRejoin()
    if not canAttemptRejoin() then
        return
    end

    isRejoining = true
    attemptCount = attemptCount + 1

    notify("Rejoining... (" .. attemptCount .. "/" .. MAX_ATTEMPTS .. ")")

    local success, errorMessage = pcall(function()
        TeleportService:Teleport(placeId, LocalPlayer)
    end)

    if not success then
        notify("Teleport failed: " .. tostring(errorMessage), Color3.fromRGB(255, 100, 100))
        task.delay(2, function()
            isRejoining = false
        end)
    end
end

local function onPlayerRemoving(player)
    if player ~= LocalPlayer then
        return
    end
    if connectionLost then
        return
    end

    connectionLost = true
    print("[Rejoin] LocalPlayer removed → attempting rejoin")
    tryRejoin()
end

local function onHeartbeat()
    if LocalPlayer and not LocalPlayer.Parent then
        if connectionLost then
            return
        end

        connectionLost = true
        print("[Rejoin] LocalPlayer.Parent became nil → attempting rejoin")
        tryRejoin()
    end
end

local function init()
    if not LocalPlayer then
        notify("LocalPlayer not found yet...", Color3.fromRGB(200, 200, 255))
        return false
    end

    isRejoining = false
    connectionLost = false
    attemptCount = 0

    local conn1 = Players.PlayerRemoving:Connect(onPlayerRemoving)
    local conn2 = RunService.Heartbeat:Connect(onHeartbeat)

    script.Destroying:Connect(function()
        pcall(function()
            conn1:Disconnect()
            conn2:Disconnect()
        end)
    end)

    notify("Rejoin script active (Place " .. placeId .. ")", Color3.fromRGB(100, 220, 120))
    return true
end

if LocalPlayer then
    init()
else
    task.spawn(function()
        local timeout = 0
        while not LocalPlayer and timeout < 12 do
            task.wait(0.3)
            timeout = timeout + 0.3
        end

        if LocalPlayer then
            init()
        else
            notify("Could not find LocalPlayer after waiting. Giving up.", Color3.fromRGB(255, 100, 100))
        end
    end)
end
