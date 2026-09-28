-- Rofl Hub | loader.lua
-- Точка входа. Скачивает и запускает все модули.
-- При ошибке показывает красную консоль.

local base = "https://raw.githubusercontent.com/vladrejs/rofl-hub/main/"

_G.RoflHub = _G.RoflHub or {}

-- ==================== ERROR CONSOLE ====================
local function showErrorConsole(moduleName, errText)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    local oldGui = PlayerGui:FindFirstChild("RoflHubErrorConsole")
    if oldGui then oldGui:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RoflHubErrorConsole"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 9999
    ScreenGui.Parent = PlayerGui

    local Frame = Instance.new("Frame")
    Frame.Name = "Console"
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Frame.Size = UDim2.new(0, 640, 0, 340)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 10, 10)
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Parent = ScreenGui

    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 12)
    FrameCorner.Parent = Frame

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color = Color3.fromRGB(220, 70, 70)
    FrameStroke.Thickness = 1.5
    FrameStroke.Parent = Frame

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(45, 15, 15)
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 2
    TitleBar.Parent = Frame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar

    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 15)
    TitleFix.Position = UDim2.new(0, 0, 1, -15)
    TitleFix.BackgroundColor3 = Color3.fromRGB(45, 15, 15)
    TitleFix.BorderSizePixel = 0
    TitleFix.ZIndex = 2
    TitleFix.Parent = TitleBar

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 30, 1, 0)
    Icon.Position = UDim2.new(0, 12, 0, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "!"
    Icon.TextColor3 = Color3.fromRGB(255, 100, 100)
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 18
    Icon.TextXAlignment = Enum.TextXAlignment.Center
    Icon.ZIndex = 3
    Icon.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 44, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Rofl Hub — Error in " .. moduleName
    TitleLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 3
    TitleLabel.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(70, 25, 25)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 220, 220)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 13
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 4
    CloseBtn.Parent = TitleBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 7)
    CloseCorner.Parent = CloseBtn

    CloseBtn.MouseEnter:Connect(function()
        CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
    end)
    CloseBtn.MouseLeave:Connect(function()
        CloseBtn.BackgroundColor3 = Color3.fromRGB(70, 25, 25)
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Size = UDim2.new(1, -24, 1, -60)
    Scroll.Position = UDim2.new(0, 12, 0, 48)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 60, 60)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    Scroll.ZIndex = 3
    Scroll.Parent = Frame

    local ErrorText = Instance.new("TextLabel")
    ErrorText.Size = UDim2.new(1, 0, 0, 0)
    ErrorText.AutomaticSize = Enum.AutomaticSize.Y
    ErrorText.BackgroundTransparency = 1
    ErrorText.Text = tostring(errText)
    ErrorText.TextColor3 = Color3.fromRGB(255, 180, 180)
    ErrorText.Font = Enum.Font.Code
    ErrorText.TextSize = 13
    ErrorText.TextXAlignment = Enum.TextXAlignment.Left
    ErrorText.TextYAlignment = Enum.TextYAlignment.Top
    ErrorText.TextWrapped = true
    ErrorText.ZIndex = 4
    ErrorText.Parent = Scroll

    local Hint = Instance.new("TextLabel")
    Hint.Size = UDim2.new(1, -24, 0, 20)
    Hint.Position = UDim2.new(0, 12, 1, -26)
    Hint.BackgroundTransparency = 1
    Hint.Text = "Send this error to the developer. Close the console with X to continue."
    Hint.TextColor3 = Color3.fromRGB(180, 120, 120)
    Hint.Font = Enum.Font.Gotham
    Hint.TextSize = 11
    Hint.TextXAlignment = Enum.TextXAlignment.Left
    Hint.ZIndex = 3
    Hint.Parent = Frame

    local dragging, dragStart, startPos = false, nil, nil
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ==================== LOAD MODULES ====================
local modules = {
    "config.lua",
    "ui.lua",
    "anchored.lua",
    "visuals.lua",
    "esp.lua",
    "settings.lua",
}

for _, name in ipairs(modules) do
    local ok, src = pcall(function()
        return game:HttpGet(base .. name)
    end)
    if not ok or not src or #src == 0 then
        showErrorConsole(name, "Failed to download module (HTTP error or empty file)")
        return
    end

    local fn, loadErr = loadstring(src)
    if not fn then
        showErrorConsole(name, "Compile error:\n\n" .. tostring(loadErr))
        return
    end

    local runOk, runErr = pcall(fn)
    if not runOk then
        showErrorConsole(name, "Runtime error:\n\n" .. tostring(runErr))
        return
    end
end

print("[Rofl Hub] All modules loaded successfully")
