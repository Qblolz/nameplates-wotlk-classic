local addonName, ns = ...

local totemNpcIDs = {}
local function addTotem(spellID, showName, shorterName, showIcon, showNameplate, ...)
	local numArgs = select("#",...)
	for i=1, numArgs do
		local npcID = select(i, ...)
		totemNpcIDs[npcID] = { spellID, showName, shorterName, showIcon, showNameplate }
	end
end


-- first argument - spellID
-- second argument - show name (true|false)
-- third argument - shorterName (
-- four argument - show icon (true|false)
-- five argument - show nameplate (true|false)
-- after, five argument and ect. - npcID
-- addTotem(2630,true, "DICK", true, false, 25142) 	-- test - shattrat city
addTotem(2484,false, nil, false, false, 2630) 	-- Earthbind
addTotem(54968,false, nil, false, false, 5924) 	-- Cleansing
addTotem(5925, false, nil, true, false, 5925) 	-- Grounding
addTotem(3968, false, nil, false, false, 3968) 	-- Sentry
addTotem(5913, false, nil, true, false, 5913) 	-- Tremor
addTotem(8512, false, nil, false, false, 6112) 	-- Windfury Totem
addTotem(15430, false, nil, false, false, 15430) 	-- Earth Elemental Totem
addTotem(15439, false, nil, false, false, 15439) 	-- Fire Elemental Totem
addTotem(15447, false, nil, false, false, 15447) 	-- Wrath of Air Totem
addTotem(10467, false, nil, true, false, 10467) 	-- Mana Tide Totem
addTotem(30706, false, nil, false, false, 17539, 30652, 30653, 30654) 	-- Totem of Wrath
addTotem(8181, false,  nil, false, false,5926, 7412, 7413, 15486, 31171, 31172) -- Frost Resistance Totem
addTotem(8184, false, nil, false, false, 5927, 7424, 7425, 15487, 31169, 31170) -- Fire Resistance Totem
addTotem(10595, false, nil, false, false, 7467, 7468, 7469, 15490, 31173, 31174) 	-- Nature Resistance Totem
addTotem(8187, false, nil, false, false, 5929, 7464, 7465, 7466, 15484, 31166, 31167) 	-- Magma Totem
addTotem(5675, false, nil, false, false, 3573, 7414, 7415, 7416, 15489, 31186, 31189, 31190) 	-- Mana Spring Totem
addTotem(31634, false, nil, false, false, 5874, 5921, 5922, 7403, 15464, 15479, 30647, 31129) 	-- Strength of Earth
addTotem(8227, false, nil, false, false, 5950, 6012, 7423, 10557, 15485, 31132, 31133, 31158) 	-- Flametongue Totem
addTotem(5394, false, nil, false, false, 3527, 3906, 3907, 3908, 3909, 15488, 31181, 31181, 31185) 	-- Healing Stream Totem
addTotem(3599, false, nil, false, false, 2523, 3902, 3903, 3904, 7400, 7402, 15480, 31162, 31164, 31165) 	-- Searing Totem
addTotem(5730, false,  nil, false, false, 3579, 3911, 3912, 3913, 7398, 7399, 15478, 31120, 31121, 31122) 	-- Stoneclaw Totem
addTotem(8071, false, nil, false, false, 5873, 5919, 5920, 7366, 7367, 7368, 15470, 15474, 31175, 31176) 	-- Stoneskin Totem

local frame = CreateFrame("Frame", nil, UIParent)
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
	return self[event](self, event, ...)
end)

local defaults = {size = 48}
local db

local function GetNPCIDByGUID(guid)
	local _, _, _, _, _, npcID = strsplit("-", guid);

	return tonumber(npcID)
end

local activeTotems = {}

function frame.UPDATE_MOUSEOVER_UNIT(self, event)
	local np = C_NamePlate.GetNamePlateForUnit("mouseover")

	if np == nil then return end

	local guid = UnitGUID("mouseover")
	local npcID = GetNPCIDByGUID(guid)

	if (npcID and totemNpcIDs[npcID]) then
		if np.UnitFrame.customName then
			np.UnitFrame.name:Hide()
		end
	end
