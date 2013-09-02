if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end

local RIA = {}
RIA.eventFrame = CreateFrame("frame")

function getRIATable()
    return RIA
end

RIA.cdFrame = {}
for i = 1, 6 do
	RIA.cdFrame[i] = CreateFrame("frame")
end

local RUNETYPE_BLOOD = 1
local RUNETYPE_UNHOLY = 2
local RUNETYPE_FROST = 3
local RUNETYPE_DEATH = 4

local iconTextures = {}

RIA.runes = {}
RIA.tex = {}
RIA.border = {}
RIA.cooldown = {}
local hide = true
local runica = false
RIA.overlay = {}
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

		self.runes[i] = _G["RIA_RuneButtonIndividual"..i]
   		self.tex[i] = _G["RIA_RuneButtonIndividual"..i.."Rune"]
    	self.border[i] = _G["RIA_RuneButtonIndividual"..i.."Border"]
    	self.cooldown[i] = _G["RIA_RuneButtonIndividual"..i.."Cooldown"]
    	self.cooldown[i]:SetScript("OnShow", function(self) if hide then self:Hide() end end)
    	self.runes[i]:SetClampedToScreen(true)
    	self.runes[i]:SetFrameStrata("LOW")
    	self.runes[i]:EnableMouse(false)
		self.runes[i]:Show()
		self.tex[i]:Show()
	end

	-- Will the callbacks work?
	-- RIA:refreshState()
end

function RIA:refreshState()
    for i = 1, 6 do
        self.runes[i]:Show()
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
    self.eventFrame:SetScript("OnEvent", self.OnEvent)
    self.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.eventFrame:RegisterEvent("PLAYER_LOGIN")
    self.eventFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
    self.eventFrame:RegisterEvent("UNIT_EXITED_VEHICLE")
    self.eventFrame:RegisterEvent("RUNE_POWER_UPDATE")
    self.eventFrame:RegisterEvent("RUNE_TYPE_UPDATE")
    self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    --imagetimer = 4
    --RIA.eventFrame:SetScript("OnUpdate", RuneItAll_ImagesOnUpdate)
end


