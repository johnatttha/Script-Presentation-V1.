-- (intentionally left blank to avoid comments)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local mainFolder = Instance.new("Folder")
mainFolder.Name = "RPGSystem"
mainFolder.Parent = ReplicatedStorage

local remoteFolder = Instance.new("Folder")
remoteFolder.Name = "Remotes"
remoteFolder.Parent = mainFolder

local statsFolder = Instance.new("Folder")
statsFolder.Name = "Stats"
statsFolder.Parent = mainFolder

local inventoryFolder = Instance.new("Folder")
inventoryFolder.Name = "InventoryData"
inventoryFolder.Parent = mainFolder

local questFolder = Instance.new("Folder")
questFolder.Name = "QuestData"
questFolder.Parent = mainFolder

local eventFolder = Instance.new("Folder")
eventFolder.Name = "Events"
eventFolder.Parent = mainFolder

local joinRemote = Instance.new("RemoteEvent")
joinRemote.Name = "JoinGame"
joinRemote.Parent = remoteFolder

local attackRemote = Instance.new("RemoteEvent")
attackRemote.Name = "Attack"
attackRemote.Parent = remoteFolder

local healRemote = Instance.new("RemoteEvent")
healRemote.Name = "Heal"
healRemote.Parent = remoteFolder

local questRemote = Instance.new("RemoteEvent")
questRemote.Name = "QuestUpdate"
questRemote.Parent = remoteFolder

local inventoryRemote = Instance.new("RemoteEvent")
inventoryRemote.Name = "InventoryUpdate"
inventoryRemote.Parent = remoteFolder

local levelRemote = Instance.new("RemoteEvent")
levelRemote.Name = "LevelUp"
levelRemote.Parent = remoteFolder

local zoneRemote = Instance.new("RemoteEvent")
zoneRemote.Name = "ZoneChange"
zoneRemote.Parent = remoteFolder

local uiRemote = Instance.new("RemoteEvent")
uiRemote.Name = "UIMessage"
uiRemote.Parent = remoteFolder

local function createStatFolder(player)
    local folder = Instance.new("Folder")
    folder.Name = player.UserId .. "_Stats"
    folder.Parent = statsFolder

    local level = Instance.new("IntValue")
    level.Name = "Level"
    level.Value = 1
    level.Parent = folder

    local exp = Instance.new("IntValue")
    exp.Name = "Experience"
    exp.Value = 0
    exp.Parent = folder

    local health = Instance.new("IntValue")
    health.Name = "Health"
    health.Value = 100
    health.Parent = folder

    local maxHealth = Instance.new("IntValue")
    maxHealth.Name = "MaxHealth"
    maxHealth.Value = 100
    maxHealth.Parent = folder

    local mana = Instance.new("IntValue")
    mana.Name = "Mana"
    mana.Value = 50
    mana.Parent = folder

    local maxMana = Instance.new("IntValue")
    maxMana.Name = "MaxMana"
    maxMana.Value = 50
    maxMana.Parent = folder

    local gold = Instance.new("IntValue")
    gold.Name = "Gold"
    gold.Value = 0
    gold.Parent = folder

    local zone = Instance.new("StringValue")
    zone.Name = "Zone"
    zone.Value = "Village"
    zone.Parent = folder

    local state = Instance.new("StringValue")
    state.Name = "State"
    state.Value = "Idle"
    state.Parent = folder

    return folder
end

local function createInventoryFolder(player)
    local folder = Instance.new("Folder")
    folder.Name = player.UserId .. "_Inventory"
    folder.Parent = inventoryFolder

    local weapon = Instance.new("StringValue")
    weapon.Name = "Weapon"
    weapon.Value = "WoodenSword"
    weapon.Parent = folder

    local armor = Instance.new("StringValue")
    armor.Name = "Armor"
    armor.Value = "ClothArmor"
    armor.Parent = folder

    local potionCount = Instance.new("IntValue")
    potionCount.Name = "HealthPotions"
    potionCount.Value = 3
    potionCount.Parent = folder

    local manaPotionCount = Instance.new("IntValue")
    manaPotionCount.Name = "ManaPotions"
    manaPotionCount.Value = 2
    manaPotionCount.Parent = folder

    local materials = Instance.new("IntValue")
    materials.Name = "Materials"
    materials.Value = 0
    materials.Parent = folder

    local keys = Instance.new("IntValue")
    keys.Name = "Keys"
    keys.Value = 0
    keys.Parent = folder

    return folder
end

