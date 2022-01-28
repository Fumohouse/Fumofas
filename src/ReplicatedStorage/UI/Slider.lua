---
-- Slider.lua - UI slider component
--

local Utils = require(script.Parent.Utils)

local UserInput = game:GetService("UserInputService")

local Slider = {}
Slider.__index = Slider

function Slider.new(parent, notifyOnRelease)
	local self = setmetatable({}, Slider)

	local slider = Instance.new("Frame")
	slider.Active = true
	slider.BorderSizePixel = 0
	slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	slider.Size = UDim2.fromScale(1, 1)
	slider.Parent = parent

	local indicator = Instance.new("Frame")
	indicator.AnchorPoint = Vector2.new(0.5, 0.5)
	indicator.Size = UDim2.fromScale(0.03, 1.5)
	indicator.BackgroundColor3 = Color3.fromRGB(87, 104, 201)
	indicator.Parent = slider

	Utils.corner(indicator, UDim.new(0.5, 0))

	self.Slider = slider
	self.Indicator = indicator
	self.Position = 0

	self._mouseDown = false

	slider.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self:_update(input)

			if self.HandleInput and not notifyOnRelease then
				self:HandleInput(input)
			end

			self._mouseDown = true
		end
	end)

	UserInput.InputChanged:Connect(function(input)
		if
			(input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
			and self._mouseDown
		then
			self:_update(input)

			if self.HandleInput and not notifyOnRelease then
				self:HandleInput(input)
			end
		end
	end)

	slider.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			self._mouseDown = false

			if notifyOnRelease then
				self:HandleInput(input)
			end
		end
	end)

	self:setPosition(0)

	return self
end

function Slider:setPosition(pos, force)
	if self._mouseDown and not force then
		return
	end

	self.Position = pos
	self.Indicator.Position = UDim2.fromScale(pos, 0.5)
end

function Slider:_update(input)
	local x = (input.Position.X - self.Slider.AbsolutePosition.X) / self.Slider.AbsoluteSize.X
	x = math.max(math.min(x, 1), 0)
	self:setPosition(x, true)
end

return Slider
