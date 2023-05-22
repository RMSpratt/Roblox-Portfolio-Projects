local Players = game:GetService("Players")

--Are there purchase buttons to be labeled?
local USE_BUTTON_LABELS = true

local Config = {}

Config.ITEM_ID_ATTRIB = "ItemId"

--Properties of Items in Catalog Data
Config.ITEM_UNLOCK_PROPERTY = "Unlocks"
Config.ITEM_LOCKED_BY_PROPERTY = "Prerequisites"
Config.ITEM_BLOCK_PROPERTY = "Blocks"
Config.ITEM_BLOCKED_BY_PROPERTY = "Antirequisites"
Config.ITEM_REPLACE_PROPERTY = "ReplaceId"
Config.ITEM_GENERATOR_PROPERTY = "RevenueAmt"

local Vendor = {}
Vendor.__index = Vendor

---Instantiation Step.
---@param tycoonId number
---@param broker ModuleScript
---@param builder ModuleScript
---@return table
function Vendor.new(tycoonId, broker, builder, tycoonCatalog)
	local self = {}
	setmetatable(self, Vendor)

	self.TycoonId = tycoonId
	self.Owner = nil
	self.Purchases = {}
	self.Broker = broker
	self.Builder = builder
	self.VendorCatalog = tycoonCatalog

	return self
end

---Initialization Step.
---@param purchaseFolder Folder
function Vendor:_Initialize(purchaseFolder, gatekeeperMod)
	self:_RegisterItemsInFolder(purchaseFolder)
	gatekeeperMod:RegisterDataKeyListener(gatekeeperMod.DataKeys.TycoonOwner, function(...) self:SetOwner(...) end)
end

---Adds a blocking Item antireqId to the Item specified
---@param blockedItem table
---@param antireqId number
function Vendor:_AddAntireqToItem(blockedItem, antireqId)

	if not blockedItem.Antireq then
		blockedItem.Antireq = {}
		blockedItem.Antireq.Count = 0
	end

	blockedItem.Antireq[antireqId] = true
	blockedItem.Antireq.Count += 1
end

---Recursively search and add the Item to the given Prerequisite tree.
---@param prereqTree table
---@param searchId number
function Vendor:_AddPrereqToItem(prereqTree, searchId)

	for _, prereq in pairs(prereqTree.Ids) do

		--Search sub-tables recursively
		if type(prereq) == 'table' then
			local prevNumRequired = prereq.Num

			self:_AddPrereqToItem(prereq, searchId)

			if prevNumRequired ~= prereq.Num then

				if prevNumRequired == 0 then
					prereqTree.Num += 1
				end

				break
			end

		elseif prereq == searchId then
			prereqTree.Num += 1
			break
		end
	end
end

---Determine if the passed Item is unlocked for purchasing.
---@param itemId number
---@return boolean
function Vendor:_CheckItemIsUnlocked(itemId)
	local isUnlocked = false

	local purchaseItem = self.VendorCatalog[itemId]

	if not purchaseItem.Prereq or purchaseItem.Prereq.Num == 0 then

		if not purchaseItem.Antireq or purchaseItem.Antireq.Count == 0 then
			isUnlocked = true
		end
	end

	return isUnlocked
end

---Clear step. Reset all Player purchases and deactivate Purchase Buttons for locked Items.
function Vendor:_Clear()
	self.Owner = nil

	--Reset the references to all of the catalog items by the Vendor
	for itemId, item in pairs(self.VendorCatalog) do
		if item.Purchased then
			self:_ClearPurchase(itemId)
		else

			--Have the Builder deactivate any active purchase buttons
			if not item.Prereq or item.Prereq.Num == 0 then
				self.Builder:DeactivatePurchaseBtn(itemId)
			end
		end
	end
end

---Clear step for Tycoon purchased Items.
---@param itemId number
function Vendor:_ClearPurchase(itemId)
	local purchaseItem = self.VendorCatalog[itemId]

	purchaseItem.Purchased = false

	self.Builder:RemoveItem(itemId)

	if purchaseItem.Unlocks then
		self:_DistributeLocksFromItem(itemId)
	end

	if purchaseItem.Blocks then
		self:_RemoveBlocksFromItem(itemId)
	end

	if purchaseItem.RevenueAmt then
		self.Broker:DecreaseIncome(purchaseItem.RevenueAmt)
	end
end

