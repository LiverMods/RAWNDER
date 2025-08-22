-- ESPModule V1 (BETA)©
local ESP = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local ESPFolder = CoreGui:FindFirstChild("ESPHolder") or Instance.new("Folder")
ESPFolder.Name = "ESPHolder"
ESPFolder.Parent = CoreGui

getgenv().ESPSettings = getgenv().ESPSettings or {
    Enabled = true,
    FillUseTeamColor = true,
    OutlineUseTeamColor = false,
    FillColor = Color3.new(0,0,0),
    OutlineColor = Color3.new(1,1,1),
    FillTransparency = 0.7,
    OutlineTransparency = 0,

    Friends = {Enabled = true, List = {}, Color = Color3.fromRGB(0,255,0)},
    Blacklist = {Enabled = true, List = {}, Color = Color3.fromRGB(255,0,0)},
    CustomColors = {},
    IgnoreLocalPlayer = true
}

local function getPlayerColor(player, isOutline)
    local s = getgenv().ESPSettings
    if s.Friends.Enabled and table.find(s.Friends.List, player.Name) then
        return s.Friends.Color
    elseif s.Blacklist.Enabled and table.find(s.Blacklist.List, player.Name) then
        return s.Blacklist.Color
    elseif s.CustomColors[player.Name] then
        return s.CustomColors[player.Name]
    elseif isOutline then
        return s.OutlineUseTeamColor and player.TeamColor.Color or s.OutlineColor
    else
        return s.FillUseTeamColor and player.TeamColor.Color or s.FillColor
    end
end

local function createESP(player)
    if not getgenv().ESPSettings.Enabled then return end
    if getgenv().ESPSettings.IgnoreLocalPlayer and player == LocalPlayer then return end
    if not player.Character then return end

    local esp = ESPFolder:FindFirstChild(player.Name) or Instance.new("Highlight")
    esp.Name = player.Name
    esp.Parent = ESPFolder
    esp.Adornee = player.Character
    esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    esp.FillColor = getPlayerColor(player, false)
    esp.OutlineColor = getPlayerColor(player, true)
    esp.FillTransparency = getgenv().ESPSettings.FillTransparency
    esp.OutlineTransparency = getgenv().ESPSettings.OutlineTransparency
end

local function removeESP(player)
    local esp = ESPFolder:FindFirstChild(player.Name)
    if esp then esp:Destroy() end
end

local function setupPlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.1)
        createESP(player)
    end)
    if player.Character then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removeESP)
for _, p in ipairs(Players:GetPlayers()) do
    setupPlayer(p)
end

ESP.UpdateAll = function()
    for _, p in ipairs(Players:GetPlayers()) do
        createESP(p)
    end
end

ESP.Toggle = function(state)
    getgenv().ESPSettings.Enabled = state
    if not state then
        ESPFolder:ClearAllChildren()
    else
        ESP.UpdateAll()
    end
end

ESP.SetFriend = function(name, state)
    local list = getgenv().ESPSettings.Friends.List
    if state then
        if not table.find(list, name) then table.insert(list, name) end
    else
        table.remove(list, table.find(list, name))
    end
    ESP.UpdateAll()
end

ESP.SetBlacklist = function(name, state)
    local list = getgenv().ESPSettings.Blacklist.List
    if state then
        if not table.find(list, name) then table.insert(list, name) end
    else
        table.remove(list, table.find(list, name))
    end
    ESP.UpdateAll()
end

ESP.SetCustomColor = function(name, color)
    getgenv().ESPSettings.CustomColors[name] = color
    ESP.UpdateAll()
end

return ESP
