-- Rofl Hub | ui.lua
-- Window, sidebar, widgets (with theme registration)
-- FIXED: correct order, no duplicates, no nil MouseLeave

local Hub = _G.RoflHub or {}
_G.RoflHub = Hub

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = workspace.CurrentCamera

local Colors = Hub.Colors
local Themes = Hub.Themes

Hub.UI = {}
local UI = Hub.UI

UI.LocalPlayer = LocalPlayer
UI.PlayerGui   = PlayerGui
UI.Camera      = Camera
UI.Tween       = TweenService
UI.Run         = RunService
UI.Input       = UserInputService

local addConn = Hub.addConn
UI.addConn = addConn

local registerTheme = Hub.registerTheme
UI.registerTheme = registerTheme

-- ==================== SCREEN GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RoflHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui
UI.ScreenGui = ScreenGui

for _, obj in ipairs(game:GetService("Lighting"):GetChildren()) do
    if obj:IsA("BlurEffect") then pcall(function() obj:Destroy() end) end
end
local Blur = Instance.new("BlurEffect")
Blur.Name = "RoflHubBlur"
Blur.Size = 0
Blur.Parent = game:GetService("Lighting")
UI.Blur = Blur

local blurTarget = 0
local blurTween = nil
function UI.setBlur(target)
    blurTarget = target
    if blurTween then pcall(function() blurTween:Cancel() end) end
    blurTween = TweenService:Create(Blur, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = target })
    blurTween:Play()
end

addConn(RunService.RenderStepped:Connect(function()
    if blurTarget > 0 and Blur.Size < 5 then UI.setBlur(blurTarget)
    elseif blurTarget == 0 and Blur.Size > 5 then UI.setBlur(0) end
end))

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
UI.ModalBtn = ModalBtn

-- ==================== TOAST ====================
local toastContainer = Instance.new("Frame")
toastContainer.Name = "ToastContainer"
toastContainer.AnchorPoint = Vector2.new(1, 0)
toastContainer.Position = UDim2.new(1, -20, 0, 80)
toastContainer.Size = UDim2.new(0, 280, 0, 400)
toastContainer.BackgroundTransparency = 1
toastContainer.Parent = ScreenGui
UI.toastContainer = toastContainer

local toastLayout = Instance.new("UIListLayout")
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Padding = UDim.new(0, 8)
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
toastLayout.Parent = toastContainer

function UI.showToast(title, subtitle)
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 56)
    toast.BackgroundColor3 = Colors.panel
    toast.BorderSizePixel = 0
    toast.Position = UDim2.new(1, 320, 0, 0)
    toast.Parent = toastContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toast

    local stroke = Instance.new("UIStroke")
    stroke.Color = Hub.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Parent = toast

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, -12)
    accentBar.Position = UDim2.new(0, 6, 0, 6)
    accentBar.BackgroundColor3 = Hub.Accent
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
    titleLbl.TextColor3 = Colors.text
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = toast

    local subLbl = Instance.new("TextLabel")
    subLbl.Size = UDim2.new(1, -30, 0, 16)
    subLbl.Position = UDim2.new(0, 18, 0, 30)
    subLbl.BackgroundTransparency = 1
    subLbl.Text = subtitle or ""
    subLbl.TextColor3 = Colors.subtext
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

-- ==================== WINDOW ====================
local Window = Instance.new("Frame")
Window.Name = "Window"
Window.AnchorPoint = Vector2.new(0.5, 0.5)
Window.Position = UDim2.new(0.5, 0, 0.5, 0)
Window.Size = UDim2.new(0, 580, 0, 400)
Window.BackgroundColor3 = Colors.bg
Window.BorderSizePixel = 0
Window.Active = false
Window.ClipsDescendants = true
Window.Parent = ScreenGui
UI.Window = Window

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

