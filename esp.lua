-- Rofl Hub | esp.lua
-- ESP (Highlight + Billboard)

local Hub = _G.RoflHub or {}
_G.RoflHub = Hub

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

Hub.ESP = {}
local E = Hub.ESP

E.Enabled       = false
E.ShowName      = true
E.ShowDistance  = false
E.ShowAvatar    = true
E.OutlineWidth  = 1.5
E.FillAlpha     = 0.55
E.Chams         = true
E.ColorChoice   = 1
E.TargetSet     = {}
E.AllExplicit   = false
E.AvatarCache   = {}

local function addConn(c)
    return Hub.addConn(c)
end

-- Цвет ESP
local function getESPColor()
    local entry = Hub.EspColors[E.ColorChoice]
    if not entry or entry.color == nil then return Hub.Accent end
    return entry.color
end

-- Проверка таргета
local function isTargeted(playerName)
    if next(E.TargetSet) == nil then return true end
    return E.TargetSet[playerName] == true
end

-- Метка таргетов
local function targetLabelText()
    local count = 0
    for _ in pairs(E.TargetSet) do count = count + 1 end
    if count == 0 then return "All" end
    if count == 1 then
        for name, _ in pairs(E.TargetSet) do return name end
    end
    return "Selected: " .. tostring(count)
end

E.getColor = getESPColor
E.isTargeted = isTargeted
E.targetLabelText = targetLabelText

-- Аватарка
local function fetchAvatar(player)
    if E.AvatarCache[player.UserId] then return E.AvatarCache[player.UserId] end
    local ok, url = pcall(function()
        return Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end)
    if ok and url then
        E.AvatarCache[player.UserId] = url
        return url
    end
    return nil
end

-- Валидность ESP
local function hasValidESP(player)
    if not player.Character then return false end
    local hl = player.Character:FindFirstChild("RoflESP")
    local tag = player.Character:FindFirstChild("RoflESPTag")
    if not hl or not tag then return false end
    if hl.Adornee ~= player.Character then return false end
    if not hl:IsA("Highlight") then return false end
    if not tag:IsA("BillboardGui") then return false end
    return true
end

local function removeESPForPlayer(player)
    if not player.Character then return end
    local hl = player.Character:FindFirstChild("RoflESP")
    local tag = player.Character:FindFirstChild("RoflESPTag")
    if hl then pcall(function() hl:Destroy() end) end
    if tag then pcall(function() tag:Destroy() end) end
end

local function clearAllESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            removeESPForPlayer(p)
        end
    end
end

local function applyVisualsToESP(player)
    if not player.Character then return end
    local hl = player.Character:FindFirstChild("RoflESP")
    local tag = player.Character:FindFirstChild("RoflESPTag")
    if not hl or not tag then return end

    local col = getESPColor()

    pcall(function()
        hl.FillColor = col
        hl.FillTransparency = E.Chams and E.FillAlpha or 1
        hl.OutlineColor = col
        hl.OutlineTransparency = 0
    end)

    local nameLbl = tag:FindFirstChild("NameLbl")
    if nameLbl then
        nameLbl.TextColor3 = col
        nameLbl.Visible = E.ShowName
    end

    local distLbl = tag:FindFirstChild("DistLbl")
    if distLbl then
        distLbl.Visible = E.ShowDistance
    end

    local avLbl = tag:FindFirstChild("AvatarLbl")
    if avLbl then
        avLbl.Visible = E.ShowAvatar
    end
end

local function createESPForPlayer(player)
    if player == LocalPlayer then return end
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not isTargeted(player.Name) then return end

    removeESPForPlayer(player)

    local col = getESPColor()
    local head = player.Character:FindFirstChild("Head")

    local hl = Instance.new("Highlight")
    hl.Name = "RoflESP"
    hl.Adornee = player.Character
    hl.FillColor = col
    hl.FillTransparency = E.Chams and E.FillAlpha or 1
    hl.OutlineColor = col
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = player.Character

    local tag = Instance.new("BillboardGui")
    tag.Name = "RoflESPTag"
    tag.Adornee = head or hrp
    tag.Size = UDim2.new(0, 200, 0, 80)
    tag.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
    tag.AlwaysOnTop = true
    tag.Parent = player.Character

    local avatarLabel = Instance.new("ImageLabel")
    avatarLabel.Name = "AvatarLbl"
    avatarLabel.AnchorPoint = Vector2.new(0.5, 0)
    avatarLabel.Size = UDim2.new(0, 28, 0, 28)
    avatarLabel.Position = UDim2.new(0.5, 0, 0, 0)
    avatarLabel.BackgroundTransparency = 1
    avatarLabel.Image = fetchAvatar(player) or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    avatarLabel.Visible = E.ShowAvatar
    avatarLabel.Parent = tag

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLbl"
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 0, 0, 30)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = col
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Visible = E.ShowName
    nameLabel.Parent = tag

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLbl"
    distLabel.Size = UDim2.new(1, 0, 0, 14)
    distLabel.Position = UDim2.new(0, 0, 0, 48)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.TextStrokeTransparency = 0
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Visible = E.ShowDistance
    distLabel.Parent = tag

    if not E.AvatarCache[player.UserId] then
        task.spawn(function()
            local url = fetchAvatar(player)
            if url and avatarLabel.Parent then
                avatarLabel.Image = url
            end
        end)
    end
end

local function refreshAllESP()
    clearAllESP()
    if E.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer
               and isTargeted(player.Name)
               and player.Character
               and player.Character:FindFirstChild("HumanoidRootPart") then
                createESPForPlayer(player)
            end
        end
    end
end

local function reapplyESPVisuals()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            applyVisualsToESP(p)
        end
    end
end

function E.setEnabled(state)
    E.Enabled = state
    if state then refreshAllESP() else clearAllESP() end
end

function E.reapplyVisuals()
    reapplyESPVisuals()
end

function E.refreshAll()
    refreshAllESP()
end

function E.setColor(idx)
    E.ColorChoice = idx
    reapplyESPVisuals()
end

function E.setState(key, value)
    E[key] = value
    reapplyESPVisuals()
end

-- Bind
local function bindPlayer(player)
    if player == LocalPlayer then return end
    addConn(player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if E.Enabled and isTargeted(player.Name) then
            createESPForPlayer(player)
        end
    end))
    addConn(player.CharacterRemoving:Connect(function()
        removeESPForPlayer(player)
    end))
end

for _, player in ipairs(Players:GetPlayers()) do
    bindPlayer(player)
end

addConn(Players.PlayerAdded:Connect(bindPlayer))
addConn(Players.PlayerRemoving:Connect(function(player)
    removeESPForPlayer(player)
    E.TargetSet[player.Name] = nil
end))

-- Update loop (дистанция + пересоздание)
task.spawn(function()
    while true do
        task.wait(0.15)
        if E.Enabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local hasChar = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if hasChar and isTargeted(p.Name) then
                        if not hasValidESP(p) then
                            createESPForPlayer(p)
                        end
                    else
                        removeESPForPlayer(p)
                    end
                end
            end

            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHRP then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local tag = p.Character:FindFirstChild("RoflESPTag")
                        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if tag and hrp then
                            local dLbl = tag:FindFirstChild("DistLbl")
                            if dLbl then
                                local dist = (hrp.Position - myHRP.Position).Magnitude
                                if dist > 1000 then
                                    dLbl.Text = string.format("%.1fkm", dist / 1000)
                                else
                                    dLbl.Text = string.format("%.0fm", dist)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

Hub.log("esp.lua loaded")
