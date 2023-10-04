---This Module Script provides methods for creating readonly variants of tables.
---Recursively set a table's sub-tables to be read-only, unlike the Lua textbook proxy example.
---Metatables are preserved. __index can be preserved if needed.

---Recursively set the passed table and all subtables to be read-only.
---@param inputTable table
local function setTableRecur(inputTable: table, readonlyMetatable: table, keyPrefix: string)

    for k, v in inputTable do

        if string.sub(k, 1, #keyPrefix) ~= keyPrefix then

            if type(v) == "table" then
                setTableRecur(v, readonlyMetatable, keyPrefix)
            end

            inputTable[`{keyPrefix}{k}`] = v
            inputTable[k] = nil
        end
    end

    --Retain any existing metamethods other than index and newindex
    local newMetatable = getmetatable(inputTable) or {}

    --If you want to use an existing index method or table as a fallback,
    --Uncomment these two lines instead of using Line 29
    -- local oldIndex = newMetatable.__index
    -- newMetatable.__index = function(...)
    --     return readonlyMetatable.__index(...) or oldIndex(...) end

    newMetatable.__index = readonlyMetatable.__index
    newMetatable.__newindex = readonlyMetatable.__newindex
    setmetatable(inputTable, newMetatable)
end

---Create Readonly versions of pased tables.
local CreateReadonlyTableUtility = {}

---Create and edit in-place the passed table to make it read-only. Optional warn for attempted edit.
---@param inputTable table
---@param keyPrefix string The prefix added to key-names to protect their contents. Default: '_'.
---@param warnOnEditMsg string The message to print in warning when attempting to edit the table.
---@param tableName string The name of the table for warning output. Default: 'RO_Table'.
function CreateReadonlyTableUtility.SetTableReadonly(inputTable: table, keyPrefix: string,
    warnOnEditMsg: string, tableName: string)
    keyPrefix = keyPrefix or '_'
    tableName = tableName or 'RO_Table'

    local readonlyMetatable = {
        __index = function(tbl, key)
            if string.sub(key, 1, #keyPrefix) ~= keyPrefix then
                return tbl[`{keyPrefix}{key}`] end
            end,
        __newindex = function() if warnOnEditMsg then warn(warnOnEditMsg) end end
    }

    setTableRecur(inputTable, readonlyMetatable, keyPrefix)
end

---Create and edit in-place the passed table to make it read-only. Error on attempted edit.
---@param inputTable table
---@param keyPrefix string The prefix added to key-names to protect their contents. Default: '_'.
---@param warnOnEditMsg string The message to print in warning when attempting to edit the table.
---@param tableName string The name of the table for warning output. Default: 'RO_Table'.
function CreateReadonlyTableUtility.SetTableReadonlyStrict(inputTable: table, keyPrefix: string,
    warnOnEditMsg: string, tableName: string)
    keyPrefix = keyPrefix or '_'
    tableName = tableName or 'RO_Table'

    local readonlyMetatable = {
        __index = function(tbl, key)
            if string.sub(key, 1, #keyPrefix) ~= keyPrefix then
                return tbl[`{keyPrefix}{key}`] end
            end,
        __newindex = function() if warnOnEditMsg then error(warnOnEditMsg) end end
    }

    setTableRecur(inputTable, readonlyMetatable, keyPrefix)
end

return CreateReadonlyTableUtility