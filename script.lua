--[[
    ============================================
        Rofl Hub  |  v1.3  (PC ONLY)
        Made for FTAP (Roblox)
        
        - Fun tab: Anchored (B key)
          → freezes item in air at its current position
          → NO NOCLIP — object collides with map normally
          → RenderStepped recovery (every frame, not 0.02s)
          → instant ownership reclaim (SetNetworkOwner + CFrame)
          → soft orientation — no sharp rotation
          → angle restore if rotated >30°
          → MAP PROTECTION
        - Skybox in Visuals (27 skyboxes)
        - FOV slider, Fullbright, No Shadows, Time
        - ESP system with full customization
    ============================================
]]

-- === ERROR HANDLER ===
local StarterGui = game:GetService("StarterGui")

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = tostring(text):sub(1, 200),
            Duration = duration or 10,
        })
    end)
end

local function log(msg)
    print("[Rofl Hub] " .. tostring(msg))
end

log("Script started")

-- === MAIN SCRIPT ===
local ok, err = pcall(function()

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = workspace.CurrentCamera

log("Variables loaded")

-- CLEANUP
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj.Name == "RoflAnchoredPos" or obj.Name == "RoflAnchoredOr"
    or obj.Name == "RoflAnchoredAtt" then
        pcall(function() obj:Destroy() end)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p.Character then
        for _, obj in ipairs(p.Character:GetDescendants()) do
            if obj:IsA("Highlight") then pcall(function() obj:Destroy() end) end
            if obj:IsA("BillboardGui") then pcall(function() obj:Destroy() end) end
            if obj.Name == "RoflESP" or obj.Name == "RoflESPTag" then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

-- CONFIG
local HUB_NAME      = "Rofl Hub"
local HUB_VERSION   = "v1.3"

local THEMES = {
    Blue   = { main = Color3.fromRGB(120, 170, 255), dark = Color3.fromRGB(70, 120, 200)  },
    Purple = { main = Color3.fromRGB(170, 120, 255), dark = Color3.fromRGB(120, 70, 200)  },
    Pink   = { main = Color3.fromRGB(255, 120, 180), dark = Color3.fromRGB(200, 70, 130)  },
    Red    = { main = Color3.fromRGB(255, 100, 100), dark = Color3.fromRGB(200, 60, 60)   },
    Green  = { main = Color3.fromRGB(120, 230, 140), dark = Color3.fromRGB(70, 180, 90)   },
}

local ESP_COLORS = {
    { name = "Theme",  color = nil },
    { name = "White",  color = Color3.fromRGB(255, 255, 255) },
    { name = "Red",    color = Color3.fromRGB(255, 70, 70) },
    { name = "Green",  color = Color3.fromRGB(70, 255, 100) },
    { name = "Blue",   color = Color3.fromRGB(70, 150, 255) },
    { name = "Yellow", color = Color3.fromRGB(255, 230, 80) },
    { name = "Pink",   color = Color3.fromRGB(255, 120, 200) },
}

local currentTheme = "Blue"
local ACCENT       = THEMES[currentTheme].main
local ACCENT_DARK  = THEMES[currentTheme].dark

local espColorChoice = 1
local espTargetSet   = {}
local allExplicit    = false

local CLOSE_COLOR   = Color3.fromRGB(220, 70, 70)
local BG_COLOR      = Color3.fromRGB(14, 14, 18)
local PANEL_COLOR   = Color3.fromRGB(22, 22, 28)
local PANEL_INNER   = Color3.fromRGB(18, 18, 24)
local BTN_COLOR     = Color3.fromRGB(30, 30, 38)
local BTN_HOVER     = Color3.fromRGB(40, 40, 50)
local BTN_ACTIVE    = Color3.fromRGB(50, 50, 68)
local TEXT_COLOR    = Color3.fromRGB(240, 240, 245)
local SUBTEXT_COLOR = Color3.fromRGB(140, 140, 155)
local EDGE_SIZE     = 6
local CORNER_SIZE   = 16

local MIN_FOV, MAX_FOV = 1, 120
local MIN_TIME, MAX_TIME = 0, 24
local toggleKey = Enum.KeyCode.M

local THEME_TWEEN_TIME = 0.45
local THEME_TWEEN_INFO = TweenInfo.new(THEME_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local ORIGINAL_FOV = Camera.FieldOfView
local ORIGINAL_LIGHTING = {
    Brightness     = Lighting.Brightness,
    ClockTime      = Lighting.ClockTime,
    FogEnd         = Lighting.FogEnd,
    FogStart       = Lighting.FogStart,
    GlobalShadows  = Lighting.GlobalShadows,
    Ambient        = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

-- SKYBOX ASSETS (27 SKYBOXES)
local SKYBOX_ASSETS = {
    ["Black Storm"] = {
        Bk = "rbxassetid://15502511288", Dn = "rbxassetid://15502508460",
        Ft = "rbxassetid://15502510289", Lf = "rbxassetid://15502507918",
        Rt = "rbxassetid://15502509398", Up = "rbxassetid://15502511911",
    },
    ["HD"] = {
        Bk = "http://www.roblox.com/asset/?id=16553658937", Dn = "http://www.roblox.com/asset/?id=16553660713",
        Ft = "http://www.roblox.com/asset/?id=16553662144", Lf = "http://www.roblox.com/asset/?id=16553664042",
        Rt = "http://www.roblox.com/asset/?id=16553665766", Up = "http://www.roblox.com/asset/?id=16553667750",
    },
    ["Snow"] = {
        Bk = "http://www.roblox.com/asset/?id=155657655", Dn = "http://www.roblox.com/asset/?id=155674246",
        Ft = "http://www.roblox.com/asset/?id=155657609", Lf = "http://www.roblox.com/asset/?id=155657671",
        Rt = "http://www.roblox.com/asset/?id=155657619", Up = "http://www.roblox.com/asset/?id=155674931",
    },
    ["Blue Space"] = {
        Bk = "rbxassetid://15536110634", Dn = "rbxassetid://15536112543",
        Ft = "rbxassetid://15536116141", Lf = "rbxassetid://15536114370",
        Rt = "rbxassetid://15536118762", Up = "rbxassetid://15536117282",
    },
    ["Realistic"] = {
        Bk = "rbxassetid://653719502", Dn = "rbxassetid://653718790",
        Ft = "rbxassetid://653719067", Lf = "rbxassetid://653719190",
        Rt = "rbxassetid://653718931", Up = "rbxassetid://653719321",
    },
    ["Stormy"] = {
        Bk = "http://www.roblox.com/asset/?id=18703245834", Dn = "http://www.roblox.com/asset/?id=18703243349",
        Ft = "http://www.roblox.com/asset/?id=18703240532", Lf = "http://www.roblox.com/asset/?id=18703237556",
        Rt = "http://www.roblox.com/asset/?id=18703235430", Up = "http://www.roblox.com/asset/?id=18703232671",
    },
    ["Pink"] = {
        Bk = "rbxassetid://12216109205", Dn = "rbxassetid://12216109875",
        Ft = "rbxassetid://12216109489", Lf = "rbxassetid://12216110170",
        Rt = "rbxassetid://12216110471", Up = "rbxassetid://12216108877",
    },
    ["Sunset"] = {
        Bk = "rbxassetid://600830446", Dn = "rbxassetid://600831635",
        Ft = "rbxassetid://600832720", Lf = "rbxassetid://600886090",
        Rt = "rbxassetid://600833862", Up = "rbxassetid://600835177",
    },
    ["Arctic"] = {
        Bk = "http://www.roblox.com/asset/?id=225469390", Dn = "http://www.roblox.com/asset/?id=225469395",
        Ft = "http://www.roblox.com/asset/?id=225469403", Lf = "http://www.roblox.com/asset/?id=225469450",
        Rt = "http://www.roblox.com/asset/?id=225469471", Up = "http://www.roblox.com/asset/?id=225469481",
    },
    ["Space"] = {
        Bk = "http://www.roblox.com/asset/?id=166509999", Dn = "http://www.roblox.com/asset/?id=166510057",
        Ft = "http://www.roblox.com/asset/?id=166510116", Lf = "http://www.roblox.com/asset/?id=166510092",
        Rt = "http://www.roblox.com/asset/?id=166510131", Up = "http://www.roblox.com/asset/?id=166510114",
    },
    ["Roblox Default"] = {
        Bk = "rbxasset://textures/sky/sky512_bk.tex", Dn = "rbxasset://textures/sky/sky512_dn.tex",
        Ft = "rbxasset://textures/sky/sky512_ft.tex", Lf = "rbxasset://textures/sky/sky512_lf.tex",
        Rt = "rbxasset://textures/sky/sky512_rt.tex", Up = "rbxasset://textures/sky/sky512_up.tex",
    },
    ["Red Night"] = {
        Bk = "http://www.roblox.com/asset/?id=401664839", Dn = "http://www.roblox.com/asset/?id=401664862",
        Ft = "http://www.roblox.com/asset/?id=401664960", Lf = "http://www.roblox.com/asset/?id=401664881",
        Rt = "http://www.roblox.com/asset/?id=401664901", Up = "http://www.roblox.com/asset/?id=401664936",
    },
    ["Deep Space 1"] = {
        Bk = "http://www.roblox.com/asset/?id=149397692", Dn = "http://www.roblox.com/asset/?id=149397686",
        Ft = "http://www.roblox.com/asset/?id=149397697", Lf = "http://www.roblox.com/asset/?id=149397684",
        Rt = "http://www.roblox.com/asset/?id=149397688", Up = "http://www.roblox.com/asset/?id=149397702",
    },
    ["Pink Skies"] = {
        Bk = "http://www.roblox.com/asset/?id=151165214", Dn = "http://www.roblox.com/asset/?id=151165197",
        Ft = "http://www.roblox.com/asset/?id=151165224", Lf = "http://www.roblox.com/asset/?id=151165191",
        Rt = "http://www.roblox.com/asset/?id=151165206", Up = "http://www.roblox.com/asset/?id=151165227",
    },
    ["Purple Sunset"] = {
        Bk = "rbxassetid://264908339", Dn = "rbxassetid://264907909",
        Ft = "rbxassetid://264909420", Lf = "rbxassetid://264909758",
        Rt = "rbxassetid://264908886", Up = "rbxassetid://264907379",
    },
    ["Blue Night"] = {
        Bk = "http://www.roblox.com/asset/?id=12064107", Dn = "http://www.roblox.com/asset/?id=12064152",
        Ft = "http://www.roblox.com/asset/?id=12064121", Lf = "http://www.roblox.com/asset/?id=12063984",
        Rt = "http://www.roblox.com/asset/?id=12064115", Up = "http://www.roblox.com/asset/?id=12064131",
    },
    ["Blossom Daylight"] = {
        Bk = "http://www.roblox.com/asset/?id=271042516", Dn = "http://www.roblox.com/asset/?id=271077243",
        Ft = "http://www.roblox.com/asset/?id=271042556", Lf = "http://www.roblox.com/asset/?id=271042310",
        Rt = "http://www.roblox.com/asset/?id=271042467", Up = "http://www.roblox.com/asset/?id=271077958",
    },
    ["Blue Nebula"] = {
        Bk = "http://www.roblox.com/asset?id=135207744", Dn = "http://www.roblox.com/asset?id=135207662",
        Ft = "http://www.roblox.com/asset?id=135207770", Lf = "http://www.roblox.com/asset?id=135207615",
        Rt = "http://www.roblox.com/asset?id=135207695", Up = "http://www.roblox.com/asset?id=135207794",
    },
    ["Blue Planet"] = {
        Bk = "rbxassetid://218955819", Dn = "rbxassetid://218953419",
        Ft = "rbxassetid://218954524", Lf = "rbxassetid://218958493",
        Rt = "rbxassetid://218957134", Up = "rbxassetid://218950090",
    },
    ["Deep Space 2"] = {
        Bk = "http://www.roblox.com/asset/?id=159248188", Dn = "http://www.roblox.com/asset/?id=159248183",
        Ft = "http://www.roblox.com/asset/?id=159248187", Lf = "http://www.roblox.com/asset/?id=159248173",
        Rt = "http://www.roblox.com/asset/?id=159248192", Up = "http://www.roblox.com/asset/?id=159248176",
    },
    ["Summer"] = {
        Bk = "rbxassetid://16648590964", Dn = "rbxassetid://16648617436",
        Ft = "rbxassetid://16648595424", Lf = "rbxassetid://16648566370",
        Rt = "rbxassetid://16648577071", Up = "rbxassetid://16648598180",
    },
    ["Galaxy"] = {
        Bk = "rbxassetid://15983968922", Dn = "rbxassetid://15983966825",
        Ft = "rbxassetid://15983965025", Lf = "rbxassetid://15983967420",
        Rt = "rbxassetid://15983966246", Up = "rbxassetid://15983964246",
    },
    ["Stylized"] = {
        Bk = "rbxassetid://18351376859", Dn = "rbxassetid://18351374919",
        Ft = "rbxassetid://18351376800", Lf = "rbxassetid://18351376469",
        Rt = "rbxassetid://18351376457", Up = "rbxassetid://18351377189",
    },
    ["Minecraft"] = {
        Bk = "rbxassetid://8735166756", Dn = "http://www.roblox.com/asset/?id=8735166707",
        Ft = "http://www.roblox.com/asset/?id=8735231668", Lf = "http://www.roblox.com/asset/?id=8735166755",
        Rt = "http://www.roblox.com/asset/?id=8735166751", Up = "http://www.roblox.com/asset/?id=8735166729",
    },
    ["Sunset 2"] = {
        Bk = "http://www.roblox.com/asset/?id=151165214", Dn = "http://www.roblox.com/asset/?id=151165197",
        Ft = "http://www.roblox.com/asset/?id=151165224", Lf = "http://www.roblox.com/asset/?id=151165191",
        Rt = "http://www.roblox.com/asset/?id=151165206", Up = "http://www.roblox.com/asset/?id=151165227",
    },
    ["Cloudy Rain"] = {
        Bk = "http://www.roblox.com/asset/?id=4498828382", Dn = "http://www.roblox.com/asset/?id=4498828812",
        Ft = "http://www.roblox.com/asset/?id=4498829917", Lf = "http://www.roblox.com/asset/?id=4498830911",
        Rt = "http://www.roblox.com/asset/?id=4498830417", Up = "http://www.roblox.com/asset/?id=4498831746",
    },
    ["Black Cloudy Rain"] = {
        Bk = "http://www.roblox.com/asset/?id=149679669", Dn = "http://www.roblox.com/asset/?id=149679979",
        Ft = "http://www.roblox.com/asset/?id=149679690", Lf = "http://www.roblox.com/asset/?id=149679709",
        Rt = "http://www.roblox.com/asset/?id=149679722", Up = "http://www.roblox.com/asset/?id=149680199",
    },
}

local DEFAULT_SKY_SETTINGS = nil
do
    local existingSky = Lighting:FindFirstChildOfClass("Sky")
    if existingSky then
        DEFAULT_SKY_SETTINGS = {
            Bk = existingSky.SkyboxBk,
            Dn = existingSky.SkyboxDn,
            Ft = existingSky.SkyboxFt,
            Lf = existingSky.SkyboxLf,
            Rt = existingSky.SkyboxRt,
            Up = existingSky.SkyboxUp,
        }
    end
end

-- STATE
local activeTabName = "Visuals"
local tabButtons, sections, themeButtons = {}, {}, {}
local themeTargets  = {}
local fovResetCallback, timeResetCallback = nil, nil
local applyTheme
local currentSkybox = "HD"
local skyboxDropdownRef = nil

local openDropdowns = {}
local ignoreGlobalClickUntil = 0

-- Anchored
local anchoredEnabled = true
local anchoredKey = Enum.KeyCode.B
local anchoredTargets = {}

local function markIgnoreNextClicks(dur)
    ignoreGlobalClickUntil = tick() + (dur or 0.1)
end

local function registerOpenDropdown(dd)
    table.insert(openDropdowns, dd)
end

local function registerTheme(obj, property, kind, extra)
    local entry = {obj = obj, property = property, kind = kind}
    if extra then for k, v in pairs(extra) do entry[k] = v end end
    table.insert(themeTargets, entry)
    return entry
end

local connections = {}
local function addConn(c)
    table.insert(connections, c)
    return c
end

local function getESPColor()
    local entry = ESP_COLORS[espColorChoice]
    if entry.color == nil then return ACCENT end
    return entry.color
end

local function isTargeted(playerName)
    if next(espTargetSet) == nil then return true end
    return espTargetSet[playerName] == true
end

local function targetLabelText()
    local count = 0
    for _ in pairs(espTargetSet) do count = count + 1 end
    if count == 0 then return "All" end
    if count == 1 then
        for name, _ in pairs(espTargetSet) do return name end
    end
    return "Selected: " .. tostring(count)
end

-- SKYBOX FUNCTIONS
local function applySkybox(skyboxName)
    local data = SKYBOX_ASSETS[skyboxName]
    if not data then return end

    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "RoflSky"
        sky.Parent = Lighting
    end

    sky.SkyboxBk = data.Bk
    sky.SkyboxDn = data.Dn
    sky.SkyboxFt = data.Ft
    sky.SkyboxLf = data.Lf
    sky.SkyboxRt = data.Rt
    sky.SkyboxUp = data.Up

    currentSkybox = skyboxName
end

local function restoreDefaultSky()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "Sky"
        sky.Parent = Lighting
    end

    if DEFAULT_SKY_SETTINGS then
        sky.SkyboxBk = DEFAULT_SKY_SETTINGS.Bk
        sky.SkyboxDn = DEFAULT_SKY_SETTINGS.Dn
        sky.SkyboxFt = DEFAULT_SKY_SETTINGS.Ft
        sky.SkyboxLf = DEFAULT_SKY_SETTINGS.Lf
        sky.SkyboxRt = DEFAULT_SKY_SETTINGS.Rt
        sky.SkyboxUp = DEFAULT_SKY_SETTINGS.Up
    else
        sky.SkyboxBk = ""
        sky.SkyboxDn = ""
        sky.SkyboxFt = ""
        sky.SkyboxLf = ""
        sky.SkyboxRt = ""
        sky.SkyboxUp = ""
    end
end

-- ANCHORED SYSTEM
local SetNetworkOwnerRemote = nil

local function findSetNetworkOwnerRemote()
    if SetNetworkOwnerRemote and SetNetworkOwnerRemote.Parent then
        return SetNetworkOwnerRemote
    end
    local ok, r = pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local grabEvents = rs:FindFirstChild("GrabEvents")
        if grabEvents then
            local remote = grabEvents:FindFirstChild("SetNetworkOwner")
            if remote then
                SetNetworkOwnerRemote = remote
                return remote
            end
        end
        return nil
    end)
    if ok then return r end
    return nil
end

local function findCurrentlyHeldPart()
    local ok, part = pcall(function()
        local grabParts = workspace:FindFirstChild("GrabParts")
        if not grabParts then return nil end
        local grabPart = grabParts:FindFirstChild("GrabPart")
        if not grabPart then return nil end
        local weld = grabPart:FindFirstChild("WeldConstraint")
        if not weld then return nil end
        return weld.Part1
    end)
    if ok then return part end
    return nil
end

local function isMapPart(part)
    if not part then return false end
    local map = workspace:FindFirstChild("Map")
    if map then
        local current = part
        while current do
            if current == map then return true end
            current = current.Parent
        end
    end
    if part:IsA("BasePart") and part.Size.Magnitude > 100 then
        return true
    end
    return false
end

local function forceOwnership(part)
    if not part or not part.Parent then return end
    local remote = findSetNetworkOwnerRemote()
    if not remote then return end
    pcall(function()
        remote:FireServer(part, part.CFrame)
    end)
end

local function attachHold(part)
    if not part or not part.Parent then return nil end

    local ok, entry = pcall(function()
        local fixedPos = part.Position
        local fixedCF = part.CFrame

        pcall(function()
            local old = part:FindFirstChild("RoflAnchoredAtt")
            if old then old:Destroy() end
        end)
        pcall(function()
            local old = part:FindFirstChild("RoflAnchoredPos")
            if old then old:Destroy() end
        end)
        pcall(function()
            local old = part:FindFirstChild("RoflAnchoredOr")
            if old then old:Destroy() end
        end)

        local att = Instance.new("Attachment")
        att.Name = "RoflAnchoredAtt"
        att.Parent = part

        local ap = Instance.new("AlignPosition")
        ap.Name = "RoflAnchoredPos"
        ap.Mode = Enum.PositionAlignmentMode.OneAttachment
        ap.Attachment0 = att
        ap.Position = fixedPos
        ap.MaxForce = 5000000
        ap.MaxVelocity = 500
        ap.Responsiveness = 200
        ap.ApplyAtCenterOfMass = true
        ap.Parent = part

        local ao = Instance.new("AlignOrientation")
        ao.Name = "RoflAnchoredOr"
        ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
        ao.Attachment0 = att
        ao.CFrame = fixedCF
        ao.MaxTorque = 2000000
        ao.MaxAngularVelocity = 100
        ao.Responsiveness = 200
        ao.Parent = part

        -- NOCLIP УБРАН — объект сталкивается с картой как обычно
        pcall(function()
            part.Anchored = false
        end)

        return {
            alignPos = ap,
            alignOr = ao,
            att = att,
            part = part,
            savedCF = fixedCF,
        }
    end)

    if ok then return entry end
    return nil
end

local function detachHold(entry)
    if not entry then return end
    pcall(function() if entry.alignPos then entry.alignPos:Destroy() end end)
    pcall(function() if entry.alignOr then entry.alignOr:Destroy() end end)
    pcall(function() if entry.att then entry.att:Destroy() end end)
end

local function releaseAllAnchored()
    for part, entry in pairs(anchoredTargets) do
        detachHold(entry)
    end
    anchoredTargets = {}
end

local function toggleAnchoredGrab()
    if not anchoredEnabled then return end

    local part = findCurrentlyHeldPart()

    if part and anchoredTargets[part] then
        detachHold(anchoredTargets[part])
        anchoredTargets[part] = nil
        return
    end

    if part then
        if isMapPart(part) then
            showToast("Anchored", "Нельзя морозить карту!")
            return
        end

        local entry = attachHold(part)
        if entry then
            anchoredTargets[part] = entry
            forceOwnership(part)
        end
        return
    end

    if next(anchoredTargets) then
        releaseAllAnchored()
    end
end

addConn(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if not anchoredEnabled then return end
    if input.KeyCode == anchoredKey then
        pcall(toggleAnchoredGrab)
    end
end))

-- ============================================================
-- RECOVERY THREAD (RenderStepped — каждый кадр, без NOCLIP)
-- Приоритет: мгновенный возврат при потере владения
-- ============================================================
addConn(RunService.RenderStepped:Connect(function()
    if not anchoredEnabled then return end
    if not next(anchoredTargets) then return end

    for part, entry in pairs(anchoredTargets) do
        if not part or not part.Parent then
            anchoredTargets[part] = nil
        else
            -- 1. Мгновенно возвращаем владельца, если его увели
            local partOwner = part:FindFirstChild("PartOwner")
            local stolen = false

            if partOwner and partOwner.Value ~= LocalPlayer.Name then
                stolen = true
            end

            if not stolen then
                pcall(function()
                    local ok, owner = pcall(function()
                        return part:GetNetworkOwner()
                    end)
                    if ok and owner and owner ~= LocalPlayer then
                        stolen = true
                    end
                end)
            end

            if stolen then
                forceOwnership(part)

                pcall(function()
                    part.CFrame = CFrame.new(entry.alignPos.Position)
                        * (entry.savedCF - entry.savedCF.Position)
                    part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end)

                pcall(function()
                    entry.alignPos.Position = entry.savedCF.Position
                end)
            else
                -- 2. Гасим скорость постоянно
                pcall(function()
                    if part.AssemblyLinearVelocity.Magnitude > 0.5 then
                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    end
                    if part.AssemblyAngularVelocity.Magnitude > 0.5 then
                        part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end)

                -- 3. Если сильно ушёл — возвращаем
                local dist = (part.Position - entry.alignPos.Position).Magnitude
                if dist > 2 then
                    pcall(function()
                        part.CFrame = CFrame.new(entry.alignPos.Position)
                            * (entry.savedCF - entry.savedCF.Position)
                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end)
                    forceOwnership(part)
                end

                -- 4. Мягкое восстановление угла
                pcall(function()
                    local currentRot = part.CFrame - part.CFrame.Position
                    local savedRot = entry.savedCF - entry.savedCF.Position
                    local dot = currentRot.LookVector:Dot(savedRot.LookVector)
                    dot = math.clamp(dot, -1, 1)
                    local angleDiff = math.deg(math.acos(dot))
                    if angleDiff > 30 then
                        part.CFrame = CFrame.new(part.Position) * savedRot
                        part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end)
            end
        end
    end
end))

-- SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RoflHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

local ModalBtn = Instance.new("TextButton")
ModalBtn.Name = "RoflHubModal"
ModalBtn.Size = UDim2.new(1, 0, 1, 0)
ModalBtn.Position = UDim2.new(0, 0, 0, 0)
ModalBtn.BackgroundTransparency = 1
ModalBtn.Text = ""
ModalBtn.AutoButtonColor = false
ModalBtn.Modal = false
ModalBtn.Visible = false
ModalBtn.ZIndex = 1
ModalBtn.Parent = ScreenGui

-- BLUR
for _, obj in ipairs(Lighting:GetChildren()) do
    if obj:IsA("BlurEffect") then pcall(function() obj:Destroy() end) end
end

local Blur = Instance.new("BlurEffect")
Blur.Name = "RoflHubBlur"
Blur.Size = 0
Blur.Parent = Lighting

local blurTarget = 0
local blurTween = nil

local function setBlur(target)
    blurTarget = target
    if blurTween then pcall(function() blurTween:Cancel() end) end
    blurTween = TweenService:Create(Blur, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = target })
    blurTween:Play()
