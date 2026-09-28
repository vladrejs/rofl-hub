-- Rofl Hub | settings.lua
-- Сборка вкладок, кейбинды, темы, ресеты

local Hub = _G.RoflHub or {}
_G.RoflHub = Hub

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local UI = Hub.UI
local A  = Hub.Anchored
local V  = Hub.Visuals
local E  = Hub.ESP

local Colors = Hub.Colors
local Themes = Hub.Themes

-- Меню состояние
Hub.Menu = Hub.Menu or {}
local M = Hub.Menu
M.ToggleKey = Enum.KeyCode.M
M.Open = true
M.Minimized = false

local ScreenGui = UI.ScreenGui
local Window    = UI.Window
local MinBtn    = UI.MinBtn
local CloseBtn  = UI.CloseBtn
local ModalBtn  = UI.ModalBtn
local Scroll    = UI.Scroll

local CAM_LOCK_NAME = "RoflHubCamRotLock"
local camLoopBound = false
local savedRotation = nil

local FULL_SIZE   = UDim2.new(0, 580, 0, 400)
local BOUNCE_SIZE = UDim2.new(0, 605, 0, 420)
local SMALL_SIZE  = UDim2.new(0, 540, 0, 370)
local MINI_SIZE   = UDim2.new(0, 280, 0, 52)

local function addConn(c) return Hub.addConn(c) end

-- Camera freeze
local function startCamFreeze()
    if camLoopBound then return end
    camLoopBound = true
    savedRotation = UI.Camera.CFrame - UI.Camera.CFrame.Position
    RunService:BindToRenderStep(CAM_LOCK_NAME, Enum.RenderPriority.Camera.Value + 1, function()
        if not M.Open then return end
        if workspace.CurrentCamera ~= UI.Camera then
            UI.Camera = workspace.CurrentCamera
            savedRotation = UI.Camera.CFrame - UI.Camera.CFrame.Position
        end
        UI.Camera.CFrame = CFrame.new(UI.Camera.CFrame.Position) * savedRotation
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
        if not M.Open then return end
        TweenService:Create(Window, OPEN_TWEEN_2, { Size = FULL_SIZE }):Play()
    end)
end

local function animateClose(cb)
    TweenService:Create(Window, CLOSE_TWEEN, { Size = SMALL_SIZE }):Play()
    task.delay(0.24, function()
        Window.Visible = false
        if cb then cb() end
    end)
end

local transitioning = false

local function openMenu()
    if M.Open then return end
    if transitioning then return end
    transitioning = true
    M.Open = true
    ScreenGui.Enabled = true
    ModalBtn.Visible = true
    ModalBtn.Modal = true
    pcall(function() UserInputService.MouseIconEnabled = true end)
    UI.setBlur(24)
    startCamFreeze()
    animateOpen()
    task.delay(0.3, function() transitioning = false end)
end

local function closeMenu()
    if not M.Open then return end
    if transitioning then return end
    transitioning = true
    M.Open = false
    stopCamFreeze()
    UI.setBlur(0)
    ModalBtn.Modal = false
    ModalBtn.Visible = false
    pcall(function() UserInputService.MouseIconEnabled = false end)
    animateClose(function() ScreenGui.Enabled = false end)
    task.delay(0.3, function() transitioning = false end)
end

M.openMenu = openMenu
M.closeMenu = closeMenu

addConn(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == M.ToggleKey then
        if M.Open then closeMenu() else openMenu() end
    end
end))

-- Minimize
addConn(MinBtn.MouseButton1Click:Connect(function()
    M.Minimized = not M.Minimized
    if M.Minimized then
        M.RestoreSize = Window.Size
        for _, obj in ipairs(Window:GetChildren()) do
            if obj ~= UI.Window:FindFirstChild("TitleBar") and obj ~= UI.AccentLine
            and not table.find(UI.dragStrips, obj)
            and obj.ClassName ~= "UICorner" and obj.ClassName ~= "UIStroke"
            and obj.ClassName ~= "UIGradient" then
                obj.Visible = false
            end
        end
        for _, strip in ipairs(UI.dragStrips) do
            if strip.Name ~= "TopEdge" and strip.Name ~= "TopRight" and strip.Name ~= "TopLeft" then
                strip.Visible = false
            end
        end
        TweenService:Create(Window, TweenInfo.new(0.2), { Size = MINI_SIZE }):Play()
        MinBtn.Text = "+"
    else
        TweenService:Create(Window, TweenInfo.new(0.2), { Size = M.RestoreSize or FULL_SIZE }):Play()
        task.wait(0.05)
        for _, obj in ipairs(Window:GetChildren()) do
            if obj ~= UI.Window:FindFirstChild("TitleBar") and obj ~= UI.AccentLine
            and not table.find(UI.dragStrips, obj)
            and obj.ClassName ~= "UICorner" and obj.ClassName ~= "UIStroke"
            and obj.ClassName ~= "UIGradient" then
                obj.Visible = true
            end
        end
        for _, strip in ipairs(UI.dragStrips) do
            strip.Visible = true
        end
        MinBtn.Text = "—"
    end
end))

