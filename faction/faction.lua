-- Определение таблицы фракций
local factions = {
    ["city_mayor"] = {
        name = "Мэрия города",
        members = {},
        leader = nil
    }
}

-- Функция для получения игрока по ID
function getPlayerFromId(id)
    for _, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "playerId") == id then
            return player
        end
    end
    return nil
end

-- Функция для отправки данных о фракции клиентам
function sendFactionDataToClient(player)
    local playerFactionId = getElementData(player, "faction")
    if playerFactionId and factions[playerFactionId] then
        local faction = factions[playerFactionId]
        local membersData = {}
        for member, _ in pairs(faction.members) do
            table.insert(membersData, { id = getElementData(member, "playerId"), name = getPlayerName(member) })
        end
        triggerClientEvent(player, "receiveFactionData", resourceRoot, membersData, faction.leader == player)
    end
end

-- Команда для добавления игрока во фракцию или удаления из фракции
addCommandHandler("set_player_faction",
    function(player, command, playerId, factionId)
        local targetPlayer = getPlayerFromId(tonumber(playerId))
        if targetPlayer then
            if factionId then
                if factions[factionId] then
                    factions[factionId].members[targetPlayer] = true
                    setElementData(targetPlayer, "faction", factionId)
                    outputChatBox("Игрок добавлен во фракцию " .. factions[factionId].name, player)
                    sendFactionDataToClient(targetPlayer)
                else
                    outputChatBox("Фракция с ID " .. factionId .. " не найдена.", player)
                end
            else
                local currentFactionId = getElementData(targetPlayer, "faction")
                if currentFactionId then
                    factions[currentFactionId].members[targetPlayer] = nil
                    setElementData(targetPlayer, "faction", nil)
                    outputChatBox("Игрок удален из фракции " .. factions[currentFactionId].name, player)
                    sendFactionDataToClient(targetPlayer)
                else
                    outputChatBox("Игрок не состоит в фракции.", player)
                end
            end
        else
            outputChatBox("Игрок с ID " .. playerId .. " не найден.", player)
        end
    end
)

-- Команда для назначения лидера фракции
addCommandHandler("set_player_faction_leader",
    function(player, command, playerId, factionId)
        local targetPlayer = getPlayerFromId(tonumber(playerId))
        if targetPlayer and factions[factionId] then
            local oldLeader = factions[factionId].leader
            if oldLeader then
                factions[factionId].members[oldLeader] = nil -- Удаление предыдущего лидера из списка членов
            end
            factions[factionId].leader = targetPlayer
            factions[factionId].members[targetPlayer] = true -- Добавление нового лидера в члены фракции
            setElementData(targetPlayer, "faction", factionId)
            if oldLeader then
                setElementData(oldLeader, "faction", nil)
            end
            outputChatBox("Игрок назначен лидером фракции " .. factions[factionId].name, player)
            sendFactionDataToClient(targetPlayer)
        else
            outputChatBox("Игрок или фракция не найдены.", player)
        end
    end
)

-- Обработчик события увольнения члена фракции
addEvent("fireFactionMember", true)
addEventHandler("fireFactionMember", resourceRoot, function(targetPlayerId)
    local targetPlayer = getPlayerFromId(targetPlayerId)
    local playerFactionId = getElementData(client, "faction")
    if targetPlayer and playerFactionId and factions[playerFactionId] then
        factions[playerFactionId].members[targetPlayer] = nil
        setElementData(targetPlayer, "faction", nil)
        outputChatBox("Игрок удален из фракции " .. factions[playerFactionId].name, client)
        sendFactionDataToClient(client)
    end
end)

-- Обработчик события приглашения члена фракции
addEvent("inviteFactionMember", true)
addEventHandler("inviteFactionMember", resourceRoot, function(targetPlayerId)
    local targetPlayer = getPlayerFromId(targetPlayerId)
    local playerFactionId = getElementData(client, "faction")
    if targetPlayer and playerFactionId and factions[playerFactionId] then
        triggerClientEvent(targetPlayer, "showInvite", resourceRoot, getPlayerName(client), factions[playerFactionId].name)
    end
end)

-- Обработчик события принятия приглашения во фракцию
addEvent("acceptFactionInvite", true)
addEventHandler("acceptFactionInvite", resourceRoot, function()
    local playerFactionId = getElementData(client, "faction")
    if playerFactionId and factions[playerFactionId] then
        factions[playerFactionId].members[client] = true
        setElementData(client, "faction", playerFactionId)
        outputChatBox("Вы приняли приглашение во фракцию " .. factions[playerFactionId].name, client)
        sendFactionDataToClient(client)
    end
end)

-- Очистка фракции при выходе игрока
addEventHandler("onPlayerQuit", root, function()
    local playerFactionId = getElementData(source, "faction")
    if playerFactionId and factions[playerFactionId] then
        local faction = factions[playerFactionId]
        if faction.leader == source then
            faction.leader = nil
            outputChatBox("Лидер фракции " .. faction.name .. " покинул сервер.", root)
        end
        faction.members[source] = nil
        setElementData(source, "faction", nil)
        sendFactionDataToClient(source)
    end
end)

