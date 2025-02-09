-- Function to load a model with error handling
function loadModel(model)
    if not IsModelInCdimage(model) then
        print("Modelis nerastas: " .. model)
        return false
    end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000 -- 5 sekundės
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(1)
    end
    if not HasModelLoaded(model) then
        print("Nepavyko užkrauti modelio: " .. model)
        return false
    end
    return true
end

-- Function to spawn NPC at given coordinates
function spawnNPC(x, y, z, h)
    local model = GetHashKey("a_m_m_business_01") -- Change to desired NPC model
    if not loadModel(model) then return end

    local npc = CreatePed(4, model, x, y, z, h, 0.0, false, true)
    SetEntityAsMissionEntity(npc, true, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetModelAsNoLongerNeeded(model)
end

-- Create blips for rental locations
for _, location in ipairs(Config.RentalLocations) do
    local blip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(blip, 226) -- Change to desired blip icon
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 3) -- Change to desired blip color
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Dviračių nuoma")
    EndTextCommandSetBlipName(blip)
end

-- Spawn NPCs at rental locations
for _, location in ipairs(Config.RentalLocations) do
    spawnNPC(location.x, location.y, location.z, location.h)
end

-- Add ox_target for rental locations
for _, location in ipairs(Config.RentalLocations) do
    exports.ox_target:addBoxZone({
        coords = vector3(location.x, location.y, location.z + 1),
        size = vector3(1, 1, 2),
        rotation = 0,
        debugPoly = false,
        options = {
            {
                name = 'rent_bikes',
                icon = 'fas fa-bicycle',
                label = 'Išsinuomoti dviratį',
                onSelect = function()
                    lib.showContext('walker_bikerental')
                end
            }
        }
    })
end

-- Function to find the closest bike spawn location
function getClosestBikeSpawn(playerCoords)
    local closestDistance = -1
    local closestCoords = nil

    for _, coords in ipairs(Config.bikespawncords) do
        local distance = #(vector3(coords.x, coords.y, coords.z) - playerCoords)
        if closestDistance == -1 or distance < closestDistance then
            closestDistance = distance
            closestCoords = coords
        end
    end

    return closestCoords
end

-- Function to spawn a bike at the closest location
function spawnBikeAtClosestLocation(playerCoords)
    -- Check if player already has a bike
    if currentBike and DoesEntityExist(currentBike) then
        lib.notify({ title = 'Jūs jau turite išsinuomotą dviratį!', type = 'error' }) -- Add notification
        return
    end

    local closestCoords = getClosestBikeSpawn(playerCoords)
    if not closestCoords then
        lib.notify({ title = 'Nerasta dviračių nuomos vietų', type = 'error' })
        return
    end

    local model = GetHashKey(Config.BikeModels)
    if not loadModel(model) then return end

    -- Create and track the bike
    currentBike = CreateVehicle(model, closestCoords.x, closestCoords.y, closestCoords.z, closestCoords.h, true, false)
    SetModelAsNoLongerNeeded(model)

    -- Seat player on the bike
    local playerPed = PlayerPedId()
    TaskWarpPedIntoVehicle(playerPed, currentBike, -1)

    lib.notify({ title = 'Dviratis sėkmingai išnuomotas!', type = 'success' })
end

-- Register UI context for bike rental
lib.registerContext({
    id = 'walker_bikerental',
    title = 'Dviračių nuoma',
    options = {
        {
            title = 'Išsinuomoti dviratį',
            description = 'Spauskite, kad išsinuomotumėte dviratį.',
            icon = 'fas fa-bicycle',
            event = 'walker_bikerental:spawnBike',
            arrow = false,
        }
    }
})

-- Event to spawn a bike
RegisterNetEvent('walker_bikerental:spawnBike')
AddEventHandler('walker_bikerental:spawnBike', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    spawnBikeAtClosestLocation(playerCoords)
end)