local _, class = UnitClass("player")
if class ~= "DEATHKNIGHT" then
    return
end

local RuneItAll = CreateFrame("frame")

local RMCD = {}
for i = 1, 6 do
	RMCD[i] = CreateFrame("frame")
end

RuneFrame:UnregisterAllEvents()
RuneFrame:SetAlpha(0)
RuneFrame:EnableMouse(false)
RuneFrame:Hide()
RuneFrame = CreateFrame("frame")

local old_runes = {}
for i = 1, 6 do
	old_runes[i] = _G["RuneButtonIndividual"..i]
	old_runes[i]:Hide()
	old_runes[i]:EnableMouse(false)
	old_runes[i]:SetAlpha(0)
	old_runes[i]:UnregisterAllEvents()
end

local RUNETYPE_BLOOD = 1
local RUNETYPE_UNHOLY = 2
local RUNETYPE_FROST = 3
local RUNETYPE_DEATH = 4

local iconTextures = {}

local path = "Interface\\AddOns\\RuneItAll\\images\\"

local runes = {}
local tex = {}
local border = {}
local cooldown = {}
local hide = true
local runica = false
local overlay = {}
local first = true

for i = 1, 6 do
    runes[i] = _G["RIA_RuneButtonIndividual"..i]
    tex[i] = _G["RIA_RuneButtonIndividual"..i.."Rune"]
    border[i] = _G["RIA_RuneButtonIndividual"..i.."Border"]
    cooldown[i] = _G["RIA_RuneButtonIndividual"..i.."Cooldown"]
    cooldown[i]:SetScript("OnShow", function(self) if hide then self:Hide() end end)
    runes[i]:SetClampedToScreen(true)
    runes[i]:SetFrameStrata("LOW")
    runes[i]:EnableMouse(false)
	runes[i]:Show()
	tex[i]:Show()
end


function RuneItAll_OnLoad(self)
    self:SetScript("OnEvent", RuneItAll_OnEvent)
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UNIT_ENTERED_VEHICLE")
    self:RegisterEvent("UNIT_EXITED_VEHICLE")
    self:RegisterEvent("RUNE_POWER_UPDATE")
    self:RegisterEvent("RUNE_TYPE_UPDATE")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    imagetimer = 4
    RuneItAll:SetScript("OnUpdate", RuneItAll_ImagesOnUpdate)
end


function RuneItAll_OnEvent(self, event, ...)
    if (event == "PLAYER_REGEN_DISABLED") then
		if not UnitInVehicle("player") then
			for i = 1, 6 do
				runes[i]:SetAlpha(RIADB.alphain)
			end
		end
    elseif (event == "PLAYER_REGEN_ENABLED") then
		if not UnitInVehicle("player") then
			for i = 1, 6 do
				runes[i]:SetAlpha(RIADB.alphaout)
			end
		end
    elseif (event == "PLAYER_ENTERING_WORLD") then
		RuneItAll:SetScript("OnUpdate", RuneItAll_VehicleOnUpdate)
    elseif (event == "UNIT_EXITED_VEHICLE") and (... == "player") then
        RuneItAll:SetScript("OnUpdate", RuneItAll_VehicleOnUpdate)
    elseif (event == "UNIT_ENTERED_VEHICLE") and (... == "player") then
        if RIADB.entv == "0" then
			for i = 1, 6 do
				runes[i]:Hide()
			end
		elseif RIADB.entv == "1" then
			RuneItAll:SetScript("OnUpdate", RuneItAll_VehicleOnUpdate)
		else
			for i = 1, 6 do
				runes[i]:Show()
			end
			RuneItAll:SetScript("OnUpdate", RuneItAll_YATAH)
		end
		RuneItAll_Clear()
		RuneItAll_Orientation(RIADB.layout)
		RuneItAll_Scale(RIADB.scale)
    elseif (event == "RUNE_TYPE_UPDATE") then
        local rune = ...
        RuneItAll_RuneUpdate(rune)
    elseif (event == "RUNE_POWER_UPDATE") then
        local rune = select(1, ...)
		local usable = select(3, GetRuneCooldown(rune))
        if not rune or rune > 6 or rune < 1 then
            return
        elseif not usable then
			RMCD[rune]:SetScript("OnUpdate", function() RuneItAll_TextOnUpdate(rune) end)
			if (RIADB.images == "0") then
				border[RuneItAll_RuneSwap(rune)]:SetAlpha(0.3)
			end
			if (RIADB.images == "7") then
				tex[RuneItAll_RuneSwap(rune)]:SetVertexColor(0.3,0.3,0.3,0.9)
			else
				tex[RuneItAll_RuneSwap(rune)]:SetVertexColor(0.4,0.4,0.4,RIADB.cdalpha)
			end
			if RIADB.display_used == "1" and InCombatLockdown() == nil then
				for i = 1, 6 do
					runes[i]:SetAlpha(RIADB.alphain)
				end
			end
        elseif usable then
			if (RIADB.images == "0" or RIADB.images == "7") then
				border[RuneItAll_RuneSwap(rune)]:SetAlpha(1)
			end
			tex[RuneItAll_RuneSwap(rune)]:SetVertexColor(1,1,1,1)
			if --[[RIADB.display_used == "1" and ]]InCombatLockdown() == nil then
				for i = 1, 6 do
					runes[i]:SetAlpha(RIADB.alphaout)
				end
			end
        end
    elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local eventtype = select(2, ...)
        if (eventtype == "UNIT_DIED") then
            local name = select(4, ...)
            if (name == UnitName("player")) then
                RuneItAll_Images(RIADB.images)
            end
        end
    end