end

addConn(RunService.RenderStepped:Connect(function()
    if blurTarget > 0 and Blur.Size < 5 then setBlur(blurTarget)
    elseif blurTarget == 0 and Blur.Size > 5 then setBlur(0) end
end))

-- TOASTS
local toastContainer = Instance.new("Frame")
toastContainer.Name = "ToastContainer"
toastContainer.AnchorPoint = Vector2.new(1, 0)
toastContainer.Position = UDim2.new(1, -20, 0, 80)
toastContainer.Size = UDim2.new(0, 280, 0, 400)
toastContainer.BackgroundTransparency = 1
toastContainer.Parent = ScreenGui

local toastLayout = Instance.new("UIListLayout")
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Padding = UDim.new(0, 8)
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
toastLayout.Parent = toastContainer

local function showToast(title, subtitle)
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 56)
    toast.BackgroundColor3 = PANEL_COLOR
    toast.BorderSizePixel = 0
    toast.Position = UDim2.new(1, 320, 0, 0)
    toast.Parent = toastContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toast

    local stroke = Instance.new("UIStroke")
    stroke.Color = ACCENT
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = toast

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, -12)
    accentBar.Position = UDim2.new(0, 6, 0, 6)
    accentBar.BackgroundColor3 = ACCENT
    accentBar.BorderSizePixel = 0
    accentBar.Parent = toast

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = accentBar

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -30, 0, 20)
    titleLbl.Position = UDim2.new(0, 18, 0, 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = TEXT_COLOR
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = toast

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(1, -30, 0, 16)
    subLbl.Position = UDim2.new(0, 18, 0, 30)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = subtitle or ""
    subLbl.TextColor3 = SUBTEXT_COLOR
    subLbl.Font = Enum.Font.Gotham
    subLbl.TextSize = 12
    subLbl.TextXAlignment = Enum.TextXAlignment.Left
    subLbl.Parent = toast

    TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    task.delay(2.5, function()
        if toast and toast.Parent then
            TweenService:Create(toast, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(titleLbl, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
            TweenService:Create(subLbl, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.3), { Transparency = 1 }):Play()
            TweenService:Create(accentBar, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            task.wait(0.35)
            if toast then toast:Destroy() end
        end
    end)
end

-- MAIN WINDOW
local Window = Instance.new("Frame")
Window.Name = "Window"
Window.AnchorPoint = Vector2.new(0.5, 0.5)
Window.Position = UDim2.new(0.5, 0, 0.5, 0)
Window.Size = UDim2.new(0, 580, 0, 400)
Window.BackgroundColor3 = BG_COLOR
Window.BorderSizePixel = 0
Window.Active = false
Window.ClipsDescendants = true
Window.Parent = ScreenGui

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0, 14)
WindowCorner.Parent = Window

local WindowStroke = Instance.new("UIStroke")
WindowStroke.Color = Color3.fromRGB(58, 58, 74)
WindowStroke.Thickness = 1
WindowStroke.Transparency = 0.15
WindowStroke.Parent = Window

local WindowGradient = Instance.new("UIGradient")
WindowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(20, 20, 28)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(14, 14, 20)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(18, 18, 24)),
})
WindowGradient.Rotation = 45
WindowGradient.Parent = Window

