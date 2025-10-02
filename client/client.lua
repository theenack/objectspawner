local PlacingObjEnt, PlacingObjModel, PlacingObjLabel, PlacingObjDist, PlacingSnapToGround = nil, nil, nil, nil, false
local PlacedObjects = {}
local rotType = "yaw"

local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    for k,v in pairs(PlacedObjects) do
        if v.IsRendered then
            DeleteObject(v.object)
            DeleteEntity(v.object)
            SetEntityAsNoLongerNeeded(v.object)
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    local coords = GetEntityCoords(PlayerPedId())
	ClearAreaOfObjects(coords.x, coords.y, coords.z, 10.0, 1)

    LoadPlacedObjects()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    LoadPlacedObjects()
end)

function LoadPlacedObjects()
    QBCore.Functions.TriggerCallback("ObjSpawner:CB:GetObjects", function(objects)
        PlacedObjects = objects
    end)
end

RegisterNetEvent("ObjSpawner:Client:OpenMenu", function()
    OpenMenu()
end)

function OpenMenu()
    SetNuiFocus(true, true)
    SendNUIMessage({ type = "OpenUI" })
end

RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback("CreateObject", function(data, cb)
    -- // Check if the object is valid first
    if not SpawnableObjs[data.model] then QBCore.Functions.Notify("Invalid Model!", "error") return end

    QBCore.Functions.LoadModel(data.model)

    PlacingObjModel = data.model
    PlacingObjLabel = data.label
    PlacingObjDist = data.distance

    local coords = GetEntityCoords(PlayerPedId())
    PlacingObjEnt = CreateObject(data.model, coords.x, coords.y, coords.z, 0, 0, 0)
    FreezeEntityPosition(PlacingObjEnt, true)
    SetEntityCollision(PlacingObjEnt, false, true)
    SetCanClimbOnEntity(PlacingObjEnt, false)
    SetEntityAlpha(PlacingObjEnt, 0.4)
end)

-- // Place Object Thread
CreateThread(function()
    while true do
        local SLEEP = 500
        if PlacingObjEnt then
            SLEEP = 0

            DisableControlAction(1, 24, 1) -- // Left Mouse (Attack)
            DisableControlAction(1, 25, 1) -- // Right Mouse (Aim)
            DisableControlAction(1, 74, 1) -- // H

            local coords = ScreenToCoords()
            SetEntityCoords(PlacingObjEnt, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0)

            if PlacingSnapToGround then
                PlaceObjectOnGroundProperly(PlacingObjEnt)
            end

            if IsControlJustReleased(1, 246) then -- // Y key
                if rotType == "pitch" then
                    rotType = "roll"
                elseif rotType == "roll" then
                    rotType = "yaw"
                elseif rotType == "yaw" then
                    rotType = "pitch"
                end

                QBCore.Functions.Notify("Rotation Mode Set: " .. rotType, "primary")
            end

            if IsControlJustReleased(1, 14) then -- // Scroll Down
                local currRot = GetEntityRotation(PlacingObjEnt)

                if IsControlPressed(1, 21) then
                    if rotType == "pitch" then SetEntityRotation(PlacingObjEnt, currRot.x + 1.5, currRot.y, currRot.z) end
                    if rotType == "roll" then SetEntityRotation(PlacingObjEnt, currRot.x, currRot.y + 1.5, currRot.z) end
                    if rotType == "yaw" then SetEntityRotation(PlacingObjEnt, currRot.x, currRot.y, currRot.z + 1.5) end
                else
                    if rotType == "pitch" then SetEntityRotation(PlacingObjEnt, currRot.x + 4.0, currRot.y, currRot.z) end
                    if rotType == "roll" then SetEntityRotation(PlacingObjEnt, currRot.x, currRot.y + 4.0, currRot.z) end
                    if rotType == "yaw" then SetEntityRotation(PlacingObjEnt, currRot.x, currRot.y, currRot.z + 4.0) end
                end
            end
            
            if IsControlJustReleased(1, 15) then -- // Scroll Up
                local currRot = GetEntityRotation(PlacingObjEnt)

                if IsControlPressed(1, 21) then
                    if rotType == "pitch" then SetEntityRotation(PlacingObjEnt, currRot.x - 1.5, currRot.y, currRot.z) end
                    if rotType == "roll" then SetEntityRotation(PlacingObjEnt, currRot.x, currRot.y - 1.5, currRot.z) end
                    if rotType == "yaw" then SetEntityRotation(PlacingObjEnt, currRot.x, currRot.y, currRot.z - 1.5) end
                else
                    if rotType == "pitch" then SetEntityRotation(PlacingObjEnt, currRot.x - 4.0, currRot.y, currRot.z) end
                    if rotType == "roll" then SetEntityRotation(PlacingObjEnt, currRot.x, currRot.y - 4.0, currRot.z) end
                    if rotType == "yaw" then SetEntityRotation(PlacingObjEnt, currRot.x, currRot.y, currRot.z - 4.0) end
                end
            end

            -- // Left Click
            if IsDisabledControlJustPressed(1, 24) then
                -- // We do this so we stop the thread from continuing
                local cacheObj = PlacingObjEnt
                local coords = GetEntityCoords(PlacingObjEnt)
                local rot = GetEntityRotation(PlacingObjEnt)
                PlacingObjEnt = nil

                TriggerServerEvent("ObjSpawner:Server:PlaceObject", PlacingObjModel, PlacingObjLabel, PlacingObjDist, coords, rot, PlacingSnapToGround)

                DeleteObject(cacheObj)
                DeleteEntity(cacheObj)
                SetEntityAsNoLongerNeeded(cacheObj)
                PlacingObjEnt = nil
                PlacingObjModel = nil
                PlacingObjLabel = nil
                PlacingObjDist = nil
                cacheObj = nil
            end

            -- // Right Click
            if IsDisabledControlJustPressed(1, 25) then
                PlacingObjEnt = nil
                PlacingObjModel = nil
                PlacingObjLabel = nil
                PlacingObjDist = nil
                DeleteObject(PlacingObjEnt)
                DeleteEntity(PlacingObjEnt)
                SetEntityAsNoLongerNeeded(PlacingObjEnt)
            end

            -- // H (Snap to Ground)
            if IsDisabledControlJustPressed(1, 74) then
                PlacingSnapToGround = not PlacingSnapToGround
            end
        end
        Wait(SLEEP)
    end
end)

