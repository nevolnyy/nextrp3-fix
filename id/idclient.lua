-- Функция для отрисовки ID над головой игрока
addEventHandler("onClientRender", root, function()
    local x, y, z

    for _, player in ipairs(getElementsByType("player")) do
        local id = getElementData(player, "playerId")

        if id then
            x, y, z = getElementPosition(player)
            z = z + 1.0

            local sx, sy = getScreenFromWorldPosition(x, y, z)

            if sx and sy then
                dxDrawText("ID: " .. id, sx, sy, sx, sy, tocolor(255, 255, 255), 1.5, "default-bold", "center", "center")
            end
        end
    end

    -- Отрисовка ID в левом верхнем углу экрана
    local id = getElementData(localPlayer, "playerId")

    if id then
        dxDrawText("Your ID: " .. id, 10, 10, 200, 30, tocolor(255, 255, 255), 1.5, "default-bold", "left", "top")
    end
end)

-- Получение ID от сервера
addEvent("onClientReceiveId", true)
addEventHandler("onClientReceiveId", root, function(id)
    setElementData(localPlayer, "playerId", id)
end)

