-- Rofl Hub | config.lua
-- Общие данные для всех модулей

local Hub = _G.RoflHub or {}
_G.RoflHub = Hub

Hub.Version = "v1.5"
Hub.Name    = "Rofl Hub"

Hub.Themes = {
    Blue   = { main = Color3.fromRGB(120, 170, 255), dark = Color3.fromRGB(70, 120, 200)  },
    Purple = { main = Color3.fromRGB(170, 120, 255), dark = Color3.fromRGB(120, 70, 200)  },
    Pink   = { main = Color3.fromRGB(255, 120, 180), dark = Color3.fromRGB(200, 70, 130)  },
    Red    = { main = Color3.fromRGB(255, 100, 100), dark = Color3.fromRGB(200, 60, 60)   },
    Green  = { main = Color3.fromRGB(120, 230, 140), dark = Color3.fromRGB(70, 180, 90)   },
}

Hub.CurrentTheme = "Blue"
Hub.Accent       = Hub.Themes[Hub.CurrentTheme].main
Hub.AccentDark   = Hub.Themes[Hub.CurrentTheme].dark

Hub.Colors = {
    close       = Color3.fromRGB(220, 70, 70),
    bg          = Color3.fromRGB(14, 14, 18),
    panel       = Color3.fromRGB(22, 22, 28),
    panelInner  = Color3.fromRGB(18, 18, 24),
    btn         = Color3.fromRGB(30, 30, 38),
    btnHover    = Color3.fromRGB(40, 40, 50),
    btnActive   = Color3.fromRGB(50, 50, 68),
    text        = Color3.fromRGB(240, 240, 245),
    subtext     = Color3.fromRGB(140, 140, 155),
    edgeSize    = 6,
    cornerSize  = 16,
}

Hub.EspColors = {
    { name = "Theme",  color = nil },
    { name = "White",  color = Color3.fromRGB(255, 255, 255) },
    { name = "Red",    color = Color3.fromRGB(255, 70, 70) },
    { name = "Green",  color = Color3.fromRGB(70, 255, 100) },
    { name = "Blue",   color = Color3.fromRGB(70, 150, 255) },
    { name = "Yellow", color = Color3.fromRGB(255, 230, 80) },
    { name = "Pink",   color = Color3.fromRGB(255, 120, 200) },
}

Hub.SkyboxAssets = {
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

-- Сохраняем дефолтный скайбокс
Hub.DefaultSkySettings = nil
do
    local existingSky = game:GetService("Lighting"):FindFirstChildOfClass("Sky")
    if existingSky then
        Hub.DefaultSkySettings = {
            Bk = existingSky.SkyboxBk,
            Dn = existingSky.SkyboxDn,
            Ft = existingSky.SkyboxFt,
            Lf = existingSky.SkyboxLf,
            Rt = existingSky.SkyboxRt,
            Up = existingSky.SkyboxUp,
        }
    end
end

-- Общее состояние
Hub.State = {
    activeTabName = "Visuals",
    tabButtons    = {},
    sections      = {},
    themeButtons  = {},
    themeTargets  = {},
    connections   = {},
    openDropdowns = {},
    ignoreGlobalClickUntil = 0,
    menuOpen      = true,
}

function Hub.addConn(c)
    table.insert(Hub.State.connections, c)
    return c
end

function Hub.showToast(title, subtitle)
    if Hub.UI and Hub.UI.showToast then
        Hub.UI.showToast(title, subtitle)
    end
end

function Hub.log(msg)
    print("[Rofl Hub] " .. tostring(msg))
end

Hub.log("config.lua loaded")
