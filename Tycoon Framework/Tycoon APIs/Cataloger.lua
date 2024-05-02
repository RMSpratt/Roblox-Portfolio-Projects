--!strict
--[[HIGH-LEVEL DESCRIPTION

Main Task (/1:
This Script controls access to a PlayerTycoon-specific copy of the TycoonPurchaseIndex.

Minor Tasks (/5):
- Create a copy of the TycoonPurchaseIndex for safe editing.
- Facilitate read-requests for Index items.
- Update prequisite trees for Tycoon purchases.
- Update antirequisite trees for Tycoon purchases.

Connections:
- N/A
*************************************************
]]--

local Cataloger = {}

---Construct a new Cataloger instance.
---@return table
function Cataloger.New()
end

---Retrieves information for the purchase specified from the master index to be stored.
---@param purchaseId number
function Cataloger:AddPurchaseToIndex(purchaseId: number)
end

---Returns true if information for the purchase specified exists within the local TycoonPurchaseIndex.
---@param purchaseId number
---@return any
function Cataloger:CheckIndexContainsPurchase(purchaseId: number)
end

---Checks if the purchase specified is unlocked by being free of prerequisites and antirequisites.
---@param purchaseId number
---@return any
function Cataloger:CheckIsUnlocked(purchaseId: number)
end

---Adds back the refunded TycoonPurchase as a prerequisite to any dependent TycoonPurchases.
---Step for returned purchases.
---@param refundId number
function Cataloger:DistributePrerequisitesForPurchase(refundId: number)
end

---Retrieves the cost for the TycoonPurchase specified.
---@param purchaseId number
---@return any
function Cataloger:GetCost(purchaseId: number)
end

---Retrieves the list of remaining prerequisites for the TycoonPurchase to be unlocked.
---@param purchaseId number
function Cataloger:GetPrerequisites(purchaseId: number)
end

---Returns the list of TycoonPurchases with the specified TycoonPurchase as an antirequisite.
---@param antireqId number
---@return table
function Cataloger:GetPurchasesWithAntirequisite(antireqId: number)
end

---Returns the list of TycoonPurchases with the specified TycoonPurchase as a prerequisite.
---@param prereqId number
---@return table
function Cataloger:GetPurchasesWithPrerequisite(prereqId: number)
end

---Removes the TycoonPurchase as a lock for any dependent TycoonPurchases and returns unlocked items.
---@param purchaseId number
---@return table
function Cataloger:RemovePrerequisitesForPurchase(purchaseId: number)
end

return Cataloger