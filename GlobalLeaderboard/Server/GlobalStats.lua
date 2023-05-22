--[[ SCRIPT OVERVIEW

This script is used for populating and displaying player stats across OrderedDataStores for creating
Global Leaderboards. Any amount of leaderboards can be passed to this script to be populated.

Instructions:

You must provide the StatConfig information for each DataStore you wish to use for Global Leaderboards.
A Max, Min, and NumDisplay value is required for each unique stat. Default num behaviour is not given by default.

The StoreConfig table contains configuration values for update retrieval times in normal situations and error cases.
]]

--1. High-level services--
local DSService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

--2. Remote Events and Functions--
local GlobalStatEV = game:GetService("ReplicatedStorage").GlobalStatEV

--3. Script-Wide Variables--

--#region Stat Variables

--Configuration related to each Stat being tracked and displayed
local StatConfig = {
	["WinsTest"] = {
		["Max"] = 255,			--The maximum stat value to retrieve
		["Min"] = 1,			--The minimum stat value to retrieve
		["NumDisplay"] = 26		--The number of entries to retrieve
	},
	["KillsTest"] = {
		["Max"] = 3000,
		["Min"] = 1,
		["NumDisplay"] = 26
	},
	["CoinsTest"] = {
		["Max"] = 50000,
		["Min"] = 1,
		["NumDisplay"] = 26
	}
}

--#endregion

--The datastores associated with the stat names
local statStores = {}

--Local Stat Leaderboards pulled from the DataStores (Top X Players)
local statLeaderboards = {}

--#region DataStore variables

--Configuration variables related to the DataStores
local StoreConfig = {
	["UpdateErrTime"] = 8,		--How long to wait between failed calls for updating a Player's value in an OrderedStore
	["RetrieveErrTime"] = 20,	--How long to wait between failed DS calls for retrieving data from the OrderedStore
	["RetrieveTime"] = 25		--How long to wait between calls to update the Global Leaderboards
}

--#endregion

--#region Utility variables

--Determines if the stat leaderboards have been built
local setupComplete = false

--Set of Players connected to the game waiting for aGlobalLeaderboard updates
local playersSubscribed = {}

--Cached usernames to help speed up Leaderboard display
local cachedNames = {}

--#endregion

--#region Testing variables
 local TEST_NAMES = {"Alpha","Beta","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Juliet","Kilo","Lima","Mike",
 	"November","Oscar","Papa","Quebec","Romeo","Sierra","Tango","Uniform","Victor","Whiskey","X-ray","Yankee","Zulu"
 }

 local TEST_DATA = {}

 --#endregion

local GlobalStatsFuncs = {}

--#region "Private" functions

--[TESTING] Utility function to generate fake data for testing purposes
local function _createTestData()

	for statName, statDetails in pairs(StatConfig) do
		local testMin = statDetails.Min
		local testMax = statDetails.Max
		local rand = Random.new(tick())

		for j, name in pairs(TEST_NAMES) do
			local testValue = rand:NextInteger(testMin, testMax)
			GlobalStatsFuncs.SetPlayerStat(j, testValue, statStores[statName])
			task.wait(0.25)
		end
	end
end


---Checks an individual Player's stat with the current stat leaders table.
---Ex. Player[wins] >= winLeaders[100]
---@param userId number
---@param userStats table
function GlobalStatsFuncs.ComparePlayerStats(userId, userStats)

	--Iterate through the Player's stats and compare with the Global Leaderboard stats registered
	for statName, statValue in pairs(userStats) do

		--Sanity check to make sure the stat specified exists within the global leaderboards
		if StatConfig[statName] then
			local minStatValue = GlobalStatsFuncs._GetStatMinimum(statName)

			if statValue > minStatValue then
				GlobalStatsFuncs.SetPlayerStat(userId, statValue, statStores[statName])
			end
		else
			warn(string.format("The stat %s is not tracked by any leaderboard.", statName))
		end
	end
end


---Set up all of the leaderboard guis i.e. when the server begins.
function GlobalStatsFuncs._Initialize()

	--Request the OrderedDataStores and create the Leaderboard tables
	for statName, statDetails in pairs(StatConfig) do
		statStores[statName] = DSService:GetOrderedDataStore(statName)
		statLeaderboards[statName] = {}
		GlobalStatsFuncs.GetTopPlayers(statName, statDetails)
	end

	--Periodically update the leaderboards
	local setupRoutine = coroutine.create(function()
		while true do
			task.wait(StoreConfig.RetrieveTime)

            --[TESTING] Repopulate the leaderboards with sample data
			_createTestData()

			GlobalStatsFuncs.UpdateLeaderboards()
		end
	end)

	coroutine.resume(setupRoutine)

	--If any Players joined the game before the Leaderboard data was retrieved, send it to those Players
	for _, plr in pairs(playersSubscribed) do
		GlobalStatEV:FireClient(plr, statLeaderboards)
	end

    setupComplete = true
