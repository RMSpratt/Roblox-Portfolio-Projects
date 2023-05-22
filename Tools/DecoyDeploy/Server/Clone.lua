--Services
local Debris = game:GetService("Debris")

-- DECOY DEPLOY TOOL PROPERTIES --
local decoyDeploy = script.Parent
local handle = decoyDeploy.Handle

--The current tool wielder
local wielder = nil

--Sound effect
local drinkSfx = Instance.new("Sound")
drinkSfx.SoundId = "rbxassetid://29529397"
drinkSfx.Parent = handle

--Animations
local drinkAnimR6 = Instance.new("Animation")
drinkAnimR6.AnimationId = "rbxassetid://8821191958"

local drinkAnimR15 = Instance.new("Animation")
drinkAnimR15.AnimationId = "rbxassetid://8820886090"

--Animation track
local drinkAnimTrack = nil

--CONFIG VARIABLES

local Config = {
	CLONE_LT = 60,			--Clone lifetime (Default=60)
	TOOL_RELOAD = 15,		--Tool cooldown (Default=15)
	SINGLE_CLONE = false,	--Restrict only one clone? (Default=false)
	USE_CLONE_LT = true,	--Automatically destroy clones after lifetime? (Default=true)
	USE_IDLE = true,		--Play idle animation on clone(s)? (Default=false)
    EXPLODE_BLAST_PRESSURE = 25
}


--The old clone of the player
local oldClone = nil

local cloneAnimEV = nil

--#region Tool Functions

---Creates an exact replica of the Player.
local function createClone()

	if not wielder.Archivable then
		wielder.Archivable = true
	end

	if Config.SINGLE_CLONE and oldClone then
		oldClone:Destroy()
	end

	local clone = wielder:Clone()

	if clone then
		clone.PrimaryPart.CFrame = wielder.PrimaryPart.CFrame + wielder.PrimaryPart.CFrame.LookVector * 5
		clone.Parent = workspace

		local humanoid = clone:FindFirstChild("Humanoid")

		if humanoid then
            local forcefield = clone:FindFirstChildOfClass("ForceField")

			humanoid:UnequipTools()

			--Connect a self-destruct function to the clone if it's killed
			humanoid.Died:Connect(function()
				if humanoid.Parent and humanoid.Parent.PrimaryPart then
					local explosion = Instance.new("Explosion")
					explosion.BlastPressure = Config.EXPLODE_BLAST_PRESSURE
					explosion.Position = humanoid.Parent.PrimaryPart.Position
					explosion.Parent = workspace
					Debris:AddItem(explosion,3)
					Debris:AddItem(clone, 3)
				end
			end)

			--Have the clone idle (for extra realism)
			if Config.USE_IDLE and humanoid.Animator and humanoid.RigType == Enum.HumanoidRigType.R15 then
				local animateScript = clone:WaitForChild("Animate")
				local idleAnim = animateScript.idle.Animation1
				local idleTrack = humanoid.Animator:LoadAnimation(idleAnim)
				idleTrack:Play()
			end

            if forcefield then
                forcefield:Destroy()
            end
		end

		--Remove the clone after a given lifetime
		if Config.USE_CLONE_LT then
			Debris:AddItem(clone, Config.CLONE_LT)
		end

		oldClone = clone
	end
end

---Check if the Tool can be equipped by the wielder Player
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

---Check if the tool wielder is alive
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

--#endregion

--#region Tool Event Callback Functions

---Tool.Activated callback function.
local function onActivate()

	if decoyDeploy.Enabled and isToolEquipped() and isWielderAlive() then
		decoyDeploy.Enabled = false

		--Spawn a clone when the drink animation ends
        if not cloneAnimEV then
            cloneAnimEV = drinkAnimTrack.Stopped:Connect(function()
                createClone()
                task.wait(Config.TOOL_RELOAD)
                decoyDeploy.Enabled = true

                --Ensure the player still has the tool equipped
                if cloneAnimEV then
                    cloneAnimEV:Disconnect()
                    cloneAnimEV = nil
                end
            end)

            --Play the drink animation
            drinkAnimTrack:Play()
        end
	end
end

---Tool.Equipped callback function
local function onEquip()
	local character = decoyDeploy.Parent
	local humanoid = character:FindFirstChild("Humanoid")

	wielder = character

	if isWielderAlive() then

		if humanoid and humanoid.Animator then

			--Get the appropriate animation by the humanoid RigType
			if humanoid.RigType == Enum.HumanoidRigType.R15 then
				drinkAnimTrack = humanoid.Animator:LoadAnimation(drinkAnimR15)

			else
				drinkAnimTrack = humanoid.Animator:LoadAnimation(drinkAnimR6)
			end

			--Hook up the drink sound event
			drinkAnimTrack:GetMarkerReachedSignal("drinkSfx"):Connect(function()
				drinkSfx:Play()
			end)
		end
	end
end

---Tool.Unequipped callback function
local function onUnequip()
	wielder = nil
	cloneAnimEV = nil
end

--#endregion

--Event callbacks
decoyDeploy.Equipped:Connect(onEquip)
decoyDeploy.Unequipped:Connect(onUnequip)
decoyDeploy.Activated:Connect(onActivate)