-- ==================== TITLE BAR ====================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 52)
TitleBar.BackgroundColor3 = Colors.panel
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
TitleFix.BackgroundColor3 = Colors.panel
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
AccentLine.BackgroundColor3 = Hub.Accent
AccentLine.BackgroundTransparency = 0.3
AccentLine.BorderSizePixel = 0
AccentLine.ZIndex = 3
AccentLine.Parent = TitleBar
UI.AccentLine = AccentLine
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
LogoStroke.Color = Hub.Accent
LogoStroke.Thickness = 1.5
LogoStroke.Parent = LogoFrame
UI.LogoStroke = LogoStroke
registerTheme(LogoStroke, "Color", "accent")

local LogoImage = Instance.new("ImageLabel")
LogoImage.Size = UDim2.new(1, -2, 1, -2)
LogoImage.Position = UDim2.new(0, 1, 0, 1)
LogoImage.BackgroundTransparency = 1
LogoImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
LogoImage.ZIndex = 4
LogoImage.Parent = LogoFrame
UI.LogoImage = LogoImage

local LogoImageCorner = Instance.new("UICorner")
LogoImageCorner.CornerRadius = UDim.new(1, 0)
LogoImageCorner.Parent = LogoImage

task.spawn(function()
    local ok, url = pcall(function()
        return Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end)
    if ok and url and LogoImage then
        LogoImage.Image = url
    end
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 100, 0, 18)
TitleLabel.Position = UDim2.new(0, 54, 0, 12)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = Hub.Name
TitleLabel.TextColor3 = Colors.text
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 60, 0, 18)
VersionLabel.Position = UDim2.new(0, 158, 0, 17)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = Hub.Version
VersionLabel.TextColor3 = Hub.Accent
VersionLabel.Font = Enum.Font.GothamBold
VersionLabel.TextSize = 11
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
VersionLabel.ZIndex = 3
VersionLabel.Parent = TitleBar
UI.VersionLabel = VersionLabel
registerTheme(VersionLabel, "TextColor3", "accent")

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Name = "FpsLabel"
FpsLabel.Size = UDim2.new(0, 55, 0, 18)
FpsLabel.Position = UDim2.new(1, -128, 0.5, -9)
FpsLabel.BackgroundTransparency = 1
FpsLabel.Text = "60 FPS"
FpsLabel.TextColor3 = Colors.subtext
FpsLabel.Font = Enum.Font.GothamBold
FpsLabel.TextSize = 12
FpsLabel.TextXAlignment = Enum.TextXAlignment.Right
FpsLabel.TextYAlignment = Enum.TextYAlignment.Center
FpsLabel.Visible = false
FpsLabel.ZIndex = 4
FpsLabel.Parent = TitleBar
UI.FpsLabel = FpsLabel

local fpsFrames = 0
local fpsTime = 0
addConn(RunService.RenderStepped:Connect(function(dt)
    fpsFrames = fpsFrames + 1
    fpsTime = fpsTime + dt
    if fpsTime >= 0.5 then
        if FpsLabel.Visible then
            FpsLabel.Text = tostring(math.floor(fpsFrames / fpsTime)) .. " FPS"
        end
        fpsFrames = 0
        fpsTime = 0
    end
end))

-- ==================== MIN BUTTON ====================
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -70, 0.5, -14)
MinBtn.BackgroundColor3 = Colors.btn
MinBtn.BackgroundTransparency = 0.3
MinBtn.BorderSizePixel = 0
MinBtn.Text = "-"
MinBtn.TextColor3 = Colors.text
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.AutoButtonColor = false
MinBtn.ZIndex = 4
MinBtn.Parent = TitleBar
UI.MinBtn = MinBtn

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(1, 0)
MinBtnCorner.Parent = MinBtn

addConn(MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0, BackgroundColor3 = Colors.btnHover}):Play()
end))
addConn(MinBtn.MouseLeave:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, BackgroundColor3 = Colors.btn}):Play()
end))

-- ==================== CLOSE BUTTON ====================
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = Colors.btn
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Colors.text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 4
CloseBtn.Parent = TitleBar
UI.CloseBtn = CloseBtn

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(1, 0)
CloseBtnCorner.Parent = CloseBtn

