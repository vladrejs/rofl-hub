-- Rofl Hub | ui.lua
-- Окно, сайдбар, все виджеты

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

-- ==================== SCREEN GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RoflHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui
UI.ScreenGui = ScreenGui

-- Blur
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

-- Modal (backdrop)
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

-- Logo / Avatar
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

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -70, 0.5, -14)
MinBtn.BackgroundColor3 = Colors.btn
MinBtn.BackgroundTransparency = 0.3
MinBtn.BorderSizePixel = 0
MinBtn.Text = "—"
MinBtn.TextColor3 = Colors.text
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.AutoButtonColor = false
MinBtn.ZIndex = 4
MinBtn.Parent = TitleBar

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(1, 0)
MinBtnCorner.Parent = MinBtn

addConn(MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0, BackgroundColor3 = Colors.btnHover}):Play()
end))
addConn(MinBtn.MouseLeave:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, BackgroundColor3 = Colors.btn}):Play()
end))

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = Colors.btn
CloseBtn.BackgroundTransparency = 0.3
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Colors.text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 4
CloseBtn.Parent = TitleBar
UI.MinBtn = MinBtn
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

-- ==================== DRAG STRIPS ====================
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

local EDGE = Colors.edgeSize
local CORNER = Colors.cornerSize

local dragStrips = {
    makeDragStrip("TopEdge",    UDim2.new(1, 0, 0, EDGE), UDim2.new(0, 0, 0, 0)),
    makeDragStrip("BottomEdge", UDim2.new(1, 0, 0, EDGE), UDim2.new(0, 0, 1, -EDGE)),
    makeDragStrip("LeftEdge",   UDim2.new(0, EDGE, 1, 0), UDim2.new(0, 0, 0, 0)),
    makeDragStrip("RightEdge",  UDim2.new(0, EDGE, 1, 0), UDim2.new(1, -EDGE, 0, 0)),
    makeDragStrip("TopLeft",    UDim2.new(0, CORNER, 0, CORNER), UDim2.new(0, 0, 0, 0)),
    makeDragStrip("TopRight",   UDim2.new(0, CORNER, 0, CORNER), UDim2.new(1, -CORNER, 0, 0)),
    makeDragStrip("BottomLeft", UDim2.new(0, CORNER, 0, CORNER), UDim2.new(0, 0, 1, -CORNER)),
    makeDragStrip("BottomRight",UDim2.new(0, CORNER, 0, CORNER), UDim2.new(1, -CORNER, 1, -CORNER)),
}
UI.dragStrips = dragStrips

local dragging, dragStart, startPos = false, nil, nil

for _, strip in ipairs(dragStrips) do
    addConn(strip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end))
end

addConn(UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end))

addConn(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end))

-- ==================== SIDEBAR ====================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 155, 1, -80)
Sidebar.Position = UDim2.new(0, 12, 0, 62)
Sidebar.BackgroundColor3 = Colors.panel
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
UI.Sidebar = Sidebar

-- ==================== CONTENT ====================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -190, 1, -88)
Content.Position = UDim2.new(0, 177, 0, 62)
Content.BackgroundColor3 = Colors.panelInner
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
UI.Scroll = Scroll

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

-- ==================== RIPPLE ====================
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
UI.attachRipple = attachRipple