local function createQuestFolder(player)
    local folder = Instance.new("Folder")
    folder.Name = player.UserId .. "_Quests"
    folder.Parent = questFolder

    local mainQuest = Instance.new("StringValue")
    mainQuest.Name = "MainQuest"
    mainQuest.Value = "Prologue"
    mainQuest.Parent = folder

    local sideQuest1 = Instance.new("StringValue")
    sideQuest1.Name = "SideQuest1"
    sideQuest1.Value = ""
    sideQuest1.Parent = folder

    local sideQuest2 = Instance.new("StringValue")
    sideQuest2.Name = "SideQuest2"
    sideQuest2.Value = ""
    sideQuest2.Parent = folder

    local completedQuests = Instance.new("IntValue")
    completedQuests.Name = "CompletedCount"
    completedQuests.Value = 0
    completedQuests.Parent = folder

    return folder
end

local function getStatFolder(player)
    return statsFolder:FindFirstChild(player.UserId .. "_Stats")
end

local function getInventoryFolder(player)
    return inventoryFolder:FindFirstChild(player.UserId .. "_Inventory")
end

local function getQuestFolder(player)
    return questFolder:FindFirstChild(player.UserId .. "_Quests")
end

local function addExperience(player, amount)
    local statFolder = getStatFolder(player)
    if not statFolder then
        statFolder = createStatFolder(player)
    end
    local exp = statFolder:FindFirstChild("Experience")
    local level = statFolder:FindFirstChild("Level")
    if exp and level then
        exp.Value = exp.Value + amount
        local required = level.Value * 100
        if exp.Value >= required then
            exp.Value = exp.Value - required
            level.Value = level.Value + 1
            levelRemote:FireClient(player, level.Value)
            local maxHealth = statFolder:FindFirstChild("MaxHealth")
            local maxMana = statFolder:FindFirstChild("MaxMana")
            local health = statFolder:FindFirstChild("Health")
            local mana = statFolder:FindFirstChild("Mana")
            if maxHealth and maxMana and health and mana then
                maxHealth.Value = maxHealth.Value + 10
                maxMana.Value = maxMana.Value + 5
                health.Value = maxHealth.Value
                mana.Value = maxMana.Value
            end
        end
    end
end

local function addGold(player, amount)
    local statFolder = getStatFolder(player)
    if not statFolder then
        statFolder = createStatFolder(player)
    end
    local gold = statFolder:FindFirstChild("Gold")
    if gold then
        gold.Value = gold.Value + amount
    end
end

local function changeZone(player, zoneName)
    local statFolder = getStatFolder(player)
    if not statFolder then
        statFolder = createStatFolder(player)
    end
    local zone = statFolder:FindFirstChild("Zone")
    if zone then
        zone.Value = zoneName
        zoneRemote:FireClient(player, zoneName)
    end
end

local function setState(player, stateName)
    local statFolder = getStatFolder(player)
    if not statFolder then
        statFolder = createStatFolder(player)
    end
    local state = statFolder:FindFirstChild("State")
    if state then
        state.Value = stateName
    end
end

local function useHealthPotion(player)
    local invFolder = getInventoryFolder(player)
    local statFolder = getStatFolder(player)
    if not invFolder or not statFolder then
        return
    end
    local potions = invFolder:FindFirstChild("HealthPotions")
    local health = statFolder:FindFirstChild("Health")
    local maxHealth = statFolder:FindFirstChild("MaxHealth")
    if potions and health and maxHealth then
        if potions.Value > 0 and health.Value < maxHealth.Value then
            potions.Value = potions.Value - 1
            health.Value = math.min(maxHealth.Value, health.Value + 50)
            healRemote:FireClient(player, "HealthPotion")
        end
    end
end

local function useManaPotion(player)
    local invFolder = getInventoryFolder(player)
    local statFolder = getStatFolder(player)
    if not invFolder or not statFolder then
        return
    end
    local potions = invFolder:FindFirstChild("ManaPotions")
    local mana = statFolder:FindFirstChild("Mana")
    local maxMana = statFolder:FindFirstChild("MaxMana")
    if potions and mana and maxMana then
        if potions.Value > 0 and mana.Value < maxMana.Value then
            potions.Value = potions.Value - 1
            mana.Value = math.min(maxMana.Value, mana.Value + 30)
            healRemote:FireClient(player, "ManaPotion")
        end
    end
end

