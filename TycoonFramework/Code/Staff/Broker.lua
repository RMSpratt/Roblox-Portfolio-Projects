local Config = {}
Config.COLLECT_DB_TIME = 0.25 --How long of a debounce to wait for the Player collecting income
Config.INCOME_GENERATE_TIME = 2 --How long does it take for income to generate in the Tycoon
Config.START_REVENUE_AMOUNT = 0 --How much revenue does the Tycoon start off with.
Config.START_INCOME_AMOUNT = 0 --How much income does the Tycoon generate by default.
Config.ALLOW_STEALING = false --Can Players other than the Owner collect generated income?

local Broker = {}
Broker.__index = Broker

---Creation Step.
---@param tycoonId number
---@return table
function Broker.new(tycoonId)
	local self = {}
	setmetatable(self, Broker)

	self.TycoonId = tycoonId
	self.Owner = nil

	self.DataKeys = {
		RevenueToCollect = "RevenueToCollect",
		IncomeAmt = "IncomeAmt",
		IncomeInterval = "IncomeInterval"
	}

	self.Data = {}
	self.Data.RevenueToCollect = 0
	self.Data.IncomeAmt = Config.START_INCOME_AMOUNT
	self.Data.IncomeInterval = Config.INCOME_GENERATE_TIME

	self.DataKeyCBFuncs = {}

	return self
end

---Initialization Step.
---@param gatekeeperMod ModuleScript
function Broker:_Initialize(gatekeeperMod)
	gatekeeperMod:RegisterDataKeyListener(gatekeeperMod.DataKeys.TycoonOwner,
		function(...) self:OnSetOwner(...) end)
end

---Clear step. Reset all generated revenue and income to 0.
function Broker:_Clear()
	self.Owner = nil
	self.TycoonActive = false
	self.Data.IncomeAmt = Config.START_INCOME_AMOUNT
	self.Data.IncomeInterval = Config.INCOME_GENERATE_TIME
	self.Data.RevenueToCollect = Config.START_REVENUE_AMOUNT

	self:_PushDataKeyUpdate(self.DataKeys.IncomeAmt)
	self:_PushDataKeyUpdate(self.DataKeys.IncomeInterval)
	self:_PushDataKeyUpdate(self.DataKeys.RevenueToCollect)
end

---Processes completed purchases for the Tycoon.
---@param itemId number
---@param cost number
function Broker:_ProcessPurchase(itemId, cost)
	--ADD: Handle the purchase for the Player
end

---Invokes any registered data key listeners to pass updated data.
---@param dataKey string
function Broker:_PushDataKeyUpdate(dataKey)

	if self.DataKeyCBFuncs[dataKey] then

		for _, listenerCB in pairs(self.DataKeyCBFuncs[dataKey]) do
			listenerCB(self.Data[dataKey])
		end
	end
end

---Start the generation of income for the Tycoon
function Broker:_Start()
	self.TycoonActive = true

	--Start the Payment cycle coroutine
	local payRoutine = coroutine.create(function()

		while self.TycoonActive do
			task.wait(self.Data.IncomeInterval)
			self.Data.RevenueToCollect += self.Data.IncomeAmt
			self:_PushDataKeyUpdate(self.DataKeys.RevenueToCollect)
		end
	end)

	coroutine.resume(payRoutine)
end

---Decrement the total income that the Tycoon generates every timestep.
---@param amount number
function Broker:DecreaseIncome(amount)
	self.Data.IncomeAmt -= amount
end

---Increment the total income that the Tycoon generates every timestep.
---@param amount number
function Broker:IncrementIncome(amount)
	self.Data.IncomeAmt += amount
end

---Set the Tycoon owner activating the Broker.
---@param tycoonOwner Player
function Broker:OnSetOwner(tycoonOwner)

	if tycoonOwner then
		self.Owner = tycoonOwner.UserId
		self:_Start()

	else
		self:_Clear()
	end
end

--Pay the Tycoon owner the current accumulated revenue amount.
function Broker:PayPlayer()
	local earnedIncome = self.Data.RevenueToCollect

	if earnedIncome > 0 then
		--ADD: Subtract from the Tycoon Owner's cash amount

		self.Data.RevenueToCollect -= earnedIncome
		self:_PushDataKeyUpdate(self.DataKeys.RevenueToCollect)
	end
end

---Register a callback function for updates to some aspect of Broker data.
---@param dataKey string
---@param listenerCB function
function Broker:RegisterDataKeyListener(dataKey, listenerCB)

	if not self.DataKeyCBFuncs[dataKey] then
		self.DataKeyCBFuncs[dataKey] = {}
	end

	table.insert(self.DataKeyCBFuncs[dataKey], listenerCB)
end

---Validates Player purchase requests for an Item.
---@param userId number
---@param itemId number
---@param cost number
---@return boolean
function Broker:ValidatePurchaseRequest(userId, itemId, cost)
	local validPurchase = false

	if userId == self.Owner then
		--ADD: Verify that the Player can afford the purchase

		self:_ProcessPurchase(itemId, cost)
		validPurchase = true
	end

	return validPurchase
end


-- End of Broker Metatable --
---------------------------------------------------------------------------


local BrokerAccess = {}

function BrokerAccess.new(tycoonId)
	return Broker.new(tycoonId)
end

return BrokerAccess
