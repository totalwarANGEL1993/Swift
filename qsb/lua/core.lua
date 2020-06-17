-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia Core                                                         # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Hier werden wichtige Basisfunktionen bereitgestellt. Diese Funktionen sind
-- auch in der Minimalkonfiguration der QSB vorhanden und essentiell für alle
-- anderen Bundles.
--
-- @set sort=true
--

API = API or {};
QSB = QSB or {};
QSB.Version = "Version 2.9.3 17/6/2020";
QSB.HumanPlayerID = 1;
QSB.Language = "de";
QSB.HistoryEdition = false;

QSB.ScriptingValues = {
    Game = "Vanilla",
    Vanilla = {
        Destination = {X = 19, Y= 20},
        Health      = -41,
        Player      = -71,
        Size        = -45,
        Visible     = -50,
    },
    HistoryEdition = {
        Destination = {X = 17, Y= 18},
        Health      = -38,
        Player      = -68,
        Size        = -42,
        Visible     = -47,
    }
}

QSB.Placeholders = {
    Names = {},
    EntityTypes = {},
};

---
-- Farben, die als Platzhalter genutzt werden können.
--
-- Verwendung:
-- <pre>{YOUR_COLOR}</pre>
-- Ersetze YOUR_COLOR mit einer der gelisteten Farben.
--
-- @field red     Rot
-- @field blue    Blau
-- @field yellow  Gelp
-- @field green   Grün
-- @field white   Weiß
-- @field black   Schwarz
-- @field grey    Grau
-- @field azure   Azurblau
-- @field orange  Orange
-- @field amber   Bernstein
-- @field violet  Violett
-- @field pink    Rosa
-- @field scarlet Scharlachrot
-- @field magenta Magenta
-- @field olive   Olivgrün
-- @field ocean   Ozeanblau
-- @field lucid   Transparent
--
QSB.Placeholders.Colors = {
    red     = "{@color:255,80,80,255}",
    blue    = "{@color:104,104,232,255}",
    yellow  = "{@color:255,255,80,255}",
    green   = "{@color:80,180,0,255}",
    white   = "{@color:255,255,255,255}",
    black   = "{@color:0,0,0,255}",
    grey    = "{@color:140,140,140,255}",
    azure   = "{@color:0,160,190,255}",
    orange  = "{@color:255,176,30,255}",
    amber   = "{@color:224,197,117,255}",
    violet  = "{@color:180,100,190,255}",
    pink    = "{@color:255,170,200,255}",
    scarlet = "{@color:190,0,0,255}",
    magenta = "{@color:190,0,89,255}",
    olive   = "{@color:74,120,0,255}",
    sky     = "{@color:145,170,210,255}",
    lucid   = "{@color:0,0,0,0}"
};

-- Mögliche (zufällige) Siedler getrennt in männlich und weiblich.
QSB.PossibleSettlerTypes = {
    Male = {
        Entities.U_BannerMaker,
        Entities.U_Baker,
        Entities.U_Barkeeper,
        Entities.U_Blacksmith,
        Entities.U_Butcher,
        Entities.U_BowArmourer,
        Entities.U_BowMaker,
        Entities.U_CandleMaker,
        Entities.U_Carpenter,
        Entities.U_DairyWorker,
        Entities.U_Pharmacist,
        Entities.U_Tanner,
        Entities.U_SmokeHouseWorker,
        Entities.U_Soapmaker,
        Entities.U_SwordSmith,
        Entities.U_Weaver,
    },
    Female = {
        Entities.U_BathWorker,
        Entities.U_SpouseS01,
        Entities.U_SpouseS02,
        Entities.U_SpouseS03,
        Entities.U_SpouseF01,
        Entities.U_SpouseF02,
        Entities.U_SpouseF03,
    }
}

QSB.RealTime_SecondsSinceGameStart = 0;

ParameterType = ParameterType or {};
g_QuestBehaviorVersion = 1;
g_QuestBehaviorTypes = {};

---
-- AddOn Versionsnummer
-- @local
--
g_GameExtraNo = 0;
if Framework then
    g_GameExtraNo = Framework.GetGameExtraNo();
elseif MapEditor then
    g_GameExtraNo = MapEditor.GetGameExtraNo();
end

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --

---
-- Initialisiert alle verfügbaren Bundles und führt ihre Install-Methode aus.
--
-- Bundles werden immer getrennt im globalen und im lokalen Skript gestartet.
-- Diese Funktion muss zwingend im globalen und lokalen Skript ausgeführt
-- werden, bevor die QSB verwendet werden kann.
--
-- @within Anwenderfunktionen
--
function API.Install()
    Core:InitalizeBundles();
end

-- General ---------------------------------------------------------------------

---
-- Kopiert eine komplette Table und gibt die Kopie zurück. Tables können
-- nicht durch Zuweisungen kopiert werden. Verwende diese Funktion. Wenn ein
-- Ziel angegeben wird, ist die zurückgegebene Table eine Vereinigung der 2
-- angegebenen Tables.
-- Die Funktion arbeitet rekursiv.
--
-- <p><b>Alias:</b> CopyTableRecursive</p>
--
-- @param[type=table] _Source Quelltabelle
-- @param[type=table] _Dest   (optional) Zieltabelle
-- @return[type=table] Kopie der Tabelle
-- @within Anwenderfunktionen
-- @usage Table = {1, 2, 3, {a = true}}
-- Copy = API.InstanceTable(Table)
--
function API.InstanceTable(_Source, _Dest)
    _Dest = _Dest or {};
    assert(type(_Source) == "table")
    assert(type(_Dest) == "table")

    for k, v in pairs(_Source) do
        if type(v) == "table" then
            _Dest[k] = _Dest[k] or {};
            for kk, vv in pairs(API.InstanceTable(v)) do
                _Dest[k][kk] = _Dest[k][kk] or vv;
            end
        else
            _Dest[k] = _Dest[k] or v;
        end
    end
    return _Dest;
end
CopyTableRecursive = API.InstanceTable;

---
-- Sucht in einer eindimensionalen Table nach einem Wert. Das erste Auftreten
-- des Suchwerts wird als Erfolg gewertet.
--
-- Es können praktisch alle Lua-Werte gesucht werden, obwohl dies nur für
-- Strings und Numbers wirklich sinnvoll ist.
--
-- <p><b>Alias:</b> Inside</p>
--
-- @param             _Data Gesuchter Eintrag (multible Datentypen)
-- @param[type=table] _Table Tabelle, die durchquert wird
-- @return[type=booelan] Wert gefunden
-- @within Anwenderfunktionen
-- @usage Table = {1, 2, 3, {a = true}}
-- local Found = API.TraverseTable(3, Table)
--
function API.TraverseTable(_Data, _Table)
    for k,v in pairs(_Table) do
        if v == _Data then
            return true;
        end
    end
    return false;
end
Inside = API.TraverseTable;

---
-- Schreibt ein genaues Abbild der Table ins Log. Funktionen, Threads und
-- Metatables werden als Adresse geschrieben.
--
-- @param[type=table]  _Table Tabelle, die gedumpt wird
-- @param[type=string] _Name Optionaler Name im Log
-- @within Anwenderfunktionen
-- @local
-- @usage Table = {1, 2, 3, {a = true}}
-- API.DumpTable(Table)
--
function API.DumpTable(_Table, _Name)
    local Start = "{";
    if _Name then
        Start = _Name.. " = \n" ..Start;
    end
    Framework.WriteToLog(Start);

    for k, v in pairs(_Table) do
        if type(v) == "table" then
            Framework.WriteToLog("[" ..k.. "] = ");
            API.DumpTable(v);
        elseif type(v) == "string" then
            Framework.WriteToLog("[" ..k.. "] = \"" ..v.. "\"");
        else
            Framework.WriteToLog("[" ..k.. "] = " ..tostring(v));
        end
    end
    Framework.WriteToLog("}");
end

---
-- Konvertiert alle Strings, Booleans und Numbers einer Tabelle in
-- einen String. Die Funktion ist rekursiv, d.h. es werden auch alle
-- Untertabellen mit konvertiert. Alles was kein Number, Boolean oder
-- String ist, wird als Adresse geschrieben.
--
-- @param[type=table] _Table Table zum konvertieren
-- @return[type=string] Converted table
-- @within Anwenderfunktionen
-- @local
--
function API.ConvertTableToString(_Table)
    assert(type(_Table) == "table");
    local TableString = "{";
    for k, v in pairs(_Table) do
        local key;
        if (tonumber(k)) then
            key = ""..k;
        else
            key = "\""..k.."\"";
        end

        if type(v) == "table" then
            TableString = TableString .. "[" .. key .. "] = " .. API.ConvertTableToString(v) .. ", ";
        elseif type(v) == "number" then
            TableString = TableString .. "[" .. key .. "] = " .. v .. ", ";
        elseif type(v) == "string" then
            TableString = TableString .. "[" .. key .. "] = \"" .. v .. "\", ";
        elseif type(v) == "boolean" or type(v) == "nil" then
            TableString = TableString .. "[" .. key .. "] = " .. tostring(v) .. ", ";
        else
            TableString = TableString .. "[" .. key .. "] = \"" .. tostring(v) .. "\", ";
        end
    end
    TableString = TableString .. "}";
    return TableString
end

---
-- Rundet eine Dezimalzahl kaufmännisch ab.
--
-- <b>Hinweis</b>: Es wird manuell gerundet um den Rundungsfehler in der
-- History Edition zu umgehen.
--
-- <p><b>Alias:</b> Round</p>
--
-- @param[type=string] _Value         Zu rundender Wert
-- @param[type=string] _DecimalDigits Maximale Dezimalstellen
-- @return[type=number] Abgerundete Zahl
-- @within Anwenderfunktionen
--
function API.Round(_Value, _DecimalDigits)
    _DecimalDigits = _DecimalDigits or 2;
    _DecimalDigits = (_DecimalDigits < 0 and 0) or _DecimalDigits;
    local Value = tostring(_Value);
    if tonumber(Value) == nil then
        return 0;
    end
    local s,e = Value:find(".", 1, true);
    if e then
        if Value:len() > e + _DecimalDigits then
            local Overhead;
            if _DecimalDigits > 0 then
                local TmpNum;
                if tonumber(Value:sub(e+_DecimalDigits+1, e+_DecimalDigits+1)) >= 5 then
                    TmpNum = tonumber(Value:sub(e+1, e+_DecimalDigits)) +1;
                    Overhead = (_DecimalDigits == 1 and TmpNum == 10);
                else
                    TmpNum = tonumber(Value:sub(e+1, e+_DecimalDigits));
                end
                Value = Value:sub(1, e-1);
                if (tostring(TmpNum):len() >= _DecimalDigits) then
                    Value = Value .. "." ..TmpNum;
                end
            else
                local NewValue = tonumber(Value:sub(1, e-1));
                if tonumber(Value:sub(e+_DecimalDigits+1, e+_DecimalDigits+1)) >= 5 then
                    NewValue = NewValue +1;
                end
                Value = NewValue;
            end
        else
            Value = (Overhead and (tonumber(Value) or 0) +1) or
                     Value .. string.rep("0", Value:len() - (e + _DecimalDigits))
        end
    end
    return tonumber(Value);
end
Round = API.Round;

-- Quests ----------------------------------------------------------------------