local function damagePlayer(player, amount)
    local statFolder = getStatFolder(player)
    if not statFolder then
        return
    end
    local health = statFolder:FindFirstChild("Health")
    if health then
        health.Value = math.max(0, health.Value - amount)
        if health.Value <= 0 then
            setState(player, "Dead")
            uiRemote:FireClient(player, "You have been defeated.")
        end
    end
end

local function healPlayer(player, amount)
    local statFolder = getStatFolder(player)
    if not statFolder then
        return
    end
    local health = statFolder:FindFirstChild("Health")
    local maxHealth = statFolder:FindFirstChild("MaxHealth")
    if health and maxHealth then
        health.Value = math.min(maxHealth.Value, health.Value + amount)
    end
end

local function spendMana(player, amount)
    local statFolder = getStatFolder(player)
    if not statFolder then
        return false
    end
    local mana = statFolder:FindFirstChild("Mana")
    if mana then
        if mana.Value >= amount then
            mana.Value = mana.Value - amount
            return true
        end
    end
    return false
end

local function addMaterial(player, amount)
    local invFolder = getInventoryFolder(player)
    if not invFolder then
        invFolder = createInventoryFolder(player)
    end
    local materials = invFolder:FindFirstChild("Materials")
    if materials then
        materials.Value = materials.Value + amount
    end
end

local function addKey(player, amount)
    local invFolder = getInventoryFolder(player)
    if not invFolder then
        invFolder = createInventoryFolder(player)
    end
    local keys = invFolder:FindFirstChild("Keys")
    if keys then
        keys.Value = keys.Value + amount
    end
end

local function setWeapon(player, weaponName)
    local invFolder = getInventoryFolder(player)
    if not invFolder then
        invFolder = createInventoryFolder(player)
    end
    local weapon = invFolder:FindFirstChild("Weapon")
    if weapon then
        weapon.Value = weaponName
        inventoryRemote:FireClient(player, "Weapon", weaponName)
    end
end

local function setArmor(player, armorName)
    local invFolder = getInventoryFolder(player)
    if not invFolder then
        invFolder = createInventoryFolder(player)
    end
    local armor = invFolder:FindFirstChild("Armor")
    if armor then
        armor.Value = armorName
        inventoryRemote:FireClient(player, "Armor", armorName)
    end
end

local function startMainQuest(player, questName)
    local qFolder = getQuestFolder(player)
    if not qFolder then
        qFolder = createQuestFolder(player)
    end
    local mainQuest = qFolder:FindFirstChild("MainQuest")
    if mainQuest then
        mainQuest.Value = questName
        questRemote:FireClient(player, "MainQuest", questName)
    end
end

local function setSideQuest(player, index, questName)
    local qFolder = getQuestFolder(player)
    if not qFolder then
        qFolder = createQuestFolder(player)
    end
    local targetName = index == 1 and "SideQuest1" or "SideQuest2"
    local quest = qFolder:FindFirstChild(targetName)
    if quest then
        quest.Value = questName
        questRemote:FireClient(player, targetName, questName)
    end
end

local function completeQuest(player, questType)
    local qFolder = getQuestFolder(player)
    if not qFolder then
        qFolder = createQuestFolder(player)
    end
    local completed = qFolder:FindFirstChild("CompletedCount")
    if completed then
        completed.Value = completed.Value + 1
    end
    if questType == "Main" then
        local mainQuest = qFolder:FindFirstChild("MainQuest")
        if mainQuest then
            mainQuest.Value = ""
            questRemote:FireClient(player, "MainQuestComplete", completed.Value)
        end
    else
        local sideQuest1 = qFolder:FindFirstChild("SideQuest1")
        local sideQuest2 = qFolder:FindFirstChild("SideQuest2")
        if sideQuest1 and sideQuest1.Value ~= "" then
            sideQuest1.Value = ""
            questRemote:FireClient(player, "SideQuest1Complete", completed.Value)
        elseif sideQuest2 and sideQuest2.Value ~= "" then
            sideQuest2.Value = ""
            questRemote:FireClient(player, "SideQuest2Complete", completed.Value)
        end
    end
end

local function broadcastMessage(message)
    for _, player in ipairs(Players:GetPlayers()) do
        uiRemote:FireClient(player, message)
    end
end

local function createZoneLighting(zoneName)
    if zoneName == "Village" then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1000
    elseif zoneName == "Forest" then
        Lighting.Brightness = 1.5
        Lighting.ClockTime = 16
        Lighting.FogEnd = 300
    elseif zoneName == "Dungeon" then
        Lighting.Brightness = 0.5
        Lighting.ClockTime = 22
        Lighting.FogEnd = 150
    elseif zoneName == "Castle" then
        Lighting.Brightness = 1
        Lighting.ClockTime = 18
        Lighting.FogEnd = 500
    else
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 1000
    end
