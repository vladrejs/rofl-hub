-- Rofl Hub | anchored.lua
-- Anchored + Anchor Aura

local Hub = _G.RoflHub or {}
_G.RoflHub = Hub

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

Hub.Anchored = {}
local A = Hub.Anchored

A.Enabled = true
A.Key = Enum.KeyCode.B
A.Targets = {}

A.AuraEnabled = true
A.AuraRadius = 100

local function addConn(c)
    return Hub.addConn(c)
end

-- Найти объект в руках (FTAP)
local function getHeldTarget()
    local ok, part = pcall(function()
        local grabParts = workspace:FindFirstChild("GrabParts")
        if not grabParts then return nil end
        local grabPart = grabParts:FindFirstChild("GrabPart")
        if not grabPart then return nil end
        local weld = grabPart:FindFirstChild("WeldConstraint")
        if not weld then return nil end
        local p1 = weld.Part1
        if not p1 or not p1.Parent then p1 = weld.Part0 end
        if not p1 or not p1.Parent or not p1:IsA("BasePart") then return nil end
        return p1
    end)
    if not ok or not part then return nil end
    local model = part:FindFirstAncestorOfClass("Model")
    if model and model ~= workspace then return model end
    return part
end

-- Проверка что это часть карты
local function isMapPart(part)
    if not part then return false end
    local map = workspace:FindFirstChild("Map")
    if map then
        local c = part
        while c do
            if c == map then return true end
            c = c.Parent
        end
    end
    if part:IsA("BasePart") and part.Size.Magnitude > 100 then return true end
    return false
end

-- Закрепить объект (BodyPosition + BodyGyro)
local function attachHold(target)
    if not target then return nil end
    local ok, entry = pcall(function()
        local mainPart, allParts = nil, {}
        if target:IsA("Model") then
            mainPart = target.PrimaryPart
            if not mainPart then
                for _, ch in ipairs(target:GetDescendants()) do
                    if ch:IsA("BasePart") then mainPart = ch break end
                end
            end
            for _, ch in ipairs(target:GetDescendants()) do
                if ch:IsA("BasePart") then table.insert(allParts, ch) end
            end
        elseif target:IsA("BasePart") then
            mainPart = target
            allParts = {target}
        else return nil end
        if not mainPart then return nil end

        local fixedPos = mainPart.Position
        local fixedCF  = mainPart.CFrame

        for _, p in ipairs(allParts) do
            for _, name in ipairs({"RoflAnchoredPos", "RoflAnchoredOr"}) do
                pcall(function()
                    local old = p:FindFirstChild(name)
                    if old then old:Destroy() end
                end)
            end
        end

        local mass = 0
        for _, p in ipairs(allParts) do mass = mass + p.AssemblyMass end
        mass = math.max(mass, 1)
        local force = math.clamp(mass * workspace.Gravity * 500, 1e6, 1e10)

        local bp = Instance.new("BodyPosition")
        bp.Name = "RoflAnchoredPos"
        bp.Position = fixedPos
        bp.P = 500000
        bp.D = 5000
        bp.MaxForce = Vector3.new(force, force, force)
        bp.Parent = mainPart

        local bg = Instance.new("BodyGyro")
        bg.Name = "RoflAnchoredOr"
        bg.CFrame = fixedCF
        bg.P = 500000
        bg.D = 5000
        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bg.Parent = mainPart

        pcall(function() mainPart:SetNetworkOwner(LocalPlayer) end)

        return {bodyPos = bp, bodyGyro = bg, part = mainPart, allParts = allParts}
    end)
    if ok then return entry end
    return nil
end

local function detachHold(entry)
    if not entry then return end
    pcall(function() if entry.bodyPos then entry.bodyPos:Destroy() end end)
    pcall(function() if entry.bodyGyro then entry.bodyGyro:Destroy() end end)
    if entry.allParts then
        for _, p in ipairs(entry.allParts) do
            pcall(function()
                for _, name in ipairs({"RoflAnchoredPos", "RoflAnchoredOr"}) do
                    local old = p:FindFirstChild(name)
                    if old then old:Destroy() end
                end
            end)
        end
    end
end

function A.releaseAll()
    for _, entry in pairs(A.Targets) do detachHold(entry) end
    A.Targets = {}
end

function A.toggle()
    if not A.Enabled then return end
    local target = getHeldTarget()
    if not target then return end

    if A.Targets[target] then
        detachHold(A.Targets[target])
        A.Targets[target] = nil
        if Hub.showToast then Hub.showToast("Anchored", "Unfrozen") end
        return
    end

    local isMap = false
    if target:IsA("Model") then
        for _, p in ipairs(target:GetDescendants()) do
            if p:IsA("BasePart") and isMapPart(p) then isMap = true break end
        end
    else
        isMap = isMapPart(target)
    end

    if isMap then
        if Hub.showToast then Hub.showToast("Anchored", "Cannot freeze the map!") end
        return
    end

    local entry = attachHold(target)
    if entry then
        A.Targets[target] = entry
        if Hub.showToast then Hub.showToast("Anchored", "Frozen") end
    end
end

-- Клавиша B
addConn(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if not A.Enabled then return end
    if input.KeyCode == A.Key then
        pcall(A.toggle)
    end
end))

-- Aura (автоматический возврат владения)
local function auraTick()
    if not A.AuraEnabled or not A.Enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local myHRP = char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local myPos = myHRP.Position
    local radius = A.AuraRadius

    for target, entry in pairs(A.Targets) do
        local part = entry.part
        if part and part.Parent then
            if (part.Position - myPos).Magnitude <= radius then
                local owner = nil
                pcall(function() owner = part:GetNetworkOwner() end)
                if owner ~= LocalPlayer then
                    pcall(function() part:SetNetworkOwner(LocalPlayer) end)
                    pcall(function()
                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end)
                end
            end
        else
            A.Targets[target] = nil
        end
    end
end

addConn(RunService.RenderStepped:Connect(auraTick))
addConn(RunService.Heartbeat:Connect(auraTick))

Hub.log("anchored.lua loaded")