local windowGradientOffset = 0
addConn(RunService.RenderStepped:Connect(function(dt)
    if not Window.Visible then return end
    windowGradientOffset = (windowGradientOffset + dt * 0.08) % 1
    WindowGradient.Offset = Vector2.new(windowGradientOffset, 0)
end))

local TopAccent = Instance.new("Frame")
TopAccent.Size = UDim2.new(1, -40, 0, 1)
TopAccent.Position = UDim2.new(0, 20, 0, 0)
TopAccent.BackgroundColor3 = ACCENT
TopAccent.BackgroundTransparency = 0.5
TopAccent.BorderSizePixel = 0
TopAccent.ZIndex = 5
TopAccent.Parent = Window
registerTheme(TopAccent, "BackgroundColor3", "accent")

-- DRAG STRIPS
local function makeDragStrip(name, size, position)
    local strip = Instance.new("Frame")
    strip.Name = name
    strip.Size = size
    strip.Position = position
    strip.BackgroundTransparency = 1
    strip.BorderSizePixel = 0
    strip.Active = true
    strip.ZIndex = 10
    strip.Parent = Window
    return strip
end

local dragStrips = {
    makeDragStrip("TopEdge",    UDim2.new(1, 0, 0, EDGE_SIZE), UDim2.new(0, 0, 0, 0)),
    makeDragStrip("BottomEdge", UDim2.new(1, 0, 0, EDGE_SIZE), UDim2.new(0, 0, 1, -EDGE_SIZE)),
    makeDragStrip("LeftEdge",   UDim2.new(0, EDGE_SIZE, 1, 0), UDim2.new(0, 0, 0, 0)),
    makeDragStrip("RightEdge",  UDim2.new(0, EDGE_SIZE, 1, 0), UDim2.new(1, -EDGE_SIZE, 0, 0)),
    makeDragStrip("TopLeft",    UDim2.new(0, CORNER_SIZE, 0, CORNER_SIZE), UDim2.new(0, 0, 0, 0)),
    makeDragStrip("TopRight",   UDim2.new(0, CORNER_SIZE, 0, CORNER_SIZE), UDim2.new(1, -CORNER_SIZE, 0, 0)),
    makeDragStrip("BottomLeft", UDim2.new(0, CORNER_SIZE, 0, CORNER_SIZE), UDim2.new(0, 0, 1, -CORNER_SIZE)),
    makeDragStrip("BottomRight",UDim2.new(0, CORNER_SIZE, 0, CORNER_SIZE), UDim2.new(1, -CORNER_SIZE, 1, -CORNER_SIZE)),
}

local dragging, dragStart, startPos = false, nil, nil

local function beginDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos  = Window.Position
    end
end

local function updateDrag(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end

local function endDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end

for _, strip in ipairs(dragStrips) do
    addConn(strip.InputBegan:Connect(beginDrag))
end
addConn(UserInputService.InputChanged:Connect(updateDrag))
addConn(UserInputService.InputEnded:Connect(endDrag))

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 52)
TitleBar.BackgroundColor3 = PANEL_COLOR
TitleBar.BackgroundTransparency = 0.25
TitleBar.BorderSizePixel = 0
TitleBar.Active = false
TitleBar.ClipsDescendants = true
TitleBar.ZIndex = 2
TitleBar.Parent = Window

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 20)
TitleFix.Position = UDim2.new(0, 0, 1, -20)
TitleFix.BackgroundColor3 = PANEL_COLOR
TitleFix.BackgroundTransparency = 0.25
TitleFix.BorderSizePixel = 0
TitleFix.Active = false
TitleFix.ZIndex = 2
TitleFix.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(38, 38, 52)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(28, 28, 38)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(22, 22, 28)),
})
TitleGradient.Parent = TitleBar

local titleGradientOffset = 0
addConn(RunService.RenderStepped:Connect(function(dt)
    if not Window.Visible then return end
    titleGradientOffset = (titleGradientOffset + dt * 0.15) % 1
    TitleGradient.Offset = Vector2.new(titleGradientOffset, 0)
end))

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(1, -32, 0, 1)
AccentLine.Position = UDim2.new(0, 16, 1, -1)
AccentLine.BackgroundColor3 = ACCENT
AccentLine.BackgroundTransparency = 0.3
AccentLine.BorderSizePixel = 0
AccentLine.ZIndex = 3
AccentLine.Parent = TitleBar
registerTheme(AccentLine, "BackgroundColor3", "accent")

local LogoFrame = Instance.new("Frame")
LogoFrame.Size = UDim2.new(0, 32, 0, 32)
LogoFrame.Position = UDim2.new(0, 14, 0.5, -16)
LogoFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
LogoFrame.BorderSizePixel = 0
LogoFrame.ZIndex = 3
LogoFrame.Parent = TitleBar

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = LogoFrame

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = ACCENT
LogoStroke.Thickness = 1.5
LogoStroke.Parent = LogoFrame
registerTheme(LogoStroke, "Color", "accent")

local LogoImage = Instance.new("ImageLabel")
LogoImage.Size = UDim2.new(1, -2, 1, -2)
LogoImage.Position = UDim2.new(0, 1, 0, 1)
LogoImage.BackgroundTransparency = 1
LogoImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
LogoImage.ZIndex = 4
LogoImage.Parent = LogoFrame

local LogoImageCorner = Instance.new("UICorner")
LogoImageCorner.CornerRadius = UDim.new(1, 0)
LogoImageCorner.Parent = LogoImage

task.spawn(function()
    pcall(function()
        local url = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
        if url and LogoImage then LogoImage.Image = url end
    end)
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 100, 0, 18)
TitleLabel.Position = UDim2.new(0, 54, 0, 12)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = HUB_NAME
TitleLabel.TextColor3 = TEXT_COLOR
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 60, 0, 18)
VersionLabel.Position = UDim2.new(0, 158, 0, 17)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = HUB_VERSION
VersionLabel.TextColor3 = ACCENT
VersionLabel.Font = Enum.Font.GothamBold
VersionLabel.TextSize = 11
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.ZIndex = 3
VersionLabel.Parent = TitleBar
registerTheme(VersionLabel, "TextColor3", "accent")

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -70, 0.5, -14)
MinBtn.BackgroundColor3 = BTN_COLOR
MinBtn.BackgroundTransparency = 0.3
MinBtn.BorderSizePixel = 0
MinBtn.Text = "—"
MinBtn.TextColor3 = TEXT_COLOR
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.AutoButtonColor = false
MinBtn.ZIndex = 4
MinBtn.Parent = TitleBar

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(1, 0)
MinBtnCorner.Parent = MinBtn

addConn(MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0, BackgroundColor3 = BTN_HOVER}):Play()
end))
addConn(MinBtn.MouseLeave:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, BackgroundColor3 = BTN_COLOR}):Play()
end))

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = BTN_COLOR
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = TEXT_COLOR
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 4
CloseBtn.Parent = TitleBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(1, 0)
CloseBtnCorner.Parent = CloseBtn

addConn(CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0, BackgroundColor3 = CLOSE_COLOR}):Play()
end))
addConn(CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, BackgroundColor3 = BTN_COLOR}):Play()
end))

-- RIPPLE
local function spawnRipple(parentFrame, xRatio, yRatio)
    local ripple = Instance.new("Frame")
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Position = UDim2.new(xRatio, 0, yRatio, 0)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.ZIndex = 8
    ripple.Parent = parentFrame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = ripple

    local targetSize = math.max(parentFrame.AbsoluteSize.X, parentFrame.AbsoluteSize.Y) * 2

    TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, targetSize, 0, targetSize),
        BackgroundTransparency = 1,
    }):Play()

    task.delay(0.5, function()
        if ripple and ripple.Parent then ripple:Destroy() end
    end)
end

local function attachRipple(obj)
    addConn(obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local relX = (input.Position.X - obj.AbsolutePosition.X) / math.max(obj.AbsoluteSize.X, 1)
            local relY = (input.Position.Y - obj.AbsolutePosition.Y) / math.max(obj.AbsoluteSize.Y, 1)
            spawnRipple(obj, math.clamp(relX, 0, 1), math.clamp(relY, 0, 1))
        end
    end))
end

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 155, 1, -80)
Sidebar.Position = UDim2.new(0, 12, 0, 62)
Sidebar.BackgroundColor3 = PANEL_COLOR
Sidebar.BackgroundTransparency = 0.4
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2
Sidebar.Parent = Window

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

local SidebarStroke = Instance.new("UIStroke")
SidebarStroke.Color = Color3.fromRGB(48, 48, 62)
SidebarStroke.Thickness = 1
SidebarStroke.Transparency = 0.4
SidebarStroke.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 10)
SidebarPad.PaddingLeft = UDim.new(0, 8)
SidebarPad.PaddingRight = UDim.new(0, 8)
SidebarPad.Parent = Sidebar

