-- Rofl Hub | ui.lua
-- Window, sidebar, widgets (with theme registration)

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

local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(1, 0)
MinBtnCorner.Parent = MinBtn

addConn(MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0, BackgroundColor3 = Colors.btnHover}):Play()
end))
addConn(MinBtn.MouseLeave:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3, BackgroundColor3 = Colors.btn
