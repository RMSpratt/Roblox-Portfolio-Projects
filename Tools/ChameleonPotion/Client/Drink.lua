--LOCAL SCRIPT

--Services
local ContextService = game:GetService("ContextActionService")

-- CHAMELEON POTION TOOL PROPERTIES --
local chameleonPotion = script.Parent
local handle = chameleonPotion.Handle

local TransformEv = chameleonPotion:FindFirstChild("TransformEV")

--Animations
local drinkAnimR6 = Instance.new("Animation")
drinkAnimR6.AnimationId = "rbxassetid://8827911151"

local drinkAnimR15 = Instance.new("Animation")
drinkAnimR15.AnimationId = "rbxassetid://8827781690"

--Animation track
local drinkAnimTrack = nil
local drinkGrip = nil

local grips = {
	Default = CFrame.new(0,-0.5,0, 1,0,0, 0,1,0, 0,0,1),
	DrinkR6 = CFrame.new(0,-0.5,0.5, 1,0,0, 0,0.703,0.711, 0,-0.711,0.703)
}

local wielder = nil

local ACTIVATE_CONTEXT_MOUSE = "transformClick"
local ACTIVATE_CONTEXT_TAP = "transformTap"

--#region ToolFunctions

---Check if the tool should be equipped by the user.
---@return boolean
local function isToolEquipped()
	local toolEquipped = false

	if wielder then
		local rightArm = wielder:FindFirstChild("Right Arm") or wielder:FindFirstChild("RightHand")

		if rightArm then
			local rightGrip = rightArm:FindFirstChild("RightGrip")

			if rightGrip and (rightGrip.Part0 == handle or rightGrip.Part1 == handle) then
				toolEquipped = true
			end
		end
	end

	return toolEquipped
end

---Check if the tool wielder is alive.
---@return boolean
local function isWielderAlive()
	local isAlive = false

	if wielder then
		local humanoid = wielder:FindFirstChild("Humanoid")

		if humanoid and humanoid.Health > 0 then
			isAlive = true
		end
	end

	return isAlive
end

---Get the target position of the user's mouse click to find the transformation target.
---@param _ any
---@param state Enum
---@param input table
local function getTransformTarget(_, state, input)

	if state == Enum.UserInputState.End then

		if chameleonPotion.Enabled then

			if not isWielderAlive() or not isToolEquipped() then
				ContextService:UnbindAction(ACTIVATE_CONTEXT_MOUSE)
				ContextService:UnbindAction(ACTIVATE_CONTEXT_TAP)

			else
				chameleonPotion.Grip = drinkGrip

				--Play the animation
				drinkAnimTrack:Play()

				--Convert the input's screen position to a position in the world
				local camera = workspace.CurrentCamera
				local unitRay = camera:ScreenPointToRay(input.Position.X, input.Position.Y)

				--Call the server to transform when the animation finishes
				drinkAnimTrack.Stopped:Connect(function()
					chameleonPotion.Grip = grips.Default
					TransformEv:FireServer(unitRay)
				end)
			end
		end
	end
end

--#endregion ToolFunctions

--#region Tool Event Callback Functions

---Callback function to the user equipping the ChameleonPotion tool.
local function onEquipped()
	wielder = chameleonPotion.Parent

	local humanoid = wielder:WaitForChild("Humanoid")

	if humanoid and humanoid.Animator then
		ContextService:BindAction(ACTIVATE_CONTEXT_MOUSE, getTransformTarget, false, Enum.UserInputType.MouseButton1)
		ContextService:BindAction(ACTIVATE_CONTEXT_TAP, getTransformTarget, false, Enum.UserInputType.Touch)

		--Get the appropriate animation by the humanoid RigType
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			drinkAnimTrack = humanoid.Animator:LoadAnimation(drinkAnimR15)
			drinkGrip = grips.Default

		else
			drinkAnimTrack = humanoid.Animator:LoadAnimation(drinkAnimR6)
			drinkGrip = grips.DrinkR6
		end
	end
end

---Callback function to the user unequipping the ChameleonPotion tool.
local function onUnequipped()
	ContextService:UnbindAction(ACTIVATE_CONTEXT_MOUSE)
	ContextService:UnbindAction(ACTIVATE_CONTEXT_TAP)
	wielder = nil
end

--#endregion

if not TransformEv then
	local childWait = nil

	childWait = script.Parent.ChildAdded:Connect(function(newChild)
		if newChild:IsA("RemoteEvent") then
			TransformEv = newChild
			childWait:Disconnect()
			childWait = nil
		end
	end)
end

--Event connections
chameleonPotion.Equipped:connect(onEquipped)
chameleonPotion.Unequipped:connect(onUnequipped)