---Distribute this Item as an antirequisite to any affected Items.
---@param antireqId number
function Vendor:_DistributeBlocksFromItem(antireqId)
	local antireqItem = self.VendorCatalog[antireqId]

	for _, blockedId in pairs(antireqItem.Blocks) do
		local blockedItem = self.VendorCatalog[blockedId]

		self:_AddAntireqToItem(blockedItem, antireqId)

		--Check for Re-lock
		if blockedItem.Antireq == 1 then

			if not blockedItem.Prereq or blockedItem.Prereq.Num <= 0 then
				self:_LockItem(antireqId)
			end
		end
	end
end

---Adds the Prerequisite Item to any Items locked by it.
---@param prereqId number
function Vendor:_DistributeLocksFromItem(prereqId)
	local prereqItem = self.VendorCatalog[prereqId]

	for _, lockedId in pairs(prereqItem.Unlocks) do
		local lockedItem = self.VendorCatalog[lockedId]

		self:_AddPrereqToItem(lockedItem.Prereq, prereqId)

		if lockedItem.Prereq.Num == 1 then
			self:_LockItem(lockedId)
		end
	end
end

---Loads any free Items or Items that were pre-purchased by the Owner Player for the Tycoon.
---@param purchaseTable table
function Vendor:_LoadCatalog(purchaseTable)

	for _, itemId in pairs(purchaseTable) do
		self.VendorCatalog[itemId].Purchased = true
	end

	--Activate Purchase Buttons for unlocked non-purchased items
	for itemId, item in pairs(self.VendorCatalog) do

		if item.Purchased then
			self:_ProcessPurchase(itemId)

		--Unlock the starting items (Unlocked by default)
		elseif not item.Prereq then
			self:_UnlockItem(itemId)
		end
	end
end

---Locks the specified Item and prevents it from being purchased.
---@param itemId number
function Vendor:_LockItem(itemId)
	self.Builder:DeactivatePurchaseBtn(itemId)
end

---Purchase Processing step.
---@param itemId number
function Vendor:_ProcessPurchase(itemId)
	local itemInfo = self.VendorCatalog[itemId]

	table.insert(self.Purchases, itemId)

	if itemInfo.ReplaceId then
		self.Builder:RemoveItem(itemInfo.ReplaceId)
	end

	if itemInfo.Unlocks then
		self:_RemoveLocksFromItem(itemId)
	end

	if itemInfo.Blocks then
		self:_DistributeBlocksFromItem(itemId)
	end

	--Register items that act as generators with the Broker
	if itemInfo.RevenueAmt then
		self.Broker:IncrementIncome(itemInfo.RevenueAmt)
	end

	self.Builder:BuildItem(itemId)
	self.Builder:DeactivatePurchaseBtn(itemId)
	itemInfo.Purchased = true
end

---Initialization Step. Registers a new item to the Tycoon's Item Catalog.
---@param item Model
function Vendor:_RegisterItem(item)

	if item:FindFirstChild("PurchaseBtn") then
		local itemId = item.PurchaseBtn:GetAttribute(Config.ITEM_ID_ATTRIB)

		if itemId then
			local itemVendorInfo = self.VendorCatalog[itemId]

			if itemVendorInfo then
				local purchaseDB = false

				--Assign the purchase button callback function
				item.PurchaseBtn.Touched:Connect(function(part)

					if not purchaseDB and part and part.Parent then
						local humanoid = part.Parent:FindFirstChild("Humanoid")

						purchaseDB = true

						if humanoid and humanoid.Health > 0 then
							local player = Players:GetPlayerFromCharacter(part.Parent)

							if player then
								self:_ValidatePurchaseRequest(player.UserId, itemId)
							end
						end

						purchaseDB = false
					end
				end)

				if USE_BUTTON_LABELS then
					self.Builder:CreatePurchaseGui(itemId, itemVendorInfo.Cost, itemVendorInfo.Name)
				end

				self.VendorCatalog[itemId] = itemVendorInfo
			end
		end
	end
end

---Recursively register all Tycoon items to the Vendor for purchase.
---@param itemFolder Folder
function Vendor:_RegisterItemsInFolder(itemFolder)

	for _, itemObj in itemFolder:GetChildren() do

		if itemObj:IsA("Folder") then
			self:_RegisterItemsInFolder(itemObj)

		elseif itemObj:IsA("Model") then
			self:_RegisterItem(itemObj)
		else
			warn(string.format("Vendor %d Invalid Item Object %s", self.TycoonId, itemObj.Name))
		end
	end
end

