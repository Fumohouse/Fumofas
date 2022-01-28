---
-- CafeDoor.server.lua - Cafe door handler
--

local door = workspace["LeFumo Cafe"]["Structure"]["Front Wall"].GlassDoor

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local motorEvt = ReplicatedStorage.MotorUpdate

local hinge = door.Parent.DoorWallPart.Motor
local debounce = false
local isOpen = false

local kTransformOpen = CFrame.Angles(0, -math.pi / 2, 0)
local kTransformClosed = CFrame.new()

local function toggleOpen()
	if debounce then
		return
	end

	isOpen = not isOpen

	if isOpen then
		motorEvt:FireAllClients(hinge, kTransformOpen)
	else
		motorEvt:FireAllClients(hinge, kTransformClosed)
	end

	coroutine.wrap(function()
		door.Glass.CanCollide = false
		wait(0.5)
		door.Glass.CanCollide = true
	end)()

	debounce = true
	wait(3)
	debounce = false
end

door.Glass.ClickDetector.MouseClick:Connect(toggleOpen)
door.FrameHandle.ClickDetector.MouseClick:Connect(toggleOpen)

Players.PlayerAdded:Connect(function(player)
	if isOpen then
		motorEvt:FireClient(player, hinge, kTransformOpen)
	else
		motorEvt:FireClient(player, hinge, kTransformClosed)
	end
end)
