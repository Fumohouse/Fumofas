---
-- MusicController.lua - Clientside playlist manager
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game.Players.LocalPlayer

local kDefaultRegion = {
	Name = "Overworld",
	Playlist = "default",
}

local kRegions = {
	Cafe = {
		Position = Vector3.new(90.575, 7.95, -23.375),
		Size = Vector3.new(42.05, 15.9, 35.75),
		Playlist = "cafe",
	},
	["Shinmyoumaru Noodle Bar"] = {
		Position = Vector3.new(-30.945, 3.039, -46.996),
		Size = Vector3.new(24.658, 5.924, 13.922),
		Playlist = "shinmy",
	},
}

local MusicController = {
	endListener = nil,
	currentSongData = nil,
	currentSong = nil,
	isPaused = false,

	playlists = {},
	playlistPositions = {},
	savedSeekPositions = {},
	currentPlaylist = nil,

	regions = {},
}

function MusicController:loadRegions()
	for name, regionInfo in pairs(kRegions) do
		local min = regionInfo.Position - regionInfo.Size / 2
		local max = regionInfo.Position + regionInfo.Size / 2

		local region = Region3.new(min, max)

		self.regions[#self.regions + 1] = {
			Name = name,
			Region = region,
			Playlist = regionInfo.Playlist,
		}
	end
end

function MusicController:bindToPlayer()
	coroutine.wrap(function()
		local currentRegion = kDefaultRegion

		while true do
			local regionFound

			local char = LocalPlayer.Character
			if char then
				for _, rg in pairs(self.regions) do
					local parts = workspace:FindPartsInRegion3WithWhiteList(rg.Region, { char.PrimaryPart })

					if #parts > 0 then
						regionFound = rg
					end
				end
			end

			local newRegion = regionFound or kDefaultRegion

			if newRegion ~= currentRegion then
				self:switchPlaylist(newRegion.Playlist)
				currentRegion = newRegion
				ReplicatedStorage.UIEvents.RegionChanged:Fire(newRegion)
			end

			wait(1)
		end
	end)()
end

function MusicController:loadPlaylist(name, playlist)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = SoundService

	for k, songData in ipairs(playlist) do
		local sound = Instance.new("Sound")
		sound.SoundId = songData.Id
		sound.Volume = 0
		sound.Name = songData.Codename
		sound.Parent = folder
	end

	self.playlists[name] = playlist
	self.playlistPositions[name] = 1

	if not self.currentPlaylist then
		self:switchPlaylist(name)
	end
end

function MusicController:switchPlaylist(name)
	if self.currentSong then
		self.savedSeekPositions[self.currentPlaylist] = self.currentSong.TimePosition
	end

	self.currentPlaylist = name
	self:advancePlaylist(0)
end

function MusicController:getCurrentFolder()
	return SoundService:FindFirstChild(self.currentPlaylist)
end

function MusicController:getCurrentPlaylist()
	return self.playlists[self.currentPlaylist], self.playlistPositions[self.currentPlaylist]
end

function MusicController:advancePlaylist(offset)
	local playlist, position = self:getCurrentPlaylist()

	position = position + offset

	if position < 1 then
		position = #playlist - position
	end

	if position > #playlist then
		position = 1
	end

	local song = playlist[position]

	if song then
		self:playSong(song)
	end

	self.playlistPositions[self.currentPlaylist] = position
end

function MusicController:setPaused(paused)
	if paused == nil then
		self.isPaused = not self.isPaused
	else
		self.isPaused = paused
	end

	local song = self.currentSong

	if song then
		if self.isPaused and not song.IsPaused then
			song:Pause()
		elseif not self.isPaused then
			if song.IsPaused then
				song:Resume()
			elseif not song.IsPlaying then
				song:Play()
			end
		end
	end
end

function MusicController:fadeVolume(song, target, cb)
	local duration = math.abs(target - song.Volume) / 0.5 * 2
	local tweenInfo = TweenInfo.new(duration)
	local goal = { Volume = target }

	local tween = TweenService:Create(song, tweenInfo, goal)
	tween:Play()

	if cb then
		coroutine.wrap(function()
			tween.Completed:Wait()
			cb()
		end)()
	end
end

function MusicController:playSong(song)
	local sound = self:getCurrentFolder():FindFirstChild(song.Codename)

	if sound then
		if self.currentSong then
			local oldSong = self.currentSong -- changes as cb is called

			self:fadeVolume(self.currentSong, 0, function()
				if self.currentSong ~= oldSong then -- handles going back and forth
					oldSong:Stop()
				end
			end)
		end

		if self.endListener then
			self.endListener:Disconnect()
		end

		local timePos = self.savedSeekPositions[self.currentPlaylist]
		if timePos then
			sound.TimePosition = timePos
			self.savedSeekPositions[self.currentPlaylist] = 0
		end

		if not self.isPaused then
			sound:Play()
		end

		self:fadeVolume(sound, song.Volume or 0.3)

		self.currentSongData = song
		self.currentSong = sound

		self.endListener = sound.Ended:Connect(function()
			self:advancePlaylist(1)
		end)

		ReplicatedStorage.UIEvents.SongChanged:Fire(song, sound)
	end
end

ReplicatedStorage.UIEvents.SetPaused.Event:Connect(function(paused)
	MusicController:setPaused(paused)
end)

ReplicatedStorage.UIEvents.AdvancePlaylist.Event:Connect(function(offset)
	MusicController:advancePlaylist(offset)
end)

ReplicatedStorage.UIEvents.GetSong.OnInvoke = function()
	return MusicController.currentSongData, MusicController.currentSong
end

return MusicController
