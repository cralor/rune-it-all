if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

local _, RIA = ...

local eventHandler = CreateFrame("frame")

local cdFrame = {}
for i = 1, 6 do
	cdFrame[i] = CreateFrame("frame")
end

local RUNETYPE_BLOOD = 1
local RUNETYPE_UNHOLY = 2
local RUNETYPE_FROST = 3
local RUNETYPE_DEATH = 4

local iconTextures = {}

local runes = {}
local tex = {}
local border = {}
local cooldown = {}
local hide = true
local runica = false
local overlay = {}
local first = true

function RIA:init()
	RuneFrame:UnregisterAllEvents()
	RuneFrame:SetAlpha(0)
	RuneFrame:EnableMouse(false)
	RuneFrame:Hide()

	local blizzardRunes = {}
	for i = 1, 6 do
		blizzardRunes[i] = _G["RuneButtonIndividual"..i]
		blizzardRunes[i]:Hide()
		blizzardRunes[i]:EnableMouse(false)
		blizzardRunes[i]:SetAlpha(0)
		blizzardRunes[i]:UnregisterAllEvents()

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

	-- Will the callbacks work?
	-- RIA:refreshState()
end

function RIA:refreshState()
    for i = 1, 6 do
        runes[i]:Show()
    end
    self:clearPoints()
	self:setAlpha(RIADB.alphaout)
	self:setScale(RIADB.scale)
	self:setLayout(RIADB.layout)
	self:setTexture(RIADB.images)
	self:setVerticalPadding(RIADB.vertical)
	self:setHorizontalPadding(RIADB.horizontal)
end


function RIA:OnLoad()
    eventHandler:SetScript("OnEvent", function(self, event, ...) return self[event](self, event, ...) end)
    eventHandler:RegisterEvent("PLAYER_REGEN_DISABLED")
    eventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventHandler:RegisterEvent("PLAYER_LOGIN")
    eventHandler:RegisterEvent("UNIT_ENTERED_VEHICLE")
    eventHandler:RegisterEvent("UNIT_EXITED_VEHICLE")
    eventHandler:RegisterEvent("RUNE_POWER_UPDATE")
    eventHandler:RegisterEvent("RUNE_TYPE_UPDATE")
    eventHandler:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    --imagetimer = 4
    --RIA.eventFrame:SetScript("OnUpdate", RuneItAll_ImagesOnUpdate)
end

function eventHandler:PLAYER_REGEN_DISABLED(event)
    if not UnitInVehicle("player") then
        self:setAlpha(RIADB.alphain)
    end
end

function eventHandler:PLAYER_REGEN_ENABLED(event)
    if not UnitInVehicle("player") then
        self:setAlpha(RIADB.alphaout)
    end
end

function eventHandler:PLAYER_LOGIN(event)
    self:init()
end

function eventHandler:UNIT_EXITED_VEHICLE(event, ...)
    if (... == "player") then
        self:refreshState()
    end
end

function eventHandler:UNIT_ENTERED_VEHICLE(event, ...)
    if (... == "player") then
        if RIADB.entv == "0" then
            for i = 1, 6 do
                runes[i]:Hide()
            end
        elseif RIADB.entv == "1" then
            self:refreshState()
        else
            self:refreshState()
            self:setAlpha(RIADB.alphain)
        end
    end
end

function eventHandler:RUNE_TYPE_UPDATE(event, rune)
    self:runeUpdate(rune)
end

