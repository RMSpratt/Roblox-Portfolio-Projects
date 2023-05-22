
--Should the Gatekeeper track when the Owner leaves the game?
local Config = {}
Config.MONITOR_OWNER_PRESENCE = true

local Gatekeeper = {}
Gatekeeper.__index = Gatekeeper

---Creation Step.
---@param tycoonId number
---@return table
function Gatekeeper.new(tycoonId)
	local self = {}
	setmetatable(self, Gatekeeper)

	self.TycoonId = tycoonId

    self.Data = {}
    self.Data.Owner = nil
    self.Data.OwnerName = nil

    self.DataKeys = {
		TycoonOwner = "Owner",
	}

    self.DataKeyCBFuncs = {}

	return self
end

---Initialization step.
function Gatekeeper:_Initialize()

	if Config.MONITOR_OWNER_PRESENCE then
		game:GetService("Players").PlayerRemoving:Connect(function(player)

			if self.Data.Owner and self.Data.Owner == player.UserId then
				self:ClearOwner()
			end
		end)
	end
end

---Invokes any registered data key listeners to pass updated data.
---@param dataKey string
function Gatekeeper:_PushDataKeyUpdate(dataKey)

	if self.DataKeyCBFuncs[dataKey] then

		for _, listenerCB in pairs(self.DataKeyCBFuncs[dataKey]) do
			listenerCB(self.Data[dataKey])
		end
	end
end

---Clears the Tycoon Owner, informing subsequent staff members.
function Gatekeeper:ClearOwner()
	self.Data.Owner = nil
	self.Broker:Clear()
end

--Get the UserId of the Owner of the Tycoon
function Gatekeeper:GetOwner()
	return self.Data.Owner
end

--Get the name of the Owner of the Tycoon
function Gatekeeper:GetOwnerName()
	return self.Owner.Name
end

---Callback to handle a Player attempting to become this Tycoon's owner.
---@param player Player
function Gatekeeper:TrySetOwner(player)

	if not self.Data.Owner then

		--ADD: Ensure that the Player isn't associated with another Tycoon
		self:Start(player)
	end
end

---Register a callback function for updates to some aspect of Gatekeeper data.
---@param dataKey string
---@param listenerCB function
function Gatekeeper:RegisterDataKeyListener(dataKey, listenerCB)

    if not self.DataKeyCBFuncs[dataKey] then
		self.DataKeyCBFuncs[dataKey] = {}
	end

	table.insert(self.DataKeyCBFuncs[dataKey], listenerCB)
end

---Start Step. Set the Owner of the Tycoon, and inform oher Staff.
---@param player Player
function Gatekeeper:Start(player)
    self.Data.Owner = player
	self.Data.OwnerId = player.UserId
	self:_PushDataKeyUpdate(self.DataKeys.TycoonOwner)
end


-- End of Gatekeeper Metatable --
---------------------------------------------------------------------------

local GatekeeperAccess = {}

function GatekeeperAccess.new(tycoonId)
	return Gatekeeper.new(tycoonId)
end

return GatekeeperAccess
