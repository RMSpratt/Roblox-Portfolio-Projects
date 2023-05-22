local snowballCannon = script.Parent
local wielder = nil

--Convert the input's screen position to a position in the world
local camera = workspace.CurrentCamera

local ContextService = game:GetService("ContextActionService")

local FireEV = snowballCannon:WaitForChild("FireEV")

local Globals = {}
Globals.ACTIVATE_MOUSE_CONTEXT = "fireClick"
Globals.ACTIVATE_TAP_CONTEXT = "fireTap"

---Check if the tool wielder is alive
---@return boolean
local function isWielderAlive()

    if wielder:FindFirstChild("Humanoid") and wielder.Humanoid.Health > 0 then
        return true
    end

    return false
end


---CA Binding to determine the desired launch position for a snowball based on user input.
---@param _ string
---@param state Enum
---@param input InputObject
local function getTargetPosition(_, state, input)

	if state == Enum.UserInputState.Begin then

		if snowballCannon.Enabled then
			if not isWielderAlive() then
				ContextService:UnbindAction(Globals.ACTIVATE_MOUSE_CONTEXT)
				ContextService:UnbindAction(Globals.ACTIVATE_TAP_CONTEXT)

			else
				snowballCannon.Enabled = false
				local unitRay = camera:ScreenPointToRay(input.Position.X, input.Position.Y)

				FireEV:FireServer(unitRay)
				task.wait(0.5)
				snowballCannon.Enabled = true
			end
		end
	end
end

---OnEquip callback for the SnowballCannon.
local function onEquipped()
	wielder = snowballCannon.Parent

	local humanoid = wielder:WaitForChild("Humanoid")

	if humanoid and humanoid.Health > 0 then
		ContextService:BindAction(Globals.ACTIVATE_MOUSE_CONTEXT, getTargetPosition, false, Enum.UserInputType.MouseButton1)
		ContextService:BindAction(Globals.ACTIVATE_TAP_CONTEXT, getTargetPosition, false, Enum.UserInputType.Touch)
	end
end

---OnUnequip callback for the SnowballCannon.
local function onUnequipped()
	ContextService:UnbindAction(Globals.ACTIVATE_MOUSE_CONTEXT)
	ContextService:UnbindAction(Globals.ACTIVATE_TAP_CONTEXT)
end

--Event callbacks
snowballCannon.Equipped:connect(onEquipped)
snowballCannon.Unequipped:connect(onUnequipped)