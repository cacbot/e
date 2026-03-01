local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local isRejoining = false
local attempt = 0
local MAX_ATTEMPTS = 5

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5,
            Icon = ""
        })
    end)
    warn("[" .. title .. "] " .. text)
end

local function safeRejoin()
    if isRejoining then return end
    if attempt >= MAX_ATTEMPTS then
        notify("Auto Rejoin", "Max attempts reached (" .. MAX_ATTEMPTS .. "). Stopped.")
        return
    end

    isRejoining = true
    attempt = attempt + 1

    notify("Auto Rejoin", "Rejoining... attempt " .. attempt .. "/" .. MAX_ATTEMPTS)

    local success, err = pcall(function()
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end)

    if not success then
        notify("Auto Rejoin", "Teleport failed: " .. tostring(err))
        task.delay(1.5, function()
            isRejoining = false
        end)
    end
end

GuiService.ErrorMessageChanged:Connect(function(newMessage)
    if newMessage and newMessage ~= "" then
        notify("Auto Rejoin", "Error/kick prompt → rejoining")
        safeRejoin()
    end
end)

LocalPlayer.AncestryChanged:Connect(function(_, newParent)
    if newParent == nil then
        notify("Auto Rejoin", "Player removed from game → rejoining")
        safeRejoin()
    end
end)

RunService.Heartbeat:Connect(function()
    if LocalPlayer and not LocalPlayer.Parent then
        notify("Auto Rejoin", "Disconnect detected → rejoining")
        safeRejoin()
    end
end)

if not LocalPlayer.Parent then
    task.delay(0.5)
end

notify("Auto Rejoin", "Enabled – will attempt rejoin on kick/disconnect/error")