addConn(CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0, BackgroundColor3 = Colors.close}):Play()
end))
addConn(CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, BackgroundColor3 = Colors.btn}):Play()
end))

-- ==================== DRAG ====================
local dragging, dragStart, startPos = false, nil, nil

local function beginDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Window.Position
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

addConn(TitleBar.InputBegan:Connect(beginDrag))
addConn(UserInputService.InputChanged:Connect(updateDrag))
addConn(UserInputService.InputEnded:Connect(endDrag))

-- ==================== MINIMIZE ====================
local minimized = false
addConn(MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Window.Size = UDim2.new(0, 580, 0, 52)
        MinBtn.Text = "+"
    else
        Window.Size = UDim2.new(0, 580, 0, 400)
        MinBtn.Text = "-"
    end
end))

-- ==================== SIDEBAR ====================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 155, 1, -68)
Sidebar.Position = UDim2.new(0, 12, 0, 60)
Sidebar.BackgroundColor3 = Colors.panel
Sidebar.BackgroundTransparency = 0.3
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 2
Sidebar.Parent = Window
UI.Sidebar = Sidebar

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

local SidebarStroke = Instance.new("UIStroke")
SidebarStroke.Color = Color3.fromRGB(40, 40, 52)
SidebarStroke.Thickness = 1
SidebarStroke.Transparency = 0.3
SidebarStroke.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 10)
SidebarPad.PaddingLeft = UDim.new(0, 8)
SidebarPad.PaddingRight = UDim.new(0, 8)
SidebarPad.Parent = Sidebar

-- ==================== CONTENT ====================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -190, 1, -76)
Content.Position = UDim2.new(0, 177, 0, 60)
Content.BackgroundColor3 = Colors.panelInner
Content.BackgroundTransparency = 0.3
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.ZIndex = 2
Content.Parent = Window
UI.Content = Content

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = Content

local ContentStroke = Instance.new("UIStroke")
ContentStroke.Color = Color3.fromRGB(40, 40, 52)
ContentStroke.Thickness = 1
ContentStroke.Transparency = 0.3
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
UI.Scroll = Scroll

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

-- ==================== TABS ====================
local tabButtons, sections = {}, {}
local activeTabName = nil

local function createTab(tabName, emoji)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Colors.btn
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    btn.ZIndex = 3
    btn.Parent = Sidebar
    tabButtons[tabName] = btn

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Hub.Accent
    btnStroke.Thickness = 1.5
    btnStroke.Transparency = 1
    btnStroke.Parent = btn
    registerTheme(btnStroke, "Color", "accent")

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 26, 1, 0)
    icon.Position = UDim2.new(0, 6, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = emoji or ""
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 14
    icon.TextColor3 = Colors.text
    icon.ZIndex = 3
    icon.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -32, 1, 0)
    lbl.Position = UDim2.new(0, 32, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tabName
    lbl.TextColor3 = Colors.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = btn

    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.ZIndex = 3
    tabContent.Parent = Scroll

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = tabContent

    sections[tabName] = tabContent

    btn.MouseButton1Click:Connect(function()
        if activeTabName == tabName then return end
        for name, b in pairs(tabButtons) do
            local s = b:FindFirstChildOfClass("UIStroke")
            if s then s.Transparency = 1 end
            b.BackgroundColor3 = Colors.btn
            if sections[name] then sections[name].Visible = false end
        end
        btnStroke.Transparency = 0
        btn.BackgroundColor3 = Colors.btnActive
        tabContent.Visible = true
        activeTabName = tabName
    end)

    btn.MouseEnter:Connect(function()
        if activeTabName ~= tabName then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Colors.btnHover}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTabName ~= tabName then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Colors.btn}):Play()
        end
    end)
end

-- ==================== WIDGETS ====================
local function createSection(parentTab, title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 30)
    section.BackgroundTransparency = 1
    section.ZIndex = 4
    section.Parent = sections[parentTab]

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Colors.subtext
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 4
    lbl.Parent = section

    return section
