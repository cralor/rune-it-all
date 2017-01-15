local _, class = UnitClass("player")
if ( class ~= "DEATHKNIGHT" ) then return end

local name, table = ...
table.ria = table.ria or CreateFrame("Frame", "RIAFrame", UIParent)
local ria = table.ria

local CURRENT_MAX_RUNES = 0
local MAX_RUNE_CAPACITY = 7
local IMAGES_PATH = "Interface\\AddOns\\RuneItAll\\images\\"
local r, o, t, b, cdText = {}, {}, {}, {}, {}

local runeColors = {
	["BLOOD"]  = {1,   0,   0},
	["UNHOLY"] = {0,   0.5, 0},
	["FROST"]  = {0,   1,   1},
	["DEATH"]  = {0.8, 0.1, 1}
}

local iconTextures = {
	["BLOOD"] = {
		["BLIZZARD"] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood.blp",
		["BETA"] = IMAGES_PATH.."beta\\blood.blp",
		["DKI"] = IMAGES_PATH.."DKI\\blood.tga",
		["LETTER"] = IMAGES_PATH.."letter\\blood.tga",
		["ORB"] = IMAGES_PATH.."orb\\blood.tga",
		["ENHANCED"] = IMAGES_PATH.."beta-enhanced\\blood.tga",
		["JAPANESE"] = IMAGES_PATH.."japanese\\blood.tga",
		["RUNICA"] = IMAGES_PATH.."runica\\blood.tga",
		["NEW_BLIZZARD"] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Ring.blp"
	},
	["DEATH"] = {
		["BLIZZARD"] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death.blp",
		["BETA"] = IMAGES_PATH.."beta\\death.blp",
		["DKI"] = IMAGES_PATH.."DKI\\death.tga",
		["LETTER"] = IMAGES_PATH.."letter\\death.tga",
		["ORB"] = IMAGES_PATH.."orb\\death.tga",
		["ENHANCED"] = IMAGES_PATH.."beta-enhanced\\death.tga",
		["JAPANESE"] = IMAGES_PATH.."japanese\\death.tga",
		["RUNICA"] = IMAGES_PATH.."runica\\death.tga",
		["NEW_BLIZZARD"] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Ring.blp"
	},
	["UNHOLY"] = {
		["BLIZZARD"] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy.blp",
		["BETA"] = IMAGES_PATH.."beta\\unholy.blp",
		["DKI"] = IMAGES_PATH.."DKI\\unholy.tga",
		["LETTER"] = IMAGES_PATH.."letter\\unholy.tga",
		["ORB"] = IMAGES_PATH.."orb\\unholy.tga",
		["ENHANCED"] = IMAGES_PATH.."beta-enhanced\\unholy.tga",
		["JAPANESE"] = IMAGES_PATH.."japanese\\unholy.tga",
		["RUNICA"] = IMAGES_PATH.."runica\\unholy.tga",
		["NEW_BLIZZARD"] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Ring.blp"
	},
	["FROST"] = {
		["BLIZZARD"] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost.blp",
		["BETA"] = IMAGES_PATH.."beta\\frost.blp",
		["DKI"] = IMAGES_PATH.."DKI\\frost.tga",
		["LETTER"] = IMAGES_PATH.."letter\\frost.tga",
		["ORB"] = IMAGES_PATH.."orb\\frost.tga",
		["ENHANCED"] = IMAGES_PATH.."beta-enhanced\\frost.tga",
		["JAPANESE"] = IMAGES_PATH.."japanese\\frost.tga",
		["RUNICA"] = IMAGES_PATH.."runica\\frost.tga",
		["NEW_BLIZZARD"] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Ring.blp"
	}
}

