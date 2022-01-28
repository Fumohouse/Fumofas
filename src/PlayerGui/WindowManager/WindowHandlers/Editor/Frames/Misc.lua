---
-- Misc.lua - Miscellaneous options
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Dropdown = require(ReplicatedStorage.Common.UI.Dropdown)
local LabeledFrame = require(ReplicatedStorage.Common.UI.LabeledFrame)

local Create = ReplicatedStorage.Common.Create
local CreateModule = require(Create.CreateModule)
local ModelSizes = require(Create.Data.ModelSizes)
local VoicePitches = require(Create.Data.VoicePitches)
local Dialogues = require(Create.Data.Dialogues)
local CharacterAppearances = require(Create.Data.CharacterAppearances)

local SelectorFrame = require(script.Parent.SelectorFrame)

local kDefaultSize = CharacterAppearances.Reimu.Size

local Misc = setmetatable({}, { __index = SelectorFrame })
Misc.__index = Misc

function Misc.new(EditorModule)
	local self = setmetatable(SelectorFrame.new(EditorModule, "Misc", "Various settings for your character"), Misc)

	self.Dropdowns = {}

	return self
end

function Misc:_updateKey(key, value)
	local appearance = self.EM.currentAppearanceInfo
	if not appearance then
		return
	end

	appearance:setKey(key, value)

	self.EM:save()
end

function Misc:_addDropdown(label, key, list, allowNil)
	local internalFrame = LabeledFrame.new(label, self.Frame, true)
	local dropdown = Dropdown.new(internalFrame, list, allowNil)
	dropdown.SelectionChanged.Event:Connect(function(value)
		self:_updateKey(key, value)
	end)

	self.Dropdowns[key] = dropdown
end

function Misc:load()
	self:_addDropdown("Fumo Size", "Size", CreateModule.keysToList(ModelSizes))
	self:_addDropdown("Voice Pitch", "VoicePitch", VoicePitches)
	self:_addDropdown("Dialogue", "Dialogue", Dialogues, true)
end

function Misc:update(appearance)
	local size = appearance.Appearance.Size or kDefaultSize
	self.Dropdowns.Size:setItem(size)

	self.Dropdowns.VoicePitch:setItem(appearance.Appearance.VoicePitch)
	self.Dropdowns.Dialogue:setItem(appearance.Appearance.Dialogue)
end

return Misc
