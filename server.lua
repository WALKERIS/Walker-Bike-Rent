-- Event to handle bike spawning on the server side
RegisterNetEvent('walker_bikerental:serverSpawnBike')
AddEventHandler('walker_bikerental:serverSpawnBike', function(coords)
    local src = source
    local model = GetHashKey(Config.BikeModels)

    -- Ensure the model is valid
    if not IsModelInCdimage(model) then
        print("Netinkamas dviračio modelis.")
        return
    end

    -- Load the model
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end

    -- Create the bike as a networked entity
    local bike = CreateVehicle(model, coords.x, coords.y, coords.z, coords.h, true, false)
    local netId = NetworkGetNetworkIdFromEntity(bike)

    -- Set vehicle properties
    SetEntityAsMissionEntity(bike, true, true)
    SetVehicleNumberPlateText(bike, "RENTAL")
    SetVehicleOnGroundProperly(bike)
    SetModelAsNoLongerNeeded(model)

    -- Assign vehicle to the player
    TriggerClientEvent('walker_bikerental:clientPlaceOnBike', src, netId)
end)