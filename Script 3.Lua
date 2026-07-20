local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local PLAYER_DATA_STORE_NAME = "RPG_PlayerData"
local playerDataStore = DataStoreService:GetDataStore(PLAYER_DATA_STORE_NAME)

local PROFILE_TEMPLATE = {
	Level = 1,
	XP = 0,
	Gold = 0,
	Class = "Warrior",
	Inventory = {},
	CompletedQuests = {},
	ActiveQuests = {},
}

local MAX_LEVEL = 50
local XP_PER_LEVEL = 100
local GOLD_START = 50

local PARTY_INVITE_TIMEOUT = 30
local QUEST_MAX_ACTIVE = 5

local ADMIN_USERNAMES = {
	["Johno11123"] = true,
}

local remoteFolder = ReplicatedStorage:FindFirstChild("RPG_Remotes")
if not remoteFolder then
	remoteFolder = Instance.new("Folder")
	remoteFolder.Name = "RPG_Remotes"
	remoteFolder.Parent = ReplicatedStorage
end

local ProfileRemote = remoteFolder:FindFirstChild("ProfileRemote")
if not ProfileRemote then
	ProfileRemote = Instance.new("RemoteEvent")
	ProfileRemote.Name = "ProfileRemote"
	ProfileRemote.Parent = remoteFolder
end

local CombatRemote = remoteFolder:FindFirstChild("CombatRemote")
if not CombatRemote then
	CombatRemote = Instance.new("RemoteEvent")
	CombatRemote.Name = "CombatRemote"
	CombatRemote.Parent = remoteFolder
end

local PartyRemote = remoteFolder:FindFirstChild("PartyRemote")
if not PartyRemote then
	PartyRemote = Instance.new("RemoteEvent")
	PartyRemote.Name = "PartyRemote"
	PartyRemote.Parent = remoteFolder
end

local QuestRemote = remoteFolder:FindFirstChild("QuestRemote")
if not QuestRemote then
	QuestRemote = Instance.new("RemoteEvent")
	QuestRemote.Name = "QuestRemote"
	QuestRemote.Parent = remoteFolder
end

local WorldEventRemote = remoteFolder:FindFirstChild("WorldEventRemote")
if not WorldEventRemote then
	WorldEventRemote = Instance.new("RemoteEvent")
	WorldEventRemote.Name = "WorldEventRemote"
	WorldEventRemote.Parent = remoteFolder
end

local AdminRemote = remoteFolder:FindFirstChild("AdminRemote")
if not AdminRemote then
	AdminRemote = Instance.new("RemoteEvent")
	AdminRemote.Name = "AdminRemote"
	AdminRemote.Parent = remoteFolder
end

local Profiles = {}
local Parties = {}
local QuestDefinitions = {}

local function safePrint(...)
	print("[RPG_Core]", ...)
end

local function isAdmin(player)
	return ADMIN_USERNAMES[player.Name] == true
end

local function deepCopy(tbl)
	local new = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			new[k] = deepCopy(v)
		else
			new[k] = v
		end
	end
	return new
end

local function createLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = 1
	level.Parent = leaderstats

	local xp = Instance.new("IntValue")
	xp.Name = "XP"
	xp.Value = 0
	xp.Parent = leaderstats

	local gold = Instance.new("IntValue")
	gold.Name = "Gold"
	gold.Value = GOLD_START
	gold.Parent = leaderstats
end

local function getLeaderstats(player)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then return nil end
	local level = ls:FindFirstChild("Level")
	local xp = ls:FindFirstChild("XP")
	local gold = ls:FindFirstChild("Gold")
	if level and xp and gold then
		return {
			Level = level,
			XP = xp,
			Gold = gold,
		}
	end
	return nil
end

local function loadProfile(player)
	local key = "Player_" .. player.UserId
	local success, data = pcall(function()
		return playerDataStore:GetAsync(key)
	end)

	local profile
	if success and data then
		profile = deepCopy(PROFILE_TEMPLATE)
		for k, v in pairs(data) do
			profile[k] = v
		end
		safePrint("Loaded profile for", player.Name)
	else
		profile = deepCopy(PROFILE_TEMPLATE)
		profile.Gold = GOLD_START
		safePrint("New profile for", player.Name)
	end

	Profiles[player] = profile

	local ls = getLeaderstats(player)
	if ls then
		ls.Level.Value = profile.Level
		ls.XP.Value = profile.XP
		ls.Gold.Value = profile.Gold
	end

	ProfileRemote:FireClient(player, "ProfileLoaded", profile)
