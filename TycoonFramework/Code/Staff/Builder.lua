local SStorage = game:GetService("ServerStorage")

local Config = {}
Config.WORKSPACE_PURCHASES_FOLDER = "Purchases"
Config.SSTORAGE_PURCHASES_FOLDER = "Purchases"
Config.WORKSPACE_TEMP_FOLDER = "Temp"
Config.SSTORAGE_TEMP_FOLDER = "Temp"

Config.PURCHASE_BTN_NAME = "PurchaseBtn"
Config.PURCHASE_ID_ATTRIB = "ItemId"

--Default Gui for Purchase Buttons (To display Cost and Name info)
local PURCHASE_GUI = SStorage:FindFirstChild("PurchaseGui", true)

local Builder = {}
Builder.__index = Builder

---Creation step. Register the Builder for the Tycoon specified.
---@param tycoonId number
---@return table
function Builder.new(tycoonId)
	local self = {}
	setmetatable(self, Builder)

	self.TycoonId = tycoonId

	self.ItemModels = {}
	self.ItemButtons = {}
	self.TempModels = {}

	return self
end

---Initialization Step. Create organized references to Tycoon Purchases and Temporary Objects.
---@param tycoonFolder any
---@param tycoonWSFolder any
function Builder:_Initialize(tycoonFolder, tycoonWSFolder)

	self.PurchaseStorageSS = tycoonFolder:FindFirstChild(Config.SSTORAGE_PURCHASES_FOLDER)
	self.PurchaseStorageWS = tycoonWSFolder:FindFirstChild(Config.WORKSPACE_PURCHASES_FOLDER)
	self.TempStorageSS = tycoonFolder:FindFirstChild(Config.SSTORAGE_TEMP_FOLDER)
	self.TempStorageWS = tycoonWSFolder:FindFirstChild(Config.WORKSPACE_TEMP_FOLDER)

	if self.PurchaseStorageWS then

		if self.PurchaseStorageSS then
			for _, child in pairs(self.PurchaseStorageSS:GetChildren()) do

				if child:IsA("Model") then
					self:_RegisterItem(child)
				end
			end
		end
	end

	if self.TempStorageWS then

		if self.TempStorageSS then

			for _, child in pairs(self.TempStorageWS:GetChildren()) do

				if child:IsA("Model") then
					self:_RegisterTemp(child)
				end
			end
		end
	end
end

---Create an Item PurchaseBtn Gui to advertise the item's name and cost. (Optional)
---@param itemId number
---@param itemCost number
---@param itemName string
function Builder:_CreatePurchaseGui(itemId, itemCost, itemName)
	local button = self.ItemButtons[itemId]
    local purchaseGui = button:FindFirstChild("PurchaseGui")
    local itemLabel = nil
    local costLabel = nil

    --Use the template gui if not present in the gui
    if not purchaseGui then

        if PURCHASE_GUI then
            purchaseGui = PURCHASE_GUI:Clone()
            purchaseGui.Parent = button
        else
            warn(string.format("Tycoon %d: No template purchase gui set for Builder.", self.TycoonId))
            return
        end
    end

    itemLabel = purchaseGui:FindFirstChild("Item", true)
    costLabel = purchaseGui:FindFirstChild("Cost", true)

    if itemLabel then
        itemLabel.Text = itemName
    end

    if costLabel then
        costLabel.Text = itemCost
    end
end

---Register a Tycoon model to the Builder's list of Craftable Items.
---@param itemModel Model
function Builder:_RegisterItem(itemModel)
    local purchaseBtn = itemModel:FindFirstChild(Config.PURCHASE_BTN_NAME)
    local itemId = purchaseBtn:GetAttribute(Config.PURCHASE_ID_ATTRIB)

    self.ItemModels[itemId] = itemModel
    self.ItemButtons[itemId] = purchaseBtn
end

---Register a Tycoon temporary model to the list of temporary stand-in Items.
---@param tempModel Model
function Builder:_RegisterTemp(tempModel)
	local purchaseId = tempModel:GetAttribute(Config.PURCHASE_ID_ATTRIB)

	if purchaseId and self.ItemModels[purchaseId] then
		self.TempModels[purchaseId] = tempModel
	else
		warn(string.format("Tycoon %d: Temp item %s has no associated purchase item Id.", self.TycoonId, tostring(tempModel.Name)))
	end
end

---Activate the passed Item's Physical Purchase Button.
---@param itemId number
function Builder:ActivatePurchaseBtn(itemId)

	if self.ItemButtons[itemId] then
    	self.ItemButtons[itemId].Parent = self.PurchaseStorageWS
	end
end

---Build the specified Item.
---@param itemId number
function Builder:BuildItem(itemId)
    self.ItemModels[itemId].Parent = self.PurchaseStorageWS

	if self.TempModels[itemId] then
    	self.TempModels[itemId].Parent = self.TempStorageSS
	end
end

---Clear Step. Remove all built Purchase Items. Restore Temporary Structures.
function Builder:Clear()

	for _, model in pairs(self.ItemModels) do
		model.Parent = self.PurchaseStorageSS
	end

	for id, button in pairs(self.ItemButtons) do
		button.Parent = self.ItemModels[id]
	end

	for _, model in pairs(self.TempModels) do
		model.Parent = self.TempStorageWS
	end
end

---Deactivate the Purchase Button for an Item.
---@param itemId number
function Builder:DeactivatePurchaseBtn(itemId)

	if self.ItemButtons[itemId] then
    	self.ItemButtons[itemId].Parent = self.PurchaseStorageSS
	end
end

---Remove a built Purchase Item.
---@param itemId number
function Builder:RemoveItem(itemId)
    self.ItemModels[itemId].Parent = self.PurchaseStorageSS

    --Return a Temporary Item to workspace if one exists for the purchase
    if self.TempModels[itemId] then
        self.TempModels[itemId].Parent = self.TempStorageWS
    end
end


-- End of Builder Metatable --
---------------------------------------------------------------------------

local BuilderAccess = {}

function BuilderAccess.new(tycoonId)
	return Builder.new(tycoonId)
end

return BuilderAccess
