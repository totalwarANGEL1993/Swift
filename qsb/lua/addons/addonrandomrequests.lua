-- -------------------------------------------------------------------------- --
-- ########################################################################## --
-- #  Symfonia AddOnRandomRequests                                          # --
-- ########################################################################## --
-- -------------------------------------------------------------------------- --

---
-- Dieses Bundle stellt zufällige Aufgaben durch NPC-Spieler bereit.
--
-- Es gibt verschiedene Typen von zufälligen Aufträgen. Es wird versucht, immer
-- einen einzigartigen Auftrag für den jeweiligen Auftraggeber zu erzeugen.
-- Wenn kein Auftrag erzeugt werden kann, wird der Spieler aufgefordert 2000
-- Gold zu bezahlen.
--
-- @within Modulbeschreibung
-- @set sort=true
--
AddOnRandomRequests = {};

API = API or {};
QSB = QSB or {};

-- -------------------------------------------------------------------------- --
-- User-Space                                                                 --
-- -------------------------------------------------------------------------- --


-- -------------------------------------------------------------------------- --
-- Application-Space                                                          --
-- -------------------------------------------------------------------------- --

AddOnRandomRequests = {
    Global = {
        Data = {
            RandomQuestNameCounter = 0;
            Claim = {},
            Deliver = {},
            KnightTitle = {},

            Text = {
                Suggestion = {
                    {de = "Ihr müsst Euer Können unter Beweis stellen!",
                     en = "Please show us what you are capable of!"},
                    {de = "Bei diesem Problem benötigen wir Eure Unterstützung!",
                     en = "This problem is driving us nuts! Please help us!"},
                    {de = "Euer Volk braucht Eure Hilfe! Werdet Ihr uns helfen?",
                     en = "Your pepole demand your attantion. Will you help them?"},
                },
                Success = {
                    {de = "Wir möchten Euch von Herzen für Eure Hilfe danken!",
                     en = "Let us thank you from the bottem of out hearts!"},
                    {de = "Ihr habt bewiesen, dass man Euch vertrauen kann!",
                     en = "You have proven the trust we have in your, Milord!"},
                    {de = "Gott segne Euch! Wir sind gerettet!",
                     en = "God be praised! You saved us all!"},
                },
                Failure = {
                    {de = "Wir haben Euch vertraut! Mich deucht Euer Wort ist nichts wert!",
                     en = "We trusted you! So that is what your words are worth! Nothing!"},
                    {de = "Anführer! Es sind viele an der Zahl doch taugen alle wenig!",
                     en = "Leaders! They are many but they can't even tie their shoes!"},
                    {de = "Ein Herrscher wollt Ihr sein? Lernt das Volk zu schätzen!",
                     en = "You call yourself a ruler? Go and remember the needs of the pepole!"},
                },
            }
        },
    },
    Local = {},
}

-- Global ----------------------------------------------------------------------

---
-- Initalisiert das AddOn.
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:Install()
end

