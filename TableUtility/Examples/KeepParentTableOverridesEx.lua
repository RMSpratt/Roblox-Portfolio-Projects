---Examples of the "KeepOverloadMethods" pattern in action.

--Example One: Custom Pizza Creation
type Pizza = {
    BakeTime: number,
    AddSauce: () -> nil,
    AddToppings: () -> nil,
    Bake: () -> nil,
    KneadDough: () -> nil,
}

---BASE CLASS TO BE DERIVED FROM
local BasePizza: Pizza = {
    BakeTime = 5,
}

---Bake the Pizza.
function BasePizza:Bake()
    task.wait(self.BakeTime)
    print("Pizza's ready!")
end

---Add Sauce to the Pizza.
function BasePizza:AddSauce()
    print("Add tomato sauce.")
end

---Add Toppings to the Pizza.
function BasePizza:AddToppings()
    print("Add cheese.")
end

---Knead the Dough.
function BasePizza:KneadDough()
    print("Kneading the dough...")
end

---CHILD CLASS TO INHERIT FROM BASE
local PepperoniPizza: Pizza = {
    BakeTime = 8
}
setmetatable(PepperoniPizza, {__index = PepperoniPizza})

---Create a New Pepperoni Pizza.
---@return any
function PepperoniPizza.New()
    local newPizza = {}

    for k,v in BasePizza do

        if PepperoniPizza[k] and type(v) == "function" then
            newPizza[k] = function(self) BasePizza[k](self) PepperoniPizza[k]() end
        else
            newPizza[k] = v
        end
    end

    setmetatable(newPizza, PepperoniPizza)

    return newPizza
end

---Add Toppings to the Pizza. Override BasePizza method.
function PepperoniPizza:AddToppings()
    --Inherit BasePizza functionality and then add additional toppings.
    print("Add pepperoni.")
end

local newPeppPizza = PepperoniPizza.New()
newPeppPizza:KneadDough()
newPeppPizza:AddSauce()
newPeppPizza:AddToppings()
newPeppPizza:Bake()


--Example Two: Custom Warning Output.

type Warning = {
    WarningType: string,
    WarningMessage: string
}

---BASE CLASS TO BE DERIVED FROM
local BaseWarning: Warning = {
    WarningType = "BaseWarning",
    WarningMessage = "Something went wrong.",
}

---Log a Warning to output.
function BaseWarning:PrintWarningFromObject()
    warn(`{self.WarningType}: {self.WarningMessage}`)
end

---Get the Type of Warning.
function BaseWarning:GetType()
    return self.WarningType
end

---CHILD CLASS TO INHERIT FROM BASE
local MissingArgWarning: Warning = {
    WarningMessage = "Missing Argument"
}
setmetatable(MissingArgWarning, {__index = MissingArgWarning})

---Create a new MissingArgWarning.
---@return table
function MissingArgWarning.New()
    local newWarning: Warning = {}

    for k,v in BaseWarning do

        if MissingArgWarning[k] and type(v) == "function" then
            newWarning[`_{k}`] = v
            newWarning[k] = function(self) newWarning[`_{k}`](self) MissingArgWarning[k]() end

        else
            newWarning[k] = v
        end
    end

    setmetatable(newWarning, MissingArgWarning)

    return newWarning
end

---Print the MissingArgWarning message along with a proximity stack trace.
function MissingArgWarning:PrintWarningFromObject()
    warn(debug.info(3, "sln"))
end


