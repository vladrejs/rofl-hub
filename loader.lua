-- Rofl Hub | loader.lua
-- Точка входа. Скачивает и запускает все модули.

local base = "https://raw.githubusercontent.com/vladrejs/rofl-hub/main/"

_G.RoflHub = _G.RoflHub or {}

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
        warn("[Rofl Hub] failed to download " .. name)
    else
        local fn, loadErr = loadstring(src)
        if not fn then
            warn("[Rofl Hub] loadstring error in " .. name .. ": " .. tostring(loadErr))
        else
            local runOk, runErr = pcall(fn)
            if not runOk then
                warn("[Rofl Hub] runtime error in " .. name .. ": " .. tostring(runErr))
            end
        end
    end
end

print("[Rofl Hub] All modules loaded")
