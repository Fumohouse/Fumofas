---
-- CoasterHandler.server.lua - Serverside handler for coasters
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CollectionSubscriber = require(ReplicatedStorage.Common.CollectionSubscriber)
local MugSurface = require(script.Parent.MugSurface)

local subscriber = CollectionSubscriber.new("Coaster")

subscriber.HandleItem = function(item)
	local surface = MugSurface.new(item.Attachment)

	item.ClickDetector.MouseClick:Connect(function(player)
		if surface.CurrentMug then
			if player == surface._currentOwner then
				surface:detach()
			end

			return
		end

		local char = player.Character
		if not char or not char.Parent then
			return
		end

		local mug = char:FindFirstChild("Mug")

		if mug and mug:IsA("Tool") then
			surface:attach(player, mug)
		end
	end)

	coroutine.wrap(function()
		while true do
			if surface.CurrentMug then
				local coasterPos = item.Position
				local playerPos = surface._currentOwner.Character.PrimaryPart.Position
				local dP = playerPos - coasterPos

				local dist = math.sqrt(dP.X ^ 2 + dP.Y ^ 2 + dP.Z ^ 2)

				if dist > 10 then
					surface:detach()
				end
			end

			wait(2)
		end
	end)()
end

subscriber:init()
