--ServerScript

local Players = game:GetService("Players")

-- CHAMELEON POTION TOOL PROPERTIES --
local chameleonPotion = script.parent
local handle = chameleonPotion.Handle
local isEquipped = false

--Timer to keep track of when to revert the Player's appearance
local revertTimer = 0

--Remote event when the Player drinks the potion
local TransformEv = chameleonPotion:FindFirstChild("TransformEV")

--Coroutine to revert the player when transformation wears off
local revertCo = nil

--Wielder properties
local wielder = nil
local wielderPlr = nil
local wielderDescription = nil

--Config
local Config = {
	TRANSFORM_COOLDOWN_LENGTH = 10,
	REVERT_COOLDOWN_LENGTH = 60,
	TRANSFORM_RANGE = 200,
	HIDE_NAME = true,
	DEFAULT_SHIRT = 'http://www.roblox.com/asset/?id=855777285',
	DEFAULT_PANTS = 'http://www.roblox.com/asset/?id=867826313'
}

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
		local humanoid = wielder.Humanoid

		if humanoid and humanoid.Health > 0 then
			isAlive = true
		end
	end

	return isAlive
end

---Transform the Player into the target Player/Humanoid Character using their raycast mouse click.
---@param origin Vector3
---@param direction Vector3
---@param params RaycastParams
local function transform(origin, direction, params)
	local hit = workspace:Raycast(origin, direction * Config.TRANSFORM_RANGE)

	--Determine the target of the raycast
	if hit and hit.Instance and hit.Instance.Parent then
		local target = hit.Instance.Parent

		--Workaround for Accessories worn by a player
		--Recursive search is another option
		if target:IsA("Accessory") and target.Parent then
			target = target.Parent
		end

		local humanoid = target:FindFirstChild("Humanoid")

		if humanoid then
			local desc = humanoid:GetAppliedDescription()
			wielder.Humanoid:ApplyDescription(desc)
			
			local wielderTShirt = wielder:FindFirstChild("ShirtGraphic")
			local wielderShirt = wielder:FindFirstChildOfClass("Shirt")
			local wielderPants = wielder:FindFirstChildOfClass("Pants")
			
			if wielderTShirt == nil and wielderShirt == nil then
				wielderTShirt = Instance.new("Shirt")
				wielderTShirt.Parent = wielder
				wielderTShirt.ShirtTemplate = Config.DEFAULT_SHIRT
			end
			
			if wielderPants == nil then
				wielderPants = Instance.new("Pants")
				wielderPants.Parent = wielder
				wielderPants.PantsTemplate = Config.DEFAULT_PANTS
			end
			
			revertTimer = Config.REVERT_COOLDOWN_LENGTH

			if Config.HIDE_NAME then
				wielder.Humanoid.DisplayName = " "
			end

			--(OPTIONAL) Shedletsky's crown can't be loaded as normal, so add it manually
			--if desc.HatAccessory and string.match(desc.HatAccessory, "1078202") then
			--	wielder.Humanoid:AddAccessory(game:GetService("InsertService"):LoadAsset(1078202))
			--end

			--Revert the Player to their original appearance
			--Don't create more than one consecutive coroutine
			if not revertCo or coroutine.status(revertCo) == "dead" then
				print("Create a couroutine.")
				revertCo = coroutine.create(function()
					while revertTimer > 0 do
						task.wait(1)
						revertTimer -= 1
					end

					print("Revert back!")
					if isWielderAlive() then
						wielder.Humanoid:ApplyDescription(wielderDescription)

						if not isEquipped then
							wielder = nil
							wielderPlr = nil
							wielderDescription = nil
						end
					end
				end)

				--Begin the revert cooldown process
				coroutine.resume(revertCo)
			end

			--Wait for the transformation cooldown time
			task.wait(Config.TRANSFORM_COOLDOWN_LENGTH)
		end
	end
end

--#endregion

--#region Tool Event Callback Functions

---Callback function to the user equipping the ChameleonPotion tool.
function onEquipped()
	wielder = chameleonPotion.Parent
	wielderPlr = Players:GetPlayerFromCharacter(wielder)

	if isWielderAlive() and wielderPlr then
		wielderDescription = Players:GetHumanoidDescriptionFromUserId(wielderPlr.UserId)
		isEquipped = true
	end
end

---Callback function to the user unequipping the ChameleonPotion tool.
function onUnequipped()
	isEquipped = false

	--Only clear the wielder information if the player isn't transformed
	if revertTimer == 0 then
		wielder = nil
		wielderPlr = nil
		wielderDescription = nil
	end
end

--#endregion

if not TransformEv then
	TransformEv = Instance.new("RemoteEvent")
	TransformEv.Parent = script.Parent
	TransformEv.Name = "TransformEV"
end

---OnServerEvent Callback to Transform the Player
TransformEv.OnServerEvent:Connect(function(plr, ray)

	if plr.UserId == wielderPlr.UserId and isEquipped then
		if chameleonPotion.Enabled and isWielderAlive() and isToolEquipped() then
			chameleonPotion.Enabled = false
			transform(ray.Origin, ray.Direction, nil)
			chameleonPotion.Enabled = true
		end
	end
end)


--Event connections
chameleonPotion.Equipped:connect(onEquipped)
chameleonPotion.Unequipped:connect(onUnequipped)