end

local function createButton(parentTab, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Colors.btn
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Colors.text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.AutoButtonColor = false
    btn.ZIndex = 4
    btn.Parent = sections[parentTab]

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Colors.btnHover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Colors.btn}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)

    return btn
end

local function createToggle(parentTab, text, default, callback)
    local state = default or false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = Colors.btn
    frame.BorderSizePixel = 0
    frame.ZIndex = 4
    frame.Parent = sections[parentTab]

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = frame

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 36, 0, 20)
    switch.Position = UDim2.new(1, -48, 0.5, -10)
    switch.BackgroundColor3 = state and Hub.Accent or Color3.fromRGB(60, 60, 75)
    switch.BorderSizePixel = 0
    switch.ZIndex = 5
    switch.Parent = frame
    registerTheme(switch, "BackgroundColor3", "accent", { condition = function() return state end })

    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(1, 0)
    sc.Parent = switch

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 6
    knob.Parent = switch

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local function setState(v)
        state = v
        TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = state and Hub.Accent or Color3.fromRGB(60, 60, 75)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        if callback then pcall(callback, state) end
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setState(not state)
        end
    end)

    return {set = setState, get = function() return state end}
end

local function createSlider(parentTab, text, min, max, default, callback)
    local value = default or min

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 44)
    frame.BackgroundColor3 = Colors.btn
    frame.BorderSizePixel = 0
    frame.ZIndex = 4
    frame.Parent = sections[parentTab]

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 0, 18)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = frame

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0, 50, 0, 18)
    valLbl.Position = UDim2.new(1, -62, 0, 4)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(value)
    valLbl.TextColor3 = Hub.Accent
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 5
    valLbl.Parent = frame
    registerTheme(valLbl, "TextColor3", "accent")

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -24, 0, 6)
    barBg.Position = UDim2.new(0, 12, 0, 30)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 5
    barBg.Parent = frame

    local bgc = Instance.new("UICorner")
    bgc.CornerRadius = UDim.new(1, 0)
    bgc.Parent = barBg

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Hub.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 6
    fill.Parent = barBg
    registerTheme(fill, "BackgroundColor3", "accent")

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill

    local draggingSlider = false

    local function updateFromMouse(x)
        local rel = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * rel + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valLbl.Text = tostring(value)
        if callback then pcall(callback, value) end
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
            updateFromMouse(input.Position.X)
        end
    end)

    addConn(UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromMouse(input.Position.X)
        end
    end))

    addConn(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end))

    return {set = function(v) value = v; fill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0); valLbl.Text = tostring(v); if callback then pcall(callback, v) end end, get = function() return value end}
end