local function CreateRuneButtonIndividualFrames()
	for i=1,MAX_RUNE_CAPACITY do
		r[i] = CreateFrame("Button", "RBI"..i, ria)
		r[i]:SetSize(18, 18)

		if i == 1 then
			r[i]:SetPoint("LEFT", ria, "LEFT")
		else
			r[i]:SetPoint("LEFT", r[i-1], "RIGHT", 3, 0)
		end

		t[i] = r[i]:CreateTexture(r[i]:GetName().."Border", "OVERLAY")
		t[i]:SetSize(24, 24)
		t[i]:SetPoint("CENTER", r[i], "CENTER", 0, -1)

		b[i] = r[i]:CreateTexture(r[i]:GetName().."Rune", "ARTWORK")
		b[i]:SetSize(24, 24)
		b[i]:SetPoint("CENTER", r[i], "CENTER", 0, -1)
	end
end

function ria:clear()
	for i=1,MAX_RUNE_CAPACITY do
		r[i]:ClearAllPoints()
	end
end

function ria:alpha(val)
	for i=1,MAX_RUNE_CAPACITY do
		r[i]:SetAlpha(val)
	end
end

function ria:showRunes()
	for i=1,CURRENT_MAX_RUNES do
		r[i]:Show()
	end
end

function ria:hideRunes()
	for i=1,CURRENT_MAX_RUNES do
		r[i]:Hide()
	end
end

function ria:scale(val)
	for i=1,MAX_RUNE_CAPACITY do
		r[i]:SetScale(val)
	end
end

local events = {}
function ria:init()
	CreateRuneButtonIndividualFrames()

	RuneFrame:UnregisterAllEvents()
	RuneFrame:EnableMouse(false)
	RuneFrame:SetAlpha(0)
	RuneFrame:Hide()

	for i = 1,MAX_RUNE_CAPACITY do
		r[i]:SetClampedToScreen(true)
		r[i]:SetFrameStrata("LOW")
		r[i]:EnableMouse(false)
		r[i]:Show()
		t[i]:Show()

		local old = _G["RuneButtonIndividual"..i]
		old:Hide()
		old:EnableMouse(false)
		old:UnregisterAllEvents()

		cdText[i] = ria:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		cdText[i]:SetPoint("CENTER", r[i])
		cdText[i]:SetAlpha(1)
		cdText[i]:Show()
	end

	self:RegisterEvent("RUNE_POWER_UPDATE")
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	self:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
	self:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("PET_BATTLE_OPENING_START")
	self:RegisterEvent("PET_BATTLE_CLOSE")
	self:SetScript("OnEvent", function(self, event, ...)
		events[event](self, ...)
	end)
end

function events:COMBAT_LOG_EVENT_UNFILTERED(...)
	local type = select(2, ...)
	if (type == "UNIT_DIED") then
			local unit = select(4, ...)
			if (unit == UnitName("player")) then
					self:images(riaDb.textureChoice)
			end
	end
end

function events:PET_BATTLE_CLOSE()
	self:showRunes()
end

function events:PET_BATTLE_OPENING_START()
	self:hideRunes()
end

function events:UNIT_EXITED_VEHICLE()
	self:refresh()
end

function events:UNIT_ENTERED_VEHICLE()
	if riaDb.entv == "0" then
		self:hideRunes()
	elseif riaDb.entv == "1" then
		self:refresh()
	else
		self:refresh(riaDb.alphaInCombat)
	end
	self:clear()
	self:orientation(riaDb.layoutChoice)
	self:scale(riaDb.scale)
end

function events:RUNE_POWER_UPDATE(...)
	local runeIndex, _ = ...
	self:RunePowerUpdate(runeIndex)
end

function events:UNIT_MAXPOWER()
	self:UpdateRuneCount()
end

function events:PLAYER_ENTERING_WORLD()
	self:UpdateRuneCount()
	for i=1, CURRENT_MAX_RUNES do
		self:RunePowerUpdate(i)
	end
	self:refresh()
end

function events:PLAYER_REGEN_DISABLED()
	if not UnitInVehicle("player") then
		self:alpha(riaDb.alphaInCombat)
	end
end

