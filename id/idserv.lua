playerIDD = {}

function generateIDD(player)
    local maxID = #playerIDD
    iprint(maxID)

    local newID = maxID + 1
    playerIDD[newID] = player

    setElementData(source, "playerId", playerId)

    triggerClientEvent(player, "onClientReceiveId", player, newID)

    return newID
end

function deletID(source)
    for index, player in pairs(playerIDD) do
        if player == source then
            playerIDD[index] = nil
            return
        end
    end
end

addEventHandler("onPlayerJoin", root, function()
    generateIDD(source)
end)

addEventHandler("onPlayerQuit", root, function()
    deletID(source)
end)


