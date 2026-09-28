-- Rofl Hub | visuals.lua
-- FOV, Lighting, Skybox, Time

local Hub = _G.RoflHub or {}
_G.RoflHub = Hub

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

Hub.Visuals = {}
local V = Hub.Visuals

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

V.OriginalFOV = ORIGINAL_FOV
V.OriginalLighting = ORIGINAL_LIGHTING

V.CurrentSkybox = "HD"

-- Применить скайбокс
function V.applySkybox(skyboxName)
    local data = Hub.SkyboxAssets[skyboxName]
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
    V.CurrentSkybox = skyboxName
end

-- Восстановить дефолтный скайбокс
function V.restoreDefaultSky()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "Sky"
        sky.Parent = Lighting
    end
    if Hub.DefaultSkySettings then
        sky.SkyboxBk = Hub.DefaultSkySettings.Bk
        sky.SkyboxDn = Hub.DefaultSkySettings.Dn
        sky.SkyboxFt = Hub.DefaultSkySettings.Ft
        sky.SkyboxLf = Hub.DefaultSkySettings.Lf
        sky.SkyboxRt = Hub.DefaultSkySettings.Rt
        sky.SkyboxUp = Hub.DefaultSkySettings.Up
    else
        sky.SkyboxBk = ""
        sky.SkyboxDn = ""
        sky.SkyboxFt = ""
        sky.SkyboxLf = ""
        sky.SkyboxRt = ""
        sky.SkyboxUp = ""
    end
end

Hub.log("visuals.lua loaded")