---
-- Gibt die ID des Quests mit dem angegebenen Namen zurück. Existiert der
-- Quest nicht, wird nil zurückgegeben.
--
-- <p><b>Alias:</b> GetQuestID</p>
--
-- @param[type=string] _Name Name des Quest
-- @return[type=number] ID des Quest
-- @within Anwenderfunktionen
--
function API.GetQuestID(_Name)
    if type(_Name) == "number" then
        return _Name;
    end
    for k, v in pairs(Quests) do
        if v and k > 0 then
            if v.Identifier == _Name then
                return k;
            end
        end
    end
end
GetQuestID = API.GetQuestID;

---
-- Prüft, ob zu der angegebenen ID ein Quest existiert. Wird ein Questname
-- angegeben wird dessen Quest-ID ermittelt und geprüft.
--
-- <p><b>Alias:</b> IsValidQuest</p>
--
-- @param[type=number] _QuestID ID oder Name des Quest
-- @return[type=boolean] Quest existiert
-- @within Anwenderfunktionen
--
function API.IsValidQuest(_QuestID)
    return Quests[_QuestID] ~= nil or Quests[API.GetQuestID(_QuestID)] ~= nil;
end
IsValidQuest = API.IsValidQuest;

---
-- Lässt eine Liste von Quests fehlschlagen.
--
-- Der Status wird auf Over und das Resultat auf Failure gesetzt.
--
-- <p><b>Alias:</b> FailQuestsByName</p>
--
-- @param[type=string] ... Liste mit Quests
-- @within Anwenderfunktionen
-- @local
--
function API.FailAllQuests(...)
    for i=1, #arg, 1 do
        API.FailQuest(arg[i]);
    end
end
FailQuestsByName = API.FailAllQuests;

---
-- Lässt den Quest fehlschlagen.
--
-- Der Status wird auf Over und das Resultat auf Failure gesetzt.
--
-- <p><b>Alias:</b> FailQuestByName</p>
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _Verbose   Meldung nicht anzeigen
-- @within Anwenderfunktionen
--
function API.FailQuest(_QuestName, _Verbose)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if not _Verbose then
            API.Note("fail quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        if BundleQuestGeneration then
            BundleQuestGeneration.Global:OnQuestStateSupposedChanged(QSB.QuestStateChange.BeforeFailure, Quest);
        end
        Quest:Fail();
    end
end
FailQuestByName = API.FailQuest;

---
-- Startet eine Liste von Quests neu.
--
-- <p><b>Alias:</b> StartQuestsByName</p>
--
-- @param[type=string] ... Liste mit Quests
-- @within Anwenderfunktionen
-- @local
--
function API.RestartAllQuests(...)
    for i=1, #arg, 1 do
        API.RestartQuest(arg[i]);
    end
end
RestartQuestsByName = API.RestartAllQuests;

---
-- Startet den Quest neu.
--
-- Der Quest muss beendet sein um ihn wieder neu zu starten. Wird ein Quest
-- neu gestartet, müssen auch alle Trigger wieder neu ausgelöst werden, außer
-- der Quest wird manuell getriggert.
--
-- Alle Änderungen an Standardbehavior müssen hier berücksichtigt werden. Wird
-- ein Standardbehavior in einem Bundle verändert, muss auch diese Funktion
-- angepasst oder überschrieben werden.
--
-- <p><b>Alias:</b> RestartQuestByName</p>
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _Verbose   Meldung nicht anzeigen
-- @within Anwenderfunktionen
--
function API.RestartQuest(_QuestName, _Verbose)
    local QuestID = GetQuestID(_QuestName);
    local Quest = Quests[QuestID];
    if Quest then
        if not _Verbose then
            API.Note("restart quest " .._QuestName);
        end

        if Quest.Objectives then
            local questObjectives = Quest.Objectives;
            for i = 1, questObjectives[0] do
                local objective = questObjectives[i];
                objective.Completed = nil
                local objectiveType = objective.Type;

                if objectiveType == Objective.Deliver then
                    local data = objective.Data;
                    data[3] = nil;
                    data[4] = nil;
                    data[5] = nil;

                elseif g_GameExtraNo and g_GameExtraNo >= 1 and objectiveType == Objective.Refill then
                    objective.Data[2] = nil;

                elseif objectiveType == Objective.Protect or objectiveType == Objective.Object then
                    local data = objective.Data;
                    for j=1, data[0], 1 do
                        data[-j] = nil;
                    end

                elseif objectiveType == Objective.DestroyEntities and objective.Data[1] == 2 and objective.DestroyTypeAmount then
                    objective.Data[3] = objective.DestroyTypeAmount;
                elseif objectiveType == Objective.DestroyEntities and objective.Data[1] == 3 then
                    objective.Data[4] = nil;

                elseif objectiveType == Objective.Distance then
                    if objective.Data[1] == -65565 then
                        objective.Data[4].NpcInstance = nil;
                    end

                elseif objectiveType == Objective.Custom2 and objective.Data[1].Reset then
                    objective.Data[1]:Reset(Quest, i);
                end
            end
        end

        local function resetCustom(_type, _customType)
            local Quest = Quest;
            local behaviors = Quest[_type];
            if behaviors then
                for i = 1, behaviors[0] do
                    local behavior = behaviors[i];
                    if behavior.Type == _customType then
                        local behaviorDef = behavior.Data[1];
                        if behaviorDef and behaviorDef.Reset then
                            behaviorDef:Reset(Quest, i);
                        end
                    end
                end
            end
        end

        resetCustom("Triggers", Triggers.Custom2);
        resetCustom("Rewards", Reward.Custom);
        resetCustom("Reprisals", Reprisal.Custom);

        Quest.Result = nil;
        local OldQuestState = Quest.State;
        Quest.State = QuestState.NotTriggered;
        Logic.ExecuteInLuaLocalState("LocalScriptCallback_OnQuestStatusChanged("..Quest.Index..")");
        if OldQuestState == QuestState.Over then
            StartSimpleJobEx(_G[QuestTemplate.Loop], Quest.QueueID);
        end
        return QuestID, Quest;
    end
end
RestartQuestByName = API.RestartQuest;

---
-- Startet eine Liste von Quests.
--
-- <p><b>Alias:</b> StartQuestsByName</p>
--
-- @param[type=string] ... Liste mit Quests
-- @within Anwenderfunktionen
-- @local
--
function API.StartAllQuests(...)
    for i=1, #arg, 1 do
        API.StartQuest(arg[i]);
    end
end
StartQuestsByName = API.StartAllQuests;

---
-- Startet den Quest sofort, sofern er existiert.
--
-- Dabei ist es unerheblich, ob die Bedingungen zum Start erfüllt sind.
--
-- <p><b>Alias:</b> StartQuestByName</p>
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _Verbose   Meldung nicht anzeigen
-- @within Anwenderfunktionen
--
function API.StartQuest(_QuestName, _Verbose)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if not _Verbose then
            API.Note("start quest " .._QuestName);
        end
        Quest:SetMsgKeyOverride();
        Quest:SetIconOverride();
        if BundleQuestGeneration then
            BundleQuestGeneration.Global:OnQuestStateSupposedChanged(QSB.QuestStateChange.BeforeTrigger, Quest);
        end
        Quest:Trigger();
        if BundleQuestGeneration then
            BundleQuestGeneration.Global:OnQuestStateSupposedChanged(QSB.QuestStateChange.AfterTrigger, Quest);
        end
    end
end
StartQuestByName = API.StartQuest;

---
-- Unterbricht eine Liste von Quests.
--
-- <p><b>Alias:</b> StopQuestsByName</p>
--
-- @param[type=string] ... Liste mit Quests
-- @within Anwenderfunktionen
-- @local
--
function API.StopAllQuests(...)
    for i=1, #arg, 1 do
        API.StopQuest(arg[i]);
    end
end
StopQuestsByName = API.StopAllQuests;

---
-- Unterbricht den Quest.
--
-- Der Status wird auf Over und das Resultat auf Interrupt gesetzt. Sind Marker
-- gesetzt, werden diese entfernt.
--
-- <p><b>Alias:</b> StopQuestByName</p>
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _Verbose   Meldung nicht anzeigen
-- @within Anwenderfunktionen
--
function API.StopQuest(_QuestName, _Verbose)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if not _Verbose then
            API.Note("interrupt quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        Quest:Interrupt(-1);
    end
end
StopQuestByName = API.StopQuest;

---
-- Gewinnt eine Liste von Quests.
--
-- Der Status wird auf Over und das Resultat auf Success gesetzt.
--
-- <p><b>Alias:</b> WinQuestsByName</p>
--
-- @param[type=string] ... Liste mit Quests
-- @within Anwenderfunktionen
-- @local
--
function API.WinAllQuests(...)
    for i=1, #arg, 1 do
        API.WinQuest(arg[i]);
    end
end
WinQuestsByName = API.WinAllQuests;

---
-- Gewinnt den Quest.
--
-- Der Status wird auf Over und das Resultat auf Success gesetzt.
--
-- <p><b>Alias:</b> WinQuestByName</p>
--
-- @param[type=string]  _QuestName Name des Quest
-- @param[type=boolean] _Verbose   Meldung nicht anzeigen
-- @within Anwenderfunktionen
--
function API.WinQuest(_QuestName, _Verbose)
    local Quest = Quests[GetQuestID(_QuestName)];
    if Quest then
        if not _Verbose then
            API.Note("win quest " .._QuestName);
        end
        Quest:RemoveQuestMarkers();
        if BundleQuestGeneration then
            BundleQuestGeneration.Global:OnQuestStateSupposedChanged(QSB.QuestStateChange.BeforeSuccess, InfoQuest);
        end
        Quest:Success();
    end
end
WinQuestByName = API.WinQuest;

-- Messages --------------------------------------------------------------------

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und ist nicht statisch.
--
-- <p><b>Alias:</b> GUI_Note</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
-- @local
--
function API.Note(_Message)
    _Message = API.ConvertPlaceholders(API.Localize(_Message));
    local MessageFunc = Logic.DEBUG_AddNote;
    if GUI then
        MessageFunc = GUI.AddNote;
    end
    MessageFunc(_Message);
end
GUI_Note = API.Note;

---
-- Schreibt eine Nachricht in das Debug Window. Der Text erscheint links am
-- Bildschirm und verbleibt dauerhaft am Bildschirm.
--
-- <p><b>Alias:</b> GUI_StaticNote</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
--
function API.StaticNote(_Message)
    _Message = API.ConvertPlaceholders(API.Localize(_Message));
    if not GUI then
        Logic.ExecuteInLuaLocalState('GUI.AddStaticNote("' .._Message.. '")');
        return;
    end
    GUI.AddStaticNote(_Message);
end
GUI_StaticNote = API.StaticNote;

---
-- Löscht alle Nachrichten im Debug Window.
--
-- @within Anwenderfunktionen
--
function API.ClearNotes()
    if not GUI then
        Logic.ExecuteInLuaLocalState('GUI.ClearNotes()');
        return;
    end
    GUI.ClearNotes();
end

---
-- Schreibt eine Nachricht in das Nachrichtenfenster unten in der Mitte.
--
-- <p><b>Alias:</b> GUI_NoteDown</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
--
function API.Message(_Message)
    _Message = API.Localize(_Message);
    if not GUI then
        Logic.ExecuteInLuaLocalState('Message("' .._Message.. '")');
        return;
    end
    Message(_Message);
end
GUI_NoteDown = API.Message;

---
-- Ermittelt den lokalisierten Text anhand der eingestellten Sprache der QSB.
--
-- Wird ein normaler String übergeben, wird dieser sofort zurückgegeben.
--
-- @param _Message Anzeigetext (String oder Table)
-- @return[type=string] Message
-- @within Anwenderfunktionen
-- @local
--
function API.Localize(_Message)
    if type(_Message) == "table" then
        local MessageText = _Message[QSB.Language];
        if MessageText then
            return MessageText;
        end
        if _Message.en then
            return _Message.en;
        end
        return tostring(_Message);
    end
    return tostring(_Message);
end

---
-- Schreibt einen FATAL auf den Bildschirm und ins Log.
--
-- <p><b>Alias:</b> API.Dbg</p>
-- <p><b>Alias:</b> fatal</p>
-- <p><b>Alias:</b> dbg</p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
-- @local
--
function API.Fatal(_Message)
    API.StaticNote("FATAL: " .._Message)
    Framework.WriteToLog("FATAL: " .._Message);
end
API.Dbg = API.Fatal;
fatal = API.Fatal;
dbg = API.Fatal;

---
-- Schreibt eine WARNING auf den Bildschirm und ins Log.
--
-- <p><p><b>Alias:</b> warn</p></p>
--
-- @param[type=string] _Message Anzeigetext
-- @within Anwenderfunktionen
-- @local
--
function API.Warn(_Message)
    API.StaticNote("WARNING: " .._Message)
    Framework.WriteToLog("WARNING: " .._Message);
end
warn = API.Warn;

-- Placeholders ----------------------------------------------------------------

---
-- Ersetzt alle Platzhalter im Text oder in der Table.
--
-- Mögliche Platzhalter:
-- <ul>
-- <li>{name:xyz} - Ersetzt einen Skriptnamen mit dem zuvor gesetzten Wert.</li>
-- <li>{type:xyz} - Ersetzt einen Typen mit dem zuvor gesetzten Wert.</li>
-- </ul>
--
-- Außerdem werden einige Standardfarben ersetzt.
-- @see QSB.Placeholders.Colors
--
-- @param _Message Text oder Table mit Texten
-- @return Ersetzter Text
-- @within Anwenderfunktionen
--
function API.ConvertPlaceholders(_Message)
    if type(_Message) == "table" then
        for k, v in pairs(_Message) do
            _Message[k] = Core:ConvertPlaceholders(v);
        end
        return _Message;
    elseif type(_Message) == "string" then
        return Core:ConvertPlaceholders(_Message);
    else
        return _Message;
    end
end

---
-- Fügt einen Platzhalter für den angegebenen Namen hinzu.
--
-- Innerhalb des Textes wird der Plathalter wie folgt geschrieben:
-- <pre>{name:YOUR_NAME}</pre>
-- YOUR_NAME muss mit dem Namen ersetzt werden.
--
-- @param[type=string] _Name        Name, der ersetzt werden soll
-- @param[type=string] _Replacement Wert, der ersetzt wird
-- @within Anwenderfunktionen
--
function API.AddNamePlaceholder(_Name, _Replacement)
    if type(_Replacement) == "function" or type(_Replacement) == "thread" then
        fatal("API.AddNamePlaceholder: Only strings, numbers, or tables are allowed!");
        return;
    end
    QSB.Placeholders.Names[_Name] = _Replacement;
end

---
-- Fügt einen Platzhalter für einen Entity-Typ hinzu.
--
-- Innerhalb des Textes wird der Plathalter wie folgt geschrieben:
-- <pre>{name:ENTITY_TYP}</pre>
-- ENTITY_TYP muss mit einem Entity-Typ ersetzt werden. Der Typ wird ohne
-- Entities. davor geschrieben.
--
-- @param[type=string] _Name        Scriptname, der ersetzt werden soll
-- @param[type=string] _Replacement Wert, der ersetzt wird
-- @within Anwenderfunktionen
--
function API.AddEntityTypePlaceholder(_Type, _Replacement)
    if Entities[_Type] == nil then
        fatal("API.AddEntityTypePlaceholder: EntityType does not exist!");
        return;
    end
    QSB.Placeholders.EntityTypes[_Type] = _Replacement;
end

-- Entities --------------------------------------------------------------------

---
-- Sendet einen Handelskarren zu dem Spieler. Startet der Karren von einem
-- Gebäude, wird immer die Position des Eingangs genommen.
--
-- <p><b>Alias:</b> SendCart</p>
--
-- @param _position                        Position (Skriptname oder Positionstable)
-- @param[type=number] _player             Zielspieler
-- @param[type=number] _good               Warentyp
-- @param[type=number] _amount             Warenmenge
-- @param[type=number] _cartOverlay        (optional) Overlay für Goldkarren
-- @param[type=boolean] _ignoreReservation (optional) Marktplatzreservation ignorieren
-- @return[type=number] Entity-ID des erzeugten Wagens
-- @within Anwenderfunktionen
-- @usage -- API-Call
-- API.SendCart(Logic.GetStoreHouse(1), 2, Goods.G_Grain, 45)
-- -- Legacy-Call mit ID-Speicherung
-- local ID = SendCart("Position_1", 5, Goods.G_Wool, 5)
--
function API.SendCart(_position, _player, _good, _amount, _cartOverlay, _ignoreReservation)
    local eID = GetID(_position);
    if not IsExisting(eID) then
        return;
    end
    local ID;
    local x,y,z = Logic.EntityGetPos(eID);
    local resCat = Logic.GetGoodCategoryForGoodType(_good);
    local orientation = 0;
    if Logic.IsBuilding(eID) == 1 then
        x,y = Logic.GetBuildingApproachPosition(eID);
        orientation = Logic.GetEntityOrientation(eID)-90;
    end

    if resCat == GoodCategories.GC_Resource then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_ResourceMerchant, x, y,orientation,_player)
    elseif _good == Goods.G_Medicine then
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Medicus, x, y,orientation,_player)
    elseif _good == Goods.G_Gold or _good == Goods.G_None or _good == Goods.G_Information then
        if _cartOverlay then
            ID = Logic.CreateEntityOnUnblockedLand(_cartOverlay, x, y,orientation,_player)
        else
            ID = Logic.CreateEntityOnUnblockedLand(Entities.U_GoldCart, x, y,orientation,_player)
        end
    else
        ID = Logic.CreateEntityOnUnblockedLand(Entities.U_Marketer, x, y,orientation,_player)
    end
    Logic.HireMerchant( ID, _player, _good, _amount, _player, _ignoreReservation)
    return ID
