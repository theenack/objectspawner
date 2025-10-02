local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add("objectmenu", "Opens the Object Spawn menu", {}, false, function(source, args)
    local src = source
    TriggerClientEvent("ObjSpawner:Client:OpenMenu", src)
end, "admin")

RegisterNetEvent("ObjSpawner:Server:PlaceObject", function(model, label, dist, coords, heading, snaptoground)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local loadFile = LoadResourceFile(GetCurrentResourceName(), "./placedobjects.json")
    local data = json.decode(loadFile)

    if not data then data = {} end

    data[#data + 1] = {
        model = model,
        label = label,
        dist = dist,
        coords = coords,
        heading = heading,
        snaptoground = snaptoground,
        uuid = GenUUID(),
    }

    SaveResourceFile(GetCurrentResourceName(), "./placedobjects.json", json.encode(data), -1)

    file = io.open( './LOGS/placedobjects.txt', "a")
    if file then
        file:write("[" .. os.date("%m/%d/%Y %I:%M:%S %p ") .. "] - " .. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. " [" .. Player.PlayerData.citizenid .. "] Placed a " .. model .. " at " .. coords)
        file:write("\n")
        file:close()
    end

    TriggerClientEvent("ObjSpawner:Client:UpdatePlacedObjects", -1, data)
end)

QBCore.Functions.CreateCallback("ObjSpawner:CB:GetObjects", function(source, cb)
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "./placedobjects.json")
    local data = json.decode(loadFile)

    cb(data)
end)

QBCore.Functions.CreateCallback("ObjSpawner:CB:DeleteObject", function(source, cb, uuid)
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "./placedobjects.json")
    local data = json.decode(loadFile)

    for k,v in pairs(data) do
        if v.uuid == uuid then
            data[k] = nil
        end
    end

    TriggerClientEvent("ObjSpawner:Client:DeletedObj", -1, uuid)

    -- // Rebuild the table so we don't fuck ourselves
    local rebuild = {}
    for k,v in pairs(data) do
        rebuild[#rebuild + 1] = v
    end

    SaveResourceFile(GetCurrentResourceName(), "./placedobjects.json", json.encode(rebuild), -1)

    TriggerClientEvent("ObjSpawner:Client:UpdatePlacedObjects", -1, rebuild)

    cb("ok")
end)

function GenUUID()
    local template ='obj-xxxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end