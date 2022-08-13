local path = {
	Ammo={

	},
	Bored={

	},
	Bye={
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Bye\\Kira_Bye_Quiet_01.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Bye\\Kira_Bye_Quiet_03.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Bye\\Kira_Bye_Quiet_05.ogg",
	},
	Greatest={

	},
	Hi={
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Hi\\Kira_Hi_Quiet_01.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Hi\\Kira_Hi_Quiet_02.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Hi\\Kira_Hi_Quiet_03.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Hi\\Kira_Hi_Quiet_06.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Hi\\Kira_Hi_Quiet_07.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Hi\\Kira_Hi_Quiet_08.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Hi\\Kira_Hi_Quiet_09.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Hi\\Kira_Hi_Quiet_10.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Hi\\Kira_Taunt_35_Quiet_01.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Hi\\Kira_Taunt_SpawnGreeting_01.ogg",
	},
	LowHp={

	},
	Melee={

	},
	Outranged={
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Outranged\\Kira_Incoming_Quiet_02.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Outranged\\Kira_Lets_Go_Quiet_01.ogg",
	},
	PetFeed={
		"Interface\\AddOns\\QuiverSounds\\Sounds\\PetFeed\\Kira_Taunt_40_Quiet_01.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\PetFeed\\Kira_Taunt_47_Quiet_01.ogg",
	},
	PetHungry={
		"Interface\\AddOns\\QuiverSounds\\Sounds\\PetHungry\\Kira_Yeah_Quiet_02.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\PetHungry\\Kira_Yeah_Quiet_03.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\PetHungry\\Kira_Taunt_Sarcastic_03.ogg",
	},
	Respawn={
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Respawn\\Kira_Respawn_Quiet_01.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Respawn\\Kira_Respawn_Quiet_02.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Respawn\\Kira_Respawn_Quiet_04.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Respawn\\Kira_Respawn_Quiet_05.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Respawn\\Kira_Respawn_Quiet_06.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Respawn\\Kira_Respawn_Quiet_07.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Respawn\\Kira_Respawn_Quiet_08.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Respawn\\Kira_Respawn_Quiet_09.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Respawn\\Kira_Respawn_Quiet_10.ogg",
		"Interface\\AddOns\\QuiverSounds\\Sounds\\Respawn\\Kira_Respawn_Quiet_11.ogg",
	},
	Revived={

	},
	ScareBeast={
		"Interface\\AddOns\\QuiverSounds\\Sounds\\ScareBeast\\Kira_Enemy_Weak_Medium_03.ogg",
	},
}


local HAPPINESS = { Sad=1, Neutral=2, Happy=3 }

local pet = (function()
	local exists = false
	local isAlive = false
	local happiness = nil

	local checkExists = function()
		local existsOld = exists
		exists = UnitIsVisible("pet")
		return exists, existsOld ~= exists
	end

	local checkAlive = function()
		local oldAlive = isAlive
		isAlive = not UnitIsDead("pet")
		-- TODO outrange requires current alive state
		-- death might require a visible check first
		--if UnitIsVisible("pet") then isAlive = not UnitIsDead("pet") end
		return isAlive, isAlive ~= oldAlive
	end

	local checkHappinessDrop = function()
		local oldHappiness = happiness
		happiness, _, _ = GetPetHappiness()
		local isDroppedToNetural =
			oldHappiness == HAPPINESS.Happy
			and happiness == HAPPINESS.Neutral
		local isDroppedToSad =
			oldHappiness == HAPPINESS.Neutral
			and happiness == HAPPINESS.Sad
		return not UnitIsDead("pet")
			and (isDroppedToNetural or isDroppedToSad)
	end

	return {
		CheckHappinessDrop=checkHappinessDrop,
		CheckExists = checkExists,
		CheckAlive = checkAlive,
	}
end)()

-- ************ Event Handlers ************
local playRandSound = function(sounds)
	local numSounds = table.getn(sounds)
	local index = math.random(1, numSounds)
	PlaySoundFile(sounds[index])
end

local handleOutrange = function(exists, existChanged, isAlive)
	if exists or not existChanged then
	-- This triggers on Call Pet, but also from hitting a load screen
	-- Check pet no longer exists to avoid false positives
		return
	elseif isAlive then
	-- Outranged a living pet
		return playRandSound(path.Follow)
	else
	-- Outranged a dead pet
		return DEFAULT_CHAT_FRAME:AddMessage("Outranged a dead pet.")
	end