end
SendCart = API.SendCart;

---
-- Ersetzt ein Entity mit einem neuen eines anderen Typs. Skriptname,
-- Rotation, Position und Besitzer werden übernommen.
--
-- <b>Hinweis</b>: Die Entity-ID ändert sich und beim Ersetzen von
-- Spezialgebäuden kann eine Niederlage erfolgen.
--
-- <p><b>Alias:</b> ReplaceEntity</p>
--
-- @param _Entity      Entity (Skriptname oder ID)
-- @param[type=number] _Type     Neuer Typ
-- @param[type=number] _NewOwner (optional) Neuer Besitzer
-- @return[type=number] Entity-ID des Entity
-- @within Anwenderfunktionen
-- @usage API.ReplaceEntity("Stein", Entities.XD_ScriptEntity)
--
function API.ReplaceEntity(_Entity, _Type, _NewOwner)
    local eID = GetID(_Entity);
    if eID == 0 then
        return;
    end
    local pos = GetPosition(eID);
    local player = _NewOwner or Logic.EntityGetPlayer(eID);
    local orientation = Logic.GetEntityOrientation(eID);
    local name = Logic.GetEntityName(eID);
    DestroyEntity(eID);
    if Logic.IsEntityTypeInCategory(_Type, EntityCategories.Soldier) == 1 then
        return CreateBattalion(player, _Type, pos.X, pos.Y, 1, name, orientation);
    else
        return CreateEntity(player, _Type, pos, name, orientation);
    end
end
ReplaceEntity = API.ReplaceEntity;

---
-- Rotiert ein Entity, sodass es zum Ziel schaut.
--
-- <p><b>Alias:</b> LookAt</p>
--
-- @param _entity         Entity (Skriptname oder ID)
-- @param _entityToLookAt Ziel (Skriptname oder ID)
-- @param[type=number]    _offsetEntity Winkel Offset
-- @within Anwenderfunktionen
-- @usage API.LookAt("Hakim", "Alandra")
--
function API.LookAt(_entity, _entityToLookAt, _offsetEntity)
    local entity = GetEntityId(_entity);
    local entityTLA = GetEntityId(_entityToLookAt);
    if not IsExisting(entity) or not IsExisting(entityTLA) then
        API.Warn("API.LookAt: One entity is invalid or dead!");
        return;
    end
    local eX, eY = Logic.GetEntityPosition(entity);
    local eTLAX, eTLAY = Logic.GetEntityPosition(entityTLA);
    local orientation = math.deg( math.atan2( (eTLAY - eY) , (eTLAX - eX) ) );
    if Logic.IsBuilding(entity) == 1 then
        orientation = orientation - 90;
    end
    _offsetEntity = _offsetEntity or 0;
    Logic.SetOrientation(entity, API.Round(orientation + _offsetEntity));
end
LookAt = API.LookAt;

---
-- Lässt zwei Entities sich gegenseitig anschauen.
--
-- @param _entity         Entity (Skriptname oder ID)
-- @param _entityToLookAt Ziel (Skriptname oder ID)
-- @within Anwenderfunktionen
-- @usage API.Confront("Hakim", "Alandra")
--
function API.Confront(_entity, _entityToLookAt)
    API.LookAt(_entity, _entityToLookAt);
    API.LookAt(_entityToLookAt, _entity);
end

---
-- Bestimmt die Distanz zwischen zwei Punkten. Es können Entity-IDs,
-- Skriptnamen oder Positionstables angegeben werden.
--
-- Wenn die Distanz nicht bestimmt werden kann, wird -1 zurückgegeben.
--
-- <p><b>Alias:</b> GetDistance</p>
--
-- @param _pos1 Erste Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @param _pos2 Zweite Vergleichsposition (Skriptname, ID oder Positions-Table)
-- @return[type=number] Entfernung zwischen den Punkten
-- @within Anwenderfunktionen
-- @usage local Distance = API.GetDistance("HQ1", Logic.GetKnightID(1))
--
function API.GetDistance( _pos1, _pos2 )
    if (type(_pos1) == "string") or (type(_pos1) == "number") then
        _pos1 = GetPosition(_pos1);
    end
    if (type(_pos2) == "string") or (type(_pos2) == "number") then
        _pos2 = GetPosition(_pos2);
    end
    if type(_pos1) ~= "table" or type(_pos2) ~= "table" then
        return -1;
    end
    local xDistance = (_pos1.X - _pos2.X);
    local yDistance = (_pos1.Y - _pos2.Y);
    return math.sqrt((xDistance^2) + (yDistance^2));
end
GetDistance = API.GetDistance;

---
-- Prüft, ob eine Positionstabelle eine gültige Position enthält.
--
-- Eine Position ist Ungültig, wenn sie sich nicht auf der Welt befindet.
-- Das ist der Fall bei negativen Werten oder Werten, welche die Größe
-- der Welt übersteigen.
--
-- <p><b>Alias:</b> IsValidPosition</p>
--
-- @param[type=table] _pos Positionstable {X= x, Y= y}
-- @return[type=boolean] Position ist valide
-- @within Anwenderfunktionen
--
function API.ValidatePosition(_pos)
    if type(_pos) == "table" then
        if (_pos.X ~= nil and type(_pos.X) == "number") and (_pos.Y ~= nil and type(_pos.Y) == "number") then
            local world = {Logic.WorldGetSize()}
            if _pos.Z and _pos.Z < 0 then
                return false;
            end
            if _pos.X <= world[1] and _pos.X >= 0 and _pos.Y <= world[2] and _pos.Y >= 0 then
                return true;
            end
        end
    end
    return false;
