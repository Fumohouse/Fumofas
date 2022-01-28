---
-- AppearanceStore.lua - Common store for appearance data
--

local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer

local ModelData = require(script.Parent.Data.ModelData)
local PostProcessor = require(script.Parent.PostProcessor)

local AppearanceInfo = {}
AppearanceInfo.__index = AppearanceInfo

function AppearanceInfo.new(id, owner, appearance)
	local self = setmetatable({}, AppearanceInfo)

	self.Id = id
	self.Owner = owner
	self.Appearance = appearance
	self.RegisteredCharacters = {}

	return self
end

function AppearanceInfo:save(modelName, isAttached)
	local modelInfo = ModelData.findModelInfo(modelName)
	if not modelInfo then
		warn("Could not find model", modelName)
		return
	end

	local attachedParts = self.Appearance.AttachedParts

	if not attachedParts[modelInfo.Target] then
		attachedParts[modelInfo.Target] = {}
	end

	if modelInfo.ScopeKey == "Accessories" then
		if not attachedParts[modelInfo.Target].Accessories then
			attachedParts[modelInfo.Target].Accessories = {}
		end

		local accessories = attachedParts[modelInfo.Target].Accessories
		local idx = table.find(accessories, modelName)

		if isAttached and not idx then
			accessories[#accessories + 1] = modelName
		elseif not isAttached then
			return table.remove(accessories, idx)
		end
	else
		local newVal

		if isAttached then
			newVal = modelName
		end

		local oldVal = attachedParts[modelInfo.Target][modelInfo.ScopeKey]

		attachedParts[modelInfo.Target][modelInfo.ScopeKey] = newVal

		return oldVal
	end
end

function AppearanceInfo:setKey(key, value)
	local prevValue = self.Appearance[key]

	self.Appearance[key] = value
	PostProcessor.optionChanged(self, key, prevValue, value)
end

function AppearanceInfo:setOption(modelName, name, value)
	if not self.Appearance.Options then
		self.Appearance.Options = {}
	end

	local options = self.Appearance.Options

	if not options[modelName] then
		options[modelName] = {}
	end

	options[modelName][name] = value
end

function AppearanceInfo:register(character)
	print("AppearanceInfo: Registering character", character.Character.Name, "to", tostring(self.Id))

	if character.BoundAppearance then
		character:deregister()
	end

	character.BoundAppearance = self

	local idx = table.find(self.RegisteredCharacters, character)
	if idx then
		return
	end

	self.RegisteredCharacters[#self.RegisteredCharacters + 1] = character
end

function AppearanceInfo:deregister(character)
	print("AppearanceInfo: Deregistering character", character.Character.Name, "from", tostring(self.Id), "<<<<<")

	local idx = table.find(self.RegisteredCharacters, character)
	if idx then
		table.remove(self.RegisteredCharacters, idx)
		character.BoundAppearance = nil
	end
end

function AppearanceInfo:fireUpdate()
	print(
		"AppearanceInfo: Propagating appearance update for ID",
		tostring(self.Id),
		"owned by",
		tostring(self.Owner),
		"to",
		#self.RegisteredCharacters,
		"characters."
	)

	for k, v in pairs(self.RegisteredCharacters) do
		print("|_ Applying to", v.Character.Name)
		v.Appearance = self.Appearance
		v:loadAppearance()
	end
end

------

local AppearanceStore = {
	Appearances = {},
	appIdx = 0,
}

AppearanceStore.__index = AppearanceStore

function AppearanceStore:createLocalAppearance(appearance)
	return AppearanceInfo.new(nil, LocalPlayer, appearance)
end

function AppearanceStore:registerLocalAppearance(appInfo, id)
	self.Appearances[id] = appInfo
	appInfo.Id = id
end

function AppearanceStore:registerAppearance(owner, appearance, id, allowClient)
	print("AppearanceStore: Got request to register ID", tostring(id), "to", tostring(owner))

	if id then
		local info = self:get(id)

		if info then
			print("|_ Appearance exists.")
			if owner ~= info.Owner then
				print("-> Rejected. Wrong owner.")
				return
			end

			info.Appearance = appearance
			info:fireUpdate()
		else
			print("-> Creating new appearance.")
			info = AppearanceInfo.new(id, owner, appearance)
			self.Appearances[id] = info
		end

		return id, info
	else
		if not allowClient and RunService:IsClient() then
			warn("Attempted to register an appearance without an ID on client-side.")
			return
		end

		print("-> Creating new appearance with auto ID", self.appIdx)

		local idx = self.appIdx
		local newInfo = AppearanceInfo.new(idx, owner, appearance)
		self.Appearances[idx] = newInfo
		self.appIdx = idx + 1

		return idx, newInfo
	end
end

function AppearanceStore:deregister(id)
	if self.Appearances[id] then
		self.Appearances[id] = nil
	end
end

function AppearanceStore:get(id)
	return self.Appearances[id]
end

return AppearanceStore
