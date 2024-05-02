--!strict
--[[HIGH-LEVEL DESCRIPTION

Main Task (/1:
This Script is responsible for managing Tycoon generated and held revenue.

Minor Tasks (/5):
- Generate income according to the current rate and speed.
- Update held income for new purchases.
- Update held income for new refunds.

Connections:
- N/A
*************************************************
]]--

local Broker = {}

---Create and return a new Broker TycoonWorker instance.
---@return any
function Broker.New()
end

---Broker Intitialize Behaviour.
function Broker:Initialize(directory: TycoonDirectory)
end

---Process the TycoonPurchase by reducing the cost from the Tycoon's ReadyIncome.
---@param purchaseCost number
---@return boolean
function Broker:ProcessPurchaseReceipt(purchaseCost: number)
end

---Increment the Tycoon's ready income for the refunded cost of the TycoonPurchase.
---@param purchaseRefund number
function Broker:ProcessPurchaseReturn(purchaseRefund: number)
end

---Broker Start Behaviour. Begin generating income for the Tycoon.
function Broker:Start(ownerTycoonData: {[string]: any}?)
end

---Broker Stop Behaviour. Clear all Tycoon revenue and halt income generation.
function Broker:Stop()
end

return Broker