function RIA:OnEvent(event, ...)
    if (event == "PLAYER_REGEN_DISABLED") then -- Entered combat
		if not UnitInVehicle("player") then
			self:setAlpha(RIADB.alphain)
		end
    elseif (event == "PLAYER_REGEN_ENABLED") then -- Exited combat
		if not UnitInVehicle("player") then
			self:setAlpha(RIADB.alphaout)
		end
    elseif (event == "PLAYER_LOGIN") then
		self:init()
    elseif (event == "UNIT_EXITED_VEHICLE") and (... == "player") then
        self:refreshState()
    elseif (event == "UNIT_ENTERED_VEHICLE") and (... == "player") then
        if RIADB.entv == "0" then
			for i = 1, 6 do
				self.runes[i]:Hide()
			end
		elseif RIADB.entv == "1" then
			self:refreshState()
		else
            self:refreshState()
			self:setAlpha(RIADB.alphain)
		end
    elseif (event == "RUNE_TYPE_UPDATE") then
        local rune = ...
        self:runeUpdate(rune)
    elseif (event == "RUNE_POWER_UPDATE") then
        local rune = select(1, ...)
		local usable = select(3, GetRuneCooldown(rune))
        if not rune or rune > 6 or rune < 1 then
            return
        elseif not usable then
			self.cdFrame[rune]:SetScript("OnUpdate", function() self:cdTextUpdate(rune) end)
			if (RIADB.images == "0") then
				self.border[self:runeSwap(rune)]:SetAlpha(0.3)
			end
			if (RIADB.images == "7") then
				self.tex[self:runeSwap(rune)]:SetVertexColor(0.3,0.3,0.3,0.9)
			else
				self.tex[self:runeSwap(rune)]:SetVertexColor(0.4,0.4,0.4,RIADB.cdalpha)
			end
			if RIADB.display_used == "1" and InCombatLockdown() == nil then
				self:setAlpha(RIADB.alphain)
			end
        elseif usable then
			if (RIADB.images == "0" or RIADB.images == "7") then
				self.border[self:runeSwap(rune)]:SetAlpha(1)
			end
			self.tex[self:runeSwap(rune)]:SetVertexColor(1,1,1,1)
			if --[[RIADB.display_used == "1" and ]]InCombatLockdown() == nil then
				self:setAlpha(RIADB.alphaout)
			end
        end
    elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local eventType = select(2, ...)
        if (eventType == "UNIT_DIED") then
            local name = select(4, ...)
            if (name == UnitName("player")) then
                self:setTexture(RIADB.images)
            end
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
			self.runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			self.runes[2]:SetPoint("BOTTOM", self.runes[1], "TOP", 0, -42)
			self.runes[3]:SetPoint("BOTTOM", self.runes[2], "TOP", 0, -42)
			self.runes[4]:SetPoint("BOTTOM", self.runes[3], "TOP", 0, -42)
			self.runes[5]:SetPoint("BOTTOM", self.runes[4], "TOP", 0, -42)
			self.runes[6]:SetPoint("BOTTOM", self.runes[5], "TOP", 0, -42)
		elseif newValue == "0" then -- HORIZONTAL
			self.runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			self.runes[2]:SetPoint("LEFT", self.runes[1], "RIGHT", 4, 0)
			self.runes[3]:SetPoint("LEFT", self.runes[2], "RIGHT", 4, 0)
			self.runes[4]:SetPoint("LEFT", self.runes[3], "RIGHT", 4, 0)
			self.runes[5]:SetPoint("LEFT", self.runes[4], "RIGHT", 4, 0)
			self.runes[6]:SetPoint("LEFT", self.runes[5], "RIGHT", 4, 0)
		elseif newValue == "2" then -- VERTICAL BLOCK
			self.runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			self.runes[2]:SetPoint("LEFT", self.runes[1], "RIGHT", 4, 0)
			self.runes[3]:SetPoint("BOTTOM", self.runes[1], "BOTTOM", 0, -22)
			self.runes[4]:SetPoint("BOTTOM", self.runes[2], "BOTTOM", 0, -22)
			self.runes[5]:SetPoint("BOTTOM", self.runes[3], "BOTTOM", 0, -22)
			self.runes[6]:SetPoint("BOTTOM", self.runes[4], "BOTTOM", 0, -22)
		elseif newValue == "3" then -- UP CURVE
			self.runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			self.runes[2]:SetPoint("LEFT", self.runes[1], "RIGHT", 6, 26)
			self.runes[3]:SetPoint("LEFT", self.runes[1], "RIGHT", 40, 36)
			self.runes[4]:SetPoint("LEFT", self.runes[3], "RIGHT", 12, 0)
			self.runes[5]:SetPoint("LEFT", self.runes[1], "RIGHT", 102, 26)
			self.runes[6]:SetPoint("LEFT", self.runes[1], "RIGHT", 125, 0)
		elseif newValue == "4" then -- HORIZONTAL BLOCK
			self.runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			self.runes[2]:SetPoint("BOTTOM", self.runes[1], "BOTTOM", 0, -22)
			self.runes[3]:SetPoint("LEFT", self.runes[1], "RIGHT", 4, 0)
			self.runes[4]:SetPoint("LEFT", self.runes[2], "RIGHT", 4, 0)
			self.runes[5]:SetPoint("LEFT", self.runes[3], "RIGHT", 4, 0)
			self.runes[6]:SetPoint("LEFT", self.runes[4], "RIGHT", 4, 0)
		elseif newValue == "5" then -- DOWN CURVE
			self.runes[1]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.x, RIADB.y)
			self.runes[2]:SetPoint("LEFT", self.runes[1], "RIGHT", 6, -26)
			self.runes[3]:SetPoint("LEFT", self.runes[1], "RIGHT", 40, -36)
			self.runes[4]:SetPoint("LEFT", self.runes[3], "RIGHT", 12, 0)
			self.runes[5]:SetPoint("LEFT", self.runes[1], "RIGHT", 102, -26)
			self.runes[6]:SetPoint("LEFT", self.runes[1], "RIGHT", 125, 0)
		end
	else -- INDIVIDUAL MOVING
		for i = 1, 6 do
			self.runes[i]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", RIADB.ind_x[i], RIADB.ind_y[i])
		end
	end
