---
-- PostProcessor.lua - Appearance modification post processor
--

local PostProcessor = {}

local kDialogueParts = {
	Rika = "HeadNipah",
	Sekibanki = "headFX",
}

function PostProcessor.optionChanged(app, option, prev, new)
	if option == "Dialogue" then
        local needsSave = false

		-- Auto-detach
		if kDialogueParts[prev] then
			app:save(kDialogueParts[prev], false)
            needsSave = true
		end

		-- Auto-attach
		if kDialogueParts[new] then
			app:save(kDialogueParts[new], true)
            needsSave = true
		end

        if needsSave then
            app:fireUpdate()
        end
	end
end

return PostProcessor
