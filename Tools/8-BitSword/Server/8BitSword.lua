--Services
local RunService = game:GetService("RunService")
local SScriptService = game:GetService("ServerScriptService")

--Modules
local MeleeWeaponMod = require(SScriptService.MeleeWeapon)
local BitSizeEffectMod = require(script.Parent.BitsizePlayer)

--Instance of a MeleeWeapon providing base melee utility functions
local BitSword = MeleeWeaponMod.New(script.Parent)


--#region Bitsword Weapon Properties
local bitSword = script.Parent
local handle = bitSword.Handle

local Animations = {
	Slash = bitSword.Slash,
	Lunge = bitSword.Lunge
}

local DamageValues = {
	Touch = 9,
	Slash = 13,
	Lunge = 17,
}

local Grips = {
	Up = CFrame.new(0, 0.05, 1.5, 1, 0, -0, 0, 0, 1, 0, -1, 0),
	Out = CFrame.new(0, 0.05, 1.5, 1, 0, -0, 0, 1, 0, 0, 0, 1),
}

local sounds = {
	Unsheath = handle:WaitForChild("Unsheath"),
	Slash = handle:WaitForChild("Slash"),
	Lunge = handle:WaitForChild("Lunge"),
}

--Animation tracks
local slashAnimTrack = nil
local lungeAnimTrack = nil

local lastAttackTime = 0

--The time interval the player has to perform a lunge attack after an initial slice
local LUNGE_WINDOW_TIME = 0.25

--Set the default properties of the sword
bitSword.Grip = Grips.Up
bitSword.Enabled = true

--#endregion

--#region Weapon Functions

---Touched callback when the sword makes contact with the player.
---@param target Instance
local function Blow(target)

	--1) Verify a part was hit with a parent model or part
	if target and target.Parent then

		--2) Verify the user's ability to use the weapon
		if BitSword:IsWielderAlive() then

			if BitSword.IsEquipped then
				local isAttached = BitSword:IsWeaponEquipped()

				if isAttached then
					local targetPlrChar = target.Parent

					--3) Verify that another alive player was struck
					if targetPlrChar ~= BitSword.Wielder then
						local humanoid = targetPlrChar:FindFirstChild("Humanoid")

						if humanoid and humanoid.Health > 0 then
							humanoid:TakeDamage(BitSword.CurrentDamage)

							if humanoid.Health <= 0 then
								BitSizeEffectMod.GenerateBitModel(targetPlrChar)
							end
						end
					end
				end
			end
		end
	end
end

---Slashing attack motion.
local function slash()
	sounds.Slash:Play()
	slashAnimTrack:Play()
end


---Lunging attack motion.
local function lunge()
	BitSword.CurrentDamage = DamageValues.Lunge
	sounds.Lunge:Play()
	lungeAnimTrack:Play()
	task.wait(0.2)
	bitSword.Grip = Grips.Out
	task.wait(0.6)
	bitSword.Grip = Grips.Up
	BitSword.CurrentDamage = DamageValues.Slash
end

--#endregion

--#region WeaponEvent Functions

---Event callback handler for weapon activation.
local function onActivated()
	if bitSword.Enabled and BitSword.IsEquipped and BitSword:IsWielderAlive() then
		bitSword.Enabled = false

		--Determine which attack to perform based on the user's input timing
		local frameTime = RunService.Stepped:Wait()

		if frameTime - lastAttackTime < LUNGE_WINDOW_TIME then
			lunge()
		else
			slash()
		end

		BitSword.CurrentDamage = DamageValues.Touch
		lastAttackTime = frameTime
		bitSword.Enabled = true
	end
end

---Event callback handler for equipping the weapon.
local function onEquip()
	BitSword.Wielder = bitSword.Parent
	BitSword.IsEquipped = true
	bitSword.Grip = Grips.Up
	sounds.Unsheath:Play()

	if BitSword:IsWielderAlive() then
		BitSword.CurrentDamage = DamageValues.Touch

		local humanoid = BitSword.Wielder:FindFirstChild("Humanoid")

		if humanoid and humanoid.Animator then
			slashAnimTrack = humanoid.Animator:LoadAnimation(Animations.Slash)
			lungeAnimTrack = humanoid.Animator:LoadAnimation(Animations.Lunge)
		end
	end
end

---Event callback handler for unequippiung the weapon.
local function onUnequip()
	bitSword.Grip = Grips.Up
	BitSword.IsEquipped = false
	BitSword.Wielder = nil
	slashAnimTrack = nil
	lungeAnimTrack = nil
end

--#endregion

--Hook up the event callback functions
bitSword.Activated:Connect(onActivated)
bitSword.Equipped:Connect(onEquip)
bitSword.Unequipped:Connect(onUnequip)
bitSword.Handle.Touched:Connect(Blow)