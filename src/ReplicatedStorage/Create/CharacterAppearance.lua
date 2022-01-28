---
-- CharacterAppearance.lua - Common handler for applying appearances to models
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterAppearances = require(script.Parent.Data.CharacterAppearances)
local FaceStyles = require(script.Parent.Data.FaceStyles)
local ModelSizes = require(script.Parent.Data.ModelSizes)
local ModelData = require(script.Parent.Data.ModelData)
local CreateModule = require(script.Parent.CreateModule)

local CharacterAppearance = {}

function CharacterAppearance.new(char, appearance)
	local self = setmetatable({}, CharacterAppearance)

	self._protectedState = {
		BoundAppearance = nil,
	}

	self.Character = char
	self.Appearance = appearance
	self.Tools = {}

	local updateEvt = Instance.new("BindableEvent")
	self.Updated = updateEvt

	if appearance then
		self:loadAppearance()
	end

	return self
end

function CharacterAppearance:_getCurrentScale()
	return self.Character:GetAttribute("Scale") or 1
end

function CharacterAppearance:registerTool(tool)
	self.Tools[#self.Tools + 1] = tool
	CreateModule.scaleModel(tool, self:_getCurrentScale())
end

function CharacterAppearance.__index(tbl, index)
	if CharacterAppearance[index] then
		return CharacterAppearance[index]
	end

	if tbl._protectedState[index] then
		return tbl._protectedState[index]
	end

	return rawget(tbl, index)
end

function CharacterAppearance.__newindex(tbl, index, value)
	if index == "BoundAppearance" then
		if tbl._protectedState.BoundAppearance and value then
			error("Tried to set bound appearance when already bound or reserved")
		else
			tbl._protectedState.BoundAppearance = value
		end

		return
	end

	rawset(tbl, index, value)
end

function CharacterAppearance:deregister()
	if self.BoundAppearance then
		self.BoundAppearance:deregister(self)
	end
end

function CharacterAppearance:_getFolder(name)
	local folder = self.Character:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name

		folder.Parent = self.Character
	end

	return folder
end

function CharacterAppearance:getPartFolder()
	return self:_getFolder("CreateFolder")
end

function CharacterAppearance:getScriptFolder()
	return self:_getFolder("Scripts")
end

function CharacterAppearance:attach(model, skipClone)
	local char = self.Character

	-- Resolve part folder
	local partFolder = self:getPartFolder()

	if partFolder:FindFirstChild(model.Name) then
		return false
	end

	-- Handle exclusivity
	local removedModels = {}

	local modelInfo = ModelData.findModelInfo(model.Name)

	if modelInfo and modelInfo.MutuallyExclusive then -- modelInfo will be null on children of folders.
		for k, v in pairs(partFolder:GetChildren()) do
			local otherInfo = ModelData.findModelInfo(v.Name)

			if modelInfo.ScopeKey == otherInfo.ScopeKey then
				removedModels[#removedModels + 1] = v.Name
				v:Destroy()
			end
		end
	end

	-- Handle folder attachment
	if model:IsA("Folder") then
		local newFolder = model:Clone()
		newFolder.Parent = partFolder

		for k, v in pairs(newFolder:GetChildren()) do
			if v:IsA("Model") then
				self:attach(v, true)
			end
		end

		return removedModels
	end

	local newModel
	if skipClone then
		newModel = model
	else
		newModel = model:Clone()
	end

	-- Find values
	local accessoryRootPart = newModel.PrimaryPart
	local iOffset = newModel:FindFirstChild("Offset")
	local weldTargetName = newModel:GetAttribute("WeldTarget")

	if not accessoryRootPart or not iOffset or not weldTargetName then
		return
	end

	local offset = iOffset.Value

	-- Handle scale
	local scale = char:GetAttribute("Scale") or 1
	local baseScale
	local baseScaleValue = model:FindFirstChild("BaseScale")

	if baseScaleValue then
		baseScale = baseScaleValue.Value
	end

	CreateModule.scaleModel(newModel, scale, baseScale)

	-- Attach
	local weldTargetPart = char:FindFirstChild(weldTargetName)
	if not weldTargetPart then
		return
	end
	weldTargetPart = weldTargetPart:FindFirstChild(weldTargetName)
	if not weldTargetPart then
		return
	end

	local weld = Instance.new("Weld")
	weld.Name = "RootWeld"
	weld.Part0 = weldTargetPart
	weld.Part1 = accessoryRootPart
	weld.C0 = offset
	weld.C1 = CFrame.new()

	weld.Parent = newModel

	CreateModule.scaleInst(weld, scale, baseScale)

	if not newModel.Parent then -- Do not set parent if it already exists (i.e. folder)
		newModel.Parent = partFolder
	end

	return removedModels
end

function CharacterAppearance:detach(modelName)
	local partFolder = self:getPartFolder()
	local model = partFolder:FindFirstChild(modelName)

	if model then
		model:Destroy()
		return true
	end

	return false
end

local function getPartTopY(part)
	return (part.Position + part.Size / 2).Y
end

local kBaseHipHeight = 0.9

function CharacterAppearance:loadAppearance()
	if not self.Appearance then
		return
	end

	print("CharacterAppearance: Got request to load appearance for", self.Character.Name)

	local char = self.Character
	local appearance = self.Appearance

	local existingFolder = self.Character:FindFirstChild("CreateFolder")

	local fallback = CharacterAppearances.Reimu

	print("|_ Loading appearance.")

	local size = ModelSizes[appearance.Size or fallback.Size]
	local sizeChanged = false
	if size then
		local currentScale = self.Character:GetAttribute("Scale") -- Store ground truths always (incase sideways)
		local targetScale = size.Scale

		print("|_ Scale:", targetScale)

		if targetScale ~= currentScale then
			print("|_ Adjusting scale, as it has changed.")

			CreateModule.scaleModel(char, targetScale)
			char.PrimaryPart.CustomPhysicalProperties = size.CustomPhysicalProperties
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.HipHeight = kBaseHipHeight * targetScale
			end

			for _, tool in pairs(self.Tools) do
				if not tool:IsDescendantOf(char) then
					CreateModule.scaleModel(tool, targetScale)
				end
			end

			char:SetAttribute("Scale", targetScale)
			sizeChanged = true
		end
	end

	local head = char.Head.Head

	local browStyle = FaceStyles.EyeBrows[appearance.EyeBrows or fallback.EyeBrows]
	if browStyle then
		head.EyeBrows.Texture = browStyle.Id
	else
		head.EyeBrows.Texture = ""
	end

	local eyeStyle = FaceStyles.Eyes[appearance.Eyes or fallback.Eyes]
	if eyeStyle then
		head.Eyes.Texture = eyeStyle.Eyes
		head.EyeShine.Texture = eyeStyle.Shine
	else
		head.Eyes.Texture = ""
		head.EyeShine.Texture = ""
	end

	local mouthStyle = FaceStyles.Mouth[appearance.Mouth or fallback.Mouth]
	if mouthStyle then
		head.Mouth.Texture = mouthStyle.Id
	else
		head.Mouth.Texture = ""
	end

	if eyeStyle and eyeStyle.SupportsRecoloring ~= false then
		head.Eyes.Color3 = appearance.EyesColor or fallback.EyesColor
	else
		head.Eyes.Color3 = Color3.fromRGB(255, 255, 255)
	end

	char.VoicePitch.Value = appearance.VoicePitch or fallback.VoicePitch
	char.Dialogue.Value = appearance.Dialogue or fallback.Dialogue

	local attachedModels = {}

	for targetName, targetInfo in pairs(appearance.AttachedParts or fallback.AttachedParts) do
		for scopeName, data in pairs(targetInfo) do
			if scopeName ~= "Accessories" then
				local modelInfo = ModelData.findModelInfo(data)
				if modelInfo then
					self:attach(modelInfo.Model)
					attachedModels[#attachedModels + 1] = data
				end
			else
				for _, name in pairs(data) do
					local modelInfo = ModelData.findModelInfo(name)
					if modelInfo then
						self:attach(modelInfo.Model)
						attachedModels[#attachedModels + 1] = name
					end
				end
			end
		end
	end

	if existingFolder then
		for _, v in pairs(existingFolder:GetChildren()) do
			if not table.find(attachedModels, v.Name) then
				v:Destroy()
			end
		end
	end

	if not char.Parent then
		CreateModule.fixJoints(char)
	end

	local options = appearance.Options
	local folder = self:getPartFolder()

	for _, model in pairs(folder:GetChildren()) do
		local optsSet = {}
		local modelInfo = ModelData.findModelInfo(model.Name)

		local function updateOpts(opts)
			if not opts then
				return
			end

			for name, data in pairs(opts) do
				if not optsSet[name] then
					local value = data.Get(modelInfo.Model)

					if options and options[model.Name] then
						value = options[model.Name][name] or value
					end

					data.Set(model, value, char)
					optsSet[name] = true
				end
			end
		end

		updateOpts(modelInfo.Options)
		updateOpts(modelInfo.InheritedOptions)
	end

	local scripts = appearance.Scripts
	local scriptFolder = self:getScriptFolder()

	for _, scr in pairs(scriptFolder:GetChildren()) do
		require(scr).Deinit(char, sizeChanged) -- sizeChanged implies that all joint offsets have been reset

		if not scripts or not table.find(scripts, scr.Name) then
			scr:Destroy()
		end
	end

	if scripts then
		for _, scriptName in pairs(scripts) do
			local existing = scriptFolder:FindFirstChild(scriptName)

			if existing then
				require(existing).Init(char, sizeChanged)
			else
				local scr = ReplicatedStorage.Models.Scripts:FindFirstChild(scriptName)

				if scr then
					local newScript = scr:Clone()
					newScript.Parent = scriptFolder

					require(newScript).Init(char, sizeChanged)
				end
			end
		end
	end

	local nameTag = head:FindFirstChild("NameTag")

	if nameTag then
		local highestPart = head
		local highestPartY = getPartTopY(highestPart)

		for _, v in pairs(self:getPartFolder():GetDescendants()) do
			if v:IsA("BasePart") then
				local topY = getPartTopY(v)

				if topY > highestPartY then
					highestPart = v
					highestPartY = topY
				end
			end
		end

		nameTag.StudsOffset = Vector3.new(0, highestPartY - head.Position.Y + 0.5 * size.Scale, 0)
	end

	print("|_ Done!")

	self.Updated:Fire()

	return true
end

return CharacterAppearance