end

--[[function RuneItAll_OnUpdate(self, elapsed)
	local cooldown = _G["RuneButtonIndividual"..self:GetID().."Cooldown"]
	local start, duration, runeReady = GetRuneCooldown(self:GetID())

	local displayCooldown = (runeReady and 0) or 1

	CooldownFrame_SetTimer(cooldown, start, duration, displayCooldown)

	if ( runeReady ) then
		self:SetScript("OnUpdate", nil)
	end
end]]

local timing = 0
function RuneItAll_YATAH(self, elapsed)
	timing = timing - elapsed
	
	if timing < 0 then
		for i = 1, 6 do
			runes[i]:SetAlpha(RIADB.alphain)
		end
		RuneItAll_PadVert(RIADB.vertical)
		RuneItAll_PadHoriz(RIADB.horizontal)
		self:SetScript("OnUpdate", nil)
	end
end

function RuneItAll_Orientation(newValue)
	if RIADB.moving == "0" then
		RuneItAll_Clear()
		if newValue == "1" then
			runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			runes[2]:SetPoint("BOTTOM", runes[1], "TOP", 0, -42)
			runes[3]:SetPoint("BOTTOM", runes[2], "TOP", 0, -42)
			runes[4]:SetPoint("BOTTOM", runes[3], "TOP", 0, -42)
			runes[5]:SetPoint("BOTTOM", runes[4], "TOP", 0, -42)
			runes[6]:SetPoint("BOTTOM", runes[5], "TOP", 0, -42)
		elseif newValue == "0" then
			runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			runes[2]:SetPoint("LEFT", runes[1], "RIGHT", 4, 0)
			runes[3]:SetPoint("LEFT", runes[2], "RIGHT", 4, 0)
			runes[4]:SetPoint("LEFT", runes[3], "RIGHT", 4, 0)
			runes[5]:SetPoint("LEFT", runes[4], "RIGHT", 4, 0)
			runes[6]:SetPoint("LEFT", runes[5], "RIGHT", 4, 0)
		elseif newValue == "2" then
			runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			runes[2]:SetPoint("LEFT", runes[1], "RIGHT", 4, 0)
			runes[3]:SetPoint("BOTTOM", runes[1], "BOTTOM", 0, -22)
			runes[4]:SetPoint("BOTTOM", runes[2], "BOTTOM", 0, -22)
			runes[5]:SetPoint("BOTTOM", runes[3], "BOTTOM", 0, -22)
			runes[6]:SetPoint("BOTTOM", runes[4], "BOTTOM", 0, -22)
		elseif newValue == "3" then
			runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			runes[2]:SetPoint("LEFT", runes[1], "RIGHT", 6, 26)
			runes[3]:SetPoint("LEFT", runes[1], "RIGHT", 40, 36)
			runes[4]:SetPoint("LEFT", runes[3], "RIGHT", 12, 0)
			runes[5]:SetPoint("LEFT", runes[1], "RIGHT", 102, 26)
			runes[6]:SetPoint("LEFT", runes[1], "RIGHT", 125, 0)
		elseif newValue == "4" then
			runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			runes[2]:SetPoint("BOTTOM", runes[1], "BOTTOM", 0, -22)
			runes[3]:SetPoint("LEFT", runes[1], "RIGHT", 4, 0)
			runes[4]:SetPoint("LEFT", runes[2], "RIGHT", 4, 0)
			runes[5]:SetPoint("LEFT", runes[3], "RIGHT", 4, 0)
			runes[6]:SetPoint("LEFT", runes[4], "RIGHT", 4, 0)
		elseif newValue == "5" then
			runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			runes[2]:SetPoint("LEFT", runes[1], "RIGHT", 6, -26)
			runes[3]:SetPoint("LEFT", runes[1], "RIGHT", 40, -36)
			runes[4]:SetPoint("LEFT", runes[3], "RIGHT", 12, 0)
			runes[5]:SetPoint("LEFT", runes[1], "RIGHT", 102, -26)
			runes[6]:SetPoint("LEFT", runes[1], "RIGHT", 125, 0)
		end
	else
		for i = 1, 6 do
			runes[i]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.ind_x[i], RIADB.ind_y[i])
		end
	end