end

local function saveProfile(player)
	local profile = Profiles[player]
	if not profile then return end

	local key = "Player_" .. player.UserId
	local success, err = pcall(function()
		playerDataStore:SetAsync(key, profile)
	end)

	if success then
		safePrint("Saved profile for", player.Name)
	else
		safePrint("Failed to save profile for", player.Name, err)
	end
end

local function addXP(player, amount)
	local profile = Profiles[player]
	if not profile then return end

	profile.XP = profile.XP + amount
	local ls = getLeaderstats(player)
	if ls then
		ls.XP.Value = profile.XP
	end

	while profile.XP >= XP_PER_LEVEL and profile.Level < MAX_LEVEL do
		profile.XP = profile.XP - XP_PER_LEVEL
		profile.Level = profile.Level + 1
		safePrint(player.Name, "leveled up to", profile.Level)
		if ls then
			ls.Level.Value = profile.Level
			ls.XP.Value = profile.XP
		end
		ProfileRemote:FireClient(player, "LevelUp", profile.Level)
	end
end

local function addGold(player, amount)
	local profile = Profiles[player]
	if not profile then return end
	profile.Gold = profile.Gold + amount
	local ls = getLeaderstats(player)
	if ls then
		ls.Gold.Value = profile.Gold
	end
	ProfileRemote:FireClient(player, "GoldChanged", profile.Gold)
end

local function addItem(player, itemName, quantity)
	quantity = quantity or 1
	local profile = Profiles[player]
	if not profile then return end

	profile.Inventory[itemName] = (profile.Inventory[itemName] or 0) + quantity
	ProfileRemote:FireClient(player, "InventoryChanged", profile.Inventory)
end

local function removeItem(player, itemName, quantity)
	quantity = quantity or 1
	local profile = Profiles[player]
	if not profile then return end

	local current = profile.Inventory[itemName] or 0
	current = current - quantity
	if current <= 0 then
		profile.Inventory[itemName] = nil
	else
		profile.Inventory[itemName] = current
	end
	ProfileRemote:FireClient(player, "InventoryChanged", profile.Inventory)
end

local function hasItem(player, itemName, quantity)
	quantity = quantity or 1
	local profile = Profiles[player]
	if not profile then return false end
	return (profile.Inventory[itemName] or 0) >= quantity
end

local ClassStats = {
	Warrior = {
		BaseDamage = 15,
		CritChance = 0.1,
		CritMultiplier = 2,
		Armor = 5,
	},
	Mage = {
		BaseDamage = 25,
		CritChance = 0.2,
		CritMultiplier = 1.5,
		Armor = 2,
	},
	Rogue = {
		BaseDamage = 18,
		CritChance = 0.3,
		CritMultiplier = 2.5,
		Armor = 3,
	},
}

local function getClassStats(className)
	return ClassStats[className] or ClassStats["Warrior"]
end

local function calculateDamage(attacker, target, baseDamageOverride)
	local profile = Profiles[attacker]
	if not profile then return 0 end

	local classStats = getClassStats(profile.Class)
	local baseDamage = baseDamageOverride or classStats.BaseDamage + profile.Level

	local crit = math.random() < classStats.CritChance
	local damage = baseDamage
	if crit then
		damage = damage * classStats.CritMultiplier
	end

	local targetProfile = Profiles[target]
	if targetProfile then
		local targetClassStats = getClassStats(targetProfile.Class)
		damage = damage - targetClassStats.Armor
	end

	if damage < 1 then
		damage = 1
	end

	return math.floor(damage), crit
end

local function applyDamage(attacker, target, damage)
	CombatRemote:FireClient(target, "TakeDamage", damage, attacker.Name)
	CombatRemote:FireClient(attacker, "DealtDamage", damage, target.Name)
end