end

local handleCallPet = function(isAlive)
	if isAlive then
		return playRandSound(path.Hi)
	else
		return DEFAULT_CHAT_FRAME:AddMessage("Called a dead pet!")
	end
end

local handleDismissPet = function(isAlive)
	if isAlive then
		playRandSound(path.Bye)
	else
		DEFAULT_CHAT_FRAME:AddMessage("Dismissed a dead pet.")
	end
end

local handleHappinessReviveDeath = function(alive, aliveChanged, isDropHappiness)
	if aliveChanged then
		if alive then
			return playRandSound(path.Respawn)
		else
			return DEFAULT_CHAT_FRAME:AddMessage("Oh no, pet died!")
		end
	elseif isDropHappiness then
		DEFAULT_CHAT_FRAME:AddMessage("Pet Happiness dropped")
		return playRandSound(path.PetHungry)
	end
end

-- "Your <name> is dismissed."
local parsePetDismissed = function(t) return string.find(t, "Your ") and string.find(t, " is dismissed.") end
local parseFeedPet = function(t) return string.find(t, " gains Feed Pet Effect.") end
local parseCallPet = function(t) return string.find(t, "You perform Call Pet.") end

--[[
Some event handlers need to know previous pet state:
- Happiness change needs to know if pet died/revived
- Dismiss needs to know if pet outranged or dead
Therefore, we update state even on events that don't need state.
]]
local isEventHandled = false
-- UNIT_PET Fires twice on summon/dismiss. Can check combat log in between.
local unitPetEventCount = 0
local handleEvent = function()
	-- Init State
	if event == "PLAYER_LOGIN" then
		pet.CheckExists()
		pet.CheckAlive()
	-- Dismiss Pet
	elseif event == "CHAT_MSG_COMBAT_MISC_INFO" then
		DEFAULT_CHAT_FRAME:AddMessage(event)
		isEventHandled = true
		local _, _ = pet.CheckExists()
		local isAlive, _ = pet.CheckAlive()
		if parsePetDismissed(arg1) then handleDismissPet(isAlive) end
	-- Call Pet
	elseif event == "CHAT_MSG_SPELL_SELF_BUFF" then
		DEFAULT_CHAT_FRAME:AddMessage(event)
		isEventHandled = true
		local _, _ = pet.CheckExists()
		local isAlive, _ = pet.CheckAlive()
		if parseCallPet(arg1) then handleCallPet(isAlive) end
	-- Feed Pet
	elseif event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then
		if parseFeedPet(arg1) then playRandSound(path.PetFeed) end
	-- Dismiss Pet
	elseif event == "UNIT_PET" then
		DEFAULT_CHAT_FRAME:AddMessage(event)
		unitPetEventCount = unitPetEventCount + 1
		if unitPetEventCount >= 2 then
			if not isEventHandled then
				local exists, existChanged = pet.CheckExists()
				local isAlive, _ = pet.CheckAlive()
				handleOutrange(exists, existChanged, isAlive)
			end
			unitPetEventCount = 0
			isEventHandled = false
		end
	-- Revive Pet, Pet Death, or Pet Happiness
	elseif event == "UNIT_FOCUS" or event == "UNIT_HAPPINESS" then
		local exists, _ = pet.CheckExists()
		if exists then
			local alive, aliveChanged = pet.CheckAlive()
			local isDropHappiness = pet.CheckHappinessDrop()
			handleHappinessReviveDeath(alive, aliveChanged, isDropHappiness)
		end
	end
end

-- ************ Initialization ************
local EVENTS = {
	"PLAYER_LOGIN",-- Init
	"CHAT_MSG_COMBAT_MISC_INFO",-- Dismiss Pet
	"CHAT_MSG_SPELL_SELF_BUFF",-- Call Pet
	"CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS",-- Feed Pet
	"UNIT_PET",-- Outrange pet
	"UNIT_HAPPINESS",-- Happiness decay, including Pet Death
	"UNIT_FOCUS",-- Revive Pet
}
local frame = CreateFrame("Frame", nil, UIParent)
frame:Hide()
for _k, e in EVENTS do frame:RegisterEvent(e) end
frame:SetScript("OnEvent", handleEvent)