-- Unload
local function unloadAll()
    M.Open = false
    stopCamFreeze()
    A.releaseAll()
    E.setEnabled(false)
    pcall(function() UI.Camera.FieldOfView = V.OriginalFOV end)
    pcall(function()
        ModalBtn.Modal = false
        ModalBtn:Destroy()
    end)
    pcall(function()
        UserInputService.MouseIconEnabled = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end)
    pcall(function()
        local L = V.OriginalLighting
        local lighting = game:GetService("Lighting")
        lighting.Brightness = L.Brightness
        lighting.ClockTime = L.ClockTime
        lighting.FogEnd = L.FogEnd
        lighting.FogStart = L.FogStart
        lighting.GlobalShadows = L.GlobalShadows
        lighting.Ambient = L.Ambient
        lighting.OutdoorAmbient = L.OutdoorAmbient
    end)
    pcall(V.restoreDefaultSky)
    pcall(function() UI.Blur:Destroy() end)
    for _, c in ipairs(Hub.State.connections) do
        pcall(function() c:Disconnect() end)
    end
    Hub.State.connections = {}
    pcall(function() ScreenGui:Destroy() end)
end

addConn(CloseBtn.MouseButton1Click:Connect(function()
    closeMenu()
    task.delay(0.3, unloadAll)
end))

-- ===================== BUILD TABS =====================

local visualsTab  = UI.createTab("Visuals",  "📷")
local espTab      = UI.createTab("ESP",      "👁")
local funTab      = UI.createTab("Fun",      "🎮")
local settingsTab = UI.createTab("Settings", "⚙")

-- ===================== VISUALS TAB =====================
UI.addLabel(visualsTab, "Camera", "Adjust how much you see on screen")

UI.addSlider(visualsTab, "Field of View", 1, 120, UI.Camera.FieldOfView, "", function(v)
    UI.Camera.FieldOfView = v
end)

UI.addLabel(visualsTab, "Lighting", "Visual tweaks for clarity")

UI.addToggle(visualsTab, "Fullbright", "💡", false, function(state)
    local L = game:GetService("Lighting")
    if state then
        L.Brightness = 3
        L.ClockTime = 14
        L.Ambient = Color3.fromRGB(140, 140, 140)
        L.OutdoorAmbient = Color3.fromRGB(140, 140, 140)
    else
        L.Brightness = V.OriginalLighting.Brightness
        L.ClockTime = V.OriginalLighting.ClockTime
        L.Ambient = V.OriginalLighting.Ambient
        L.OutdoorAmbient = V.OriginalLighting.OutdoorAmbient
    end
end)

UI.addToggle(visualsTab, "No Shadows", "☀", false, function(state)
    local L = game:GetService("Lighting")
    if state then
        L.GlobalShadows = false
    else
        L.GlobalShadows = V.OriginalLighting.GlobalShadows
    end
end)

UI.addLabel(visualsTab, "World", "Change time of day")

UI.addSlider(visualsTab, "Time (hours)", 0, 24, game:GetService("Lighting").ClockTime, "h", function(v)
    game:GetService("Lighting").ClockTime = v
end)

-- Skybox
UI.addLabel(visualsTab, "Skybox", "27 skyboxes available")

local skyboxNames = {}
for name, _ in pairs(Hub.SkyboxAssets) do
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

-- Заглушка для dropdown (в этой версии ui.lua его нет, используем простой list из 27 кнопок)
for _, name in ipairs(skyboxNames) do
    UI.addActionButton(visualsTab, name, "🌌", function()
        V.applySkybox(name)
        Hub.showToast("Skybox: " .. name, "Applied")
    end)
end

UI.addActionButton(visualsTab, "Restore Default Sky", "↩", function()
    V.restoreDefaultSky()
    Hub.showToast("Skybox restored", "Original FTAP sky")
end)

