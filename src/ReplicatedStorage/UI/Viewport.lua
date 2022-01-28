---
-- Viewport.lua - ViewportFrame with limited simulated physics and controls
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Create = ReplicatedStorage.Common.Create
local CreateModule = require(Create.CreateModule)

local Viewport = {}
Viewport.__index = Viewport

function Viewport.new(parent, disableInput)
	local self = setmetatable({}, Viewport)

	local viewport = Instance.new("ViewportFrame")
	viewport.Active = true
	viewport.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	viewport.BorderSizePixel = 0
	viewport.Parent = parent
	self.Viewport = viewport

	local camera = Instance.new("Camera")
	viewport.CurrentCamera = camera
	camera.Parent = viewport
	self.Camera = camera

	self.FocalPoint = Vector3.new(0, 0, 0)
	self.Rotation = Vector2.new(0, 0)
	self.Offset = Vector3.new(0, 0, 0)
	self.Zoom = 1 -- Smaller number = more zoom

	if disableInput then
		return self
	end

	-- Input Handling

	local function handleScroll(input)
		local scroll = input.Position.Z

		self.Zoom = self.Zoom - scroll * 0.1
		self:updateCamera()
	end

	local mouseDown = false

	viewport.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			mouseDown = true
		elseif input.UserInputType == Enum.UserInputType.MouseWheel then
			handleScroll(input)
		end
	end)

	local lastPos

	viewport.InputChanged:Connect(function(input)
		if
			(input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
			and mouseDown
		then
			if lastPos then
				local kSensitivity = 1 -- Pixels per degree
				local delta = input.Position - lastPos
				local dX = delta.X / kSensitivity * math.pi / 180
				local dY = delta.Y / kSensitivity * math.pi / 180

				local kMaxXRot = math.pi / 2 - 1e-1 -- Prevent weirdness that is too much of a pain to deal with.

				local targetX = math.min(math.max(self.Rotation.X + dY, -kMaxXRot), kMaxXRot)
				local targetY = (self.Rotation.Y - dX) % (2 * math.pi)

				self.Rotation = Vector2.new(targetX, targetY)
				self:updateCamera()
			end

			lastPos = input.Position
		elseif input.UserInputType == Enum.UserInputType.MouseWheel then
			handleScroll(input)
		end
	end)

	viewport.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			mouseDown = false
			lastPos = nil
		end
	end)

	return self
end

function Viewport:updateSubject()
	CreateModule.fixJoints(self.Viewport)
end

function Viewport:setFocalCFrame(cf)
	self.FocalPoint = (cf * (cf - cf.Position):Inverse()).Position
end

function Viewport:updateCamera()
	local rotation = CFrame.fromEulerAnglesYXZ(self.Rotation.X, self.Rotation.Y, 0)
	self.Camera.CFrame = CFrame.lookAt(self.FocalPoint + rotation * self.Offset * self.Zoom, self.FocalPoint)
end

return Viewport
