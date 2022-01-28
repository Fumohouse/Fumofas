---
-- ItemPickup.server.lua - Collection handler for item pickup ClickDetectors
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CollectionSubscriber = require(ReplicatedStorage.Common.CollectionSubscriber)

local subscriber = CollectionSubscriber.new("ItemPickup")

subscriber.HandleItem = function(detector)
	local itemName = detector:GetAttribute("Item")
	local item = ServerStorage.Items:FindFirstChild(itemName)
	if not item then
		return
	end

	detector.MouseClick:Connect(function(player)
		item:Clone().Parent = player.Backpack
	end)
end

subscriber:init()
