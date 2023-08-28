--[[ Sample Testing Insert
----#region Testing Instructions
--  local TestMod = require(script.Parent.Parent.Test)

--  for _, errMsg in TestMod.CheckParamTypes({
--      ...
--  }) do
--         table.insert(..., errMsg)
--  end

-- for _, errMsg in TestMod.CheckLocalTypes({
--     ...
-- })  do
--         table.insert(..., errMsg)
-- end

-- if #<errors> > 0 then
--     return
-- end
----#endregion
]]--

---Validates a table of variables according to each's expected and actual types.
---@param variableTypeMoniker string
---@param variableTable table
---@return table
local function _checkVariableTypes(variableTypeMoniker: string, variableTable: table)
    local errTable = {}

    for variableIdx, variableInfo in ipairs(variableTable) do

        if variableInfo[2] then
            local actualType = string.lower(typeof(variableInfo[2]))

            if actualType == "instance" and variableInfo[1] ~= actualType then

                if not variableInfo[2]["ClassName"] then
                    table.insert(errTable, `Invalid {variableTypeMoniker} var type #{variableIdx}. Ex: {variableInfo[1]} Actual: {actualType}.`)

                elseif string.lower(variableInfo[2].ClassName) ~= string.lower(variableInfo[1]) then
                    table.insert(errTable, `Invalid {variableTypeMoniker} var type #{variableIdx}. Ex: {variableInfo[1]} Actual: {variableInfo[2].ClassName}.`)
                end

            elseif actualType ~= string.lower(variableInfo[1]) then
                    table.insert(errTable, `Invalid {variableTypeMoniker} var type #{variableIdx}. Ex: {variableInfo[1]} Actual: {actualType}.`)
            end
        else
            table.insert(errTable, `Missing variable {variableTypeMoniker}_{variableIdx}.`)
        end
    end

    return errTable
end

local TestAccess = {
    Types = {
        Character = "character",
        Folder = "folder",
        Function = "function",
        Instance = "instance",
        Modulescript = "modulescript",
        Number = "number",
        Player = "player",
        RemoteEvent = "remoteEvent",
        RemoteFunction = "remoteFunction",
        String = "string",
        Table = "table",
        Vector = "vector",
    }
}

---Checks the passed Instance for a set of expected attributes.
---@param instanceToCheck Instance
---@param attribTable table
function TestAccess.CheckInstanceAttributes(instanceToCheck: Instance, attribTable: table)
    local errTable = {}

    for attribName, attribType in pairs(attribTable) do
        local actualAttrib = instanceToCheck:GetAttribute(attribName)

        if actualAttrib then

            if not typeof(actualAttrib) == attribType then
                table.insert(errTable, `Unexpected value on {instanceToCheck.Name} for attribute {attribName}.`)
            end

        else
            table.insert(errTable, `Missing attribute {attribName} on {instanceToCheck.Name}`)
        end
    end

    return errTable
end

---Evaluates each {type, value} pair to see if the value matches the expected type (string).
---@param localTable table
---@return table
function TestAccess.CheckLocalTypes(localTable: {[string]: any})
    return _checkVariableTypes("local", localTable)
end

---Evaluates each {type, value} pair to see if the value matches the expected type (string).
---@param paramTable table
---@return table
function TestAccess.CheckParamTypes(paramTable: {[string]: any})
   return _checkVariableTypes("param", paramTable)
end

---Checks if the passed value exists within the lookup table provided.
---@param lookupValue any
---@param lookupTableName string
---@param lookupTable table
---@return table
function TestAccess.CheckValueInLookup(lookupValue: any, lookupTableName: string, lookupTable: table)

    if not lookupTable[lookupValue] then
        return {`Missing expected value {lookupValue} within the lookup table {lookupTableName}.`}
    end

    return {}
end

---Evaluates each {type, value} pair to see if the value matches the expected type (string).
---@param moniker string
---@param valueTable table
---@return table
function TestAccess.CheckVariableTypes(moniker: string, valueTable: {[string]: any})

    if not moniker then
        moniker = "variable"
    end
    return _checkVariableTypes(moniker, valueTable)
end

---Returns a formatted warning message for an Instance missing a required attribute.
---@param instanceName string
---@param expectedAttrib string
---@return string
function TestAccess.WarnMissingAttrib(instanceName: string, expectedAttrib: string)
    return (`Instance {instanceName} missing expected attribute {expectedAttrib}.`)
end

---Returns a formatted warning message for a missing Instance.
---@param searchName string
---@param parentName string
---@return string
function TestAccess.WarnMissingInstance(searchName: string, parentName: string)
    return (`Parent {parentName} is missing expected child {searchName}.`)
end

---Returns a formatted warning message for an unexpected variable type.
---@param variableName string
---@param actualType string
---@param expectedType string
---@return string
function TestAccess.WarnUnexpectedType(variableName: string, actualType: string, expectedType: string)
    return (`Variable {variableName} is type {actualType} and not expected type {expectedType}.`)
end

return TestAccess