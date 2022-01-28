---
-- KeyboardUtils.lua - Utilities for keyboard visualization
--

local KeyboardUtils = {
	KeyboardData = {},
}

local kOctaves = { "1", "2", "3", "4", "5", "6" }
local kNotes = { "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" }

function KeyboardUtils.load(kbd)
	if KeyboardUtils.KeyboardData[kbd] then
		return
	end

	local keyboardData = {}

	for _, octaveName in ipairs(kOctaves) do
		local octave = kbd[octaveName]

		for _, note in ipairs(kNotes) do
			local notePart = octave:FindFirstChild(note)
			if not notePart then
				break
			end

			keyboardData[#keyboardData + 1] = notePart
		end
	end

	KeyboardUtils.KeyboardData[kbd] = keyboardData
end

function KeyboardUtils.pressNote(kbd, note)
	local kbdData = KeyboardUtils.KeyboardData[kbd]
	if not kbdData then
		return
	end

	local notePart = kbdData[note]
	notePart.Mesh.Offset = Vector3.new(0, -0.05, 0)

	delay(0.1, function()
		notePart.Mesh.Offset = Vector3.new(0, 0, 0)
	end)
end

return KeyboardUtils
