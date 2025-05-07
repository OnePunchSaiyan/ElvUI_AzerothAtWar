local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule("UnitFrames")

local class = select(2, UnitClass("player"))

local customRangeSpells = {
    ["NECROMANCER"] = {
        ["Death & Decay"] = 30,
        ["Deathchill Bolt"] = 30,
        ["Frost Nova"] = 30,
        ["Gift of the Damned"] = 30,
        ["Shadowfrost Armor"] = 40,
        ["Ice Spike"] = 30,
        ["Shadow Shock"] = 30,
        ["Drain Essence"] = 30,
        ["Rebuild Minion"] = 30,
        ["Hold Undead"] = 30,
        ["Corpse Explosion"] = 30,
        ["Summon Necromantic Crystal"] = 10,
        ["Raise Ally"] = 30,
        ["Ghostly Skull"] = 30,
        ["Unholy Frenzy"] = 30,
        ["Plague of Exertion"] = 30,
        ["Plaguebolt"] = 35,
        ["Necrotic Plague"] = 30,
        ["Cripple"] = 30,
        ["Sapping Plague"] = 30,
        ["Plague of Brittleness"] = 30,
        ["Plague of Undeath"] = 30,
        ["Fatiguing Plague"] = 30,
        ["Plague Cauldron"] = 10,
        ["Blight"] = 40,
        ["Ice Tomb"] = 30,
        ["Frostblast"] = 30,
        ["Lich Form"] = 100,

    },
    -- Add other class spell data as needed
}

local function SafeUpdateRangeCheckSpells()
    if not UF.RangeCheckSpells or next(UF.RangeCheckSpells) == nil then
        local spells = customRangeSpells[class]
        if spells then
            E:Print("ElvUI_RangeFix: Applied fallback range check for class:", class)
            UF.RangeCheckSpells = spells
        else
            E:Print("ElvUI_RangeFix: No fallback range check data found for class:", class)  --Throws errors for all other classes when update fires need to fix
        end
    end
end

-- Patch ElvUI's internal function
hooksecurefunc(UF, "UpdateRangeCheckSpells", SafeUpdateRangeCheckSpells)
