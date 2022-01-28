---
-- Scripts.lua - Scripts editor
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Scripts = ReplicatedStorage.Models.Scripts

local LabeledFrame = require(ReplicatedStorage.Common.UI.LabeledFrame)
local TextSelector = require(ReplicatedStorage.Common.UI.TextSelector)

local SelectorFrame = require(script.Parent.SelectorFrame)

local ScriptsFrame = setmetatable({}, { __index = SelectorFrame })
ScriptsFrame.__index = ScriptsFrame

function ScriptsFrame.new(EditorModule)
	local self = setmetatable(SelectorFrame.new(EditorModule, "Scripts"), ScriptsFrame)

	self.Selector = nil

	return self
end

function ScriptsFrame:load()
	local internalFrame = LabeledFrame.new("Scripts", self.Frame)

	local items = {}

	for _, scr in pairs(Scripts:GetChildren()) do
		items[#items + 1] = scr.Name
	end

	local selector = TextSelector.new(internalFrame, items, true, true)

	selector.ItemSelected.Event:Connect(function(item)
		local appearance = self.EM.currentAppearanceInfo
		if not appearance then
			return
		end

		local scripts = appearance.Appearance.Scripts

		if not scripts then
			scripts = {}
			appearance.Appearance.Scripts = scripts
		end

		local idx = table.find(scripts, item)
		if not idx then
			scripts[#scripts + 1] = item
			self.EM:save()
		end
	end)

	selector.ItemDeselected.Event:Connect(function(item)
		local appearance = self.EM.currentAppearanceInfo
		if not appearance then
			return
		end

		local scripts = appearance.Appearance.Scripts

		if scripts then
			local idx = table.find(scripts, item)

			if idx then
				table.remove(scripts, idx)

				if #scripts == 0 then
					appearance.Appearance.Scripts = nil
				end

				self.EM:save()
			end
		end
	end)

	selector:loadItems()

	self.Selector = selector
end

function ScriptsFrame:update(appearance)
	self.Selector:setSelection(appearance.Appearance.Scripts or {})
end

return ScriptsFrame
