---
-- CharacterStore.lua - Serverside storage of character data
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CharacterAppearance = require(ReplicatedStorage.Common.Create.CharacterAppearance)

local CharacterStore = {
	Players = {},
}

CharacterStore.__index = {}

function CharacterStore:getFromPlayer(player, character, appearance)
	local char = character or player.Character
	local charApp = self.Players[player.UserId]

	if not char then
		warn("CS: Tried to get CharacterAppearance of player with no character")
		return
	end

	if charApp and charApp.Character == char then
		print("CS: Appearance already exists")
		if appearance then
			charApp.Appearance = appearance
			charApp:loadAppearance()
		end

		return charApp
	end

	print("CS: Creating new appearance")
	charApp = CharacterAppearance.new(char, appearance)
	self.Players[player.UserId] = charApp

	local listener
	listener = player.CharacterAdded:Connect(function(newChar)
		if newChar == char then
			return
		end

		print("CS: Player", player.Name, "switched characters. Listener disconnecting. <<<<<")
		charApp:deregister()

		listener:Disconnect()
	end)

	return charApp
end

return CharacterStore