end


---Retrieve the Player's username by their userId.
---@param userId number
---@return string
function GlobalStatsFuncs._GetNameById(userId)
	local userName = nil

	if userId then
		if cachedNames[userId] then
			userName = cachedNames[userId]
		else

			local player = Players:GetPlayerByUserId(userId)

			if player then
				cachedNames[userId] = player.Name
				userName = player.Name
			else

				pcall(function ()
					userName = Players:GetNameFromUserIdAsync(userId)
				end)
				cachedNames[userId] = userName
			end
		end

	end

	if not userName then
		userName = "Player" .. userId
	end

	return userName
end


---Retrieve the minimum amount for the given stat required for a Player to reach the top X Players of that stat
---@param statName string
---@return number
function GlobalStatsFuncs._GetStatMinimum(statName)
	local statMin = 0
	local numEntries = StatConfig[statName].NumDisplay

	if #statLeaderboards[statName] == numEntries then
		statMin = statLeaderboards[statName][numEntries].Count
	end

	return statMin
end

--#endregion

--#region "Public" Functions

---Retrieve the top X players of the given stat from the corresponding ordered datastore
---@param statName string
---@param statDetails table
function GlobalStatsFuncs.GetTopPlayers(statName, statDetails)
	local statLeaderStore = statStores[statName]
	local numEntries = statDetails.NumDisplay
	local statMin = statDetails.Min or 1
	local statMax = statDetails.Max or math.huge

	if statLeaderStore then
		local numTries = 0
		local success, response = nil

		repeat

			if numTries >= 1 then
				warn("Retrying retrieval... " .. "Previous error: " .. response)
				task.wait(StoreConfig.RetrieveTime)
			end

			--Call the Leaderboard retrieving [numEntries] players in descending order between the range ALL_MIN and statMax
			success, response = pcall(statLeaderStore.GetSortedAsync, statLeaderStore, false, numEntries, statMin, statMax)
			numTries += 1

		until success

		if success and response then
			local topPlayers = response:GetCurrentPage()
			for rank, statInfo in pairs(topPlayers) do
				statLeaderboards[statName][rank] = statLeaderboards[statName][rank] or {}

				--[TESTING] variant. Replace with the commented line below to get actual data
				statLeaderboards[statName][rank].Name = TEST_NAMES[tonumber(string.sub(statInfo.key, 3))]

				--Trim the "P_" prefix from leaderboard entries
				--statLeaderboards[statName][rank].Name = GlobalStatsFuncs._GetNameById(tonumber(string.sub(statInfo.key, 3)))
				statLeaderboards[statName][rank].Count = statInfo.value
			end
		end
	end
end


---Send a specific player the newly updated GlobalLeaderboard values
---@param player Player
function GlobalStatsFuncs.SendCurrentStandings(player)

	if setupComplete then
		GlobalStatEV:FireClient(player, statLeaderboards)
	else
		playersSubscribed[player.UserId] = player
	end
end


---Save a Player's stat for a leaderboard category to the corresponding ordered datastore
---@param userId number
---@param newStatValue number
---@param statLeaderStore DataStore
function GlobalStatsFuncs.SetPlayerStat(userId, newStatValue, statLeaderStore)

	local idString = "P_" .. userId

	local success, response = nil
	local numTries = 0

	repeat

		if numTries >= 1 then
			warn("Retrying update... " .. "Previous error: " .. response)
			task.wait(StoreConfig.UpdateErrTime)
		end

		success, response = pcall(statLeaderStore.UpdateAsync, statLeaderStore, idString, function(oldValue)

			local savedValue = oldValue or 0

			--Uncomment if only strictly increasing variables make sense
			--if savedValue < newStatValue then
				savedValue = newStatValue
			--end

			return savedValue
		end)
		numTries += 1

	until success
end


---Update each leaderboard for display
function GlobalStatsFuncs.UpdateLeaderboards()

	for statName, statDetails in pairs(StatConfig) do
		GlobalStatsFuncs.GetTopPlayers(statName, statDetails)
		task.wait(2)
	end

	GlobalStatEV:FireAllClients(statLeaderboards)
end

--#endregion

--Start listening for events from clients to send the current standings
GlobalStatEV.OnServerEvent:Connect(GlobalStatsFuncs.SendCurrentStandings)

return GlobalStatsFuncs