end
IsValidPosition = API.ValidatePosition;

---
-- Lokalisiert ein Entity auf der Map. Es können sowohl Skriptnamen als auch
-- IDs verwendet werden. Wenn das Entity nicht gefunden wird, wird eine
-- Tabelle mit XYZ = 0 zurückgegeben.
--
-- <p><b>Alias:</b> GetPosition</p>
--
-- @param _Entity Entity (Skriptname oder ID)
-- @return[type=table] Positionstabelle {X= x, Y= y, Z= z}
-- @within Anwenderfunktionen
-- @usage local Position = API.LocateEntity("Hans")
--
function API.LocateEntity(_Entity)
    if (type(_Entity) == "table") then
        return _Entity;
    end
    if (not IsExisting(_Entity)) then
        return {X= 0, Y= 0, Z= 0};
    end
    local x, y, z = Logic.EntityGetPos(GetID(_Entity));
    return {X= API.Round(x), Y= API.Round(y), Z= API.Round(y)};
end
GetPosition = API.LocateEntity;

---
-- Aktiviert ein interaktives Objekt, sodass es benutzt werden kann.
--
-- Der State bestimmt, ob es immer aktiviert werden kann, oder ob der Spieler
-- einen Helden benutzen muss. Wird der Parameter weggelassen, muss immer ein
-- Held das Objekt aktivieren.
--
-- <p><b>Alias:</b> InteractiveObjectActivate</p>
--
-- @param[type=string] _ScriptName  Skriptname des IO
-- @param[type=number] _State       Aktivierungszustand
-- @within Anwenderfunktionen
-- @usage API.ActivateIO("Haus1", 0)
-- API.ActivateIO("Hut1")
--
function API.ActivateIO(_ScriptName, _State)
    _State = _State or 0;
    if GUI then
        GUI.SendScriptCommand('API.ActivateIO("' .._ScriptName.. '", ' .._State..')');
        return;
    end
    if not IsExisting(_ScriptName) then
        return
    end
    Logic.InteractiveObjectSetAvailability(GetID(_ScriptName), true);
    for i = 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, _State);
    end
end
InteractiveObjectActivate = API.ActivateIO;

---
-- Deaktiviert ein Interaktives Objekt, sodass es nicht mehr vom Spieler
-- aktiviert werden kann.
--
-- <p><b>Alias:</b> InteractiveObjectDeactivate</p>
--
-- @param[type=string] _ScriptName Skriptname des IO
-- @within Anwenderfunktionen
-- @usage API.DeactivateIO("Hut1")
--
function API.DeactivateIO(_ScriptName)
    if GUI then
        GUI.SendScriptCommand('API.DeactivateIO("' .._ScriptName.. '")');
        return;
    end
    if not IsExisting(_ScriptName) then
        return;
    end
    Logic.InteractiveObjectSetAvailability(GetID(_ScriptName), false);
    for i = 1, 8 do
        Logic.InteractiveObjectSetPlayerState(GetID(_ScriptName), i, 2);
    end
end
InteractiveObjectDeactivate = API.DeactivateIO;

---
-- Ermittelt alle Entities in der Kategorie auf dem Territorium und gibt
-- sie als Liste zurück.
--
-- <p><b>Alias:</b> GetEntitiesOfCategoryInTerritory</p>
--
-- @param[type=number] _player    PlayerID [0-8] oder -1 für alle
-- @param[type=number] _category  Kategorie, der die Entities angehören
-- @param[type=number] _territory Zielterritorium
-- @within Anwenderfunktionen
-- @usage local Found = API.GetEntitiesOfCategoryInTerritory(1, EntityCategories.Hero, 5)
--
function API.GetEntitiesOfCategoryInTerritory(_player, _category, _territory)
    local PlayerEntities = {};
    local Units = {};
    if (_player == -1) then
        for i=0,8 do
            local NumLast = 0;
            repeat
                Units = { Logic.GetEntitiesOfCategoryInTerritory(_territory, i, _category, NumLast) };
                PlayerEntities = Array_Append(PlayerEntities, Units);
                NumLast = NumLast + #Units;
            until #Units == 0;
        end
    else
        local NumLast = 0;
        repeat
            Units = { Logic.GetEntitiesOfCategoryInTerritory(_territory, _player, _category, NumLast) };
            PlayerEntities = Array_Append(PlayerEntities, Units);
            NumLast = NumLast + #Units;
        until #Units == 0;
    end
    return PlayerEntities;
end
GetEntitiesOfCategoryInTerritory = API.GetEntitiesOfCategoryInTerritory;

---
-- Gibt dem Entity einen eindeutigen Skriptnamen und gibt ihn zurück.
-- Hat das Entity einen Namen, bleibt dieser unverändert und wird
-- zurückgegeben.
-- @param[type=number] _EntityID Entity ID
-- @return[type=string] Skriptname
-- @within Anwenderfunktionen
--
function API.EnsureScriptName(_EntityID)
    if type(_EntityID) == "string" then
        return _EntityID;
    else
        assert(type(_EntityID) == "number");
        local name = Logic.GetEntityName(_EntityID);
        if (type(name) ~= "string" or name == "" ) then
            QSB.GiveEntityNameCounter = (QSB.GiveEntityNameCounter or 0)+ 1;
            name = "EnsureScriptName_Name_"..QSB.GiveEntityNameCounter;
            Logic.SetEntityName(_EntityID, name);
        end
        return name;
    end
end
GiveEntityName = API.EnsureScriptName;

