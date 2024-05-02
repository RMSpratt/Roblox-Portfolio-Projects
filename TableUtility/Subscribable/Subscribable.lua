--!strict
--[[HIGH-LEVEL DESCRIPTION

Main Task (/1:
This Script is responsible for defining the base Subscribable table type.

Minor Tasks (/5):
- Create new Subscribable table instances.
- Define Base Subscribe method.
- Define Base Notify method.
- Define Base Unsubscribe method.

Connections:
- N/A
*************************************************
]]--

--[M]odules
local HiddenKeyTableMod = require(script.Parent.HiddenKeyTable)
local SubscribableEventMod = require(script.Parent.SubscribableEventPool)
local SubscribableTableMod = require(script.Parent.SubscribableTable)

--[T]ypes

--Defines a table type with data that can be subscribed to for OnChange events.
type Subscribable = typeof(setmetatable({} :: {
    _Type: string,
    Data: {[string]: any},
    DataKeys: {[string]: string},
    DataEvents: {[string]: BindableEvent},
    Subscribers: {[string]: {
        Connections: {[string | Instance]: RBXScriptConnection},
        Num: number
    }},
}, {} :: SubscribableFuncs))

--Defines functions attached to Susbcribable type objects.
type SubscribableFuncs = {
    __index: SubscribableFuncs,
    AddDataKeyValuePair: (self: Subscribable, dataKey: string, dataValue: any) -> (boolean, string),
    AddAllDataKeyValuePairs: (self: Subscribable, dataKeyValuePairs: {[string]: any}) -> (boolean, string),
    ClearSubscribers: (self: Subscribable) -> (),
    Notify: SubscribableNotifyCB,
    Subscribe: (self: Subscribable, subscriberId: string | Instance, dataKey: string, updateCB: (string, any) -> ()) -> (boolean, string),
    Unsubscribe: (self: Subscribable, subscriberId: string | Instance, dataKey: string) -> (boolean, string)
}

--Defines the expected function callback signature for subscribers to Subscribable data.
type SubscribableNotifyCB = (subscribable: Subscribable, dataKey: string, dataValue: any, {}) -> ()

--[C]onfig Variables
local DATA_KEY_INVALID_ERR = 'invalid data key %s for %s request; expected string'
local DATA_KEY_MISSING_ERR = 'invalid data key %s for %s request; not defined in table'
local DATA_VALUE_NIL_ERR = 'invalid data value nil for %s request matching data key %s'
local SUBSCRIBER_ID_INVALID_ERR = 'invalid subscriber id %s for %s request; expected string or instance, got %s'
local SUBSCRIBER_ID_DUPLICATE_ERR = 'duplicate request for subscriber id %s to subscribe to dataKey %s'

--[L]ocal Variables
local Subscribable: SubscribableFuncs = {} :: SubscribableFuncs
Subscribable.__index = Subscribable

---Add a series of dataKey-dataValue pairs to the Subscribable table instance.
---@param dataKeyValueTable table A series of key-value pairs to add to the Subscribable data.
function Subscribable:AddAllDataKeyValuePairs(dataKeyValueTable: {[string]: any})
    local addAllKeyValueSuccess = false
    local addAlleyValueErr = nil

    for dataKey, dataValue in dataKeyValueTable do

        if typeof(dataKey) ~= 'string' then
            addAlleyValueErr = string.format(DATA_KEY_INVALID_ERR, dataKey, 'addAllDataKeyValuePairs')
            return addAllKeyValueSuccess, addAlleyValueErr
        end

        if dataValue == nil then
            addAlleyValueErr = string.format(DATA_VALUE_NIL_ERR, 'addAllDataKeyValuePairs')
            return addAllKeyValueSuccess, addAlleyValueErr
        end

        self.Data[dataKey] = dataValue
        self.DataKeys[dataKey] = dataKey
    end

    return addAllKeyValueSuccess, addAlleyValueErr
end

---Add one dataKey-dataValue pair to the Subscribable table instance.
---@param dataKey string The key name to be added to the Subscribable data.
---@param dataValue any The corresponding value to be added to the Subscribable data.
function Subscribable:AddDataKeyValuePair(dataKey: string, dataValue: any)
    local addKeyValueSuccess = false
    local addKeyValueErr = nil

    if typeof(dataKey) ~= 'string' then
        addKeyValueErr = string.format(DATA_KEY_INVALID_ERR, dataKey, 'addDataKeyValuePair')
        return addKeyValueSuccess, addKeyValueErr
    end

    if dataValue == nil then
        addKeyValueErr = string.format(DATA_VALUE_NIL_ERR, 'addDataKeyValuePair')
        return addKeyValueSuccess, addKeyValueErr
    end

    self.Data[dataKey] = dataValue
    self.DataKeys[dataKey] = dataKey

    return addKeyValueSuccess, addKeyValueErr
end

---Clears all subscribers for all data keys.
function Subscribable:ClearSubscribers()

    for dataKey, _ in self.Subscribers do
        for subscriberId, _ in self.Subscribers[dataKey].Connections do
            self:Unsubscribe(subscriberId, dataKey)
        end

        table.clear(self.Subscribers[dataKey])
    end

    table.clear(self.Subscribers)
end

------Invokes all callback functions associated with updates to the specified dataKey.
---@param dataKeyPath string The path to the updated data value from the root Data table.
---@param dataValue any The updated data value.
---@param baseTable table The Susbcriber's base data table.
function Subscribable:Notify(dataKeyPath: string, dataValue: any, baseTable: {})
    local dataKeys = string.gmatch(dataKeyPath, "%a+")

    --Unfortunate necessity as the readonly metatable will be lost in the BindableEvent call
    local rawTable = HiddenKeyTableMod.ExtractTable(baseTable, '_')

    --The first token will be an empty string (as the name of the base table)
    for dataKey in dataKeys do
        rawTable = rawTable[dataKey]

        if self.DataEvents[dataKey] then
            self.DataEvents[dataKey]:Fire(dataKey, rawTable)
        end
    end
end

---Adds a callback function subscriber to the list of listeners for a data key.
---@param subscriberId string An identifier for the Subscriber.
---@param dataKey string The dataKey to track changes for.
---@param updateCB function
---@return boolean subscribeSuccess Whether or not the request succeeded.
---@return string subscribeErr Error message to the subscribe request dispatched.
function Subscribable:Subscribe(subscriberId: string | Instance, dataKey: string, updateCB: (string, any) -> ())
    local subscribeSuccess = false
    local subscribeErr = nil

    if typeof(subscriberId) ~= 'string' and typeof(subscriberId) ~= 'Instance' then
        subscribeErr = string.format(SUBSCRIBER_ID_INVALID_ERR, subscriberId, 'subscribe', typeof(subscriberId))
        return subscribeSuccess, subscribeErr
    end

    if typeof(dataKey) ~= 'string' then
        subscribeErr = string.format(DATA_KEY_INVALID_ERR, dataKey, 'subscribe')
        return subscribeSuccess, subscribeErr
    end

    if self.Data[dataKey] == nil then
        subscribeErr = string.format(DATA_KEY_MISSING_ERR, dataKey, 'subscribe')
        return subscribeSuccess, subscribeErr
    end

    if not self.DataEvents[dataKey] then
        self.DataEvents[dataKey] = SubscribableEventMod.RemoveEventFromPool()
    end

    self.Subscribers[dataKey] = self.Subscribers[dataKey] or {Connections = {}, Num = 0}

    if not self.Subscribers[dataKey].Connections[subscriberId] then
        self.Subscribers[dataKey].Connections[subscriberId] = self.DataEvents[dataKey].Event:Connect(updateCB)
        self.Subscribers[dataKey].Num += 1
        subscribeSuccess = true
    else
        subscribeErr = string.format(SUBSCRIBER_ID_DUPLICATE_ERR, subscriberId, dataKey)
    end

    return subscribeSuccess, subscribeErr
end

---Removes a callback function subscriber from the list of listeners for a data key.
---@param subscriberId string Unique identifier for the subscribing data listener.
---@param dataKey string The dataKeyValue name for monitoring changes.
function Subscribable:Unsubscribe(subscriberId: string | Instance, dataKey: string)
    local unsubscribeSuccess =  false
    local unsubscribeErr = nil

    if typeof(subscriberId) ~= 'string' and typeof(subscriberId) ~= 'Instance' then
        unsubscribeErr = string.format(SUBSCRIBER_ID_INVALID_ERR, subscriberId, 'unsubscribe', typeof(subscriberId))
        return unsubscribeSuccess, unsubscribeErr
    end

    if typeof(dataKey) ~= 'string' or not self.Data[dataKey] then
        unsubscribeErr = string.format(DATA_KEY_INVALID_ERR, dataKey, 'unsubscribe')
        return unsubscribeSuccess, unsubscribeErr
    end

    if self.Subscribers[dataKey] and self.Subscribers[dataKey].Connections[subscriberId] then
        self.Subscribers[dataKey].Connections[subscriberId]:Disconnect()
        self.Subscribers[dataKey].Num -= 1

        if self.Subscribers[dataKey].Num == 0 then
            SubscribableEventMod.ReturnEventToPool(self.DataEvents[dataKey])
            self.DataEvents[dataKey] = nil
        end
    end

    return unsubscribeSuccess, unsubscribeErr
end

---Utility Table to create new Subscribable table instances.
local SubscribableFactory = {}

---Initialize an ObjectPool for managing DataEvent BindableEvents.
---@param poolName string
function SubscribableFactory._Initialize(poolName: string)
    SubscribableEventMod.CreatePool(poolName)
end

---Create and return a new Subscribable table instance.
---@return table
function SubscribableFactory.New()
    local newSubscribable = {
        _Type = 'Subscribable',
        Data = {},
        DataEvents = {},
        DataKeys = {},
        Subscribers = {},
    }

    setmetatable(newSubscribable, Subscribable)

    SubscribableTableMod.SetTableSubscribable(
        newSubscribable.Data,
        function(dataKey, dataValue) newSubscribable:Notify(dataKey, dataValue, newSubscribable.Data) end)

    return newSubscribable
end

SubscribableFactory._Initialize('SubscribableEvents')

return SubscribableFactory