-- CONTENT
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -190, 1, -88)
Content.Position = UDim2.new(0, 177, 0, 62)
Content.BackgroundColor3 = PANEL_INNER
Content.BackgroundTransparency = 0.4
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.ZIndex = 2
Content.Parent = Window

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 12)
ContentCorner.Parent = Content

local ContentStroke = Instance.new("UIStroke")
ContentStroke.Color = Color3.fromRGB(48, 48, 62)
ContentStroke.Thickness = 1
ContentStroke.Transparency = 0.4
ContentStroke.Parent = Content

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, 0)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 90)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.ZIndex = 3
Scroll.Active = true
Scroll.Parent = Content

addConn(UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
    if not ScreenGui.Enabled then return end
    local mouse = UserInputService:GetMouseLocation()
    local sp = Scroll.AbsolutePosition
    local ss = Scroll.AbsoluteSize
    if mouse.X >= sp.X and mouse.X <= sp.X + ss.X
    and mouse.Y >= sp.Y and mouse.Y <= sp.Y + ss.Y then
        local newY = Scroll.CanvasPosition.Y - input.Position.Z * 40
        local maxY = math.max(0, Scroll.AbsoluteCanvasSize.Y - Scroll.AbsoluteSize.Y)
        Scroll.CanvasPosition = Vector2.new(0, math.clamp(newY, 0, maxY))
    end
end))

local ScrollPad = Instance.new("UIPadding")
ScrollPad.PaddingTop = UDim.new(0, 14)
ScrollPad.PaddingLeft = UDim.new(0, 16)
ScrollPad.PaddingRight = UDim.new(0, 16)
ScrollPad.PaddingBottom = UDim.new(0, 14)
ScrollPad.Parent = Scroll

local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
ScrollLayout.Padding = UDim.new(0, 8)
ScrollLayout.Parent = Scroll

-- TAB SYSTEM
local function fadeInSection(section)
    local snapshots = {}
    for _, obj in ipairs(section:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            snapshots[obj] = { prop = "TextTransparency", value = obj.TextTransparency }
            obj.TextTransparency = 1
        end
        if obj:IsA("Frame") then
            snapshots[obj] = { prop = "BackgroundTransparency", value = obj.BackgroundTransparency }
            obj.BackgroundTransparency = 1
        end
    end

    task.spawn(function()
        local t0 = tick()
        local dur = 0.2
        while tick() - t0 < dur do
            local a = math.clamp((tick() - t0) / dur, 0, 1)
            for obj, data in pairs(snapshots) do
                if obj and obj.Parent then
                    if data.prop == "TextTransparency" then
                        obj.TextTransparency = 1 - (1 - data.value) * a
                    else
                        obj.BackgroundTransparency = 1 - (1 - data.value) * a
                    end
                end
            end
            RunService.RenderStepped:Wait()
        end
        for obj, data in pairs(snapshots) do
            if obj and obj.Parent then obj[data.prop] = data.value end
        end
    end)
end

local function createTab(tabName, iconEmoji)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = BTN_COLOR
    btn.BackgroundTransparency = 0.5
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.ZIndex = 3
    btn.Parent = Sidebar

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = ACCENT
    btnStroke.Thickness = 1
    btnStroke.Transparency = 1
    btnStroke.Parent = btn
    registerTheme(btnStroke, "Color", "accent")

    local leftBar = Instance.new("Frame")
    leftBar.Size = UDim2.new(0, 3, 0, 20)
    leftBar.Position = UDim2.new(0, 2, 0.5, -10)
    leftBar.BackgroundColor3 = ACCENT
    leftBar.BorderSizePixel = 0
    leftBar.BackgroundTransparency = 1
    leftBar.ZIndex = 4
    leftBar.Parent = btn
    registerTheme(leftBar, "BackgroundColor3", "accent")

    local leftBarCorner = Instance.new("UICorner")
    leftBarCorner.CornerRadius = UDim.new(1, 0)
    leftBarCorner.Parent = leftBar

    local iconCircle = Instance.new("Frame")
    iconCircle.Size = UDim2.new(0, 24, 0, 24)
    iconCircle.Position = UDim2.new(0, 12, 0.5, -12)
    iconCircle.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    iconCircle.BackgroundTransparency = 0.3
    iconCircle.BorderSizePixel = 0
    iconCircle.ZIndex = 3
    iconCircle.Parent = btn

    local iconCircleCorner = Instance.new("UICorner")
    iconCircleCorner.CornerRadius = UDim.new(1, 0)
    iconCircleCorner.Parent = iconCircle

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = iconEmoji or ""
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 13
    icon.TextColor3 = TEXT_COLOR
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.ZIndex = 4
    icon.Parent = iconCircle

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 44, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tabName
    lbl.TextColor3 = TEXT_COLOR
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = btn

    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.BackgroundTransparency = 1
    section.Visible = false
    section.ZIndex = 3
    section.Parent = Scroll

    local secLayout = Instance.new("UIListLayout")
    secLayout.SortOrder = Enum.SortOrder.LayoutOrder
    secLayout.Padding = UDim.new(0, 8)
    secLayout.Parent = section

    sections[tabName] = section
    table.insert(tabButtons, {
        button = btn,
        name = tabName,
        label = lbl,
        icon = icon,
        stroke = btnStroke,
        leftBar = leftBar,
    })

    attachRipple(btn)

    addConn(btn.MouseButton1Click:Connect(function()
        activeTabName = tabName
        for _, data in ipairs(tabButtons) do
            TweenService:Create(data.button, THEME_TWEEN_INFO, {BackgroundTransparency = 0.5}):Play()
            data.label.TextColor3 = TEXT_COLOR
            data.icon.TextColor3 = TEXT_COLOR
            TweenService:Create(data.leftBar, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(data.stroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
        end
        TweenService:Create(btn, THEME_TWEEN_INFO, {BackgroundTransparency = 0}):Play()
        TweenService:Create(btn, THEME_TWEEN_INFO, {BackgroundColor3 = BTN_ACTIVE}):Play()
        lbl.TextColor3 = ACCENT
        icon.TextColor3 = ACCENT
        TweenService:Create(leftBar, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play()
        for _, sec in pairs(sections) do sec.Visible = false end
        section.Visible = true
        fadeInSection(section)
    end))

    addConn(btn.MouseEnter:Connect(function()
        if btn.BackgroundColor3 ~= BTN_ACTIVE then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.15}):Play()
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_HOVER}):Play()
        end
    end))
    addConn(btn.MouseLeave:Connect(function()
        if btn.BackgroundColor3 ~= BTN_ACTIVE then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.5}):Play()
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_COLOR}):Play()
        end
    end))

    return section
end

-- WIDGETS
local function addLabel(parent, text, subtext)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, subtext and 46 or 26)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 3
    holder.Parent = parent

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0, 18)
    bar.Position = UDim2.new(0, 0, 0, 2)
    bar.BackgroundColor3 = ACCENT
    bar.BorderSizePixel = 0
    bar.ZIndex = 3
    bar.Parent = holder
    registerTheme(bar, "BackgroundColor3", "accent")

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 0, 22)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = TEXT_COLOR
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = holder

    if subtext then
        local sub = Instance.new("TextLabel")
        sub.Size = UDim2.new(1, -12, 0, 16)
        sub.Position = UDim2.new(0, 12, 0, 24)
        sub.BackgroundTransparency = 1
        sub.Text = subtext
        sub.TextColor3 = SUBTEXT_COLOR
        sub.Font = Enum.Font.Gotham
        sub.TextSize = 12
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.ZIndex = 3
        sub.Parent = holder
    end
    return holder
end

local function addSlider(parent, labelText, minV, maxV, defaultValue, suffix, onChanged, registerReset)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 62)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 3
    holder.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText .. ": " .. math.floor(defaultValue) .. (suffix or "")
    lbl.TextColor3 = TEXT_COLOR
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = holder

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 32)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    bar.BorderSizePixel = 0
    bar.ZIndex = 3
    bar.Parent = holder

    local barC = Instance.new("UICorner")
    barC.CornerRadius = UDim.new(1, 0)
    barC.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((defaultValue - minV) / (maxV - minV), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = ACCENT
    fill.BorderSizePixel = 0
    fill.ZIndex = 3
    fill.Parent = bar

    local fillC = Instance.new("UICorner")
    fillC.CornerRadius = UDim.new(1, 0)
    fillC.Parent = fill

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, ACCENT_DARK),
        ColorSequenceKeypoint.new(1, ACCENT),
    })
    fillGradient.Parent = fill

    registerTheme(fill, "BackgroundColor3", "accent")
    registerTheme(fillGradient, "Color", "gradient")

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(math.clamp((defaultValue - minV) / (maxV - minV), 0, 1), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 4
    knob.Parent = bar

    local knobC = Instance.new("UICorner")
    knobC.CornerRadius = UDim.new(1, 0)
    knobC.Parent = knob

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = ACCENT
    knobStroke.Thickness = 2
    knobStroke.Parent = knob
    registerTheme(knobStroke, "Color", "accent")

    local draggingSlider = false

    local function setValue(v)
        v = math.clamp(v, minV, maxV)
        lbl.Text = labelText .. ": " .. math.floor(v) .. (suffix or "")
        local r = (v - minV) / (maxV - minV)
        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, -8, 0.5, -8)
        if onChanged then onChanged(v) end
    end

    if registerReset then registerReset(setValue, defaultValue) end

    addConn(bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
            local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            setValue(minV + rel * (maxV - minV))
        end
    end))

    addConn(UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            setValue(minV + rel * (maxV - minV))
        end
    end))

    addConn(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end))

    return {setValue = setValue}
end

