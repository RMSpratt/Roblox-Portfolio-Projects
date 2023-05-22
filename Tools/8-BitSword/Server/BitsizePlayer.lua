--Credit to LuckyMaxer for original part qualities and base bit model generation code

local Debris = game:GetService("Debris")

--Size of each bit block representing a player
local BIT_SIZE = 0.5

--The lifetime for the 8bit player model before it is destroyed
local BIT_LIFETIME = 10

--Whether or not the original reflective adornments to the parts should be kept
local USE_ORIGINAL_APPEARANCE = true

--[[FUNCTION: _setOriginalAppearance

	This function was entirely pulled from the original 8BitSword code.
	This function applies the same visual effects to the blocks that are used in the original weapon.
	Full credit for this function's code goes to LuckyMaxer.
]]
local function _setOriginalAppearance(block)
	local specMesh = Instance.new("SpecialMesh")
	specMesh.Name = "Mesh"
	specMesh.MeshType = Enum.MeshType.Brick
	specMesh.Offset = Vector3.new(0, 0, 0)
	specMesh.VertexColor = Vector3.new(1, 1, 1)
	specMesh.Parent = block

	local Surfaces = {
		{Surface = "Top", Shading = 20},
		{Surface = "Bottom", Shading = 40},
		{Surface = "Left", Shading = 60},
		{Surface = "Right", Shading = 80},
		{Surface = "Front", Shading = 100},
		{Surface = "Back", Shading = 120},
	}

	local color = block.BrickColor.Color
	local r = color.r
	local g = color.g
	local b = color.b

	for i, v in pairs(Surfaces) do
		local Shading = (v.Shading / 255)
		local FrameColor = Color3.new((r + Shading), (g + Shading), (b + Shading))
		local SurfaceImage = Instance.new("SurfaceGui")
		SurfaceImage.Adornee = block
		SurfaceImage.CanvasSize = Vector2.new(800, 600)
		SurfaceImage.Face = Enum.NormalId[v.Surface]
		SurfaceImage.Active = false
		SurfaceImage.Enabled = true

		local imageFrame = Instance.new("Frame")
		imageFrame.Position = UDim2.new(0, 0, 0, 0)
		imageFrame.Size = UDim2.new(1, 0, 1, 0)
		imageFrame.BorderSizePixel = 2
		imageFrame.BackgroundColor3 = FrameColor
		imageFrame.BorderColor3 = FrameColor
		imageFrame.ZIndex = 1
		imageFrame.Parent = SurfaceImage
		SurfaceImage.Parent = block
	end
end


---Creates a "bit" block used to represent bloxxed Players.
---@return Instance
local function createBitBlock()
	local bitBlock = Instance.new("Part")
	bitBlock.Shape = Enum.PartType.Block
	bitBlock.Material = Enum.Material.SmoothPlastic
	bitBlock.FormFactor = Enum.FormFactor.Custom
	bitBlock.Size = Vector3.new(BIT_SIZE, BIT_SIZE, BIT_SIZE)
	bitBlock.CanCollide = true
	bitBlock.Locked = true
	bitBlock.Anchored = false
	bitBlock.Friction = 0.3
	bitBlock.Elasticity = 0.5

	return bitBlock
end


---Converts a bloxxed player part into a series of bit blocks.
---@param part Instance
local function bitsizePart(part)
	local fullBitModel = Instance.new("Model")
	fullBitModel.Name = "BitModel"

	local refBit = createBitBlock()

	--Determine how many parts to create for each body limb
	local numBitsX = math.min(math.floor(part.Size.X / BIT_SIZE), 5)
	local numBitsY = math.min(math.floor(part.Size.Y / BIT_SIZE), 5)
	local numBitsZ = math.min(math.floor(part.Size.Z / BIT_SIZE), 5)

	--Get the edges of the part as the start locations for placing 8-bit parts
	local leftEdge = (-(part.Size.X / 2) + BIT_SIZE / 2)
	local topEdge = ((part.Size.Y / 2) - BIT_SIZE / 2)
	local backEdge = (-(part.Size.Z / 2) + BIT_SIZE / 2)

	--Calculate the difference between the bit's total length on an axes and the part dimension
	--This will space out the bit blocks if they don't take up the full dimensional space of a part
	local xMidOffset = (part.Size.X - (BIT_SIZE * numBitsX)) / 2
	local yMidOffset = (part.Size.Y - (BIT_SIZE * numBitsY)) / 2
	local zMidOffset = (part.Size.Z - (BIT_SIZE * numBitsZ)) / 2

	--Create each bit
	for x=1, numBitsX do
		for y=1, numBitsY do
			for z=1, numBitsZ do
				local bitBlock = refBit:Clone()

				--Offset each bit in the array by the size of the previously placed bits
				local xPos = xMidOffset + (leftEdge + (BIT_SIZE * (x - 1)))
				local yPos = yMidOffset - (topEdge - (BIT_SIZE * (y - 1)))
				local zPos = zMidOffset + (backEdge + (BIT_SIZE * (z - 1)))

				bitBlock.Color = part.Color
				bitBlock.CFrame = (part.CFrame * CFrame.new(xPos, yPos, zPos))

				--Apply the shaders and surfaceimages to each block
				if USE_ORIGINAL_APPEARANCE then
					_setOriginalAppearance(bitBlock)
				end

				bitBlock.Parent = fullBitModel
			end
		end
	end

	Debris:AddItem(fullBitModel, BIT_LIFETIME)
	fullBitModel.Parent = workspace
end


-- MODULE --

local Bitsize = {}

---Create an 8bit model for the passed model (Assumed to be a player/humanoid)
---@param player Player
function Bitsize.GenerateBitModel(player)
	local limbs = {}

	--1) Clear the player's body while storing their limbs
	for _, part in pairs(player:GetChildren()) do

		--Only visible parts of a Player model will be converted to bits
		if part:IsA("BasePart") then

			if part.Transparency < 1 then
				table.insert(limbs, part:Clone())
			end

			part:Destroy()

		elseif part:IsA("Tool") or part:IsA("Accessory") then
			part:Destroy()
		end
	end

	--2) Create 8bit representations of the player's limbs
	for _, part in pairs(limbs) do
		bitsizePart(part)
	end
end

return Bitsize
