--!strict
--[[HIGH-LEVEL DESCRIPTION

Main Task (/1:
This Script is responsible for validating Tycoon purchase requirements.

Minor Tasks (/5):
- Initialize TycoonPurchaseButton instances for a Tycoon.
- Validate purchase requests according to any purchase dependencies.
- Issue requests to a Tycoon Builder to move TycoonObjects.
- Issue requests to a Tycoon Broker to process TycoonPurchases.

Connections:
- N/A
*************************************************
]]--

local Vendor = {}

---Construct a Vendor TycoonWorker.
---@return table
function Vendor.New()
end

---Assigns the specified TycoonId to all TycoonPurchaseButton instances in the given folder.
---@param directory table
---@param tycoonSsFolder Instance
---@param tycoonWsFolder Instance
function Vendor:Initialize(directory: TycoonDirectory, tycoonId: number, tycoonSsFolder: Instance, tycoonWsFolder: Instance)
end

---Attempts to purchase the TycoonPurchase tied to the TycoonPurchaseButton provided.
---@param broker table This Tycoon's Broker TycoonWorker
---@param builder table This Tycoon's Builder TycoonWorker
---@param purchaseBtnInstance Instance The TycoonPurchaseButton tied to a TycoonPurchase for this tycoon.
---@return boolean success Indication of the purchase's success or failure.
---@return number tycoonId The id of the TycoonPurchase tied to the TycoonPurchaseButton provided.
function Vendor:Purchase(broker: Broker, builder: Builder, purchaseBtnInstance: Instance)
end

---Processes the return of a TycoonPurchase.
---@param broker table
---@param builder table
---@param purchaseBtnInstance Instance
function Vendor:ReturnPurchase(broker: Broker, builder: Builder, purchaseBtnInstance: Instance)
end

---Vendor Start Behaviour. Unlock default purchases and any savedata purchases.
---@param ownerTycoonData table Saved TycoonData KeyValue Pairs for the new Owner.
---@param builder table The Builder TycoonWorker for this Tycoon.
function Vendor:Start(ownerTycoonData: {[string]: any}?, builder: Builder)
end

---Vendor Stop Behaviour. Clear any completed purchases.
---Return TycoonPurchaseButton instances to Storage.
function Vendor:Stop(builder: Builder)
end

return Vendor