end

function RuneItAll_Images(newValue)
    if newValue == "1" then
        hide = true
        for i = 1, 6 do
            border[i]:Hide()
            if runica == true then
                overlay[i]:SetTexture(nil)
                tex[i]:SetTexCoord(0,1,0,1)
                runes[i]:SetHeight(18)
                runes[i]:SetWidth(18)
            end
        end
        iconTextures[RUNETYPE_BLOOD] = path.."beta\\blood.blp"
        iconTextures[RUNETYPE_UNHOLY] = path.."beta\\unholy.blp"
        iconTextures[RUNETYPE_FROST] = path.."beta\\frost.blp"
        iconTextures[RUNETYPE_DEATH] = path.."beta\\death.blp"
    elseif newValue == "0" then
        hide = false
        for i = 1, 6 do
            border[i]:Show()
            cooldown[i]:Show()
            if runica == true then
                tex[i]:SetTexCoord(0,1,0,1)
                runes[i]:SetHeight(18)
                runes[i]:SetWidth(18)
                cooldown[i]:SetWidth(18)
                cooldown[i]:SetHeight(18)
                overlay[i]:SetTexture(nil)
            end
        end
        iconTextures[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood.blp"
        iconTextures[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy.blp"
        iconTextures[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost.blp"
        iconTextures[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death.blp"
    elseif newValue == "2" then
        hide = true
        for i = 1, 6 do
            border[i]:Hide()
            if runica == true then
                overlay[i]:SetTexture(nil)
                tex[i]:SetTexCoord(0,1,0,1)
                runes[i]:SetHeight(18)
                runes[i]:SetWidth(18)
            end
        end
        iconTextures[RUNETYPE_BLOOD] = path.."DKI\\blood.tga"
        iconTextures[RUNETYPE_UNHOLY] = path.."DKI\\unholy.tga"
        iconTextures[RUNETYPE_FROST] = path.."DKI\\frost.tga"
        iconTextures[RUNETYPE_DEATH] = path.."DKI\\death.tga"
    elseif newValue == "3" then
        hide = true
        for i = 1, 6 do
            border[i]:Hide()
            if runica == true then
                overlay[i]:SetTexture(nil)
                tex[i]:SetTexCoord(0,1,0,1)
                runes[i]:SetHeight(18)
                runes[i]:SetWidth(18)
            end
        end
        iconTextures[RUNETYPE_BLOOD] = path.."letter\\blood.tga"
        iconTextures[RUNETYPE_UNHOLY] = path.."letter\\unholy.tga"
        iconTextures[RUNETYPE_FROST] = path.."letter\\frost.tga"
        iconTextures[RUNETYPE_DEATH] = path.."letter\\death.tga"
    elseif newValue == "4" then
        hide = true
        for i = 1, 6 do
            border[i]:Hide()
            if runica == true then
                overlay[i]:SetTexture(nil)
                tex[i]:SetTexCoord(0,1,0,1)
                runes[i]:SetHeight(18)
                runes[i]:SetWidth(18)
            end
        end
        iconTextures[RUNETYPE_BLOOD] = path.."orb\\blood.tga"
        iconTextures[RUNETYPE_UNHOLY] = path.."orb\\unholy.tga"
        iconTextures[RUNETYPE_FROST] = path.."orb\\frost.tga"
        iconTextures[RUNETYPE_DEATH] = path.."orb\\death.tga"
    elseif newValue == "5" then
        hide = true
        for i = 1, 6 do
            border[i]:Hide()
            if runica == true then
                overlay[i]:SetTexture(nil)
                tex[i]:SetTexCoord(0,1,0,1)
                runes[i]:SetHeight(18)
                runes[i]:SetWidth(18)
            end
        end
        iconTextures[RUNETYPE_BLOOD] = path.."beta-enhanced\\blood.tga"
        iconTextures[RUNETYPE_UNHOLY] = path.."beta-enhanced\\unholy.tga"
        iconTextures[RUNETYPE_FROST] = path.."beta-enhanced\\frost.tga"
        iconTextures[RUNETYPE_DEATH] = path.."beta-enhanced\\death.tga"
    elseif newValue == "6" then
        hide = true
        for i = 1, 6 do
            border[i]:Hide()
            if runica == true then
                overlay[i]:SetTexture(nil)
                tex[i]:SetTexCoord(0,1,0,1)
                runes[i]:SetHeight(18)
                runes[i]:SetWidth(18)
            end
        end
        iconTextures[RUNETYPE_BLOOD] = path.."japanese\\blood.tga"
        iconTextures[RUNETYPE_UNHOLY] = path.."japanese\\unholy.tga"
        iconTextures[RUNETYPE_FROST] = path.."japanese\\frost.tga"
        iconTextures[RUNETYPE_DEATH] = path.."japanese\\death.tga"
    elseif newValue == "7" then
        hide = false
        runica = true
        for i = 1, 6 do
            tex[i]:SetTexCoord(0.1,0.9,0.1,0.9)
            border[i]:Hide()
            runes[i]:SetHeight(21)
            runes[i]:SetWidth(21)
            cooldown[i]:Show()
            cooldown[i]:SetWidth(22)
            cooldown[i]:SetHeight(22)
            overlay[i] = runes[i]:CreateTexture("RuneButtonIndividual"..i.."Overlay", "OVERLAY")
            overlay[i]:SetTexture(path.."runica\\border.tga")
            overlay[i]:SetAllPoints(tex[i])
        end
        iconTextures[RUNETYPE_BLOOD] = path.."runica\\blood.tga"
        iconTextures[RUNETYPE_UNHOLY] = path.."runica\\unholy.tga"
        iconTextures[RUNETYPE_FROST] = path.."runica\\frost.tga"
        iconTextures[RUNETYPE_DEATH] = path.."runica\\death.tga"
    end
    tex[1]:SetTexture(iconTextures[1])
    tex[2]:SetTexture(iconTextures[1])
    tex[3]:SetTexture(iconTextures[3])
    tex[4]:SetTexture(iconTextures[3])
    tex[5]:SetTexture(iconTextures[2])
    tex[6]:SetTexture(iconTextures[2])
end

function RuneItAll_Clear()
    for i = 1, 6 do
        runes[i]:ClearAllPoints()
    end
end

function RuneItAll_RuneUpdate(rune)
	local runeType = GetRuneType(rune)
	local rune = RuneItAll_RuneSwap(rune)
    
    if (rune ~= 7 and rune ~= 8) then
        if (runeType) then
            tex[rune]:Show()
            tex[rune]:SetTexture(iconTextures[runeType])
        else
            tex[rune]:Hide()
        end
    end
end

local timer = 0
function RuneItAll_VehicleOnUpdate(self, elapsed)
    timer = timer - elapsed
    RuneItAll_Clear()
    
    if timer < 0 then
		for i = 1, 6 do
			runes[i]:Show()
			runes[i]:SetAlpha(RIADB.alphaout)
			runes[i]:SetScale(RIADB.scale)
		end
        RuneItAll_Orientation(RIADB.layout)
		RuneItAll_Images(RIADB.images)
		RuneItAll_PadVert(RIADB.vertical)
		RuneItAll_PadHoriz(RIADB.horizontal)
        self:SetScript("OnUpdate", nil)
    end
end

local imagetimer = 0
function RuneItAll_ImagesOnUpdate(self, elapsed)
    imagetimer = imagetimer - elapsed
	
	if RIADB.moving == "1" then
		for i = 1, 6 do
			runes[i]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.ind_x[i], RIADB.ind_y[i])
		end
	end
    
    if imagetimer < 0 then
        RuneItAll_Images(RIADB.images)
        self:SetScript("OnUpdate", nil)
    end
end

local fonts = {}
for i = 1, 6 do
	fonts[i] = RuneItAll:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	fonts[i]:SetPoint("CENTER", runes[i])
end
function RuneItAll_Lock(newValue)
	RuneItAll_Clear()
    if newValue == "1" then
		if RIADB.moving == "0" then
			fonts[1]:SetText("|cffffffffX|r")
			fonts[1]:SetPoint("CENTER", runes[1])
			fonts[1]:Show()
			runes[1]:EnableMouse(true)
			runes[1]:SetMovable(true)
			runes[1]:RegisterForDrag("LeftButton")
			RuneItAll_Orientation(RIADB.layout)
			runes[1]:SetScript("OnDragStart", function() runes[1]:StartMoving() end)
			runes[1]:SetScript("OnDragStop", function() runes[1]:StopMovingOrSizing()
			RIADB.x, RIADB.y = runes[1]:GetLeft(), runes[1]:GetBottom() end)
		elseif RIADB.moving == "1" then
			for i = 1, 6 do
				fonts[i]:SetText("|cffffffffX|r")
				fonts[i]:Show()
				runes[i]:EnableMouse(true)
				runes[i]:SetMovable(true)
				runes[i]:RegisterForDrag("LeftButton")
				runes[i]:SetScript("OnDragStart", function() runes[i]:StartMoving() end)
				runes[i]:SetScript("OnDragStop", function() runes[i]:StopMovingOrSizing()
				RIADB.ind_x[i], RIADB.ind_y[i] = runes[i]:GetLeft(), runes[i]:GetBottom() end)
			end
		end
    elseif newValue == "0" then
		if RIADB.moving == "0" then
			fonts[1]:Hide()
			runes[1]:EnableMouse(false)
			runes[1]:SetMovable(false)
		elseif RIADB.moving == "1" then
			for i = 1, 6 do
				fonts[i]:Hide()
				runes[i]:EnableMouse(false)
				runes[i]:SetMovable(false)
			end
		end
    end
end

function RuneItAll_Scale(newValue)
    for i = 1, 6 do
        runes[i]:SetScale(newValue)
    end
end

function RuneItAll_AlphaOut(newValue)
	for i = 1, 6 do
		runes[i]:SetAlpha(newValue)
	end
end

function RuneItAll_PadHoriz(newValue)
	if RIADB.moving == "0" and (RIADB.layout == "0") or (RIADB.layout == "1") then
		RuneItAll_Clear()
		RuneItAll_Orientation(RIADB.layout)
		for i = 2, 6 do
			runes[i]:SetPoint("LEFT", runes[i-1], "RIGHT", tonumber(newValue), 0)
		end
	end
end

function RuneItAll_PadVert(newValue)
	if RIADB.moving == "0" and (RIADB.layout == "0") or (RIADB.layout == "1") then
		RuneItAll_Clear()
		RuneItAll_Orientation(RIADB.layout)
		for i = 2, 6 do
			runes[i]:SetPoint("TOP", runes[i-1], "BOTTOM", 0, -tonumber(newValue))
		end
	end
end

local runeColors = {
	[RUNETYPE_BLOOD]  = {1,   0,   0},
	[RUNETYPE_UNHOLY] = {0,   0.5, 0},
	[RUNETYPE_FROST]  = {0,   1,   1},
	[RUNETYPE_DEATH]  = {0.8, 0.1, 1}
}

--[[ Credit to Yury's RuneDisplay for cooldown code ]]--
--[[ Credit to Parnic for coding help ]]--
-- Setup CD texts
local cd_ind = {}
for i = 1, 6 do
	cd_ind[i] = RuneItAll:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	cd_ind[i]:SetPoint("CENTER", runes[i])
	cd_ind[i]:SetAlpha(1)
	cd_ind[i]:Show()
end

--RuneItAll_CDFontSize(RIADB.cdfs)
-- Set font size of cooldown count text
function RuneItAll_CDFontSize(newValue)
	RIADB.cdfs = newValue
	for i = 1, 6 do
		cd_ind[i]:SetFont("Fonts\\FRIZQT__.TTF", newValue)
	end
end

-- OnUpdate to count down cooldown counts
function RuneItAll_TextOnUpdate(rune)
	local start, duration, runeReady = GetRuneCooldown(rune)
	if (RIADB.cdtext == "1") then
		local apply, time = RuneItAll_CooldownUpdate(rune, start, duration, runeReady)
		if (apply) then
			RuneItAll_CooldownCount(rune, time)
		end
	end
	if (runeReady) then
		RMCD[rune]:SetScript("OnUpdate", nil)
	end
end

-- Set and color the cooldown texts
local lastUpdate = {0, 0, 0, 0, 0, 0}
function RuneItAll_CooldownCount(rune, time)
	lastUpdate[rune] = GetTime()
	local time = floor(time + 0.5)
	local color = {1,1,0}
	if (time == 0) then
		time = ""
	elseif (RIADB.color == "1") then
		color = runeColors[GetRuneType(RuneItAll_RuneSwap(rune))]
	elseif (RIADB.color == "2") then
		local r = RIADB.color_picker.r
		local g = RIADB.color_picker.g
		local b = RIADB.color_picker.b
		local o = RIADB.color_picker.opacity
		color = {r,g,b,o}
	elseif (time < 3) then
		local _,g,_ = cd_ind[RuneItAll_RuneSwap(rune)]:GetTextColor()
		if (g > 0.5) then color = {1,0,0} end
	end
	rune = RuneItAll_RuneSwap(rune)
	cd_ind[rune]:SetTextColor(unpack(color))
	cd_ind[rune]:SetText(time)
end

function RuneItAll_RuneSwap(rune)
	if rune == 3 then
		rune = 5
	elseif rune == 5 then
		rune = 3
	elseif rune == 4 then
		rune = 6
	elseif rune == 6 then
		rune = 4
	end
	return rune
end

-- Calculate the current cooldown
function RuneItAll_CooldownUpdate(rune, start, duration, ready)
	local now = GetTime()
	local FREQ = 0.25
	if (ready or (now - start) >= duration) then
		return true, 0
	elseif (now >= lastUpdate[rune] + FREQ) then
		return true, duration - (now - start)
	end
	return false, nil
end

-- Slash Command Stuff
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

-- Initiate AddOn to Load
RuneItAll_OnLoad(RuneItAll)