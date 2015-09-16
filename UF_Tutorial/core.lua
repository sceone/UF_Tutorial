-- Step I : UnitButton
local f = CreateFrame("Button", "UFT_Target", UIParent, "SecureUnitButtonTemplate")
f:SetAttribute("unit", "target")
f:RegisterForClicks("anyup")
f:SetAttribute("*type1", "target")
f:SetAttribute("*type2", "togglemenu")
f.unit = "target"
f:SetScript("OnEnter", UnitFrame_OnEnter)
f:SetScript("OnLeave", UnitFrame_OnLeave)

RegisterUnitWatch(f)

-- Step II : Style
f:SetPoint("CENTER", UIParent, "TOP", 0, -150)
f:SetFrameStrata("LOW")
f:SetWidth(250)
f:SetHeight(36)

f:SetBackdrop({
	bgFile = "Interface\\CHATFRAME\\CHATFRAMEBACKGROUND",
	tile = true,
	tileSize = 16
})
f:SetBackdropColor(.1, .1, .1, .7)

f.Health = CreateFrame("StatusBar", nil, f)
f.Health:SetPoint("TOPLEFT")
f.Health:SetPoint("TOPRIGHT")
f.Health:SetHeight(28)
f.Health:SetFrameStrata("LOW")
f.Health:SetStatusBarTexture("Interface\\RAIDFRAME\\Raid-Bar-Hp-Fill")

f.Power = CreateFrame("StatusBar", nil, f)
f.Power:SetPoint("TOPLEFT", f.Health, "BOTTOMLEFT", 0, -1)
f.Power:SetPoint("BOTTOMRIGHT")
f.Power:SetFrameStrata("LOW")
f.Power:SetStatusBarTexture("Interface\\BUTTONS\\GreyscaleRamp64")

f.Health.Value = f.Health:CreateFontString(nil, "OVERLAY")
f.Health.Value:SetFont("Fonts\\2002.TTF", 11, "OUTLINE")
f.Health.Value:SetTextColor(.9, .8, .5)
f.Health.Value:SetPoint("RIGHT", -6, 0)

f.Name = f.Health:CreateFontString(nil, "OVERLAY")
f.Name:SetFont("Fonts\\2002.TTF", 14, "OUTLINE")
f.Name:SetPoint("LEFT", 8, 0)


-- Step III : Event Handling
local function SetUnit(self)
	local unit = self.unit
	if not UnitExists(unit) then return end
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		self.Health:SetStatusBarColor(RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b)
	else
		self.Health:SetStatusBarColor(1, .8, 0)
	end
	
	local name = GetUnitName(unit)
	self.Name:SetText(name)
	
	local powerType = UnitPowerType(unit)
	local info = PowerBarColor[powerType] or PowerBarColor["MANA"]
	self.Power:SetStatusBarColor(info.r, info.g, info.b, 1)
end

local function UpdateText(self, val)
	if not val then return end
	
	self.Health.Value:SetText(BreakUpLargeNumbers(val))
end

local function UpdateHealth(self)
	local unit = self.unit
	if not UnitExists(unit) then return end

	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	self.Health:SetMinMaxValues(0, max)
	self.Health:SetValue(min)
	
	UpdateText(self, min)
end

local function UpdatePower(self)
	local unit = self.unit
	if not UnitExists(unit) then return end
	
	local type = UnitPowerType(unit)
	local min, MAX = UnitPower(unit, type), UnitPowerMax(unit, type)
	self.Power:SetMinMaxValues(0, max(1, MAX))
	self.Power:SetValue(min)
end

f:RegisterEvent("PLAYER_FOCUS_CHANGED")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", f.unit)
f:RegisterUnitEvent("UNIT_POWER_FREQUENT", f.unit)
f:SetScript("OnEvent", function(self, event)
	if event == "UNIT_HEALTH" or event == "UNIT_HEALTH_FREQUENT" then
		UpdateHealth(self)
	elseif event == "PLAYER_FOCUS_CHANGED" or event == "PLAYER_TARGET_CHANGED" then
		SetUnit(self)
		UpdateHealth(self)
		UpdatePower(self)
	elseif event == "UNIT_POWER" or event == "UNIT_POWER_FREQUENT" then
		UpdatePower(self)
	end
end)
