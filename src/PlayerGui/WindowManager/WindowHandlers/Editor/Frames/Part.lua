---
-- Part.lua - Part attachment editor
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local UI = ReplicatedStorage.Common.UI
local PaginatedSelector = require(UI.PaginatedSelector)
local Viewport = require(UI.Viewport)
local Utils = require(UI.Utils)
local LabeledFrame = require(UI.LabeledFrame)

local Create = ReplicatedStorage.Common.Create
local CreateModule = require(Create.CreateModule)
local Schemas = require(Create.Data.Schemas)
local CharacterAppearance = require(Create.CharacterAppearance)

local SelectorFrame = require(script.Parent.SelectorFrame)

local PartFrame = setmetatable({}, { __index = SelectorFrame })
PartFrame.__index = PartFrame

local kTextPreviews = {
	ShanghaiPuppetCtl = "Puppet Control",
}

function PartFrame.new(EditorModule, targetFolder)
	local self = setmetatable(SelectorFrame.new(EditorModule, targetFolder.Name), PartFrame)

	self.TargetName = targetFolder.Name
	self.TargetFolder = targetFolder

	self.Selectors = {}

	return self
end

function PartFrame:load()
	for _, scopeFolder in pairs(self.TargetFolder:GetChildren()) do
		local internalFrame = LabeledFrame.new(scopeFolder.Name, self.Frame)

		local appearanceName = scopeFolder.Name
		local appearanceNameVal = scopeFolder:FindFirstChild("AppearanceName")
		if appearanceNameVal then
			appearanceName = appearanceNameVal.Value
		end

		local required = Schemas.isRequired(self.TargetName, appearanceName)

		local models = {}

		for _, model in pairs(scopeFolder:GetChildren()) do
			if model:IsA("Folder") or model:IsA("Model") then
				if not model:GetAttribute("Hidden") then
					models[#models + 1] = model.Name
				end
			end
		end

		local selector = PaginatedSelector.new(internalFrame, models, not required, scopeFolder.Name == "Accessories")

		selector.GetItemContent = function(frame, item)
			if kTextPreviews[item] then
				local label = Utils.createText()
				label.Size = UDim2.fromScale(1, 1)
				label.Text = kTextPreviews[item]
				label.TextScaled = true
				label.TextXAlignment = Enum.TextXAlignment.Center
				label.TextYAlignment = Enum.TextYAlignment.Center
				label.Parent = frame

				return
			end

			local model = scopeFolder:FindFirstChild(item)
			local viewport = Viewport.new(frame, true)
			viewport.Viewport.Active = false
			viewport.Viewport.Size = UDim2.fromScale(1, 1)
			viewport.Viewport.BackgroundTransparency = 1

			local char = ReplicatedStorage.Models.BaseViewport:Clone()
			local charApp = CharacterAppearance.new(char)
			charApp:attach(model)

			viewport.Camera.CameraSubject = char
			char.Parent = viewport.Viewport

			viewport:updateSubject()

			if self.TargetName == "Head" then
				viewport.Offset = Vector3.new(0, 0, -2.5)
				viewport:setFocalCFrame(char.Head.Head.CFrame)
			elseif self.TargetName == "Legs" then
				viewport.Offset = Vector3.new(0, 0, -1.5)
				viewport:setFocalCFrame(char.RLeg.RLeg.CFrame:Lerp(char.LLeg.LLeg.CFrame, 0.5))
			else
				viewport.Offset = Vector3.new(0, 0, -3)
				viewport:setFocalCFrame(char.Torso.Torso.CFrame)

				local partOffset = model:FindFirstChild("Offset")
				if partOffset then
					if partOffset.Value.Position.Z > 0 then
						viewport.Rotation = Vector2.new(0, math.pi)
					end
				end
			end

			viewport:updateCamera()

			local viewportRotation = viewport.Rotation
			local id = "Viewport_" .. item

			viewport.Viewport.MouseEnter:Connect(function()
				RunService:BindToRenderStep(id, 1, function(dT)
					viewport.Rotation = viewport.Rotation + (dT / (1 / 60)) * Vector2.new(0, 2 * math.pi / 180)
					viewport:updateCamera()
				end)
			end)

			viewport.Viewport.MouseLeave:Connect(function()
				RunService:UnbindFromRenderStep(id)
				viewport.Rotation = viewportRotation
				viewport:updateCamera()
			end)
		end

		selector.ItemSelected.Event:Connect(function(item)
			local appearance = self.EM.currentAppearanceInfo
			if not appearance then
				return
			end

			appearance:save(item, true)
			self.EM:save()
		end)

		selector.ItemDeselected.Event:Connect(function(item)
			local appearance = self.EM.currentAppearanceInfo
			if not appearance then
				return
			end

			appearance:save(item, false)
			self.EM:save()
		end)

		selector:loadItems()

		local scopeKey = scopeFolder:FindFirstChild("AppearanceName")
		local scopeName = scopeFolder.Name

		if scopeKey then
			scopeName = scopeKey.Value
		end

		self.Selectors[scopeName] = selector
	end
end

function PartFrame:update(appearance)
	for _, selector in pairs(self.Selectors) do
		selector:setSelection({})
	end

	local targetData = appearance.Appearance.AttachedParts[self.TargetName]

	if targetData then
		for scope, data in pairs(targetData) do
			if scope == "Accessories" then
				self.Selectors[scope]:setSelection(CreateModule.recursiveCopy(data))
			else
				self.Selectors[scope]:setSelection({ data })
			end
		end
	end
end

return PartFrame