function eventHandler:RUNE_POWER_UPDATE(event, ...)
    local rune = select(1, ...)
    local usable = select(3, GetRuneCooldown(rune))
    if not rune or rune > 6 or rune < 1 then
        return
    elseif not usable then
        cdFrame[rune]:SetScript("OnUpdate", function() cdTextUpdate(rune) end)
        if (RIADB.images == "0") then
            border[self:runeSwap(rune)]:SetAlpha(0.3)
        end
        if (RIADB.images == "7") then
            tex[self:runeSwap(rune)]:SetVertexColor(0.3,0.3,0.3,0.9)
        else
            tex[self:runeSwap(rune)]:SetVertexColor(0.4,0.4,0.4,RIADB.cdalpha)
        end
        if RIADB.display_used == "1" and InCombatLockdown() == nil then
            self:setAlpha(RIADB.alphain)
        end
    elseif usable then
        if (RIADB.images == "0" or RIADB.images == "7") then
            border[self:runeSwap(rune)]:SetAlpha(1)
        end
        tex[self:runeSwap(rune)]:SetVertexColor(1,1,1,1)
        if --[[RIADB.display_used == "1" and ]]InCombatLockdown() == nil then
            self:setAlpha(RIADB.alphaout)
        end
    end
end

function eventHandler:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
    local eventType = select(2, ...)
    if (eventType == "UNIT_DIED") then
        local name = select(4, ...)
        if (name == UnitName("player")) then
            self:setTexture(RIADB.images)
        end
    end
end

--[[function RuneItAll_OnUpdate(RIA. elapsed)
	local RIA.cooldown = _G["RuneButtonIndividual"..RIA.GetID().."Cooldown"]
	local start, duration, runeReady = GetRuneCooldown(RIA.GetID())

	local displayCooldown = (runeReady and 0) or 1

	CooldownFrame_SetTimer(RIA.cooldown, start, duration, displayCooldown)

	if ( runeReady ) then
		RIA.SetScript("OnUpdate", nil)
	end
end]]

--[[local timing = 0
local function RuneItAll_YATAH(RIA. elapsed)
	timing = timing - elapsed
	
	if timing < 0 then
		for i = 1, 6 do
			RIA.runes[i]:SetAlpha(RIADB.alphain)
		end
		RuneItAll_PadVert(RIADB.vertical)
		RuneItAll_PadHoriz(RIADB.horizontal)
		RIA.SetScript("OnUpdate", nil)
	end
end]]

function RIA:setLayout(newValue)
	if RIADB.moving == "0" then
		self:clearPoints()
		if newValue == "1" then
			runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			runes[2]:SetPoint("BOTTOM", runes[1], "TOP", 0, -42)
			runes[3]:SetPoint("BOTTOM", runes[2], "TOP", 0, -42)
			runes[4]:SetPoint("BOTTOM", runes[3], "TOP", 0, -42)
			runes[5]:SetPoint("BOTTOM", runes[4], "TOP", 0, -42)
			runes[6]:SetPoint("BOTTOM", runes[5], "TOP", 0, -42)
		elseif newValue == "0" then -- HORIZONTAL
			runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			runes[2]:SetPoint("LEFT", runes[1], "RIGHT", 4, 0)
			runes[3]:SetPoint("LEFT", runes[2], "RIGHT", 4, 0)
			runes[4]:SetPoint("LEFT", runes[3], "RIGHT", 4, 0)
			runes[5]:SetPoint("LEFT", runes[4], "RIGHT", 4, 0)
			runes[6]:SetPoint("LEFT", runes[5], "RIGHT", 4, 0)
		elseif newValue == "2" then -- VERTICAL BLOCK
			runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			runes[2]:SetPoint("LEFT", runes[1], "RIGHT", 4, 0)
			runes[3]:SetPoint("BOTTOM", runes[1], "BOTTOM", 0, -22)
			runes[4]:SetPoint("BOTTOM", runes[2], "BOTTOM", 0, -22)
			runes[5]:SetPoint("BOTTOM", runes[3], "BOTTOM", 0, -22)
			runes[6]:SetPoint("BOTTOM", runes[4], "BOTTOM", 0, -22)
		elseif newValue == "3" then -- UP CURVE
			runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			runes[2]:SetPoint("LEFT", runes[1], "RIGHT", 6, 26)
			runes[3]:SetPoint("LEFT", runes[1], "RIGHT", 40, 36)
			runes[4]:SetPoint("LEFT", runes[3], "RIGHT", 12, 0)
			runes[5]:SetPoint("LEFT", runes[1], "RIGHT", 102, 26)
			runes[6]:SetPoint("LEFT", runes[1], "RIGHT", 125, 0)
		elseif newValue == "4" then -- HORIZONTAL BLOCK
			runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			runes[2]:SetPoint("BOTTOM", runes[1], "BOTTOM", 0, -22)
			runes[3]:SetPoint("LEFT", runes[1], "RIGHT", 4, 0)
			runes[4]:SetPoint("LEFT", runes[2], "RIGHT", 4, 0)
			runes[5]:SetPoint("LEFT", runes[3], "RIGHT", 4, 0)
			runes[6]:SetPoint("LEFT", runes[4], "RIGHT", 4, 0)
		elseif newValue == "5" then -- DOWN CURVE
			runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			runes[2]:SetPoint("LEFT", runes[1], "RIGHT", 6, -26)
			runes[3]:SetPoint("LEFT", runes[1], "RIGHT", 40, -36)
			runes[4]:SetPoint("LEFT", runes[3], "RIGHT", 12, 0)
			runes[5]:SetPoint("LEFT", runes[1], "RIGHT", 102, -26)
			runes[6]:SetPoint("LEFT", runes[1], "RIGHT", 125, 0)
		end
	else -- INDIVIDUAL MOVING
		for i = 1, 6 do
			runes[i]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.ind_x[i], RIADB.ind_y[i])
		end
	end