-- ==================== CREATE TAB ====================
local function createTab(tabName, iconEmoji)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Colors.btn
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
    btnStroke.Color = Hub.Accent
    btnStroke.Thickness = 1
    btnStroke.Transparency = 1
    btnStroke.Parent = btn

    local leftBar = Instance.new("Frame")
    leftBar.Size = UDim2.new(0, 3, 0, 20)
    leftBar.Position = UDim2.new(0, 2, 0.5, -10)
    leftBar.BackgroundColor3 = Hub.Accent
    leftBar.BorderSizePixel = 0
    leftBar.BackgroundTransparency = 1
    leftBar.ZIndex = 4
    leftBar.Parent = btn

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
    icon.TextColor3 = Colors.text
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.ZIndex = 4
    icon.Parent = iconCircle

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 44, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tabName
    lbl.TextColor3 = Colors.text
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

    Hub.State.sections[tabName] = section
    table.insert(Hub.State.tabButtons, {
        button = btn,
        name = tabName,
        label = lbl,
        icon = icon,
        stroke = btnStroke,
        leftBar = leftBar,
    })

    attachRipple(btn)

    addConn(btn.MouseButton1Click:Connect(function()
        Hub.State.activeTabName = tabName
        for _, data in ipairs(Hub.State.tabButtons) do
            TweenService:Create(data.button, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()
            data.label.TextColor3 = Colors.text
            data.icon.TextColor3 = Colors.text
            TweenService:Create(data.leftBar, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            TweenService:Create(data.stroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
        end
        TweenService:Create(btn, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0, BackgroundColor3 = Colors.btnActive}):Play()
        lbl.TextColor3 = Hub.Accent
        icon.TextColor3 = Hub.Accent
        TweenService:Create(leftBar, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play()
        for _, sec in pairs(Hub.State.sections) do sec.Visible = false end
        section.Visible = true
    end))

    addConn(btn.MouseEnter:Connect(function()
        if btn.BackgroundColor3 ~= Colors.btnActive then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.15, BackgroundColor3 = Colors.btnHover}):Play()
        end
    end))
    addConn(btn.MouseLeave:Connect(function()
        if btn.BackgroundColor3 ~= Colors.btnActive then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.5, BackgroundColor3 = Colors.btn}):Play()
        end
    end))

    return section
end
UI.createTab = createTab

-- ==================== WIDGET: LABEL ====================
local function addLabel(parent, text, subtext)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, subtext and 46 or 26)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 3
    holder.Parent = parent

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 0, 18)
    bar.Position = UDim2.new(0, 0, 0, 2)
    bar.BackgroundColor3 = Hub.Accent
    bar.BorderSizePixel = 0
    bar.ZIndex = 3
    bar.Parent = holder

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 0, 22)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.text
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
        sub.TextColor3 = Colors.subtext
        sub.Font = Enum.Font.Gotham
        sub.TextSize = 12
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.ZIndex = 3
        sub.Parent = holder
    end
    return holder
end
UI.addLabel = addLabel

-- ==================== WIDGET: INFO BLOCK ====================
local function addInfoBlock(parent, text)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 0)
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    holder.BackgroundTransparency = 0.3
    holder.ZIndex = 3
    holder.Parent = parent

    local holderCorner = Instance.new("UICorner")
    holderCorner.CornerRadius = UDim.new(0, 8)
    holderCorner.Parent = holder

    local holderStroke = Instance.new("UIStroke")
    holderStroke.Color = Color3.fromRGB(58, 58, 74)
    holderStroke.Thickness = 1
    holderStroke.Transparency = 0.5
    holderStroke.Parent = holder

    local holderPad = Instance.new("UIPadding")
    holderPad.PaddingTop = UDim.new(0, 8)
    holderPad.PaddingBottom = UDim.new(0, 8)
    holderPad.PaddingLeft = UDim.new(0, 10)
    holderPad.PaddingRight = UDim.new(0, 10)
    holderPad.Parent = holder

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.subtext
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.TextWrapped = true
    lbl.ZIndex = 3
    lbl.Parent = holder

    return holder
end
UI.addInfoBlock = addInfoBlock

-- ==================== WIDGET: SLIDER ====================
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
    lbl.TextColor3 = Colors.text
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
    fill.BackgroundColor3 = Hub.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 3
    fill.Parent = bar

    local fillC = Instance.new("UICorner")
    fillC.CornerRadius = UDim.new(1, 0)
    fillC.Parent = fill

    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Hub.AccentDark),
        ColorSequenceKeypoint.new(1, Hub.Accent),
    })
    fillGradient.Parent = fill

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
    knobStroke.Color = Hub.Accent
    knobStroke.Thickness = 2
    knobStroke.Parent = knob

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
UI.addSlider = addSlider

