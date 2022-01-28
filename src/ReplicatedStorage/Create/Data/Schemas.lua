---
-- Schemas.lua - Validation of appearance data
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreateModule = require(script.Parent.Parent.CreateModule)
local ModelData = require(script.Parent.ModelData)
local FaceStyles = require(script.Parent.FaceStyles)
local ModelSizes = require(script.Parent.ModelSizes)
local VoicePitches = require(script.Parent.VoicePitches)
local Dialogues = require(script.Parent.Dialogues)
local partsFolder = ReplicatedStorage.Models.Parts

local requiredScopes = {
	Head = {
		Hair = true,
	},
	Torso = {
		Outfit = true,
	},
}

local Schemas = {}

local appearanceSchema = {
	Size = {
		Type = "string",
		AcceptedValues = CreateModule.keysToList(ModelSizes, false),
		Optional = true,
	},
	EyeBrows = {
		Type = "string",
		AcceptedValues = CreateModule.keysToList(FaceStyles.EyeBrows, true),
	},
	Eyes = {
		Type = "string",
		AcceptedValues = CreateModule.keysToList(FaceStyles.Eyes, true),
	},
	Mouth = {
		Type = "string",
		AcceptedValues = CreateModule.keysToList(FaceStyles.Mouth, true),
	},
	VoicePitch = {
		Type = "string",
		AcceptedValues = CreateModule.valuesToList(VoicePitches, true),
	},
	Dialogue = {
		Type = "string",
		AcceptedValues = CreateModule.valuesToList(Dialogues, true),
		Optional = true,
	},
	EyesColor = {
		Typeof = "Color3",
	},

	AttachedParts = {
		Type = "table",
		VerifyFunction = function(tbl)
			for index, partInfo in pairs(tbl) do
				if type(index) ~= "string" then
					return false
				end

				local targetFolder = partsFolder:FindFirstChild(index)

				if not targetFolder then
					return false
				end

				if type(partInfo) ~= "table" then
					return false
				end

				for scope, value in pairs(partInfo) do
					if type(scope) ~= "string" then
						return false
					end

					local scopeFolder

					for _, child in pairs(targetFolder:GetChildren()) do
						local appearanceNameVal = child:FindFirstChild("AppearanceName")

						if (appearanceNameVal and appearanceNameVal.Value == scope) or scope == child.Name then
							scopeFolder = child
							break
						end
					end

					if not scopeFolder then
						return false
					end

					if scope ~= "Accessories" then
						if not scopeFolder:FindFirstChild(value) then
							return false
						end
					else
						if type(value) ~= "table" then
							return false
						end

						for idx, modelName in pairs(value) do
							if type(idx) ~= "number" then
								return false
							end

							if not scopeFolder:FindFirstChild(modelName) then
								return false
							end
						end
					end
				end
			end

			for scope, info in pairs(requiredScopes) do
				if not tbl[scope] then
					return false
				end

				for name, _ in pairs(info) do
					if not tbl[scope][name] then
						return false
					end
				end
			end

			return true
		end,
	},

	Options = {
		Type = "table",
		Optional = true,
		VerifyFunction = function(tbl, appearance)
			local attachedParts = CreateModule.findAllModels(appearance)

			for modelName, options in pairs(tbl) do
				if not table.find(attachedParts, modelName) then
					return false
				end

				if not type(options) == "table" then
					return false
				end

				local modelInfo = ModelData.findModelInfo(modelName)
				if not modelInfo then
					return false
				end

				for option, value in pairs(options) do
					local optionInfo

					if modelInfo.Options and modelInfo.Options[option] then
						optionInfo = modelInfo.Options[option]
					end

					if not optionInfo and modelInfo.InheritedOptions and modelInfo.InheritedOptions[option] then
						optionInfo = modelInfo.InheritedOptions[option]
					end

					if not optionInfo or typeof(value) ~= optionInfo.Type then
						return false
					end

					if optionInfo.GetAcceptedValues then
						local accepted = optionInfo.GetAcceptedValues()

						if not (optionInfo.AllowNone and (value == "" or value == nil)) and not table.find(accepted, value) then
							return false
						end
					end
				end
			end

			return true
		end,
	},

	Scripts = {
		Type = "table",
		Optional = true,
		VerifyFunction = function(list)
			for _, scriptName in pairs(list) do
				if not ReplicatedStorage.Models.Scripts:FindFirstChild(scriptName) then
					return false
				end
			end

			return true
		end,
	},
}

function Schemas.isRequired(target, scope)
	return requiredScopes[target] and requiredScopes[target][scope] == true
end

function Schemas.verifyAppearance(appearance)
	if type(appearance) ~= "table" then
		return false
	end

	for k, v in pairs(appearance) do
		local schemaInfo = appearanceSchema[k]
		if not schemaInfo then
			return false
		end

		if schemaInfo.Type and type(v) ~= schemaInfo.Type then
			return false
		end

		if schemaInfo.Typeof and typeof(v) ~= schemaInfo.Typeof then
			return false
		end

		if schemaInfo.AcceptedValues and table.find(schemaInfo.AcceptedValues, v) == nil then
			return false
		end

		if schemaInfo.VerifyFunction and not schemaInfo.VerifyFunction(v, appearance) then
			return false
		end
	end

	for k, v in pairs(appearanceSchema) do
		if not v.Optional and not appearance[k] then
			return false
		end
	end

	return true
end

return Schemas
