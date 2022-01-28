---
-- EditorHandler.client.lua - Editor UI initializer
--

-- Services & Imports

local WMModule = require(script.Parent.Parent.Parent.WMModule)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Create = ReplicatedStorage.Common.Create
local CreateModule = require(Create.CreateModule)
local CharacterAppearances = require(Create.Data.CharacterAppearances)

local Utils = require(ReplicatedStorage.Common.UI.Utils)
local LabeledFrame = require(ReplicatedStorage.Common.UI.LabeledFrame)

local EditorModule = require(script.Parent.EditorModule)
EditorModule:init()

-- UI

local Frames = script.Parent.Frames

EditorModule:registerSelectorFrame(require(Frames.Misc).new(EditorModule))
EditorModule:registerSelectorFrame(require(Frames.Face).new(EditorModule))

for _, targetFolder in pairs(ReplicatedStorage.Models.Parts:GetChildren()) do
	EditorModule:registerSelectorFrame(require(Frames.Part).new(EditorModule, targetFolder))
end

EditorModule:registerSelectorFrame(require(Frames.Scripts).new(EditorModule))
EditorModule:registerSelectorFrame(require(Frames.Options).new(EditorModule))

local backButton = Utils.createPaddedButton("rbxassetid://6031091000", 0.1)
backButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backButton.BorderSizePixel = 0
backButton.Size = UDim2.fromScale(0.05, 0.05)
backButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
backButton.Position = UDim2.fromScale(0.01, 0.01)
backButton.Parent = EditorModule.Editor.Sidebar

backButton.MouseButton1Click:Connect(function()
	WMModule:switchWindow("Characters", false)
end)

-- Select handler

EditorModule.Editor.Opened.Event:Connect(function(ctx)
	if ctx.Preset then
		local appearance = CreateModule.recursiveCopy(CharacterAppearances[ctx.Name])
		local appearanceInfo = CreateModule.Appearances:createLocalAppearance(appearance)

		EditorModule.spawnOverrideId = ctx.Id
		EditorModule:updateAppearance(appearanceInfo)
	else
		local appearanceInfo = CreateModule.Appearances:get(ctx.Id)
		if not appearanceInfo then
			warn("Appearance ID", ctx.Id, "was requested but is not present on the client.")
			return
		end

		EditorModule.spawnOverrideId = nil
		EditorModule:updateAppearance(appearanceInfo)
	end

	EditorModule:update()
end)

-- Save/Spawn

local saveEvt = script.Parent.Parent.Events.CharSaved

local function saveAppearance()
	local success = EditorModule:saveAppearance()

	if not success then
		return false
	end

	saveEvt:Fire(EditorModule.currentId)

	return true
end

local viewportControls = EditorModule.Editor.Sidebar.Scroll

local actionControls, _, actionListLayout = LabeledFrame.new("Actions", viewportControls, true)
actionListLayout.FillDirection = Enum.FillDirection.Horizontal
actionListLayout.Padding = UDim.new(0.01, 0)

local function createActionButton(icon)
	local button = Utils.createPaddedButton(icon, 0.15)
	button.Size = UDim2.fromScale(0.1, 0.1)
	button.SizeConstraint = Enum.SizeConstraint.RelativeXX
	button.BorderSizePixel = 0
	button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	button.Parent = actionControls

	return button
end

local saveButton = createActionButton("rbxassetid://6035067857")

saveButton.MouseButton1Click:Connect(function()
	saveAppearance()
end)

local spawnButton = createActionButton("rbxassetid://6034281904")

spawnButton.MouseButton1Click:Connect(function()
	if EditorModule.spawnOverrideId then
		Create.Events.SpawnAsAppearance:InvokeServer(EditorModule.spawnOverrideId)
		return
	end

	local success = saveAppearance()

	if success then
		Create.Events.SpawnAsAppearance:InvokeServer(EditorModule.currentId)
	end
end)
