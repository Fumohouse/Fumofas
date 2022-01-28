---
-- PaginatedSelector.lua - Generic selector for one, none, or multiple (ideally graphic) things
--

local TweenService = game:GetService("TweenService")

local SelectorBase = require(script.Parent.Base.SelectorBase)
local Utils = require(script.Parent.Utils)

local PaginatedSelector = setmetatable({}, { __index = SelectorBase })
PaginatedSelector.__index = PaginatedSelector

local kNavSize = 20

local kColumnCount = 4
local kRowCount = 2

local navTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function PaginatedSelector._createNavButton(icon)
	local button = Utils.createIconButton(icon)
	button.Size = UDim2.new(0, kNavSize, 1, 0)
	button.BackgroundColor3 = Color3.fromRGB(52, 72, 99)
	button.BorderSizePixel = 0

	return button
end

function PaginatedSelector._tweenNav(nav, anchorPos)
	local tween = TweenService:Create(nav, navTweenInfo, { AnchorPoint = anchorPos })
	tween:Play()
end

function PaginatedSelector.new(parent, items, allowNone, allowMultiple)
	local self = setmetatable(SelectorBase.new(parent, items, allowNone, allowMultiple), PaginatedSelector)

	self.Root.ClipsDescendants = true
	self.Root.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_updateSize()
	end)

	self:_updateSize()

	local pageLayout = Instance.new("Frame")
	Utils.disableBg(pageLayout)
	pageLayout.Size = UDim2.fromScale(1, 1)
	pageLayout.Parent = self.Root
	self.PageLayout = pageLayout

	local uiPage = Instance.new("UIPageLayout")
	uiPage.FillDirection = Enum.FillDirection.Horizontal
	uiPage.Animated = false
	uiPage.Circular = true
	uiPage.ScrollWheelInputEnabled = false -- Scroll input sucks balls. Don't use it
	uiPage.TouchInputEnabled = false -- Touch input sucks balls. Use own implementation
	uiPage.Parent = pageLayout

    -- Navigation
	local navLeft = PaginatedSelector._createNavButton("rbxassetid://6034323696")
	navLeft.AnchorPoint = Vector2.new(1, 0)
	navLeft.Parent = self.Root

	navLeft.MouseButton1Click:Connect(function()
		uiPage:Previous()
	end)

	local navRight = PaginatedSelector._createNavButton("rbxassetid://6034315956")
	navRight.Position = UDim2.fromScale(1, 0)
	navRight.Parent = self.Root

	navRight.MouseButton1Click:Connect(function()
		uiPage:Next()
	end)

    -- Page input handling
	local leftShown = false
	local rightShown = false

	self.Root.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local offset = (input.Position.X - self.Root.AbsolutePosition.X) / self.Root.AbsoluteSize.X

			if offset < 0.1 then
				if not leftShown then
					PaginatedSelector._tweenNav(navLeft, Vector2.new(0, 0))
					leftShown = true
				end
			elseif leftShown then
				PaginatedSelector._tweenNav(navLeft, Vector2.new(1, 0))
				leftShown = false
			end

			if offset > 0.9 then
				if not rightShown then
					PaginatedSelector._tweenNav(navRight, Vector2.new(1, 0))
					rightShown = true
				end
			elseif rightShown then
				PaginatedSelector._tweenNav(navRight, Vector2.new(0, 0))
				rightShown = false
			end
		end
	end)

    self.Root.TouchSwipe:Connect(function(direction)
		if direction == Enum.SwipeDirection.Left then
			uiPage:Next()
		elseif direction == Enum.SwipeDirection.Right then
			uiPage:Previous()
		end
	end)

	uiPage:JumpToIndex(0)

	self.ItemFrames = {}

	return self
end

function PaginatedSelector:_updateSize()
	local parent = self.Root.Parent
	local parentSize = parent.AbsoluteSize
	self.Root.Size = UDim2.fromOffset(parentSize.X, parentSize.X * kRowCount / kColumnCount)
end

-- override SelectorBase
function PaginatedSelector:updateItem(item, isActive)
	self.ItemFrames[item].SetActive(isActive)
end

function PaginatedSelector:_createButton(item)
	-- Outer frame (button)
	local itemFrame = Utils.createTextButton()
	itemFrame.Active = false
	itemFrame.Size = UDim2.fromScale(1, 1)
	itemFrame.Text = ""
	itemFrame.BorderSizePixel = 1
	itemFrame.BackgroundColor3 = Color3.fromRGB(42, 49, 88)

	if self.GetItemContent then
		self.GetItemContent(itemFrame, item)
	end

	-- Indicator
	local indicator = Utils.createIndicator(itemFrame)
	indicator.Size = UDim2.fromScale(0.125, 0.125)
	indicator.Position = UDim2.fromScale(0.9, 0.1)
	indicator.AnchorPoint = Vector2.new(1, 0)
	indicator.BackgroundColor3 = Color3.fromRGB(0, 193, 64)
	indicator.Visible = false

	local isActive = false

	local function setActive(active)
		if active == isActive then
			return
		end

		isActive = active
		indicator.Visible = active
	end

	-- Click Handling
	itemFrame.MouseButton1Click:Connect(function()
		if isActive then
			self:deselectItem(item)
		else
			self:selectItem(item)
		end
	end)

	self.ItemFrames[item] = {
		Indicator = indicator,
		SetActive = setActive,
	}

	return itemFrame
end

function PaginatedSelector:loadItems()
	local page

	for i, item in ipairs(self.Items) do
		if (i - 1) % (kRowCount * kColumnCount) == 0 then
			page = self:_addPage()
		end

		local itemFrame = self:_createButton(item)
		itemFrame.Parent = page
	end
end

function PaginatedSelector:_addPage()
	local page = Instance.new("Frame")
	Utils.disableBg(page)
	page.Size = UDim2.fromScale(1, 1)
	page.Parent = self.PageLayout

	local grid = Instance.new("UIGridLayout")
	grid.CellPadding = UDim2.fromScale(0, 0)
	grid.CellSize = UDim2.fromScale(1 / kColumnCount, 1 / kRowCount)
	grid.Parent = page

	return page
end

return PaginatedSelector
