local Cataloger = {}

---Create a copy of the information about a Catalog Item entry.
---@param itemInfoTable table
---@return table
function Cataloger._CopyCatalogItem(itemInfoTable)
	local itemCopyTable = {}

	if itemInfoTable == nil then
		return {}
	end

	for name, value in pairs(itemInfoTable) do

		--Recur to copy sub-tables
		if type(value) == "table" then
			value = Cataloger._CopyCatalogItem(value)
		end

		itemCopyTable[name] = value
	end

	return itemCopyTable
end

---Get all of the information associated with a Catalog Item as a copy.
---@param itemCatalog table
---@param itemId number
---@return table
function Cataloger.GetCatalogItem(itemCatalog, itemId)
	local itemInfo = nil

	if itemCatalog[itemId] then
		itemInfo = Cataloger._CopyCatalogItem(itemCatalog[itemId])
	end

	return itemInfo
end

---Get a full copy of the ItemCatalog passed with total information about its Items.
---@param itemCatalog table
---@return table
function Cataloger.GetAllItems(itemCatalog)
	local catalogCopy = {}

	for itemId, itemInfo in pairs(itemCatalog) do
		catalogCopy[itemId] = Cataloger._CopyCatalogItem(itemInfo)
	end

	return catalogCopy
end


return Cataloger