CombatRemote.OnServerEvent:Connect(function(player, action, data)
	if action == "Attack" then
		local target = data.Target
		if typeof(target) == "Instance" and target:IsA("Player") then
			local damage, crit = calculateDamage(player, target)
			applyDamage(player, target, damage)
			if crit then
				CombatRemote:FireClient(player, "Crit", damage, target.Name)
			end
			addXP(player, 5)
		end
	elseif action == "UseItem" then
		local itemName = data.ItemName
		if hasItem(player, itemName, 1) then
			removeItem(player, itemName, 1)
			CombatRemote:FireClient(player, "ItemUsed", itemName)
		end
	end
end)

local function getPartyId(player)
	for partyId, party in pairs(Parties) do
		if party.Members[player] then
			return partyId
		end
	end
	return nil
end

local function createParty(leader)
	local partyId = "Party_" .. leader.UserId .. "_" .. tick()
	Parties[partyId] = {
		Leader = leader,
		Members = {
			[leader] = true,
		},
		Invites = {},
	}
	safePrint("Party created by", leader.Name, "ID:", partyId)
	return partyId
end

local function addMemberToParty(partyId, player)
	local party = Parties[partyId]
	if not party then return end
	party.Members[player] = true
	PartyRemote:FireClient(player, "JoinedParty", partyId)
	for member in pairs(party.Members) do
		PartyRemote:FireClient(member, "PartyUpdated", partyId)
	end
end

local function removeMemberFromParty(partyId, player)
	local party = Parties[partyId]
	if not party then return end
	party.Members[player] = nil
	PartyRemote:FireClient(player, "LeftParty", partyId)
	for member in pairs(party.Members) do
		PartyRemote:FireClient(member, "PartyUpdated", partyId)
	end
	if player == party.Leader then
		safePrint("Leader left party, disbanding", partyId)
		for member in pairs(party.Members) do
			PartyRemote:FireClient(member, "PartyDisbanded", partyId)
		end
		Parties[partyId] = nil
	end
end

local function inviteToParty(partyId, inviter, target)
	local party = Parties[partyId]
	if not party then return end
	party.Invites[target] = tick()
	PartyRemote:FireClient(target, "PartyInvite", partyId, inviter.Name)
end

local function cleanupExpiredInvites()
	local now = tick()
	for partyId, party in pairs(Parties) do
		for player, inviteTime in pairs(party.Invites) do
			if now - inviteTime > PARTY_INVITE_TIMEOUT then
				party.Invites[player] = nil
			end
		end
	end
end

PartyRemote.OnServerEvent:Connect(function(player, action, data)
	if action == "CreateParty" then
		if getPartyId(player) then
			PartyRemote:FireClient(player, "Error", "Already in a party.")
			return
		end
		local partyId = createParty(player)
		PartyRemote:FireClient(player, "PartyCreated", partyId)
	elseif action == "Invite" then
		local target = data.Target
		if typeof(target) == "Instance" and target:IsA("Player") then
			local partyId = getPartyId(player)
			if not partyId then
				partyId = createParty(player)
			end
			inviteToParty(partyId, player, target)
		end
	elseif action == "AcceptInvite" then
		local partyId = data.PartyId
		local party = Parties[partyId]
		if party and party.Invites[player] then
			party.Invites[player] = nil
			addMemberToParty(partyId, player)
		end
	elseif action == "LeaveParty" then
		local partyId = getPartyId(player)
		if partyId then
			removeMemberFromParty(partyId, player)
		end
	end
end)

QuestDefinitions = {
	["SlimeHunt"] = {
		Name = "Slime Hunt",
		Description = "Defeat 10 slimes in the forest.",
		Objectives = {
			KillSlimes = 10,
		},
		Rewards = {
			XP = 50,
			Gold = 30,
			Items = {
				["HealthPotion"] = 2,
			},
		},
	},
	["BossTrial"] = {
		Name = "Boss Trial",
		Description = "Defeat the Forest Guardian.",
		Objectives = {
			KillBoss = 1,
		},
		Rewards = {
			XP = 200,
			Gold = 100,
			Items = {
				["EpicSword"] = 1,
			},
		},
	},
}