end
function frame.NAME_PLATE_UNIT_ADDED(self, event, unit)
	local np = C_NamePlate.GetNamePlateForUnit(unit)
	local guid = UnitGUID(unit)
	local npcID = GetNPCIDByGUID(guid)

	if (npcID and totemNpcIDs[npcID]) then
		activeTotems[guid] = np

		local totemData = totemNpcIDs[npcID]
		local spellID, showName, shorterName, showIcon, showNameplate = unpack(totemData)

		if false == showName then
			np.UnitFrame.name:Hide()
		end

		if true == showName and nil ~= shorterName then
			np.UnitFrame.customName = np.UnitFrame:CreateFontString()
			np.UnitFrame.customName:SetFont(np.UnitFrame.name:GetFont())
			np.UnitFrame.customName:SetText(tostring(shorterName))
			np.UnitFrame.customName:SetAllPoints(np.UnitFrame.name)
			np.UnitFrame.name:Hide()
		end

		if false == showNameplate then
			np.UnitFrame.healthBar:Hide()
			np.UnitFrame.CastBar:Hide()
			np.UnitFrame.RaidTargetFrame:Hide()
			np.UnitFrame.LevelFrame:Hide()
			np.UnitFrame.selectionHighlight:Hide()
		end

		if true == showIcon then
			if not np.customIcon then
				np.customIcon = np:CreateTexture(nil, "BACKGROUND")
				np.customIcon:SetWidth(db.size)
				np.customIcon:SetHeight(db.size)
			end

			if np.UnitFrame.customName then
				np.UnitFrame.customName:ClearAllPoints()
				np.UnitFrame.customName:SetPoint("CENTER", np, "CENTER", 0, (db.size / 2) + 10)
			else
				np.UnitFrame.name:ClearAllPoints()
				np.UnitFrame.name:SetPoint("CENTER", np, "CENTER", 0, (db.size / 2) + 10)
			end

			np.customIcon:ClearAllPoints()
			np.customIcon:SetPoint("CENTER", np, "CENTER", 0, 0)
			np.customIcon:SetTexture(GetSpellTexture(spellID))
			np.customIcon:Show()
		end

		np.UnitFrame:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
		np.UnitFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
	end

	if np.UnitFrame.customName then
		np.UnitFrame.customName:ClearAllPoints()
		np.UnitFrame.customName:SetPoint("BOTTOM", np.UnitFrame.healthBar.border, "TOP", 0, 2)
	else
		np.UnitFrame.name:ClearAllPoints()
		np.UnitFrame.name:SetPoint("BOTTOM", np.UnitFrame.healthBar.border, "TOP", 0, 2)
	end
end

function frame.NAME_PLATE_UNIT_REMOVED(self, event, unit)
	local np = C_NamePlate.GetNamePlateForUnit(unit)
	if np.customIcon then
		np.customIcon:Hide()

		local guid = UnitGUID(unit)
		activeTotems[guid] = nil
	end
end

function frame.PLAYER_LOGIN(self)
	_G.TotemNameplatesDB = _G.TotemNameplatesDB or {}
	db = _G.TotemNameplatesDB
	ns.SetupDefaults(_G.TotemNameplatesDB, defaults)

	SLASH_TOTEMNAMEPLATES1= "/totemnp"
	SLASH_TOTEMNAMEPLATES2= "/tnp"
	SlashCmdList["TOTEMNAMEPLATES"] = self.SlashCmd
end

local ParseOpts = function(str)
	local t = {}
	local capture = function(k,v)
		t[k:lower()] = tonumber(v) or v
		return ""
	end
	str:gsub("(%w+)%s*=%s*%[%[(.-)%]%]", capture):gsub("(%w+)%s*=%s*(%S+)", capture)
	return t
end

frame.Commands = {
	["size"] = function(v)
		local newSize = tonumber(v)
		if newSize then
			db.size = newSize
		end
	end
}

function frame.SlashCmd(msg)
	local helpMessage = {
		"|cff00ffbb/nti size 63|r",
	}

	local k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
	if not k or k == "help" then
		print("Usage:")
		for k,v in ipairs(helpMessage) do
			print(" - ",v)
		end
	end
	if frame.Commands[k] then
		frame.Commands[k](v)
	end
end

function ns.SetupDefaults(t, defaults)
	if not defaults then return end
	for k,v in pairs(defaults) do
		if type(v) == "table" then
			if t[k] == nil then
				t[k] = CopyTable(v)
			elseif t[k] == false then
				t[k] = false --pass
			else
				ns.SetupDefaults(t[k], v)
			end
		else
			if t[k] == nil then t[k] = v end
		end
	end
end

function ns.RemoveDefaults(t, defaults)
	if not defaults then return end
	for k, v in pairs(defaults) do
		if type(t[k]) == 'table' and type(v) == 'table' then
			ns.RemoveDefaults(t[k], v)
			if next(t[k]) == nil then
				t[k] = nil
			end
		elseif t[k] == v then
			t[k] = nil
		end
	end
	return t
end