---
-- SelectorBase.lua - Base class for single/multiple/none selectors
--

local Utils = require(script.Parent.Parent.Utils)

local SelectorBase = {}
SelectorBase.__index = SelectorBase

function SelectorBase.new(parent, items, allowNone, allowMultiple)
	local self = setmetatable({}, SelectorBase)

	self.Items = items
	self.AllowNone = allowNone
	self.AllowMultiple = allowMultiple

	local root = Instance.new("Frame")
	Utils.disableBg(root)
	root.Active = true
	root.Parent = parent
	self.Root = root

	local selectedEvt = Instance.new("BindableEvent")
	selectedEvt.Parent = root
	self.ItemSelected = selectedEvt

	local deselectedEvt = Instance.new("BindableEvent")
	deselectedEvt.Parent = root
	self.ItemDeselected = deselectedEvt

	self.SelectedItems = {}

	return self
end

function SelectorBase:setSelection(selected)
	for _, item in pairs(self.Items) do
		self:updateItem(item, false)
	end

	self.SelectedItems = {}

	for _, item in pairs(selected) do
		if table.find(self.Items, item) then
			self:updateItem(item, true)
			self.SelectedItems[#self.SelectedItems + 1] = item
		end
	end
end

function SelectorBase:selectItem(item)
	if not self.AllowMultiple and #self.SelectedItems > 0 then -- Deselect one and select the other (radio)
		local itemToRemove = self.SelectedItems[1]
		self.ItemDeselected:Fire(itemToRemove)
		self:updateItem(itemToRemove, false)

		self.SelectedItems[1] = item
		self.ItemSelected:Fire(item)
	else -- Select another
		self.SelectedItems[#self.SelectedItems + 1] = item
		self.ItemSelected:Fire(item)
	end

	self:updateItem(item, true)
end

function SelectorBase:deselectItem(item)
	if #self.SelectedItems == 1 and not self.AllowNone then
		return
	end

	local idx = table.find(self.SelectedItems, item)
	if idx then
		table.remove(self.SelectedItems, idx)
	end

	self.ItemDeselected:Fire(item)

	self:updateItem(item, false)
end

function SelectorBase:updateItem(item, isActive) end

return SelectorBase
