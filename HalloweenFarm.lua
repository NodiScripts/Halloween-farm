local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local player = Players.LocalPlayer
local playerGui = player:WaitForChild('PlayerGui')
local repeatDelay = 0.05
local core = workspace.__REMOTES.Core
local remote = workspace.__REMOTES.Game.Coins
local coins = workspace.__THINGS.Coins
local old = playerGui:FindFirstChild('AutoMineGui')
if old then old:Destroy() end
local enabled, alive = false, true
local selectedMode = 'Halloween4'
local modes = {
    {key = 'Halloween4', label = 'Halloween 4'},
    {key = 'Halloween5', label = 'H5 Castle Chest'},
    {key = 'GiantPumpkin', label = 'Giant Pumpkin'}
}
local gui = Instance.new('ScreenGui')
gui.Name = 'AutoMineGui'
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui
local frame = Instance.new('Frame')
frame.Size = UDim2.fromOffset(310, 385)
frame.Position = UDim2.new(0.5, -155, 0.5, -192)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.BorderSizePixel = 0
frame.Parent = gui
local function round(object, radius)
    local c = Instance.new('UICorner')
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = object
end
round(frame, 10)
local title = Instance.new('TextLabel')
title.Size = UDim2.new(1, 0, 0, 38)
title.BackgroundTransparency = 1
title.Text = 'Halloween Farm - drag to move'
title.TextColor3 = Color3.fromRGB(235, 235, 235)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Active = true
title.Parent = frame
local function button(text, position, size)
    local b = Instance.new('TextButton')
    b.Position = position
    b.Size = size
    b.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Parent = frame
    round(b, 8)
    return b
end
local buttons = {}
local function updateModes()
    for key, b in pairs(buttons) do
        b.BackgroundColor3 = selectedMode == key and Color3.fromRGB(155, 85, 30) or Color3.fromRGB(55, 55, 65)
    end
end
for i, mode in ipairs(modes) do
    local key = mode.key
    local position, size
    if i == 3 then
        position = UDim2.fromOffset(12, 92)
        size = UDim2.new(1, -24, 0, 40)
    else
        position = i == 1 and UDim2.fromOffset(12, 42) or UDim2.new(0.5, 6, 0, 42)
        size = UDim2.new(0.5, -18, 0, 40)
    end
    local b = button(mode.label, position, size)
    buttons[key] = b
    b.Activated:Connect(function() selectedMode = key; updateModes() end)
end
updateModes()
local toggle = button('OFF', UDim2.fromOffset(12, 142), UDim2.new(1, -24, 0, 42))
toggle.TextSize = 20
toggle.BackgroundColor3 = Color3.fromRGB(180, 55, 55)
toggle.Activated:Connect(function()
    enabled = not enabled
    toggle.Text = enabled and 'ON' or 'OFF'
    toggle.BackgroundColor3 = enabled and Color3.fromRGB(45, 165, 85) or Color3.fromRGB(180, 55, 55)
end)
local status = Instance.new('TextLabel')
status.Position = UDim2.fromOffset(12, 190)
status.Size = UDim2.new(1, -24, 0, 44)
status.BackgroundTransparency = 1
status.Text = 'Loading equipped pets...'
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextWrapped = true
status.Parent = frame
local petList = Instance.new('ScrollingFrame')
petList.Position = UDim2.fromOffset(12, 240)
petList.Size = UDim2.new(1, -24, 1, -252)
petList.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
petList.BorderSizePixel = 0
petList.ScrollBarThickness = 4
petList.CanvasSize = UDim2.fromOffset(0, 0)
petList.Parent = frame
round(petList, 6)
local listText = Instance.new('TextLabel')
listText.Position = UDim2.fromOffset(8, 6)
listText.Size = UDim2.new(1, -16, 0, 0)
listText.BackgroundTransparency = 1
listText.Text = ''
listText.TextColor3 = Color3.fromRGB(160, 235, 175)
listText.Font = Enum.Font.Code
listText.TextSize = 13
listText.TextXAlignment = Enum.TextXAlignment.Left
listText.TextYAlignment = Enum.TextYAlignment.Top
listText.Parent = petList
local dragging = false
local dragInput, dragStart, startPosition, dragEndConnection
title.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    dragging = true
    dragStart = input.Position
    startPosition = frame.Position
    if input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    if dragEndConnection then dragEndConnection:Disconnect() end
    dragEndConnection = input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then dragging = false end
    end)
