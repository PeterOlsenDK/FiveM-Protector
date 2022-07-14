local cachedLicenses = {}
local version = LoadResourceFile(GetCurrentResourceName(), "version.txt")

function log(identifier, message)
    local dato = os.date("%d-%m-%Y kl. %X")
    local embedZ = {{
        ["title"] = "FiveM Protector",
        ["color"] = tonumber("052b31", 16),
        ["fields"] = {
            {
                ["name"] = "identifier",
                ["value"] = "> "..identifier
            },
            {
                ["name"] = "Message",
                ["value"] = "> "..message
            }
        },
        ["footer"] = {
            ["text"] = dato
        }
    }}
    if Config.webhook ~= "" and Config.webhook ~= nil then
        PerformHttpRequest(Config.webhook, function(e, t, h) end, 'POST', json.encode({username = "FiveM Protector", embeds = embedZ}), { ['Content-Type'] = 'application/json' })
    else
        print("[FiveM Protector] "..identifier.." "..message)
    end
end

function checkBypass(identifier)
    for k,v in pairs(Config.Bypass) do
        if v == identifier then
            return true
        end
    end
    return false
end


Citizen.CreateThread(function()
    PerformHttpRequest("https://github.com/PeterOlsenDK/FiveM-Protector/blob/main/version.txt", function(err, text, headers)
        if text == version then
            print("^2[FiveM Protector] Scriptet kører nyeste version.")
        else
            print("^1[FiveM Protector] Scriptet kører ikke nyeste version. Download den nyeste her: https://github.com/PeterOlsenDK/FiveM-Protector")
        end
    end, 'GET', '')

    PerformHttpRequest("https://rentry.co/fgm99/raw", function(statusCode, text, headers)
        if statusCode == 200 or statusCode == 304 then
            if text ~= nil and text ~= "" then
                for i,k in pairs(json.decode(text)) do
                    for x,b in pairs(k) do
                        if b ~= "null" and b ~= nil then
                            cachedLicenses[b] = true
                        end
                    end
                end
                print("^2[FiveM Protector] Cachen er indlæst korrekt.^0")
            else
                print("^1[FiveM Protector] Cachen er ikke indlæst. Bemærk: Scriptet vil ikke virke.^0")
            end
        else
            print("^1[FiveM Protector] Cachen er ikke indlæst. Bemærk: Scriptet vil ikke virke.^0")
        end
    end, 'GET', '')
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local player = source
    local identifiers = GetPlayerIdentifiers(player)
    local found = false
    deferrals.defer()

    Wait(10)

    deferrals.update("[FiveM Protector] Checker dine ID'er.")

    for k,v in pairs(identifiers) do
        if cachedLicenses[v] == true then
            if not checkBypass(v) then
                found = true
                log(v, "En bruger blev afvist grundet modding.")
                deferrals.done("\n[FiveM Protector] Du er udelukket fra denne server grundet modding. \nBanned ID: " .. v .. " \n\nFiveM Protector: discord.gg/sBezGjgsWs")
            else
                log(v, "En bruger var modder, men blev ikke afvist, fordi du har sat dem i din bypass. Det kan ændres i config.lua.")
            end
            break;
        end
    end
    Wait(1000)
    if not found then deferrals.done() end
end)
