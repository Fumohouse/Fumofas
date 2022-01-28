---
-- MugSurface.lua - Handler for surface to put mugs on
--

local Players = game:GetService("Players")

local MugSurface = {}
MugSurface.__index = MugSurface

local random = Random.new(tick())

function MugSurface.new(baseAttachment)
	local self = setmetatable({
		CurrentMug = nil,
		_currentOwner = nil,

		_lResetChar = nil,
		_lAttachmentChange = nil,

		BaseAttachment = baseAttachment,
	}, MugSurface)

	Players.PlayerRemoving:Connect(function(player)
		if player == self._currentOwner then
			self:reset(true)
		end
	end)

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://5314629484"
	sound.Parent = baseAttachment.Parent

	self._sound = sound

	local weld = Instance.new("Weld")
	weld.Name = "MugWeld"
	weld.Part0 = baseAttachment.Parent
	weld.C0 = baseAttachment.CFrame
	weld.C1 = CFrame.new()
	weld.Parent = baseAttachment.Parent

	self._weld = weld

	return self
end

function MugSurface:reset(destroyMug)
	if self._lResetChar then
		self._lResetChar:Disconnect()
	end

	if self._lAttachmentChange then
		self._lAttachmentChange:Disconnect()
	end

	if destroyMug then
		self.CurrentMug:Destroy()
	end

	self.CurrentMug = nil
	self._currentOwner = nil
end

function MugSurface:_updateWeld()
	self._weld.C1 = self.CurrentMug.Coffee.Cup.SurfaceAttachment.CFrame
end

function MugSurface:attach(player, mug)
	self._currentOwner = player
	self.CurrentMug = mug

	self._lResetChar = player.CharacterAdded:Connect(function()
		self:reset(true)
	end)

	self.CurrentMug.Parent = self.BaseAttachment.Parent
	self.CurrentMug.SetWelded:Fire(false)
	self:_updateWeld()
	self._weld.C0 = self._weld.C0 * CFrame.Angles(random:NextNumber(0, math.pi), 0, 0)
	self._weld.Part1 = self.CurrentMug.Coffee.Cup

	self._lAttachmentChange = self.CurrentMug.Coffee.Cup.SurfaceAttachment
		:GetPropertyChangedSignal("CFrame")
		:Connect(self._updateWeld)

	self._sound:Play()
end

function MugSurface:detach()
	local char = self._currentOwner.Character
	if not char then
		self:reset(true)
		return
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		self:reset(true)
		return
	end

	hum:EquipTool(self.CurrentMug)
	self.CurrentMug.SetWelded:Fire(true)
	self._weld.Part1 = nil
	self:reset()
end

return MugSurface