end

local function teleportPlayerToZone(player, zoneName)
    local character = player.Character
    if not character then
        return
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end
    local targetPosition
    if zoneName == "Village" then
        targetPosition = Vector3.new(0, 5, 0)
    elseif zoneName == "Forest" then
        targetPosition = Vector3.new(200, 5, 0)
    elseif zoneName == "Dungeon" then
        targetPosition = Vector3.new(400, -10, 0)
    elseif zoneName == "Castle" then
        targetPosition = Vector3.new(600, 10, 0)
    else
        targetPosition = Vector3.new(0, 5, 0)
    end
    root.CFrame = CFrame.new(targetPosition)
    changeZone(player, zoneName)
    createZoneLighting(zoneName)
end

local function animateZoneTransition(player, zoneName)
    uiRemote:FireClient(player, "Traveling to " .. zoneName .. "...")
    teleportPlayerToZone(player, zoneName)
end

local function performBasicAttack(player, target)
    local statFolder = getStatFolder(player)
    local invFolder = getInventoryFolder(player)
    if not statFolder or not invFolder then
        return
    end
    local weapon = invFolder:FindFirstChild("Weapon")
    local level = statFolder:FindFirstChild("Level")
    if not weapon or not level then
        return
    end
    local baseDamage = 10 + level.Value * 2
    if weapon.Value == "WoodenSword" then
        baseDamage = baseDamage + 5
    elseif weapon.Value == "IronSword" then
        baseDamage = baseDamage + 10
    elseif weapon.Value == "MagicStaff" then
        baseDamage = baseDamage + 8
    end
    attackRemote:FireClient(player, "BasicAttack")
    if target and target:IsA("Model") then
        local humanoid = target:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:TakeDamage(baseDamage)
        end
    end
    addExperience(player, 10)
end

local function performSkillAttack(player, target, skillName)
    local statFolder = getStatFolder(player)
    local invFolder = getInventoryFolder(player)
    if not statFolder or not invFolder then
        return
    end
    local level = statFolder:FindFirstChild("Level")
    if not level then
        return
    end
    local manaCost = 0
    local damageMultiplier = 1
    if skillName == "FireSlash" then
        manaCost = 10
        damageMultiplier = 1.5
    elseif skillName == "IceBurst" then
        manaCost = 15
        damageMultiplier = 1.8
    elseif skillName == "ThunderStrike" then
        manaCost = 20
        damageMultiplier = 2
    else
        manaCost = 5
        damageMultiplier = 1.2
    end
    if not spendMana(player, manaCost) then
        uiRemote:FireClient(player, "Not enough mana.")
        return
    end
    local baseDamage = 15 + level.Value * 3
    local totalDamage = baseDamage * damageMultiplier
    attackRemote:FireClient(player, skillName)
    if target and target:IsA("Model") then
        local humanoid = target:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:TakeDamage(totalDamage)
        end
    end
    addExperience(player, 20)
end

local function createFloatingText(position, text, color)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(1, 1, 1)
    part.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    part.Transparency = 1
    part.Parent = Workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = part
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.Parent = billboard

    local tween = TweenService:Create(part, TweenInfo.new(1.5), {CFrame = part.CFrame + Vector3.new(0, 5, 0)})
    tween:Play()
    tween.Completed:Connect(function()
        part:Destroy()
    end)
end

local function rewardChest(player, chestType)
    if chestType == "Bronze" then
        addGold(player, 50)
        addMaterial(player, 5)
        uiRemote:FireClient(player, "Bronze chest opened.")
    elseif chestType == "Silver" then
        addGold(player, 150)
        addMaterial(player, 10)
        addKey(player, 1)
        uiRemote:FireClient(player, "Silver chest opened.")
    elseif chestType == "Gold" then
        addGold(player, 300)
        addMaterial(player, 20)
        addKey(player, 2)
        uiRemote:FireClient(player, "Gold chest opened.")
    else
        addGold(player, 20)
        uiRemote:FireClient(player, "Basic chest opened.")
    end
end

local function randomChestReward(player)
    local roll = math.random(1, 100)
    if roll <= 50 then
        rewardChest(player, "Bronze")
    elseif roll <= 80 then
        rewardChest(player, "Silver")
    else
        rewardChest(player, "Gold")
    end
