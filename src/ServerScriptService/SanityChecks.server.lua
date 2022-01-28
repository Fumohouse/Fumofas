---
-- SanityChecks.server.lua - Serverside sanity/integrity checks
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Create = ReplicatedStorage.Common.Create

local Schemas = require(Create.Data.Schemas)

local testData = {
	["Empty Table"] = {},
	["Missing AttachedParts"] = {
		EyeBrows = "A",
		Eyes = "A",
		Mouth = "A",
		EyesColor = Color3.fromRGB(255, 0, 43),
		VoicePitch = "Base",
		Dialogue = "",
	},
	["Invalid Color"] = {
		EyeBrows = "A",
		Eyes = "A",
		Mouth = "A",
		EyesColor = Vector2.new(1, 2),
		VoicePitch = "Base",
		Dialogue = "",
		AttachedParts = {
			Head = {
				Hair = "ReimuHair",
				Accessories = {
					"ReimuBraidBow",
					"ReimuBow",
				},
			},
			Torso = {
				Outfit = "ReimuOutfit",
			},
			Legs = {
				Shoes = "ReimuShoes",
			},
		},
	},
	["No Clothes"] = {
		EyeBrows = "A",
		Eyes = "A",
		Mouth = "A",
		EyesColor = Color3.fromRGB(255, 0, 43),
		VoicePitch = "Base",
		Dialogue = "",
		AttachedParts = {
			Head = {
				Hair = "ReimuHair",
				Accessories = {
					"ReimuBraidBow",
					"ReimuBow",
				},
			},
			Legs = {
				Shoes = "ReimuShoes",
			},
		},
	},
	["Invalid Model Name"] = {
		EyeBrows = "A",
		Eyes = "A",
		Mouth = "A",
		EyesColor = Color3.fromRGB(255, 0, 43),
		VoicePitch = "Base",
		Dialogue = "",
		AttachedParts = {
			Head = {
				Hair = "sfihgoia",
				Accessories = {
					"ReimuBraidBow",
					"ReimuBow",
				},
			},
			Torso = {
				Outfit = "ReimuOutfit",
			},
			Legs = {
				Shoes = "ReimuShoes",
			},
		},
	},
	["Invalid Face Definition"] = {
		EyeBrows = "Asgsgsgs",
		Eyes = "A",
		Mouth = "A",
		EyesColor = Color3.fromRGB(255, 0, 43),
		VoicePitch = "Base",
		Dialogue = "",
		AttachedParts = {
			Head = {
				Hair = "ReimuHair",
				Accessories = {
					"ReimuBraidBow",
					"ReimuBow",
				},
			},
			Torso = {
				Outfit = "ReimuOutfit",
			},
			Legs = {
				Shoes = "ReimuShoes",
			},
		},
	},
}

print("----    Appearance Schema Test    ----")

print("True Cases:")
for name, data in pairs(require(Create.Data.CharacterAppearances)) do
	local result = Schemas.verifyAppearance(data)

	if result then
		print(name, "- PASS")
	else
		warn("Character", name, "failed the schema check.")
	end
end

print()
print("False Cases:")
for name, data in pairs(testData) do
	local result = Schemas.verifyAppearance(data)

	if result then
		warn("False test case failed -", name)
	else
		print(name, "- PASS")
	end
end

print()

print("----    Collision Check    ----")

local pass = true

for _, targetFolder in pairs(ReplicatedStorage.Models.Parts:GetChildren()) do
	for _, scopeFolder in pairs(targetFolder:GetChildren()) do
		for _, model in pairs(scopeFolder:GetChildren()) do
			for _, desc in pairs(model:GetDescendants()) do
				if desc:IsA("BasePart") and desc.CanCollide then
					warn("Part", desc.Name, "of model", model.Name, "has collision on.")
					pass = false
				end
			end
		end
	end
end

if pass then
	print("ALL PASS")
end

print("-------------------------------")
print()
