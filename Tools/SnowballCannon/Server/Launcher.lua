local Debris = game:GetService("Debris")

local SnowballCannonEV = nil
local FireEV = nil

local Config = {}
Config.CAN_COLLIDE = false
Config.LAUNCH_POWER = 500
Config.MAX_DISTANCE = 200
Config.LIFETIME = 5
Config.FIRE_RATE = 0.5

local snowballCannon = script.Parent
local handle = snowballCannon.Handle

local hitsounds = {"19326853", "19326880", "19326891"}
local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset/?id=" .. hitsounds[math.random(1,#hitsounds)]
HitSound.Parent = handle
HitSound.Volume = 1

local isEquipped = false

local wielder = nil

--The target position of the most recently launched snowball
local snowballTargetPos = nil

local SFX = {}
SFX.Fire = handle.Fire

--script.Parent.SnowballScript:clone().Parent = snowBall

local cannonParams = RaycastParams.new()
cannonParams.FilterType = Enum.RaycastFilterType.Blacklist

---Check if the tool wielder is alive
---@return boolean
local function isWielderAlive()

    if wielder:FindFirstChild("Humanoid") and wielder.Humanoid.Health > 0 then
        return true
    end

    return false
end

---Check if the Tool can be equipped by the wielder Player
---@return boolean
local function isToolEquipped()
	local toolEquipped = false

	if wielder then
		local rightArm = wielder:FindFirstChild("Right Arm") or wielder:FindFirstChild("RightHand")

		if rightArm then
			local rightGrip = rightArm:FindFirstChild("RightGrip")

			if rightGrip and (rightGrip.Part0 == handle or rightGrip.Part1 == handle) then
				toolEquipped = true
			end
		end
	end

	return toolEquipped
end

---Builds a new Snowball part instance.
---@return Instance
local function CreateSnowball()
    local snowball = Instance.new("Part")
    snowball.Size = Vector3.new(1, 1, 1)
    snowball.Shape = 0
    snowball.BrickColor = BrickColor.new("Pastel blue-green")
    snowball.Material = Enum.Material.Concrete
    snowball.Locked = true
    snowball.TopSurface = 0
    snowball.BottomSurface = 0
    snowball.Massless = true
    snowball.CanCollide = false
    return snowball
end


---Have the Snowball explode on impact generating snow parts.
---@param impactPoint any
local function Explode(impactPoint)
	local count = 5
	for _ = 1, count do
		local p = Instance.new("Part")
		p.BrickColor = BrickColor.new("Pastel blue-green")
		p.formFactor = 2
		p.Size = Vector3.new(1,.4,1)
		p.Material = Enum.Material.Ice
		p.TopSurface = 0
		p.BottomSurface = 0
		p.Position = impactPoint + Vector3.new(math.random(-2,2),math.random(1,2),math.random(-2,2))
		p.Parent = game.Workspace
		Debris:AddItem(p, 6)
	end
end


---Generates a snowball and launches it at the Player.
---@param fireRay RaycastParams
local function FireSnowball(fireRay)
	local launchPower = Config.LAUNCH_POWER
    local launchDirection = nil
    local launchForce = Instance.new("VectorForce")
    local launchAttach = Instance.new("Attachment")
    local newSnowball = CreateSnowball()
    local gravForce = newSnowball.Mass * workspace.Gravity

	--Perform a raycast to see if a specific target was hit
	local hit = workspace:Raycast(fireRay.Origin, fireRay.Direction * Config.MAX_DISTANCE, cannonParams)

	--If a target was hit, use the raycast result as the target for the snowball
	if hit and hit.Instance then
		snowballTargetPos = hit.Position
		launchDirection = (hit.Position - handle.Position).Unit

		--Optional: Scale the force by proximity of the target selected
		if (hit.Position - handle.Position).Magnitude < 10 then
			launchPower = 100
		end
	else
		snowballTargetPos = nil
		local destPos = fireRay.Origin + fireRay.Direction * Config.MAX_DISTANCE
		launchDirection = (destPos - handle.Position).Unit
	end

	--Offset the effect of gravity when launching
    launchAttach.Parent = newSnowball
    launchForce.Force = Vector3.new(launchDirection.X * launchPower, launchDirection.Y * launchPower + gravForce, launchDirection.Z * launchPower)
	launchForce.RelativeTo = Enum.ActuatorRelativeTo.World
	launchForce.ApplyAtCenterOfMass = true
	launchForce.Attachment0 = launchAttach

	newSnowball.Position = handle.Position + (launchDirection * 3)
	newSnowball.Parent = game.Workspace
	launchForce.Parent = newSnowball

	newSnowball.Touched:Connect(function(other)

        if other then
            local parentObj = other.Parent

            --Don't allow the player to hit themselves
            if parentObj then

                if not wielder or not wielder:IsAncestorOf(other) then
                    local humanoid = nil

                    HitSound:Play()

                    if parentObj:IsA("Accessory") or parentObj:IsA("Tool") then
                        parentObj = parentObj.Parent
                    end

                    humanoid = parentObj:FindFirstChild("Humanoid")

                    if humanoid then
                        local targetPlr = game:GetService("Players"):GetPlayerFromCharacter(humanoid.Parent)

                        if targetPlr then
                            print("Hit!")
                            SnowballCannonEV:FireClient(targetPlr)
                        end
                    end

                    if snowballTargetPos then

                        Explode(snowballTargetPos)
                    else
                        Explode(newSnowball.Position)
                    end
                    newSnowball:Destroy()
                end
            end
        end
    end)

	SFX.Fire:Play()
	Debris:AddItem(launchForce, 2)
	Debris:AddItem(newSnowball, Config.LIFETIME)
    snowballCannon.Enabled = false
	task.wait(Config.FIRE_RATE)
	snowballCannon.Enabled = true
end

---Initilization Step.
local function _Initialize()
    local RStorage = game:GetService("ReplicatedStorage")

    SnowballCannonEV = RStorage:FindFirstChild("SnowballCannonEV")
    FireEV = snowballCannon:FindFirstChild("FireEV")

    if not SnowballCannonEV or not SnowballCannonEV:GetAttribute("IsSnowballCannonEvent") then
        SnowballCannonEV = Instance.new("RemoteEvent")
        SnowballCannonEV.Name = "SnowballCannonEV"
        SnowballCannonEV:SetAttribute("IsSnowballCannonEvent", true)
        SnowballCannonEV.Parent = RStorage
    end

    if not FireEV then
        FireEV = Instance.new("RemoteEvent")
        FireEV.Name = "FireEV"
        FireEV.Parent = snowballCannon
    end
end

_Initialize()

--Respond to the Player using the Snowball Cannon tool on the client
FireEV.OnServerEvent:Connect(function(_, fireRay)

    if isEquipped and isToolEquipped() and isWielderAlive() then
        FireSnowball(fireRay)
    end
end)


snowballCannon.Equipped:Connect(function()
	wielder = snowballCannon.Parent
    isEquipped = true

    local wielderPlr = game:GetService("Players"):GetPlayerFromCharacter(wielder)

	if isWielderAlive() and wielderPlr then
        cannonParams.FilterDescendantsInstances = {wielder}
	end
end)

snowballCannon.Unequipped:Connect(function()
    wielder = nil
    isEquipped = false
end)