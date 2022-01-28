---
-- SelectorFrame.lua - Base class for editor selector frames
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Button = require(ReplicatedStorage.Common.UI.Button)
local TitledScroll = require(ReplicatedStorage.Common.UI.TitledScroll)

local SelectorFrame = {}
SelectorFrame.__index = SelectorFrame

function SelectorFrame.new(EditorModule, name, description)
	local self = setmetatable({}, SelectorFrame)

	local buttonInfo = Button.new(nil, name)

	local scroll = TitledScroll.new(nil, name, description)
	scroll.Root.Visible = false

	buttonInfo.Button.MouseButton1Click:Connect(function()
		local selected = EditorModule:switchFrame(name)

		if selected then
			self:onSelected()
		end
	end)

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scroll.Scroll

	self.Name = name
	self.Button = buttonInfo
	self.Scroll = scroll
	self.Frame = scroll.Scroll
	self.EM = EditorModule

	self._loaded = false

	return self
end

function SelectorFrame:updateSelected(selected)
	self.Button:SetActive(selected, true)
	self.Scroll.Root.Visible = selected
end

function SelectorFrame:onSelected()
	self.Frame.ClipsDescendants = false

	if not self._loaded then
		self:load()
		self._loaded = true

		self:doUpdate()
	end

	wait()
	self.Frame.ClipsDescendants = true
end

function SelectorFrame:load() end

function SelectorFrame:doUpdate()
	local appearance = self.EM.currentAppearanceInfo
	if appearance then
		self:update(appearance)
	end
end

function SelectorFrame:update(appearance) end

function SelectorFrame:handleSave() end

return SelectorFrame
