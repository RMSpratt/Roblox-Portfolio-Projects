--1. High-level services--
local RStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--2. Remote Events and Functions--
local GlobalStatEV = RStorage:WaitForChild("GlobalStatEV")

--3. Script-Wide Variables--
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--3a. Setup Variables--
local isInitialized = false
local isUpdating = false

--3b. Stat-related Variables--
local statLeaderboards = {}

--#region Tweening variables
local rubberTween = TweenInfo.new(
	4,
	Enum.EasingStyle.Elastic,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local linearTween = TweenInfo.new(
	2,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local TweenConfig = {
	["TweenOffsetTime"] = 0.2,	        	--How long to wait in-between tweening each ranked frame
	["TweenGoalX"] = UDim.new(0.5,0),   	--The goal position for the frame on-screen
	["TweenStartX"] = UDim.new(-0.5,0), 	--The starting off-screen position for the frame
	["TweenEndX"] = UDim.new(1.5,0)     	--The ending off-screen position for the frame
}

--#endregion

--#region Functions

---Play an initialize tween to get the frames on-screen
---@param rankFrame Frame
---@param statInfo table
---@param tweenInfo TweenInfo
local function playInitTween(rankFrame, statInfo, tweenInfo)
	local goalPos = UDim2.new(TweenConfig.TweenGoalX.Scale, TweenConfig.TweenGoalX.Offset, rankFrame.Position.Y.Scale, rankFrame.Position.Y.Offset)

	rankFrame.Content.Value.Text = statInfo.Count
	rankFrame.Content.Username.Text = statInfo.Name
	rankFrame.Visible = true

	TweenService:Create(rankFrame, tweenInfo.InTween, {Position = goalPos}):Play()
end

---Play an update tween to change the frame values.
---@param rankFrame Frame
---@param statInfo table
---@param tweenInfo TweenInfo
local function playUpdateTween(rankFrame, statInfo, tweenInfo)
	local goalEndPos = UDim2.new(TweenConfig.TweenEndX.Scale, TweenConfig.TweenEndX.Offset, rankFrame.Position.Y.Scale, rankFrame.Position.Y.Offset)
	local goalPos = UDim2.new(TweenConfig.TweenGoalX.Scale, TweenConfig.TweenGoalX.Offset, rankFrame.Position.Y.Scale, rankFrame.Position.Y.Offset)
	local outTween = TweenService:Create(rankFrame, tweenInfo.OutTween, {Position = goalEndPos})
	local inTween = TweenService:Create(rankFrame, tweenInfo.InTween, {Position = goalPos})

	--Update the new frame values off-screen
	--Tween the frame back on-screen
	outTween.Completed:Connect(function()
		rankFrame.Content.Value.Text = statInfo.Count
		rankFrame.Content.Username.Text = statInfo.Name
		rankFrame.Position = UDim2.new(TweenConfig.TweenStartX.Scale, TweenConfig.TweenStartX.Offset, rankFrame.Position.Y.Scale, rankFrame.Position.Y.Offset)
		task.wait(2)
		inTween:Play()
	end)

	outTween:Play()
end


---Initialize the leaderboards for display
local function initializeLists()
	local leaderboardList = PlayerGui:WaitForChild("Leaderboards"):GetChildren()

	for _, leaderboard in pairs(leaderboardList) do
		statLeaderboards[leaderboard.Name] = leaderboard
	end
	GlobalStatEV:FireServer()
end

--#endregion

--#region Remote Event Callback Functions

--Listen for events from the server to update the leaderboards
GlobalStatEV.OnClientEvent:Connect(function(statInfo)

	--Ignore updates if the leaderboards are mid-update
	if not isUpdating then
		isUpdating = true

		--Determine the tween animation to use for frames
		local tweenFunc = nil

		if isInitialized then
			tweenFunc = playUpdateTween
		else
			tweenFunc = playInitTween
		end

		--Update each leaderboard
		for statName, playerList in pairs(statInfo) do
			local leaderboard = statLeaderboards[statName]
			local leaderboardList = leaderboard.Body.List
			leaderboardList.CanvasSize = UDim2.new(0,0,0,95 * #playerList)

			--Iterate through all of the player rankings for display
			for i, rankInfo in ipairs(playerList) do

				local rankFrame = leaderboardList:FindFirstChild(i)

				--Create new frames as they're needed
				if not rankFrame then
					rankFrame = leaderboard.ExampleRank:Clone()
					rankFrame.Name = i
					rankFrame.Content.RankFrame.Rank.Text = i
					rankFrame.Position = UDim2.new(-0.5,0,0,95*(i-1))
					rankFrame.Parent = leaderboardList
				end

				--Bring the frame in for display
				--You can specify whichever Tween you want here for In and Out moves
				tweenFunc(rankFrame, rankInfo, {["InTween"] = rubberTween, ["OutTween"] = linearTween})

				task.wait(TweenConfig.TweenOffsetTime)
			end
		end

		if not isInitialized then
			isInitialized = true
		end

		isUpdating = false
	end
end)

--#endregion

initializeLists()