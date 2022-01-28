---
-- SpecialDialogues.lua - Chat sound handler
--

local module = {}

local DEBRIS = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")

local alphabet = {
	a = "rbxassetid://6467913316",
	b = "rbxassetid://6467913731",
	c = "rbxassetid://6467913902",
	d = "rbxassetid://6467914139",
	e = "rbxassetid://6467914458",
	v = "rbxassetid://6467914458",
	g = "rbxassetid://6467914139",
	z = "rbxassetid://6467913902",
	f = "rbxassetid://6467914636",
	h = "rbxassetid://6467914848",
	i = "rbxassetid://6467915181",
	j = "rbxassetid://6467915383",
	k = "rbxassetid://6467915567",
	l = "rbxassetid://6467916088",
	m = "rbxassetid://6467916506",
	n = "rbxassetid://6467916506",
	o = "rbxassetid://6467916807",
	p = "rbxassetid://6467916994",
	q = "rbxassetid://6467917172",
	r = "rbxassetid://6467917432",
	s = "rbxassetid://6467920697",
	x = "rbxassetid://6467920697",
	t = "rbxassetid://6467920914",
	u = "rbxassetid://6467921079",
	w = "rbxassetid://6467921260",
	y = "rbxassetid://6467921438",
}

local symbols = {
	alphabet.m,
	alphabet.n,
	alphabet.o,
	alphabet.p,
	alphabet.q,
	alphabet.r,
	alphabet.s,
	alphabet.x,
	alphabet.t,
	alphabet.u,
	alphabet.w,
	alphabet.y,
}

local pitches = {
	Low = 1.1,
	Base = 1.25,
	High = 1.4,
	Amogus = 0.55,
	Serball = 1.9,
}

local nipah = {
	"rbxassetid://6597172405",
	"rbxassetid://6597095839",
	"rbxassetid://6597095898",
}

local spoonful = {
	"rbxassetid://7829037435",
	"rbxassetid://7829037326",
	"rbxassetid://7829037178",
}

local function playSound(character, id, vol, speed, min, max)
	speed = speed or (1 + Random.new():NextNumber(-0.05, 0.05))
	min = min or 10
	max = max or 300

	local sfx = Instance.new("Sound")
	sfx.SoundId = id
	sfx.Volume = vol
	sfx.RollOffMinDistance = min
	sfx.RollOffMaxDistance = max
	sfx.PlaybackSpeed = speed
	sfx.Parent = character.Head.Head
	sfx:Play()
	DEBRIS:AddItem(sfx, 2)
end

local dialogues = {}

local function setDecalsTransparency(inst, transparency)
	for _, desc in pairs(inst:GetDescendants()) do
		if desc:IsA("Decal") then
			desc.Transparency = transparency
		end
	end
end

