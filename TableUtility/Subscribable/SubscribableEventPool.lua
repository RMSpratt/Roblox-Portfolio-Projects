--!strict
--[[HIGH-LEVEL DESCRIPTION

Main Task (/1:
This Script is responsible for managing BindableEvents for use by SubscribableEvent instances.

Minor Tasks (/5):
- Create new SubscribableEvent instances.
- Retrieve SubscribableEvent instances from the object pool.
- Remove SubscribableEvent instances from the object pool.

Connections:
- N/A
*************************************************
]]--

--Lookup directory to manage all created SubscribableEvent instances whether used or unused.
local subscribableEvents: {[BindableEvent]: BindableEvent} = {}

--Object Pool table containing all created BindableEvent instances.
local subscribableEventPool: {BindableEvent} = {}

--Parent directory to house created SubscribableEvent instances.
local subscribableEventPoolFolder = nil

---Creates instances of the BindableEvent for use.
---@return BindableEvent
local function createSubscribableEvent()
    local newEvent = Instance.new("BindableEvent")
    newEvent.Parent = subscribableEventPoolFolder
    subscribableEvents[newEvent] = newEvent

    return newEvent
end

local SubscribableEventPoolAccess = {}

---Create a Pool to store the pooled event instances.
---@param poolFolderName string
function SubscribableEventPoolAccess.CreatePool(poolFolderName: string)

    --This method may be invoked an additional time for each client
    if subscribableEventPoolFolder then
        return
    end

    local RStorage = game:GetService("ReplicatedStorage")
    local poolFolder = Instance.new("Folder")
    poolFolder.Name = poolFolderName
    poolFolder.Parent = RStorage
    subscribableEventPoolFolder = poolFolder
end

---Returns a BindableEvent from the Event Pool
---@return BindableEvent
function SubscribableEventPoolAccess.RemoveEventFromPool()

    if not subscribableEventPoolFolder then
        warn(`{script.Name}: Pool not created for SubscribableEvent instances.`)
        return
    end

    if #subscribableEventPool > 0 then
        return table.remove(subscribableEventPool)
    end

    return createSubscribableEvent()
end

---Returns a SubscribableEvent to the ObjectPool for later re-use.
---@param subscribableEvent BindableEvent
function SubscribableEventPoolAccess.ReturnEventToPool(subscribableEvent: BindableEvent)

    if not subscribableEventPoolFolder then
        error(
            `{script.Name}: Pool not created for SubscribableEvent instances.`
        )
        return
    end

    if typeof(subscribableEvent) ~= "Instance" or subscribableEvent.ClassName ~= "BindableEvent" then
        error(
            `{script.Name}: Ignoring non-BindableEvent instance {subscribableEvent.Name} for return to pool.`
        )
        return
    end

    if subscribableEvent.Parent == nil then
        error(
            `{script.Name}: Ignoring BindableEvent instance {subscribableEvent.Name} being destroyed for return to pool.`
        )
        return
    end

    if subscribableEvents[subscribableEvent] then
        table.insert(subscribableEventPool, subscribableEvent)
    else
        error(
            `{script.Name}: Ignoring unknown BindableEvent instance {subscribableEvent.Name} received for return to pool`
        )

        subscribableEvent:Destroy()
    end
end

return SubscribableEventPoolAccess