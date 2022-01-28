---
-- Utils.lua - Various UI utilities
--

local Utils = {}

function Utils.lerpNumber(a, b, alpha)
	return a + (b - a) * alpha
end

function Utils.createIndicator(parent)
	local indicator = Instance.new("Frame")
	indicator.BorderSizePixel = 0
	indicator.Parent = parent

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0)
	uiCorner.Parent = indicator

	return indicator
end

function Utils.aspect(parent, ratio)
	local uiAspect = Instance.new("UIAspectRatioConstraint")
	uiAspect.AspectRatio = ratio
	uiAspect.AspectType = Enum.AspectType.ScaleWithParentSize
	uiAspect.Parent = parent
end

function Utils.corner(parent, radius)
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = radius
	uiCorner.Parent = parent
end

function Utils.disableBg(guiObj)
	guiObj.BackgroundTransparency = 1
	guiObj.BorderSizePixel = 0
end

function Utils.initText(textObj, font)
	textObj.Font = font or Enum.Font.Gotham
	textObj.TextColor3 = Color3.fromRGB(255, 255, 255)
	textObj.TextXAlignment = Enum.TextXAlignment.Left
	textObj.TextYAlignment = Enum.TextYAlignment.Bottom
end

function Utils.listLayout(parent)
	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = parent

	return list
end

local kScrollThickness = 8

function Utils.createScroll()
	local scroll = Instance.new("ScrollingFrame")
	Utils.disableBg(scroll)
	scroll.Size = UDim2.fromScale(1, 1)
	scroll.ScrollBarThickness = kScrollThickness
	scroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	scroll.HorizontalScrollBarInset = Enum.ScrollBarInset.Always

	return scroll
end

function Utils.createHorizontalScroll()
	local scroll = Utils.createScroll()
	scroll.ScrollingDirection = Enum.ScrollingDirection.X
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.X
	scroll.CanvasSize = UDim2.new(0, 0, 1, -kScrollThickness)

	return scroll
end

function Utils.createVerticalScroll()
	local scroll = Utils.createScroll()
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new(1, -kScrollThickness, 0, 0)

	return scroll
end

function Utils.initImage(imageObj, image)
	imageObj.Image = image
	imageObj.ScaleType = Enum.ScaleType.Fit
end

function Utils.createIcon(icon)
	local label = Instance.new("ImageLabel")
	Utils.disableBg(label)
	Utils.initImage(label, icon)

	return label
end

function Utils.createIconButton(icon)
	local button = Instance.new("ImageButton")
	Utils.initImage(button, icon)

	return button
end

function Utils.createText(font)
	local text = Instance.new("TextLabel")
	Utils.disableBg(text)
	Utils.initText(text, font)

	return text
end

function Utils.createTextButton(font)
	local text = Instance.new("TextButton")
	Utils.initText(text, font)

	return text
end

function Utils.createPaddedButton(icon, paddingR, paddingO)
	local button = Utils.createTextButton()
	button.Text = ""

	local img = Utils.createIcon(icon)
	img.Size = UDim2.fromScale(1, 1)
	img.Parent = button

	local padding = Instance.new("UIPadding")
	local dim = UDim.new(paddingR or 0, paddingO or 0)
	padding.PaddingLeft = dim
	padding.PaddingRight = dim
	padding.PaddingTop = dim
	padding.PaddingBottom = dim
	padding.Parent = button

	return button, img
end

return Utils