-- ==================== WIDGET: TOGGLE ====================
local function addToggle(parent, text, iconEmoji, defaultState, callback)
    local state = defaultState or false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Colors.btn
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
    icon.TextColor3 = Colors.text
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.ZIndex = 3
    icon.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 38, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = btn

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 36, 0, 18)
    track.Position = UDim2.new(1, -50, 0.5, -9)
    track.BackgroundColor3 = state and Hub.Accent or Color3.fromRGB(50, 50, 62)
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

    attachRipple(btn)

    addConn(btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0, BackgroundColor3 = Colors.btnHover}):Play()
    end))
    addConn(btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, BackgroundColor3 = Colors.btn}):Play()
    end))

    local function setState(newState, fireCallback)
        state = newState
        if state then
            TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = Hub.Accent}):Play()
            TweenService:Create(ball, TweenInfo.new(0.15), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
        else
            TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 50, 62)}):Play()
            TweenService:Create(ball, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
        end
        if fireCallback and callback then callback(state) end
    end

    addConn(btn.MouseButton1Click:Connect(function()
        setState(not state, true)
        UI.showToast(text, state and "Enabled" or "Disabled")
    end))

    return {button = btn, setState = setState, isOn = function() return state end}
end
UI.addToggle = addToggle

-- ==================== WIDGET: ACTION BUTTON ====================
local function addActionButton(parent, text, iconEmoji, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Colors.btn
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
    icon.TextColor3 = Colors.text
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.ZIndex = 3
    icon.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 38, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Colors.text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = btn

    attachRipple(btn)

    addConn(btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0, BackgroundColor3 = Colors.btnHover}):Play()
    end))
    addConn(btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, BackgroundColor3 = Colors.btn}):Play()
    end))

    addConn(btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end))

    return btn
end
UI.addActionButton = addActionButton

-- ==================== WIDGET: KEYBIND ====================
local function addKeybind(parent, labelText, defaultKey, onChanged)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Colors.btn
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
    lbl.TextColor3 = Colors.text
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
    keyBox.TextColor3 = Colors.text
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
        keyBox.TextColor3 = Colors.text
        UI.showToast("Keybind: " .. currentKey.Name, labelText)
    end))

    attachRipple(btn)

    addConn(btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0, BackgroundColor3 = Colors.btnHover}):Play()
    end))
    addConn(btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, BackgroundColor3 = Colors.btn}):Play()
    end))

    addConn(btn.MouseButton1Click:Connect(function()
        if listening then
            listening = false
            keyBox.Text = currentKey.Name
            keyBox.TextColor3 = Colors.text
        else
            listening = true
            keyBox.Text = "..."
            keyBox.TextColor3 = Hub.Accent
        end
    end))

    return btn
end
UI.addKeybind = addKeybind

-- ==================== WIDGET: THEME BUTTON ====================
local function addThemeButton(parent, themeName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Colors.btn
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
    dot.BackgroundColor3 = Themes[themeName].main
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
    lbl.TextColor3 = Colors.text
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
    check.TextColor3 = Hub.Accent
    check.Font = Enum.Font.GothamBold
    check.TextSize = 14
    check.TextXAlignment = Enum.TextXAlignment.Right
    check.ZIndex = 3
    check.Parent = btn

    Hub.State.themeButtons[themeName] = {btn = btn, check = check, label = lbl, dot = dot}

    attachRipple(btn)

    addConn(btn.MouseEnter:Connect(function()
        if Hub.CurrentTheme ~= themeName then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Colors.btnHover, BackgroundTransparency = 0}):Play()
        end
    end))
    addConn(btn.MouseLeave:Connect(function()
        if Hub.CurrentTheme ~= themeName then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Colors.btn, BackgroundTransparency = 0.3}):Play()
        end
    end))

    addConn(btn.MouseButton1Click:Connect(function()
        if Hub.applyTheme then Hub.applyTheme(themeName) end
        UI.showToast("Theme: " .. themeName, "Applied")
    end))

    return btn
end
UI.addThemeButton = addThemeButton

Hub.log("ui.lua loaded")ц