end

function RIA:setTexture(newValue)
	local path = "Interface\\AddOns\\RuneItAll\\images\\"
    if newValue == "1" then -- BETA RUNES
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
    elseif newValue == "0" then -- DEFAULT RUNES
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
    elseif newValue == "2" then -- DKI RUNES
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
    elseif newValue == "3" then -- LETTER RUNES
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
    elseif newValue == "4" then -- ORB RUNES
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
    elseif newValue == "5" then -- ENHANCED BETA RUNES
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
    elseif newValue == "6" then -- JAPANESE RUNES
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
    elseif newValue == "7" then -- RUNICA RUNES
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

function RIA:clearPoints()
    for i = 1, 6 do
        runes[i]:ClearAllPoints()
    end
end

function RIA:runeUpdate(rune)
	local runeType = GetRuneType(rune)
	local rune = self:runeSwap(rune)
    
    if (rune ~= 7 and rune ~= 8) then
        if (runeType) then
            tex[rune]:Show()
            tex[rune]:SetTexture(iconTextures[runeType])
        else
            tex[rune]:Hide()
        end
    end
end

--[[local timer = 0
function RuneItAll_VehicleOnUpdate(RIA. elapsed)
    timer = timer - elapsed
    RuneItAll_Clear()
    
    if timer < 0 then
		for i = 1, 6 do
			RIA.runes[i]:Show()
			RIA.runes[i]:SetAlpha(RIADB.alphaout)
			RIA.runes[i]:SetScale(RIADB.scale)
		end
        RuneItAll_Orientation(RIADB.layout)
		RuneItAll_Images(RIADB.images)
		RuneItAll_PadVert(RIADB.vertical)
		RuneItAll_PadHoriz(RIADB.horizontal)
        RIA.SetScript("OnUpdate", nil)
    end
end]]

--[[local imagetimer = 0
local function RuneItAll_ImagesOnUpdate(RIA. elapsed)
    imagetimer = imagetimer - elapsed
	
	if RIADB.moving == "1" then
		for i = 1, 6 do
			RIA.runes[i]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.ind_x[i], RIADB.ind_y[i])
		end
	end
    
    if imagetimer < 0 then
        RuneItAll_Images(RIADB.images)
        RIA.SetScript("OnUpdate", nil)
    end
end]]

local fonts = {}
for i = 1, 6 do
	fonts[i] = eventHandler:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	fonts[i]:SetPoint("CENTER", runes[i])