UI.addActionButton(visualsTab, "Random Skybox", "🎲", function()
    local rn = skyboxNames[math.random(1, #skyboxNames)]
    V.applySkybox(rn)
    Hub.showToast("Random Skybox", rn)
end)

-- ===================== ESP TAB =====================
UI.addLabel(espTab, "Players", "See players through walls")

UI.addToggle(espTab, "Player ESP", "👁", false, function(state)
    E.setEnabled(state)
end)

UI.addLabel(espTab, "ESP Color", "Choose a color")

for i, e in ipairs(Hub.EspColors) do
    UI.addActionButton(espTab, e.name, "🎨", function()
        E.setColor(i)
        Hub.showToast("ESP Color: " .. e.name, "")
    end)
end

UI.addLabel(espTab, "Options", "Toggle visibility")

UI.addToggle(espTab, "Show Name", "🏷", true, function(state)
    E.setState("ShowName", state)
end)

UI.addToggle(espTab, "Show Distance", "📏", false, function(state)
    E.setState("ShowDistance", state)
end)

UI.addToggle(espTab, "Show Avatar", "🧑", true, function(state)
    E.setState("ShowAvatar", state)
end)

UI.addToggle(espTab, "Chams (fill)", "🎨", true, function(state)
    E.setState("Chams", state)
end)

UI.addSlider(espTab, "Outline Thickness", 0, 3, 2, "px", function(v)
    E.OutlineWidth = v
end)

UI.addSlider(espTab, "Fill Transparency", 0, 100, math.floor(E.FillAlpha * 100), "%", function(v)
    E.FillAlpha = v / 100
    E.reapplyVisuals()
end)

-- ===================== FUN TAB =====================
UI.addLabel(funTab, "Anchored", "Hold an object and press B to freeze it")

UI.addToggle(funTab, "Anchored", "🧊", true, function(state)
    A.Enabled = state
    if not state then A.releaseAll() end
end)

UI.addKeybind(funTab, "Anchored Key", A.Key, function(newKey)
    A.Key = newKey
end)

UI.addActionButton(funTab, "Release All", "📤", function()
    A.releaseAll()
    Hub.showToast("Anchored", "All released")
end)

UI.addInfoBlock(funTab, "In this version, you cannot anchor other players yet. This feature is not implemented.")

UI.addLabel(funTab, "Anchor Aura", "Reclaims ownership of frozen objects near you")

UI.addToggle(funTab, "Aura Enabled", "🛡", true, function(state)
    A.AuraEnabled = state
end)

UI.addSlider(funTab, "Aura Radius", 10, 100, 100, " studs", function(v)
    A.AuraRadius = v
end)

-- ===================== SETTINGS TAB =====================
UI.addLabel(settingsTab, "Keybind", "Click the box, then press a key")
UI.addKeybind(settingsTab, "Toggle menu", M.ToggleKey, function(newKey)
    M.ToggleKey = newKey
end)

UI.addLabel(settingsTab, "Interface", "Extra widgets for the hub")
UI.addToggle(settingsTab, "Show FPS", "📊", false, function(state)
    if UI.FpsLabel then
        UI.FpsLabel.Visible = state
    end
end)

UI.addLabel(settingsTab, "Theme", "Pick a color for the hub")
for _, name in ipairs({"Blue", "Purple", "Pink", "Red", "Green"}) do
    UI.addThemeButton(settingsTab, name)
end

UI.addLabel(settingsTab, "Rofl Hub " .. Hub.Version, "Made for FTAP")

-- Apply theme
Hub.applyTheme = function(themeName)
    if not Themes[themeName] then return end
    Hub.CurrentTheme = themeName
    Hub.Accent = Themes[themeName].main
    Hub.AccentDark = Themes[themeName].dark

    for _, entry in ipairs(Hub.State.themeTargets) do
        pcall(function()
            local obj = entry.obj
            if not obj or not obj.Parent then return end
            if entry.kind == "accent" then
                TweenService:Create(obj, TweenInfo.new(0.45), {[entry.property] = Hub.Accent}):Play()
            elseif entry.kind == "accentDark" then
                TweenService:Create(obj, TweenInfo.new(0.45), {[entry.property] = Hub.AccentDark}):Play()
            end
        end)
    end

    for name, data in pairs(Hub.State.themeButtons) do
        if name == Hub.CurrentTheme then
            data.btn.BackgroundColor3 = Colors.btnActive
            data.btn.BackgroundTransparency = 0
            data.check.TextColor3 = Themes[name].main
            data.check.Text = "✓"
        else
            data.btn.BackgroundColor3 = Colors.btn
            data.btn.BackgroundTransparency = 0.3
            data.check.Text = ""
        end
    end
end

-- Регистрируем AccentLine и VersionLabel в themeTargets
table.insert(Hub.State.themeTargets, {obj = UI.AccentLine, property = "BackgroundColor3", kind = "accent"})
table.insert(Hub.State.themeTargets, {obj = UI.VersionLabel, property = "TextColor3", kind = "accent"})

-- Заглушка для registerTheme (не используется в этой версии UI)
Hub.registerTheme = function(obj, property, kind)
    table.insert(Hub.State.themeTargets, {obj = obj, property = property, kind = kind})
end

-- Стартовая вкладка
Hub.State.activeTabName = "Visuals"
for _, data in ipairs(Hub.State.tabButtons) do
    if data.name == "Visuals" then
        data.button.BackgroundColor3 = Colors.btnActive
        data.button.BackgroundTransparency = 0
        data.label.TextColor3 = Hub.Accent
        data.icon.TextColor3 = Hub.Accent
        data.leftBar.BackgroundTransparency = 0
        data.stroke.Transparency = 0.7
    else
        data.button.BackgroundColor3 = Colors.btn
        data.button.BackgroundTransparency = 0.5
        data.label.TextColor3 = Colors.text
        data.icon.TextColor3 = Colors.text
        data.leftBar.BackgroundTransparency = 1
        data.stroke.Transparency = 1
    end
end
Hub.State.sections["Visuals"].Visible = true

-- Открываем меню
openMenu()

Hub.log("settings.lua loaded")