---
-- Wählt aus einer Liste von Typen einen zufälligen Siedler-Typ aus. Es werden
-- nur Stadtsiedler zurückgegeben. Sie können männlich oder weiblich sein.
--
-- @return[type=number] Zufälliger Typ
-- @within Anwenderfunktionen
-- @local
--
function API.GetRandomSettlerType()
    local Gender = (math.random(1, 2) == 1 and "Male") or "Female";
    local Type   = math.random(1, #QSB.PossibleSettlerTypes[Gender]);
    return QSB.PossibleSettlerTypes[Gender][Type];
end

---
-- Wählt aus einer Liste von Typen einen zufälligen männlichen Siedler aus. Es
-- werden nur Stadtsiedler zurückgegeben.
--
-- @return[type=number] Zufälliger Typ
-- @within Anwenderfunktionen
-- @local
--
function API.GetRandomMaleSettlerType()
    local Type = math.random(1, #QSB.PossibleSettlerTypes.Male);
    return QSB.PossibleSettlerTypes.Male[Type];
end

---
-- Wählt aus einer Liste von Typen einen zufälligen weiblichen Siedler aus. Es
-- werden nur Stadtsiedler zurückgegeben.
--
-- @return[type=number] Zufälliger Typ
-- @within Anwenderfunktionen
-- @local
--
function API.GetRandomFemaleSettlerType()
    local Type = math.random(1, #QSB.PossibleSettlerTypes.Female);
    return QSB.PossibleSettlerTypes.Female[Type];
end

-- Overwrite -------------------------------------------------------------------

---
-- Schickt einen Skriptbefehl an die jeweils andere Skriptumgebung.
--
-- Wird diese Funktion als dem globalen Skript aufgerufen, sendet sie den
-- Befehl an das lokale Skript. Wird diese Funktion im lokalen Skript genutzt,
-- wird der Befehl an das globale Skript geschickt.
--
-- @param[type=string]  _Command Lua-Befehl als String
-- @param[type=boolean] _Flag FIXME Optional für GUI.SendScriptCommand benötigt. 
--                      Was macht das Flag?
-- @within Anwenderfunktionen
-- @local
--
function API.Bridge(_Command, _Flag)
    if not GUI then
        Logic.ExecuteInLuaLocalState(_Command)
    else
        GUI.SendScriptCommand(_Command, _Flag)
    end
end

---
-- Wandelt underschiedliche Darstellungen einer Boolean in eine echte um.
--
-- Jeder String, der mit j, t, y oder + beginnt, wird als true interpretiert.
-- Alles andere als false.
--
-- Ist die Eingabe bereits ein Boolean wird es direkt zurückgegeben.
--
-- <p><b>Alias:</b> AcceptAlternativeBoolean</p>
--
-- @param _Value Wahrheitswert
-- @return[type=boolean] Wahrheitswert
-- @within Anwenderfunktionen
-- @local
--
-- @usage local Bool = API.ToBoolean("+")  --> Bool = true
-- local Bool = API.ToBoolean("no") --> Bool = false
--
function API.ToBoolean(_Value)
    return Core:ToBoolean(_Value);
end
AcceptAlternativeBoolean = API.ToBoolean;

---
-- Fügt eine Beschreibung zu einem selbst gewählten Hotkey hinzu.
--
-- Ist der Hotkey bereits vorhanden, wird -1 zurückgegeben.
--
-- @param[type=string] _Key         Tastenkombination
-- @param[type=string] _Description Beschreibung des Hotkey
-- @return[type=number] Index oder Fehlercode
-- @within Anwenderfunktionen
--
function API.AddHotKey(_Key, _Description)
    if not GUI then
        API.Fatal("API.AddHotKey: Can not be used from the global script!");
        return;
    end
    g_KeyBindingsOptions.Descriptions = nil;
    table.insert(Core.Data.HotkeyDescriptions, {_Key, _Description});
    return #Core.Data.HotkeyDescriptions;
end

---
-- Entfernt eine Beschreibung eines selbst gewählten Hotkeys.
--
-- @param[type=number] _Index Index in Table
-- @within Anwenderfunktionen
--
function API.RemoveHotKey(_Index)
    if not GUI then
        API.Fatal("API.RemoveHotKey: Can not be used from the global script!");
        return;
    end
    if type(_Index) ~= "number" or _Index > #Core.Data.HotkeyDescriptions then
        API.Fatal("API.RemoveHotKey: No candidate found or Index is nil!");
        return;
    end
    Core.Data.HotkeyDescriptions[_Index] = nil;
end

---
-- Registriert eine Funktion, die nach dem laden ausgeführt wird.
--
-- <b>Alias</b>: AddOnSaveGameLoadedAction
--
-- @param[type=function] _Function Funktion, die ausgeführt werden soll
-- @within Anwenderfunktionen
-- @usage SaveGame = function()
--     API.Note("foo")
-- end
-- API.AddSaveGameAction(SaveGame)
--
function API.AddSaveGameAction(_Function)
    if GUI then
        API.Fatal("API.AddSaveGameAction: Can not be used from the local script!");
        return;
    end
    return Core:AppendFunction("Mission_OnSaveGameLoaded", _Function)
end
AddOnSaveGameLoadedAction = API.AddSaveGameAction;

-- Simple Job Overhaul ---------------------------------------------------------

---
-- Pausiert einen laufenden Job.
--
-- <b>Hinweis</b>: Der Job darf nicht direkt mit Trigger.RequestTrigger
-- gestartet worden sein.
--
-- <b>Alias</b>: YieldJob
--
-- @param[type=number] _JobID Job-ID
-- @within Anwenderfunktionen
--
function API.YieldJob(_JobID)
    for k, v in pairs(Core.Data.EventJobs) do
        if Core.Data.EventJobs[k][_JobID] then
            Core.Data.EventJobs[k][_JobID].Enabled = false;
        end
    end
end
YieldJob = API.YieldJob;

---
-- Aktiviert einen angehaltenen Job.
--
-- <b>Hinweis</b>: Der Job darf nicht direkt mit Trigger.RequestTrigger
-- gestartet worden sein.
--
-- <b>Alias</b>: ResumeJob
--
-- @param[type=number] _JobID Job-ID
-- @within Anwenderfunktionen
--
function API.ResumeJob(_JobID)
    for k, v in pairs(Core.Data.EventJobs) do
        if Core.Data.EventJobs[k][_JobID] then
            Core.Data.EventJobs[k][_JobID].Enabled = true;
        end
    end
end
ResumeJob = API.ResumeJob;

---
-- Prüft ob der angegebene Job aktiv und eingeschaltet ist.
--
-- <b>Alias</b>: JobIsRunning
--
-- @param[type=number] _JobID Job-ID
-- @within Anwenderfunktionen
--
function API.JobIsRunning(_JobID)
    for k, v in pairs(Core.Data.EventJobs) do
        if Core.Data.EventJobs[k][_JobID] then
            if Core.Data.EventJobs[k][_JobID].Active == true and Core.Data.EventJobs[k][_JobID].Enabled == true then
                return true;
            end
        end
    end
    return false;
end
JobIsRunning = API.JobIsRunning;

---
-- Beendet einen aktiven Job endgültig.
--
-- <b>Alias</b>: ResumeJob
--
-- @param[type=number] _JobID Job-ID
-- @within Anwenderfunktionen
--
function API.EndJob(_JobID)
    for k, v in pairs(Core.Data.EventJobs) do
        if Core.Data.EventJobs[k][_JobID] then
            Core.Data.EventJobs[k][_JobID].Active = false;
            return;
        end
    end
end
EndJob = API.EndJob;

---
-- Erzeugt einen neuen Event-Job.
--
-- <b>Hinweis</b>: Nur wenn ein Event Job mit dieser Funktion gestartet wird,
-- können ResumeJob und YieldJob auf den Job angewendet werden.
--
-- <b>Hinweis</b>: Events.LOGIC_EVENT_ENTITY_CREATED funktioniert nicht!
--
-- <b>Hinweis</b>: Wird ein Table als Argument an den Job übergeben, wird eine
-- Kopie angeleigt um Speicherprobleme zu verhindern. Es handelt sich also um
-- eine neue Table und keine Referenz!
--
-- @param[type=number]   _EventType Event-Typ
-- @param _Function      Funktion (Funktionsreferenz oder String)
-- @param ...            Optionale Argumente des Job
-- @return[type=number] ID des Jobs
-- @within Anwenderfunktionen
--
function API.StartEventJob(_EventType, _Function, ...)
    local Function = _Function;
    if type(Function) == "string" then
        Function = _G[Function];
    end
    if type(Function) ~= "function" and type(_Function) == "string" then
        fatal(string.format("API.StartEventJob: Can not find function for name '%s'!", _Function));
        return;
    elseif type(Function) ~= "function" and type(_Function) ~= "string" then
        fatal("API.StartEventJob: Received illegal reference as function!");
        return;
    end

    Core.Data.EventJobID = Core.Data.EventJobID +1;
    local ID = Core.Data.EventJobID
    Core.Data.EventJobs[_EventType][ID] = {
        Function = Function,
        Arguments = API.InstanceTable(arg);
        Active = true,
        Enabled = true,
    }
    return ID;
end

---
-- Fügt eine Funktion als Job hinzu, die einmal pro Sekunde ausgeführt
-- wird. Die Argumente werden an die Funktion übergeben.
--
-- Die Funktion kann als Referenz, Inline oder als String übergeben werden.
--
-- <b>Alias</b>: StartSimpleJobEx
--
-- <b>Alias</b>: StartSimpleJob
--
-- @param _Function Funktion (Funktionsreferenz oder String)
-- @param ...       Liste von Argumenten
-- @return[type=number] Job ID
-- @within Anwenderfunktionen
--
-- @usage -- Führt eine Funktion nach 15 Sekunden aus.
-- API.StartJob(function(_Time, _EntityType)
--     if Logic.GetTime() > _Time + 15 then
--         MachWas(_EntityType);
--         return true;
--     end
-- end, Logic.GetTime(), Entities.U_KnightHealing)
--
-- -- Startet einen Job
-- StartSimpleJob("MeinJob");
--
function API.StartJob(_Function, ...)
    return API.StartEventJob(Events.LOGIC_EVENT_EVERY_SECOND, _Function, unpack(arg));
end
StartSimpleJob = API.StartJob;
StartSimpleJobEx = API.StartJob;

---
-- Fügt eine Funktion als Job hinzu, die zehn Mal pro Sekunde ausgeführt
-- wird. Die Argumente werden an die Funktion übergeben.
--
-- Die Funktion kann als Referenz, Inline oder als String übergeben werden.
--
-- <b>Alias</b>: StartSimpleHiResJobEx
--
-- <b>Alias</b>: StartSimpleHiResJob
--
-- @param _Function Funktion (Funktionsreferenz oder String)
-- @param ...       Liste von Argumenten
-- @return[type=number] Job ID
-- @within Anwenderfunktionen
--
function API.StartHiResJob(_Function, ...)
    return API.StartEventJob(Events.LOGIC_EVENT_EVERY_TURN, _Function, unpack(arg));
end
StartSimpleHiResJob = API.StartHiResJob;
StartSimpleHiResJobEx = API.StartHiResJob;

-- Echtzeit --------------------------------------------------------------------

---
-- Gibt die real vergangene Zeit seit dem Spielstart in Sekunden zurück.
-- @return[type=number] Vergangene reale Zeit
-- @within Anwenderfunktionen
--
function API.RealTimeGetSecondsPassedSinceGameStart()
    return QSB.RealTime_SecondsSinceGameStart;
end

---
-- Wartet die angebene Zeit in realen Sekunden und führt anschließend das
-- Callback aus. Die Ausführung erfolgt asynchron. Das bedeutet, dass das
-- Skript weiterläuft.
--
-- Hinweis: Einmal gestartet, kann wait nicht beendet werden.
--
-- @param[type=number] _Waittime Wartezeit in realen Sekunden
-- @param[type=function] _Action Callback-Funktion
-- @param ... Liste der Argumente
-- @return[type=number] Vergangene reale Zeit
-- @within Anwenderfunktionen
--
function API.RealTimeWait(_Waittime, _Action, ...)
    StartSimpleJobEx( function(_StartTime, _Delay, _Callback, _Arguments)
        if (QSB.RealTime_SecondsSinceGameStart >= _StartTime + _Delay) then
            if #_Arguments > 0 then
                _Callback(unpack(_Arguments));
            else
                _Callback();
            end
            return true;
        end
    end, QSB.RealTime_SecondsSinceGameStart, _Waittime, _Action, {...});
end

-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

Core = {
    Data = {
        EventJobID = 0,
        EventJobs = {
            [Events.LOGIC_EVENT_DIPLOMACY_CHANGED]         = {},
            [Events.LOGIC_EVENT_ENTITY_CREATED]            = {},
            [Events.LOGIC_EVENT_ENTITY_DESTROYED]          = {},
            [Events.LOGIC_EVENT_ENTITY_HURT_ENTITY]        = {},
            [Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY] = {},
            [Events.LOGIC_EVENT_EVERY_SECOND]              = {},
            [Events.LOGIC_EVENT_EVERY_TURN]                = {},
            [Events.LOGIC_EVENT_GOODS_TRADED]              = {},
            [Events.LOGIC_EVENT_PLAYER_DIED]               = {},
            [Events.LOGIC_EVENT_RESEARCH_DONE]             = {},
            [Events.LOGIC_EVENT_TRIBUTE_PAID]              = {},
            [Events.LOGIC_EVENT_WEATHER_STATE_CHANGED]     = {},
        },
        Events = {
            EverySecond = {},
            EveryTurn = {},
            JobIDCounter = 0,
        },
        Overwrite = {
            StackedFunctions = {},
            AppendedFunctions = {},
            Fields = {},
        },
        HotkeyDescriptions = {},
        BundleInitializerList = {},
        InitalizedBundles = {},
    }
}

---
-- Initialisiert alle verfügbaren Bundles und führt ihre Install-Methode aus.
-- Bundles werden immer getrennt im globalen und im lokalen Skript gestartet.
-- @within Internal
-- @local
--
function Core:InitalizeBundles()
    if not GUI then
        QSB.Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";

        self:OverwriteBasePricesAndRefreshRates();
        self:CreateRandomSeedBySystemTime();
        self:SetupGobal_HackCreateQuest();
        self:SetupGlobal_HackQuestSystem();
        self:IdentifyHistoryEdition();

        Trigger.RequestTrigger(Events.LOGIC_EVENT_DIPLOMACY_CHANGED, "", "CoreEventJob_OnDiplomacyChanged", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "CoreEventJob_OnEntityCreated", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "CoreEventJob_OnEntityDestroyed", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "CoreEventJob_OnEntityHurtEntity", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY, "", "CoreEventJob_OnEntityInRangeOfEntity", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "CoreEventJob_OnEverySecond", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "CoreEventJob_OnEveryTurn", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_GOODS_TRADED, "", "CoreEventJob_OnGoodsTraded", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_PLAYER_DIED, "", "CoreEventJob_OnPlayerDied", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_RESEARCH_DONE, "", "CoreEventJob_OnResearchDone", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_TRIBUTE_PAID, "", "CoreEventJob_OnTributePaied", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_WEATHER_STATE_CHANGED, "", "CoreEventJob_OnWatherChanged", 1);
        
        StartSimpleJobEx(Core.EventJob_EventOnEveryRealTimeSecond);
    else
        QSB.Language = (Network.GetDesiredLanguage() == "de" and "de") or "en";

        self:CreateRandomSeedBySystemTime();
        self:SetupLocal_HackRegisterHotkey();
        self:SetupLocal_HistoryEditionAutoSave();

        Trigger.RequestTrigger(Events.LOGIC_EVENT_DIPLOMACY_CHANGED, "", "CoreEventJob_OnDiplomacyChanged", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "CoreEventJob_OnEntityCreated", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "CoreEventJob_OnEntityDestroyed", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY, "", "CoreEventJob_OnEntityHurtEntity", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY, "", "CoreEventJob_OnEntityInRangeOfEntity", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "CoreEventJob_OnEverySecond", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "CoreEventJob_OnEveryTurn", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_GOODS_TRADED, "", "CoreEventJob_OnGoodsTraded", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_PLAYER_DIED, "", "CoreEventJob_OnPlayerDied", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_RESEARCH_DONE, "", "CoreEventJob_OnResearchDone", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_TRIBUTE_PAID, "", "CoreEventJob_OnTributePaied", 1); 
        Trigger.RequestTrigger(Events.LOGIC_EVENT_WEATHER_STATE_CHANGED, "", "CoreEventJob_OnWatherChanged", 1);

        StartSimpleJobEx(Core.EventJob_EventOnEveryRealTimeSecond);
    end

    for k,v in pairs(self.Data.BundleInitializerList) do
        local Bundle = _G[v];
        if not GUI then
            if Bundle.Global ~= nil and Bundle.Global.Install ~= nil then
                Bundle.Global:Install();
                Bundle.Local = nil;
            end
        else
            if Bundle.Local ~= nil and Bundle.Local.Install ~= nil then
                Bundle.Local:Install();
                Bundle.Global = nil;
            end
        end
        self.Data.InitalizedBundles[v] = true;
        collectgarbage();
    end
end

---
-- Führt alle Event Jobs des angegebenen Typen aus und prüft deren Status.
--
-- @param[type=number] _Type Typ des Jobs
-- @within Internal
-- @local
--
function Core:TriggerEventJobs(_Type)
    for k, v in pairs(self.Data.EventJobs[_Type]) do
        if type(v) == "table" then
            if v.Active == false then
                self.Data.EventJobs[_Type][k] = nil;
            else
                if v.Enabled then
                    if v.Function then
                        local Arguments = v.Arguments or {};
                        if v.Function(unpack(Arguments)) == true then
                            self.Data.EventJobs[_Type][k] = nil;
                        end
                    end
                end
            end
        end
    end
end

---
-- Fügt fehlende Einträge für Militäreinheiten bei den Basispreisen
-- und Erneuerungsraten hinzu, damit diese gehandelt werden können.
-- @within Internal
-- @local
--
function Core:OverwriteBasePricesAndRefreshRates()
    MerchantSystem.BasePrices[Entities.U_CatapultCart] = MerchantSystem.BasePrices[Entities.U_CatapultCart] or 1000;
    MerchantSystem.BasePrices[Entities.U_BatteringRamCart] = MerchantSystem.BasePrices[Entities.U_BatteringRamCart] or 450;
    MerchantSystem.BasePrices[Entities.U_SiegeTowerCart] = MerchantSystem.BasePrices[Entities.U_SiegeTowerCart] or 600;
    MerchantSystem.BasePrices[Entities.U_AmmunitionCart] = MerchantSystem.BasePrices[Entities.U_AmmunitionCart] or 180;
    MerchantSystem.BasePrices[Entities.U_MilitarySword_RedPrince] = MerchantSystem.BasePrices[Entities.U_MilitarySword_RedPrince] or 150;
    MerchantSystem.BasePrices[Entities.U_MilitarySword] = MerchantSystem.BasePrices[Entities.U_MilitarySword] or 150;
    MerchantSystem.BasePrices[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.BasePrices[Entities.U_MilitaryBow_RedPrince] or 220;
    MerchantSystem.BasePrices[Entities.U_MilitaryBow] = MerchantSystem.BasePrices[Entities.U_MilitaryBow] or 220;

    MerchantSystem.RefreshRates[Entities.U_CatapultCart] = MerchantSystem.RefreshRates[Entities.U_CatapultCart] or 270;
    MerchantSystem.RefreshRates[Entities.U_BatteringRamCart] = MerchantSystem.RefreshRates[Entities.U_BatteringRamCart] or 190;
    MerchantSystem.RefreshRates[Entities.U_SiegeTowerCart] = MerchantSystem.RefreshRates[Entities.U_SiegeTowerCart] or 220;
    MerchantSystem.RefreshRates[Entities.U_AmmunitionCart] = MerchantSystem.RefreshRates[Entities.U_AmmunitionCart] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.RefreshRates[Entities.U_MilitarySword_RedPrince] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitarySword] = MerchantSystem.RefreshRates[Entities.U_MilitarySword] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow_RedPrince] or 150;
    MerchantSystem.RefreshRates[Entities.U_MilitaryBow] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow] or 150;

    if g_GameExtraNo >= 1 then
        MerchantSystem.BasePrices[Entities.U_MilitaryBow_Khana] = MerchantSystem.BasePrices[Entities.U_MilitaryBow_Khana] or 220;
        MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] = MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] or 150;
        MerchantSystem.BasePrices[Entities.U_MilitarySword_Khana] = MerchantSystem.BasePrices[Entities.U_MilitarySword_Khana] or 150;
        MerchantSystem.RefreshRates[Entities.U_MilitaryBow_Khana] = MerchantSystem.RefreshRates[Entities.U_MilitarySword_Khana] or 150;
    end
