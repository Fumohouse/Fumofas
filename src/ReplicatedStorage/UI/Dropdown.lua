---
-- Dropdown.lua - Dropdown component
--

local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local popups = PlayerGui:WaitForChild("Popups")

local TweenService = game:GetService("TweenService")
local UserInput = game:GetService("UserInputService")

local Utils = require(script.Parent.Utils)

local Dropdown = {}
Dropdown.__index = Dropdown

local kHeight = 35
local kPaddingPixels = 10
local kButtonHeight = 20

local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function Dropdown.new(parent, items, allowNil)
	local self = setmetatable({}, Dropdown)

	local root = Instance.new("Frame")
	Utils.disableBg(root)
	root.Size = UDim2.fromScale(0.75, 0)
	root.AutomaticSize = Enum.AutomaticSize.Y
	root.Parent = parent

	local header = Utils.createTextButton(Enum.Font.GothamSemibold)
	header.BackgroundColor3 = Color3.fromRGB(52, 72, 99)
	header.BorderSizePixel = 0
	header.Size = UDim2.new(1, 0, 0, kHeight)
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.TextYAlignment = Enum.TextYAlignment.Center
	header.TextSize = kHeight * 0.5
	header.TextTruncate = Enum.TextTruncate.AtEnd
	header.Parent = root

	Utils.corner(header, UDim.new(0, 5))

	local padding = Instance.new("UIPadding")
	local kPadding = UDim.new(0, kPaddingPixels)
	padding.PaddingLeft = kPadding
	padding.PaddingRight = kPadding
	padding.Parent = header

	local icon = Utils.createIcon("rbxassetid://6031091004")
	icon.AnchorPoint = Vector2.new(1, 0.5)
	icon.Position = UDim2.fromScale(1, 0.5)
	icon.Size = UDim2.fromScale(0.7, 0.7)
	icon.SizeConstraint = Enum.SizeConstraint.RelativeYY
	icon.Parent = header

	local dropdown = Utils.createVerticalScroll()
	dropdown.Active = true
	dropdown.Position = UDim2.new(0, 0, 0, kHeight)
	dropdown.BackgroundTransparency = 0
	dropdown.Visible = false
	dropdown.BackgroundColor3 = Color3.fromRGB(39, 55, 75)
	dropdown.Parent = popups
	Utils.listLayout(dropdown)

	local evt = Instance.new("BindableEvent")
	evt.Parent = root

	self.Items = items
	self.SelectionChanged = evt
	self.Header = header
	self.Dropdown = dropdown
	self.Open = false
	self.AllowNil = allowNil
	self._loaded = false

	self:_updateMenuPosition()

	header:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_updateMenuPosition()
	end)

	local initialValue

	if not allowNil then
		initialValue = items[1]
	else
		self:_createButton(nil)
	end

	self.CurrentItem = initialValue

	self:_updateHeader()

	header.MouseButton1Click:Connect(function()
		self:setOpen(not self.Open)
	end)

	UserInput.InputBegan:Connect(function(input)
		if not self.Open then
			return
		end

		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			local objects = PlayerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
			local shouldClose = true

			for _, gui in pairs(objects) do
				if gui == root or gui == dropdown then
					shouldClose = false
					break
				end
			end

			if shouldClose then
				self:setOpen(false)
			end
		end
	end)

	return self
end

function Dropdown:_getClosedSize()
	return UDim2.fromOffset(self.Header.AbsoluteSize.X, 0)
end

function Dropdown:_getOpenSize()
	return self:_getClosedSize() + UDim2.fromOffset(0, kHeight * 3)
end

function Dropdown:_updateMenuPosition()
	if self.Open then
		self.Dropdown.Size = self:_getOpenSize()
	else
		self.Dropdown.Size = self:_getClosedSize()

		local targetPos = self.Header.AbsolutePosition + Vector2.new(0, self.Header.AbsoluteSize.Y)
		local offset = targetPos - popups.AbsolutePosition
		self.Dropdown.Position = UDim2.fromOffset(offset.X, offset.Y)
	end
end

function Dropdown:setItem(item)
	if not ((item == nil or item == "") and self.AllowNil) and not table.find(self.Items, item) then
		error("Dropdown: Cannot set item! Not present in list")
	end

	self.CurrentItem = item
	self:_updateHeader()
end

function Dropdown:setOpen(isOpen)
	if self.Open == isOpen then
		return
	end

	self.Open = isOpen

	local goal = {}

	if self.Open then
		if not self._loaded then
			self:_loadItems()
			self._loaded = true
		end

		goal.Size = self:_getOpenSize()
		self.Dropdown.Visible = true
	else
		goal.Size = self:_getClosedSize()
	end

	local tween = TweenService:Create(self.Dropdown, tweenInfo, goal)
	tween:Play()

	if not self.Open then
		coroutine.wrap(function()
			tween.Completed:Wait()
			self.Dropdown.Visible = false
		end)()
	end
end

function Dropdown:_loadItems()
	for _, val in ipairs(self.Items) do
		self:_createButton(val)
	end
end

function Dropdown:_getString(item)
	if item == nil or item == "" then
		return "None"
	elseif self.GetDisplayString then
		return self.GetDisplayString(item)
	elseif type(item) == "string" then
		return item
	end

	return "???"
end

function Dropdown:_updateHeader()
	self.Header.Text = self:_getString(self.CurrentItem)
end

function Dropdown:_createButton(item)
	local button = Utils.createTextButton()
	button.TextSize = kButtonHeight * 0.9
	button.Size = UDim2.new(1, 0, 0, kButtonHeight)
	button.BorderSizePixel = 0
	button.BackgroundColor3 = Color3.fromRGB(39, 55, 75)
	button.Text = self:_getString(item)
	button.TextTruncate = Enum.TextTruncate.AtEnd
	button.Parent = self.Dropdown

	button.MouseButton1Click:Connect(function()
		self:setOpen(false)

		if self.CurrentItem == item then
			return
		end

		self.SelectionChanged:Fire(item)
		self.CurrentItem = item
		self:_updateHeader()
	end)
end

return Dropdown
