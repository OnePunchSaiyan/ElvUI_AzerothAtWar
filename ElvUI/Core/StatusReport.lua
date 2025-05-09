local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local Skins = E:GetModule("Skins")

--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame
local GetAddOnInfo = GetAddOnInfo
local GetCurrentResolution = GetCurrentResolution
local GetCVar = GetCVar
local GetLocale = GetLocale
local GetNumAddOns = GetNumAddOns
local GetRealZoneText = GetRealZoneText
local GetScreenResolutions = GetScreenResolutions

local function AreOtherAddOnsEnabled()
	local name, loadable, reason, _
	for i = 1, GetNumAddOns() do
		name, _, _, loadable, reason = GetAddOnInfo(i)
		if (name ~= "ElvUI" and name ~= "ElvUI_OptionsUI") and (loadable or (not loadable and reason == "DEMAND_LOADED")) then --Loaded or load on demand
			return "Yes"
		end
	end

	return "No"
end

local function GetDisplayMode()
	local window, maximize = GetCVar("gxWindow"), GetCVar("gxMaximize")
	local displayMode

	if window == "1" then
		if maximize == "1" then
			displayMode = "Windowed (Fullscreen)"
		else
			displayMode = "Windowed"
		end
	else
		displayMode = "Fullscreen"
	end

	return displayMode
end

local EnglishClassName = {
	["DEATHKNIGHT"] = "Death Knight",
	["DRUID"] = "Druid",
	["HUNTER"] = "Hunter",
	["MAGE"] = "Mage",
	["PALADIN"] = "Paladin",
	["PRIEST"] = "Priest",
	["ROGUE"] = "Rogue",
	["SHAMAN"] = "Shaman",
	["WARLOCK"] = "Warlock",
	["WARRIOR"] = "Warrior",
	["NECROMANCER"] = "Necromancer",
}

local EnglishSpecName = {
	DEATHKNIGHT = {
		"Blood",
		"Frost",
		"Unholy"
	},
	DRUID = {
		"Balance",
		"Feral",
		"Guardian",
		"Restoration"
	},
	HUNTER = {
		"Beast Mastery",
		"Marksmanship",
		"Survival"
	},
	MAGE = {
		"Arcane",
		"Fire",
		"Frost"
	},
	PALADIN = {
		"Holy",
		"Protection",
		"Retribution"
	},
	PRIEST = {
		"Discipline",
		"Holy",
		"Shadow"
	},
	ROGUE = {
		"Assasination",
		"Combat",
		"Sublety"
	},
	SHAMAN = {
		"Elemental",
		"Enhancement",
		"Restoration"
	},
	WARLOCK = {
		"Affliction",
		"Demonoligy",
		"Destruction"
	},
	WARRIOR = {
		"Arms",
		"Fury",
		"Protection"	
	},
	NECROMANCER = {
		"Necrolord",
		"Plaguebringer",
		"Lichdom"
	}
}

local function GetSpecName()
	local specIdx, specName = E:GetTalentSpecInfo()

	if (specIdx and specIdx ~= 0) and (specName and specName ~= "") then
		return EnglishSpecName[E.myclass][specIdx]
	else
		return "None"
	end
end

local function GetResolution()
	return (({GetScreenResolutions()})[GetCurrentResolution()] or GetCVar("gxWindowedResolution"))
end

