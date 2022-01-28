---
-- ClientUtils.lua - Client Utilities
--

local ClientUtils = {}

function ClientUtils.raycast(pos, params)
	local unitRay = workspace.CurrentCamera:ScreenPointToRay(pos.X, pos.Y)
	local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)

	return result
end

function ClientUtils.playNoteSample(soundPool, code)
	local note = (code - 1) % 12
	local sampleIdx = math.floor(note / 2)
	local octave = math.floor((code - 1) / 12)

	local sound = soundPool:getSound(sampleIdx + 1)
	if not sound then
		return
	end

	sound.TimePosition = 16 * octave + 8 * (note % 2)
	sound:Play()

	delay(4, function()
		sound:Stop()
	end)
end

return ClientUtils
