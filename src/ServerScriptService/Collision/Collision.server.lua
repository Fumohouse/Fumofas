---
-- Collision.server.lua - Collision remote handling
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CollisionData = require(script.Parent.CollisionData)

Players.PlayerAdded:Connect(function(player)
	CollisionData.collisionData[player] = true

	if player.Character then
		CollisionData.updateCollision(player, player.Character.PrimaryPart)
	end

	player.CharacterAdded:Connect(function(char)
		CollisionData.updateCollision(player, char.PrimaryPart)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	CollisionData.collisionData[player] = nil
end)

ReplicatedStorage.UIRemotes.SetColl.OnServerEvent:Connect(function(player, enabled)
	if typeof(enabled) ~= "boolean" then
		return
	end

	if CollisionData.collisionData[player] ~= enabled then
		CollisionData.collisionData[player] = enabled

		if player.Character then
			CollisionData.updateCollision(player, player.Character.PrimaryPart)
		end
	end
end)
