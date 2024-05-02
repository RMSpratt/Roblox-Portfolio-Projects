--!strict
--[[HIGH-LEVEL DESCRIPTION

Main Task (/1:
This Script is responsible for managing TycoonPurchase instances.

Minor Tasks (/5):
- Initialize TycoonPurchase instances for a Tycoon.
- Move TycoonPurchase instances into the workspace.
- Move TycoonPurchase instances into ServerStorage.

Connections:
- N/A
*************************************************
]]--

local Builder = {}

---Construct a Builder TycoonWorker.
---@return table
function Builder.New()
end

---TycoonWorker Initialization Step. Sets up TycoonPurchases and TycoonComponents.
---@param _ table
---@param tycoonId number
---@param tycoonSsFolder Instance
---@param tycoonWsFolder Instance
function Builder:Initialize(_: TycoonDirectory, tycoonId: number, tycoonSsFolder: Instance, tycoonWsFolder: Instance)
end

---Move the passed Instance to the TycoonPlot folder in workspace.
---@param tycoonInstance Instance
function Builder:MoveInstanceToPlot(tycoonInstance: Instance)
end

---Move the passed Instance to the TycoonStorage folder in ServerStorage.
---@param tycoonInstance Instance
function Builder:MoveInstanceToStorage(tycoonInstance: Instance)
end

---Builder Start Behaviour. Move any Components to the Workspace.
function Builder:Start()
end

---Builder Stop Behaviour. Clean up the Tycoon and return any Components to ServerStorage.
function Builder:Stop()
end


return Builder