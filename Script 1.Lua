local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local PLAYER_STORE_NAME = "MegaFramework_Player_v1"
local playerStore = DataStoreService:GetDataStore(PLAYER_STORE_NAME)

local ECONOMY_STORE_NAME = "MegaFramework_Economy_v1"
local economyStore = DataStoreService:GetDataStore(ECONOMY_STORE_NAME)

local ROUND_STORE_NAME = "MegaFramework_RoundStats_v1"
local roundStore = DataStoreService:GetDataStore(ROUND_STORE_NAME)

local MAX_LEVEL = 60
local XP_PER_LEVEL = 120
local START_GOLD = 100
local START_BALANCE = 150

local ROUND_LOBBY_TIME = 30
local ROUND_INTERMISSION_TIME = 15
local ROUND_PLAY_TIME = 180
local ROUND_POST_TIME = 10
local MIN_PLAYERS_TO_START = 2

local TEAM_RED = "Red"
local TEAM_BLUE = "Blue"

local MAPS_FOLDER_NAME = "MegaMaps"

local TAX_RATE = 0.05
local AUCTION_FEE_RATE = 0.02

local ADMIN_USERNAMES = {
	["Johno11123"] = true,
}


local remoteFolder = ReplicatedStorage:FindFirstChild("Mega_Remotes")
if not remoteFolder then
	remoteFolder = Instance.new("Folder")
	remoteFolder.Name = "Mega_Remotes"
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

local RoundRemote = remoteFolder:FindFirstChild("RoundRemote")
if not RoundRemote then
	RoundRemote = Instance.new("RemoteEvent")
	RoundRemote.Name = "RoundRemote"
	RoundRemote.Parent = remoteFolder
end

local MapVoteRemote = remoteFolder:FindFirstChild("MapVoteRemote")
if not MapVoteRemote then
	MapVoteRemote = Instance.new("RemoteEvent")
	MapVoteRemote.Name = "MapVoteRemote"
	MapVoteRemote.Parent = remoteFolder
end

local TeamRemote = remoteFolder:FindFirstChild("TeamRemote")
if not TeamRemote then
	TeamRemote = Instance.new("RemoteEvent")
	TeamRemote.Name = "TeamRemote"
	TeamRemote.Parent = remoteFolder
end

local ScoreRemote = remoteFolder:FindFirstChild("ScoreRemote")
if not ScoreRemote then
	ScoreRemote = Instance.new("RemoteEvent")
	ScoreRemote.Name = "ScoreRemote"
	ScoreRemote.Parent = remoteFolder
end

local WalletRemote = remoteFolder:FindFirstChild("WalletRemote")
if not WalletRemote then
	WalletRemote = Instance.new("RemoteEvent")
	WalletRemote.Name = "WalletRemote"
	WalletRemote.Parent = remoteFolder
end

local ShopRemote = remoteFolder:FindFirstChild("ShopRemote")
if not ShopRemote then
	ShopRemote = Instance.new("RemoteEvent")
	ShopRemote.Name = "ShopRemote"
	ShopRemote.Parent = remoteFolder
end

local TradeRemote = remoteFolder:FindFirstChild("TradeRemote")
if not TradeRemote then
	TradeRemote = Instance.new("RemoteEvent")
	TradeRemote.Name = "TradeRemote"
	TradeRemote.Parent = remoteFolder
end

local AuctionRemote = remoteFolder:FindFirstChild("AuctionRemote")
if not AuctionRemote then
	AuctionRemote = Instance.new("RemoteEvent")
	AuctionRemote.Name = "AuctionRemote"
	AuctionRemote.Parent = remoteFolder
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


local function safePrint(...)
	print("[MegaFramework]", ...)
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

local function isAdmin(player)
	return ADMIN_USERNAMES[player.Name] == true
end


local Profiles = {}
local EconomyProfiles = {}
local RoundStats = {}
local Parties = {}
local Auctions = {}

local PROFILE_TEMPLATE = {
	Level = 1,
	XP = 0,
	Gold = START_GOLD,
	Class = "Warrior",
	Inventory = {},
	CompletedQuests = {},
	ActiveQuests = {},
	Wins = 0,
	Losses = 0,
	TotalScore = 0,
}

