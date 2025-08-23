-- ESPModule V1.3 (BETA)©
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
    OutlineUseTeamColor = true,
    IgnoreSameTeam = true,
    FillColor = Color3.new(0,0,0),
    OutlineColor = Color3.new(1,0,0),
    FillTransparency = 0.7,
    OutlineTransparency = 0,
    Friends = {Enabled = true, List = {}, Color = Color3.fromRGB(0,255,0)},
    Blacklist = {Enabled = true, List = {}, Color = Color3.fromRGB(255,0,0)},
    CustomColors = {},
    IgnoreLocalPlayer = true
}

local function getPlayerColor(player)
    local s = getgenv().ESPSettings
    local name = player.Name
    if s.Friends.Enabled and table.find(s.Friends.List, name) then
        return s.Friends.Color
    elseif s.Blacklist.Enabled and table.find(s.Blacklist.List, name) then
        return s.Blacklist.Color
    elseif s.CustomColors[name] then
        return s.CustomColors[name]
    elseif s.FillUseTeamColor then
        return player.Team and player.TeamColor.Color or s.FillColor
    else
        return s.FillColor
    end
end

local function createESP(player)
    local s = getgenv().ESPSettings
    if not s.Enabled then return end
    if s.IgnoreLocalPlayer and player == LocalPlayer then return end
    if not player.Character then return end
    if s.IgnoreSameTeam and player.Team == LocalPlayer.Team then
        return removeESP(player)
    end
    local esp = ESPFolder:FindFirstChild(player.Name) or Instance.new("Highlight")
    esp.Name = player.Name
    esp.Parent = ESPFolder
    esp.Adornee = player.Character
    esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    local color = getPlayerColor(player)
    esp.FillColor = color
    esp.OutlineColor = color
    esp.FillTransparency = s.FillTransparency
    esp.OutlineTransparency = s.OutlineTransparency
end

function removeESP(player)
    local esp = ESPFolder:FindFirstChild(player.Name)
    if esp then esp:Destroy() end
end

local function UpdateAllESP()
    for _, p in ipairs(Players:GetPlayers()) do
        createESP(p)
    end
end

local function setupPlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.1)
        createESP(player)
    end)
    if player.Character then
        createESP(player)
    end

    player:GetPropertyChangedSignal("Team"):Connect(function()
        UpdateAllESP()
    end)
end

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
    UpdateAllESP()
end)

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removeESP)

for _, p in ipairs(Players:GetPlayers()) do
    setupPlayer(p)
end

ESP.UpdateAll = UpdateAllESP

ESP.Toggle = function(state)
    getgenv().ESPSettings.Enabled = state
    if not state then
        ESPFolder:ClearAllChildren()
    else
        UpdateAllESP()
    end
end

ESP.SetFriend = function(name, state)
    local list = getgenv().ESPSettings.Friends.List
    if state then
        if not table.find(list, name) then table.insert(list, name) end
    else
        local i = table.find(list, name)
        if i then table.remove(list, i) end
    end
    UpdateAllESP()
end

ESP.SetBlacklist = function(name, state)
    local list = getgenv().ESPSettings.Blacklist.List
    if state then
        if not table.find(list, name) then table.insert(list, name) end
    else
        local i = table.find(list, name)
        if i then table.remove(list, i) end
    end
    UpdateAllESP()
end

ESP.SetCustomColor = function(name, color)
    getgenv().ESPSettings.CustomColors[name] = color
    UpdateAllESP()
end

ESP.RemoveCustomColor = function(name)
    if getgenv().ESPSettings.CustomColors[name] then
        getgenv().ESPSettings.CustomColors[name] = nil
        UpdateAllESP()
    end
end

return ESP
