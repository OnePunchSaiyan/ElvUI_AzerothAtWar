local addonName, CF = ...

CF.db = {
    enableClassPatch = true,
    enableColorPatch = true
}

local function patchClassGlobals()
    if not CF.db.enableClassPatch then return end

    -- Initialize the class globals if they're missing
    if not LOCALIZED_CLASS_NAMES_MALE then
        LOCALIZED_CLASS_NAMES_MALE = {}
    end
    if not LOCALIZED_CLASS_NAMES_FEMALE then
        LOCALIZED_CLASS_NAMES_FEMALE = {}
    end

    local fallbackNames = {
        WARRIOR = "Warrior", MAGE = "Mage", PRIEST = "Priest",
        PALADIN = "Paladin", SHAMAN = "Shaman", DRUID = "Druid",
        ROGUE = "Rogue", HUNTER = "Hunter", WARLOCK = "Warlock",
        DEATHKNIGHT = "Death Knight", NECROMANCER = "Necromancer"
    }

    for class, name in pairs(fallbackNames) do
        -- Only overwrite if the class name is still missing
        LOCALIZED_CLASS_NAMES_MALE[class] = LOCALIZED_CLASS_NAMES_MALE[class] or name
        LOCALIZED_CLASS_NAMES_FEMALE[class] = LOCALIZED_CLASS_NAMES_FEMALE[class] or name
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    if not _G["MMHolder"] and _G["Minimap"] then
        local mm = _G["Minimap"]
        local holder = CreateFrame("Frame", "MMHolder", UIParent)
        holder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -20, -20)
        holder:SetSize(mm:GetWidth(), mm:GetHeight())
        mm:ClearAllPoints()
        mm:SetPoint("CENTER", holder, "CENTER")
        print("MMHolder safely created and positioned.")
    end
end)

local function patchRaidClassColors()
    if not CF.db.enableColorPatch then return end

    -- Ensure RAID_CLASS_COLORS is initialized properly
    if not RAID_CLASS_COLORS then
        RAID_CLASS_COLORS = {}
    end

    -- Prevent overwriting RAID_CLASS_COLORS if it's already set
    if next(RAID_CLASS_COLORS) then return end

    -- Define class colors
    RAID_CLASS_COLORS = {
        HUNTER = { r = 0.67, g = 0.83, b = 0.45 },
        WARRIOR = { r = 0.4, g = 0.21, b = 0.43 },
        PALADIN = { r = 0.96, g = 0.55, b = 0.73 },
        MAGE = { r = 0.41, g = 0.8, b = 0.94 },
        PRIEST = { r = 1.0, g = 1.0, b = 1.0 },
        NECROMANCER = { r = 0.0, g = 0.45, b = 0.45 },
        WARLOCK = { r = 0.58, g = 0.51, b = 0.79 },
        DEATHKNIGHT = { r = 0.77, g = 0.12, b = 0.23 },
        DRUID = { r = 1.0, g = 0.49, b = 0.04 },
        SHAMAN = { r = 0.0, g = 0.44, b = 0.87 },
        ROGUE = { r = 1.0, g = 0.96, b = 0.41 },
    }
end

local function onEvent()
    patchClassGlobals()
    patchRaidClassColors()
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == addonName then
        onEvent()
    end
end)
