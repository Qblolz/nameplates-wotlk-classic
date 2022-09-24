local totemNpcIDs = {
	-- [npcID] = { spellID, duration }
	[2630] = { 2484, 45 }, -- Earthbind
	[5925] = { 8177, 45 }, -- Grounding
	[3968] = { 6495, 300 }, -- Sentry
	[15430] = { 2062, 120 }, -- Earth Elemental Totem
	[15439] = { 2894, 120 }, -- Fire Elemental Totem
	[15447] = { 3738, 120 }, -- Wrath of Air Totem
	[5913] = { 8143, 300 }, -- Tremor
	[10467] = { 16190, 12 }, -- Mana Tide Totem
}
local function addTotem(data, ...)
	local numArgs = select("#",...)
	for i=1, numArgs do
		local npcID = select(i, ...)
		totemNpcIDs[npcID] = data
	end
end

addTotem({ 30706, 300 }, 17539, 30652, 30653, 30654) -- Totem of Wrath
addTotem({ 5675, 300 }, 3573, 7414, 7415, 7416, 15489, 31186, 31189, 31190) -- Mana Spring Totem
addTotem({ 8187, 20 }, 5929, 7464, 7465, 7466, 15484, 31166, 31167) -- Magma Totem
addTotem({ 3599, 60 }, 2523, 3902, 3903, 3904, 7400, 7402, 15480, 31162, 31164, 31165) -- Searing Totem
addTotem({ 5730, 15 }, 3579, 3911, 3912, 3913, 7398, 7399, 15478, 31120, 31121, 31122) -- Stoneclaw Totem
addTotem({ 8184, 300 }, 5927, 7424, 7425, 15487, 31169, 31170) -- Fire Resistance Totem
addTotem({ 8227, 300 }, 5950, 6012, 7423, 10557, 15485, 31132, 31133, 31158) -- Flametongue Totem
addTotem({ 8181, 300 }, 5926, 7412, 7413, 15486, 31171, 31172) -- Frost Resistance Totem
addTotem({ 10595, 300 }, 7467, 7468, 7469, 15490, 31173, 31174) -- Nature Resistance Totem
addTotem({ 8071, 300 }, 5873, 5919, 5920, 7366, 7367, 7368, 15470, 15474, 31175, 31176) -- Stoneskin Totem
addTotem({ 31634, 300 }, 5874, 5921, 5922, 7403, 15464, 15479, 30647, 31129) -- Strength of Earth
addTotem({ 8512, 300 }, 6112) -- Windfury Totem
addTotem({ 5394, 300 }, 3527, 3906, 3907, 3908, 3909, 15488, 31181, 31181, 31185) -- Healing Stream Totem

local frame = CreateFrame("Frame", nil, UIParent)
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

frame:SetScript("OnEvent", function(self, event, ...)
	return self[event](self, event, ...)
end)

local function GetNPCIDByGUID(guid)
	local _, _, _, _, _, npcID = strsplit("-", guid);
	return tonumber(npcID)
end

local activeTotems = {}

function frame.NAME_PLATE_UNIT_ADDED(self, event, unit)
	local np = C_NamePlate.GetNamePlateForUnit(unit)
	local guid = UnitGUID(unit)
	local npcID = GetNPCIDByGUID(guid)

	if (npcID and totemNpcIDs[npcID]) then
		activeTotems[guid] = np

		if not np.customIcon then
			np.customIcon = np:CreateTexture(nil, "BACKGROUND")
			np.customIcon:SetWidth(32 * 0.7)
			np.customIcon:SetHeight(32 * 0.7)
		end

		local totemData = totemNpcIDs[npcID]
		local spellID, duration = unpack(totemData)

		np.customIcon:ClearAllPoints()
		np.customIcon:SetPoint("CENTER", np, "CENTER", 0, -30)
		np.customIcon:SetTexture(GetSpellTexture(spellID))

		np.customIcon:Show()

		np.UnitFrame:Hide()
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