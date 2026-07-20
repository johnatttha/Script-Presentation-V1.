local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local SURVIVAL_STORE_NAME = "SurvivalFramework_Player_v1"
local survivalStore = DataStoreService:GetDataStore(SURVIVAL_STORE_NAME)

local MAX_HUNGER = 100
local MAX_THIRST = 100
local MAX_TEMPERATURE = 100
local MIN_TEMPERATURE = 0

local HUNGER_DECAY_PER_MIN = 2
local THIRST_DECAY_PER_MIN = 3
local TEMP_CHANGE_PER_MIN = 1

local DAY_LENGTH_SECONDS = 600
local WEATHER_CHECK_INTERVAL = 60

local PARTY_INVITE_TIMEOUT = 30

local RESOURCE_RESPAWN_TIME = 120

local RAID_INTERVAL_MIN = 300
local RAID_INTERVAL_MAX = 600

local ADMIN_USERNAMES = {
	["Johno11123"] = true,
}

local remoteFolder = ReplicatedStorage:FindFirstChild("Survival_Remotes")
if not remoteFolder then
	remoteFolder = Instance.new("Folder")
	remoteFolder.Name = "Survival_Remotes"
	remoteFolder.Parent = ReplicatedStorage
end

local ProfileRemote = remoteFolder:FindFirstChild("ProfileRemote")
if not ProfileRemote then
	ProfileRemote = Instance.new("RemoteEvent")
	ProfileRemote.Name = "ProfileRemote"
	ProfileRemote.Parent = remoteFolder
end

local SurvivalRemote = remoteFolder:FindFirstChild("SurvivalRemote")
if not SurvivalRemote then
	SurvivalRemote = Instance.new("RemoteEvent")
	SurvivalRemote.Name = "SurvivalRemote"
	SurvivalRemote.Parent = remoteFolder
end

local WorldRemote = remoteFolder:FindFirstChild("WorldRemote")
if not WorldRemote then
	WorldRemote = Instance.new("RemoteEvent")
	WorldRemote.Name = "WorldRemote"
	WorldRemote.Parent = remoteFolder
end

local ResourceRemote = remoteFolder:FindFirstChild("ResourceRemote")
if not ResourceRemote then
	ResourceRemote = Instance.new("RemoteEvent")
	ResourceRemote.Name = "ResourceRemote"
	ResourceRemote.Parent = remoteFolder
end

local CraftRemote = remoteFolder:FindFirstChild("CraftRemote")
if not CraftRemote then
	CraftRemote = Instance.new("RemoteEvent")
	CraftRemote.Name = "CraftRemote"
	CraftRemote.Parent = remoteFolder
end

local BuildRemote = remoteFolder:FindFirstChild("BuildRemote")
if not BuildRemote then
	BuildRemote = Instance.new("RemoteEvent")
	BuildRemote.Name = "BuildRemote"
	BuildRemote.Parent = remoteFolder
end

local PartyRemote = remoteFolder:FindFirstChild("PartyRemote")
if not PartyRemote then
	PartyRemote = Instance.new("RemoteEvent")
	PartyRemote.Name = "PartyRemote"
	PartyRemote.Parent = remoteFolder
end

local TradeRemote = remoteFolder:FindFirstChild("TradeRemote")
if not TradeRemote then
	TradeRemote = Instance.new("RemoteEvent")
	TradeRemote.Name = "TradeRemote"
	TradeRemote.Parent = remoteFolder
end

local RaidRemote = remoteFolder:FindFirstChild("RaidRemote")
if not RaidRemote then
	RaidRemote = Instance.new("RemoteEvent")
	RaidRemote.Name = "RaidRemote"
	RaidRemote.Parent = remoteFolder
end

local AdminRemote = remoteFolder:FindFirstChild("AdminRemote")
if not AdminRemote then
	AdminRemote = Instance.new("RemoteEvent")
	AdminRemote.Name = "AdminRemote"
	AdminRemote.Parent = remoteFolder
end

