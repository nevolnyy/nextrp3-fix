local factionPanel = {}
local isFactionPanelVisible = false

function createFactionPanel()
    factionPanel.window = guiCreateWindow(0.25, 0.25, 0.5, 0.5, "Панель фракции", true)
    guiWindowSetSizable(factionPanel.window, false)
    factionPanel.tabPanel = guiCreateTabPanel(0.02, 0.08, 0.96, 0.9, true, factionPanel.window)
    
    -- Вкладка "Список участников"
    factionPanel.membersTab = guiCreateTab("Список участников", factionPanel.tabPanel)
    factionPanel.membersGrid = guiCreateGridList(0.02, 0.05, 0.96, 0.7, true, factionPanel.membersTab)
    guiGridListAddColumn(factionPanel.membersGrid, "ID", 0.2)
    guiGridListAddColumn(factionPanel.membersGrid, "Имя игрока", 0.7)
    
    -- Кнопка "Уволить" для лидеров фракции
    factionPanel.fireButton = guiCreateButton(0.02, 0.78, 0.45, 0.1, "Уволить", true, factionPanel.membersTab)
    addEventHandler("onClientGUIClick", factionPanel.fireButton, onFireButtonClick, false)
    guiSetEnabled(factionPanel.fireButton, false)
    
    -- Поле ввода и кнопка "Пригласить" для лидеров фракции
    factionPanel.inviteEdit = guiCreateEdit(0.02, 0.9, 0.45, 0.05, "", true, factionPanel.membersTab)
    factionPanel.inviteButton = guiCreateButton(0.5, 0.9, 0.45, 0.05, "Пригласить", true, factionPanel.membersTab)
    addEventHandler("onClientGUIClick", factionPanel.inviteButton, onInviteButtonClick, false)
    guiSetEnabled(factionPanel.inviteEdit, false)
    guiSetEnabled(factionPanel.inviteButton, false)
    
    -- Вкладка "Управление городом" (для лидеров фракции)
    factionPanel.managementTab = guiCreateTab("Управление городом", factionPanel.tabPanel)
    factionPanel.managementLabel = guiCreateLabel(0.05, 0.1, 0.9, 0.1, "Управление городом", true, factionPanel.managementTab)
    
    guiSetVisible(factionPanel.window, false)
end
addEventHandler("onClientResourceStart", resourceRoot, createFactionPanel)

-- Функция для отображения/скрытия панели
function toggleFactionPanel(state)
    if state == nil then
        state = not isFactionPanelVisible
    end
    guiSetVisible(factionPanel.window, state)
    showCursor(state)
    isFactionPanelVisible = state
end

-- Функция для обновления списка участников
function updateFactionMembers(members)
    guiGridListClear(factionPanel.membersGrid)
    for _, member in ipairs(members) do
        local row = guiGridListAddRow(factionPanel.membersGrid)
        guiGridListSetItemText(factionPanel.membersGrid, row, 1, tostring(member.id), false, false)
        guiGridListSetItemText(factionPanel.membersGrid, row, 2, member.name, false, false)
    end
end

-- Функция для проверки является ли игрок лидером
function setFactionLeaderState(isLeader)
    guiSetEnabled(factionPanel.fireButton, isLeader)
    guiSetEnabled(factionPanel.inviteEdit, isLeader)
    guiSetEnabled(factionPanel.inviteButton, isLeader)
    guiSetEnabled(factionPanel.managementTab, isLeader)
end

-- Обработчик нажатия клавиши "P" для открытия/закрытия панели фракции
bindKey("p", "down", function()
    if getElementData(localPlayer, "faction") then
        if isFactionPanelVisible then
            toggleFactionPanel(false)
        else
            toggleFactionPanel(true)
            -- Здесь не нужно отправлять запрос на сервер, так как данные уже есть на клиенте
        end
    end
end)

-- Получение данных фракции с сервера
addEvent("receiveFactionData", true)
addEventHandler("receiveFactionData", resourceRoot, function(members, isLeader)
    updateFactionMembers(members)
    setFactionLeaderState(isLeader)
end)

-- Обработчик нажатия кнопки "Уволить"
function onFireButtonClick()
    local selectedRow, selectedCol = guiGridListGetSelectedItem(factionPanel.membersGrid)
    if selectedRow ~= -1 then
        local playerId = guiGridListGetItemText(factionPanel.membersGrid, selectedRow, 1)
        triggerServerEvent("fireFactionMember", localPlayer, tonumber(playerId))
    end
end

-- Обработчик нажатия кнопки "Пригласить"
function onInviteButtonClick()
    local playerId = guiGetText(factionPanel.inviteEdit)
    if playerId ~= "" then
        triggerServerEvent("inviteFactionMember", localPlayer, tonumber(playerId))
    end
end

-- Обработчик принятия приглашения
addEvent("showInvite", true)
addEventHandler("showInvite", root, function(inviterName, factionName)
    local inviteWindow = guiCreateWindow(0.4, 0.4, 0.2, 0.2, "Приглашение", true)
    guiCreateLabel(0.1, 0.3, 0.8, 0.2, inviterName .. " приглашает вас вступить в " .. factionName, true, inviteWindow)
    local acceptButton = guiCreateButton(0.1, 0.6, 0.35, 0.2, "Принять", true, inviteWindow)
    local declineButton = guiCreateButton(0.55, 0.6, 0.35, 0.2, "Отказаться", true, inviteWindow)

    addEventHandler("onClientGUIClick", acceptButton, function()
        triggerServerEvent("acceptFactionInvite", localPlayer)
        destroyElement(inviteWindow)
    end, false)

    addEventHandler("onClientGUIClick", declineButton, function()
        destroyElement(inviteWindow)
    end, false)
end)