end

local function createZonePortal(name, position)
    local part = Instance.new("Part")
    part.Name = name .. "Portal"
    part.Size = Vector3.new(6, 10, 1)
    part.Anchored = true
    part.CanCollide = false
    part.CFrame = CFrame.new(position)
    part.Parent = Workspace

    local touchConnection
    touchConnection = part.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            animateZoneTransition(player, name)
        end
    end)
end

createZonePortal("Village", Vector3.new(0, 5, 50))
createZonePortal("Forest", Vector3.new(200, 5, 50))
createZonePortal("Dungeon", Vector3.new(400, 5, 50))
createZonePortal("Castle", Vector3.new(600, 5, 50))

local function setupPlayerGui(player)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RPGGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0, 10, 1, -160)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(0, 280, 0, 20)
    healthBar.Position = UDim2.new(0, 10, 0, 10)
    healthBar.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = frame

    local manaBar = Instance.new("Frame")
    manaBar.Name = "ManaBar"
    manaBar.Size = UDim2.new(0, 280, 0, 20)
    manaBar.Position = UDim2.new(0, 10, 0, 40)
    manaBar.BackgroundColor3 = Color3.fromRGB(0, 0, 150)
    manaBar.BorderSizePixel = 0
    manaBar.Parent = frame

    local expBar = Instance.new("Frame")
    expBar.Name = "ExpBar"
    expBar.Size = UDim2.new(0, 280, 0, 20)
    expBar.Position = UDim2.new(0, 10, 0, 70)
    expBar.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    expBar.BorderSizePixel = 0
    expBar.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "InfoLabel"
    label.Size = UDim2.new(0, 280, 0, 40)
    label.Position = UDim2.new(0, 10, 0, 100)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = "Welcome to the RPG."
    label.Parent = frame
end

local function updateGuiBars(player)
    local statFolder = getStatFolder(player)
    if not statFolder then
        return
    end
    local health = statFolder:FindFirstChild("Health")
    local maxHealth = statFolder:FindFirstChild("MaxHealth")
    local mana = statFolder:FindFirstChild("Mana")
    local maxMana = statFolder:FindFirstChild("MaxMana")
    local exp = statFolder:FindFirstChild("Experience")
    local level = statFolder:FindFirstChild("Level")
    if not health or not maxHealth or not mana or not maxMana or not exp or not level then
        return
    end
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then
        return
    end
    local screenGui = gui:FindFirstChild("RPGGui")
    if not screenGui then
        return
    end
    local frame = screenGui:FindFirstChild("Frame")
    if not frame then
        return
    end
    local healthBar = frame:FindFirstChild("HealthBar")
    local manaBar = frame:FindFirstChild("ManaBar")
    local expBar = frame:FindFirstChild("ExpBar")
    local label = frame:FindFirstChild("InfoLabel")
    if healthBar and manaBar and expBar and label then
        local healthRatio = health.Value / maxHealth.Value
        local manaRatio = mana.Value / maxMana.Value
        local expRatio = exp.Value / (level.Value * 100)
        healthBar.Size = UDim2.new(healthRatio, 0, 0, 20)
        manaBar.Size = UDim2.new(manaRatio, 0, 0, 20)
        expBar.Size = UDim2.new(expRatio, 0, 0, 20)
        label.Text = "Lv." .. level.Value .. " HP:" .. health.Value .. "/" .. maxHealth.Value .. " MP:" .. mana.Value .. "/" .. maxMana.Value
    end
end

local function periodicGuiUpdate()
    while true do
        for _, player in ipairs(Players:GetPlayers()) do
            updateGuiBars(player)
        end
        wait(0.5)
    end
end

spawn(periodicGuiUpdate)

local function handleJoin(player)
    createStatFolder(player)
    createInventoryFolder(player)
    createQuestFolder(player)
    setupPlayerGui(player)
    uiRemote:FireClient(player, "You entered the world.")
end

Players.PlayerAdded:Connect(function(player)
    handleJoin(player)
end)

Players.PlayerRemoving:Connect(function(player)
    local statFolder = getStatFolder(player)
    local invFolder = getInventoryFolder(player)
    local qFolder = getQuestFolder(player)
    if statFolder then
        statFolder:Destroy()
    end
    if invFolder then
        invFolder:Destroy()
    end
    if qFolder then
        qFolder:Destroy()
    end
end)

joinRemote.OnServerEvent:Connect(function(player)
    handleJoin(player)
end)