local function safePrint(...)
	print("[SurvivalFramework]", ...)
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
local Parties = {}
local ActiveTrades = {}

local PROFILE_TEMPLATE = {
	Hunger = MAX_HUNGER,
	Thirst = MAX_THIRST,
	Temperature = 50,
	DaysSurvived = 0,
	Deaths = 0,
	RaidsWon = 0,
	Inventory = {},
	Skills = {
		Woodcutting = 1,
		Mining = 1,
		Crafting = 1,
		Building = 1,
		Combat = 1,
	},
	UnlockedRecipes = {},
}

local function createLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local days = Instance.new("IntValue")
	days.Name = "DaysSurvived"
	days.Value = 0
	days.Parent = leaderstats

	local deaths = Instance.new("IntValue")
	deaths.Name = "Deaths"
	deaths.Value = 0
	deaths.Parent = leaderstats

	local raids = Instance.new("IntValue")
	raids.Name = "RaidsWon"
	raids.Value = 0
	raids.Parent = leaderstats
end

local function getLeaderstats(player)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then return nil end
	local days = ls:FindFirstChild("DaysSurvived")
	local deaths = ls:FindFirstChild("Deaths")
	local raids = ls:FindFirstChild("RaidsWon")
	if days and deaths and raids then
		return {
			DaysSurvived = days,
			Deaths = deaths,
			RaidsWon = raids,
		}
	end
	return nil
end

local function loadProfile(player)
	local key = "Survival_" .. player.UserId
	local success, data = pcall(function()
		return survivalStore:GetAsync(key)
	end)

	local profile = deepCopy(PROFILE_TEMPLATE)
	if success and data then
		for k, v in pairs(data) do
			profile[k] = v
		end
		safePrint("Loaded survival profile for", player.Name)
	else
		safePrint("New survival profile for", player.Name)
	end

	Profiles[player] = profile

	local ls = getLeaderstats(player)
	if ls then
		ls.DaysSurvived.Value = profile.DaysSurvived
		ls.Deaths.Value = profile.Deaths
		ls.RaidsWon.Value = profile.RaidsWon
	end

	ProfileRemote:FireClient(player, "ProfileLoaded", profile)
end

local function saveProfile(player)
	local profile = Profiles[player]
	if not profile then return end

	local key = "Survival_" .. player.UserId
	local success, err = pcall(function()
		survivalStore:SetAsync(key, profile)
	end)

	if success then
		safePrint("Saved survival profile for", player.Name)
	else
		safePrint("Failed to save survival profile for", player.Name, err)
	end
end

local function clamp(val, min, max)
	if val < min then return min end
	if val > max then return max end
	return val
end

local function changeHunger(player, amount)
	local profile = Profiles[player]
	if not profile then return end
	profile.Hunger = clamp(profile.Hunger + amount, 0, MAX_HUNGER)
	SurvivalRemote:FireClient(player, "HungerChanged", profile.Hunger)
end

local function changeThirst(player, amount)
	local profile = Profiles[player]
	if not profile then return end
	profile.Thirst = clamp(profile.Thirst + amount, 0, MAX_THIRST)
	SurvivalRemote:FireClient(player, "ThirstChanged", profile.Thirst)
end

local function changeTemperature(player, amount)
	local profile = Profiles[player]
	if not profile then return end
	profile.Temperature = clamp(profile.Temperature + amount, MIN_TEMPERATURE, MAX_TEMPERATURE)
	SurvivalRemote:FireClient(player, "TemperatureChanged", profile.Temperature)
end

local function applySurvivalDamage(player)
	local profile = Profiles[player]
	if not profile then return end

	local damage = 0
	if profile.Hunger <= 0 then
		damage = damage + 5
	end
	if profile.Thirst <= 0 then
		damage = damage + 10
	end
	if profile.Temperature <= 10 or profile.Temperature >= 90 then
		damage = damage + 5
	end

	if damage > 0 then
		SurvivalRemote:FireClient(player, "TakeSurvivalDamage", damage)
	end
end