local ECONOMY_TEMPLATE = {
	Balance = START_BALANCE,
	BankBalance = 0,
	Items = {},
}

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
	gold.Value = START_GOLD
	gold.Parent = leaderstats

	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = 0
	wins.Parent = leaderstats

	local losses = Instance.new("IntValue")
	losses.Name = "Losses"
	losses.Value = 0
	losses.Parent = leaderstats

	local totalScore = Instance.new("IntValue")
	totalScore.Name = "TotalScore"
	totalScore.Value = 0
	totalScore.Parent = leaderstats
end

local function getLeaderstats(player)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then return nil end
	local level = ls:FindFirstChild("Level")
	local xp = ls:FindFirstChild("XP")
	local gold = ls:FindFirstChild("Gold")
	local wins = ls:FindFirstChild("Wins")
	local losses = ls:FindFirstChild("Losses")
	local totalScore = ls:FindFirstChild("TotalScore")
	if level and xp and gold and wins and losses and totalScore then
		return {
			Level = level,
			XP = xp,
			Gold = gold,
			Wins = wins,
			Losses = losses,
			TotalScore = totalScore,
		}
	end
	return nil
end

local function loadProfile(player)
	local key = "Player_" .. player.UserId
	local success, data = pcall(function()
		return playerStore:GetAsync(key)
	end)

	local profile = deepCopy(PROFILE_TEMPLATE)
	if success and data then
		for k, v in pairs(data) do
			profile[k] = v
		end
		safePrint("Loaded profile for", player.Name)
	else
		safePrint("New profile for", player.Name)
	end

	Profiles[player] = profile

	local ls = getLeaderstats(player)
	if ls then
		ls.Level.Value = profile.Level
		ls.XP.Value = profile.XP
		ls.Gold.Value = profile.Gold
		ls.Wins.Value = profile.Wins
		ls.Losses.Value = profile.Losses
		ls.TotalScore.Value = profile.TotalScore
	end

	ProfileRemote:FireClient(player, "ProfileLoaded", profile)
end

local function saveProfile(player)
	local profile = Profiles[player]
	if not profile then return end

	local key = "Player_" .. player.UserId
	local success, err = pcall(function()
		playerStore:SetAsync(key, profile)
	end)

	if success then
		safePrint("Saved profile for", player.Name)
	else
		safePrint("Failed to save profile for", player.Name, err)
	end
end

local function loadEconomy(player)
	local key = "Economy_" .. player.UserId
	local success, data = pcall(function()
		return economyStore:GetAsync(key)
	end)

	local profile = deepCopy(ECONOMY_TEMPLATE)
	if success and data then
		for k, v in pairs(data) do
			profile[k] = v
		end
		safePrint("Loaded economy for", player.Name)
	else
		safePrint("New economy for", player.Name)
	end

	EconomyProfiles[player] = profile
	WalletRemote:FireClient(player, "EconomyLoaded", profile)
end

local function saveEconomy(player)
	local profile = EconomyProfiles[player]
	if not profile then return end

	local key = "Economy_" .. player.UserId
	local success, err = pcall(function()
		economyStore:SetAsync(key, profile)
	end)

	if success then
		safePrint("Saved economy for", player.Name)
	else
		safePrint("Failed to save economy for", player.Name, err)
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
		if ls then
			ls.Level.Value = profile.Level
			ls.XP.Value = profile.XP
		end
		ProfileRemote:FireClient(player, "LevelUp", profile.Level)
		safePrint(player.Name, "leveled up to", profile.Level)
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


local function changeBalance(player, amount)
	local profile = EconomyProfiles[player]
	if not profile then return end
	profile.Balance = profile.Balance + amount
	WalletRemote:FireClient(player, "BalanceChanged", profile.Balance)
end

local function changeBankBalance(player, amount)
	local profile = EconomyProfiles[player]
	if not profile then return end
	profile.BankBalance = profile.BankBalance + amount
	WalletRemote:FireClient(player, "BankBalanceChanged", profile.BankBalance)
end

