local RStorage = game:GetService("ReplicatedStorage")
local SnowballCannonEV = RStorage:WaitForChild("SnowballCannonEV", 10)

local debris = game:GetService("Debris")

local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local snowFlakes = {"66808700", "66808701", "66808703", "66808704", "66808705", "66808707", "66808711"}
local snowGlobs = {"66808543", "66808546"}

---Generates a snow GUI effect that covers the user's screen when hit by a snowball.
---Credit to the original tool creator (Unnamed)
local function Snowface()
	local guiMain = Instance.new("GuiMain")
	guiMain.Parent = PlayerGui
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "SnowfaceEffect"
	mainFrame.Position = UDim2.new(0, 0, 0, 0)
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor = BrickColor.new(1,1,1)
	mainFrame.Transparency = 1
	mainFrame.BorderColor = BrickColor.new(1,1,1)
	mainFrame.Parent = guiMain

	debris:AddItem(guiMain, 10)

	--- big glob
	local s = Instance.new("ImageLabel")
	local size = (math.random() * .2) + .5
	s.Size = UDim2.new(size,0,size,0)
	s.Position = UDim2.new(math.random() - (size/2),0, math.random() - (size/2),0)
	s.SizeConstraint = Enum.SizeConstraint.RelativeXX
	s.Transparency = 1
	s.Image = "http://www.roblox.com/asset/?id=" .. snowGlobs[math.random(1, #snowGlobs)]
	s.Parent = mainFrame

	debris:AddItem(s, 5 + (math.random() * 2))

	--flakes
	for i = 1, 20 do
		local s = Instance.new("ImageLabel")
		local size = (math.random() * .05) + .05
		s.Size = UDim2.new(size,0,size,0)
		s.Position = UDim2.new(math.random() - (size/2),0, math.random() - (size/2),0)
		s.SizeConstraint = Enum.SizeConstraint.RelativeXX
		s.Transparency = 1
		s.Image = "http://www.roblox.com/asset/?id=" .. snowFlakes[math.random(1, #snowFlakes)]
		s.Parent = mainFrame
		debris:AddItem(s, 3 + (math.random() * 6))
	end
end

if SnowballCannonEV ~= nil and SnowballCannonEV:GetAttribute("IsSnowballCannonEvent") then
	SnowballCannonEV.OnClientEvent:Connect(function()
		Snowface()
	end)
else
	print("No HitEV found")
end