---
-- Erzeugt einen zufälligen Slave Quest anhand der Einstellungen im Quest.
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:CreateSlaveQuest(_Behavior, _Quest)
    if not _Behavior.SlaveQuest then
        local QuestGoals = self:GetPossibleBehaviors(_Behavior, _Quest);
        -- Fallback
        if #QuestGoals == 0 then
            QuestGoals[#QuestGoals+1] = {"Goal_Deliver", "G_Gold", 2000};
        end
        local SelectedGoal = QuestGoals[math.random(1, #QuestGoals)];
        local FunctionName = table.remove(SelectedGoal, 1);

        self.Data.RandomQuestNameCounter = self.Data.RandomQuestNameCounter +1;
        local QuestName = API.CreateQuest {
            Name        = "RandomRequest_Player" .._Quest.SendingPlayer.. "_" ..self.Data.RandomQuestNameCounter;
            Suggestion  = _Quest.QuestStartMsg or self.Data.Text.Suggestion[math.random(1, 3)],
            Success     = _Quest.QuestSuccessMsg or self.Data.Text.Success[math.random(1, 3)],
            Failure     = _Quest.QuestFailureMsg or self.Data.Text.Failure[math.random(1, 3)],
            Receiver    = _Quest.ReceivingPlayer,
            Sender      = _Quest.SendingPlayer,
            Time        = _Behavior.TimeLimit,

            _G[FunctionName](unpack(SelectedGoal)),
            Trigger_Time(0),
        };
        _Behavior.SlaveQuest = Quests[GetQuestID(QuestName)];
    end
end

---
-- Gibt eine Liste mit Behavior zurück, die für den Random Quest verfügbar
-- sind. Es wird eines der Behavior ausgewählt.
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetPossibleBehaviors(_Behavior, _Quest)
    local QuestGoals = {};
    if _Behavior.TypeDeliverGoods then
        QuestGoals[#QuestGoals+1] = self:GetDeliverGoodsBehavior(_Behavior, _Quest);
    end
    if _Behavior.TypeDeliverGold then
        local Amount = math.random(150, 225) * (Logic.GetKnightTitle(_Quest.ReceivingPlayer) +1);
        QuestGoals[#QuestGoals+1] = {"Goal_Deliver", "G_Gold", Amount};
    end
    if _Behavior.TypeClaim then
        QuestGoals[#QuestGoals+1] = self:GetClaimTerritoryBehavior(_Behavior, _Quest);
    end
    if _Behavior.TypeKnightTitle then
        QuestGoals[#QuestGoals+1] = self:GetKnightTitleBehavior(_Behavior, _Quest);
    end
    if _Behavior.TypeReputation then
        QuestGoals[#QuestGoals+1] = {"Goal_CityReputation", 25 + (10 * Logic.GetKnightTitle(_Quest.ReceivingPlayer))};
    end
    if _Behavior.TypeBuildWall then
        QuestGoals[#QuestGoals+1] = self:GetBuildWallBehavior(_Behavior, _Quest);
    end
    return QuestGoals;
end

---
-- Erstellt Goal_KnightTitle für den Random Quest.
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetKnightTitleBehavior(_Behavior, _Quest)
    if Logic.GetKnightTitle(_Quest.ReceivingPlayer) < KnightTitles.Archduke then
        local PossibleTitles = {"Mayor", "Baron", "Earl", "Marquees", "Duke", "Archduke"};
        local NextTitle = PossibleTitles[Logic.GetKnightTitle(_Quest.ReceivingPlayer)+1];
        self.Data.KnightTitle[_Quest.ReceivingPlayer] = self.Data.KnightTitle[_Quest.ReceivingPlayer] or {};
        if self.Data.KnightTitle[_Quest.ReceivingPlayer][NextTitle] then
            return;
        end
        self.Data.KnightTitle[_Quest.ReceivingPlayer][NextTitle] = true;
        return {"Goal_KnightTitle", NextTitle};
    end 
end

---
-- Erstellt Goal_BuildWall für den Random Quest.
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetBuildWallBehavior(_Behavior, _Quest)
    local FirstEnemy;
    for i= 1, 8, 1 do
        if i ~= _Quest.SendingPlayer and i ~= _Quest.ReceivingPlayer and GetDiplomacyState(i, _Quest.ReceivingPlayer) == DiplomacyState.Enemy then
            FirstEnemy = i;
            break;
        end
    end
    if FirstEnemy then
        local SPStorehouse = Logic.GetStoreHouse(_Quest.SendingPlayer);
        local RPStorehouse = Logic.GetStoreHouse(_Quest.ReceivingPlayer);
        return {"Goal_BuildWall", FirstEnemy, RPStorehouse, SPStorehouse};
    end
end

---
-- Erstellt Goal_Claim für den Random Quest.
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetClaimTerritoryBehavior(_Behavior, _Quest)
    local AllTerritories = {Logic.GetTerritories()};
    self.Data.Claim[_Quest.ReceivingPlayer] = self.Data.Claim[_Quest.ReceivingPlayer] or {};
    for i= #AllTerritories, 1, -1 do
        if self.Data.Claim[_Quest.ReceivingPlayer][NextTitle] then
            return;
        end
        if AllTerritories[i] == 0 or Logic.GetTerritoryPlayerID(AllTerritories[i]) ~= 0 
        or self.Data.Claim[_Quest.ReceivingPlayer][AllTerritories[i]] then
            table.remove(AllTerritories, i);
        end
    end
    if #AllTerritories > 0 then
        local Territory = AllTerritories[math.random(1, #AllTerritories)];
        self.Data.Claim[_Quest.ReceivingPlayer][Territory] = true;
        return {"Goal_Claim", AllTerritories[math.random(1, #AllTerritories)]};
    end
end

---
-- Erstellt Goal_Deliver (Rohstoffe) für den Random Quest.
-- @param[type=table] _Behavior Behavior Data
-- @param[type=table] _Quest    Quest Data
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:GetDeliverGoodsBehavior(_Behavior, _Quest)
    local GoodTypes = {
        "G_Wood", "G_Iron", "G_Stone", "G_Carcass", "G_Herb", "G_Wool",
        "G_Honeycomb", "G_Grain", "G_Milk", "G_RawFish"
    };

    local Receiver = _Quest.ReceivingPlayer;
    local Sender   = _Quest.SendingPlayer;
    self.Data.Deliver[Receiver] = self.Data.Deliver[Receiver] or {};
    self.Data.Deliver[Receiver][Sender] = self.Data.Deliver[Receiver][Sender] or {};

    local SelectedGood;
    repeat
        SelectedGood = GoodTypes[math.random(1, #GoodTypes)];
    until (self:CanGoodBeSetAsGoal(Sender, Receiver, Goods[SelectedGood]));
    local Amount = math.random(15, 25) * (Logic.GetKnightTitle(Receiver) +1);
    self.Data.Deliver[Receiver][Sender][Goods[SelectedGood]] = true;
    return {"Goal_Deliver", SelectedGood, Amount};
end 

---
-- Prüft, ob eine Ware für ein Goal_Deliver verwendet werden kann.
-- @param[type=number] _SenderID   Sendender Spieler
-- @param[type=number] _ReceiverID Empfangender Spieler
-- @param[type=number] _Good       Warentyp
-- @return[type=boolean] Ware kann benutzt werden.
-- @within Internal
-- @local
--
function AddOnRandomRequests.Global:CanGoodBeSetAsGoal(_SenderID, _ReceiverID, _Good)
    if self.Data.Deliver[_ReceiverID][_SenderID][_Good] then
        return false;
    end
    if MerchantSystem.TradeBlackList[_SenderID] then
        for k, v in pairs(MerchantSystem.TradeBlackList[_SenderID]) do
            if v == _Good then
                return false;
            end
        end
    end
    return true;
end

-- -------------------------------------------------------------------------- --

---
-- Wählt einen zufälligen Auftrag für den Spieler aus. Über die Parameter kann
-- bestimmt werden, welche Typen von Aufträgen erscheinen können. Dieses
-- Behavior sollte in versteckten Quests benutzt werden.
--
-- Tribute und Warenanforderungen steigen in der Menge mit höherem Titel
-- des Auftragnehmers.
--
-- <b>Hinweis</b>: Das Behavior erzeugt einen weiteren Quest mit dem zufällig
-- gewählten Ziel.
--
-- @param[type=boolean] _DeliverGoods   Ziel: Waren liefern
-- @param[type=boolean] _DeliverGold    Ziel: Tribut bezahlen
-- @param[type=boolean] _ClaimTerritory Ziel: Territorium erobern
-- @param[type=boolean] _KnightTitle    Ziel: Nächst höherer Titel
-- @param[type=boolean] _CityReputation Ziel: Ruf der Stadt
-- @param[type=number]  _Time           Zeit bis zur Niederlage (0 = aus)
--
-- @within Goal
--
function Goal_RandomRequest(...)
    return b_Goal_RandomRequest:new(...);
end

b_Goal_RandomRequest = {
    Name = "Goal_RandomRequest",
    Description = {
        en = "Goal: Der Spieler erhält einen zufällig generierten Auftrag, der erfüllt werden muss. Über die Parameter wird bestimmt, welche Typen von Aufträgen möglich sind. Tipp: Für versteckten Quest nutzen!",
        de = "Ziel: The player receives an randomly generated quest that he needs to complete. Define which types of quest possibly appear by setting the parameters. Tip: Use this quest as invisible quest!",
    },
    Parameter = {
        { ParameterType.Custom, en = "Deliver goods",        de = "Waren liefern" },
        { ParameterType.Custom, en = "Pay tribute",          de = "Tribut entrichten" },
        { ParameterType.Custom, en = "Claim territory",      de = "Territorium beanspruchen" },
        { ParameterType.Custom, en = "Knight title",         de = "Titel erreichen" },
        { ParameterType.Custom, en = "City reputation",      de = "Ruf der Stadt" },
        { ParameterType.Custom, en = "Build rampart",        de = "Festung bauen" },
        { ParameterType.Number, en = "Time limit (0 = off)", de = "Leitlimit (0 = aus)" },
    },
}

function b_Goal_RandomRequest:GetGoalTable()
    return {Objective.Custom2, {self, self.CustomFunction}};
end

function b_Goal_RandomRequest:AddParameter(_Index, _Parameter)
    if (_Index == 0) then
        self.TypeDeliverGoods = API.ToBoolean(_Parameter);
    elseif (_Index == 1) then
        self.TypeDeliverGold = API.ToBoolean(_Parameter);
    elseif (_Index == 2) then
        self.TypeClaim = API.ToBoolean(_Parameter);
    elseif (_Index == 3) then
        self.TypeKnightTitle = API.ToBoolean(_Parameter);
    elseif (_Index == 3) then
        self.TypeReputation = API.ToBoolean(_Parameter);
    elseif (_Index == 3) then
        self.TypeBuildWall = API.ToBoolean(_Parameter);
    elseif (_Index == 6) then
        self.TimeLimit = _Parameter * 1;
    end
end

function b_Goal_RandomRequest:GetCustomData(_Index)
    return {"true", "false"};
end

function b_Goal_RandomRequest:CustomFunction(_Quest)
    AddOnRandomRequests.Global:CreateSlaveQuest(self, _Quest);
    if self.SlaveQuest and self.SlaveQuest.Result == QuestResult.Success then
        return true;
    end
    if self.SlaveQuest and self.SlaveQuest.Result == QuestResult.Failure then
        return false;
    end
end

function b_Goal_RandomRequest:Reset(_Quest)
    self:Interrupt(_Quest);
    if self.SlaveQuest then
        API.RestartQuest(self.SlaveQuest.Identifier, false);
    end
end

function b_Goal_RandomRequest:Interrupt(_Quest)
    if self.SlaveQuest and self.SlaveQuest.State == QuestState.Active then
        API.StopQuest(self.SlaveQuest.Identifier, false);
    end
end

function b_Goal_RandomRequest:Debug(_Quest)
    return false;
end

Core:RegisterBehavior(b_Goal_RandomRequest);

-- -------------------------------------------------------------------------- --

Core:RegisterAddOn("AddOnRandomRequests");
