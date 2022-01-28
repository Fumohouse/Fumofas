---
-- SoundPool.lua - System for playing/getting named sounds
-- Assumes that a sound which is not playing is free to be used again
--

local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")

local poolFolder = Instance.new("Folder")
poolFolder.Name = "SoundPool"
poolFolder.Parent = SoundService

local SoundPool = {}
SoundPool.__index = SoundPool

-- 16 seconds per octave, 8 seconds per sample, ~50% silent -> 4s playback
local kSamples = {
	"rbxassetid://233836579", --C/C#
	"rbxassetid://233844049", --D/D#
	"rbxassetid://233845680", --E/F
	"rbxassetid://233852841", --F#/G
	"rbxassetid://233854135", --G#/A
	"rbxassetid://233856105", --A#/B
}

function SoundPool.new(name, sounds, copies, parent)
	local self = setmetatable({}, SoundPool)

	sounds = sounds or kSamples

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent or poolFolder

	self.Folder = folder
	self.SoundIds = sounds
	self.Sounds = {}

	self:_preload()

	for soundName, _ in pairs(sounds) do
		for i = 1, copies do
			self:createSound(soundName)
		end
	end

	return self
end

function SoundPool:_preload()
	local preload = {}

	for _, soundId in pairs(self.SoundIds) do
		local sound = Instance.new("Sound")
		sound.SoundId = soundId

		preload[#preload + 1] = sound
	end

	ContentProvider:PreloadAsync(preload)
end

function SoundPool:createSound(name)
	local soundCopies = self.Sounds[name]
	if not soundCopies then
		soundCopies = {}
		self.Sounds[name] = soundCopies
	end

	local sound = Instance.new("Sound")
	sound.Name = tostring(name)
	sound.SoundId = self.SoundIds[name]
	sound.Parent = self.Folder

	soundCopies[#soundCopies + 1] = sound

	return sound
end

function SoundPool:getSound(name)
	local soundList = self.Sounds[name]

	if soundList then
		for _, sound in pairs(soundList) do
			if not sound.IsPlaying then
				return sound
			end
		end

		local newSound = self:createSound(name)

        local function removeSound()
            newSound:Destroy()
            table.remove(soundList, table.find(soundList, newSound))
        end

		newSound.Stopped:Connect(removeSound)
		newSound.Ended:Connect(removeSound)

		return newSound
	end
end

return SoundPool