end
function RIA:setLocked(newValue)
	self:clearPoints()
    if newValue == "1" then
		if RIADB.moving == "0" then
			fonts[1]:SetText("|cffffffffX|r")
			fonts[1]:SetPoint("CENTER", runes[1])
			fonts[1]:Show()
			runes[1]:EnableMouse(true)
			runes[1]:SetMovable(true)
			runes[1]:RegisterForDrag("LeftButton")
			self:setLayout(RIADB.layout)
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

function RIA:setScale(newValue)
    for i = 1, 6 do
        runes[i]:SetScale(newValue)
    end
end

function RIA:setAlpha(newValue)
	for i = 1, 6 do
		runes[i]:SetAlpha(newValue)
	end
end

function RIA:setHorizontalPadding(newValue)
	if RIADB.moving == "0" and (RIADB.layout == "0") or (RIADB.layout == "1") then
		self:clearPoints()
		self:setLayout(RIADB.layout)
		for i = 2, 6 do
			runes[i]:SetPoint("LEFT", runes[i-1], "RIGHT", tonumber(newValue), 0)
		end
	end
end

function RIA:setVerticalPadding(newValue)
	if RIADB.moving == "0" and (RIADB.layout == "0") or (RIADB.layout == "1") then
		self:clearPoints()
		self:setLayout(RIADB.layout)
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
local cdText = {}
for i = 1, 6 do
	cdText[i] = eventHandler:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	cdText[i]:SetPoint("CENTER", runes[i])
	cdText[i]:SetAlpha(1)
	cdText[i]:Show()
end

--RuneItAll_CDFontSize(RIADB.cdfs)
-- Set font size of RIA.cooldown count text
function RIA:setCDFontSize(newValue)
	RIADB.cdfs = newValue
	for i = 1, 6 do
		cdText[i]:SetFont("Fonts\\FRIZQT__.TTF", newValue)
	end
end

-- OnUpdate to count down RIA.cooldown counts
function RIA:cdTextUpdate(rune)
	local start, duration, runeReady = GetRuneCooldown(rune)
	if (RIADB.cdtext == "1") then
		local apply, time = self:cooldownUpdate(rune, start, duration, runeReady)
		if (apply) then
			self:ccCount(rune, time)
		end
	end
	if (runeReady) then
		cdFrame[rune]:SetScript("OnUpdate", nil)
	end
end

-- Set and color the RIA.cooldown texts
local lastUpdate = {0, 0, 0, 0, 0, 0}
function RIA:ccCount(rune, time)
	lastUpdate[rune] = GetTime()
	local time = floor(time + 0.5)
	local color = {1,1,0}

	if (time == 0) then
		time = ""
	elseif (RIADB.color == "1") then
		color = runeColors[GetRuneType(self:runeSwap(rune))]
	elseif (RIADB.color == "2") then
		local r = RIADB.color_picker.r
		local g = RIADB.color_picker.g
		local b = RIADB.color_picker.b
		local o = RIADB.color_picker.opacity
		color = {r,g,b,o}
	elseif (time < 3) then
		local _,g,_ = cdText[self:runeSwap(rune)]:GetTextColor()
		if (g > 0.5) then color = {1,0,0} end
	end

	rune = self:runeSwap(rune)
	cdText[rune]:SetTextColor(unpack(color))
	cdText[rune]:SetText(time)
end

function RIA:runeSwap(rune)
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

-- Calculate the current RIA.cooldown
function RIA:cooldownUpdate(rune, start, duration, ready)
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
    RIA:slashHandler(string.lower(msg))
end

SLASH_RUNEITALL1 = "/runeitall"
SLASH_RUNEITALL2 = "/ria"
SLASH_RUNEITALL3 = "/rune-it-all"

function RIA:slashHandler(msg)
    local optionsFrame = LibStub("Portfolio").GetOptionsFrame("RuneItAll")
    InterfaceOptionsFrame_OpenToCategory(optionsFrame)
end

-- Initiate AddOn to Load
RIA:OnLoad()