local function addToggle(parent, text, iconEmoji, defaultState, callback)
    local state = defaultState or false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = BTN_COLOR
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.ZIndex = 3
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = btn

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 22, 1, 0)
    icon.Position = UDim2.new(0, 12, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = iconEmoji or ""
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 13
    icon.TextColor3 = TEXT_COLOR
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.ZIndex = 3
    icon.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 38, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = TEXT_COLOR
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = btn

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 36, 0, 18)
    track.Position = UDim2.new(1, -50, 0.5, -9)
    track.BackgroundColor3 = state and ACCENT or Color3.fromRGB(50, 50, 62)
    track.BorderSizePixel = 0
    track.ZIndex = 3
    track.Parent = btn

    local trackC = Instance.new("UICorner")
    trackC.CornerRadius = UDim.new(1, 0)
    trackC.Parent = track

    local ball = Instance.new("Frame")
    ball.Size = UDim2.new(0, 14, 0, 14)
    ball.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    ball.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    ball.BorderSizePixel = 0
    ball.ZIndex = 4
    ball.Parent = track

    local ballC = Instance.new("UICorner")
    ballC.CornerRadius = UDim.new(1, 0)
    ballC.Parent = ball

    registerTheme(track, "BackgroundColor3", "accentOnWhen", {
        isOn = function() return state end,
    })

    attachRipple(btn)

    addConn(btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0, BackgroundColor3 = BTN_HOVER}):Play()
    end))
    addConn(btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, BackgroundColor3 = BTN_COLOR}):Play()
    end))

    local function setState(newState, fireCallback)
        state = newState
        if state then
            TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = ACCENT}):Play()
            TweenService:Create(ball, TweenInfo.new(0.15), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
        else
            TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 50, 62)}):Play()
            TweenService:Create(ball, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
        end
        if fireCallback and callback then callback(state) end
    end

    addConn(btn.MouseButton1Click:Connect(function()
        setState(not state, true)
        showToast(text, state and "Enabled" or "Disabled")
    end))

    return {button = btn, setState = setState, isOn = function() return state end}
end

-- DROPDOWN
local function addDropdown(parent, labelText, options, defaultIndex, onChanged, config)
    config = config or {}
    local showAvatar = config.showAvatar or false
    local showIcon   = config.showIcon or false
    local iconEmoji  = config.iconEmoji or "🌌"

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 60)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 5
    holder.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = TEXT_COLOR
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = holder

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, 22)
    btn.BackgroundColor3 = BTN_COLOR
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 6
    btn.Parent = holder

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(58, 58, 74)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.3
    btnStroke.Parent = btn

    local previewIcon = Instance.new("Frame")
    previewIcon.Size = UDim2.new(0, 18, 0, 18)
    previewIcon.Position = UDim2.new(0, 10, 0.5, -9)
    previewIcon.BackgroundTransparency = 1
    previewIcon.ZIndex = 7
    previewIcon.Parent = btn

    if showAvatar then
        local av = Instance.new("ImageLabel")
        av.Name = "PreviewAvatar"
        av.Size = UDim2.new(1, 0, 1, 0)
        av.BackgroundTransparency = 1
        av.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        av.ZIndex = 7
        av.Parent = previewIcon
        local avc = Instance.new("UICorner")
        avc.CornerRadius = UDim.new(1, 0)
        avc.Parent = av
    elseif showIcon then
        local ic = Instance.new("TextLabel")
        ic.Name = "PreviewIcon"
        ic.Size = UDim2.new(1, 0, 1, 0)
        ic.BackgroundTransparency = 1
        ic.Text = iconEmoji
        ic.Font = Enum.Font.GothamBold
        ic.TextSize = 14
        ic.TextColor3 = TEXT_COLOR
        ic.ZIndex = 7
        ic.Parent = previewIcon
    end

    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(1, -60, 1, 0)
    selectedLbl.Position = UDim2.new(0, 34, 0, 0)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Text = options[defaultIndex].name or options[defaultIndex]
    selectedLbl.TextColor3 = TEXT_COLOR
    selectedLbl.Font = Enum.Font.GothamMedium
    selectedLbl.TextSize = 13
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Left
    selectedLbl.ZIndex = 7
    selectedLbl.Parent = btn

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 24, 1, 0)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = SUBTEXT_COLOR
    arrow.Font = Enum.Font.Gotham
    arrow.TextSize = 9
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.ZIndex = 7
    arrow.Parent = btn

    local list = Instance.new("Frame")
    list.Size = UDim2.new(0, 300, 0, #options * 34 + 12)
    list.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    list.BorderSizePixel = 0
    list.Visible = false
    list.ZIndex = 50
    list.ClipsDescendants = true
    list.Parent = ScreenGui

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = list

    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(70, 70, 90)
    listStroke.Thickness = 1
    listStroke.Transparency = 0.1
    listStroke.Parent = list

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 110)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 34 + 8)
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    scrollFrame.ZIndex = 51
    scrollFrame.Parent = list

    local scrollPad = Instance.new("UIPadding")
    scrollPad.PaddingTop = UDim.new(0, 6)
    scrollPad.PaddingBottom = UDim.new(0, 6)
    scrollPad.PaddingLeft = UDim.new(0, 4)
    scrollPad.PaddingRight = UDim.new(0, 4)
    scrollPad.Parent = scrollFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = scrollFrame

    local currentIndex = defaultIndex
    local isOpen = false

    local function updatePreview()
        local opt = options[currentIndex]
        if not opt then return end
        local name = opt.name or opt
        selectedLbl.Text = name

        if showAvatar then
            local av = previewIcon:FindFirstChild("PreviewAvatar")
            if av then
                local plr = Players:FindFirstChild(name)
                if plr then
                    task.spawn(function()
                        local ok, url = pcall(function()
                            return Players:GetUserThumbnailAsync(
                                plr.UserId,
                                Enum.ThumbnailType.HeadShot,
                                Enum.ThumbnailSize.Size100x100
                            )
                        end)
                        if ok and url and av and av.Parent then
                            av.Image = url
                        end
                    end)
                else
                    av.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
                end
            end
        end
    end

    local function closeList()
        isOpen = false
        list.Visible = false
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_COLOR}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.15), {Transparency = 0.3, Color = Color3.fromRGB(58, 58, 74)}):Play()
    end

    local function openList()
        list.Position = UDim2.new(
            0, btn.AbsolutePosition.X - 4,
            0, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y + 6
        )
        local maxH = 280
        local totalH = #options * 34 + 12
        list.Size = UDim2.new(0, btn.AbsoluteSize.X + 8, 0, math.min(totalH, maxH))
        isOpen = true
        list.Visible = true

        list.BackgroundTransparency = 0.3
        TweenService:Create(list, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()

        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_ACTIVE}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.15), {Color = ACCENT, Transparency = 0.2}):Play()
    end

    local function selectOption(idx)
        if not options[idx] then return end
        currentIndex = idx
        updatePreview()
        closeList()
        if onChanged then onChanged(options[idx], idx) end
    end

    for i, opt in ipairs(options) do
        local name = opt.name or opt

        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1, 0, 0, 32)
        item.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        item.BackgroundTransparency = 1
        item.BorderSizePixel = 0
        item.Text = ""
        item.AutoButtonColor = false
        item.ZIndex = 52
        item.Parent = scrollFrame

        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 7)
        itemCorner.Parent = item

        local accentBar = Instance.new("Frame")
        accentBar.Size = UDim2.new(0, 3, 0, 18)
        accentBar.Position = UDim2.new(0, 4, 0.5, -9)
        accentBar.BackgroundColor3 = ACCENT
        accentBar.BackgroundTransparency = 1
        accentBar.BorderSizePixel = 0
        accentBar.ZIndex = 53
        accentBar.Parent = item
        registerTheme(accentBar, "BackgroundColor3", "accent")

        local accentCorner = Instance.new("UICorner")
        accentCorner.CornerRadius = UDim.new(1, 0)
        accentCorner.Parent = accentBar

        if showAvatar then
            local itemIcon = Instance.new("ImageLabel")
            itemIcon.Size = UDim2.new(0, 22, 0, 22)
            itemIcon.Position = UDim2.new(0, 12, 0.5, -11)
            itemIcon.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            itemIcon.BorderSizePixel = 0
            itemIcon.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
            itemIcon.ZIndex = 53
            itemIcon.Parent = item

            local ic = Instance.new("UICorner")
            ic.CornerRadius = UDim.new(1, 0)
            ic.Parent = itemIcon

            task.spawn(function()
                local plr = Players:FindFirstChild(name)
                if plr then
                    local ok, url = pcall(function()
                        return Players:GetUserThumbnailAsync(
                            plr.UserId,
                            Enum.ThumbnailType.HeadShot,
                            Enum.ThumbnailSize.Size100x100
                        )
                    end)
                    if ok and url and itemIcon and itemIcon.Parent then
                        itemIcon.Image = url
                    end
                end
            end)
        elseif showIcon then
            local iconHolder = Instance.new("Frame")
            iconHolder.Size = UDim2.new(0, 22, 0, 22)
            iconHolder.Position = UDim2.new(0, 12, 0.5, -11)
            iconHolder.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            iconHolder.BorderSizePixel = 0
            iconHolder.ZIndex = 53
            iconHolder.Parent = item

            local ic = Instance.new("UICorner")
            ic.CornerRadius = UDim.new(1, 0)
            ic.Parent = iconHolder

            local icLbl = Instance.new("TextLabel")
            icLbl.Size = UDim2.new(1, 0, 1, 0)
            icLbl.BackgroundTransparency = 1
            icLbl.Text = iconEmoji
            icLbl.Font = Enum.Font.GothamBold
            icLbl.TextSize = 13
            icLbl.TextColor3 = TEXT_COLOR
            icLbl.ZIndex = 54
            icLbl.Parent = iconHolder
        end

        local itemLbl = Instance.new("TextLabel")
        itemLbl.Size = UDim2.new(1, -80, 1, 0)
        itemLbl.Position = UDim2.new(0, (showAvatar or showIcon) and 42 or 14, 0, 0)
        itemLbl.BackgroundTransparency = 1
        itemLbl.Text = name
        itemLbl.TextColor3 = TEXT_COLOR
        itemLbl.Font = Enum.Font.GothamMedium
        itemLbl.TextSize = 13
        itemLbl.TextXAlignment = Enum.TextXAlignment.Left
        itemLbl.ZIndex = 53
        itemLbl.Parent = item

        local check = Instance.new("TextLabel")
        check.Size = UDim2.new(0, 20, 1, 0)
        check.Position = UDim2.new(1, -28, 0, 0)
        check.BackgroundTransparency = 1
        check.Text = (i == currentIndex) and "✓" or ""
        check.TextColor3 = ACCENT
        check.Font = Enum.Font.GothamBold
        check.TextSize = 14
        check.TextXAlignment = Enum.TextXAlignment.Right
        check.ZIndex = 53
        check.Parent = item
        registerTheme(check, "TextColor3", "accent")

        addConn(item.MouseEnter:Connect(function()
            TweenService:Create(item, TweenInfo.new(0.1), {BackgroundTransparency = 0.85}):Play()
            TweenService:Create(accentBar, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        end))
        addConn(item.MouseLeave:Connect(function()
            TweenService:Create(item, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
            TweenService:Create(accentBar, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end))
        addConn(item.MouseButton1Click:Connect(function()
            selectOption(i)
        end))
    end

    local self = {
        setIndex = function(idx)
            if not options[idx] then return end
            currentIndex = idx
            updatePreview()
        end,
        getIndex = function() return currentIndex end,
        close = closeList,
        isOpen = function() return isOpen end,
        _list = list,
        _btn = btn,
        _scroller = scrollFrame,
    }
    registerOpenDropdown(self)

    addConn(btn.MouseButton1Click:Connect(function()
        for _, dd in ipairs(openDropdowns) do
            if dd ~= self then pcall(function() dd.close() end) end
        end
        if isOpen then
            closeList()
        else
            openList()
            markIgnoreNextClicks(0.1)
        end
    end))

    updatePreview()
    return self
end

-- MULTI-SELECT DROPDOWN
local function addMultiSelectDropdown(parent, labelText, getOptions, onChanged)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 60)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 5
    holder.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = TEXT_COLOR
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = holder

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, 22)
    btn.BackgroundColor3 = BTN_COLOR
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 6
    btn.Parent = holder

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(58, 58, 74)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.3
    btnStroke.Parent = btn

    local previewIcon = Instance.new("Frame")
    previewIcon.Size = UDim2.new(0, 18, 0, 18)
    previewIcon.Position = UDim2.new(0, 10, 0.5, -9)
    previewIcon.BackgroundTransparency = 1
    previewIcon.ZIndex = 7
    previewIcon.Parent = btn

    local previewLbl = Instance.new("TextLabel")
    previewLbl.Size = UDim2.new(1, 0, 1, 0)
    previewLbl.BackgroundTransparency = 1
    previewLbl.Text = "👥"
    previewLbl.Font = Enum.Font.GothamBold
    previewLbl.TextSize = 14
    previewLbl.TextColor3 = TEXT_COLOR
    previewLbl.ZIndex = 7
    previewLbl.Parent = previewIcon

    local selectedLbl = Instance.new("TextLabel")
    selectedLbl.Size = UDim2.new(1, -60, 1, 0)
    selectedLbl.Position = UDim2.new(0, 34, 0, 0)
    selectedLbl.BackgroundTransparency = 1
    selectedLbl.Text = targetLabelText()
    selectedLbl.TextColor3 = TEXT_COLOR
    selectedLbl.Font = Enum.Font.GothamMedium
    selectedLbl.TextSize = 13
    selectedLbl.TextXAlignment = Enum.TextXAlignment.Left
    selectedLbl.ZIndex = 7
    selectedLbl.Parent = btn

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 24, 1, 0)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = SUBTEXT_COLOR
    arrow.Font = Enum.Font.Gotham
    arrow.TextSize = 9
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.ZIndex = 7
    arrow.Parent = btn

    local list = Instance.new("Frame")
    list.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    list.BorderSizePixel = 0
    list.Visible = false
    list.ZIndex = 50
    list.ClipsDescendants = true
    list.Parent = ScreenGui

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = list

    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(70, 70, 90)
    listStroke.Thickness = 1
    listStroke.Transparency = 0.1
    listStroke.Parent = list

    local scroller = Instance.new("ScrollingFrame")
    scroller.Size = UDim2.new(1, 0, 1, 0)
    scroller.BackgroundTransparency = 1
    scroller.BorderSizePixel = 0
    scroller.ScrollBarThickness = 3
    scroller.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 110)
    scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroller.ScrollingDirection = Enum.ScrollingDirection.Y
    scroller.ZIndex = 51
    scroller.Parent = list

    local scrollerPad = Instance.new("UIPadding")
    scrollerPad.PaddingTop = UDim.new(0, 6)
    scrollerPad.PaddingBottom = UDim.new(0, 6)
    scrollerPad.PaddingLeft = UDim.new(0, 4)
    scrollerPad.PaddingRight = UDim.new(0, 4)
    scrollerPad.Parent = scroller

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = scroller

    local isOpen = false

    local function closeList()
        isOpen = false
        list.Visible = false
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_COLOR}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(58, 58, 74), Transparency = 0.3}):Play()
    end

    local function refreshLabel()
        selectedLbl.Text = targetLabelText()
    end

    local function rebuildRows()
        for _, ch in ipairs(scroller:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end

        local names = getOptions()

        local allRow = Instance.new("TextButton")
        allRow.Size = UDim2.new(1, 0, 0, 32)
        allRow.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
        allRow.BackgroundTransparency = 1
        allRow.BorderSizePixel = 0
        allRow.Text = ""
        allRow.AutoButtonColor = false
        allRow.ZIndex = 52
        allRow.Parent = scroller

        local arc = Instance.new("UICorner")
        arc.CornerRadius = UDim.new(0, 7)
        arc.Parent = allRow

        local allAccent = Instance.new("Frame")
        allAccent.Size = UDim2.new(0, 3, 0, 18)
        allAccent.Position = UDim2.new(0, 4, 0.5, -9)
        allAccent.BackgroundColor3 = ACCENT
        allAccent.BackgroundTransparency = 1
        allAccent.BorderSizePixel = 0
        allAccent.ZIndex = 53
        allAccent.Parent = allRow
        registerTheme(allAccent, "BackgroundColor3", "accent")

        local allAccentC = Instance.new("UICorner")
        allAccentC.CornerRadius = UDim.new(1, 0)
        allAccentC.Parent = allAccent

        local allIcon = Instance.new("Frame")
        allIcon.Size = UDim2.new(0, 22, 0, 22)
        allIcon.Position = UDim2.new(0, 12, 0.5, -11)
        allIcon.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        allIcon.BorderSizePixel = 0
        allIcon.ZIndex = 53
        allIcon.Parent = allRow
        local allIconC = Instance.new("UICorner")
        allIconC.CornerRadius = UDim.new(1, 0)
        allIconC.Parent = allIcon
        local allIconLbl = Instance.new("TextLabel")
        allIconLbl.Size = UDim2.new(1, 0, 1, 0)
        allIconLbl.BackgroundTransparency = 1
        allIconLbl.Text = "🌐"
        allIconLbl.Font = Enum.Font.GothamBold
        allIconLbl.TextSize = 13
        allIconLbl.TextColor3 = TEXT_COLOR
        allIconLbl.ZIndex = 54
        allIconLbl.Parent = allIcon

        local allLbl = Instance.new("TextLabel")
        allLbl.Size = UDim2.new(1, -80, 1, 0)
        allLbl.Position = UDim2.new(0, 42, 0, 0)
        allLbl.BackgroundTransparency = 1
        allLbl.Text = "All Players"
        allLbl.TextColor3 = TEXT_COLOR
        allLbl.Font = Enum.Font.GothamMedium
        allLbl.TextSize = 13
        allLbl.TextXAlignment = Enum.TextXAlignment.Left
        allLbl.ZIndex = 53
        allLbl.Parent = allRow

        local allCheck = Instance.new("TextLabel")
        allCheck.Size = UDim2.new(0, 20, 1, 0)
        allCheck.Position = UDim2.new(1, -28, 0, 0)
        allCheck.BackgroundTransparency = 1
        allCheck.Text = allExplicit and "✓" or ""
        allCheck.TextColor3 = ACCENT
        allCheck.Font = Enum.Font.GothamBold
        allCheck.TextSize = 14
        allCheck.TextXAlignment = Enum.TextXAlignment.Right
        allCheck.ZIndex = 53
        allCheck.Parent = allRow
        registerTheme(allCheck, "TextColor3", "accent")

        addConn(allRow.MouseEnter:Connect(function()
            TweenService:Create(allRow, TweenInfo.new(0.1), {BackgroundTransparency = 0.85}):Play()
            TweenService:Create(allAccent, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        end))
        addConn(allRow.MouseLeave:Connect(function()
            TweenService:Create(allRow, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
            TweenService:Create(allAccent, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end))
        addConn(allRow.MouseButton1Click:Connect(function()
            espTargetSet = {}
            allExplicit = true
            refreshLabel()
            rebuildRows()
            if onChanged then onChanged() end
        end))

        for _, name in ipairs(names) do
            local row = Instance.new("TextButton")
            row.Size = UDim2.new(1, 0, 0, 32)
            row.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
            row.BackgroundTransparency = 1
            row.BorderSizePixel = 0
            row.Text = ""
            row.AutoButtonColor = false
            row.ZIndex = 52
            row.Parent = scroller

            local rc = Instance.new("UICorner")
            rc.CornerRadius = UDim.new(0, 7)
            rc.Parent = row

            local rowAccent = Instance.new("Frame")
            rowAccent.Size = UDim2.new(0, 3, 0, 18)
            rowAccent.Position = UDim2.new(0, 4, 0.5, -9)
            rowAccent.BackgroundColor3 = ACCENT
            rowAccent.BackgroundTransparency = 1
            rowAccent.BorderSizePixel = 0
            rowAccent.ZIndex = 53
            rowAccent.Parent = row
            registerTheme(rowAccent, "BackgroundColor3", "accent")

            local rowAccentC = Instance.new("UICorner")
            rowAccentC.CornerRadius = UDim.new(1, 0)
            rowAccentC.Parent = rowAccent

            local av = Instance.new("ImageLabel")
            av.Size = UDim2.new(0, 22, 0, 22)
            av.Position = UDim2.new(0, 12, 0.5, -11)
            av.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            av.BorderSizePixel = 0
            av.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
            av.ZIndex = 53
            av.Parent = row
            local avc = Instance.new("UICorner")
            avc.CornerRadius = UDim.new(1, 0)
            avc.Parent = av

            task.spawn(function()
                local plr = Players:FindFirstChild(name)
                if plr then
                    local ok, url = pcall(function()
                        return Players:GetUserThumbnailAsync(
                            plr.UserId,
                            Enum.ThumbnailType.HeadShot,
                            Enum.ThumbnailSize.Size100x100
                        )
                    end)
                    if ok and url and av and av.Parent then
                        av.Image = url
                    end
                end
            end)

            local rowLbl = Instance.new("TextLabel")
            rowLbl.Size = UDim2.new(1, -80, 1, 0)
            rowLbl.Position = UDim2.new(0, 42, 0, 0)
            rowLbl.BackgroundTransparency = 1
            rowLbl.Text = name
            rowLbl.TextColor3 = TEXT_COLOR
            rowLbl.Font = Enum.Font.GothamMedium
            rowLbl.TextSize = 13
            rowLbl.TextXAlignment = Enum.TextXAlignment.Left
            rowLbl.ZIndex = 53
            rowLbl.Parent = row

            local check = Instance.new("TextLabel")
            check.Size = UDim2.new(0, 20, 1, 0)
            check.Position = UDim2.new(1, -28, 0, 0)
            check.BackgroundTransparency = 1
            check.Text = espTargetSet[name] and "✓" or ""
            check.TextColor3 = ACCENT
            check.Font = Enum.Font.GothamBold
            check.TextSize = 14
            check.TextXAlignment = Enum.TextXAlignment.Right
            check.ZIndex = 53
            check.Parent = row
            registerTheme(check, "TextColor3", "accent")

            addConn(row.MouseEnter:Connect(function()
                TweenService:Create(row, TweenInfo.new(0.1), {BackgroundTransparency = 0.85}):Play()
                TweenService:Create(rowAccent, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
            end))
            addConn(row.MouseLeave:Connect(function()
                TweenService:Create(row, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
                TweenService:Create(rowAccent, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
            end))
            addConn(row.MouseButton1Click:Connect(function()
                if espTargetSet[name] then
                    espTargetSet[name] = nil
                else
                    espTargetSet[name] = true
                end
                allExplicit = false
                check.Text = espTargetSet[name] and "✓" or ""
                refreshLabel()
                if onChanged then onChanged() end
            end))
        end
    end

    local function openList()
        list.Position = UDim2.new(
            0, btn.AbsolutePosition.X - 4,
            0, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y + 6
        )
        local maxH = 280
        local totalH = (#getOptions() + 1) * 34 + 12
        list.Size = UDim2.new(0, btn.AbsoluteSize.X + 8, 0, math.min(totalH, maxH))
        scroller.CanvasSize = UDim2.new(0, 0, 0, totalH)
        scroller.CanvasPosition = Vector2.new(0, 0)
        rebuildRows()
        isOpen = true
        list.Visible = true

        list.BackgroundTransparency = 0.3
        TweenService:Create(list, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_ACTIVE}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.15), {Color = ACCENT, Transparency = 0.2}):Play()
    end

    local self = {
        refreshLabel = refreshLabel,
        close = closeList,
        isOpen = function() return isOpen end,
        reset = function()
            espTargetSet = {}
            allExplicit = false
            refreshLabel()
        end,
        _list = list,
        _btn = btn,
        _scroller = scroller,
    }
    registerOpenDropdown(self)

    addConn(btn.MouseButton1Click:Connect(function()
        for _, dd in ipairs(openDropdowns) do
            if dd ~= self then pcall(function() dd.close() end) end
        end
        if isOpen then
            closeList()
        else
            openList()
            markIgnoreNextClicks(0.1)
        end
    end))

    addConn(btn.MouseEnter:Connect(function()
        if not isOpen then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_HOVER}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.15), {Transparency = 0.1}):Play()
        end
    end))
    addConn(btn.MouseLeave:Connect(function()
        if not isOpen then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_COLOR}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.15), {Transparency = 0.3}):Play()
        end
    end))

    return self
