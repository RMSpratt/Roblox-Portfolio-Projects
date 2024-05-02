local HiddenKeyTable = require(script.Parent.HiddenKeyTable)

---Creates a Subscribable version of the input table.
---@param subTable any
---@param level number
---@param notifyCB table
---@param recurDown boolean
---@param keyPath string
---@param baseTable table
local function setTableSubscribable(subTable, level: number, notifyCB: (string, any, {}) -> (), recurDown: boolean, keyPath: string, baseTable: {})

    --Sanity check
    if level > 8 then
        warn("Attempt to set readonly table at recursion depth > 8.")
        return
    end

    for k, v in subTable do

        if type(v) == "table" and recurDown then
            setTableSubscribable(v, level + 1, notifyCB, recurDown, `{keyPath}/{k}`, baseTable)
        end
    end

    --Retain any existing metamethods other than index and newindex
    local newMetatable = getmetatable(subTable) or {}
    newMetatable.__newindex = function(tbl, key, newValue)
        if type(newValue) == 'table' then
            HiddenKeyTable.HideTableKeys(newValue, '_')
        end

        rawset(tbl, `_{key}`, newValue)
        notifyCB(`{keyPath}/{key}`, newValue, baseTable)
    end

    setmetatable(subTable, newMetatable)
end

local SubscribableTable = {}

---Set the table's __newindex method to invoke a callback function when its values are updated.
---@param baseTable any
---@param notifyCB function
function SubscribableTable.SetTableSubscribable(baseTable, notifyCB: (string, any, {}) -> ())
    HiddenKeyTable.HideTableKeys(baseTable, '_')
    setTableSubscribable(baseTable, 1, notifyCB, true, '', baseTable)
end

---Set the table's __newindex method to invoke a callback function when its values are updated.
---Does not affect child sub-tables.
---@param baseTable any
---@param notifyCB function
function SubscribableTable.SetTableSubscribableShallow(baseTable, notifyCB: (string, any, {}) -> ())
    HiddenKeyTable.HideTableKeys(baseTable, '_')
    setTableSubscribable(baseTable, 1, notifyCB, false, '', baseTable)
end

function SubscribableTable.CreateSubscribableTable(baseTable, notifyCB: (string, any, {}) -> ())
    local subscribableTable = HiddenKeyTable.HideTableKeys(baseTable, '_')
    setTableSubscribable(subscribableTable, 1, notifyCB, false, '', baseTable)
    return subscribableTable
end


return SubscribableTable