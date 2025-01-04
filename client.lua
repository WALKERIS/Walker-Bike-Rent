-- client.lua



-- Function to spawn NPC at given coordinates
function spawnNPC(x, y, z, h)
    local model = GetHashKey("a_m_m_business_01") -- Change to desired NPC model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end

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
        coords = vector3(location.x, location.y, location.z+1),
        size = vector3(1, 1, 2),
        rotation = 0,
        debugPoly = false,
        options = {
            {
                name = 'rent_bikes',
                icon = 'fas fa-bicycle',
                label = 'Rent a Bike',
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
    local closestCoords = getClosestBikeSpawn(playerCoords)
    if closestCoords then
        local model = GetHashKey(Config.BikeModels) -- Change to desired bike model
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end

        local bike = CreateVehicle(model, closestCoords.x, closestCoords.y, closestCoords.z, closestCoords.h, 0.0, true, false)
        SetModelAsNoLongerNeeded(model)

        -- Seat player on the bike
        local playerPed = PlayerPedId()
        TaskWarpPedIntoVehicle(playerPed, bike, -1)

        print("Bike spawned at closest location and player seated!")
    else
        print("No bike spawn locations available.")
    end
end

-- Example usage: spawn bike at closest location to player's current position
local sumokejo = false
lib.registerContext({
    id = 'walker_bikerental',
    title = 'Bike rental',
    options = {
      {
        title = 'Bike Rental',
        description = 'Bike rental options',
        icon = 'check',
        event = 'walker_bikerental:spawnBike',
        arrow = false,
      }
    }
  })


RegisterNetEvent('walker_bikerental:spawnBike')
AddEventHandler('walker_bikerental:spawnBike', function()
local playerPed = PlayerPedId()
local playerCoords = GetEntityCoords(playerPed)
spawnBikeAtClosestLocation(playerCoords)
end)