local function econAddItem(player, itemName, quantity)
	quantity = quantity or 1
	local profile = EconomyProfiles[player]
	if not profile then return end
	profile.Items[itemName] = (profile.Items[itemName] or 0) + quantity
	WalletRemote:FireClient(player, "ItemsChanged", profile.Items)
end

local function econRemoveItem(player, itemName, quantity)
	quantity = quantity or 1
	local profile = EconomyProfiles[player]
	if not profile then return end
	local current = profile.Items[itemName] or 0
	current = current - quantity
	if current <= 0 then
		profile.Items[itemName] = nil
	else
		profile.Items[itemName] = current
	end
	WalletRemote:FireClient(player, "ItemsChanged", profile.Items)
end

local function econHasItem(player, itemName, quantity)
	quantity = quantity or 1
	local profile = EconomyProfiles[player]
	if not profile then return false end
	return (profile.Items[itemName] or 0) >= quantity
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

local function calculateDamage(attacker, target, baseOverride)
	local profile = Profiles[attacker]
	if not profile then return 0 end
	local classStats = getClassStats(profile.Class)
	local baseDamage = baseOverride or (classStats.BaseDamage + profile.Level)

	local crit = math.random() < classStats.CritChance
	local damage = baseDamage
	if crit then
		damage = damage * classStats.CritMultiplier
	end

	local targetProfile = Profiles[target]
	if targetProfile then
		local targetStats = getClassStats(targetProfile.Class)
		damage = damage - targetStats.Armor
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
	safePrint("Party created:", partyId, "Leader:", leader.Name)
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
		for member in pairs(party.Members) do
			PartyRemote:FireClient(member, "PartyDisbanded", partyId)
		end
		Parties[partyId] = nil
		safePrint("Party disbanded:", partyId)
	end
end

local function inviteToParty(partyId, inviter, target)
	local party = Parties[partyId]
	if not party then return end
	party.Invites[target] = tick()
	PartyRemote:FireClient(target, "PartyInvite", partyId, inviter.Name)
end

local PARTY_INVITE_TIMEOUT = 30

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