end

-- GLOBAL INPUT
local function handleGlobalClick(mx, my)
    if tick() < ignoreGlobalClickUntil then return end

    for _, dd in ipairs(openDropdowns) do
        if dd.isOpen and dd.isOpen() then
            local lst = dd._list
            local b = dd._btn
            local lp = lst.AbsolutePosition
            local ls = lst.AbsoluteSize
            local bp = b.AbsolutePosition
            local bs = b.AbsoluteSize
            local insideList = mx >= lp.X and mx <= lp.X + ls.X and my >= lp.Y and my <= lp.Y + ls.Y
            local insideBtn  = mx >= bp.X and mx <= bp.X + bs.X and my >= bp.Y and my <= bp.Y + bs.Y
            if not insideList and not insideBtn then
                pcall(function() dd.close() end)
            end
        end
    end
end

addConn(UserInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    local mouse = UserInputService:GetMouseLocation()
    handleGlobalClick(mouse.X, mouse.Y)
end))

addConn(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    local mouse = UserInputService:GetMouseLocation()
    handleGlobalClick(mouse.X, mouse.Y)
end))

local prevLMBDown = false
addConn(RunService.RenderStepped:Connect(function()
    if not menuOpen then return end
    local lmb = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    if lmb and not prevLMBDown then
        local mouse = UserInputService:GetMouseLocation()
        handleGlobalClick(mouse.X, mouse.Y)
    end
    prevLMBDown = lmb
end))

addConn(UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
    local mouse = UserInputService:GetMouseLocation()
    for _, dd in ipairs(openDropdowns) do
        if dd.isOpen and dd.isOpen() and dd._scroller then
            local lst = dd._list
            local lp = lst.AbsolutePosition
            local ls = lst.AbsoluteSize
            if mouse.X >= lp.X and mouse.X <= lp.X + ls.X
            and mouse.Y >= lp.Y and mouse.Y <= lp.Y + ls.Y then
                local sc = dd._scroller
                local newY = sc.CanvasPosition.Y - input.Position.Z * 30
                local maxY = math.max(0, sc.AbsoluteCanvasSize.Y - sc.AbsoluteSize.Y)
                sc.CanvasPosition = Vector2.new(0, math.clamp(newY, 0, maxY))
            end
        end
    end
end))

-- THEME BUTTON
local function addThemeButton(parent, themeName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = BTN_COLOR
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.ZIndex = 3
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = btn

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(0, 14, 0.5, -7)
    dot.BackgroundColor3 = THEMES[themeName].main
    dot.BorderSizePixel = 0
    dot.ZIndex = 3
    dot.Parent = btn

    local dotC = Instance.new("UICorner")
    dotC.CornerRadius = UDim.new(1, 0)
    dotC.Parent = dot

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 38, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = themeName
    lbl.TextColor3 = TEXT_COLOR
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = btn

    local check = Instance.new("TextLabel")
    check.Size = UDim2.new(0, 20, 1, 0)
    check.Position = UDim2.new(1, -30, 0, 0)
    check.BackgroundTransparency = 1
    check.Text = ""
    check.TextColor3 = ACCENT
    check.Font = Enum.Font.GothamBold
    check.TextSize = 14
    check.TextXAlignment = Enum.TextXAlignment.Right
    check.ZIndex = 3
    check.Parent = btn
    registerTheme(check, "TextColor3", "accent")

    themeButtons[themeName] = {btn = btn, check = check, label = lbl, dot = dot}

    attachRipple(btn)

    addConn(btn.MouseEnter:Connect(function()
        if currentTheme ~= themeName then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_HOVER, BackgroundTransparency = 0}):Play()
        end
    end))
    addConn(btn.MouseLeave:Connect(function()
        if currentTheme ~= themeName then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_COLOR, BackgroundTransparency = 0.3}):Play()
        end
    end))

    addConn(btn.MouseButton1Click:Connect(function()
        if applyTheme then applyTheme(themeName) end
        showToast("Theme: " .. themeName, "Applied")
    end))

    return btn
