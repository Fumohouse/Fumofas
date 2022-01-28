---
-- ServerAppearanceHandler.server.lua - Serverside handling of appearance & characters
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Create = ReplicatedStorage.Common.Create

local StarterCharacterScripts = game:GetService("StarterPlayer").StarterCharacterScripts

local CollisionData = require(script.Parent.Parent.Collision.CollisionData)
local CharacterStore = require(script.Parent.CharacterStore)

local CreateModule = require(Create.CreateModule)
local Schemas = require(Create.Data.Schemas)
local CharacterAppearances = require(Create.Data.CharacterAppearances)

local baseModel = ReplicatedStorage.Models.BaseNormal

local spawnPoints = workspace.Spawns:GetChildren()

math.randomseed(tick())

-- Setting appearance

local function addNametag(char)
	if not char then
		return
	end

	local head = char:FindFirstChild("Head")
	if not head then
		return
	end
	head = head:FindFirstChild("Head")
	if not head or not head:IsA("BasePart") then
		return
	end

	local nameTag = game.ServerStorage.NameTag:Clone()
	nameTag.Parent = head
	nameTag.Adornee = head
	nameTag:FindFirstChildOfClass("TextLabel").Text = char.Name
end

local function setPlayerAppearance(player, id, forceCreate)
	print("SAH: Setting player appearance for", player.Name, "to", tostring(id))

	local info = CreateModule.Appearances:get(id)

	if not info then
		print("-> Rejected. Appearance ID doesn't exist.")
		return false, "The appearance ID given doesn't exist."
	end

	local char = player.Character

	if forceCreate or not char or not char:GetAttribute("AppearanceId") then
		print("|_ Creating a new character.")
		char = baseModel:Clone()
		char.Name = player.Name

		addNametag(char)

		for k, v in pairs(StarterCharacterScripts:GetChildren()) do
			v:Clone().Parent = char
		end

		player.Character = char
		char.Parent = workspace
	else
		local hum = char:FindFirstChildOfClass("Humanoid")

		if hum and hum.Sit then
			hum.Sit = false
			wait(0.2)
		end
	end

	print("|_ Getting CharacterAppearance.")

	local charApp = CharacterStore:getFromPlayer(player, char, info.Appearance)
	if charApp.BoundAppearance ~= info then
		info:register(charApp)
	end

	char:SetAttribute("AppearanceId", id)

	-- Choose spawnpoint manually
	local spawnIdx = math.floor(math.random() * #spawnPoints) + 1
	local cf, size = char:GetBoundingBox()
	char:SetPrimaryPartCFrame(spawnPoints[spawnIdx].CFrame + Vector3.new(0, size.Y / 2, 0))

	print("-> Spawned.")
	print("<< set appearance request end >>")
end

-- Load presets

local presetIds = {}

local kDefaultCharacter = "Reimu"

for name, appearance in pairs(CharacterAppearances) do
	local id, info = CreateModule.Appearances:registerAppearance("SERVER", appearance)
	presetIds[name] = id
end

-- Spawn, Reset, Death

local function randomVelocity(max)
	local x = 2 * math.random() * max - max
	local y = 2 * math.random() * max - max
	local z = 2 * math.random() * max - max

	return Vector3.new(x, y, z)
end

local function handlePlayerDeath(player)
	local char = player.Character
	if not char or not char.Parent or player:GetAttribute("IsDying") then
		return
	end

	player:SetAttribute("IsDying", true)

	print("SAH: Player", player.Name, "died.")

	for k, v in pairs(char:GetDescendants()) do
		if v:IsA("JointInstance") then
			v:Destroy()
		end
	end

	for k, v in pairs(char:GetDescendants()) do
		if v ~= char.PrimaryPart and v:IsA("BasePart") then
			v.CanCollide = true
			v.Velocity = randomVelocity(100)
			CollisionData.updateCollision(player, v)
		end
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://6599361591"
	sound.Volume = 0.2
	sound.Parent = char.PrimaryPart

	sound:Play()

	local particle = Instance.new("ParticleEmitter")
	particle.Enabled = false
	particle.Texture = "rbxassetid://306412332"
	particle.Drag = 5
	particle.Lifetime = NumberRange.new(0.5, 1)
	particle.Speed = NumberRange.new(20, 40)
	particle.SpreadAngle = Vector2.new(180, 180)
	particle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 157, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 157, 0)),
	})
	particle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.01, 5),
		NumberSequenceKeypoint.new(1, 8),
	})
	particle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.8, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	particle.Parent = char.PrimaryPart

	particle:Emit(50)

	coroutine.wrap(function()
		wait(3)

		if not player.Parent then
			return
		end -- if they left

		local id = char:GetAttribute("AppearanceId")
		if not id then
			return
		end

		setPlayerAppearance(player, id, true)

		player:SetAttribute("IsDying", false)
	end)()
end

Players.PlayerAdded:Connect(function(player)
	Create.Events.LoadPresets:FireClient(player, presetIds)

	player.CharacterAdded:Connect(function(char)
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Died:Connect(function()
				handlePlayerDeath(player)
			end)
		end
	end)

	setPlayerAppearance(player, presetIds[kDefaultCharacter])
end)

Players.PlayerRemoving:Connect(function(player)
	print("SAH: Player", player.Name, "left. Clearing appearances...")
	for id, appearance in pairs(CreateModule.Appearances.Appearances) do
		if appearance.Owner == player then
			local registered = appearance.RegisteredCharacters

			print("|_ Appearance", tostring(appearance.Id) .. ":")

			for k, v in pairs(registered) do
				print("|_ Registered:", v.Character.Name)
			end

			local newOwnerFound = false

			for k, boundChar in pairs(registered) do
				local boundPlayer = Players:GetPlayerFromCharacter(boundChar.Character)
				if boundPlayer then
					print("|_ Switching ownership of", id, "to", boundPlayer.Name)
					appearance.Owner = boundPlayer

					newOwnerFound = true
				end
			end

			if not newOwnerFound then
				print("|_ Removing appearance", id, "owned by", player.Name, "as they left.")
				CreateModule.Appearances:deregister(id)
			end
		end
	end

	print("<< leave listener end >>")
end)

Create.Events.ResetChar.OnServerEvent:Connect(handlePlayerDeath)

local kMaxFall = -500

RunService.Stepped:Connect(function()
	for k, v in pairs(Players:GetPlayers()) do
		if v.Character and not v:GetAttribute("IsDying") then
			if v.Character:GetPrimaryPartCFrame().Y < kMaxFall then
				print("SAH: Player", v.Character.Name, "fell to their death.")
				handlePlayerDeath(v)
			end
		end
	end
end)

-- Register and spawn as custom

Create.Events.RegisterAppearance.OnServerInvoke = function(player, appearance, id)
	print("Register request from", player.Name, "for appearance ID", tostring(id))
	if not Schemas.verifyAppearance(appearance) then
		print("-> Request was rejected. Invalid appearance.")
		return false, "The appearance data is invalid."
	end

	local id, info = CreateModule.Appearances:registerAppearance(player, appearance, id)
	if not id then
		print("-> Request was rejected. No permissions.")
		return false, "The appearance failed to save. Do you own it?"
	end

	print("-> Successfully registered as ID", id)
	print("<< request end >>")

	return true, id
end

Create.Events.SpawnAsAppearance.OnServerInvoke = function(player, id)
	print("SAH: Player-issued request from", player.Name, "to spawn as", tostring(id))
	setPlayerAppearance(player, id)
	print("<< switch character request end >>")
end
