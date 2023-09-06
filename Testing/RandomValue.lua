export type NumberRangeWeight = {
    MinNum: number,
    MaxNum: number,
    Weight: number
}

export type TableKeyWeight = {
    Key: any,
    Weight: number
}

--A series of NumberRangeWeight values
export type NumberRangeWeightTable = {
    [number]: NumberRangeWeight
}

--A series of TableKeyWeight values
export type TableKeyWeightTable = {
    [number]: TableKeyWeight
}

local randGenerator: Random = Random.new(tick())

local RandomValueFuncs = {}

---Get a random value from the passed array table.
---@param arrayTable table The array table to select from
---@return any
function RandomValueFuncs.GetArrayValueByIndex(arrayTable: {[number]: any})
    return arrayTable[randGenerator:NextInteger(1, #arrayTable)]
end

---Get a random boolean value assignment with optional weight influence.
---@param weightTrue number The percentage chance [0-1] to generate a true value.
---@return boolean
function RandomValueFuncs.GetBooleanValue(weightTrue: number)
    weightTrue = tonumber(weightTrue) or 0.5

    return randGenerator:NextNumber() < weightTrue
end

---Gets a random integer from within a range according to uniform distribution.
---@param minNum number
---@param maxNum number
---@return number
function RandomValueFuncs.GetIntegerInRange(minNum: number, maxNum: number)
    minNum = tonumber(minNum) or 0
    maxNum = tonumber(maxNum) or 0

    if maxNum < minNum then
        local temp = minNum
        minNum = maxNum
        maxNum = temp
    end

    return randGenerator:NextInteger(minNum, maxNum)
end

---Gets a random number from within the range [0,1] with an optional specification for rounding.
---@param numDecimalPlaces number
---@return number
function RandomValueFuncs.GetNumber01(numDecimalPlaces: number)
    local generatedNum = randGenerator:NextNumber()

    numDecimalPlaces = tonumber(numDecimalPlaces)

    return(tonumber(string.format(string.format("%%.df"), numDecimalPlaces), generatedNum))
end

---Get a random value from the passed table. Uniform selection across the keys is used.
---@param keyValueTable table The key-value table to select from
---@return any
function RandomValueFuncs.GetTableValueByKey(keyValueTable: table)
    local selectedValue = nil
    local chancePerKey = 1
    local weightSelectedValue = randGenerator:NextNumber()
    local totalWeight = 0
    local numTableKeys = 0

    if not type(keyValueTable) ~= "table" then
        warn(debug.traceback("Invalid object passed for random selection."))
        return nil
    end

    for _ in keyValueTable do
        numTableKeys += 1
    end

    if numTableKeys == 0 then
        warn(debug.traceback("Empty key-value table passed for random selection."))
        return nil
    end

    chancePerKey = 1 / numTableKeys

    for _, tableValue in keyValueTable do
        totalWeight += chancePerKey

        if weightSelectedValue < totalWeight then
            selectedValue = tableValue
            break
        end
    end

    return selectedValue
end

---Get a random value from the passed array. Weighted selection is used based on probabilities specified.
---@param arrayTable table The array table to select from
---@param indexWeightTable table The weight assigned to each index for selection
---@return any
function RandomValueFuncs.GetWeightedArrayValueByIndex(arrayTable: {[number]: any}, indexWeightTable: table)
    local selectedValue = 0
    local totalWeight = 0
    local weightSelectValue = randGenerator:NextNumber()

    if not type(arrayTable) ~= "table" then
        warn(debug.traceback("Invalid object passed for random selection."))
        return nil
    end

    if not type(indexWeightTable) ~= "table" then
        warn(debug.traceback("Invalid object passed for weight table."))
        return nil
    end

    for arrayIdx, idxWeight in ipairs(indexWeightTable) do
        totalWeight += tonumber(idxWeight)

        if weightSelectValue < totalWeight then
            selectedValue = arrayTable[arrayIdx]
            break
        end
    end

    if (totalWeight - 1) > 0.001 then
        warn(debug.traceback("Weights exceed 1.00. Some values were not considered for selection.", 1))

    elseif (totalWeight - 1) < -0.001 then
        warn(debug.traceback("Weights subceded 1.00. Final value given extra weight.", 1))
    end

    return selectedValue
end

---Gets a random integer from within a range according to a stepwise weight distribution.
---@param numRanges table
---@return number
function RandomValueFuncs.GetWeightedIntegerInRange(numRanges: NumberRangeWeightTable)
    local generatedNum = 0
    local totalWeight = 0

    local weightSelectValue = randGenerator:NextNumber()

    if not type(numRanges) == "table" then
        warn(debug.traceback("Invalid object passed for NumberRangeWeightTable."))
        return 0
    end

    for _, weightedRange: NumberRangeWeight in ipairs(numRanges) do
        totalWeight += tonumber(weightedRange.Weight) or 0

        if weightSelectValue < totalWeight then
            generatedNum = RandomValueFuncs.GetIntegerInRange(weightedRange.MinNum, weightedRange.MaxNum)
            break
        end
    end

    return generatedNum
end

---Get a random value from the passed table. Weighted selection is used based on probabilities specified.
---Table keys not specified in keyWeightTable are not considered for selection.
---@param keyValueTable table The key-value table to select from
---@param keyWeightTable table The weight assigned to each key for selection
---@return any
function RandomValueFuncs.GetWeightedTableValueByKey(keyValueTable: table, keyWeightTable: table)
    local selectedValue = nil
    local weightSelectedValue = randGenerator:NextNumber()

    local totalWeight = 0

    --Maps a loop iteration index value to the associated key in keyValueTable
    local valueIndexToKeyNameMap = {}

    --The weight thresholds applied to each key-value pair in keyValueTable for selection
    local valueWeightTable = {}

    if not type(keyValueTable) ~= "table" then
        warn(debug.traceback("Invalid object passed for random selection."))
        return nil
    end

    if not type(keyWeightTable) ~= "table" then
        warn(debug.traceback("Invalid object passed for weight table."))
        return nil
    end

    --Iterate through the key-weight pairs dictated in keyWeightTable
    --Assign each key with a total weight as a cutoff to compare with weightSelectedValue
    --Number indices are used for valueWeightTable to preserve iteration order
    for weightInfoIdx, weightInfo: TableKeyWeight in keyWeightTable do
        totalWeight += weightInfo.Weight

        valueWeightTable[weightInfoIdx] = totalWeight
        valueIndexToKeyNameMap[weightInfoIdx] = weightInfo.Key
    end

    if (totalWeight - 1) > 0.001 then
        warn(debug.traceback("Weights exceed 1.00. Some values were not considered for selection.", 1))

    elseif (totalWeight - 1) < -0.001 then
        warn(debug.traceback("Weights subceded 1.00. Final value given extra weight.", 1))
    end

    --Select the value to be returned
    --Iterate in-order from the smallest key-weight pair threshold to the largest
    --The first threshold larger than the selected random value will be the key to choose
    for keyWeightIndex, keyWeightStep in ipairs(valueWeightTable) do

        if weightSelectedValue < keyWeightStep then
            selectedValue = valueIndexToKeyNameMap[keyWeightIndex]
            break
        end
    end

    return selectedValue
end

---Sets the Module's random number generator to use the seed passed.
---@param seed number
function RandomValueFuncs.SetRandomSeed(seed: number)
    randGenerator = Random.new(tonumber(seed) or 0)
end

---Generates a new random seed for the Module's random number generator.
function RandomValueFuncs.SetNewRandomSeed()
    randGenerator = Random.new(tick())
end

return RandomValueFuncs