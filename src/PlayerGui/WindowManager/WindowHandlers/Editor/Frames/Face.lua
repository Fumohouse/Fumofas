---
-- Face.lua - Face editor
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UI = ReplicatedStorage.Common.UI
local ColorPicker = require(UI.ColorPicker)
local PaginatedSelector = require(UI.PaginatedSelector)
local Utils = require(UI.Utils)
local LabeledFrame = require(UI.LabeledFrame)

local Create = ReplicatedStorage.Common.Create
local CreateModule = require(Create.CreateModule)
local FaceStyles = require(Create.Data.FaceStyles)

local SelectorFrame = require(script.Parent.SelectorFrame)

local FaceFrame = setmetatable({}, { __index = SelectorFrame })
FaceFrame.__index = FaceFrame

function FaceFrame.new(EditorModule)
	local self = setmetatable(SelectorFrame.new(EditorModule, "Face", "Customize your fumo's face"), FaceFrame)

	self._colorPicker = nil
	self.Selectors = {}

	return self
end

function FaceFrame:load()
	for dType, data in pairs(FaceStyles) do
		local internalFrame = LabeledFrame.new(dType, self.Frame)

		local selector = PaginatedSelector.new(internalFrame, CreateModule.keysToList(data), true, false)

		selector.GetItemContent = function(frame, item)
			local itemInfo = data[item]

			frame.BackgroundColor3 = Color3.fromRGB(255, 240, 208)

			if dType == "Eyes" then
				local eyes = Utils.createIcon(itemInfo.Eyes)
				eyes.Size = UDim2.fromScale(1, 1)
				eyes.Parent = frame

				local shine = Utils.createIcon(itemInfo.Shine)
				shine.Size = UDim2.fromScale(1, 1)
				shine.Parent = frame
			else
				local image = Utils.createIcon(itemInfo.Id)
				image.Size = UDim2.fromScale(1, 1)
				image.Parent = frame
			end
		end

		selector.ItemSelected.Event:Connect(function(item)
			local appearance = self.EM.currentAppearanceInfo
			if not appearance then
				return
			end

			appearance.Appearance[dType] = item
			self.EM:save()
		end)

		selector.ItemDeselected.Event:Connect(function()
			if #selector.SelectedItems ~= 0 then
				return
			end

			local appearance = self.EM.currentAppearanceInfo
			if not appearance then
				return
			end

			appearance.Appearance[dType] = ""
			self.EM:save()
		end)

		selector:loadItems()

		self.Selectors[dType] = selector
	end

	local pickerFrame = LabeledFrame.new("Eye Color", self.Frame)

	self._colorPicker = ColorPicker.new(pickerFrame)
	self._colorPicker.ColorChanged.Event:Connect(function(color)
		local appearanceInfo = self.EM.currentAppearanceInfo
		if not appearanceInfo then
			return
		end

		appearanceInfo.Appearance.EyesColor = color

		self.EM:save()
	end)
end

function FaceFrame:update(appearance)
	if self._colorPicker then
		self._colorPicker:setColor(appearance.Appearance.EyesColor)
	end

	for key, sel in pairs(self.Selectors) do
		sel:setSelection({ appearance.Appearance[key] })
	end
end

return FaceFrame
