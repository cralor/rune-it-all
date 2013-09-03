-- <= == == == == == == == == == == == == =>
-- => Option Registration
-- <= == == == == == == == == == == == == =>

local _, RIA = ...

if not RIADB then
	RIADB = {
        x = 500;
        y = 500;
		ind_x = {};
		ind_y = {};
    };
end

local L = RIA.locales

local Portfolio = LibStub and LibStub("Portfolio")
if not Portfolio then return end

local function callback(id, value, isGUI, isUpdate) 
	Portfolio.Print(id.." callback( \""..tostring(value).."\", "..tostring(isGUI)..", "..tostring(isUpdate)..")")
end

local function colorCallback(id, color, isGUI, isUpdate)
	(SELECTED_CHAT_FRAME or DEFAULT_CHAT_FRAME)
		:AddMessage(id.." Updated. callback( { r="..tostring(color.r):format("%.2f")..", g="
		..tostring(color.g):format("%.2f")..", b="..tostring(color.b):format("%.2f")..", opacity="
		..tostring(color.opacity).." }, "..tostring(isGUI)..", "..tostring(isUpdate)..") ", 
		color.r, color.g, color.b) 
end

local optionTable = {
	id="RuneItAll";
	text="Rune-It-All";
	addon="RuneItAll";
	about=true;
	options = {
		{
			id = "moving";
			headerText = L["Unlock Type"];
			type = CONTROLTYPE_DROPDOWN;
			defaultValue = "0";
			menuList = {
				{
					text = L["Unlock as Shape"];
                    value = "0";
				};
				{
					text = L["Unlock Individually"];
                    value = "1";
				};
			};
		};
		{
			id = "unlocked";
			text = L["Unlock Runes"];
			tooltipText = L["Check this to unlock the runes with the type you have chosen."];
			type = CONTROLTYPE_CHECKBOX;
			defaultValue = "0";
			point = {"LEFT", "moving", "RIGHT", 20, 0};
			callback = RIA.setLocked;
		};
		--[[{
			id = "display_used";
			text = "Pop Runes O.O.C. (See tooltip description!)";
			tooltipText = "Check this to have runes appear, even if the alpha is 0, while O.O.C. when you use one (Such as DND).";
			type = CONTROLTYPE_CHECKBOX;
			defaultValue = "0";
			point = {nil, "moving", nil, nil, nil};
		};]]
		--[[{
			id = "shine";
			text = "Shine Runes";
			tooltipText = "Have runes make a shiny flash when they are usable again.";
			type = CONTROLTYPE_CHECKBOX;
			defaultValue = "1";
		};]]
        {
			id = "layout";
			headerText = L["Rune Layouts"];
			type = CONTROLTYPE_DROPDOWN;
			defaultValue = "0";
			menuList = {
				{
					text = L["Horizontal"];
                    value = "0";
				};
				{
					text = L["Vertical"];
					value = "1";
				};
				{
					text = L["Vertical Block"];
					value = "2";
				};
                {
                    text = L["Horizontal Block"];
                    value = "4";
                };
				{
					text = L["Up Curve"];
					value = "3";
				};
                {
                    text = L["Down Curve"];
                    value = "5";
                };
			};
			point = {"TOP", "moving", "BOTTOM", -5, -25};
            callback = RIA.setLayout;
		};
        {
            id = "images";
            headerText = L["Rune Textures"];
            type = CONTROLTYPE_DROPDOWN;
            defaultValue = "0";
            menuList = {
                {
					text = L["Default"];
                    value = "0";
				};
				{
					text = L["Beta Runes"];
					value = "1";
				};
				{
					text = L["DKI Runes"];
					value = "2";
				};
				{
					text = L["Letter Runes"];
					value = "3";
				};
                {
                    text = L["Orb Runes"];
                    value = "4";
                };
                {
                    text = L["Enhanced Beta Runes"];
                    value = "5";
                };
                {
                    text = L["Japanese Runes"];
                    value = "6";
                };
                {
                    text = L["Runica Runes"];
                    value = "7";
                };
            };
			point = {"LEFT", "layout", "RIGHT", 15, 0};
            callback = RIA.setTexture;
        };
		{
            id = "entv";
            headerText = L["Entering Vehicle"];
            type = CONTROLTYPE_DROPDOWN;
            defaultValue = "0";
            menuList = {
                {
					text = L["Hide"];
                    value = "0";
				};
				{
					text = L["O.O.C. Alpha"];
					value = "1";
				};
				{
					text = L["I.C. Alpha"];
					value = "2";
				};
            };
			point = {"LEFT", "images", "RIGHT", 15, 0};
        };
		{
            id = "scale";
            text = L["Rune Scale (%.1f)"];
            tooltipText = L["Adjust the scale of the runes."];
            minText = L["Small"];
            maxText = L["Large"];
            minValue = 0.5;
            maxValue = 2.0;
            valueStep = 0.1;
            type = CONTROLTYPE_SLIDER;
            defaultValue = "1.2";
			point = {nil, "layout", nil, nil, -25};
            callback = RIA.setScale;
        };
		{
            id = "cdalpha";
            text = L["CD Rune Alpha (%.1f)"];
            tooltipText = L["The transparency of the runes when on cooldown."];
            minText = L["Light"];
            maxText = L["Solid"];
            minValue = 0;
            maxValue = 1;
            valueStep = 0.1;
            type = CONTROLTYPE_SLIDER;
            defaultValue = "0.9";
			point = {"LEFT", "scale", "RIGHT", 20, 0};
        };
		{
			id = "alphain";
			text = L["Alpha I.C. (%.1f)"];
			tooltipText = L["The transparency of the runes while in combat."];
			minText = L["Light"];
			maxText = L["Solid"];
			minValue = 0.1;
			maxValue = 1;
			valueStep = 0.1;
			type = CONTROLTYPE_SLIDER;
			defaultValue = "1";
			point = {"TOP", "scale", "BOTTOM", 0, -25};
		};
        {
            id = "alphaout";
            text = L["Alpha O.O.C. (%.1f)"];
            tooltipText = L["The transparency of the runes while out of combat."];
            minText = L["Light"];
            maxText = L["Solid"];
            minValue = 0;
            maxValue = 1;
            valueStep = 0.1;
            type = CONTROLTYPE_SLIDER;
            defaultValue = "0.5";
			point = {"LEFT", "alphain", "RIGHT", 20, 0};
            callback = RIA.setAlpha;
        };
		{
			id = "horizontal";
			text = L["Horizontal Padding (%1.0f)"];
			tooltipText = L["The horizontal distance between runes."];
			minText = L["Close"];
			maxText = L["Far"];
			minValue = -25;
			maxValue = 25;
			valueStep = 1;
			type = CONTROLTYPE_SLIDER;
			defaultValue = "4";
			point = {"TOP", "alphain", "BOTTOM", 0, -25};
			callback = RIA.setHorizontalPadding;
		};
		{
			id = "vertical";
			text = L["Vertical Padding (%1.0f)"];
			tooltipText = L["The vertical distance between runes."];
			minText = L["Close"];
			maxText = L["Far"];
			minValue = -25;
			maxValue = 25;
			valueStep = 1;
			type = CONTROLTYPE_SLIDER;
			defaultValue = "-18";
			point = {"LEFT", "horizontal", "RIGHT", 20, 0};
			callback = RIA.setVerticalPadding;
		};
		{
			id = "CDHeader";
			text = L["Cooldown Text"];
			type = CONTROLTYPE_HEADER;
			point = {nil, "horizontal", nil, nil, nil};
		};
		{
			id = "cdtext";
			text = L["Enabled"];
			tooltipText = L["Check this to have cooldown timers appear on your runes."];
			type = CONTROLTYPE_CHECKBOX;
			defaultValue = "0";
		};
		{
			id = "color";
			headerText = L["Cooldown Text Colors"];
			type = CONTROLTYPE_DROPDOWN;
			defaultValue = "0";
			menuList = {
				{
					text = L["Default"];
					value = "0";
				};
				{
					text = L["Rune Colors"];
					value = "1";
				};
				{
					text = L["Custom (Color Picker)"];
					value = "2";
				};
			};
		};
		{
			id = "color_picker";
			text = L["Custom Color"];
			type = CONTROLTYPE_COLORPICKER;
			hasOpacity = true;
			defaultValue = {r=0.5, g=1, b=0.75, opacity=1};
			point = {"LEFT", "color", "RIGHT", 40, 0};
		};
		{
			id = "cdfs";
			text = L["Cooldown Font Size (%1.0f)"];
			tooltipText = L["The font size of the cooldown count text."];
			minText = L["Small"];
			maxText = L["Large"];
			minValue = 10;
			maxValue = 25;
			valueStep = 1;
			type = CONTROLTYPE_SLIDER;
			defaultValue = "14";
			point = {"LEFT", "cdtext", "RIGHT", 150, 0};
			callback = RIA.setCDFontSize;
		};
	};
	savedVarTable = "RIADB";
}

Portfolio.RegisterOptionSet(optionTable)