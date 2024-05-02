--!strict
--[[HIGH-LEVEL DESCRIPTION

Main Task (/1:
This Script is responsible for the creation and maintenance of assignable Tycoons.

Minor Tasks (/5):
- Create and initialize new Tycoon instances.
- Create and initialize TycoonWorker instances.
- Facilitate data read-access requests for tycoons.
- Facilitate data write-access requests for tycoons.
- Facilitate data subscription requests for TycoonData.

Connections:
- Broker
- Builder
- Vendor
*************************************************
]]--

local PlayerTycoon = {}

---Create a new claimable Tycoon instance.
---@param tycoonId number
---@param tycoonPlotFolder Instance
---@param tycoonStorageFolder Instance
---@return any
function PlayerTycoon.New(tycoonId: number, tycoonPlotFolder: Instance, tycoonStorageFolder: Instance)
end

---Process requests from a Tycoon's Owner to make purchases.
---@param tycoon table
---@param purchaseBtn Instance
function PlayerTycoon.Purchase(tycoon: PlayerTycoon<any>, purchaseBtn: Instance)
end

---Process requests from a Tycoon's Owner to read data values.
---@param tycoon table
---@param readKey string
---@return boolean
---@return any
function PlayerTycoon.Read(tycoon: PlayerTycoon<any>, readKey: string)
end

---Start each TycoonWorker, marking the Tycoon ready for use.
---@param tycoon table
---@param owner Player
---@param ownerTycoonData table?
function PlayerTycoon.Start(tycoon: PlayerTycoon<any>, owner: Player, ownerTycoonData: {[string]: any}?)
end

---Stop each TycoonWorker, resetting any owner-specific data and influence.
---@param tycoon table
---@param owner Player
function PlayerTycoon.Stop(tycoon: PlayerTycoon<any>, owner: Player)
end

---Process requests to subscribe to updates to TycoonData values.
---@param tycoon table
---@param subscriberId string | Instance
---@param requestKey string
---@param subscriberCB function
---@return boolean
function PlayerTycoon.Subscribe(tycoon: PlayerTycoon<any>, subscriberId: string | Instance, requestKey: string, subscriberCB: (string, any) -> nil)
end

---Process requests to unsubscribe from updates to TycoonData values.
---@param tycoon table
---@param subscriberId string | Instance
---@param requestKey string
---@return boolean
function PlayerTycoon.Unsubscribe(tycoon: PlayerTycoon<any>, subscriberId: string | Instance, requestKey: string)
end

---Update a PlayerTycoonDataKeyValue within the passed PlayerTycoon.
---@param tycoon table
---@param updateKey string
---@param updateValue number
---@return boolean
function PlayerTycoon.Update(tycoon: PlayerTycoon<any>, updateKey: string, updateValue: number)
end

---Write to a PlayerTycoonDataKeyValue within the passed PlayerTycoon.
---@param tycoon table
---@param writeKey string
---@param writeValue any
---@return boolean
function PlayerTycoon.Write(tycoon: PlayerTycoon<any>, writeKey: string, writeValue: any)
end


return PlayerTycoon