function events:PLAYER_REGEN_ENABLED()
	if not UnitInVehicle("player") then
		self:alpha(riaDb.alphaOutOfCombat)
	end
end

function ria:refresh(alphaVal)
	alphaVal = alphaVal or riaDb.alphaOutOfCombat

	self:clear()
	self:showRunes()
	self:alpha(alphaVal)
	self:scale(riaDb.scale)
	self:orientation(riaDb.layoutChoice)
	self:images(riaDb.textureChoice)
	self:setV(riaDb.vPadding)
	self:setH(riaDb.hPadding)
end

function ria:updateCdText(runeIndex, start, duration, runeReady)
	local apply, time = ria:getCurrentCd(runeIndex, start, duration, runeReady)
	if apply then
		ria:setCdText(runeIndex, time)
	end
	if runeReady then
		r[runeIndex]:SetScript("OnUpdate", nil)
	end
end

local cdLastUpdate = {0,0,0,0,0,0,0}
function ria:setCdText(runeIndex, time)
	cdLastUpdate[runeIndex] = GetTime()
	local time = floor(time + 0.5)
	local color = {1, 1, 0}

	if (time == 0) then
		time = ""
	elseif (riaDb.cdTextColor == "RUNE_COLORS") then
		color = runeColors[riaDb.runeType]
	elseif (riaDb.cdTextColor == "CUSTOM_COLOR") then
		color = {
			riaDb.cdCustomColorPicker.r,
			riaDb.cdCustomColorPicker.g,
			riaDb.cdCustomColorPicker.b,
			riaDb.cdCustomColorPicker.opacity
		}
	elseif time < 3 then
		local _, g, _ = cdText[runeIndex]:GetTextColor()
		if (g > 0.5) then color = {1, 0, 0} end
	end
	cdText[runeIndex]:Show()
	cdText[runeIndex]:SetTextColor(unpack(color))
	cdText[runeIndex]:SetText(time)
end

function ria:getCurrentCd(runeIndex, start, duration, runeReady)
	local now = GetTime()
	local FREQ = 0.25
	if (runeReady or (now - start) >= duration) then
		return true, 0
	elseif (now >= cdLastUpdate[runeIndex] + FREQ) then
		return true, duration - (now - start)
	end
	return false, nil
end

function ria:setCdFontSize(newValue)
	for i=1,MAX_RUNE_CAPACITY do
		cdText[i]:SetFont("Fonts\\FRIZQT__.TTF", newValue)
	end
end

function ria:RunePowerUpdate(runeIndex)
	if runeIndex and runeIndex >= 1 and runeIndex <= CURRENT_MAX_RUNES then
		local start, duration, runeReady = GetRuneCooldown(runeIndex)

		if not runeReady then -- not usable
			if riaDb.cdEnabled == "1" then
				r[runeIndex]:SetScript("OnUpdate", function()
					ria:updateCdText(runeIndex, start, duration, runeReady) end)
			end
			if riaDb.textureChoice == "BLIZZARD" or riaDb.textureChoice == "NEW_BLIZZARD" then
				b[runeIndex]:SetAlpha(0.3)
			end
			if riaDb.textureChoice == "RUNICA" then
				t[runeIndex]:SetVertexColor(0.3,0.3,0.3,0.9)
			else
				t[runeIndex]:SetVertexColor(0.4,0.4,0.4,riaDb.cdTextAlpha)
			end
			-- if InCombatLockdown() == nil then
			-- 	self:alpha(riaDb.alphaInCombat)
			-- end
		else -- usable
			if (riaDb.textureChoice == "BLIZZARD" or riaDb.textureChoice == "NEW_BLIZZARD" or riaDb.textureChoice == "RUNICA") then
				b[runeIndex]:SetAlpha(1)
			end
			t[runeIndex]:SetVertexColor(1,1,1,1)
			if InCombatLockdown() == nil then
				self:alpha(riaDb.alphaOutOfCombat)
			end
		end
	end
end

