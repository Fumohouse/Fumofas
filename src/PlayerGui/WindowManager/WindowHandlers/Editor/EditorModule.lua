---
-- EditorModule.lua - Manager for editor UI
--

local editor = require(script.Parent.Parent.Parent.WMModule):getWindow("Editor")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Viewport = require(ReplicatedStorage.Common.UI.Viewport)

local Create = ReplicatedStorage.Common.Create
local CreateModule = require(Create.CreateModule)
local CharacterAppearance = require(Create.CharacterAppearance)

local targetsScroll = editor.TargetsFrame.Targets
local partsFrame = editor.PartsFrame

local EditorModule = {
	Editor = editor,
	_viewport = nil,
	_camera = nil,
	_char = nil,
	charInfo = nil,
	currentAppearanceInfo = nil,
	currentId = nil,
	spawnOverrideId = nil,

	_selectorFrames = {},
	_selectedFrame = nil,

	_characterButtons = {},
}

EditorModule.__index = EditorModule

function EditorModule:init()
	-- Viewport

	local viewport = Viewport.new(editor.Sidebar)
	viewport.Viewport.Size = UDim2.fromScale(0.8, 0.5)
	viewport.Viewport.Position = UDim2.fromScale(0.5, 0.04)
	viewport.Viewport.AnchorPoint = Vector2.new(0.5, 0)

	self._viewport = viewport

	-- Character and Camera

	self.Saving = false

	local char = ReplicatedStorage.Models.BaseNormal:Clone()
	self._char = char
	self.charInfo = CharacterAppearance.new(char)
	self.charInfo.Updated.Event:Connect(function()
		if self.Saving then -- internal saves do not need the additional update.
			return
		end

		self:update()
	end)

	viewport.Camera.CameraSubject = char
	char.Parent = viewport.Viewport
	char.HumanoidRootPart.CFrame = CFrame.new(0, 0, 0)
end

function EditorModule:updateAppearance(appearance)
	if self.currentAppearanceInfo then
		self.currentAppearanceInfo:deregister(self.charInfo)
	end

	self.currentAppearanceInfo = appearance
	appearance:register(self.charInfo)
	appearance:fireUpdate()

	self.currentId = appearance.Id

	self:_updateCharacterRender()
end

function EditorModule:saveAppearance()
	if not self.currentAppearanceInfo then
		return
	end

	local success, id = Create.Events.RegisterAppearance:InvokeServer(
		self.currentAppearanceInfo.Appearance,
		self.currentId
	)

	if success then
		self.currentId = id
		CreateModule.Appearances:registerLocalAppearance(self.currentAppearanceInfo, id)

		self.spawnOverrideId = nil

		return true
	end
end

function EditorModule:registerSelectorFrame(selectorFrame)
	self._selectorFrames[selectorFrame.Name] = selectorFrame

	selectorFrame.Button.Button.Parent = targetsScroll
	selectorFrame.Scroll.Root.Parent = partsFrame
end

function EditorModule:switchFrame(name)
	local frame = self._selectorFrames[name]

	if self._selectedFrame == frame then
		return false
	end

	if self._selectedFrame then
		self._selectedFrame:updateSelected(false)
	end

	frame:updateSelected(true)

	self._selectedFrame = frame

	return true
end

function EditorModule:update()
	for _, v in pairs(self._selectorFrames) do
		if v._loaded then
			v:doUpdate()
		end
	end
end

function EditorModule:save()
	self.Saving = true

	self.spawnOverrideId = nil

	self.currentAppearanceInfo:fireUpdate()
	self:_updateCharacterRender()

	for _, selectorFrame in pairs(self._selectorFrames) do
		selectorFrame:handleSave()
	end

	self.Saving = false
end

function EditorModule:_updateCharacterRender()
	if not self._char then
		return
	end

	self._viewport:updateSubject()

	local scale = self._char:GetAttribute("Scale") or 1
	local torsoCf = self._char.Torso.Torso.CFrame

	local centerCf = self._char:GetBoundingBox()
	self._viewport.Offset = Vector3.new(0, 0, -4) * scale
	self._viewport.FocalPoint = Vector3.new(torsoCf.Position.X, centerCf.Position.Y, torsoCf.Position.Z) -- Ensure center in viewport
	self._viewport:updateCamera()
end

return EditorModule
