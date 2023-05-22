local Globals = {}
Globals.WORKSPACE_PURCHASES_FOLDER = "Purchases"
Globals.SSTORAGE_PURCHASES_FOLDER = "Purchases"
Globals.WORKSPACE_TEMP_FOLDER = "Temp"
Globals.SSTORAGE_TEMP_FOLDER = "Temp"

Globals.WORKSPACE_COLLECTORS_FOLDER = "Collectors"
Globals.SSTORAGE_COLLECTORS_FOLDER = "Collectors"

Globals.WORKSPACE_DISPLAY_FOLDER = "Displays"
Globals.WORKSPACE_GATE_MODEL = "Gate"

local Organizer = {}
Organizer.__index = Organizer

---Creation Step.
---@param tycoonId number
---@return table
function Organizer.new(tycoonId)
	local self = {}
	setmetatable(self, Organizer)

	self.TycoonId = tycoonId

	return self
end

---Initialization Step.
---@param tycoonFolder Folder
---@param tycoonWSFolder Folder
---@param catalogerMod ModuleScript
function Organizer:_Initialize(tycoonFolder, tycoonWSFolder, catalogerMod)
	local purchaseFolder = tycoonFolder:FindFirstChild(Globals.SSTORAGE_PURCHASES_FOLDER, true)
	local purchaseWSFolder = tycoonWSFolder:FindFirstChild(Globals.WORKSPACE_PURCHASES_FOLDER, true)

	local staffFolder = script.parent
	local BrokerMod = require(staffFolder.Broker)
	local BuilderMod = require(staffFolder.Builder)
	local GatekeeperMod = require(staffFolder.Gatekeeper)
	local VendorMod = require(staffFolder.Vendor)
	local SecurityMod = require(staffFolder.Security)

	local MasterCatalogMod = require(script.Parent.Parent.MasterCatalog)

	if purchaseFolder then

		if purchaseWSFolder then

			for _, purchase in pairs(purchaseWSFolder:GetChildren()) do
				purchase.Parent = purchaseFolder
			end
		end
	end

	self.Cataloger = catalogerMod

	self.Gatekeeper = GatekeeperMod.new(self.TycoonId)
	self.Gatekeeper:_Initialize()

	self.Broker = BrokerMod.new(self.TycoonId)
	self.Broker:_Initialize(self.Gatekeeper)

	self.Builder = BuilderMod.new(self.TycoonId)
	self.Builder:_Initialize(tycoonFolder, tycoonWSFolder)

	self.Vendor = VendorMod.new(self.TycoonId, self.Broker, self.Builder, self.Cataloger.GetAllItems(MasterCatalogMod.Items))
	self.Vendor:_Initialize(purchaseFolder, self.Gatekeeper)

	self.Security = SecurityMod.new(self.TycoonId)
	self.Security:_Initialize(self.Gatekeeper, purchaseFolder, purchaseWSFolder)

	--Optional: Add SmartObjects
end

--Get the full list of itemId purchases for the Tycoon
function Organizer:GetTycoonPurchases()
	return self.Vendor:GetCatalogReport()
end


-- End of Organizer Metatable --
---------------------------------------------------------------------------

--Module Script Access functions
local OrganizerAccess = {}

function OrganizerAccess.new(tycoonId)
	return Organizer.new(tycoonId)
end

return OrganizerAccess
