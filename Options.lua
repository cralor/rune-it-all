-- <= == == == == == == == == == == == == =>
-- => Option Registration
-- <= == == == == == == == == == == == == =>
local _, class = UnitClass("player")
if ( class ~= "DEATHKNIGHT" ) then
  return
end

local name, table = ...
local ria = table.ria

if (not riaDb) then
  riaDb = {
    --parent = UIParent;
    --point = "BOTTOMLEFT";
    --parentPoint = "BOTTOMLEFT";
    x = GetScreenWidth()/2*UIParent:GetEffectiveScale();
    y = GetScreenHeight()/2*UIParent:GetEffectiveScale();
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
      id = "unlockType";
      headerText = "Unlock Type";
      type = CONTROLTYPE_DROPDOWN;
      defaultValue = "SHAPE";
      menuList = {
        {
          text = "Unlock as Shape";
          value = "SHAPE";
        };
        {
          text = "Unlock Individually";
          value = "INDIVIDUAL";
        };
      };
--      callback = function(value, isGUI, isUpdate) ria:orientation(riaDb.layoutChoice) end;
    };
    {
      id = "unlocked";
      text = "Unlock Runes";
      tooltipText = "Check this to unlock the runes with the type you have chosen.";
      type = CONTROLTYPE_CHECKBOX;
      defaultValue = "0";
      point = {"LEFT", "unlockType", "RIGHT", 20, 0};
      callback = function(value, isGUI, isUpdate) ria:lock(value == "1") end;
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
      id = "layoutChoice";
      headerText = "Rune Layouts";
      type = CONTROLTYPE_DROPDOWN;
      defaultValue = "HORIZONTAL";
      menuList = {
        {
          text = "Horizontal";
          value = "HORIZONTAL";
        };
        {
          text = "Vertical";
          value = "VERTICAL";
        };
        {
          text = "Vertical Block";
          value = "VERTICAL_BLOCK";
        };
        {
            text = "Horizontal Block";
            value = "HORIZONTAL_BLOCK";
        };
        {
          text = "Up Curve";
          value = "UP_CURVE";
        };
        {
            text = "Down Curve";
            value = "DOWN_CURVE";
        };
      };
      point = {"TOP", "unlockType", "BOTTOM", -5, -25};
      callback = function(value, isGUI, isUpdate) ria:orientation(value) end;
    };
    {
      id = "textureChoice";
      headerText = "Rune Textures";
      type = CONTROLTYPE_DROPDOWN;
      defaultValue = "NEW_BLIZZARD";
      menuList = {
          {
            text = "Original Blizzard";
            value = "BLIZZARD";
          };
          {
            text = "Beta Runes";
            value = "BETA";
          };
          {
            text = "DKI Runes";
            value = "DKI";
          };
          {
            text = "Letter Runes";
            value = "LETTER";
          };
          {
              text = "Orb Runes";
              value = "ORB";
          };
          {
              text = "Enhanced Beta Runes";
              value = "ENHANCED";
          };
          {
              text = "Japanese Runes";
              value = "JAPANESE";
          };
          {
              text = "Runica Runes";
              value = "RUNICA";
          };
          -- {
          --     text = "Default Legion Runes";
          --     value = "NEW_BLIZZARD";
          -- };
        };
        point = {"LEFT", "layoutChoice", "RIGHT", 15, 0};
        callback = function(value, isGUI, isUpdate) if not isUpdate then ria:images(value) end end;
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
        point = {"LEFT", "textureChoice", "RIGHT", 15, 0};
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
        point = {nil, "layoutChoice", nil, nil, -25};
        callback = function(value, isGUI, isUpdate) ria:scale(value) end;
    };
    {
        id = "cdTextAlpha";
        text = "CD Rune Alpha (%.1f)";
        tooltipText = "The transparency of the runes when on cooldown.";
        minText = "Light";
        maxText = "Solid";
        minValue = 0.0;
        maxValue = 1.0;
        valueStep = 0.1;
        type = CONTROLTYPE_SLIDER;
        defaultValue = "0.9";
        point = {"LEFT", "scale", "RIGHT", 20, 0};
    };
    {
      id = "alphaInCombat";
      text = "Alpha I.C. (%.1f)";
      tooltipText = "The transparency of the runes while in combat.";
      minText = "Light";
      maxText = "Solid";
      minValue = 0.1;
      maxValue = 1.0;
      valueStep = 0.1;
      type = CONTROLTYPE_SLIDER;
      defaultValue = "1";
      point = {"TOP", "scale", "BOTTOM", 0, -25};
    };
    {
      id = "alphaOutOfCombat";
      text = "Alpha O.O.C. (%.1f)";
      tooltipText = "The transparency of the runes while out of combat.";
      minText = "Light";
      maxText = "Solid";
      minValue = 0.0;
      maxValue = 1.0;
      valueStep = 0.1;
      type = CONTROLTYPE_SLIDER;
      defaultValue = "0.5";
      point = {"LEFT", "alphaInCombat", "RIGHT", 20, 0};
      callback = function(value, isGUI, isUpdate) ria:alpha(value) end;
    };
    {
      id = "hPadding";
      text = "Horizontal Padding (%1.0f)";
      tooltipText = "The horizontal distance between runes.";
      minText = "Close";
      maxText = "Far";
      minValue = -25;
      maxValue = 25;
      valueStep = 1.0;
      type = CONTROLTYPE_SLIDER;
      defaultValue = "3";
      point = {"TOP", "alphaInCombat", "BOTTOM", 0, -25};
      callback = function(value, isGUI, isUpdate) ria:setH(value) end;
    };
    {
      id = "vPadding";
      text = "Vertical Padding (%1.0f)";
      tooltipText = "The vertical distance between runes.";
      minText = "Close";
      maxText = "Far";
      minValue = -25;
      maxValue = 25;
      valueStep = 1.0;
      type = CONTROLTYPE_SLIDER;
      defaultValue = "-18";
      point = {"LEFT", "hPadding", "RIGHT", 20, 0};
      callback = function(value, isGUI, isUpdate) ria:setV(value) end;
    };
    {
      id = "CDHeader";
      text = "Cooldown Text";
      type = CONTROLTYPE_HEADER;
      point = {nil, "hPadding", nil, nil, nil};
    };
    {
      id = "cdEnabled";
      text = "Enabled";
      tooltipText = "Check this to have cooldown timers appear on your runes.";
      type = CONTROLTYPE_CHECKBOX;
      defaultValue = "0";
    };
    {
      id = "cdTextColor";
      headerText = "Cooldown Text Colors";
      type = CONTROLTYPE_DROPDOWN;
      defaultValue = "DEFAULT";
      menuList = {
        {
          text = "Default";
          value = "DEFAULT";
        };
        {
          text = "Rune Colors";
          value = "RUNE_COLORS";
        };
        {
          text = "Custom (Color Picker)";
          value = "CUSTOM_COLOR";
        };
      };
    };
    {
      id = "cdCustomColorPicker";
      text = "Custom Color";
      type = CONTROLTYPE_COLORPICKER;
      hasOpacity = true;
      defaultValue = {r=0.5, g=1, b=0.75, opacity=1};
      point = {"LEFT", "cdTextColor", "RIGHT", 40, 0};
    };
    {
      id = "cdTextFontSize";
      text = "Cooldown Font Size (%1.0f)";
      tooltipText = "The font size of the cooldown count text.";
      minText = "Small";
      maxText = "Large";
      minValue = 10;
      maxValue = 25;
      valueStep = 1.0;
      type = CONTROLTYPE_SLIDER;
      defaultValue = "14";
      point = {"LEFT", "cdEnabled", "RIGHT", 150, 0};
      callback = function(value, isGUI, isUpdate) ria:setCdFontSize(value) end;
    };
    -- {
    --   id = "runeType";
    --   headerText = "Rune Art Type";
    --   type = CONTROLTYPE_DROPDOWN;
    --   defaultValue = "DEATH";
    --   menuList = {
    --     {
    --       text = "Death";
    --       value = "Death";
    --     };
    --     {
    --       text = "Blood";
    --       value = "Blood";
    --     };
    --     {
    --       text = "Frost";
    --       value = "Frost";
    --     };
    --     {
    --       text = "Unholy";
    --       value = "Unholy";
    --     };
    --     {
    --       text = "My Current Spec";
    --       value = "SPEC";
    --     }
    --   };
    --   point = {"LEFT", "cdTextAlpha", "RIGHT", 25, 0};
    --   callback = function(value, isGUI, isUpdate) if not isUpdate then ria:images(riaDb.textureChoice) end end;
    -- };
  };
  savedVarTable = "riaDb";
}

Portfolio.RegisterOptionSet(optionTable)