end

-- KEYBIND
local function addKeybind(parent, labelText, defaultKey, onChanged)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = BTN_COLOR
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.ZIndex = 3
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -110, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = TEXT_COLOR
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = btn

    local keyBox = Instance.new("TextLabel")
    keyBox.Size = UDim2.new(0, 80, 0, 24)
    keyBox.Position = UDim2.new(1, -92, 0.5, -12)
    keyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    keyBox.BorderSizePixel = 0
    keyBox.Text = defaultKey.Name
    keyBox.TextColor3 = TEXT_COLOR
    keyBox.Font = Enum.Font.GothamBold
    keyBox.TextSize = 12
    keyBox.ZIndex = 4
    keyBox.Parent = btn

    local kbCorner = Instance.new("UICorner")
    kbCorner.CornerRadius = UDim.new(0, 6)
    kbCorner.Parent = keyBox

    local listening = false
    local currentKey = defaultKey

    addConn(UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not listening then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        currentKey = input.KeyCode
        onChanged(currentKey)
        listening = false
        keyBox.Text = currentKey.Name
        keyBox.TextColor3 = TEXT_COLOR
        showToast("Keybind: " .. currentKey.Name, labelText)
    end))

    attachRipple(btn)

    addConn(btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_HOVER, BackgroundTransparency = 0}):Play()
    end))
    addConn(btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_COLOR, BackgroundTransparency = 0.3}):Play()
    end))

    addConn(btn.MouseButton1Click:Connect(function()
        if listening then
            listening = false
            keyBox.Text = currentKey.Name
            keyBox.TextColor3 = TEXT_COLOR
        else
            listening = true
            keyBox.Text = "..."
            keyBox.TextColor3 = ACCENT
        end
    end))

    return btn
end

local function addActionButton(parent, text, iconEmoji, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = BTN_COLOR
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.ZIndex = 3
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = btn

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 22, 1, 0)
    icon.Position = UDim2.new(0, 12, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = iconEmoji or ""
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 13
    icon.TextColor3 = TEXT_COLOR
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.ZIndex = 3
    icon.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 38, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = TEXT_COLOR
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = btn

    attachRipple(btn)

    addConn(btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_HOVER, BackgroundTransparency = 0}):Play()
    end))
    addConn(btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_COLOR, BackgroundTransparency = 0.3}):Play()
    end))

    addConn(btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end))

    return btn
end

local function addResetOption(parent, text)
    local state = false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = BTN_COLOR
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.ZIndex = 3
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = btn

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 18, 0, 18)
    box.Position = UDim2.new(0, 14, 0.5, -9)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    box.BorderSizePixel = 0
    box.ZIndex = 3
    box.Parent = btn

    local boxC = Instance.new("UICorner")
    boxC.CornerRadius = UDim.new(0, 5)
    boxC.Parent = box

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(70, 70, 90)
    boxStroke.Thickness = 1
    boxStroke.Parent = box

    local check = Instance.new("TextLabel")
    check.Size = UDim2.new(1, 0, 1, 0)
    check.BackgroundTransparency = 1
    check.Text = ""
    check.TextColor3 = Color3.fromRGB(255, 255, 255)
    check.Font = Enum.Font.GothamBold
    check.TextSize = 12
    check.ZIndex = 4
    check.Parent = box

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 42, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = TEXT_COLOR
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = btn

    local function setState(newState)
        state = newState
        if state then
            box.BackgroundColor3 = ACCENT
            boxStroke.Color = ACCENT
            check.Text = "✓"
        else
            box.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
            boxStroke.Color = Color3.fromRGB(70, 70, 90)
            check.Text = ""
        end
    end

    addConn(btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_HOVER, BackgroundTransparency = 0}):Play()
    end))
    addConn(btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = BTN_COLOR, BackgroundTransparency = 0.3}):Play()
    end))

    addConn(btn.MouseButton1Click:Connect(function()
        setState(not state)
    end))

    return {
        button = btn,
        setState = setState,
        isOn = function() return state end,
    }
end

-- ESP SYSTEM
local espEnabled       = false
local espShowName      = true
local espShowDistance  = false
local espShowAvatar    = true
local espOutlineWidth  = 1.5
local espFillAlpha     = 0.55
local espChams         = true

local avatarCache = {}

local function fetchAvatar(player)
    if avatarCache[player.UserId] then return avatarCache[player.UserId] end
    local ok, url = pcall(function()
        return Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end)
    if ok and url then
        avatarCache[player.UserId] = url
        return url
    end
    return nil
end

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
        hl.FillTransparency = espChams and espFillAlpha or 1
        hl.OutlineColor = col
        hl.OutlineTransparency = 0
    end)

    local nameLbl = tag:FindFirstChild("NameLbl")
    if nameLbl then
        nameLbl.TextColor3 = col
        nameLbl.Visible = espShowName
    end

    local distLbl = tag:FindFirstChild("DistLbl")
    if distLbl then
        distLbl.Visible = espShowDistance
    end

    local avLbl = tag:FindFirstChild("AvatarLbl")
    if avLbl then
        avLbl.Visible = espShowAvatar
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
    hl.FillTransparency = espChams and espFillAlpha or 1
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
    avatarLabel.Visible = espShowAvatar
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
    nameLabel.Visible = espShowName
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
    distLabel.Visible = espShowDistance
    distLabel.Parent = tag

    if not avatarCache[player.UserId] then
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
    if espEnabled then
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

local function setESPState(state)
    espEnabled = state
    if state then refreshAllESP() else clearAllESP() end
end

