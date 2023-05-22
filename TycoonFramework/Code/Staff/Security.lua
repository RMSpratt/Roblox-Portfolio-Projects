local Config = {}
Config.TYCOON_COLL_GROUP_PREFIX = "Tycoon_"
Config.OWNER_ATTRIB = "OwnerAccess"


local Security = {}
Security.__index = Security

---Creation Step. One instance of Security is created per Tycoon for the server duration.
---@param tycoonId number
---@return table
function Security.new(tycoonId)
	local self = {}
	setmetatable(self, Security)

	self.CollisionId = nil
	self.TycoonId = tycoonId
	self.Owner = nil
	self.OwnerRespawnEV = nil

	return self
end

---Initialization Step.
---@param gatekeeperMod ModuleScript
---@param purchaseFolder Folder
---@param purchaseWSFolder Folder
function Security:_Initialize(gatekeeperMod, purchaseFolder, purchaseWSFolder)
	local PhysicsService = game:GetService("PhysicsService")

	self.CollisionId = string.format("%s%d", Config.TYCOON_COLL_GROUP_PREFIX, self.TycoonId)
	PhysicsService:RegisterCollisionGroup(self.CollisionId)
	PhysicsService:CollisionGroupSetCollidable(self.CollisionId, self.CollisionId, false)

	gatekeeperMod:RegisterDataKeyListener(gatekeeperMod.DataKeys.TycoonOwner,
		function(...) self:OnSetOwner(...) end)

	--Behaviour can be overridden
	--By assumption here, all "Owner-specific" parts exist in Purchase folders
	self:_GetOwnerPartsByAttribute(purchaseFolder)
	self:_GetOwnerPartsByAttribute(purchaseWSFolder)
end

---Assign the Player to the Tycoon-specific Collision Group
---@param characterModel Model
function Security:_AssignOwnerPrivileges(characterModel)
	print(characterModel.Name, self.CollisionId)
	for _, item in pairs(characterModel:GetChildren()) do
		if item:IsA("BasePart") then
			item.CollisionGroup = self.CollisionId
		end
	end
end

---Clear step. Remove the owner of the Tycoon.
function Security:_Clear()

	if self.Owner and self.OwnerRespawnEV then
		self.OwnerRespawnEV:Disconnect()
		self.OwnerRespawnEV = nil
	end
end

---Another way to get 'Owner specific' parts in a Tycoon.
---Tag must be unique per Tycoon.
function Security:_GetOwnerPartsByTag()
end

---Loop through the passed folder and set the CollisionGroup of owner-specific parts.
---@param instanceFolder table
function Security:_GetOwnerPartsByAttribute(instanceFolder)
	for _, instanceObj in pairs(instanceFolder:GetDescendants()) do

		if instanceObj:IsA("BasePart") and instanceObj:GetAttribute(Config.OWNER_ATTRIB) then
			instanceObj.CollisionGroup = self.CollisionId
		end
	end
end

---Start step. Assign the Owner of the tycoon, and begin listening for respawn events.
---@param owner Player
function Security:OnSetOwner(owner)
	self.Owner = owner

	if self.Owner then
		self:_AssignOwnerPrivileges(owner.Character)

		self.OwnerRespawnEV = owner.CharacterAdded:Connect(function(character)
			self:_AssignOwnerPrivileges(character)
		end)
	else
		self:_Clear()
	end
end


-- End of Security Metatable --
---------------------------------------------------------------------------

local SecurityAccess = {}

function SecurityAccess.new(tycoonId)
	return Security.new(tycoonId)
end


return SecurityAccess