attackRemote.OnServerEvent:Connect(function(player, attackType, target)
    if attackType == "Basic" then
        performBasicAttack(player, target)
    else
        performSkillAttack(player, target, attackType)
    end
end)

healRemote.OnServerEvent:Connect(function(player, healType)
    if healType == "HealthPotion" then
        useHealthPotion(player)
    elseif healType == "ManaPotion" then
        useManaPotion(player)
    elseif healType == "Spell" then
        if spendMana(player, 10) then
            healPlayer(player, 40)
        end
    end
end)

questRemote.OnServerEvent:Connect(function(player, action, data)
    if action == "StartMain" then
        startMainQuest(player, data)
    elseif action == "StartSide1" then
        setSideQuest(player, 1, data)
    elseif action == "StartSide2" then
        setSideQuest(player, 2, data)
    elseif action == "CompleteMain" then
        completeQuest(player, "Main")
    elseif action == "CompleteSide" then
        completeQuest(player, "Side")
    end
end)

inventoryRemote.OnServerEvent:Connect(function(player, action, data)
    if action == "SetWeapon" then
        setWeapon(player, data)
    elseif action == "SetArmor" then
        setArmor(player, data)
    elseif action == "OpenChest" then
        randomChestReward(player)
    end
end)

zoneRemote.OnServerEvent:Connect(function(player, zoneName)
    animateZoneTransition(player, zoneName)
end)

uiRemote.OnServerEvent:Connect(function(player, message)
    uiRemote:FireClient(player, message)
end)

local function spawnDummyEnemy(name, position, healthValue)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = Workspace

    local part = Instance.new("Part")
    part.Size = Vector3.new(2, 4, 2)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = healthValue
    humanoid.Health = healthValue
    humanoid.Parent = model

    humanoid.Died:Connect(function()
        createFloatingText(position, name .. " defeated", Color3.fromRGB(255, 255, 0))
        model:Destroy()
    end)
end

spawnDummyEnemy("Slime", Vector3.new(210, 5, 0), 50)
spawnDummyEnemy("Goblin", Vector3.new(220, 5, 10), 80)
spawnDummyEnemy("Wolf", Vector3.new(230, 5, -10), 90)
spawnDummyEnemy("Skeleton", Vector3.new(410, -10, 0), 120)
spawnDummyEnemy("DarkMage", Vector3.new(420, -10, 15), 150)
spawnDummyEnemy("Knight", Vector3.new(610, 10, 0), 200)

local function periodicWorldEvents()
    while true do
        wait(30)
        local roll = math.random(1, 3)
        if roll == 1 then
            broadcastMessage("A mysterious wind blows through the forest.")
        elseif roll == 2 then
            broadcastMessage("The dungeon trembles with distant echoes.")
        else
            broadcastMessage("The castle bells ring in the distance.")
        end
    end
end

spawn(periodicWorldEvents)

local function randomBuff(player)
    local statFolder = getStatFolder(player)
    if not statFolder then
        return
    end
    local health = statFolder:FindFirstChild("Health")
    local maxHealth = statFolder:FindFirstChild("MaxHealth")
    local mana = statFolder:FindFirstChild("Mana")
    local maxMana = statFolder:FindFirstChild("MaxMana")
    local roll = math.random(1, 4)
    if roll == 1 and health and maxHealth then
        health.Value = math.min(maxHealth.Value, health.Value + 20)
        uiRemote:FireClient(player, "You feel revitalized.")
    elseif roll == 2 and mana and maxMana then
        mana.Value = math.min(maxMana.Value, mana.Value + 15)
        uiRemote:FireClient(player, "Your mind feels clearer.")
    elseif roll == 3 then
        addExperience(player, 30)
        uiRemote:FireClient(player, "You gain sudden insight.")
    else
        addGold(player, 50)
        uiRemote:FireClient(player, "You find hidden coins.")
    end
end

local function periodicPlayerBuffs()
    while true do
        wait(45)
        for _, player in ipairs(Players:GetPlayers()) do
            randomBuff(player)
        end
    end
end

spawn(periodicPlayerBuffs)

local function createTrainingDummy(position)
    local model = Instance.new("Model")
    model.Name = "TrainingDummy"
    model.Parent = Workspace

    local part = Instance.new("Part")
    part.Size = Vector3.new(2, 6, 2)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 9999
    humanoid.Health = 9999
    humanoid.Parent = model
end