local function bindPlayer(player)
    if player == LocalPlayer then return end

    addConn(player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled and isTargeted(player.Name) then
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

addConn(Players.PlayerAdded:Connect(function(player)
    bindPlayer(player)
end))

addConn(Players.PlayerRemoving:Connect(function(player)
    removeESPForPlayer(player)
    espTargetSet[player.Name] = nil
end))

task.spawn(function()
    while true do
        task.wait(0.15)
        if espEnabled then
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

-- BUILD TABS
local visualsTab  = createTab("Visuals",  "📷")
local espTab      = createTab("ESP",      "👁")
local funTab      = createTab("Fun",      "🎮")
local settingsTab = createTab("Настройки", "⚙")

-- CAMERA
addLabel(visualsTab, "Camera", "Adjust how much you see on screen")
addSlider(visualsTab, "Field of View", MIN_FOV, MAX_FOV, Camera.FieldOfView, "", function(v)
    Camera.FieldOfView = v
end, function(setter, default) fovResetCallback = function() setter(default) end end)

-- LIGHTING
addLabel(visualsTab, "Lighting", "Visual tweaks for clarity")

local fullbrightToggle = addToggle(visualsTab, "Fullbright", "💡", false, function(state)
    if state then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(140, 140, 140)
        Lighting.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
    else
        Lighting.Brightness = ORIGINAL_LIGHTING.Brightness
        Lighting.ClockTime = ORIGINAL_LIGHTING.ClockTime
        Lighting.Ambient = ORIGINAL_LIGHTING.Ambient
        Lighting.OutdoorAmbient = ORIGINAL_LIGHTING.OutdoorAmbient
    end
end)

local noShadowsToggle = addToggle(visualsTab, "No Shadows", "☀", false, function(state)
    if state then
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = ORIGINAL_LIGHTING.GlobalShadows
    end
end)

-- WORLD TIME
addLabel(visualsTab, "World", "Change time of day")
addSlider(visualsTab, "Time (hours)", MIN_TIME, MAX_TIME, Lighting.ClockTime, "h", function(v)
    Lighting.ClockTime = v
end, function(setter, default)
    timeResetCallback = function() setter(ORIGINAL_LIGHTING.ClockTime) end
end)

-- SKYBOX
addLabel(visualsTab, "Skybox", "27 skyboxes available")

local skyboxNames = {}
for name, _ in pairs(SKYBOX_ASSETS) do
    table.insert(skyboxNames, name)
end
table.sort(skyboxNames)

local skyboxOptions = {}
for _, name in ipairs(skyboxNames) do
    table.insert(skyboxOptions, {name = name})
end

local defaultSkyboxIdx = 1
for i, opt in ipairs(skyboxOptions) do
    if opt.name == "HD" then defaultSkyboxIdx = i break end
end

skyboxDropdownRef = addDropdown(visualsTab, "Select Skybox", skyboxOptions, defaultSkyboxIdx, function(option)
    applySkybox(option.name)
    showToast("Skybox: " .. option.name, "Applied")
end, {showIcon = true, iconEmoji = "🌌"})

addActionButton(visualsTab, "Restore Default Sky", "↩", function()
    restoreDefaultSky()
    showToast("Skybox restored", "Original FTAP sky")
end)

addActionButton(visualsTab, "Random Skybox", "🎲", function()
    local randomName = skyboxNames[math.random(1, #skyboxNames)]
    applySkybox(randomName)
    if skyboxDropdownRef then
        for i, opt in ipairs(skyboxOptions) do
            if opt.name == randomName then
                skyboxDropdownRef.setIndex(i)
                break
            end
        end
    end
    showToast("Random Skybox", randomName)
end)

-- ESP TAB
addLabel(espTab, "Players", "See players through walls")

local espMainToggle = addToggle(espTab, "Player ESP", "👁", false, function(state)
    setESPState(state)
end)

local colorOptions = {}
for _, e in ipairs(ESP_COLORS) do
    table.insert(colorOptions, {name = e.name})
end

local colorDropdown = addDropdown(espTab, "ESP Color", colorOptions, 1, function(option, idx)
    espColorChoice = idx
    reapplyESPVisuals()
end, {showIcon = true, iconEmoji = "🎨"})

local targetDropdown = addMultiSelectDropdown(
    espTab,
    "Target Players (multi-select)",
    function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(names, p.Name)
            end
        end
        table.sort(names)
        return names
    end,
    function()
        refreshAllESP()
    end
)

local espNameToggle = addToggle(espTab, "Show Name", "🏷", true, function(state)
    espShowName = state
    reapplyESPVisuals()
end)

local espDistToggle = addToggle(espTab, "Show Distance", "📏", false, function(state)
    espShowDistance = state
    reapplyESPVisuals()
end)

local espAvatarToggle = addToggle(espTab, "Show Avatar", "🧑", true, function(state)
    espShowAvatar = state
    reapplyESPVisuals()
end)

local espChamsToggle = addToggle(espTab, "Chams (fill)", "🎨", true, function(state)
    espChams = state
    reapplyESPVisuals()
end)

local espOutlineSlider = addSlider(espTab, "Outline Thickness", 0, 3, 2, "px", function(v)
    espOutlineWidth = v
    reapplyESPVisuals()
end)

local espFillSlider = addSlider(espTab, "Fill Transparency", 0, 100, math.floor(espFillAlpha * 100), "%", function(v)
    espFillAlpha = v / 100
    reapplyESPVisuals()
end)

-- FUN TAB
local anchoredToggle = addToggle(funTab, "Anchored", "🧊", true, function(state)
    anchoredEnabled = state
    if not state then releaseAllAnchored() end
end)

addKeybind(funTab, "Anchored Key", anchoredKey, function(newKey)
    anchoredKey = newKey
end)

addActionButton(funTab, "Release All", "📤", function()
    releaseAllAnchored()
    showToast("Anchored", "All released")
end)

-- SETTINGS TAB
addLabel(settingsTab, "Keybind", "Click the box, then press a key")
addKeybind(settingsTab, "Toggle menu", toggleKey, function(newKey)
    toggleKey = newKey
end)

addLabel(settingsTab, "Interface", "Extra widgets for the hub")
addToggle(settingsTab, "Show FPS", "📊", false, function(state)
    FpsLabel.Visible = state
end)

local function doResetVisuals()
    if fovResetCallback then fovResetCallback() end
    if timeResetCallback then timeResetCallback() end
    pcall(function()
        Lighting.Brightness     = ORIGINAL_LIGHTING.Brightness
        Lighting.ClockTime      = ORIGINAL_LIGHTING.ClockTime
        Lighting.FogEnd         = ORIGINAL_LIGHTING.FogEnd
        Lighting.FogStart       = ORIGINAL_LIGHTING.FogStart
        Lighting.GlobalShadows  = ORIGINAL_LIGHTING.GlobalShadows
        Lighting.Ambient        = ORIGINAL_LIGHTING.Ambient
        Lighting.OutdoorAmbient = ORIGINAL_LIGHTING.OutdoorAmbient
    end)
    if fullbrightToggle and fullbrightToggle.isOn() then fullbrightToggle.setState(false, false) end
    if noShadowsToggle and noShadowsToggle.isOn() then noShadowsToggle.setState(false, false) end
    restoreDefaultSky()
end

local function doResetESP()
    espColorChoice   = 1
    espTargetSet     = {}
    allExplicit      = false
    espShowName      = true
    espShowDistance  = false
    espShowAvatar    = true
    espOutlineWidth  = 1.5
    espFillAlpha     = 0.55
    espChams         = true

    pcall(function() colorDropdown.setIndex(1) end)
    pcall(function() targetDropdown.reset() end)
    pcall(function() espNameToggle.setState(true, false) end)
    pcall(function() espDistToggle.setState(false, false) end)
    pcall(function() espAvatarToggle.setState(true, false) end)
    pcall(function() espChamsToggle.setState(true, false) end)
    pcall(function() espOutlineSlider.setValue(2) end)
    pcall(function() espFillSlider.setValue(math.floor(0.55 * 100)) end)

    reapplyESPVisuals()
    refreshAllESP()
end

local function doResetTheme()
    applyTheme("Blue")
end

addLabel(settingsTab, "Reset Options", "Check what to reset, then click Apply")

local resetVis   = addResetOption(settingsTab, "Reset Visuals (FOV + Lighting + Sky)")
local resetESP   = addResetOption(settingsTab, "Reset ESP")
local resetTheme = addResetOption(settingsTab, "Reset Theme (Blue)")

resetVis.setState(true)
resetESP.setState(true)
resetTheme.setState(false)

addActionButton(settingsTab, "Apply Selected Resets", "♻", function()
    if resetVis.isOn()   then doResetVisuals() end
    if resetESP.isOn()   then doResetESP() end
    if resetTheme.isOn() then doResetTheme() end
    showToast("Resets Applied", "")
end)

addLabel(settingsTab, "Theme", "Pick a color for the hub")
for _, name in ipairs({"Blue", "Purple", "Pink", "Red", "Green"}) do
    addThemeButton(settingsTab, name)
end

addLabel(settingsTab, "Rofl Hub " .. HUB_VERSION, "Made for FTAP")

activeTabName = "Visuals"
for _, data in ipairs(tabButtons) do
    if data.name == "Visuals" then
        data.button.BackgroundColor3 = BTN_ACTIVE
        data.button.BackgroundTransparency = 0
        data.label.TextColor3 = ACCENT
        data.icon.TextColor3 = ACCENT
        data.leftBar.BackgroundTransparency = 0
        data.stroke.Transparency = 0.7
    else
        data.button.BackgroundColor3 = BTN_COLOR
        data.button.BackgroundTransparency = 0.5
        data.label.TextColor3 = TEXT_COLOR
        data.icon.TextColor3 = TEXT_COLOR
        data.leftBar.BackgroundTransparency = 1
        data.stroke.Transparency = 1
    end
end
sections["Visuals"].Visible = true

-- THEME
local function refreshActiveTabsAnimated()
    for _, data in ipairs(tabButtons) do
        if data.name == activeTabName then
            TweenService:Create(data.button, THEME_TWEEN_INFO, {BackgroundColor3 = BTN_ACTIVE, BackgroundTransparency = 0}):Play()
            data.label.TextColor3 = ACCENT
            data.icon.TextColor3 = ACCENT
            TweenService:Create(data.leftBar, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(data.stroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play()
        else
            TweenService:Create(data.button, THEME_TWEEN_INFO, {BackgroundColor3 = BTN_COLOR, BackgroundTransparency = 0.5}):Play()
            data.label.TextColor3 = TEXT_COLOR
            data.icon.TextColor3 = TEXT_COLOR
            TweenService:Create(data.leftBar, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(data.stroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
        end
    end
end

local function refreshThemeButtonsAnimated()
    for name, data in pairs(themeButtons) do
        if name == currentTheme then
            TweenService:Create(data.btn, THEME_TWEEN_INFO, {BackgroundColor3 = BTN_ACTIVE, BackgroundTransparency = 0}):Play()
            TweenService:Create(data.check, THEME_TWEEN_INFO, {TextColor3 = THEMES[name].main}):Play()
            data.check.Text = "✓"
        else
            TweenService:Create(data.btn, THEME_TWEEN_INFO, {BackgroundColor3 = BTN_COLOR, BackgroundTransparency = 0.3}):Play()
            data.check.Text = ""
        end
    end
end

applyTheme = function(themeName)
    if not THEMES[themeName] then return end
    currentTheme = themeName
    ACCENT      = THEMES[themeName].main
    ACCENT_DARK = THEMES[themeName].dark

    for _, entry in ipairs(themeTargets) do
        pcall(function()
            local obj = entry.obj
            if not obj or not obj.Parent then return end

            if entry.kind == "accent" then
                TweenService:Create(obj, THEME_TWEEN_INFO, {[entry.property] = ACCENT}):Play()
            elseif entry.kind == "accentDark" then
                TweenService:Create(obj, THEME_TWEEN_INFO, {[entry.property] = ACCENT_DARK}):Play()
            elseif entry.kind == "gradient" then
                task.spawn(function()
                    local from = obj[entry.property]
                    local t0 = tick()
                    local dur = THEME_TWEEN_TIME
                    while tick() - t0 < dur do
                        local a = (tick() - t0) / dur
                        local c1 = from.Keypoints[1].Value:Lerp(ACCENT_DARK, a)
                        local c2 = from.Keypoints[2].Value:Lerp(ACCENT, a)
                        obj[entry.property] = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, c1),
                            ColorSequenceKeypoint.new(1, c2),
                        })
                        RunService.RenderStepped:Wait()
                    end
                    obj[entry.property] = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, ACCENT_DARK),
                        ColorSequenceKeypoint.new(1, ACCENT),
                    })
                end)
            elseif entry.kind == "accentOnWhen" then
                if entry.isOn and entry.isOn() then
                    TweenService:Create(obj, THEME_TWEEN_INFO, {[entry.property] = ACCENT}):Play()
                end
            end
        end)
    end

    refreshActiveTabsAnimated()
    refreshThemeButtonsAnimated()
    reapplyESPVisuals()
end

refreshActiveTabsAnimated()
refreshThemeButtonsAnimated()

-- RUNTIME STATE
local menuOpen       = true
local savedRotation  = nil
local camLoopBound   = false
local transitioning  = false

local FULL_SIZE  = UDim2.new(0, 580, 0, 400)
local BOUNCE_SIZE = UDim2.new(0, 605, 0, 420)
local SMALL_SIZE = UDim2.new(0, 540, 0, 370)
local MINI_SIZE  = UDim2.new(0, 280, 0, 52)

local CAM_LOCK_NAME = "RoflHubCamRotLock"

local function startCamFreeze()
    if camLoopBound then return end
    camLoopBound = true
    savedRotation = Camera.CFrame - Camera.CFrame.Position
    RunService:BindToRenderStep(CAM_LOCK_NAME, Enum.RenderPriority.Camera.Value + 1, function()
        if not menuOpen then return end
        if workspace.CurrentCamera ~= Camera then
            Camera = workspace.CurrentCamera
            savedRotation = Camera.CFrame - Camera.CFrame.Position
        end
        Camera.CFrame = CFrame.new(Camera.CFrame.Position) * savedRotation
    end)
end

local function stopCamFreeze()
    if not camLoopBound then return end
    camLoopBound = false
    pcall(function() RunService:UnbindFromRenderStep(CAM_LOCK_NAME) end)
end

local OPEN_TWEEN_1 = TweenInfo.new(0.20, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local OPEN_TWEEN_2 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local CLOSE_TWEEN  = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

local function animateOpen()
    Window.Visible = true
    Window.Size = SMALL_SIZE
    Window.BackgroundTransparency = 0.4
    TweenService:Create(Window, OPEN_TWEEN_1, { Size = BOUNCE_SIZE, BackgroundTransparency = 0 }):Play()
    task.delay(0.20, function()
        if not menuOpen then return end
        TweenService:Create(Window, OPEN_TWEEN_2, { Size = FULL_SIZE }):Play()
    end)
end

local function animateClose(callback)
    TweenService:Create(Window, CLOSE_TWEEN, { Size = SMALL_SIZE }):Play()
    task.delay(0.24, function()
        Window.Visible = false
        if callback then callback() end
    end)
end

local function openMenu()
    if menuOpen then return end
    if transitioning then return end
    transitioning = true

    menuOpen = true
    ScreenGui.Enabled = true

    ModalBtn.Visible = true
    ModalBtn.Modal = true

    pcall(function() UserInputService.MouseIconEnabled = true end)

    task.delay(0.05, function()
        if menuOpen then
            pcall(function() UserInputService.MouseIconEnabled = true end)
        end
    end)

    setBlur(24)
    startCamFreeze()
    animateOpen()

    task.delay(0.3, function() transitioning = false end)
end

local function closeMenu()
    if not menuOpen then return end
    if transitioning then return end
    transitioning = true

    menuOpen = false
    stopCamFreeze()
    setBlur(0)

    ModalBtn.Modal = false
    ModalBtn.Visible = false

    pcall(function() UserInputService.MouseIconEnabled = false end)

    animateClose(function() ScreenGui.Enabled = false end)

    task.delay(0.3, function() transitioning = false end)
end

addConn(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == toggleKey then
        if menuOpen then closeMenu() else openMenu() end
    end
end))

local minimized = false
local restoreSize = FULL_SIZE

addConn(MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        restoreSize = Window.Size
        for _, obj in ipairs(Window:GetChildren()) do
            if obj ~= TitleBar and obj ~= WindowCorner and obj ~= WindowStroke
            and obj ~= WindowGradient and obj ~= TopAccent
            and not table.find(dragStrips, obj) then
                obj.Visible = false
            end
        end
        for _, strip in ipairs(dragStrips) do
            if strip.Name ~= "TopEdge" and strip.Name ~= "TopRight" and strip.Name ~= "TopLeft" then
                strip.Visible = false
            end
        end
        TweenService:Create(Window, TweenInfo.new(0.2), { Size = MINI_SIZE }):Play()
        MinBtn.Text = "+"
    else
        TweenService:Create(Window, TweenInfo.new(0.2), { Size = restoreSize }):Play()
        task.wait(0.05)
        for _, obj in ipairs(Window:GetChildren()) do
            if obj ~= TitleBar and obj ~= WindowCorner and obj ~= WindowStroke
            and obj ~= WindowGradient and obj ~= TopAccent
            and not table.find(dragStrips, obj) then
                obj.Visible = true
            end
        end
        for _, strip in ipairs(dragStrips) do
            strip.Visible = true
        end
        MinBtn.Text = "—"
    end
end))

local function unloadAll()
    menuOpen = false
    stopCamFreeze()

    clearAllESP()
    espEnabled = false

    releaseAllAnchored()

    pcall(function() Camera.FieldOfView = ORIGINAL_FOV end)

    pcall(function()
        ModalBtn.Modal = false
        ModalBtn:Destroy()
    end)

    pcall(function()
        UserInputService.MouseIconEnabled = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end)

    pcall(function()
        Lighting.Brightness     = ORIGINAL_LIGHTING.Brightness
        Lighting.ClockTime      = ORIGINAL_LIGHTING.ClockTime
        Lighting.FogEnd         = ORIGINAL_LIGHTING.FogEnd
        Lighting.FogStart       = ORIGINAL_LIGHTING.FogStart
        Lighting.GlobalShadows  = ORIGINAL_LIGHTING.GlobalShadows
        Lighting.Ambient        = ORIGINAL_LIGHTING.Ambient
        Lighting.OutdoorAmbient = ORIGINAL_LIGHTING.OutdoorAmbient
    end)

    restoreDefaultSky()

    pcall(function() Blur:Destroy() end)

    for _, c in ipairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    connections = {}

    pcall(function() ScreenGui:Destroy() end)
end

addConn(CloseBtn.MouseButton1Click:Connect(function()
    clearAllESP()
    espEnabled = false
    if espMainToggle and espMainToggle.setState then
        espMainToggle.setState(false, false)
    end

    closeMenu()
    task.delay(0.3, unloadAll)
end))

openMenu()

log("Script finished OK")

end)

if not ok then
    notify("ОШИБКА Rofl Hub", tostring(err), 30)
    warn("[Rofl Hub ERROR] " .. tostring(err))
end