---Removes the specified Antirequisite Item from this item's list of Antirequisites.
---@param blockedItem table
---@param antireqId number
function Vendor:_RemoveAntireqFromItem(blockedItem, antireqId)
	blockedItem.Antireq[antireqId] = nil
	blockedItem.Count -= 1
end

---Removes the passed Item from any Items that have it as an Antirequisite.
---@param antireqId number
function Vendor:_RemoveBlocksFromItem(antireqId)
	local antireqItem = self.VendorCatalog[antireqId]

	for _, blockedId in pairs(antireqItem.Blocks) do
		self:_RemoveAntireqFromItem(self.VendorCatalog[blockedId], antireqId)

		--Check for unlock
		if self:_CheckItemIsUnlocked(blockedId) then
			self:_UnlockItem(blockedId)
		end
	end
end

---Recursively search for the specified Item in the passed prerequite tree to remove it.
---@param prereqTree table
---@param searchId number
function Vendor:_RemoveLockFromItem(prereqTree, searchId)

	for _, prereq in pairs(prereqTree.Ids) do

		if type(prereq) == "table" then
			local prevNumRequired = prereq.Num

			self:_RemoveLockFromItem(prereq, searchId)

			if prevNumRequired ~= prereq.Num then

				if prereq.Num == 0 then
					prereqTree.Num -= 1
					break
				end

				break
			end

		elseif prereq == searchId then
			prereqTree.Num -= 1
			break
		end
	end
end

---Removes the passed item from any items that require it as a prerequisite.
---@param prereqId number
function Vendor:_RemoveLocksFromItem(prereqId)
	local prereqItem = self.VendorCatalog[prereqId]

	for _, lockedId in pairs(prereqItem.Unlocks) do
		local lockedItem = self.VendorCatalog[lockedId]

		self:_RemoveLockFromItem(lockedItem.Prereq, prereqId)

		if self:_CheckItemIsUnlocked(lockedId) then
			self:_UnlockItem(lockedId)
		end
	end
end

---Unlocks the specified Item and allows it to be purchased.
---@param itemId number
function Vendor:_UnlockItem(itemId)
	self.Builder:ActivatePurchaseBtn(itemId)
end

---Validate an incoming Item purchase request made by the Player.
---@param userId number
---@param itemId number
function Vendor:_ValidatePurchaseRequest(userId, itemId)

	--1) Check if the requesting Player is the Tycoon Owner
	if userId == self.Owner then
		local purchaseItem = nil

		itemId = tonumber(itemId)
		purchaseItem = self.VendorCatalog[itemId]

		--2) Check if the item is on-sale and can be purchased
		if purchaseItem then
			if not purchaseItem.Purchased then

				--3) Valdiate the purchase with the Broker
				local validPurchase = self.Broker:ValidatePurchaseRequest(userId, itemId, purchaseItem.Cost)

				if validPurchase then
					self:_ProcessPurchase(itemId)
				end
			end
		end
	end
end

--Returns information for the full set of purchaseable items with the Tycoon
function Vendor:GetCatalogReport()
	local catalogCopy = {}
	catalogCopy.NumItems = 0
	catalogCopy.TotalCost = 0
	catalogCopy.Items = {}

	for itemId, item in pairs(self.VendorCatalog) do
		table.insert(catalogCopy.Items, itemId)
		catalogCopy.NumItems += 1

		if item.Cost then
			catalogCopy.TotalCost += item.Cost
		end
	end

	return catalogCopy
end

---Checks if the passed Item is unlocked for this Tycoon.
---@param itemId any
---@return any
function Vendor:IsItemUnlocked(itemId)

	if self.VendorCatalog[itemId] then
		return self:_CheckItemIsUnlocked(itemId)
	end

	return false
end

--Callback to set the Tycoon Owner. Load previous save data or clear data if the Owner has left.
---@param tycoonOwner Player
function Vendor:SetOwner(tycoonOwner)

	if tycoonOwner then

		local ownerPurchases = {}
		--ADD: Get the Player's save data with prior purchases (if relevant)

		self.Owner = tycoonOwner.UserId
		self:_LoadCatalog(ownerPurchases)

	else
		self:_Clear()
	end
end


-- End of Vendor Metatable --
---------------------------------------------------------------------------


local VendorAccess = {}

function VendorAccess.new(tycoonId, broker, builder, tycoonCatalog)
	return Vendor.new(tycoonId, broker, builder, tycoonCatalog)
end


return VendorAccess