local function survivalHeartbeat()
	local lastTick = tick()
	while true do
		task.wait(5)
		local now = tick()
		local dt = now - lastTick
		lastTick = now

		local minutes = dt / 60
		for player, profile in pairs(Profiles) do
			changeHunger(player, -HUNGER_DECAY_PER_MIN * minutes)
			changeThirst(player, -THIRST_DECAY_PER_MIN * minutes)
			applySurvivalDamage(player)
		end
	end
end

local function addItem(player, itemName, quantity)
	quantity = quantity or 1
	local profile = Profiles[player]
	if not profile then return end
	profile.Inventory[itemName] = (profile.Inventory[itemName] or 0) + quantity
	SurvivalRemote:FireClient(player, "InventoryChanged", profile.Inventory)
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
	SurvivalRemote:FireClient(player, "InventoryChanged", profile.Inventory)
end

local function hasItem(player, itemName, quantity)
	quantity = quantity or 1
	local profile = Profiles[player]
	if not profile then return false end
	return (profile.Inventory[itemName] or 0) >= quantity
end

local function addSkillXP(player, skillName, amount)
	local profile = Profiles[player]
	if not profile then return end
	local current = profile.Skills[skillName] or 1
	local newLevel = current + amount
	profile.Skills[skillName] = newLevel
	SurvivalRemote:FireClient(player, "SkillChanged", skillName, newLevel)
end

local WorldState = {
	TimeOfDay = 0,
	IsDay = true,
	Weather = "Clear",
}

local function updateWorldTime(dt)
	WorldState.TimeOfDay = (WorldState.TimeOfDay + dt) % DAY_LENGTH_SECONDS
	local halfDay = DAY_LENGTH_SECONDS / 2
	WorldState.IsDay = WorldState.TimeOfDay < halfDay
	WorldRemote:FireAllClients("TimeUpdate", WorldState.TimeOfDay, WorldState.IsDay)
end

local function randomWeather()
	local roll = math.random()
	if roll < 0.6 then
		WorldState.Weather = "Clear"
	elseif roll < 0.8 then
		WorldState.Weather = "Rain"
	else
		WorldState.Weather = "Storm"
	end
	WorldRemote:FireAllClients("WeatherUpdate", WorldState.Weather)
end

local function weatherHeartbeat()
	while true do
		task.wait(WEATHER_CHECK_INTERVAL)
		randomWeather()
	end
end

RunService.Heartbeat:Connect(function(dt)
	updateWorldTime(dt)
end)

local resourceFolder = workspace:FindFirstChild("SurvivalResources")
if not resourceFolder then
	resourceFolder = Instance.new("Folder")
	resourceFolder.Name = "SurvivalResources"
	resourceFolder.Parent = workspace
end

local ResourceDefinitions = {
	Tree = {
		Yield = {
			Wood = 3,
		},
		Skill = "Woodcutting",
	},
	Rock = {
		Yield = {
			Stone = 3,
		},
		Skill = "Mining",
	},
	WaterSource = {
		Yield = {
			WaterBottle = 1,
		},
		Skill = "None",
	},
}

local ResourceRespawnQueue = {}

local function registerResource(resource)
	resource:SetAttribute("IsDepleted", false)
end

for _, child in ipairs(resourceFolder:GetChildren()) do
	if child:IsA("Model") or child:IsA("Part") then
		registerResource(child)
	end
end

local function scheduleRespawn(resource)
	local id = resource:GetDebugId()
	ResourceRespawnQueue[id] = {
		Resource = resource,
		RespawnTime = tick() + RESOURCE_RESPAWN_TIME,
	}
end

local function respawnHeartbeat()
	while true do
		task.wait(5)
		local now = tick()
		for id, info in pairs(ResourceRespawnQueue) do
			if now >= info.RespawnTime then
				local res = info.Resource
				if res and res.Parent then
					res:SetAttribute("IsDepleted", false)
					ResourceRemote:FireAllClients("ResourceRespawned", res)
				end
				ResourceRespawnQueue[id] = nil
			end
		end
	end
end