function ria:UpdateRuneCount()
	CURRENT_MAX_RUNES = UnitPowerMax("player", SPELL_POWER_RUNES)
	for i=1, MAX_RUNE_CAPACITY do
		if(i <= CURRENT_MAX_RUNES) then
			r[i]:Show()
		else
			r[i]:Hide()
		end
	end
end

function ria:lock(unlocked)
	self:clear()
	if unlocked then
		r[MAX_RUNE_CAPACITY]:Show()
		if riaDb.unlockType == "SHAPE" then
			t[1]:SetVertexColor(1,0,0,1)
			r[1]:SetFrameStrata("HIGH")
			r[1]:EnableMouse(true)
			r[1]:SetMovable(true)
			r[1]:RegisterForDrag("LeftButton")
			self:orientation(riaDb.layoutChoice)
			r[1]:SetScript("OnDragStart", function() r[1]:StartMoving() end)
			r[1]:SetScript("OnDragStop", function() r[1]:StopMovingOrSizing()
			riaDb.x, riaDb.y = r[1]:GetLeft(), r[1]:GetBottom() end)
		elseif riaDb.unlockType == "INDIVIDUAL" then
			for i = 1,MAX_RUNE_CAPACITY do
				t[i]:SetVertexColor(1,0,0,1)
				r[i]:SetFrameStrata("HIGH")
				r[i]:EnableMouse(true)
				r[i]:SetMovable(true)
				r[i]:RegisterForDrag("LeftButton")
				r[i]:SetScript("OnDragStart", function() r[i]:StartMoving() end)
				r[i]:SetScript("OnDragStop", function() r[i]:StopMovingOrSizing()
				riaDb.ind_x[i], riaDb.ind_y[i] = r[i]:GetLeft(), r[i]:GetBottom() end)
			end
		end
	else
		r[MAX_RUNE_CAPACITY]:Hide()
		if riaDb.unlockType == "SHAPE" then
			t[1]:SetVertexColor(1,1,1,1)
			r[1]:SetFrameStrata("LOW")
			r[1]:EnableMouse(false)
			r[1]:SetMovable(false)
		elseif riaDb.unlockType == "INDIVIDUAL" then
			for i = 1,MAX_RUNE_CAPACITY do
				t[i]:SetVertexColor(1,1,1,1)
				r[i]:SetFrameStrata("LOW")
				r[i]:EnableMouse(false)
				r[i]:SetMovable(false)
			end
		end
	end
end

function ria:setH(newValue)
	if riaDb.unlockType == "SHAPE" and
		(riaDb.layoutChoice == "HORIZONTAL") or (riaDb.layoutChoice == "VERTICAL") then
		for i = 2,MAX_RUNE_CAPACITY do
			r[i]:SetPoint("LEFT", r[i-1], "RIGHT", tonumber(newValue), 0)
		end
	end
end

function ria:setV(newValue)
	if riaDb.unlockType == "SHAPE" and
		(riaDb.layoutChoice == "HORIZONTAL") or (riaDb.layoutChoice == "VERTICAL") then
		for i = 2,MAX_RUNE_CAPACITY do
			r[i]:SetPoint("TOP", r[i-1], "BOTTOM", 0, -tonumber(newValue))
		end
	end
end

