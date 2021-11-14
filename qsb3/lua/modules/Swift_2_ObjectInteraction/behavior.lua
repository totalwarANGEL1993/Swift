--[[
Swift_2_ObjectInteraction/Behavior

Copyright (C) 2021 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]


---
-- Stellt neue Behavior für Objekte bereit.
--
-- @within Beschreibung
-- @set sort=true
--

---
-- Der Spieler muss bis zu 4 interaktive Objekte benutzen.
--
-- @param[type=string] _Object1 Erstes Objekt
-- @param[type=string] _Object2 (optional) Zweites Objekt
-- @param[type=string] _Object3 (optional) Drittes Objekt
-- @param[type=string] _Object4 (optional) Viertes Objekt
--
-- @within Goal
--
function Goal_ActivateSeveralObjects(...)
    return B_Goal_ActivateSeveralObjects:new(...);
end

B_Goal_ActivateSeveralObjects = {
    Name = "Goal_ActivateSeveralObjects",
    Description = {
        en = "Goal: Activate an interactive object",
        de = "Ziel: Aktiviere ein interaktives Objekt",
    },
    Parameter = {
        { ParameterType.Default, en = "Object name 1", de = "Skriptname 1" },
        { ParameterType.Default, en = "Object name 2", de = "Skriptname 2" },
        { ParameterType.Default, en = "Object name 3", de = "Skriptname 3" },
        { ParameterType.Default, en = "Object name 4", de = "Skriptname 4" },
    },
    ScriptNames = {};
}

function B_Goal_ActivateSeveralObjects:GetGoalTable()
    return {Objective.Object, { unpack(self.ScriptNames) } }
end

function B_Goal_ActivateSeveralObjects:AddParameter(_Index, _Parameter)
    if _Index == 0 then
        assert(_Parameter ~= nil and _Parameter ~= "", "Goal_ActivateSeveralObjects: At least one IO needed!");
    end
    if _Parameter ~= nil and _Parameter ~= "" then
        table.insert(self.ScriptNames, _Parameter);
    end
end

function B_Goal_ActivateSeveralObjects:GetMsgKey()
    return "Quest_Object_Activate"
end

Swift:RegisterBehavior(B_Goal_ActivateSeveralObjects);
