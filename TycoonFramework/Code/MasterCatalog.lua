--Put all information about possible Tycoon purchases here
--The only required key for each entry is 'Cost'
--Order of the keys is irrelevant
local MasterCatalog = {}

MasterCatalog.Items = {
	[1] = {
		Name = "Sample",
		Cost = 0,
		RevnueAmt = 25,
	},
	[2] = {
		Name = "Sample-2",
		Cost = 0,
		RevnueAmt = 50,
		Prereq = {
			Ids = {1}
		},
		ReplaceId = 1
	},
}

---Build all of the pre-requisite trees for unlocking Items in a Tycoon's Catalog.
function MasterCatalog._Initialize()

	--Assign dependencies between items
	for itemId, item in pairs(MasterCatalog.Items) do

		if item.Prereq then
			MasterCatalog._BuildPrereqTree(itemId, item.Prereq)
		end
	end
end

---Build the tree of pre-requisites for unlocking a specific Item.
---@param itemId number
---@param prereqTree table
---@return table
function MasterCatalog._BuildPrereqTree(itemId, prereqTree)
	local numPrereqs = 0

	if not prereqTree.Ids then
		warn("Item " .. itemId .. " has an invalid prerequisite tree.")
		return nil
	end

	for _, prereq in pairs(prereqTree.Ids) do

		if type(prereq) == 'table' then
			MasterCatalog._BuildPrereqTree(itemId, prereq)

		--Assign the items that unlock other items
		else
			if not MasterCatalog.Items[prereq].Unlocks then
				MasterCatalog.Items[prereq].Unlocks = {}
			end

			table.insert(MasterCatalog.Items[prereq].Unlocks, itemId)
		end

		numPrereqs += 1
	end

	if not prereqTree.Num then
		prereqTree.Num = numPrereqs
	end

	return prereqTree
end


return MasterCatalog