function dialogues.Rika(character, chatText, exclaim)
	if chatText:lower():match("nipah") or chatText:match("\227\129\171\227\129\177") then
		coroutine.wrap(function()
			local headNipah = character.CreateFolder:FindFirstChild("HeadNipah")
			if not headNipah then
				return
			end

			headNipah = headNipah.HeadNipah

			local headHead = character.Head.Head

			headHead.Transparency = 1
			setDecalsTransparency(headHead, 1)

			headNipah.Transparency = 0
			setDecalsTransparency(headNipah, 0)

			wait(3)

			headHead.Transparency = 0
			setDecalsTransparency(headHead, 0)

			headNipah.Transparency = 1
			setDecalsTransparency(headNipah, 1)
		end)()

		playSound(character, nipah[math.random(1, #nipah)], 0.7, 1, 10, 550)

		return true
	end

	return false
end

function dialogues.Dog(character, chatText, exclaim)
	local result = false

	if chatText:lower():match("awoo") or chatText:match("\227\130\162\227\130\166") then
		local speed = pitches[character.VoicePitch.Value] - 0.25 + Random.new():NextNumber(-0.05, 0.05)
		playSound(character, "rbxassetid://6659426377", 0.2, speed)

		result = true
	end

	if chatText:lower():match("wan") or chatText:match("\227\131\175\227\131\179") then
		local speed = pitches[character.VoicePitch.Value] - 0.3 + Random.new():NextNumber(-0.05, 0.05)
		playSound(character, "rbxassetid://6659426307", 0.4, speed, 10, 550)

		result = true
	end

	return result
end

function dialogues.Mukyu(character, chatText, exclaim)
	if chatText:lower():match("mukyu") or chatText:match("\227\131\160\227\130\175\227\131\165") then
		playSound(character, "rbxassetid://6689920558", 0.2)
		return true
	end

	return false
end

function dialogues.Serval(character, chatText, exclaim)
	if chatText:lower():match("sugoi") or chatText:match("\227\129\153\227\129\148\227\129\132") then
		playSound(character, "rbxassetid://7118237673", 0.13)
		return true
	end

	return false
end

function dialogues.MAGES(character, chatText, exclaim)
	if
		chatText:lower():match("wake up")
		or chatText:match("\231\155\174\227\130\146\232\166\154\227\129\190\227\129\153")
	then
		playSound(character, "rbxassetid://7118257163", 0.5)
		return true
	end

	return false
end

function dialogues.Tanya(character, chatText, exclaim)
	if chatText:lower():match("kami") or chatText:match("\231\165\158") then
		playSound(character, "rbxassetid://7119290973", 0.15)
		return true
	end

	return false
end

function dialogues.Rat(character, chatText, exclaim)
	if
		chatText:lower():match("naides")
		or chatText:match("\227\129\170\227\129\132\227\129\167\227\129\153")
		or chatText:lower():match("naidesu")
	then
		playSound(character, "rbxassetid://7122812805", 0.25)
		return true
	end

	return false
end

local bankiHead = {}

local function createEffectHead(character)
	local head = character.Head.Head:Clone()
	local createFolder = character.CreateFolder

	local models = { character.Head }

	for _, v in pairs(createFolder:GetDescendants()) do
		if v:GetAttribute("WeldTarget") == "Head" then
			local model = v:Clone()
			model.RootWeld.Part0 = head
			model.RootWeld.Part1 = model.PrimaryPart
			model.Parent = head

			models[#models + 1] = v
		end
	end

	local tag = head:FindFirstChild("NameTag")
	if tag then
		tag:Destroy()
	end

	local bubble = head:FindFirstChild("ChatBubble")
	if bubble then
		bubble:Destroy()
	end

	PhysicsService:SetPartCollisionGroup(head, "CollDisabled")
	head.CanCollide = true

	return head, models
end

function dialogues.Sekibanki(character, chatText, exclaim)
	if bankiHead[character] then
		return false
	end

	if chatText:lower():match("head") or chatText:match("\233\160\173") then
		coroutine.wrap(function()
			bankiHead[character] = true

			local effectHead, models = createEffectHead(character)
			local touchedParts = {}

			for _, model in pairs(models) do
				for _, descendant in pairs(model:GetDescendants()) do
					if descendant:IsA("BasePart") then
						descendant:SetAttribute("lastSize", descendant.Size)
						descendant:SetAttribute("lastTransparency", descendant.Transparency)

						descendant.Size = Vector3.new(0, 0, 0)
						descendant.Transparency = 1

						touchedParts[#touchedParts + 1] = descendant
					end
				end
			end

			effectHead.CFrame = character.Head.Head.CFrame
			effectHead.Parent = game.Workspace
			DEBRIS:AddItem(effectHead, 5)

			wait(5)
			if not character then
				bankiHead[character] = nil
				return
			end

			for k, descendant in pairs(touchedParts) do
				descendant.Size = descendant:GetAttribute("lastSize")
				descendant.Transparency = descendant:GetAttribute("lastTransparency")
			end

			local headFX = character.CreateFolder:FindFirstChild("headFX")

			if headFX then
				headFX = headFX.headFX
				headFX.s1:Play()
				headFX.p1:Emit(10)
			end

			wait(0.5)
			bankiHead[character] = nil
		end)()
	end

	return false
end

function dialogues.Cirno(character, chatText, exclaim)
	if chatText:lower():match("baka") or chatText:match("\233\166\172\233\185\191") then
		playSound(character, "rbxassetid://7133976089", 0.3)
		return true
	end

	return false
end

function dialogues.Rumia(character, chatText, exclaim)
	if
		chatText:lower():match("so nanoka")
		or chatText:match("\227\129\157\227\131\188\227\129\170\227\129\174\227\129\139\227\131\188")
	then
		playSound(character, "rbxassetid://7133986095", 0.2)
		return true
	end

	return false
end

function dialogues.Cat(character, chatText, exclaim)
	if
		chatText:lower():match("nya")
		or chatText:lower():match("meow")
		or chatText:match("\227\131\139\227\131\163")
	then
		playSound(character, "rbxassetid://7133989059", 0.12)
		return true
	end

	return false
end

function dialogues.Madotsuki(character, chatText, exclaim)
	if
		chatText:lower():match("no good")
		or chatText:match("\227\129\160\227\130\129")
		or chatText:match("\227\131\128\227\131\161")
	then
		playSound(character, "rbxassetid://7139231500", 0.12)
		return true
	elseif chatText:lower():match("impossible") or chatText:match("\231\132\161\231\144\134") then
		playSound(character, "rbxassetid://7139231572", 0.12)
		return true
	end

	return false
end

function dialogues.Ari(character, chatText, exclaim)
	if chatText:lower():match("burger") then
		playSound(character, "rbxassetid://7142972264", 0.4)
		return true
	elseif chatText:lower():match("buh") then
		playSound(character, "rbxassetid://7142972323", 1.6)
		return true
	end

	return false
end

function dialogues.Doremy(character, chatText, exclaim)
	if chatText:lower():match("buh") then
		playSound(character, "rbxassetid://7142972323", 1.6)
		return true
	end

	return false
end

function dialogues.LittleNazrin(character, chatText, exclaim)
	if
		chatText:lower():match("naides")
		or chatText:match("\227\129\170\227\129\132\227\129\167\227\129\153")
		or chatText:lower():match("naidesu")
	then
		playSound(character, "rbxassetid://7122812805", 0.25)
		return true
	elseif
		chatText:lower():match("welcome home") or chatText:match("\227\129\138\227\129\139\227\129\136\227\130\138")
	then
		playSound(character, "rbxassetid://7162911891", 0.2)
		return true
	end

	return false
end

function dialogues.Sachiko(character, chatText, exclaim)
	if chatText:lower():match("okay") then
		playSound(character, "rbxassetid://7162928158", 0.3)
		return true
	end

	return false
end

function dialogues.Amogus(character, chatText, exclaim)
	if chatText:lower():match("amogus") or chatText:lower():match("among us") then
		playSound(character, "rbxassetid://7163204696", 0.15)
		return true
	end

	return false
end

function dialogues.Serball(character, chatText, exclaim)
	if chatText:lower():match("sugoi") or chatText:match("\227\129\153\227\129\148\227\129\132") then
		local speed = 1.9 + Random.new():NextNumber(-0.05, 0.05)
		playSound(character, "rbxassetid://7118237673", 0.13, speed)

		return true
	end

	return false
end

function dialogues.Yoshika(character, chatText, exclaim)
	if
		chatText:lower():match("gwa gwa")
		or chatText:lower():match("\227\130\176\227\130\161 \227\130\176\227\130\161")
	then
		playSound(character, "rbxassetid://7179802622", 0.12)
		return true
	end

	return false
end

function dialogues.Yacchie(character, chatText, exclaim)
	if
		chatText:lower():match("gao gao")
		or chatText:match("\227\130\172\227\130\170 \227\130\172\227\130\170\227\131\188")
	then
		playSound(character, "rbxassetid://7183016670", 0.12)
		return true
	end

	return false
end

function dialogues.Rei(character, chatText, exclaim)
	if chatText:lower():match("rei chiquita") then
		playSound(character, "rbxassetid://7519954053", 0.3)
		return true
	end

	return false
end

function dialogues.Soku(character, chatText, exclaim)
	local volume = 0.3
	if exclaim then
		volume = 1
	end

	if chatText:lower():match("soku") then
		playSound(character, "rbxassetid://7791781630", volume)

		return true
	elseif chatText:lower():match("ay yo catgirl") then
		playSound(character, "rbxassetid://7791939510", volume)

		return true
	end

	return false
end

function dialogues.Yuuma(character, chatText, exclaim)
	if chatText:lower():match("only a spoonful") then
		playSound(character, spoonful[math.random(1, #spoonful)], 0.5, nil, 10, 230)
		return true
	elseif chatText:lower():match("*scream*") then
		playSound(character, "rbxassetid://7829191336", 0.3, nil, 10, 170)

		return true
	end

	return false
end

function module:doSound(character, letter, exclaim)
	if not character then
		return
	end

	local addPitch = 0
	if exclaim then
		addPitch = 0.04
	end

	local soundId = alphabet[letter:lower()]
	local sfx = Instance.new("Sound")

	if soundId then
		sfx.SoundId = soundId
	else
		sfx.SoundId = symbols[math.random(1, #symbols)]
	end
	sfx.Volume = 1.8
	sfx.RollOffMinDistance = 1
	sfx.Parent = character.Head.Head

	local pitchValue = character:FindFirstChild("VoicePitch")
	if pitchValue and pitches[pitchValue.Value] then
		sfx.PlaybackSpeed = pitches[pitchValue.Value] + Random.new():NextNumber(-0.05, 0.05) + addPitch
	else
		sfx.PlaybackSpeed = Random.new():NextNumber(0.97, 1.07) + addPitch
	end

	sfx:Play()
	DEBRIS:AddItem(sfx, 0.5)
end

function module:CheckDialogue(dialogueName)
	return dialogues[dialogueName] ~= nil
end

function module:SpecialDialogue(character, chatText, exclaim, dialogueName)
	if not character then
		return false
	end
	return dialogues[dialogueName](character, chatText, exclaim)
end

return module