end

---
-- Überschreibt CreateQuest für die Anbindung an Symfonia.
-- @within Internal
-- @local
--
function Core:SetupGobal_HackCreateQuest()
    CreateQuest = function(_QuestName, _QuestGiver, _QuestReceiver, _QuestHidden, _QuestTime, _QuestDescription, _QuestStartMsg, _QuestSuccessMsg, _QuestFailureMsg)
        local Triggers = {};
        local Goals = {};
        local Reward = {};
        local Reprisal = {};
        local NumberOfBehavior = Logic.Quest_GetQuestNumberOfBehaviors(_QuestName);

        for i=0, NumberOfBehavior-1, 1 do
            -- Behavior ermitteln
            local BehaviorName = Logic.Quest_GetQuestBehaviorName(_QuestName, i);
            local BehaviorTemplate = GetBehaviorTemplateByName(BehaviorName);
            assert( BehaviorTemplate, "No template for name: " .. BehaviorName .. " - using an invalid QuestSystemBehavior.lua?!");
            local NewBehavior = {};
            Table_Copy(NewBehavior, BehaviorTemplate);
            local Parameter = Logic.Quest_GetQuestBehaviorParameter(_QuestName, i);
            for j=1,#Parameter do
                NewBehavior:AddParameter(j-1, Parameter[j]);
            end

            -- Füge als Goal hinzu
            if (NewBehavior.GetGoalTable ~= nil) then
                Goals[#Goals + 1] = NewBehavior:GetGoalTable();
                Goals[#Goals].Context = NewBehavior;
                Goals[#Goals].FuncOverrideIcon = NewBehavior.GetIcon;
                Goals[#Goals].FuncOverrideMsgKey = NewBehavior.GetMsgKey;
            end
            -- Füge als Trigger hinzu
            if (NewBehavior.GetTriggerTable ~= nil) then
                Triggers[#Triggers + 1] = NewBehavior:GetTriggerTable();
            end
            -- Füge als Reprisal hinzu
            if (NewBehavior.GetReprisalTable ~= nil) then
                Reprisal[#Reprisal + 1] = NewBehavior:GetReprisalTable();
            end
            -- Füge als Reward hinzu
            if (NewBehavior.GetRewardTable ~= nil) then
                Reward[#Reward + 1] = NewBehavior:GetRewardTable();
            end
        end

        -- Prüfe Mindestkonfiguration des Quest
        if (#Triggers == 0) or (#Goals == 0) then
            return;
        end

        -- Erzeuge den Quest
        if Core:CheckQuestName(_QuestName) then
            local QuestID = QuestTemplate:New(
                _QuestName,
                _QuestGiver or 1,
                _QuestReceiver or 1,
                Goals,
                Triggers,
                tonumber(_QuestTime) or 0,
                Reward,
                Reprisal,
                nil, nil,
                (not _QuestHidden or ( _QuestStartMsg and _QuestStartMsg ~= "") ),
                (not _QuestHidden or ( _QuestSuccessMsg and _QuestSuccessMsg ~= "") or ( _QuestFailureMsg and _QuestFailureMsg ~= "") ),
                _QuestDescription,
                _QuestStartMsg,
                _QuestSuccessMsg,
                _QuestFailureMsg
            );
            g_QuestNameToID[_QuestName] = QuestID;
        else
            fatal("Quest '"..tostring(_QuestName).."': invalid questname! Contains forbidden characters!");
        end
    end
end

---
-- Implementiert die vordefinierten Texte für Custom Behavior und den Aufruf
-- der :Interrupt Methode.
-- @within Internal
-- @local
--
function Core:SetupGlobal_HackQuestSystem()
    QuestTemplate.Trigger_Orig_QSB_Core = QuestTemplate.Trigger
    QuestTemplate.Trigger = function(_quest)
        QuestTemplate.Trigger_Orig_QSB_Core(_quest);
        for i=1,_quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].SetDescriptionOverwrite then
                local Desc = _quest.Objectives[i].Data[1]:SetDescriptionOverwrite(_quest);
                Core:ChangeCustomQuestCaptionText(Desc, _quest);
                break;
            end
        end
    end

    QuestTemplate.Interrupt_Orig_QSB_Core = QuestTemplate.Interrupt;
    QuestTemplate.Interrupt = function(_quest)
        QuestTemplate.Interrupt_Orig_QSB_Core(_quest);
        for i=1, _quest.Objectives[0] do
            if _quest.Objectives[i].Type == Objective.Custom2 and _quest.Objectives[i].Data[1].Interrupt then
                _quest.Objectives[i].Data[1]:Interrupt(_quest, i);
            end
        end
        for i=1, _quest.Triggers[0] do
            if _quest.Triggers[i].Type == Triggers.Custom2 and _quest.Triggers[i].Data[1].Interrupt then
                _quest.Triggers[i].Data[1]:Interrupt(_quest, i);
            end
        end
    end
end

---
-- Überschreibt das Hotkey-Register, sodass eigene Hotkeys mit im Menü
-- angezeigt werden können.
-- @within Internal
-- @local
--
function Core:SetupLocal_HackRegisterHotkey()
    function g_KeyBindingsOptions:OnShow()
        if Game ~= nil then
            XGUIEng.ShowWidget("/InGame/KeyBindingsMain/Backdrop", 1);
        else
            XGUIEng.ShowWidget("/InGame/KeyBindingsMain/Backdrop", 0);
        end

        if g_KeyBindingsOptions.Descriptions == nil then
            g_KeyBindingsOptions.Descriptions = {};
            DescRegister("MenuInGame");
            DescRegister("MenuDiplomacy");
            DescRegister("MenuProduction");
            DescRegister("MenuPromotion");
            DescRegister("MenuWeather");
            DescRegister("ToggleOutstockInformations");
            DescRegister("JumpMarketplace");
            DescRegister("JumpMinimapEvent");
            DescRegister("BuildingUpgrade");
            DescRegister("BuildLastPlaced");
            DescRegister("BuildStreet");
            DescRegister("BuildTrail");
            DescRegister("KnockDown");
            DescRegister("MilitaryAttack");
            DescRegister("MilitaryStandGround");
            DescRegister("MilitaryGroupAdd");
            DescRegister("MilitaryGroupSelect");
            DescRegister("MilitaryGroupStore");
            DescRegister("MilitaryToggleUnits");
            DescRegister("UnitSelect");
            DescRegister("UnitSelectToggle");
            DescRegister("UnitSelectSameType");
            DescRegister("StartChat");
            DescRegister("StopChat");
            DescRegister("QuickSave");
            DescRegister("QuickLoad");
            DescRegister("TogglePause");
            DescRegister("RotateBuilding");
            DescRegister("ExitGame");
            DescRegister("Screenshot");
            DescRegister("ResetCamera");
            DescRegister("CameraMove");
            DescRegister("CameraMoveMouse");
            DescRegister("CameraZoom");
            DescRegister("CameraZoomMouse");
            DescRegister("CameraRotate");

            for k,v in pairs(Core.Data.HotkeyDescriptions) do
                if v then
                    v[1] = (type(v[1]) == "table" and API.Localize(v[1])) or v[1];
                    v[2] = (type(v[2]) == "table" and API.Localize(v[2])) or v[2];
                    table.insert(g_KeyBindingsOptions.Descriptions, 1, v);
                end
            end
        end
        XGUIEng.ListBoxPopAll(g_KeyBindingsOptions.Widget.ShortcutList);
        XGUIEng.ListBoxPopAll(g_KeyBindingsOptions.Widget.ActionList);
        for Index, Desc in ipairs(g_KeyBindingsOptions.Descriptions) do
            XGUIEng.ListBoxPushItem(g_KeyBindingsOptions.Widget.ShortcutList, Desc[1]);
            XGUIEng.ListBoxPushItem(g_KeyBindingsOptions.Widget.ActionList,   Desc[2]);
        end
    end
end

---
-- Überschreibt die Hotkey-Funktion, die das Spiel speichert. Durch die
-- Prüfung, ob Briefings oder Cutscenes aktiv sind, wird vermieden, dass
-- die History Edition automatisch speichert.
--
-- @within Internal
-- @local
--
function Core:SetupLocal_HistoryEditionAutoSave()
    KeyBindings_SaveGame_Orig_Core_SaveGame = KeyBindings_SaveGame;
    KeyBindings_SaveGame = function()
        -- In der History Edition wird diese Funktion aufgerufen, wenn der
        -- letzte Spielstand der Map älter als 15 Minuten ist. Wenn ein
        -- Briefing oder eine Cutscene aktiv ist, sollen keine Quicksaves
        -- erstellt werden.
        if not Core:CanGameBeSaved() then
            return;
        end
        KeyBindings_SaveGame_Orig_Core_SaveGame();
    end
end

---
-- Prüft, ob das Spiel gerade gespeichert werden kann.
--
-- @return [boolean]  Speichern ist möglich
-- @within Internal
-- @local
--
function Core:CanGameBeSaved()
    -- Briefing ist aktiv
    if IsBriefingActive and IsBriefingActive() then
        return false;
    end
    -- Cutscene ist aktiv
    if IsCutsceneActive and IsCutsceneActive() then
        return false;
    end
    -- Die Map wird noch geladen
    if GUI and XGUIEng.IsWidgetShownEx("/LoadScreen/LoadScreen") ~= 0 then
        return false;
    end
    return true;
end

---
-- Prüft, ob das Bundle bereits initalisiert ist.
--
-- @param[type=string] _Bundle Name des Moduls
-- @return[type=boolean] Bundle initalisiert
-- @within Internal
-- @local
--
function Core:IsBundleRegistered(_Bundle)
    return self.Data.InitalizedBundles[_Bundle] == true;
end

---
-- Registiert ein Bundle, sodass es initialisiert wird.
--
-- @param[type=string] _Bundle Name des Moduls
-- @within Internal
-- @local
--
function Core:RegisterBundle(_Bundle)
    local text = string.format("Error while initialize bundle '%s': does not exist!", tostring(_Bundle));
    assert(_G[_Bundle] ~= nil, text);
    table.insert(self.Data.BundleInitializerList, _Bundle);
end

---
-- Registiert ein AddOn als Bundle, sodass es initialisiert wird.
--
-- Diese Funktion macht prinziplell das Gleiche wie Core:RegisterBundle und
-- existiert nur zur Übersichtlichkeit.
--
-- @param[type=string] _AddOn Name des Moduls
-- @within Internal
-- @local
--
function Core:RegisterAddOn(_AddOn)
    local text = string.format("Error while initialize addon '%s': does not exist!", tostring(_AddOn));
    assert(_G[_AddOn] ~= nil, text);
    table.insert(self.Data.BundleInitializerList, _AddOn);
end

---
-- Bereitet ein Behavior für den Einsatz im Assistenten und im Skript vor.
-- Erzeugt zudem den Konstruktor.
--
-- @param[type=table] _Behavior Behavior-Objekt
-- @within Internal
-- @local
--
function Core:RegisterBehavior(_Behavior)
    if GUI then
        return;
    end
    if _Behavior.RequiresExtraNo and _Behavior.RequiresExtraNo > g_GameExtraNo then
        return;
    end

    if not _G["b_" .. _Behavior.Name] then
        fatal("AddQuestBehavior: can not find ".. _Behavior.Name .."!");
    else
        if not _G["b_" .. _Behavior.Name].new then
            _G["b_" .. _Behavior.Name].new = function(self, ...)
                local arg = {...}; -- Notwendiger Fix für LuaJ
                local behavior = API.InstanceTable(self);
                behavior.i47ya_6aghw_frxil = {};
                behavior.v12ya_gg56h_al125 = {};
                for i= 1, #arg, 1 do
                    table.insert(behavior.v12ya_gg56h_al125, arg[i]);
                    if self.Parameter and self.Parameter[i] ~= nil then
                        behavior:AddParameter(i-1, arg[i]);
                    else
                        table.insert(behavior.i47ya_6aghw_frxil, arg[i]);
                    end
                end
                return behavior;
            end
        end

        for i= 1, #g_QuestBehaviorTypes, 1 do
            if g_QuestBehaviorTypes[i].Name == _Behavior.Name then
                return;
            end
        end
        table.insert(g_QuestBehaviorTypes, _Behavior);
    end
end

---
-- Prüft, ob der Questname formal korrekt ist. Questnamen dürfen i.d.R. nur
-- die Zeichen A-Z, a-7, 0-9, - und _ enthalten.
--
-- @param[type=string] _Name Name des Quest
-- @return[type=boolean] Questname ist fehlerfrei
-- @within Internal
-- @local
--
function Core:CheckQuestName(_Name)
    return string.find(_Name, "^[A-Za-z0-9_]+$") ~= nil;
end

---
-- Ändert den Text des Beschreibungsfensters eines Quests. Die Beschreibung
-- wird erst dann aktualisiert, wenn der Quest ausgeblendet wird.
--
-- @param[type=string] _Text Neuer Text
-- @param[type=table] _Quest Quest Table
-- @within Internal
-- @local
--
function Core:ChangeCustomQuestCaptionText(_Text, _Quest)
    _Quest.QuestDescription = _Text;
    Logic.ExecuteInLuaLocalState([[
        XGUIEng.ShowWidget("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/BGDeco",0)
        local identifier = "]].._Quest.Identifier..[["
        for i=1, Quests[0] do
            if Quests[i].Identifier == identifier then
                local text = Quests[i].QuestDescription
                XGUIEng.SetText("/InGame/Root/Normal/AlignBottomLeft/Message/QuestObjectives/Custom/Text", "]].._Text..[[")
                break
            end
        end
    ]]);
end

---
-- Erweitert eine Funktion um eine andere Funktion.
--
-- Jede hinzugefügte Funktion wird vor der Originalfunktion ausgeführt. Es
-- ist möglich, eine neue Funktion an einem bestimmten Index einzufügen. Diese
-- Funktion ist nicht gedacht, um sie direkt auszuführen. Für jede Funktion
-- im Spiel sollte eine API-Funktion erstellt werden.
--
-- Wichtig: Die gestapelten Funktionen, die vor der Originalfunktion
-- ausgeführt werden, müssen etwas zurückgeben, um die Funktion an
-- gegebener Stelle zu verlassen.
--
-- @param[type=string]   _FunctionName Name der erweiterten Funktion
-- @param[type=function] _StackFunction Neuer Funktionsinhalt
-- @param[type=number]   _Index Reihenfolgeindex
-- @within Internal
-- @local
--
function Core:StackFunction(_FunctionName, _StackFunction, _Index)
    if not self.Data.Overwrite.StackedFunctions[_FunctionName] then
        self.Data.Overwrite.StackedFunctions[_FunctionName] = {
            Original = self:GetFunctionInString(_FunctionName),
            Attachments = {}
        };

        local batch = function(...)
            local ReturnValue;
            for i= 1, #self.Data.Overwrite.StackedFunctions[_FunctionName].Attachments, 1 do
                local Function = self.Data.Overwrite.StackedFunctions[_FunctionName].Attachments[i];
                ReturnValue = {Function(unpack(arg))};
                if #ReturnValue > 0 then
                    return unpack(ReturnValue);
                end
            end
            ReturnValue = {self.Data.Overwrite.StackedFunctions[_FunctionName].Original(unpack(arg))};
            return unpack(ReturnValue);
        end
        self:ReplaceFunction(_FunctionName, batch);
    end

    _Index = _Index or #self.Data.Overwrite.StackedFunctions[_FunctionName].Attachments+1;
    table.insert(self.Data.Overwrite.StackedFunctions[_FunctionName].Attachments, _Index, _StackFunction);
end

---
-- Erweitert eine Funktion um eine andere Funktion.
--
-- Jede hinzugefügte Funktion wird nach der Originalfunktion ausgeführt. Es
-- ist möglich eine neue Funktion an einem bestimmten Index einzufügen. Diese
-- Funktion ist nicht gedacht, um sie direkt auszuführen. Für jede Funktion
-- im Spiel sollte eine API-Funktion erstellt werden.
--
-- @param[type=string]   _FunctionName Name der erweiterten Funktion
-- @param[type=function] _AppendFunction Neuer Funktionsinhalt
-- @param[type=number]   _Index Reihenfolgeindex
-- @within Internal
-- @local
--
function Core:AppendFunction(_FunctionName, _AppendFunction, _Index)
    if not self.Data.Overwrite.AppendedFunctions[_FunctionName] then
        self.Data.Overwrite.AppendedFunctions[_FunctionName] = {
            Original = self:GetFunctionInString(_FunctionName),
            Attachments = {}
        };

        local batch = function(...)
            local ReturnValue = self.Data.Overwrite.AppendedFunctions[_FunctionName].Original(unpack(arg));
            for i= 1, #self.Data.Overwrite.AppendedFunctions[_FunctionName].Attachments, 1 do
                local Function = self.Data.Overwrite.AppendedFunctions[_FunctionName].Attachments[i];
                ReturnValue = {Function(unpack(arg))};
            end
            return unpack(ReturnValue);
        end
        self:ReplaceFunction(_FunctionName, batch);
    end

    _Index = _Index or #self.Data.Overwrite.AppendedFunctions[_FunctionName].Attachments+1;
    table.insert(self.Data.Overwrite.AppendedFunctions[_FunctionName].Attachments, _Index, _AppendFunction);
end

---
-- Überschreibt eine Funktion mit einer anderen.
--
-- Funktionen in einer Tabelle werden überschrieben, indem jede Ebene des
-- Tables mit einem Punkt angetrennt wird.
--
-- @param[type=string]   _FunctionName Name der erweiterten Funktion
-- @param[type=function] _AppendFunction Neuer Funktionsinhalt
-- @local
-- @within Internal
-- @usage A = {foo = function() API.Note("bar") end}
-- B = function() API.Note("muh") end
-- Core:ReplaceFunction("A.foo", B)
-- -- A.foo() == B() => "muh"
--
function Core:ReplaceFunction(_FunctionName, _Function)
    assert(type(_FunctionName) == "string");
    local ref = _G;

    local s, e = _FunctionName:find("%.");
    while (s ~= nil) do
        local SubName = _FunctionName:sub(1, e-1);
        SubName = (tonumber(SubName) ~= nil and tonumber(SubName)) or SubName;

        ref = ref[SubName];
        _FunctionName = _FunctionName:sub(e+1);
        s, e = _FunctionName:find("%.");
    end

    local SubName = (tonumber(_FunctionName) ~= nil and tonumber(_FunctionName)) or _FunctionName;
    ref[SubName] = _Function;
end

---
-- Sucht eine Funktion mit dem angegebenen Namen.
--
-- Ist die Funktionen innerhalb einer Table, so sind alle Ebenen bis zum
-- Funktionsnamen mit anzugeben, abgetrennt durch einen Punkt.
--
-- @param[type=string] _FunctionName Name der erweiterten Funktion
-- @return[type=function] Referenz auf die Funktion
-- @within Internal
-- @local
--
function Core:GetFunctionInString(_FunctionName)
    assert(type(_FunctionName) == "string");
    local ref = _G;

    local s, e = _FunctionName:find("%.");
    while (s ~= nil) do
        local SubName = _FunctionName:sub(1, e-1);
        SubName = (tonumber(SubName) ~= nil and tonumber(SubName)) or SubName;

        ref = ref[SubName];
        _FunctionName = _FunctionName:sub(e+1);
        s, e = _FunctionName:find("%.");
    end

    local SubName = (tonumber(_FunctionName) ~= nil and tonumber(_FunctionName)) or _FunctionName;
    return ref[SubName];
end

---
-- Wandelt underschiedliche Darstellungen einer Boolean in eine echte um.
--
-- Jeder String, der mit j, t, y oder + beginnt, wird als true interpretiert.
-- Alles andere als false.
--
-- Ist die Eingabe bereits ein Boolean wird es direkt zurückgegeben.
--
-- @param[type=string] _Input Boolean-Darstellung
-- @return[type=boolean] Konvertierte Boolean
-- @within Internal
-- @local
--
function Core:ToBoolean(_Input)
    if type(_Input) == "boolean" then
        return _Input;
    end
    if string.find(string.lower(tostring(_Input)), "^[tjy\\+].*$") then
        return true;
    end
    return false;
end

---
-- Identifiziert anhand der um +3 Verschobenen PlayerID bei den Scripting
-- Values die infamous History Edition. Ob es sich um die History Edition
-- hält, wird in der Variable QSB.HistoryEdition gespeichert.
--
-- TODO: Es sollten mehr Kritieren als nur die PlayerID geprüft werden!
--
-- @within Internal
-- @local
--
function Core:IdentifyHistoryEdition()
    local EntityID = Logic.CreateEntity(Entities.U_NPC_Amma_NE, 100, 100, 0, 8);
    MakeInvulnerable(EntityID);
    if Logic.GetEntityScriptingValue(EntityID, -68) == 8 then
        API.Bridge("QSB.HistoryEdition = true");
        API.Bridge("QSB.ScriptingValues.Game = 'HistoryEdition'");
        QSB.HistoryEdition = true;
        QSB.ScriptingValues.Game = "HistoryEdition";
    end
    DestroyEntity(EntityID);
end

---
-- Setzt den Random Seed für die Erzeugung von Zufallszahlen anhand der
-- aktuellen Systemzeit.
--
-- @return[type=number] Random Seed
-- @within Internal
-- @local
--
function Core:CreateRandomSeedBySystemTime()
    local DateTimeString = Framework.GetSystemTimeDateString();

    local s, e = DateTimeString:find(" ");
    local TimeString = DateTimeString:sub(e+2, DateTimeString:len()-1):gsub("'", "");
    TimeString = "1" ..TimeString;

    local RandomSeed = tonumber(TimeString);
    math.randomseed(RandomSeed);
    return RandomSeed;
end

-- Placeholders ----------------------------------------------------------------

---
-- Ersetzt alle Platzhalter innerhalb des übergebenen Text.
-- @param[type=string] _Text Text mit Platzhaltern
-- @return[type=string] Ersetzter Text
-- @within Internal
-- @local
--
function Core:ConvertPlaceholders(_Text)
    local s1, e1, s2, e2;
    while true do
        local Before, Placeholder, After, Replacement, s1, e1, s2, e2;
        if _Text:find("{name:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{name:");
            Replacement = QSB.Placeholders.Names[Placeholder];
            _Text = Before .. API.Localize(Replacement or "ERROR_PLACEHOLDER_NOT_FOUND") .. After;
        elseif _Text:find("{type:") then
            Before, Placeholder, After, s1, e1, s2, e2 = self:SplicePlaceholderText(_Text, "{type:");
            Replacement = QSB.Placeholders.EntityTypes[Placeholder];
            _Text = Before .. API.Localize(Replacement or "ERROR_PLACEHOLDER_NOT_FOUND") .. After;
        end
        if s1 == nil or e1 == nil or s2 == nil or e2 == nil then
            break;
        end
    end
    _Text = self:ReplaceColorPlaceholders(_Text);
    return _Text;
end

---
-- Zerlegt einen String in 3 Strings: Anfang, Platzhalter, Ende.
-- @param[type=string] _Text  Text
-- @param[type=string] _Start Anfang-Tag
-- @return[type=string] Text vor dem Platzhalter
-- @return[type=string] Platzhalter
-- @return[type=string] Text nach dem Platzhalter
-- @return[type=number] Anfang Start-Tag
-- @return[type=number] Ende Start-Tag
-- @return[type=number] Anfang Schluss-Tag
-- @return[type=number] Ende Schluss-Tag
-- @within Internal
-- @local
--
function Core:SplicePlaceholderText(_Text, _Start)
    local s1, e1 = _Text:find(_Start);
    local s2, e2 = _Text:find("}", e1);

    local Before      = _Text:sub(1, s1-1);
    local Placeholder = _Text:sub(e1+1, s2-1);
    local After       = _Text:sub(e2+1);
    return Before, Placeholder, After, s1, e1, s2, e2;
end

---
-- Ersetzt Platzhalter mit einer Farbe mit dem Wert aus der Wertetabelle.
-- @param[type=string] Text mit Platzhaltern
-- @return[type=string] Text mit ersetzten Farben
-- @see QSB.Placeholders.Colors
-- @within Internal
-- @local
--
function Core:ReplaceColorPlaceholders(_Text)
    for k, v in pairs(QSB.Placeholders.Colors) do
        _Text = _Text:gsub("{" ..k.. "}", v);
    end
    return _Text;
end

-- Scripting Values ------------------------------------------------------------

---
-- Bestimmt das Modul b der Zahl a.
--
-- @param[type=number] a Zahl
-- @param[type=number] b Modul
-- @return[type=number] qmod der Zahl
-- @within Internal
-- @local
--
function Core:qmod(a, b)
    return a - math.floor(a/b)*b
end

---
-- Gibt den Integer als Bits zurück.
--
-- @param[type=number] num Bits
-- @return[type=table] Table mit Bits
-- @within Internal
-- @local
--
function Core:ScriptingValueBitsInteger(num)
    local t={}
    while num>0 do
        rest=self:qmod(num, 2) table.insert(t,1,rest) num=(num-rest)/2
    end
    table.remove(t, 1)
    return t
end

---
-- Stellt eine Zahl als eine Folge von Bits in einer Table dar.
--
-- @param[type=number] num Integer
-- @param[type=table]  t   Table
-- @return[type=table] Table mit Bits
-- @within Internal
-- @local
--
function Core:ScriptingValueBitsFraction(num, t)
    for i = 1, 48 do
        num = num * 2
        if(num >= 1) then table.insert(t, 1); num = num - 1 else table.insert(t, 0) end
        if(num == 0) then return t end
    end
    return t
end

---
-- Konvertiert eine Ganzzahl in eine Dezimalzahl.
--
-- @param[type=number] num Integer
-- @return[type=number] Integer als Float
-- @within Internal
-- @local
--
function Core:ScriptingValueIntegerToFloat(num)
    if(num == 0) then return 0 end
    local sign = 1
    if(num < 0) then num = 2147483648 + num; sign = -1 end
    local frac = self:qmod(num, 8388608)
    local headPart = (num-frac)/8388608
    local expNoSign = self:qmod(headPart, 256)
    local exp = expNoSign-127
    local fraction = 1
    local fp = 0.5
    local check = 4194304
    for i = 23, 0, -1 do
        if(frac - check) > 0 then fraction = fraction + fp; frac = frac - check end
        check = check / 2; fp = fp / 2
    end
    return fraction * math.pow(2, exp) * sign
end

---
-- Konvertiert eine Dezimalzahl in eine Ganzzahl.
--
-- @param[type=number] fval Float
-- @return[type=number] Float als Integer
-- @within Internal
-- @local
--
function Core:ScriptingValueFloatToInteger(fval)
    if(fval == 0) then return 0 end
    local signed = false
    if(fval < 0) then signed = true; fval = fval * -1 end
    local outval = 0;
    local bits
    local exp = 0
    if fval >= 1 then
        local intPart = math.floor(fval); local fracPart = fval - intPart;
        bits = self:ScriptingValueBitsInteger(intPart); exp = table.getn(bits); self:ScriptingValueBitsFraction(fracPart, bits)
    else
        bits = {}; self:ScriptingValueBitsFraction(fval, bits)
        while(bits[1] == 0) do exp = exp - 1; table.remove(bits, 1) end
        exp = exp - 1
        table.remove(bits, 1)
    end
    local bitVal = 4194304; local start = 1
    for bpos = start, 23 do
        local bit = bits[bpos]
        if(not bit) then break; end
        if(bit == 1) then outval = outval + bitVal end
        bitVal = bitVal / 2
    end
    outval = outval + (exp+127)*8388608
    if(signed) then outval = outval - 2147483648 end
    return outval;
end

-- Jobs ------------------------------------------------------------------------

-- Folgende Jobs steuern den Trigger Fix. Prinzipiell wird für jede Art Trigger
-- ein bestimmter Trigger erstellt, der dann die eigentlichen Trigger aufruft
-- und ihren Zustand abfragt.

function Core.EventJob_OnDiplomacyChanged()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_DIPLOMACY_CHANGED);
end
CoreEventJob_OnDiplomacyChanged = Core.EventJob_OnDiplomacyChanged;


function Core.EventJob_OnEntityCreated()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_CREATED);
end
CoreEventJob_OnEntityCreated = Core.EventJob_OnEntityCreated


function Core.EventJob_OnEntityDestroyed()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_DESTROYED);
end
CoreEventJob_OnEntityDestroyed = Core.EventJob_OnEntityDestroyed;


function Core.EventJob_OnEntityHurtEntity()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_HURT_ENTITY);
end
CoreEventJob_OnEntityHurtEntity = Core.EventJob_OnEntityHurtEntity;


function Core.EventJob_OnEntityInRangeOfEntity()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_ENTITY_IN_RANGE_OF_ENTITY);
end
CoreEventJob_OnEntityInRangeOfEntity = Core.EventJob_OnEntityInRangeOfEntity;


function Core.EventJob_OnEverySecond()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_EVERY_SECOND);
end
CoreEventJob_OnEverySecond = Core.EventJob_OnEverySecond;


function Core.EventJob_OnEveryTurn()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_EVERY_TURN);
end
CoreEventJob_OnEveryTurn = Core.EventJob_OnEveryTurn;


