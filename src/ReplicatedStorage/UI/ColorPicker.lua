---
-- ColorPicker.lua - Color picker component
--

local Slider = require(script.Parent.Slider)
local Utils = require(script.Parent.Utils)

local ColorPicker = {}
ColorPicker.__index = ColorPicker

local kHeight = 100

function ColorPicker.new(parent)
	local self = setmetatable({}, ColorPicker)

	local root = Instance.new("Frame")
	Utils.disableBg(root)
	root.Size = UDim2.new(1, 0, 0, kHeight)
	root.Parent = parent

	local padding = Instance.new("UIPadding")
	local kPadding = UDim.new(0.05, 0)
	padding.PaddingBottom = kPadding
	padding.PaddingTop = kPadding
	padding.PaddingLeft = kPadding
	padding.PaddingRight = kPadding

	padding.Parent = root

	local sliderFrame = Instance.new("Frame")
	Utils.disableBg(sliderFrame)
	sliderFrame.Size = UDim2.fromScale(0.5, 1)
	sliderFrame.Parent = root

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0.1, 0)
	layout.Parent = sliderFrame

	local colorIndicator = Instance.new("Frame")
	colorIndicator.BorderSizePixel = 0
	colorIndicator.AnchorPoint = Vector2.new(0, 0.5)
	colorIndicator.Position = UDim2.fromScale(0.6, 0.5)
	colorIndicator.Size = UDim2.fromScale(0, 0.5)
	colorIndicator.Parent = root

	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.DominantAxis = Enum.DominantAxis.Height
	aspect.AspectType = Enum.AspectType.ScaleWithParentSize
	aspect.Parent = colorIndicator

	self.Root = root
	self.SliderFrame = sliderFrame
	self.ColorIndicator = colorIndicator

	self.H = 0
	self.S = 1
	self.V = 1

	local event = Instance.new("BindableEvent")
	event.Parent = root
	self.ColorChanged = event

	local hSlider = self:_createSlider("H")
	self._h = hSlider

	local sSlider = self:_createSlider("S")
	self._s = sSlider

	local vSlider = self:_createSlider("V")
	self._v = vSlider

	self:_update()

	return self
end

function ColorPicker:_createGradient(component)
	local colors = {}
	for i = 0, 1, 0.25 do
		if component == "H" then
			colors[#colors + 1] = ColorSequenceKeypoint.new(i, Color3.fromHSV(i, self.S, self.V))
		elseif component == "S" then
			colors[#colors + 1] = ColorSequenceKeypoint.new(i, Color3.fromHSV(self.H, i, self.V))
		elseif component == "V" then
			colors[#colors + 1] = ColorSequenceKeypoint.new(i, Color3.fromHSV(self.H, self.S, i))
		end
	end

	return ColorSequence.new(colors)
end

function ColorPicker:_update()
	self._h.Grad.Color = self:_createGradient("H")
	self._s.Grad.Color = self:_createGradient("S")
	self._v.Grad.Color = self:_createGradient("V")

	self.ColorIndicator.BackgroundColor3 = self:getColor()
end

function ColorPicker:_createSlider(component)
	local sliderObj = Slider.new(self.SliderFrame)
	sliderObj.Slider.Size = UDim2.fromScale(1, 0.15)

	local grad = Instance.new("UIGradient")
	grad.Parent = sliderObj.Slider

	local s = self

	function sliderObj:HandleInput()
		s[component] = self.Position
		s.ColorChanged:Fire(s:getColor())
		s:_update()
	end

	return {
		Slider = sliderObj,
		Grad = grad,
	}
end

function ColorPicker:getColor()
	return Color3.fromHSV(self.H, self.S, self.V)
end

function ColorPicker:setColor(color)
	local h, s, v = Color3.toHSV(color)

	self.H = h
	self.S = s
	self.V = v

	self._h.Slider:setPosition(self.H)
	self._s.Slider:setPosition(self.S)
	self._v.Slider:setPosition(self.V)
	self:_update()
end

return ColorPicker