local QuestDefinitions = {
	["SlimeHunt"] = {
		Name = "Slime Hunt",
		Description = "Defeat 10 slimes.",
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

local QUEST_MAX_ACTIVE = 5

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
		acceptQuest(player, data.QuestId)
	elseif action == "ReportKill" then
		local enemyType = data.EnemyType
		if enemyType == "Slime" then
			updateQuestProgress(player, "SlimeHunt", "KillSlimes", 1)
		elseif enemyType == "ForestGuardian" then
			updateQuestProgress(player, "BossTrial", "KillBoss", 1)
		end
	end
end)


local function getMapsFolder()
	local folder = ServerStorage:FindFirstChild(MAPS_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = MAPS_FOLDER_NAME
		folder.Parent = ServerStorage
	end
	return folder
end

local function getAvailableMaps()
	local mapsFolder = getMapsFolder()
	local maps = {}
	for _, child in ipairs(mapsFolder:GetChildren()) do
		if child:IsA("Model") then
			table.insert(maps, child)
		end
	end
	return maps
end

local CurrentMapModel = nil
local CurrentMapName = "None"
local MapVotes = {}

local function resetMapVotes()
	MapVotes = {}
end

local function castMapVote(player, mapName)
	MapVotes[player] = mapName
	MapVoteRemote:FireAllClients("VoteUpdate", player.Name, mapName)
end

local function tallyMapVotes()
	local voteCounts = {}
	for _, mapName in pairs(MapVotes) do
		voteCounts[mapName] = (voteCounts[mapName] or 0) + 1
	end
	local bestMapName = nil
	local bestCount = -1
	for mapName, count in pairs(voteCounts) do
		if count > bestCount then
			bestCount = count
			bestMapName = mapName
		end
	end
	return bestMapName
end

local function loadMap(mapName)
	local mapsFolder = getMapsFolder()
	local chosenModel = mapsFolder:FindFirstChild(mapName)
	if not chosenModel then
		safePrint("Map not found:", mapName)
		return
	end
	if CurrentMapModel then
		CurrentMapModel:Destroy()
		CurrentMapModel = nil
	end
	local clone = chosenModel:Clone()
	clone.Parent = workspace
	CurrentMapModel = clone
	CurrentMapName = mapName
	RoundRemote:FireAllClients("MapLoaded", mapName)
	safePrint("Loaded map:", mapName)
end

local RoundState = "Lobby"
local RoundTimer = 0

local function setRoundState(state, duration)
	RoundState = state
	RoundTimer = duration or 0
	RoundRemote:FireAllClients("RoundState", RoundState, RoundTimer, CurrentMapName)
	safePrint("Round state:", RoundState, "Timer:", RoundTimer)
end

local function waitWithTimer(seconds, stateName)
	RoundTimer = seconds
	for i = seconds, 1, -1 do
		RoundTimer = i
		RoundRemote:FireAllClients("RoundTimer", stateName, RoundTimer)
		task.wait(1)
	end
end

local function resetRoundStats()
	RoundStats = {}
	for _, player in ipairs(Players:GetPlayers()) do
		RoundStats[player] = {
			Kills = 0,
			Objectives = 0,
			Score = 0,
			Team = nil,
		}
	end
end

local function addRoundScore(player, amount)
	local stats = RoundStats[player]
	if not stats then return end
	stats.Score = stats.Score + amount
	ScoreRemote:FireAllClients("ScoreUpdate", player.Name, stats.Score)
end

local function addRoundKill(player)
	local stats = RoundStats[player]
	if not stats then return end
	stats.Kills = stats.Kills + 1
	addRoundScore(player, 10)
end

local function addRoundObjective(player)
	local stats = RoundStats[player]
	if not stats then return end
	stats.Objectives = stats.Objectives + 1
	addRoundScore(player, 20)
end

local function assignTeams()
	local players = Players:GetPlayers()
	local redCount = 0
	local blueCount = 0
	for _, player in ipairs(players) do
		local stats = RoundStats[player]
		if stats then
			if redCount <= blueCount then
				stats.Team = TEAM_RED
				redCount += 1
			else
				stats.Team = TEAM_BLUE
				blueCount += 1
			end
			TeamRemote:FireClient(player, "TeamAssigned", stats.Team)
		end
	end
	safePrint("Teams assigned. Red:", redCount, "Blue:", blueCount)
end

local function getTeamScore(teamName)
	local total = 0
	for player, stats in pairs(RoundStats) do
		if stats.Team == teamName then
			total = total + stats.Score
		end
	end
	return total
end

local function rewardPlayers()
	for player, stats in pairs(RoundStats) do
		local profile = Profiles[player]
		if profile then
			profile.TotalScore = profile.TotalScore + stats.Score
			local ls = getLeaderstats(player)
			if ls then
				ls.TotalScore.Value = profile.TotalScore
			end
		end
	end
end

local function updateWinLoss(teamWinner)
	for player, stats in pairs(RoundStats) do
		local profile = Profiles[player]
		if profile then
			if stats.Team == teamWinner then
				profile.Wins = profile.Wins + 1
			else
				profile.Losses = profile.Losses + 1
			end
			local ls = getLeaderstats(player)
			if ls then
				ls.Wins.Value = profile.Wins
				ls.Losses.Value = profile.Losses
			end
		end
	end
end

local function runRoundLoop()
	while true do
		setRoundState("Lobby", ROUND_LOBBY_TIME)
		resetRoundStats()
		resetMapVotes()
		waitWithTimer(ROUND_LOBBY_TIME, "Lobby")

		if #Players:GetPlayers() < MIN_PLAYERS_TO_START then
			RoundRemote:FireAllClients("Announcement", "Not enough players to start a round.")
			task.wait(5)
			continue
		end

		setRoundState("Intermission", ROUND_INTERMISSION_TIME)
		local maps = getAvailableMaps()
		local mapNames = {}
		for _, mapModel in ipairs(maps) do
			table.insert(mapNames, mapModel.Name)
		end
		MapVoteRemote:FireAllClients("StartVoting", mapNames)
		waitWithTimer(ROUND_INTERMISSION_TIME, "Intermission")

		local chosenMapName = tallyMapVotes()
		if not chosenMapName then
			if #mapNames > 0 then
				chosenMapName = mapNames[math.random(1, #mapNames)]
			else
				chosenMapName = "None"
			end
		end

		loadMap(chosenMapName)

		setRoundState("Playing", ROUND_PLAY_TIME)
		assignTeams()
		waitWithTimer(ROUND_PLAY_TIME, "Playing")

		local redScore = getTeamScore(TEAM_RED)
		local blueScore = getTeamScore(TEAM_BLUE)
		local winner = nil
		if redScore > blueScore then
			winner = TEAM_RED
		elseif blueScore > redScore then
			winner = TEAM_BLUE
		else
			winner = "Tie"
		end

		RoundRemote:FireAllClients("RoundEnded", winner, redScore, blueScore)
		rewardPlayers()
		if winner ~= "Tie" then
			updateWinLoss(winner)
		end

		setRoundState("PostRound", ROUND_POST_TIME)
		waitWithTimer(ROUND_POST_TIME, "PostRound")
	end
end

MapVoteRemote.OnServerEvent:Connect(function(player, action, data)
	if action == "VoteMap" then
		castMapVote(player, data.MapName)
	end
end)

ScoreRemote.OnServerEvent:Connect(function(player, action, data)
	if action == "Kill" then
		addRoundKill(player)
	elseif action == "Objective" then
		addRoundObjective(player)
	end
end)


local ShopInventory = {
	["WoodSword"] = {
		BasePrice = 50,
		Stock = 999,
	},
	["IronSword"] = {
		BasePrice = 150,
		Stock = 50,
	},
	["HealthPotion"] = {
		BasePrice = 25,
		Stock = 200,
	},
}

local function getDynamicPrice(itemName)
	local item = ShopInventory[itemName]
	if not item then return nil end
	local stockFactor = math.max(0.5, math.min(2, 100 / (item.Stock + 1)))
	local price = math.floor(item.BasePrice * stockFactor)
	return price
end

local function buyItem(player, itemName, quantity)
	quantity = quantity or 1
	local item = ShopInventory[itemName]
	if not item then
		ShopRemote:FireClient(player, "Error", "Item not found.")
		return
	end

	local pricePer = getDynamicPrice(itemName)
	local totalPrice = pricePer * quantity
	local tax = math.floor(totalPrice * TAX_RATE)
	local finalCost = totalPrice + tax

	local profile = EconomyProfiles[player]
	if not profile then return end

	if profile.Balance < finalCost then
		ShopRemote:FireClient(player, "Error", "Not enough balance.")
		return
	end

	if item.Stock < quantity then
		ShopRemote:FireClient(player, "Error", "Not enough stock.")
		return
	end

	item.Stock = item.Stock - quantity
	changeBalance(player, -finalCost)
	econAddItem(player, itemName, quantity)

	ShopRemote:FireClient(player, "PurchaseSuccess", itemName, quantity, finalCost, tax)
	safePrint(player.Name, "bought", quantity, itemName, "for", finalCost, "(tax:", tax .. ")")
end

local function sellItem(player, itemName, quantity)
	quantity = quantity or 1
	if not econHasItem(player, itemName, quantity) then
		ShopRemote:FireClient(player, "Error", "You don't have enough of that item.")
		return
	end

	local item = ShopInventory[itemName]
	if not item then
		ShopRemote:FireClient(player, "Error", "Shop doesn't buy that item.")
		return
	end

	local pricePer = getDynamicPrice(itemName)
	local totalGain = math.floor(pricePer * quantity * 0.5)

	econRemoveItem(player, itemName, quantity)
	changeBalance(player, totalGain)

	item.Stock = item.Stock + quantity

	ShopRemote:FireClient(player, "SellSuccess", itemName, quantity, totalGain)
	safePrint(player.Name, "sold", quantity, itemName, "for", totalGain)
end

ShopRemote.OnServerEvent:Connect(function(player, action, data)
	if action == "Buy" then
		buyItem(player, data.ItemName, data.Quantity or 1)
	elseif action == "Sell" then
		sellItem(player, data.ItemName, data.Quantity or 1)
	end
end)


local ActiveTrades = {}

local function createTradeId(playerA, playerB)
	return "Trade_" .. playerA.UserId .. "_" .. playerB.UserId .. "_" .. tick()
end

local function startTrade(playerA, playerB)
	local tradeId = createTradeId(playerA, playerB)
	ActiveTrades[tradeId] = {
		A = playerA,
		B = playerB,
		OfferA = {
			Items = {},
			Money = 0,
		},
		OfferB = {
			Items = {},
			Money = 0,
		},
		ConfirmA = false,
		ConfirmB = false,
	}
	TradeRemote:FireClient(playerA, "TradeStarted", tradeId, playerB.Name)
	TradeRemote:FireClient(playerB, "TradeStarted", tradeId, playerA.Name)
	safePrint("Trade started:", tradeId, playerA.Name, "<->", playerB.Name)
end

local function getTradeById(tradeId)
	return ActiveTrades[tradeId]
end

local function addOfferItem(tradeId, player, itemName, quantity)
	local trade = getTradeById(tradeId)
	if not trade then return end

	local offer
	if player == trade.A then
		offer = trade.OfferA
		trade.ConfirmA = false
		trade.ConfirmB = false
	elseif player == trade.B then
		offer = trade.OfferB
		trade.ConfirmA = false
		trade.ConfirmB = false
	else
		return
	end

	if not econHasItem(player, itemName, quantity) then
		TradeRemote:FireClient(player, "Error", "You don't have enough of that item.")
		return
	end

	offer.Items[itemName] = (offer.Items[itemName] or 0) + quantity
	TradeRemote:FireClient(trade.A, "OfferUpdated", tradeId, "A", trade.OfferA)
	TradeRemote:FireClient(trade.B, "OfferUpdated", tradeId, "B", trade.OfferB)
end

local function addOfferMoney(tradeId, player, amount)
	local trade = getTradeById(tradeId)
	if not trade then return end

	local offer
	if player == trade.A then
		offer = trade.OfferA
		trade.ConfirmA = false
		trade.ConfirmB = false
	elseif player == trade.B then
		offer = trade.OfferB
		trade.ConfirmA = false
		trade.ConfirmB = false
	else
		return
	end

	local profile = EconomyProfiles[player]
	if not profile then return end

	if profile.Balance < amount then
		TradeRemote:FireClient(player, "Error", "Not enough balance.")
		return
	end

	offer.Money = amount
	TradeRemote:FireClient(trade.A, "OfferUpdated", tradeId, "A", trade.OfferA)
	TradeRemote:FireClient(trade.B, "OfferUpdated", tradeId, "B", trade.OfferB)
end

local function confirmTrade(tradeId, player)
	local trade = getTradeById(tradeId)
	if not trade then return end

	if player == trade.A then
		trade.ConfirmA = true
	elseif player == trade.B then
		trade.ConfirmB = true
	else
		return
	end

	TradeRemote:FireClient(trade.A, "ConfirmStatus", tradeId, trade.ConfirmA, trade.ConfirmB)
	TradeRemote:FireClient(trade.B, "ConfirmStatus", tradeId, trade.ConfirmA, trade.ConfirmB)

	if trade.ConfirmA and trade.ConfirmB then
		local profileA = EconomyProfiles[trade.A]
		local profileB = EconomyProfiles[trade.B]
		if not profileA or not profileB then return end

		for itemName, qty in pairs(trade.OfferA.Items) do
			if not econHasItem(trade.A, itemName, qty) then
				TradeRemote:FireClient(trade.A, "Error", "You no longer have required items.")
				TradeRemote:FireClient(trade.B, "Error", "Trade failed.")
				ActiveTrades[tradeId] = nil
				return
			end
		end

		for itemName, qty in pairs(trade.OfferB.Items) do
			if not econHasItem(trade.B, itemName, qty) then
				TradeRemote:FireClient(trade.B, "Error", "You no longer have required items.")
				TradeRemote:FireClient(trade.A, "Error", "Trade failed.")
				ActiveTrades[tradeId] = nil
				return
			end
		end

		if profileA.Balance < trade.OfferA.Money or profileB.Balance < trade.OfferB.Money then
			TradeRemote:FireClient(trade.A, "Error", "Insufficient balance.")
			TradeRemote:FireClient(trade.B, "Error", "Insufficient balance.")
			ActiveTrades[tradeId] = nil
			return
		end

		for itemName, qty in pairs(trade.OfferA.Items) do
			econRemoveItem(trade.A, itemName, qty)
			econAddItem(trade.B, itemName, qty)
		end

		for itemName, qty in pairs(trade.OfferB.Items) do
			econRemoveItem(trade.B, itemName, qty)
			econAddItem(trade.A, itemName, qty)
		end

		changeBalance(trade.A, -trade.OfferA.Money)
		changeBalance(trade.B, -trade.OfferB.Money)

		changeBalance(trade.A, trade.OfferB.Money)
		changeBalance(trade.B, trade.OfferA.Money)

		TradeRemote:FireClient(trade.A, "TradeCompleted", tradeId)
		TradeRemote:FireClient(trade.B, "TradeCompleted", tradeId)
		safePrint("Trade completed:", tradeId, trade.A.Name, "<->", trade.B.Name)
		ActiveTrades[tradeId] = nil
	end
end

local function cancelTrade(tradeId, player)
	local trade = getTradeById(tradeId)
	if not trade then return end
	TradeRemote:FireClient(trade.A, "TradeCancelled", tradeId)
	TradeRemote:FireClient(trade.B, "TradeCancelled", tradeId)
	safePrint("Trade cancelled:", tradeId, "by", player.Name)
	ActiveTrades[tradeId] = nil
end

TradeRemote.OnServerEvent:Connect(function(player, action, data)
	if action == "StartTrade" then
		local target = data.Target
		if typeof(target) == "Instance" and target:IsA("Player") then
			startTrade(player, target)
		end
	elseif action == "OfferItem" then
		addOfferItem(data.TradeId, player, data.ItemName, data.Quantity or 1)
	elseif action == "OfferMoney" then
		addOfferMoney(data.TradeId, player, data.Amount or 0)
	elseif action == "Confirm" then
		confirmTrade(data.TradeId, player)
	elseif action == "Cancel" then
		cancelTrade(data.TradeId, player)
	end
end)


local function createAuctionId(player, itemName)
	return "Auction_" .. player.UserId .. "_" .. itemName .. "_" .. tick()
end

local function listAuction(player, itemName, quantity, startingBid, duration)
	quantity = quantity or 1
	duration = duration or 120

	if not econHasItem(player, itemName, quantity) then
		AuctionRemote:FireClient(player, "Error", "You don't have enough of that item.")
		return
	end

	local auctionId = createAuctionId(player, itemName)
	Auctions[auctionId] = {
		Seller = player,
		ItemName = itemName,
		Quantity = quantity,
		HighestBid = startingBid,
		HighestBidder = nil,
		EndTime = tick() + duration,
	}

	econRemoveItem(player, itemName, quantity)
	AuctionRemote:FireAllClients("AuctionListed", auctionId, itemName, quantity, startingBid, duration)
	safePrint("Auction listed:", auctionId, itemName, "x" .. quantity, "starting at", startingBid)
end

local function placeBid(player, auctionId, amount)
	local auction = Auctions[auctionId]
	if not auction then
		AuctionRemote:FireClient(player, "Error", "Auction not found.")
		return
	end

	local profile = EconomyProfiles[player]
	if not profile then return end

	if profile.Balance < amount then
		AuctionRemote:FireClient(player, "Error", "Not enough balance.")
		return
	end

	if amount <= auction.HighestBid then
		AuctionRemote:FireClient(player, "Error", "Bid too low.")
		return
	end

	auction.HighestBid = amount
	auction.HighestBidder = player
	AuctionRemote:FireAllClients("BidPlaced", auctionId, player.Name, amount)
	safePrint(player.Name, "bid", amount, "on auction", auctionId)
end

local function finalizeAuction(auctionId)
	local auction = Auctions[auctionId]
	if not auction then return end

	local sellerProfile = EconomyProfiles[auction.Seller]
	if not sellerProfile then
		Auctions[auctionId] = nil
		return
	end

	if auction.HighestBidder then
		local bidderProfile = EconomyProfiles[auction.HighestBidder]
		if not bidderProfile then
			Auctions[auctionId] = nil
			return
		end

		if bidderProfile.Balance < auction.HighestBid then
			AuctionRemote:FireClient(auction.HighestBidder, "Error", "Insufficient balance at auction end.")
			Auctions[auctionId] = nil
			return
		end

		local fee = math.floor(auction.HighestBid * AUCTION_FEE_RATE)
		local net = auction.HighestBid - fee

		changeBalance(auction.HighestBidder, -auction.HighestBid)
		changeBalance(auction.Seller, net)

		econAddItem(auction.HighestBidder, auction.ItemName, auction.Quantity)

		AuctionRemote:FireAllClients("AuctionEnded", auctionId, auction.HighestBidder.Name, auction.HighestBid, fee)
		safePrint("Auction ended:", auctionId, "winner:", auction.HighestBidder.Name, "bid:", auction.HighestBid, "fee:", fee)
	else
		econAddItem(auction.Seller, auction.ItemName, auction.Quantity)
		AuctionRemote:FireAllClients("AuctionEnded", auctionId, nil, 0, 0)
		safePrint("Auction ended with no bids:", auctionId)
	end

	Auctions[auctionId] = nil
end

local function auctionHeartbeat()
	while true do
		local now = tick()
		for auctionId, auction in pairs(Auctions) do
			if now >= auction.EndTime then
				finalizeAuction(auctionId)
			end
		end
		task.wait(1)
	end
end

AuctionRemote.OnServerEvent:Connect(function(player, action, data)
	if action == "List" then
		listAuction(player, data.ItemName, data.Quantity or 1, data.StartingBid or 10, data.Duration or 120)
	elseif action == "Bid" then
		placeBid(player, data.AuctionId, data.Amount or 0)
	end
end)


local npcFolder = workspace:FindFirstChild("MegaNPCs")
if not npcFolder then
	npcFolder = Instance.new("Folder")
	npcFolder.Name = "MegaNPCs"
	npcFolder.Parent = workspace
end

local npcTemplate = ServerStorage:FindFirstChild("MegaNPC")

local function spawnNPC(position)
	if not npcTemplate then
		safePrint("No NPC template named 'MegaNPC' in ServerStorage")
		return
	end
	local npc = npcTemplate:Clone()
	npc.Parent = npcFolder
	npc:SetPrimaryPartCFrame(CFrame.new(position))

	task.spawn(function()
		while npc.Parent do
			local primary = npc.PrimaryPart
			if primary then
				local offset = Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))
				primary.CFrame = CFrame.new(primary.Position + offset)
			end
			task.wait(math.random(2, 5))
		end
	end)
end

task.spawn(function()
	while true do
		task.wait(20)
		local pos = Vector3.new(math.random(-50, 50), 5, math.random(-50, 50))
		spawnNPC(pos)
	end
end)


local function spawnBoss()
	local bossModel = ServerStorage:FindFirstChild("ForestGuardian")
	if not bossModel then
		safePrint("No boss model named 'ForestGuardian'")
		return
	end
	local boss = bossModel:Clone()
	boss.Parent = workspace
	boss:SetPrimaryPartCFrame(CFrame.new(0, 10, 0))
	WorldEventRemote:FireAllClients("BossSpawned", "ForestGuardian")
	safePrint("Boss spawned: ForestGuardian")
end

task.spawn(function()
	while true do
		task.wait(300)
		WorldEventRemote:FireAllClients("Announcement", "A powerful presence is felt...")
		task.wait(30)
		spawnBoss()
	end
end)


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
	elseif action == "ForceRound" then
		RoundRemote:FireAllClients("Announcement", "Admin forced round restart.")
	end
end)


Players.PlayerAdded:Connect(function(player)
	safePrint("Player joined:", player.Name)
	createLeaderstats(player)
	loadProfile(player)
	loadEconomy(player)
end)

Players.PlayerRemoving:Connect(function(player)
	safePrint("Player leaving:", player.Name)
	saveProfile(player)
	saveEconomy(player)
	Profiles[player] = nil
	EconomyProfiles[player] = nil
	RoundStats[player] = nil
end)

task.spawn(runRoundLoop)
task.spawn(auctionHeartbeat)

RunService.Heartbeat:Connect(function(dt)
	cleanupExpiredInvites()
end)
