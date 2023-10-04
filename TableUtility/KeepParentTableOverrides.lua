---This example demonstrates an inheritance relationship that maintains overridden methods.
---The overridden BaseClass methods are invoked prior to the ChildClass methods.
---The overridden methods can be hidden or unhidden.

---The BaseClass to inherit from.
local BaseClass = {}

--The ChildClass to create instances of.
local ChildClass = {}
setmetatable(ChildClass, {__index = ChildClass})

---Create an instance of the Child Class
---@return table
function ChildClass.New()
    local newChild = {}

    for k,v in BaseClass do

        if ChildClass[k] and type(v) == "function" then

            --Hide BaseClass methods, only allowing indirect invocation.
            newChild[k] = function(self) BaseClass[k](self) ChildClass[k]() end

            --Alt: Allow Access to BaseClass methods for direct invocation.
            --newChild[`_{k}`] = v
            --newChild[k] = function(self) newChild[`_{k}`](self) ChildClass[k]() end
        else
            newChild[k] = v
        end
    end

    setmetatable(newChild, ChildClass)

    return newChild
end