local function createDropdown(parentTab, text, options, default, callback)
    local selected = default or options[1]
    local open = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = Colors.btn
    frame.BorderSizePixel = 0
    frame.ZIndex = 4
    frame.Parent = sections[parentTab]

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = frame

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.5, -24, 1, 0)
    valLbl.Position = UDim2.new(0.5, 12, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = selected
    valLbl.TextColor3 = Hub.Accent
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 13
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.ZIndex = 5
    valLbl.Parent = frame
    registerTheme(valLbl, "TextColor3", "accent")

    local list = Instance.new("Frame")
    list.Size = UDim2.new(1, 0, 0, 0)
    list.Position = UDim2.new(0, 0, 1, 4)
    list.BackgroundColor3 = Colors.panelInner
    list.BorderSizePixel = 0
    list.ClipsDescendants = true
    list.Visible = false
    list.ZIndex = 6
    list.Parent = frame

    local lc = Instance.new("UICorner")
    lc.CornerRadius = UDim.new(0, 7)
    lc.Parent = list

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = list

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 4)
    listPad.PaddingBottom = UDim.new(0, 4)
    listPad.PaddingLeft = UDim.new(0, 4)
    listPad.PaddingRight = UDim.new(0, 4)
    listPad.Parent = list

    local optionButtons = {}

    local function closeList()
        open = false
        list.Visible = false
        for _, b in ipairs(optionButtons) do b.Visible = false end
    end

    local function openList()
        open = true
        list.Visible = true
        for _, b in ipairs(optionButtons) do b.Visible = true end
        local totalH = #options * 28 + 8
        TweenService:Create(list, TweenInfo.new(0.15), {Size = UDim2.new(1, 0, 0, totalH)}):Play()
    end

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 26)
        optBtn.BackgroundColor3 = Colors.btn
        optBtn.BorderSizePixel = 0
        optBtn.Text = opt
        optBtn.TextColor3 = Colors.text
        optBtn.Font = Enum.Font.GothamMedium
        optBtn.TextSize = 12
        optBtn.AutoButtonColor = false
        optBtn.Visible = false
        optBtn.ZIndex = 7
        optBtn.Parent = list
        table.insert(optionButtons, optBtn)

        local oc = Instance.new("UICorner")
        oc.CornerRadius = UDim.new(0, 5)
        oc.Parent = optBtn

        optBtn.MouseEnter:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.btnHover}):Play()
        end)
        optBtn.MouseLeave:Connect(function()
            TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Colors.btn}):Play()
        end)
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            valLbl.Text = opt
            closeList()
            if callback then pcall(callback, opt) end
        end)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if open then closeList() else openList() end
        end
    end)

    return {set = function(v) selected = v; valLbl.Text = v; if callback then pcall(callback, v) end end, get = function() return selected end}
end

local function createKeybind(parentTab, text, defaultKey, callback)
    local currentKey = defaultKey or Enum.KeyCode.M
    local listening = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = Colors.btn
    frame.BorderSizePixel = 0
    frame.ZIndex = 4
    frame.Parent = sections[parentTab]

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = frame

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 60, 0, 22)
    keyBtn.Position = UDim2.new(1, -72, 0.5, -11)
    keyBtn.BackgroundColor3 = Colors.panelInner
    keyBtn.BorderSizePixel = 0
    keyBtn.Text = currentKey.Name
    keyBtn.TextColor3 = Colors.text
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 12
    keyBtn.AutoButtonColor = false
    keyBtn.ZIndex = 5
    keyBtn.Parent = frame

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(0, 5)
    kc.Parent = keyBtn

    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."
    end)

    addConn(UserInputService.InputBegan:Connect(function(input, gpe)
        if not listening then return end
        if gpe then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        listening = false
        currentKey = input.KeyCode
        keyBtn.Text = currentKey.Name
        if callback then pcall(callback, currentKey) end
    end))

    return {get = function() return currentKey end}
end

-- ==================== APPLY THEME ====================
function UI.applyTheme(themeName)
    local t = Themes[themeName]
    if not t then return end
    Hub.Accent = t.main
    Hub.AccentDark = t.dark
    Hub.CurrentTheme = themeName
    for _, entry in ipairs(Hub.State.themeTargets) do
        local obj = entry.obj
        if obj and obj.Parent then
            if entry.kind == "accent" then
                pcall(function() obj[entry.property] = t.main end)
            elseif entry.kind == "accentDark" then
                pcall(function() obj[entry.property] = t.dark end)
            end
        end
    end
end

-- ==================== CREATE DEFAULT TABS ====================
createTab("Visuals", "👁")
createTab("ESP", "🎯")
createTab("Fun", "🎮")
createTab("Settings", "⚙")
createTab("Themes", "🎨")

if sections["Visuals"] then sections["Visuals"].Visible = true end
activeTabName = "Visuals"
local vBtn = tabButtons["Visuals"]
if vBtn then
    local s = vBtn:FindFirstChildOfClass("UIStroke")
    if s then s.Transparency = 0 end
    vBtn.BackgroundColor3 = Colors.btnActive
end

-- ==================== EXPORT ====================
UI.createTab = createTab
UI.createSection = createSection
UI.createButton = createButton
UI.createToggle = createToggle
UI.createSlider = createSlider
UI.createDropdown = createDropdown
UI.createKeybind = createKeybind

return UI
