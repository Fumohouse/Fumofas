---
-- CreateModule.lua - Various utility functions
--

local AppearanceStore = require(script.Parent.AppearanceStore)

local CreateModule = {
	Appearances = AppearanceStore,
}

CreateModule.__index = CreateModule

function CreateModule.findAllModels(appearance)
	if not appearance.AttachedParts then
		return {}
	end

	local modelNames = {}

	for _, targetInfo in pairs(appearance.AttachedParts) do
		for scopeName, data in pairs(targetInfo) do
			if scopeName ~= "Accessories" then
				modelNames[#modelNames + 1] = data
			else
				for _, accessory in pairs(data) do
					modelNames[#modelNames + 1] = accessory
				end
			end
		end
	end

	return modelNames
end

local commonWeldTargets = { "Head", "Torso", "LLeg", "RLeg", "LArm", "RArm", "HumanoidRootPart" }

function CreateModule.getTotalOffset(char, weld, commonTarget)
	local checkWeld = weld
	local totalOffset = weld.C0 * weld.C1:Inverse()
	local levels = 0

	while commonTarget or not table.find(commonWeldTargets, checkWeld.Part0.Name) do
		local weldFound = false

		for _, desc in pairs(char:GetDescendants()) do
			if desc:IsA("JointInstance") and desc.Part1 == checkWeld.Part0 then
				totalOffset = desc.C0 * desc.C1:Inverse() * totalOffset
				checkWeld = desc
				levels = levels + 1

				if desc.Part0.Name == commonTarget then
					return desc, totalOffset, levels
				end

				weldFound = true
				break
			end
		end

		if not weldFound then
			break
		end
	end

	return checkWeld, totalOffset, levels
end

function CreateModule.recursiveCopy(tbl)
	local copy = {}

	for k, v in pairs(tbl) do
		if type(v) == "table" then
			copy[k] = CreateModule.recursiveCopy(v)
		else
			copy[k] = v
		end
	end

	return copy
end

local function storeTruth(inst, prop, value)
	local valueName = "orig_" .. prop

	local propType = typeof(value)
	local newVal

	if propType == "CFrame" then
		newVal = Instance.new("CFrameValue")
	elseif propType == "Vector3" or propType == "number" then
		inst:SetAttribute(valueName, value)
	else
		return
	end

	if newVal then
		newVal.Name = valueName
		newVal.Value = value
		newVal.Parent = inst
	end
end

-- Retrieve and store ground-truth data from attribute/ObjectValue
local function getProp(inst, prop)
	local valueName = "orig_" .. prop

	local valueObj = inst:FindFirstChild(valueName)
	if valueObj then
		return valueObj.Value
	end

	local attrValue = inst:GetAttribute(valueName)
	if attrValue then
		return attrValue
	end

	storeTruth(inst, prop, inst[prop])
	return inst[prop]
end

local function scaleValue(value, scale)
	local valType = typeof(value)

	if valType == "Vector3" or valType == "number" then
		return value * scale
	elseif valType == "CFrame" then
		return (value - value.Position) + value.Position * scale
	end
end

local function scaleProp(inst, prop, scale, baseScale)
	if baseScale then
		storeTruth(inst, prop, scaleValue(inst[prop], 1 / baseScale))
	end

	inst[prop] = scaleValue(getProp(inst, prop), scale)
end

function CreateModule.scaleInst(inst, scale, baseScale)
	local toScale

	if inst:IsA("BasePart") then
		toScale = { "Size" }
	elseif inst:IsA("JointInstance") then
		toScale = { "C0", "C1" }
	elseif inst:IsA("Texture") then
		toScale = { "OffsetStudsU", "OffsetStudsV", "StudsPerTileU", "StudsPerTileV" }
	elseif inst:IsA("SpecialMesh") and inst.MeshType == Enum.MeshType.FileMesh then
		toScale = { "Scale", "Offset" }
	elseif inst:IsA("Attachment") then
		toScale = { "CFrame" }
	elseif inst:IsA("RopeConstraint") then
		toScale = { "Length", "Thickness" }
	else
		return
	end

	for _, prop in ipairs(toScale) do
		scaleProp(inst, prop, scale, baseScale)
	end
end

function CreateModule.scaleModel(model, scale, baseScale)
	for _, desc in pairs(model:GetDescendants()) do
		CreateModule.scaleInst(desc, scale, baseScale)
	end
end

function CreateModule.fixJoints(char)
	local joints = {}

	for _, joint in pairs(char:GetDescendants()) do
		if joint:IsA("JointInstance") then
			local weld, offset, levels = CreateModule.getTotalOffset(char, joint, "HumanoidRootPart")

			joints[#joints + 1] = {
				Joint = joint,
				Weld = weld,
				Offset = offset,
				Levels = levels,
			}
		end
	end

	for _, jointInfo in ipairs(joints) do
		local targetPart = jointInfo.Joint.Part1
		local rootPart = jointInfo.Weld.Part0

		targetPart.CFrame = rootPart.CFrame * jointInfo.Offset
	end
end

function CreateModule.keysToList(tbl, allowEmptyString)
	local out = {}

	if allowEmptyString then
		out[1] = ""
	end

	for k, _ in pairs(tbl) do
		out[#out + 1] = k
	end

	return out
end

function CreateModule.valuesToList(tbl, allowEmptyString)
	local out = {}

	if allowEmptyString then
		out[1] = ""
	end

	for _, v in pairs(tbl) do
		out[#out + 1] = v
	end

	return out
end

return CreateModule