local function canAcceptQuest(player, questId)
	local profile = Profiles[player]
	if not profile then return false, "No profile" end
	if profile.ActiveQuests[questId] then
		return false, "Already active"
	end
	if profile.CompletedQuests[questId] then
		return false, "Already completed"
	end
	local count = 0
	for _ in pairs(profile.ActiveQuests) do
		count += 1
	end
	if count >= QUEST_MAX_ACTIVE then
		return false, "Too many active quests"
	end
	return true
end

local function acceptQuest(player, questId)
	local questDef = QuestDefinitions[questId]
	if not questDef then return end

	local ok, reason = canAcceptQuest(player, questId)
	if not ok then
		QuestRemote:FireClient(player, "Error", reason)
		return
	end

	local profile = Profiles[player]
	profile.ActiveQuests[questId] = {
		Progress = {},
	}
	QuestRemote:FireClient(player, "QuestAccepted", questId, questDef)
end

local function updateQuestProgress(player, questId, objectiveKey, amount)
	local profile = Profiles[player]
	if not profile then return end
	local questDef = QuestDefinitions[questId]
	if not questDef then return end
	local active = profile.ActiveQuests[questId]
	if not active then return end

	active.Progress[objectiveKey] = (active.Progress[objectiveKey] or 0) + amount

	QuestRemote:FireClient(player, "QuestProgress", questId, active.Progress)

	local completed = true
	for objKey, required in pairs(questDef.Objectives) do
		local current = active.Progress[objKey] or 0
		if current < required then
			completed = false
			break
		end
	end

	if completed then
		profile.ActiveQuests[questId] = nil
		profile.CompletedQuests[questId] = true
		addXP(player, questDef.Rewards.XP or 0)
		addGold(player, questDef.Rewards.Gold or 0)
		if questDef.Rewards.Items then
			for itemName, qty in pairs(questDef.Rewards.Items) do
				addItem(player, itemName, qty)
			end
		end
		QuestRemote:FireClient(player, "QuestCompleted", questId, questDef.Rewards)
	end
end

QuestRemote.OnServerEvent:Connect(function(player, action, data)
	if action == "AcceptQuest" then
		local questId = data.QuestId
		acceptQuest(player, questId)
	elseif action == "ReportKill" then
		local enemyType = data.EnemyType
		if enemyType == "Slime" then
			updateQuestProgress(player, "SlimeHunt", "KillSlimes", 1)
		elseif enemyType == "ForestGuardian" then
			updateQuestProgress(player, "BossTrial", "KillBoss", 1)
		end
	end
end)

local function spawnBoss()
	local bossModel = ServerStorage:FindFirstChild("ForestGuardian")
	if not bossModel then
		safePrint("No boss model named 'ForestGuardian' in ServerStorage")
		return
	end
	local boss = bossModel:Clone()
	boss.Parent = workspace
	boss:SetPrimaryPartCFrame(CFrame.new(0, 10, 0))
	WorldEventRemote:FireAllClients("BossSpawned", "ForestGuardian")
	safePrint("Boss spawned: ForestGuardian")
end

local function periodicWorldEvents()
	while true do
		task.wait(300)
		WorldEventRemote:FireAllClients("Announcement", "A powerful presence is felt in the forest...")
		task.wait(30)
		spawnBoss()
	end
end

task.spawn(periodicWorldEvents)

AdminRemote.OnServerEvent:Connect(function(player, action, data)
	if not isAdmin(player) then
		safePrint(player.Name, "attempted admin action:", action)
		return
	end

	if action == "GiveGold" then
		local target = data.Target
		local amount = data.Amount or 0
		if typeof(target) == "Instance" and target:IsA("Player") then
			addGold(target, amount)
		end
	elseif action == "GiveXP" then
		local target = data.Target
		local amount = data.Amount or 0
		if typeof(target) == "Instance" and target:IsA("Player") then
			addXP(target, amount)
		end
	elseif action == "SpawnBoss" then
		spawnBoss()
	end
end)

Players.PlayerAdded:Connect(function(player)
	safePrint("Player joined:", player.Name)
	createLeaderstats(player)
	loadProfile(player)
end)

Players.PlayerRemoving:Connect(function(player)
	safePrint("Player leaving:", player.Name)
	saveProfile(player)
	Profiles[player] = nil
end)

RunService.Heartbeat:Connect(function(dt)
	cleanupExpiredInvites()
end