local function gatherResource(player, resource)
	if not resource or not resource.Parent then return end
	if resource:GetAttribute("IsDepleted") then
		ResourceRemote:FireClient(player, "Error", "Resource is depleted.")
		return
	end

	local resType = resource:GetAttribute("ResourceType") or resource.Name
	local def = ResourceDefinitions[resType]
	if not def then
		ResourceRemote:FireClient(player, "Error", "Unknown resource.")
		return
	end

	for itemName, qty in pairs(def.Yield) do
		addItem(player, itemName, qty)
	end

	if def.Skill ~= "None" then
		addSkillXP(player, def.Skill, 1)
	end

	resource:SetAttribute("IsDepleted", true)
	ResourceRemote:FireAllClients("ResourceDepleted", resource)
	scheduleRespawn(resource)
end

ResourceRemote.OnServerEvent:Connect(function(player, action, data)
	if action == "Gather" then
		local resource = data.Resource
		if typeof(resource) == "Instance" then
			gatherResource(player, resource)
		end
	end
end)

local CraftingRecipes = {
	["Campfire"] = {
		Requires = {
			Wood = 5,
			Stone = 3,
		},
		UnlockSkill = "Building",
	},
	["WoodAxe"] = {
		Requires = {
			Wood = 3,
			Stone = 1,
		},
		UnlockSkill = "Woodcutting",
	},
	["StonePickaxe"] = {
		Requires = {
			Wood = 2,
			Stone = 3,
		},
		UnlockSkill = "Mining",
	},
}

local function canCraft(player, recipeName)
	local profile = Profiles[player]
	if not profile then return false, "No profile" end
	local recipe = CraftingRecipes[recipeName]
	if not recipe then return false, "Unknown recipe" end

	for itemName, qty in pairs(recipe.Requires) do
		if not hasItem(player, itemName, qty) then
			return false, "Missing " .. itemName
		end
	end

	return true
end

local function craftItem(player, recipeName)
	local ok, reason = canCraft(player, recipeName)
	if not ok then
		CraftRemote:FireClient(player, "Error", reason)
		return
	end

	local recipe = CraftingRecipes[recipeName]
	for itemName, qty in pairs(recipe.Requires) do
		removeItem(player, itemName, qty)
	end

	addItem(player, recipeName, 1)
	addSkillXP(player, recipe.UnlockSkill, 1)

	CraftRemote:FireClient(player, "CraftSuccess", recipeName)
end

CraftRemote.OnServerEvent:Connect(function(player, action, data)
	if action == "Craft" then
		craftItem(player, data.RecipeName)
	end
end)

local buildFolder = workspace:FindFirstChild("SurvivalBuilds")
if not buildFolder then
	buildFolder = Instance.new("Folder")
	buildFolder.Name = "SurvivalBuilds"
	buildFolder.Parent = workspace
end

local BuildTemplates = {
	Campfire = ServerStorage:FindFirstChild("Campfire"),
	Shelter = ServerStorage:FindFirstChild("Shelter"),
}

local function canPlaceBuild(player, buildName, position)
	local template = BuildTemplates[buildName]
	if not template then
		return false, "Unknown build"
	end

	if not hasItem(player, buildName, 1) then
		return false, "You must craft " .. buildName .. " first."
	end

	if position.Y < 0 then
		return false, "Invalid position."
	end

	return true
end

local function placeBuild(player, buildName, position)
	local ok, reason = canPlaceBuild(player, buildName, position)
	if not ok then
		BuildRemote:FireClient(player, "Error", reason)
		return
	end

	local template = BuildTemplates[buildName]
	if not template then return end

	local build = template:Clone()
	build.Parent = buildFolder
	if build:IsA("Model") and build.PrimaryPart then
		build:SetPrimaryPartCFrame(CFrame.new(position))
	elseif build:IsA("BasePart") then
		build.CFrame = CFrame.new(position)
	end

	removeItem(player, buildName, 1)
	BuildRemote:FireClient(player, "BuildPlaced", buildName, position)
end

