--!strict
--[[HIGH-LEVEL DESCRIPTION

Main Task (/1:
This Script is responsible for converting tables into a variant with hidden key-value access.

Minor Tasks (/5):
- Convert tables into hidden-key versions using the existing data.
- Exctract original table data from hidden-key versions.

Connections:
- N/A
*************************************************
]]--

---Recursively copies data from the passed readonly table into the new raw table.
---@param readonlyTable any
---@param keyPrefix string
---@param level number
---@param rawTable any
local function extractTable(readonlyTable, keyPrefix: string, level: number, rawTable)

    --KeyPrefix is removed as per the __iter metamethod of the readonly table.
    for key, value in readonlyTable do

        if type(value) == 'table' then
            rawTable[key] = {}
            extractTable(value, keyPrefix, level + 1, rawTable[key])
        else
            rawTable[key] = value
        end
    end
end

---Create an index function to define __index behaviour for a readonly or hidden-key table.
---@param keyPrefix string
---@return function
local function getReadonlyIndexMethod(keyPrefix: string)
    return function(tbl, key)
        key = tostring(key)

        if string.sub(key, 1, #keyPrefix) ~= keyPrefix then
            return tbl[`{keyPrefix}{key}`]
        else
            return nil
        end
    end
end

---Create a function to define __iter behaviour for a readonly or hidden-key table.
---@param keyPrefix string
---@return function
local function getReadonlyIterMethod(keyPrefix: string)
    return function(self)
        local nextKey = nil

        return function()
            local key, value = next(self, nextKey)

            if key then
                nextKey = key
                key = type(key) == 'string' and string.sub(key, #keyPrefix+1) or key
                key = tonumber(key) or key
                return key, value
            end
            return nil
        end
    end
end

---Overrides a set of keys in the passed table to use the specified string prefix.
---@param inputTable any
---@param keyPrefix string
---@param level number
local function hideTableKeys(inputTable, keyPrefix: string, level: number)
    local oldKeys = {}

    for k, v in inputTable do

        --Prevent circular assignment
        if string.sub(k, 1, #keyPrefix) ~= keyPrefix then

            if type(v) == "table" then
                hideTableKeys(v, keyPrefix, level + 1)
            end

            inputTable[`{keyPrefix}{k}`] = v
            table.insert(oldKeys, k)
        end
    end

    for _, k in oldKeys do
        inputTable[k] = nil
    end

    local newMetatable = getmetatable(inputTable) or {}
    newMetatable.__index = getReadonlyIndexMethod(keyPrefix)
    newMetatable.__iter = getReadonlyIterMethod(keyPrefix)
    setmetatable(inputTable, newMetatable)
end


local HiddenKeyTable = {}

---Creates a 'Hidden Key' version of the passed table by re-assigning its keys with a prefix.
---Re-assigns the __index and __iter metamethods.
---Any keys that already begin with the specified prefix will not be considered at any level.
---@param inputTable table
---@param keyPrefix string
function HiddenKeyTable.HideTableKeys(inputTable, keyPrefix: string)
    hideTableKeys(inputTable, keyPrefix, 1)
 end

 ---Returns a clean copy of the passed readonly table's data excluding metamethods.
 ---@param hiddenKeyTable any
 ---@param keyPrefix string
 ---@return any
 function HiddenKeyTable.ExtractTable(hiddenKeyTable, keyPrefix: string)
     local rawTable = {}
     extractTable(hiddenKeyTable, keyPrefix, 1, rawTable)

     return rawTable
 end

 return HiddenKeyTable