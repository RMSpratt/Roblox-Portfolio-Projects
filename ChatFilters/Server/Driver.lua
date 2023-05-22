--Driver script for testing functionality

local ChatMod = require(script.Parent.PrivateChat)

ChatMod.StartFiltering()
ChatMod.RegisterPrivateChat('Dead')

game:GetService('Players').PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(character)
        ChatMod.JoinPrivateChat(player, 'Dead')
    end)
end)