BuildRemote.OnServerEvent:Connect(function(player, action, data)
	if action == "Place" then
		placeBuild(player, data.BuildName, data.Position)
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
		},
		OfferB = {
			Items = {},
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

	if not hasItem(player, itemName, quantity) then
		TradeRemote:FireClient(player, "Error", "You don't have enough of that item.")
		return
	end

	offer.Items[itemName] = (offer.Items[itemName] or 0) + quantity
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
		for itemName, qty in pairs(trade.OfferA.Items) do
			if not hasItem(trade.A, itemName, qty) then
				TradeRemote:FireClient(trade.A, "Error", "You no longer have required items.")
				TradeRemote:FireClient(trade.B, "Error", "Trade failed.")
				ActiveTrades[tradeId] = nil
				return
			end
		end

		for itemName, qty in pairs(trade.OfferB.Items) do
			if not hasItem(trade.B, itemName, qty) then
				TradeRemote:FireClient(trade.B, "Error", "You no longer have required items.")
				TradeRemote:FireClient(trade.A, "Error", "Trade failed.")
				ActiveTrades[tradeId] = nil
				return
			end
		end

		for itemName, qty in pairs(trade.OfferA.Items) do
			removeItem(trade.A, itemName, qty)
			addItem(trade.B, itemName, qty)
		end

		for itemName, qty in pairs(trade.OfferB.Items) do
			removeItem(trade.B, itemName, qty)
			addItem(trade.A, itemName, qty)
		end

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
	elseif action == "Confirm" then
		confirmTrade(data.TradeId, player)
	elseif action == "Cancel" then
		cancelTrade(data.TradeId, player)
	end
end)

local raidFolder = workspace:FindFirstChild("SurvivalRaiders")
if not raidFolder then
	raidFolder = Instance.new("Folder")
	raidFolder.Name = "SurvivalRaiders"
	raidFolder.Parent = workspace
end

local raiderTemplate = ServerStorage:FindFirstChild("RaiderNPC")

local function spawnRaiders(targetPosition, count)
	if not raiderTemplate then
		safePrint("No raider template named 'RaiderNPC'")
		return
	end

	for i = 1, count do
		local npc = raiderTemplate:Clone()
		npc.Parent = raidFolder
		npc:SetPrimaryPartCFrame(CFrame.new(targetPosition + Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))))

		task.spawn(function()
			while npc.Parent do
				local primary = npc.PrimaryPart
				if primary then
					local offset = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
					primary.CFrame = CFrame.new(primary.Position + offset)
				end
				task.wait(math.random(1, 3))
			end
		end)
	end

	RaidRemote:FireAllClients("RaidStarted", targetPosition, count)
end

local function randomBasePosition()
	return Vector3.new(math.random(-100, 100), 5, math.random(-100, 100))
end

local function raidHeartbeat()
	while true do
		local waitTime = math.random(RAID_INTERVAL_MIN, RAID_INTERVAL_MAX)
		task.wait(waitTime)
		local pos = randomBasePosition()
		spawnRaiders(pos, math.random(3, 8))
	end
end

AdminRemote.OnServerEvent:Connect(function(player, action, data)
	if not isAdmin(player) then
		safePrint(player.Name, "attempted admin action:", action)
		return
	end

	if action == "GiveItem" then
		local target = data.Target
		local itemName = data.ItemName
		local qty = data.Quantity or 1
		if typeof(target) == "Instance" and target:IsA("Player") then
			addItem(target, itemName, qty)
		end
	elseif action == "SetWeather" then
		WorldState.Weather = data.Weather or "Clear"
		WorldRemote:FireAllClients("WeatherUpdate", WorldState.Weather)
	elseif action == "ForceRaid" then
		local pos = data.Position or randomBasePosition()
		spawnRaiders(pos, data.Count or 5)
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

task.spawn(survivalHeartbeat)
task.spawn(respawnHeartbeat)
task.spawn(weatherHeartbeat)
task.spawn(raidHeartbeat)

RunService.Heartbeat:Connect(function(dt)
	cleanupExpiredInvites()
end)
