local Players = game:GetService("Players")

local MELEE_TAG = "MeleeWeapon"

---ModuleScript functions for handling Melee Weapons
local MeleeWeapon = {}

--Required for setting the object metatable
MeleeWeapon.__index = MeleeWeapon

---Sets up the passed weapon tool with these functions for use.
---@param weapon Instance
---@return table
function MeleeWeapon.new(weapon)
	local self = {}
	setmetatable(self, MeleeWeapon)

	self.CurrentDamage = 0
	self.IsEquipped = false
	self.WeaponHandle = weapon.Handle
	self.Wielder = nil

	return self
end

---Enable touch damage for the weapon handle.
function MeleeWeapon:ActivateTouchDamage()

	if self.WeaponHandle then
		self.WeaponHandle.Touched:Connect(function(part)
			self:OnHit(part)
		end)
	end
end

---Check if the weapon wielding player is on the same team as the target player.
---@param wielderPlr Player
---@param targetPlr Player
---@return boolean
function MeleeWeapon:IsTeammate(wielderPlr, targetPlr)
	local isTeammate = false

	if wielderPlr.Neutral == false and targetPlr.Neutral == false then

        if wielderPlr.TeamColor == targetPlr.TeamColor then
			isTeammate = true
		end
	end

    return isTeammate
end


---Determines if the Player can be wielding a weapon.
---@return boolean
function MeleeWeapon:IsWeaponEquipped()
	local isEquipped = false
	local rightArm = self.Wielder:FindFirstChild("Right Arm") or self.Wielder:FindFirstChild("RightHand")

	if rightArm then
		local rightGrip = rightArm:FindFirstChild("RightGrip")

		if rightGrip and (rightGrip.Part0 == self.WeaponHandle or rightGrip.Part1 == self.WeaponHandle) then
			isEquipped = true
		end
	end

	return isEquipped
end

---Determines if the Player is alive.
---@return boolean
function MeleeWeapon:IsWielderAlive()
	local isAlive = false

	if self.Wielder then
		local humanoid = self.Wielder:FindFirstChild("Humanoid")

		if humanoid and humanoid.Health > 0 then
			isAlive = true
		end
	end

	return isAlive
end

---Basic callback for applying damage to a target for a MeleeWeapon.
---@param target Instance
---@param configOptions table
function MeleeWeapon:OnHit(target, configOptions)

	--1) Verify a part was hit with a parent model or part
	if target and target.Parent then

		--2) Verify the user's ability to use the weapon
		if self:IsWielderAlive() then

			if self.IsEquipped then
				local isAttached = self:IsWeaponEquipped()

				if isAttached then
					local targetPlrChar = target.Parent

					--3) Verify that another alive player was struck
					if targetPlrChar ~= self.Wielder then
						local humanoid = targetPlrChar:FindFirstChild("Humanoid")

						if humanoid and humanoid.Health > 0 then

							--4) OPTIONAL: Ensure the Players are on separate teams
							if configOptions and configOptions.TeamsActive then
								local wielderPlr = Players:GetPlayerFromCharacter(self.Wielder)
								local targetPlr = Players:GetPlayerFromCharacter(targetPlrChar)

								if targetPlr then

									if self:IsTeammate(wielderPlr, targetPlr) then
										print("No friendly fire!")
										return
									end
								end
							end
							humanoid:TakeDamage(self.CurrentDamage)
						end
					end
				end
			end
		end
	end
end

--Can be used for tracking leaderboard stats

-- function MeleeWeapon:TagTarget()

-- end

-- function MeleeWeapon:TagTargetAttrib()

-- end

local MeleeWeaponAccess = {}

function MeleeWeaponAccess.New(weapon)
	local newMeleeWeapon = MeleeWeapon.new(weapon)
	return newMeleeWeapon
end

return MeleeWeaponAccess