function Core.EventJob_OnGoodsTraded()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_GOODS_TRADED);
end
CoreEventJob_OnGoodsTraded = Core.EventJob_OnGoodsTraded;


function Core.EventJob_OnPlayerDied()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_PLAYER_DIED);
end
CoreEventJob_OnPlayerDied = Core.EventJob_OnPlayerDied;


function Core.EventJob_OnResearchDone()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_RESEARCH_DONE);
end
CoreEventJob_OnResearchDone = Core.EventJob_OnResearchDone;


function Core.EventJob_OnTributePaied()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_TRIBUTE_PAID);
end
CoreEventJob_OnTributePaied = Core.EventJob_OnTributePaied;


function Core.EventJob_OnWatherChanged()
    Core:TriggerEventJobs(Events.LOGIC_EVENT_WEATHER_STATE_CHANGED);
end
CoreEventJob_OnWatherChanged = Core.EventJob_OnWatherChanged;

-- Dieser Job ermittelt automatisch, ob eine Sekunde reale Zeit vergangen ist
-- und zählt eine Variable hoch, die die gesamt verstrichene reale Zeit hält.

function Core.EventJob_EventOnEveryRealTimeSecond()
    if not QSB.RealTime_LastTimeStamp then
        QSB.RealTime_LastTimeStamp = math.floor(Framework.TimeGetTime());
    end
    local CurrentTimeStamp = math.floor(Framework.TimeGetTime());

    -- Eine Sekunde ist vergangen
    if QSB.RealTime_LastTimeStamp ~= CurrentTimeStamp then
        QSB.RealTime_LastTimeStamp = CurrentTimeStamp;
        QSB.RealTime_SecondsSinceGameStart = QSB.RealTime_SecondsSinceGameStart +1;
    end
end

