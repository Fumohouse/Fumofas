---
-- SeatHandler.server.lua - Serverside handler for seat scaling
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionSubscriber = require(ReplicatedStorage.Common.CollectionSubscriber)

local subscriber = CollectionSubscriber.new("Seat")

subscriber.HandleItem = function(item)
	local offsetToTop = item.Size.Y / 2

	local lSignal
	local currentOccupant

	item:GetPropertyChangedSignal("Occupant"):Connect(function()
		if lSignal then
			lSignal:Disconnect()
		end

		if not item.Occupant and currentOccupant then
            wait(0.5)
			item.CanCollide = true
			return
		end

		item.CanCollide = false

		local char = item.Occupant.Parent
		local weld = item.SeatWeld

		local function updateScale()
			local scale = char:GetAttribute("Scale") or 1
			weld.C1 = CFrame.new(0, -char.Torso.Torso.Size.Y / 2 + 0.1 * scale, 0)
		end

		weld.C0 = CFrame.new(0, -offsetToTop, 0)
		updateScale()

		lSignal = char.AttributeChanged:Connect(function(attr)
			if attr == "Scale" then
				updateScale()
			end
		end)

		currentOccupant = char
	end)
end

subscriber:init()
