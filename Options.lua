-- <= == == == == == == == == == == == == =>
-- => Option Registration
-- <= == == == == == == == == == == == == =>

if (not RIADB) then
	RIADB = {
        --parent = UIParent;
        --point = "BOTTOMLEFT";
        --parentPoint = "BOTTOMLEFT";
        x = 500;
        y = 500;
		ind_x = {};
		ind_y = {};
    };
end

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
			headerText = "Unlock Type";
			type = CONTROLTYPE_DROPDOWN;
			defaultValue = "0";
			menuList = {
				{
					text = "Unlock as Shape";
                    value = "0";
				};
				{
					text = "Unlock Individually";
                    value = "1";
				};
			};
		};
		{
			id = "unlocked";
			text = "Unlock Runes";
			tooltipText = "Check this to unlock the runes with the type you have chosen.";
			type = CONTROLTYPE_CHECKBOX;
			defaultValue = "0";
			point = {"LEFT", "moving", "RIGHT", 20, 0};
			callback = RuneItAll_Lock
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
			headerText = "Rune Layouts";
			type = CONTROLTYPE_DROPDOWN;
			defaultValue = "0";
			menuList = {
				{
					text = "Horizontal";
                    value = "0";
				};
				{
					text = "Vertical";
					value = "1";
				};
				{
					text = "Vertical Block";
					value = "2";
				};
                {
                    text = "Horizontal Block";
                    value = "4";
                };
				{
					text = "Up Curve";
					value = "3";
				};
                {
                    text = "Down Curve";
                    value = "5";
                };
			};
			point = {"TOP", "moving", "BOTTOM", -5, -25};
            callback = RuneItAll_Orientation
		};
        {
            id = "images";
            headerText = "Rune Textures";
            type = CONTROLTYPE_DROPDOWN;
            defaultValue = "0";
            menuList = {
                {
					text = "Default";
                    value = "0";
				};
				{
					text = "Beta Runes";
					value = "1";
				};
				{
					text = "DKI Runes";
					value = "2";
				};
				{
					text = "Letter Runes";
					value = "3";
				};
                {
                    text = "Orb Runes";
                    value = "4";
                };
                {
                    text = "Enhanced Beta Runes";
                    value = "5";
                };
                {
                    text = "Japanese Runes";
                    value = "6";
                };
                {
                    text = "Runica Runes";
                    value = "7";
                };
            };
			point = {"LEFT", "layout", "RIGHT", 15, 0};
            callback = RuneItAll_Images
        };
		{
            id = "entv";
            headerText = "Entering Vehicle";
            type = CONTROLTYPE_DROPDOWN;
            defaultValue = "0";
            menuList = {
                {
					text = "Hide";
                    value = "0";
				};
				{
					text = "O.O.C. Alpha";
					value = "1";
				};
				{
					text = "I.C. Alpha";
					value = "2";
				};
            };
			point = {"LEFT", "images", "RIGHT", 15, 0};
        };
		{
            id = "scale";
            text = "Rune Scale (%.1f)";
            tooltipText = "Adjust the scale of the runes.";
            minText = "Small";
            maxText = "Large";
            minValue = 0.5;
            maxValue = 2.0;
            valueStep = 0.1;
            type = CONTROLTYPE_SLIDER;
            defaultValue = "1.2";
			point = {nil, "layout", nil, nil, -25};
            callback = RuneItAll_Scale
        };
		{
            id = "cdalpha";
            text = "CD Rune Alpha (%.1f)";
            tooltipText = "The transparency of the runes when on cooldown.";
            minText = "Light";
            maxText = "Solid";
            minValue = 0;
            maxValue = 1;
            valueStep = 0.1;
            type = CONTROLTYPE_SLIDER;
            defaultValue = "0.9";
			point = {"LEFT", "scale", "RIGHT", 20, 0};
        };
		{
			id = "alphain";
			text = "Alpha I.C. (%.1f)";
			tooltipText = "The transparency of the runes while in combat.";
			minText = "Light";
			maxText = "Solid";
			minValue = 0.1;
			maxValue = 1;
			valueStep = 0.1;
			type = CONTROLTYPE_SLIDER;
			defaultValue = "1";
			point = {"TOP", "scale", "BOTTOM", 0, -25};
		};
        {
            id = "alphaout";
            text = "Alpha O.O.C. (%.1f)";
            tooltipText = "The transparency of the runes while out of combat.";
            minText = "Light";
            maxText = "Solid";
            minValue = 0;
            maxValue = 1;
            valueStep = 0.1;
            type = CONTROLTYPE_SLIDER;
            defaultValue = "0.5";
			point = {"LEFT", "alphain", "RIGHT", 20, 0};
            callback = RuneItAll_AlphaOut
        };
		{
			id = "horizontal";
			text = "Horizontal Padding (%1.0f)";
			tooltipText = "The horizontal distance between runes.";
			minText = "Close";
			maxText = "Far";
			minValue = -25;
			maxValue = 25;
			valueStep = 1;
			type = CONTROLTYPE_SLIDER;
			defaultValue = "4";
			point = {"TOP", "alphain", "BOTTOM", 0, -25};
			callback = RuneItAll_PadHoriz
		};
		{
			id = "vertical";
			text = "Vertical Padding (%1.0f)";
			tooltipText = "The vertical distance between runes.";
			minText = "Close";
			maxText = "Far";
			minValue = -25;
			maxValue = 25;
			valueStep = 1;
			type = CONTROLTYPE_SLIDER;
			defaultValue = "-18";
			point = {"LEFT", "horizontal", "RIGHT", 20, 0};
			callback = RuneItAll_PadVert
		};
		{
			id = "CDHeader";
			text = "Cooldown Text";
			type = CONTROLTYPE_HEADER;
			point = {nil, "horizontal", nil, nil, nil};
		};
		{
			id = "cdtext";
			text = "Enabled";
			tooltipText = "Check this to have cooldown timers appear on your runes.";
			type = CONTROLTYPE_CHECKBOX;
			defaultValue = "0";
		};
		{
			id = "color";
			headerText = "Cooldown Text Colors";
			type = CONTROLTYPE_DROPDOWN;
			defaultValue = "0";
			menuList = {
				{
					text = "Default";
					value = "0";
				};
				{
					text = "Rune Colors";
					value = "1";
				};
				{
					text = "Custom (Color Picker)";
					value = "2";
				};
			};
		};
		{
			id = "color_picker";
			text = "Custom Color";
			type = CONTROLTYPE_COLORPICKER;
			hasOpacity = true;
			defaultValue = {r=0.5, g=1, b=0.75, opacity=1};
			point = {"LEFT", "color", "RIGHT", 40, 0};
		};
		{
			id = "cdfs";
			text = "Cooldown Font Size (%1.0f)";
			tooltipText = "The font size of the cooldown count text.";
			minText = "Small";
			maxText = "Large";
			minValue = 10;
			maxValue = 25;
			valueStep = 1;
			type = CONTROLTYPE_SLIDER;
			defaultValue = "14";
			point = {"LEFT", "cdtext", "RIGHT", 150, 0};
			callback = RuneItAll_CDFontSize
		};
	};
	savedVarTable = "RIADB";
}

Portfolio.RegisterOptionSet(optionTable)