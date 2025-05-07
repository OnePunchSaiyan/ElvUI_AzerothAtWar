local E, L, V, P, G = unpack(ElvUI)
local LSM = LibStub("LibSharedMedia-3.0");
local UF = E:GetModule("UnitFrames")
local CT = E:GetModule("CustomTweaks")
local isEnabled = E.private["unitframe"].enable and E.private["CustomTweaks"] and E.private["CustomTweaks"]["SecondaryHealthBarTexture"] and true or false

--Cache global variables
---
-- GLOBALS: AceGUIWidgetLSMlists
---

P["CustomTweaks"]["SecondaryHealthBarTexture"] = {
	["secondaryhealthstatusbar"] = "ElvUI Norm",
}

local function ConfigTable()
	E.Options.args.CustomTweaks.args.Unitframe.args.options.args.SecondaryHealthBarTexture = {
		type = "group",
		name = "SecondaryHealthBarTexture",
		get = function(info) return E.db.CustomTweaks.SecondaryHealthBarTexture[info[#info]] end,
		set = function(info, value) E.db.CustomTweaks.SecondaryHealthBarTexture[info[#info]] = value; UF:Update_AllFrames() end,
		args = {
			secondaryhealthstatusbar = {
				order = 1,
				type = "select", dialogControl = "LSM30_Statusbar",
				name = L["Secondary HealthBar Texture"],
				disabled = function() return not isEnabled end,
				values = AceGUIWidgetLSMlists.statusbar,
			},
		},  
	}
end
CT.Configs["SecondaryHealthBarTexture"] = ConfigTable
if not isEnabled then return; end

local function UpdateStatusBars(_, frame)
    if frame.unitframeType == "target" or frame.unitframeType == "targettarget" or frame.unitframeType == "boss" or frame.unitframeType == "arena" then
        local statusBarTexture = LSM:Fetch("statusbar", E.db.CustomTweaks.SecondaryHealthBarTexture.secondaryhealthstatusbar)
	    local health = frame.Health
		if health == nil then
			SendChatMessage("Target Health nil")
		end
	    UF.statusbars[health] = nil
	    if health and health:GetObjectType() == "StatusBar" and not health.isTransparent then
		    health:SetStatusBarTexture(statusBarTexture)
		    health.texture = statusBarTexture --Update .texture for oUF
	    elseif health and health:GetObjectType() == "Texture" then
		    health:SetStatusBarTexture(statusBarTexture)
	    end
    end
end
hooksecurefunc(UF, "Configure_HealthBar", UpdateStatusBars)