function E:CreateStatusFrame()
	local function CreateSection(width, height, parent, anchor1, anchorTo, anchor2, yOffset)
		local section = CreateFrame("Frame", nil, parent)
		section:Size(width, height)
		section:Point(anchor1, anchorTo, anchor2, 0, yOffset)

		section.Header = CreateFrame("Frame", nil, section)
		section.Header:Size(300, 30)
		section.Header:Point("TOP", section)

		section.Header.Text = section.Header:CreateFontString(nil, "ARTWORK", "NumberFont_Outline_Large")
		section.Header.Text:Point("TOP")
		section.Header.Text:Point("BOTTOM")
		section.Header.Text:SetJustifyH("CENTER")
		section.Header.Text:SetJustifyV("MIDDLE")
		local font, fontHeight, flags = section.Header.Text:GetFont()
		section.Header.Text:SetFont(font, fontHeight*1.3, flags)

		section.Header.LeftDivider = section.Header:CreateTexture(nil, "ARTWORK")
		section.Header.LeftDivider:Height(8)
		section.Header.LeftDivider:Point("LEFT", section.Header, "LEFT", 5, 0)
		section.Header.LeftDivider:Point("RIGHT", section.Header.Text, "LEFT", -5, 0)
		section.Header.LeftDivider:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		section.Header.LeftDivider:SetTexCoord(0.81, 0.94, 0.5, 1)

		section.Header.RightDivider = section.Header:CreateTexture(nil, "ARTWORK")
		section.Header.RightDivider:Height(8)
		section.Header.RightDivider:Point("RIGHT", section.Header, "RIGHT", -5, 0)
		section.Header.RightDivider:Point("LEFT", section.Header.Text, "RIGHT", 5, 0)
		section.Header.RightDivider:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
		section.Header.RightDivider:SetTexCoord(0.81, 0.94, 0.5, 1)

		return section
	end

	local function CreateContentLines(num, parent, anchorTo)
		local content = CreateFrame("Frame", nil, parent)
		content:Size(240, (num * 20) + ((num - 1) * 5)) --20 height and 5 spacing
		content:Point("TOP", anchorTo, "BOTTOM", 0, -5)
		for i = 1, num do
			local line = CreateFrame("Frame", nil, content)
			line:Size(240, 20)
			line.Text = line:CreateFontString(nil, "ARTWORK", "NumberFont_Outline_Large")
			line.Text:SetAllPoints()
			line.Text:SetJustifyH("LEFT")
			line.Text:SetJustifyV("MIDDLE")
			content["Line"..i] = line

			if i == 1 then
				content["Line"..i]:Point("TOP", content, "TOP")
			else
				content["Line"..i]:Point("TOP", content["Line"..(i - 1)], "BOTTOM", 0, -5)
			end
		end

		return content
	end

	--Main frame
	local StatusFrame = CreateFrame("Frame", "ElvUIStatusReport", E.UIParent)
	StatusFrame:Size(300, 640)
	StatusFrame:Point("CENTER", E.UIParent, "CENTER")
	StatusFrame:SetFrameStrata("HIGH")
	StatusFrame:CreateBackdrop("Transparent", nil, true)
	StatusFrame:Hide()
	StatusFrame:CreateCloseButton()
	StatusFrame:SetClampedToScreen(true)
	StatusFrame:SetMovable(true)
	StatusFrame:EnableMouse(true)
	StatusFrame:RegisterForDrag("LeftButton", "RightButton")
	StatusFrame:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	StatusFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)

	--Title logo
	StatusFrame.TitleLogoFrame = CreateFrame("Frame", nil, StatusFrame)
	StatusFrame.TitleLogoFrame:Size(128, 64)
	StatusFrame.TitleLogoFrame:SetPoint("CENTER", StatusFrame, "TOP", 0, 0)
	StatusFrame.TitleLogoFrame.Texture = StatusFrame.TitleLogoFrame:CreateTexture(nil, "ARTWORK")
	StatusFrame.TitleLogoFrame.Texture:SetTexture(E.Media.Textures.Logo)
	StatusFrame.TitleLogoFrame.Texture:SetAllPoints()

	--Sections
	StatusFrame.Section1 = CreateSection(300, 150, StatusFrame, "TOP", StatusFrame, "TOP", -30)
	StatusFrame.Section2 = CreateSection(300, 175, StatusFrame, "TOP", StatusFrame.Section1, "BOTTOM", 0)
	StatusFrame.Section3 = CreateSection(300, 220, StatusFrame, "TOP", StatusFrame.Section2, "BOTTOM", 0)
	StatusFrame.Section4 = CreateSection(300, 60, StatusFrame, "TOP", StatusFrame.Section3, "BOTTOM", 0)

	--Section headers
	StatusFrame.Section1.Header.Text:SetText("|cfffe7b2cAddOn Info|r")
	StatusFrame.Section2.Header.Text:SetText("|cfffe7b2cWoW Info|r")
	StatusFrame.Section3.Header.Text:SetText("|cfffe7b2cCharacter Info|r")
	StatusFrame.Section4.Header.Text:SetText("|cfffe7b2cExport To|r")

	--Section content
	StatusFrame.Section1.Content = CreateContentLines(4, StatusFrame.Section1, StatusFrame.Section1.Header)
	StatusFrame.Section2.Content = CreateContentLines(5, StatusFrame.Section2, StatusFrame.Section2.Header)
	StatusFrame.Section3.Content = CreateContentLines(7, StatusFrame.Section3, StatusFrame.Section3.Header)
	StatusFrame.Section4.Content = CreateFrame("Frame", nil, StatusFrame.Section4)
	StatusFrame.Section4.Content:Size(240, 25)
	StatusFrame.Section4.Content:SetPoint("TOP", StatusFrame.Section4.Header, "BOTTOM", 0, 0)

	--Content lines
	StatusFrame.Section1.Content.Line1.Text:SetFormattedText("Version of ElvUI: |cff4beb2c%s|r", E.version)
	StatusFrame.Section1.Content.Line2.Text:SetFormattedText("Other AddOns Enabled: |cff4beb2c%s|r", AreOtherAddOnsEnabled())
	StatusFrame.Section1.Content.Line3.Text:SetFormattedText("Recommended Scale: |cff4beb2c%s|r", E:PixelBestSize())
	StatusFrame.Section1.Content.Line4.Text:SetFormattedText("UI Scale Is: |cff4beb2c%s|r", E.global.general.UIScale)

	StatusFrame.Section2.Content.Line1.Text:SetFormattedText("Version of WoW: |cff4beb2c%s (build %s)|r", E.wowpatch, E.wowbuild)
	StatusFrame.Section2.Content.Line2.Text:SetFormattedText("Client Language: |cff4beb2c%s|r", GetLocale())
	StatusFrame.Section2.Content.Line3.Text:SetFormattedText("Display Mode: |cff4beb2c%s|r", GetDisplayMode())
	StatusFrame.Section2.Content.Line4.Text:SetFormattedText("Resolution: |cff4beb2c%s|r", GetResolution())
	StatusFrame.Section2.Content.Line5.Text:SetFormattedText("Using Mac Client: |cff4beb2c%s|r", (E.isMacClient == true and "Yes" or "No"))

	StatusFrame.Section3.Content.Line1.Text:SetFormattedText("Faction: |cff4beb2c%s|r", E.myfaction)
	StatusFrame.Section3.Content.Line2.Text:SetFormattedText("Race: |cff4beb2c%s|r", E.myrace)
	StatusFrame.Section3.Content.Line3.Text:SetFormattedText("Class: |cff4beb2c%s|r", EnglishClassName[E.myclass])
	StatusFrame.Section3.Content.Line4.Text:SetFormattedText("Specialization: |cff4beb2c%s|r", GetSpecName())
	StatusFrame.Section3.Content.Line5.Text:SetFormattedText("Level: |cff4beb2c%s|r", E.mylevel)
	StatusFrame.Section3.Content.Line6.Text:SetFormattedText("Zone: |cff4beb2c%s|r", GetRealZoneText())
	StatusFrame.Section3.Content.Line7.Text:SetFormattedText("Realm: |cff4beb2c%s|r", E.myrealm)

	--Export buttons
	StatusFrame.Section4.Content.Button1 = CreateFrame("Button", nil, StatusFrame.Section4.Content, "UIPanelButtonTemplate")
	StatusFrame.Section4.Content.Button1:Size(100, 25)
	StatusFrame.Section4.Content.Button1:Point("LEFT", StatusFrame.Section4.Content, "LEFT")
	StatusFrame.Section4.Content.Button1:SetText("Forum")
	StatusFrame.Section4.Content.Button1:SetButtonState("DISABLED")
	Skins:HandleButton(StatusFrame.Section4.Content.Button1, true)

	StatusFrame.Section4.Content.Button2 = CreateFrame("Button", nil, StatusFrame.Section4.Content, "UIPanelButtonTemplate")
	StatusFrame.Section4.Content.Button2:Size(100, 25)
	StatusFrame.Section4.Content.Button2:Point("RIGHT", StatusFrame.Section4.Content, "RIGHT")
	StatusFrame.Section4.Content.Button2:SetText("Ticket")
	StatusFrame.Section4.Content.Button2:SetButtonState("DISABLED")
	Skins:HandleButton(StatusFrame.Section4.Content.Button2, true)

	E.StatusFrame = StatusFrame
end

local function UpdateDynamicValues()
	E.StatusFrame.Section2.Content.Line3.Text:SetFormattedText("Display Mode: |cff4beb2c%s|r", GetDisplayMode())
	E.StatusFrame.Section2.Content.Line4.Text:SetFormattedText("Resolution: |cff4beb2c%s|r", GetResolution())
	E.StatusFrame.Section3.Content.Line4.Text:SetFormattedText("Specialization: |cff4beb2c%s|r", GetSpecName())
	E.StatusFrame.Section3.Content.Line5.Text:SetFormattedText("Level: |cff4beb2c%s|r", E.mylevel)
	E.StatusFrame.Section3.Content.Line6.Text:SetFormattedText("Zone: |cff4beb2c%s|r", GetRealZoneText())
end

function E:ShowStatusReport()
	if not self.StatusFrame then
		self:CreateStatusFrame()
	end

	if not self.StatusFrame:IsShown() then
		UpdateDynamicValues()
		self.StatusFrame:Raise() --Set framelevel above everything else
		self.StatusFrame:Show()
	else
		self.StatusFrame:Hide()
	end
end