function ria:orientation(newValue)
	if riaDb.unlockType == "SHAPE" then
		self:clear()
		if newValue == "VERTICAL" then
			r[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", riaDb.x, riaDb.y)
			r[2]:SetPoint("BOTTOM", r[1], "TOP", 0, -42)
			r[3]:SetPoint("BOTTOM", r[2], "TOP", 0, -42)
			r[4]:SetPoint("BOTTOM", r[3], "TOP", 0, -42)
			r[5]:SetPoint("BOTTOM", r[4], "TOP", 0, -42)
			r[6]:SetPoint("BOTTOM", r[5], "TOP", 0, -42)
			r[7]:SetPoint("BOTTOM", r[6], "TOP", 0, -42)
		elseif newValue == "HORIZONTAL" then
			r[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", riaDb.x, riaDb.y)
			r[2]:SetPoint("LEFT", r[1], "RIGHT", 3, 0)
			r[3]:SetPoint("LEFT", r[2], "RIGHT", 3, 0)
			r[4]:SetPoint("LEFT", r[3], "RIGHT", 3, 0)
			r[5]:SetPoint("LEFT", r[4], "RIGHT", 3, 0)
			r[6]:SetPoint("LEFT", r[5], "RIGHT", 3, 0)
			r[7]:SetPoint("LEFT", r[6], "RIGHT", 3, 0)
		elseif newValue == "VERTICAL_BLOCK" then
			r[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", riaDb.x, riaDb.y)
			r[2]:SetPoint("LEFT", r[1], "RIGHT", 3, 0)
			r[3]:SetPoint("BOTTOM", r[1], "BOTTOM", 0, -22)
			r[4]:SetPoint("BOTTOM", r[2], "BOTTOM", 0, -22)
			r[5]:SetPoint("BOTTOM", r[3], "BOTTOM", 0, -22)
			r[6]:SetPoint("BOTTOM", r[4], "BOTTOM", 0, -22)
			r[7]:SetPoint("BOTTOM", r[5], "BOTTOM", 0, -22)
		elseif newValue == "UP_CURVE" then
			r[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", riaDb.x, riaDb.y)
			r[2]:SetPoint("LEFT", r[1], "RIGHT", 6, 26)
			r[3]:SetPoint("LEFT", r[1], "RIGHT", 40, 36)
			r[4]:SetPoint("LEFT", r[3], "RIGHT", 12, 0)
			r[5]:SetPoint("LEFT", r[1], "RIGHT", 102, 26)
			r[6]:SetPoint("LEFT", r[1], "RIGHT", 125, 0)
			r[7]:SetPoint("TOP", r[3], "TOP", 15, -25)
		elseif newValue == "HORIZONTAL_BLOCK" then
			r[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", riaDb.x, riaDb.y)
			r[2]:SetPoint("BOTTOM", r[1], "BOTTOM", 0, -22)
			r[3]:SetPoint("LEFT", r[1], "RIGHT", 3, 0)
			r[4]:SetPoint("LEFT", r[2], "RIGHT", 3, 0)
			r[5]:SetPoint("LEFT", r[3], "RIGHT", 3, 0)
			r[6]:SetPoint("LEFT", r[4], "RIGHT", 3, 0)
			r[7]:SetPoint("LEFT", r[5], "RIGHT", 3, 0)
		elseif newValue == "DOWN_CURVE" then
			r[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", riaDb.x, riaDb.y)
			r[2]:SetPoint("LEFT", r[1], "RIGHT", 6, -26)
			r[3]:SetPoint("LEFT", r[1], "RIGHT", 40, -36)
			r[4]:SetPoint("LEFT", r[3], "RIGHT", 12, 0)
			r[5]:SetPoint("LEFT", r[1], "RIGHT", 102, -26)
			r[6]:SetPoint("LEFT", r[1], "RIGHT", 125, 0)
			r[7]:SetPoint("BOTTOM", r[3], "BOTTOM", 15, 25)
		end
	else
		for i = 1, CURRENT_MAX_RUNES do
			r[i]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", riaDb.ind_x[i], riaDb.ind_y[i])
		end
	end
end

local runica = false
function ria:images(newValue)
    if newValue == "BETA" then
        for i = 1, MAX_RUNE_CAPACITY do
            b[i]:Hide()
            if runica == true then
                o[i]:SetTexture(nil)
                t[i]:SetTexCoord(0,1,0,1)
                r[i]:SetHeight(18)
                r[i]:SetWidth(18)
            end
        end
    elseif newValue == "BLIZZARD" then
        for i = 1, MAX_RUNE_CAPACITY do
            b[i]:Hide()
            -- cooldown[i]:Show()
            if runica == true then
                t[i]:SetTexCoord(0,1,0,1)
                r[i]:SetHeight(18)
                r[i]:SetWidth(18)
                -- cooldown[i]:SetWidth(18)
                -- cooldown[i]:SetHeight(18)
                o[i]:SetTexture(nil)
            end
        end
		elseif newValue == "NEW_BLIZZARD" then
			for i = 1, MAX_RUNE_CAPACITY do
					b[i]:Show()
					b[i]:SetTexture("Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-SingleRune.blp")
					if runica == true then
							t[i]:SetTexCoord(0,1,0,1)
							r[i]:SetHeight(18)
							r[i]:SetWidth(18)
							o[i]:SetTexture(nil)
					end
			end
			RuneItAllControlPanelruneTypeButton:SetText("Death")
			riaDb.runeType = "DEATH"
    elseif newValue == "DKI" then
        for i = 1, MAX_RUNE_CAPACITY do
            b[i]:Hide()
            if runica == true then
                o[i]:SetTexture(nil)
                t[i]:SetTexCoord(0,1,0,1)
                r[i]:SetHeight(18)
                r[i]:SetWidth(18)
            end
        end
    elseif newValue == "LETTER" then
        for i = 1, MAX_RUNE_CAPACITY do
            b[i]:Hide()
            if runica == true then
                o[i]:SetTexture(nil)
                t[i]:SetTexCoord(0,1,0,1)
                r[i]:SetHeight(18)
                r[i]:SetWidth(18)
            end
        end
    elseif newValue == "ORB" then
        for i = 1, MAX_RUNE_CAPACITY do
            b[i]:Hide()
            if runica == true then
                o[i]:SetTexture(nil)
                t[i]:SetTexCoord(0,1,0,1)
                r[i]:SetHeight(18)
                r[i]:SetWidth(18)
            end
        end
    elseif newValue == "ENHANCED" then
        for i = 1, MAX_RUNE_CAPACITY do
            b[i]:Hide()
            if runica == true then
                o[i]:SetTexture(nil)
                t[i]:SetTexCoord(0,1,0,1)
                r[i]:SetHeight(18)
                r[i]:SetWidth(18)
            end
        end
    elseif newValue == "JAPENESE" then
        for i = 1, MAX_RUNE_CAPACITY do
            b[i]:Hide()
            if runica == true then
                o[i]:SetTexture(nil)
                t[i]:SetTexCoord(0,1,0,1)
                r[i]:SetHeight(18)
                r[i]:SetWidth(18)
            end
        end
    elseif newValue == "RUNICA" then
        runica = true
        for i = 1, MAX_RUNE_CAPACITY do
            t[i]:SetTexCoord(0.1,0.9,0.1,0.9)
            b[i]:Hide()
            r[i]:SetHeight(21)
            r[i]:SetWidth(21)
            -- cooldown[i]:Show()
            -- cooldown[i]:SetWidth(22)
            -- cooldown[i]:SetHeight(22)
            o[i] = r[i]:CreateTexture("RBI"..i.."Overlay", "OVERLAY")
            o[i]:SetTexture(IMAGES_PATH.."runica\\border.tga")
            o[i]:SetAllPoints(t[i])
        end
				self:orientation(riaDb.layoutChoice)
    end
		for i=1,MAX_RUNE_CAPACITY do
			t[i]:SetTexture(iconTextures[riaDb.runeType][newValue])
		end
end

SlashCmdList["RUNEITALL"] = function(msg)
	RuneItAll_SlashHandler(string.lower(msg))
end

SLASH_RUNEITALL1 = "/runeitall"
SLASH_RUNEITALL2 = "/ria"
SLASH_RUNEITALL3 = "/rune-it-all"

function RuneItAll_SlashHandler(msg)
    local frame = LibStub("Portfolio").GetOptionsFrame("RuneItAll")
    InterfaceOptionsFrame_OpenToCategory(frame)
end

ria:init()
