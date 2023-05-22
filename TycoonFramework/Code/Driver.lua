--ServerScript

local rootFolder = script.Parent
local staffFolder = rootFolder.Staff

--Module Scripts
local MasterCatalogMod = require(rootFolder:FindFirstChild("MasterCatalog"))
local OrganizerMod = require(staffFolder:FindFirstChild("Organizer"))

local Config = {}
Config.WORKSPACE_TYCOON_FOLDER = "Tycoons"
Config.SSTORAGE_TYCOON_FOLDER = "Tycoons"

local Tycoons = {}

---Initialization Step. Called on Server Start.
local function _initialize()
	local tycoonGroupFolder = game:GetService("ServerStorage"):FindFirstChild(Config.SSTORAGE_TYCOON_FOLDER)
	local tycoonGroupWSFolder = workspace:FindFirstChild(Config.WORKSPACE_TYCOON_FOLDER, true)
	local CatalogerMod = require(script.Parent.Cataloger)
	local tempTycoonTable = {}

	CatalogerMod._Initialize()
	MasterCatalogMod._Initialize()

	if tycoonGroupFolder then

		for _, childObj in pairs(tycoonGroupFolder:GetChildren()) do

			if childObj:IsA("Folder") then
				local tycoonId = childObj:GetAttribute("TycoonId")

				if tycoonId then
					tempTycoonTable[tycoonId] = {}
					tempTycoonTable[tycoonId].SStorage = childObj
				end
			end
		end
	end

	if tycoonGroupWSFolder then

		for _, childObj in pairs(tycoonGroupWSFolder:GetChildren()) do

			if childObj:IsA("Folder") then
				local tycoonId = childObj:GetAttribute("TycoonId")

				if tycoonId and tempTycoonTable[tycoonId] then
					tempTycoonTable[tycoonId].Workspace = childObj

					--Create Tycoons with both required folder references
					Tycoons[tycoonId] = OrganizerMod.new(tycoonId)
					Tycoons[tycoonId]:_Initialize(
						tempTycoonTable[tycoonId].SStorage,
						tempTycoonTable[tycoonId].Workspace,
						CatalogerMod)
				end
			end
		end
	end
end

_initialize()