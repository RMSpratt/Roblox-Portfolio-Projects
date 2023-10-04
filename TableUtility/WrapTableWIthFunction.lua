--This module provides a method to wrap a table's functions with another function.
--The wrapper function can perform functionality before or after the table function is called.
--The wrapper function could otherwise prevent table function calls if desired.

---Provides a method to wrap a table's functions with a wrapper function.
local WrapTableUtility = {}

---Filter all of the passed BaseTable's functions with the passed wrapper function.
---@param baseTable table
---@param wrapperFunc function
function WrapTableUtility.WrapTable(baseTable: table, wrapperFunc: ((any) -> (any), ...any) -> (any))
    local tableFuncs = {}

    for k, v in baseTable do

        if (type(v) == "function") then
            tableFuncs[k] = v
        end
    end

    for k, v in tableFuncs do
        baseTable[k] = function(...) return wrapperFunc(v, ...) end
    end
end

return WrapTableUtility