createTrainingDummy(Vector3.new(20, 5, 0))
createTrainingDummy(Vector3.new(25, 5, 5))
createTrainingDummy(Vector3.new(30, 5, -5))

local function createCampfire(position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(4, 1, 4)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Parent = Workspace

    local fire = Instance.new("Fire")
    fire.Size = 5
    fire.Heat = 10
    fire.Parent = part
end

createCampfire(Vector3.new(5, 5, 10))
createCampfire(Vector3.new(205, 5, 10))
createCampfire(Vector3.new(405, -10, 10))

local function createZoneSign(text, position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(6, 3, 1)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Parent = Workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = part
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = text
    label.Parent = billboard
end

createZoneSign("Village", Vector3.new(0, 7, 40))
createZoneSign("Forest", Vector3.new(200, 7, 40))
createZoneSign("Dungeon", Vector3.new(400, -8, 40))
createZoneSign("Castle", Vector3.new(600, 12, 40))

local function createAmbientSound(name, soundId, position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 1, 1)
    part.Anchored = true
    part.Transparency = 1
    part.CFrame = CFrame.new(position)
    part.Parent = Workspace

    local sound = Instance.new("Sound")
    sound.Name = name
    sound.SoundId = soundId
    sound.Looped = true
    sound.Volume = 0.5
    sound.Parent = part
    sound:Play()
end

createAmbientSound("VillageAmbience", "rbxassetid://184352", Vector3.new(0, 5, 0))
createAmbientSound("ForestAmbience", "rbxassetid://184353", Vector3.new(200, 5, 0))
createAmbientSound("DungeonAmbience", "rbxassetid://184354", Vector3.new(400, -10, 0))
createAmbientSound("CastleAmbience", "rbxassetid://184355", Vector3.new(600, 10, 0))

local function createZoneBoundary(position, size)
    local part = Instance.new("Part")
    part.Size = size
    part.Anchored = true
    part.Transparency = 1
    part.CFrame = CFrame.new(position)
    part.Parent = Workspace
end

createZoneBoundary(Vector3.new(0, 0, 0), Vector3.new(100, 1, 100))
createZoneBoundary(Vector3.new(200, 0, 0), Vector3.new(100, 1, 100))
createZoneBoundary(Vector3.new(400, -15, 0), Vector3.new(100, 1, 100))
createZoneBoundary(Vector3.new(600, 0, 0), Vector3.new(100, 1, 100))

local function createBridge(position, length)
    local part = Instance.new("Part")
    part.Size = Vector3.new(length, 1, 8)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Parent = Workspace
end

createBridge(Vector3.new(100, 0, 0), 50)
createBridge(Vector3.new(300, -5, 0), 50)
createBridge(Vector3.new(500, 5, 0), 50)

local function createRiver(position, size)
    local part = Instance.new("Part")
    part.Size = size
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Color = Color3.fromRGB(0, 0, 255)
    part.Material = Enum.Material.SmoothPlastic
    part.Parent = Workspace
end

createRiver(Vector3.new(100, -2, 0), Vector3.new(60, 1, 20))
createRiver(Vector3.new(300, -7, 0), Vector3.new(60, 1, 20))
createRiver(Vector3.new(500, 3, 0), Vector3.new(60, 1, 20))

local function createTree(position)
    local trunk = Instance.new("Part")
    trunk.Size = Vector3.new(1, 6, 1)
    trunk.Anchored = true
    trunk.CFrame = CFrame.new(position)
    trunk.Color = Color3.fromRGB(101, 67, 33)
    trunk.Parent = Workspace

    local leaves = Instance.new("Part")
    leaves.Size = Vector3.new(4, 4, 4)
    leaves.Anchored = true
    leaves.CFrame = CFrame.new(position + Vector3.new(0, 4, 0))
    leaves.Color = Color3.fromRGB(34, 139, 34)
    leaves.Parent = Workspace
end

for i = 1, 20 do
    createTree(Vector3.new(180 + i * 3, 5, -20 + i))
end

local function createRock(position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(3, 2, 3)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Color = Color3.fromRGB(128, 128, 128)
    part.Material = Enum.Material.Slate
    part.Parent = Workspace
end

for i = 1, 15 do
    createRock(Vector3.new(380 + i * 2, -10, -15 + i))
end

local function createBanner(text, position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(2, 6, 1)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Parent = Workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.Adornee = part
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = text
    label.Parent = billboard
end

createBanner("Training Grounds", Vector3.new(15, 7, 0))
createBanner("Forest Edge", Vector3.new(190, 7, 0))
createBanner("Dungeon Entrance", Vector3.new(390, -8, 0))
createBanner("Castle Gate", Vector3.new(590, 12, 0))

local function createLantern(position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 4, 1)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Color = Color3.fromRGB(80, 80, 80)
    part.Parent = Workspace

    local light = Instance.new("PointLight")
    light.Range = 15
    light.Brightness = 2
    light.Color = Color3.fromRGB(255, 220, 150)
    light.Parent = part
end

for i = 1, 10 do
    createLantern(Vector3.new(-10 + i * 5, 5, 20))
end

local function createDungeonTorch(position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(1, 3, 1)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Color = Color3.fromRGB(60, 60, 60)
    part.Parent = Workspace

    local fire = Instance.new("Fire")
    fire.Size = 3
    fire.Heat = 8
    fire.Parent = part
end

for i = 1, 12 do
    createDungeonTorch(Vector3.new(390 + i * 3, -10, -10))
end

local function createCastleWall(position, size)
    local part = Instance.new("Part")
    part.Size = size
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Color = Color3.fromRGB(150, 150, 150)
    part.Material = Enum.Material.Concrete
    part.Parent = Workspace
end

createCastleWall(Vector3.new(600, 15, -20), Vector3.new(40, 20, 2))
createCastleWall(Vector3.new(620, 15, 0), Vector3.new(2, 20, 40))
createCastleWall(Vector3.new(580, 15, 0), Vector3.new(2, 20, 40))

local function createThrone(position)
    local base = Instance.new("Part")
    base.Size = Vector3.new(4, 1, 4)
    base.Anchored = true
    base.CFrame = CFrame.new(position)
    base.Color = Color3.fromRGB(120, 0, 0)
    base.Parent = Workspace

    local back = Instance.new("Part")
    back.Size = Vector3.new(4, 6, 1)
    back.Anchored = true
    back.CFrame = CFrame.new(position + Vector3.new(0, 3, -1.5))
    back.Color = Color3.fromRGB(120, 0, 0)
    back.Parent = Workspace
end

createThrone(Vector3.new(600, 10, 10))

local function createBossSpawn(position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(6, 1, 6)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Color = Color3.fromRGB(80, 0, 0)
    part.Parent = Workspace
end

createBossSpawn(Vector3.new(610, 10, -10))

local function periodicBossAnnouncement()
    while true do
        wait(120)
        broadcastMessage("A powerful boss stirs within the castle.")
    end
end

spawn(periodicBossAnnouncement)

local function createTrainingSign(position, text)
    local part = Instance.new("Part")
    part.Size = Vector3.new(4, 2, 1)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Parent = Workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = part
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = text
    label.Parent = billboard
end

createTrainingSign(Vector3.new(25, 7, 5), "Hit dummies to test damage.")
createTrainingSign(Vector3.new(25, 7, -5), "Use skills to see effects.")

local function createZoneHint(position, text)
    local part = Instance.new("Part")
    part.Size = Vector3.new(3, 2, 1)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Parent = Workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 180, 0, 40)
    billboard.Adornee = part
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 255)
    label.Font = Enum.Font.Gotham
    label.TextScaled = true
    label.Text = text
    label.Parent = billboard
end

createZoneHint(Vector3.new(190, 7, -10), "Forest enemies drop materials.")
createZoneHint(Vector3.new(390, -8, -10), "Dungeon enemies drop keys.")
createZoneHint(Vector3.new(590, 12, -10), "Castle enemies drop rare loot.")

local function createSpawnPad(position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(6, 1, 6)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Color = Color3.fromRGB(0, 255, 0)
    part.Parent = Workspace
end

createSpawnPad(Vector3.new(0, 0, 0))

local function createZoneMusicToggle(position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(2, 2, 2)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Color = Color3.fromRGB(255, 255, 0)
    part.Parent = Workspace

    part.Touched:Connect(function(hit)
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if player then
            uiRemote:FireClient(player, "Zone music toggled.")
        end
    end)
end

createZoneMusicToggle(Vector3.new(10, 5, 10))

local function createRPGStatBoard(position)
    local part = Instance.new("Part")
    part.Size = Vector3.new(8, 6, 1)
    part.Anchored = true
    part.CFrame = CFrame.new(position)
    part.Parent = Workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 250, 0, 150)
    billboard.Adornee = part
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = "RPG World"
    label.Parent = billboard
end

createRPGStatBoard(Vector3.new(0, 7, -20))