end)
title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
local movementConnection = UIS.InputChanged:Connect(function(input)
    if not alive or not dragging or input ~= dragInput then return end
    local d = input.Position - dragStart
    frame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + d.X, startPosition.Y.Scale, startPosition.Y.Offset + d.Y)
end)
gui.Destroying:Connect(function()
    alive = false
    enabled = false
    movementConnection:Disconnect()
    if dragEndConnection then dragEndConnection:Disconnect() end
end)
local function getEquippedPets(save)
    local pets = {}
    for _, p in pairs(save.Pets or {}) do
        if p.e == true and p.id ~= nil and tonumber(p.l) and tonumber(p.xp) then table.insert(pets, p) end
    end
    table.sort(pets, function(a, b) return tostring(a.id) < tostring(b.id) end)
    return pets
end
local function updatePetList(pets)
    local lines = {}
    for _, p in ipairs(pets) do
        table.insert(lines, 'ID: ' .. tostring(p.id))
        table.insert(lines, 'Level: ' .. tostring(p.l))
        table.insert(lines, '')
    end
    if #pets == 0 then lines = {'No equipped pets found.'} end
    listText.Text = table.concat(lines, '\n')
    local height = math.max(24, #lines * 17)
    listText.Size = UDim2.new(1, -16, 0, height)
    petList.CanvasSize = UDim2.fromOffset(0, height + 12)
end
local function calc(level)
    return level < 0 and -3 or ((level - 1) * 2 * (level + 1))
end
local function matchesTarget(coin, mode)
    if not coin:IsA('BasePart') then return false end
    local name = coin:FindFirstChild('CoinName')
    if not name or not name:IsA('StringValue') then return false end
    if mode == 'GiantPumpkin' then return name.Value == 'Halloween1 Pumpkin' end
    if mode == 'Halloween5' then return name.Value == 'Halloween5 Castle Chest' end
    if mode == 'Halloween4' then
        local prefix = 'Halloween4'
        return name.Value:sub(1, #prefix) == prefix
    end
    return false
end
local function findCoin(mode)
    for _, coin in ipairs(coins:GetChildren()) do
        if matchesTarget(coin, mode) then return coin end
    end
end
local function modeLabel(key)
    for _, mode in ipairs(modes) do
        if mode.key == key then return mode.label end
    end
    return key
end
local function runCycle()
    local save = core['Get Stats']:InvokeServer().Save
    if not alive then return end
    local pets = getEquippedPets(save)
    updatePetList(pets)
    local mode = selectedMode
    local label = modeLabel(mode)
    if not enabled then status.Text = 'OFF | ' .. label .. '\nEquipped pets: ' .. #pets; return end
    if #pets == 0 then status.Text = 'ON | No equipped pets found'; return end
    local coin = findCoin(mode)
    if not coin then status.Text = 'ON | Waiting for ' .. label; return end
    local passes = save.Gamepasses or {}
    local b = table.find(passes, 4918550) and 2 or 1
    local v = table.find(passes, 4918538) and 1.5 or 1
    local sent = 0
    for _, pet in ipairs(pets) do
        if not alive or not enabled or selectedMode ~= mode or coin.Parent ~= coins then break end
        local targetLevel = tonumber(pet.l) + 1
        local amount = ((calc(targetLevel) - tonumber(pet.xp)) * 10) / (b * v)
        if amount > 0 then
            remote:FireServer('Mine', coin.Name, amount, pet.id)
            sent = sent + 1
        end
    end
    if not alive then return end
    if enabled and selectedMode == mode and sent > 0 and coin.Parent == coins then
        local character = player.Character
        if character then character:MoveTo(coin.Position) end
    end
    status.Text = enabled and ('ON | ' .. modeLabel(selectedMode) .. '\nEquipped: ' .. #pets .. ' | Sent: ' .. sent) or ('OFF | Equipped pets: ' .. #pets)
end
task.spawn(function()
    while alive do
        local success, err = pcall(runCycle)
        if not success and alive then status.Text = 'Error - check console'; warn('Auto Mine:', err) end
        task.wait(repeatDelay)
    end
end)