function ScreenToCoords()
    local Cam = GetGameplayCamCoord()
    local handle
    handle = StartExpensiveSynchronousShapeTestLosProbe(Cam, GetCoordsFromCam(10.0, Cam), -1, PlayerPedId(), 4)
    local _, Hit, Coords, _, Entity = GetShapeTestResult(handle)
    return Coords
end

function GetCoordsFromCam(distance, coords)
    local rotation = GetGameplayCamRot()
    local adjustedRotation = vector3((math.pi / 180) * rotation.x, (math.pi / 180) * rotation.y, (math.pi / 180) * rotation.z)
    local direction = vector3(-math.sin(adjustedRotation[3]) * math.abs(math.cos(adjustedRotation[1])), math.cos(adjustedRotation[3]) * math.abs(math.cos(adjustedRotation[1])), math.sin(adjustedRotation[1]))
    return vector3(coords[1] + direction[1] * distance, coords[2] + direction[2] * distance, coords[3] + direction[3] * distance)
end

RegisterNetEvent("ObjSpawner:Client:UpdatePlacedObjects", function(objects)
    PlacedObjects = objects
end)

function SpawnPlacedObject(model, label, dist, coords, heading, snaptoground)
    if #(GetEntityCoords(PlayerPedId()) - vector3(coords.x, coords.y, coords.z)) <= dist then
        QBCore.Functions.LoadModel(model)
        local obj = CreateObject(model, coords.x, coords.y, coords.z, 0, 0, 0)
        FreezeEntityPosition(obj, true)
        SetEntityRotation(obj, heading.x, heading.y, heading.z)

        if snaptoground then
            PlaceObjectOnGroundProperly(obj)
        end

        return obj
    end
end

CreateThread(function()
    while true do
        Wait(3000)

        for k,v in pairs(PlacedObjects) do
            local dist = #(GetEntityCoords(PlayerPedId()) - vector3(v.coords.x, v.coords.y, v.coords.z))
            if not v.IsRendered and dist <= v.dist then
                local obj = SpawnPlacedObject(v.model, v.label, v.dist, v.coords, v.heading, v.snaptoground)
                v.obj = obj
                v.IsRendered = true
            elseif v.IsRendered and dist > v.dist then
                DeleteObject(v.obj)
                DeleteEntity(v.obj)
                SetEntityAsNoLongerNeeded(v.obj)
                v.obj = nil
                v.IsRendered = false
            end
        end
    end
end)

RegisterNUICallback("GetPlacedObjects", function(data, cb)
    QBCore.Functions.TriggerCallback("ObjSpawner:CB:GetObjects", function(objects)
        cb(objects)
    end)
end)

RegisterNUICallback("DeleteObject", function(data, cb)
    QBCore.Functions.TriggerCallback("ObjSpawner:CB:DeleteObject", function()
        cb("ok")
    end, data.uuid)
end)

RegisterNetEvent("ObjSpawner:Client:DeletedObj", function(uuid)
    -- // Get the Objects data
    local objData = nil
    for k,v in pairs(PlacedObjects) do
        if v.uuid == uuid then
            objData = v
            break
        end
    end

    -- // Check if we're close to the object
    if #(GetEntityCoords(PlayerPedId()) - vector3(objData.coords.x, objData.coords.y, objData.coords.z)) <= objData.dist then
        DeleteObject(objData.obj)
        DeleteEntity(objData.obj)
        SetEntityAsNoLongerNeeded(objData.obj)
    end
end)