end

function RIA:setTexture(newValue)
	local path = "Interface\\AddOns\\RuneItAll\\images\\"
    if newValue == "1" then -- BETA RUNES
        hide = true
        for i = 1, 6 do
            self.border[i]:Hide()
            if runica == true then
                self.overlay[i]:SetTexture(nil)
                self.tex[i]:SetTexCoord(0,1,0,1)
                self.runes[i]:SetHeight(18)
                self.runes[i]:SetWidth(18)
            end
        end
        iconTextures[RUNETYPE_BLOOD] = path.."beta\\blood.blp"
        iconTextures[RUNETYPE_UNHOLY] = path.."beta\\unholy.blp"
        iconTextures[RUNETYPE_FROST] = path.."beta\\frost.blp"
        iconTextures[RUNETYPE_DEATH] = path.."beta\\death.blp"
    elseif newValue == "0" then -- DEFAULT RUNES
        hide = false
        for i = 1, 6 do
            self.border[i]:Show()
            self.cooldown[i]:Show()
            if runica == true then
                self.tex[i]:SetTexCoord(0,1,0,1)
                self.runes[i]:SetHeight(18)
                self.runes[i]:SetWidth(18)
                self.cooldown[i]:SetWidth(18)
                self.cooldown[i]:SetHeight(18)
                self.overlay[i]:SetTexture(nil)
            end
        end
        iconTextures[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood.blp"
        iconTextures[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy.blp"
        iconTextures[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost.blp"
        iconTextures[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death.blp"
    elseif newValue == "2" then -- DKI RUNES
        hide = true
        for i = 1, 6 do
            self.border[i]:Hide()
            if runica == true then
                self.overlay[i]:SetTexture(nil)
                self.tex[i]:SetTexCoord(0,1,0,1)
                self.runes[i]:SetHeight(18)
                self.runes[i]:SetWidth(18)
            end
        end
        iconTextures[RUNETYPE_BLOOD] = path.."DKI\\blood.tga"
        iconTextures[RUNETYPE_UNHOLY] = path.."DKI\\unholy.tga"
        iconTextures[RUNETYPE_FROST] = path.."DKI\\frost.tga"
        iconTextures[RUNETYPE_DEATH] = path.."DKI\\death.tga"
    elseif newValue == "3" then -- LETTER RUNES
        hide = true
        for i = 1, 6 do
            self.border[i]:Hide()
            if runica == true then
                self.overlay[i]:SetTexture(nil)
                self.tex[i]:SetTexCoord(0,1,0,1)
                self.runes[i]:SetHeight(18)
                self.runes[i]:SetWidth(18)
            end
        end
        iconTextures[RUNETYPE_BLOOD] = path.."letter\\blood.tga"
        iconTextures[RUNETYPE_UNHOLY] = path.."letter\\unholy.tga"
        iconTextures[RUNETYPE_FROST] = path.."letter\\frost.tga"
        iconTextures[RUNETYPE_DEATH] = path.."letter\\death.tga"
    elseif newValue == "4" then -- ORB RUNES
        hide = true
        for i = 1, 6 do
            self.border[i]:Hide()
            if runica == true then
                self.overlay[i]:SetTexture(nil)
                self.tex[i]:SetTexCoord(0,1,0,1)
                self.runes[i]:SetHeight(18)
                self.runes[i]:SetWidth(18)
            end
        end
        iconTextures[RUNETYPE_BLOOD] = path.."orb\\blood.tga"
        iconTextures[RUNETYPE_UNHOLY] = path.."orb\\unholy.tga"
        iconTextures[RUNETYPE_FROST] = path.."orb\\frost.tga"
        iconTextures[RUNETYPE_DEATH] = path.."orb\\death.tga"
    elseif newValue == "5" then -- ENHANCED BETA RUNES
        hide = true
        for i = 1, 6 do
            self.border[i]:Hide()
            if runica == true then
                self.overlay[i]:SetTexture(nil)
                self.tex[i]:SetTexCoord(0,1,0,1)
                self.runes[i]:SetHeight(18)
                self.runes[i]:SetWidth(18)
            end
        end
        iconTextures[RUNETYPE_BLOOD] = path.."beta-enhanced\\blood.tga"
        iconTextures[RUNETYPE_UNHOLY] = path.."beta-enhanced\\unholy.tga"
        iconTextures[RUNETYPE_FROST] = path.."beta-enhanced\\frost.tga"
        iconTextures[RUNETYPE_DEATH] = path.."beta-enhanced\\death.tga"
    elseif newValue == "6" then -- JAPANESE RUNES
        hide = true
        for i = 1, 6 do
            self.border[i]:Hide()
            if runica == true then
                self.overlay[i]:SetTexture(nil)
                self.tex[i]:SetTexCoord(0,1,0,1)
                self.runes[i]:SetHeight(18)
                self.runes[i]:SetWidth(18)
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
            self.tex[i]:SetTexCoord(0.1,0.9,0.1,0.9)
            self.border[i]:Hide()
            self.runes[i]:SetHeight(21)
            self.runes[i]:SetWidth(21)
            self.cooldown[i]:Show()
            self.cooldown[i]:SetWidth(22)
            self.cooldown[i]:SetHeight(22)
            self.overlay[i] = self.runes[i]:CreateTexture("RuneButtonIndividual"..i.."Overlay", "OVERLAY")
            self.overlay[i]:SetTexture(path.."runica\\border.tga")
            self.overlay[i]:SetAllPoints(self.tex[i])
        end
        iconTextures[RUNETYPE_BLOOD] = path.."runica\\blood.tga"
        iconTextures[RUNETYPE_UNHOLY] = path.."runica\\unholy.tga"
        iconTextures[RUNETYPE_FROST] = path.."runica\\frost.tga"
        iconTextures[RUNETYPE_DEATH] = path.."runica\\death.tga"
    end
    self.tex[1]:SetTexture(iconTextures[1])
    self.tex[2]:SetTexture(iconTextures[1])
    self.tex[3]:SetTexture(iconTextures[3])
    self.tex[4]:SetTexture(iconTextures[3])
    self.tex[5]:SetTexture(iconTextures[2])
    self.tex[6]:SetTexture(iconTextures[2])
end

function RIA:clearPoints()
    for i = 1, 6 do
        self.runes[i]:ClearAllPoints()
    end
end

function RIA:runeUpdate(rune)
	local runeType = GetRuneType(rune)
	local rune = self:runeSwap(rune)
    
    if (rune ~= 7 and rune ~= 8) then
        if (runeType) then
            self.tex[rune]:Show()
            self.tex[rune]:SetTexture(iconTextures[runeType])
        else
            self.tex[rune]:Hide()
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

RIA.fonts = {}
for i = 1, 6 do
	RIA.fonts[i] = RIA.eventFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	RIA.fonts[i]:SetPoint("CENTER", RIA.runes[i])
end
function RIA:setLocked(newValue)
	self:clearPoints()
    if newValue == "1" then
		if RIADB.moving == "0" then
			self.fonts[1]:SetText("|cffffffffX|r")
			self.fonts[1]:SetPoint("CENTER", self.runes[1])
			self.fonts[1]:Show()
			self.runes[1]:EnableMouse(true)
			self.runes[1]:SetMovable(true)
			self.runes[1]:RegisterForDrag("LeftButton")
			self:setLayout(RIADB.layout)
			self.runes[1]:SetScript("OnDragStart", function() self.runes[1]:StartMoving() end)
			self.runes[1]:SetScript("OnDragStop", function() self.runes[1]:StopMovingOrSizing()
			RIADB.x, RIADB.y = self.runes[1]:GetLeft(), self.runes[1]:GetBottom() end)
		elseif RIADB.moving == "1" then
			for i = 1, 6 do
				self.fonts[i]:SetText("|cffffffffX|r")
				self.fonts[i]:Show()
				self.runes[i]:EnableMouse(true)
				self.runes[i]:SetMovable(true)
				self.runes[i]:RegisterForDrag("LeftButton")
				self.runes[i]:SetScript("OnDragStart", function() self.runes[i]:StartMoving() end)
				self.runes[i]:SetScript("OnDragStop", function() self.runes[i]:StopMovingOrSizing()
				RIADB.ind_x[i], RIADB.ind_y[i] = self.runes[i]:GetLeft(), self.runes[i]:GetBottom() end)
			end
		end
    elseif newValue == "0" then
		if RIADB.moving == "0" then
			self.fonts[1]:Hide()
			self.runes[1]:EnableMouse(false)
			self.runes[1]:SetMovable(false)
		elseif RIADB.moving == "1" then
			for i = 1, 6 do
				self.fonts[i]:Hide()
				self.runes[i]:EnableMouse(false)
				self.runes[i]:SetMovable(false)
			end
		end
    end
end

function RIA:setScale(newValue)
    for i = 1, 6 do
        self.runes[i]:SetScale(newValue)
    end
end

function RIA:setAlpha(newValue)
	for i = 1, 6 do
		self.runes[i]:SetAlpha(newValue)
	end
end

function RIA:setHorizontalPadding(newValue)
	if RIADB.moving == "0" and (RIADB.layout == "0") or (RIADB.layout == "1") then
		self:clearPoints()
		self:setLayout(RIADB.layout)
		for i = 2, 6 do
			self.runes[i]:SetPoint("LEFT", self.runes[i-1], "RIGHT", tonumber(newValue), 0)
		end
	end
end

function RIA:setVerticalPadding(newValue)
	if RIADB.moving == "0" and (RIADB.layout == "0") or (RIADB.layout == "1") then
		self:clearPoints()
		self:setLayout(RIADB.layout)
		for i = 2, 6 do
			self.runes[i]:SetPoint("TOP", self.runes[i-1], "BOTTOM", 0, -tonumber(newValue))
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
RIA.cdText = {}
for i = 1, 6 do
	RIA.cdText[i] = RIA.eventFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	RIA.cdText[i]:SetPoint("CENTER", RIA.runes[i])
	RIA.cdText[i]:SetAlpha(1)
	RIA.cdText[i]:Show()
end

--RuneItAll_CDFontSize(RIADB.cdfs)
-- Set font size of RIA.cooldown count text
function RIA:setCDFontSize(newValue)
	RIADB.cdfs = newValue
	for i = 1, 6 do
		self.cdText[i]:SetFont("Fonts\\FRIZQT__.TTF", newValue)
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
		self.cdFrame[rune]:SetScript("OnUpdate", nil)
	end
end

-- Set and color the RIA.cooldown texts
RIA.lastUpdate = {0, 0, 0, 0, 0, 0}
function RIA:ccCount(rune, time)
	self.lastUpdate[rune] = GetTime()
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
		local _,g,_ = self.cdText[self:runeSwap(rune)]:GetTextColor()
		if (g > 0.5) then color = {1,0,0} end
	end

	rune = self:runeSwap(rune)
	self.cdText[rune]:SetTextColor(unpack(color))
	self.cdText[rune]:SetText(time)
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