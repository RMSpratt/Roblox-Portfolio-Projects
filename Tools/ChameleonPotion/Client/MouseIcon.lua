--Made by Luckymaxer, modified by WhySoMysterious

local ACTIVE_ICON = "rbxasset://textures/GunCursor.png"
local RELOADING_ICON = "rbxasset://textures/GunWaitCursor.png"

local tool = script.Parent
local mouse = nil

---Update the Mouse Icon when using the Weapon
function UpdateIcon()
	if mouse then
		mouse.Icon = tool.Enabled and ACTIVE_ICON or RELOADING_ICON
	end
end

---OnEquip Mouse Icon.
---@param ToolMouse Mouse
function OnEquipped(ToolMouse)
	mouse = ToolMouse
	UpdateIcon()
end

---OnChange Mouse Icon
---@param isEnabled boolean
function OnEnabled(isEnabled)
	if tool.Parent:FindFirstChild("Humanoid") then
		UpdateIcon()
	end
end

tool.Equipped:Connect(OnEquipped)
tool:GetPropertyChangedSignal("Enabled"):Connect(OnEnabled)
