---
-- Options.lua - Model options editor
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Create = ReplicatedStorage.Common.Create

local CreateModule = require(Create.CreateModule)
local ModelData = require(Create.Data.ModelData)

local ColorPicker = require(ReplicatedStorage.Common.UI.ColorPicker)
local LabeledFrame = require(ReplicatedStorage.Common.UI.LabeledFrame)
local TextSelector = require(ReplicatedStorage.Common.UI.TextSelector)

local SelectorFrame = require(script.Parent.SelectorFrame)

local OptionsFrame = setmetatable({}, { __index = SelectorFrame })
OptionsFrame.__index = OptionsFrame

function OptionsFrame.new(EditorModule)
	local self = setmetatable(SelectorFrame.new(EditorModule, "Options", "Settings for individual parts"), OptionsFrame)

	self._optionsFrames = {}

	return self
end

local function getOptionValue(opts, model, name)
	if opts then
		if opts[model] then
			return opts[model][name]
		end
	end
end

function OptionsFrame:_updateOptions()
	if self.EM.Saving then
		return
	end

	local appearance = self.EM.currentAppearanceInfo
	if not appearance then
		return
	end

	local appOptions = appearance.Appearance.Options

	local attachedParts = CreateModule.findAllModels(appearance.Appearance)

	for modelName, frame in pairs(self._optionsFrames) do
		frame:Destroy()
		self._optionsFrames[modelName] = nil
		if not table.find(attachedParts, modelName) and appOptions then
			appOptions[modelName] = nil
		end
	end

	for _, modelName in pairs(attachedParts) do
		local modelInfo = ModelData.findModelInfo(modelName)

		if modelInfo and (modelInfo.InheritedOptions or modelInfo.Options) then
			local internalFrame, frame = LabeledFrame.new("Options for " .. modelName, self.Frame)

			local function loadOptions(opts)
				if not opts then
					return
				end

				for name, data in pairs(opts) do
					if data.Type == "Color3" then
						local picker = ColorPicker.new(internalFrame)

						local initialValue = getOptionValue(appOptions, modelName, name) or data.Get(modelInfo.Model)
						picker:setColor(initialValue)

						picker.ColorChanged.Event:Connect(function(color)
							appearance:setOption(modelName, name, color)
							self.EM:save()
						end)
					elseif data.Type == "string" and data.GetAcceptedValues then
						local pickerInternalFrame = LabeledFrame.new(modelName .. " " .. name, internalFrame)
						local values = data.GetAcceptedValues()

						local initialValue = getOptionValue(appOptions, modelName, name)
						local selector = TextSelector.new(pickerInternalFrame, values, data.AllowNone)

						selector.GetItemLabel = function(item)
							if data.GetDisplayName then
								return data.GetDisplayName(item)
							end

							return item
						end

						selector.ItemSelected.Event:Connect(function(item)
							appearance:setOption(modelName, name, item)
							self.EM:save()
						end)

						selector.ItemDeselected.Event:Connect(function()
							appearance:setOption(modelName, name, nil)
							self.EM:save()
						end)

						selector:loadItems()
						selector:setSelection({ initialValue })
					end
				end
			end

			loadOptions(modelInfo.InheritedOptions)
			loadOptions(modelInfo.Options)

			self._optionsFrames[modelName] = frame
		end
	end
end

function OptionsFrame:load()
	self:_updateOptions()
end

function OptionsFrame:update()
	self:_updateOptions()
end

function OptionsFrame:handleSave()
	if self._loaded then
		self:_updateOptions()
	end
end

return OptionsFrame
