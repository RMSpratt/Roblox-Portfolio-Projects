--[[Description of Script

This script offers functions to allow for players to join and leave exclusive 'private' chat channels such that messages sent
within the private channel are only visible within the channel.

Note: This does not prevent the player from seeing messages from other non-private chat channels i.e. "All/System".

This could be used to allow players to chat privately without having to specify which chat to message in.
The downside is that they would have to leave the private chat or be removed from the private chat for other players to get messages.

A potential use case for this type of chatroom that completely blocks cross-communication is for team chats, i.e. when implementing a "Dead" chat channel.
]]

local SScriptService = game:GetService("ServerScriptService")
local ChatService = require(SScriptService:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))

local chat = game:GetService("Chat")

--The regular chat channel that all players are subscribed to
local GlobalChatChannel = ChatService:GetChannel("All")

local PrivateChatFuncs = {
	PrivateChatSubscribers = {}
}

---Filter messages for the given channel such that messages from players in private chat channels
---@param speakerName string
---@param message string
---@param _ any
---@return boolean
function PrivateChatFuncs.FilterMessages(speakerName, message, _)
	local speaker = ChatService:GetSpeaker(speakerName)
	local privateChannel = nil

	if PrivateChatFuncs.PrivateChatSubscribers[speakerName] then
		privateChannel = ChatService:GetChannel(PrivateChatFuncs.PrivateChatSubscribers[speakerName])
	end

	if not speaker or not privateChannel then return false end

	--Only send the message in the private chat channel
	speaker:SayMessage(message, privateChannel.Name)
	return true
end

---Subscribe the Player to the specified chat channel.
---@param player Player
---@param channelName string
function PrivateChatFuncs.JoinPrivateChat(player, channelName)
	local chatSpeaker = ChatService:GetSpeaker(player.Name)

	if chatSpeaker then

		if channelName and ChatService:GetChannel(channelName) then
			if not chatSpeaker:IsInChannel(channelName) then

				local oldChannelName = PrivateChatFuncs.PrivateChatSubscribers[player.Name]

				if oldChannelName and chatSpeaker:IsInChannel(oldChannelName) then
					chatSpeaker:LeaveChannel(oldChannelName)
				end

				chatSpeaker:JoinChannel(channelName)
				PrivateChatFuncs.PrivateChatSubscribers[player.Name] = channelName

				--local channelObj = ChatService:GetChannel('To' .. chatSpeaker.Name)
			end
		else
			warn("Private chat channel: " .. tostring(channelName) .. " does not exist.")
		end
	end
end

---Unsubscribe the player from the specified chat channel
---@param player Player
---@param channelName string
function PrivateChatFuncs.LeavePrivateChat(player, channelName)
	local chatSpeaker = ChatService:GetSpeaker(player.Name)

	if channelName and ChatService:GetChannel(channelName) then
		if chatSpeaker then

			--Kick the Player from the filtered chat channel
			chatSpeaker:LeaveChannel(channelName)
			PrivateChatFuncs.PrivateChatSubscribers[player.Name] = nil
		end
	else
		warn("Private chat channel: " .. tostring(channelName) .. " does not exist.")
	end
end

---Register a new private chat for use
---@param channelName string
function PrivateChatFuncs.RegisterPrivateChat(channelName)

	if channelName and not ChatService:GetChannel(channelName) then
		local privateChat = ChatService:AddChannel(channelName)
		privateChat.Joinable = false
		privateChat.Leavable = false
		privateChat.AutoJoin = false
		privateChat.Private = true
	end
end


---Start filtering messages for all chat channels.
function PrivateChatFuncs.StartFiltering()

	--Register the filter function
	if GlobalChatChannel then
		GlobalChatChannel:RegisterProcessCommandsFunction("filterMessages", PrivateChatFuncs.FilterMessages)
	end

	--ChatService:UnregisterProcessCommandsFunction("whisper_commands")
end

---Utility function to stop a filter function
function PrivateChatFuncs.StopFiltering()

	--Remove the filter function
	if GlobalChatChannel then
		GlobalChatChannel:UnregisterProcessCommandsFunction("filterMessages")
	end
end


---Unregister a private chat
function PrivateChatFuncs.UnregisterPrivateChat(channelName)

	if channelName and not ChatService:GetChannel(channelName) then
		local privateChat = ChatService:AddChannel(channelName)
		privateChat.Joinable = false
		privateChat.Leavable = false
		privateChat.AutoJoin = false
		privateChat.Private = true
	end
end


---Optional function to filter whispers.
function PrivateChatFuncs.FilterWhispers(speakerName, messageObj, channelName)

	--Filter Option 1: Change the message to 'Redacted' or something similar
	--Filter Option 2: Register a Process Commands Function instead to hide the message altogether
	messageObj.Message = "Redacted"
end

---Detection for whisper channels
ChatService.ChannelAdded:Connect(function(channelName)

	if string.find(channelName, 'To') then
		local whisperChannel = ChatService:GetChannel(channelName)

		if whisperChannel then
			whisperChannel:RegisterFilterMessageFunction("filterWhispers", PrivateChatFuncs.FilterWhispers)
		end
	end
end)

return PrivateChatFuncs
