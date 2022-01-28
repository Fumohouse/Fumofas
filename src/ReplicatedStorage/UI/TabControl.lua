---
-- TabControl.lua - Text selector for horizontal tabs
--

local SelectorBase = require(script.Parent.Base.SelectorBase)
local Button = require(script.Parent.Button)
local Utils = require(script.Parent.Utils)

local TabControl = setmetatable({}, { __index = SelectorBase })
TabControl.__index = TabControl

function TabControl.new(parent, items)
	local self = setmetatable(SelectorBase.new(parent, items, false, false), TabControl)

	self.Root.Size = UDim2.new(1, 0, 0, Button.kHeight)

	local scroll = Utils.createHorizontalScroll()
	scroll.ScrollBarThickness = 0
	scroll.CanvasSize = UDim2.fromScale(0, 1)
	scroll.Parent = self.Root

	local list = Utils.listLayout(scroll)
	list.FillDirection = Enum.FillDirection.Horizontal

	self.Scroll = scroll
	self.Buttons = {}

	return self
end

-- override SelectorBase
function TabControl:updateItem(item, isActive)
	self.Buttons[item]:SetActive(isActive, true)
end

function TabControl:loadItems()
	for _, item in pairs(self.Items) do
		local label = item

		if self.GetItemLabel then
			label = self.GetItemLabel(item)
		end

		local button = Button.new(self.Scroll, label)
		button.Button.AutomaticSize = Enum.AutomaticSize.X
        button.Button.Size = UDim2.new(0, 0, 0, Button.kHeight)

        local padding = Instance.new("UIPadding")
        local kPadding = UDim.new(0, 5)
        padding.PaddingLeft = kPadding
        padding.PaddingRight = kPadding
        padding.Parent = button.Button

		button.Button.MouseButton1Click:Connect(function()
			if button.IsActive then
				self:deselectItem(item)
			else
				self:selectItem(item)
			end
		end)

		self.Buttons[item] = button
	end
end

return TabControl
