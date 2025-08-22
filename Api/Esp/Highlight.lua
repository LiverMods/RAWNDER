-- ESPModule V1.1 (BETA)©
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
    BorderUseTeamColor = false,
    IgnoreSameTeam = true,
    FillColor = Color3.new(0,0,0),
    OutlineColor = Color3.new(1,1,1),
    BorderColor = Color3.new(1,0,0),
    FillTransparency = 0.7,
    OutlineTransparency = 0,
    BorderTransparency = 0,
    Friends = {Enabled = true, List = {}, Color = Color3.fromRGB(0,255,0)},
    Blacklist = {Enabled = true, List = {}, Color = Color3.fromRGB(255,0,0)},
    CustomColors = {},
    IgnoreLocalPlayer = true
}

local function getPlayerColor(player, mode)
    local s = getgenv().ESPSettings
    local name = player.Name
    if s.Friends.Enabled and table.find(s.Friends.List, name) then
        return s.Friends.Color
    elseif s.Blacklist.Enabled and table.find(s.Blacklist.List, name) then
        return s.Blacklist.Color
    elseif s.CustomColors[name] then
        return s.CustomColors[name]
    end
    if mode == "Fill" then
        if s.FillUseTeamColor then
            return player.Team and player.TeamColor.Color or s.FillColor
        else
            return s.FillColor or (player.Team and player.TeamColor.Color)
        end
    elseif mode == "Outline" then
        if s.OutlineUseTeamColor then
            return player.Team and player.TeamColor.Color or s.OutlineColor
        else
            return s.OutlineColor or (player.Team and player.TeamColor.Color)
        end
    elseif mode == "Border" then
        if s.BorderUseTeamColor then
            return player.Team and player.TeamColor.Color or s.BorderColor
        else
            return s.BorderColor or (player.Team and player.TeamColor.Color)
        end
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
    esp.FillColor = getPlayerColor(player, "Fill")
    esp.OutlineColor = getPlayerColor(player, "Border")
    esp.FillTransparency = s.FillTransparency
    esp.OutlineTransparency = s.BorderTransparency
end

function removeESP(player)
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
    player:GetPropertyChangedSignal("Team"):Connect(function()
        createESP(player)
    end)
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
        local i = table.find(list, name)
        if i then table.remove(list, i) end
    end
    ESP.UpdateAll()
end

ESP.SetBlacklist = function(name, state)
    local list = getgenv().ESPSettings.Blacklist.List
    if state then
        if not table.find(list, name) then table.insert(list, name) end
    else
        local i = table.find(list, name)
        if i then table.remove(list, i) end
    end
    ESP.UpdateAll()
end

ESP.SetCustomColor = function(name, color)
    getgenv().ESPSettings.CustomColors[name] = color
    ESP.UpdateAll()
end

return ESP
