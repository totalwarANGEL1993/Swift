--[[
Swift_2_EntityMovement/Source

Copyright (C) 2021 - 2022 totalwarANGEL - All Rights Reserved.

This file is part of Swift. Swift is created by totalwarANGEL.
You may use and modify this file unter the terms of the MIT licence.
(See https://en.wikipedia.org/wiki/MIT_License)
]]

ModuleEntityMovement = {
    Properties = {
        Name = "ModuleEntityMovement",
    },

    Global = {
        PathMovingEntities = {},
    };
    Local = {},
    -- This is a shared structure but the values are asynchronous!
    Shared = {},
};

-- -------------------------------------------------------------------------- --

function ModuleEntityMovement.Global:OnGameStart()
    QSB.ScriptEvents.EntityArrived = API.RegisterScriptEvent("Event_EntityArrived");
    QSB.ScriptEvents.EntityStuck = API.RegisterScriptEvent("Event_EntityStuck");
    QSB.ScriptEvents.EntityAtCheckpoint = API.RegisterScriptEvent("Event_EntityAtCheckpoint");

    QSB.ScriptEvents.PathFindingFinished = API.RegisterScriptEvent("Event_PathFindingFinished");
    QSB.ScriptEvents.PathFindingFailed = API.RegisterScriptEvent("Event_PathFindingFailed");

    API.StartHiResJob(function()
        Pathfinder:Controller();
    end);
end

function ModuleEntityMovement.Global:OnEvent(_ID, _Event, ...)
end

function ModuleEntityMovement.Global:FillMovingEntityDataForController(_Entity, _Path, _LookAt, _Action, _IgnoreBlocking)
    local Index = #self.PathMovingEntities +1;
    self.PathMovingEntities[Index] = {
        Entity = GetID(_Entity),
        IgnoreBlocking = _IgnoreBlocking == true,
        LookAt = _LookAt,
        Callback = _Action,
        Index = 0
    };
    for i= 1, #_Path do
        table.insert(self.PathMovingEntities[Index], _Path[i]);
    end
    return Index;
end

function ModuleEntityMovement.Global:MoveEntityPathController(_Index)
    local Data = self.PathMovingEntities[_Index];

    local CanMove = true;
    if not IsExisting(Data.Entity) then
        CanMove = false;
    end

    if CanMove and Logic.IsEntityMoving(Data.Entity) == false then
        -- Arrived at waypoint
        if Data.Index > 0 then
            API.SendScriptEvent(QSB.ScriptEvents.EntityAtCheckpoint, Data.Entity, GetID(Data[Data.Index]), _Index);
            Logic.ExecuteInLuaLocalState(string.format(
                [[API.SendScriptEvent(QSB.ScriptEvents.EntityAtCheckpoint, %d, %d, %d)]],
                Data.Entity, GetID(Data[Data.Index]), _Index
            ));
        end
        self.PathMovingEntities[_Index].Index = Data.Index +1;

        -- Check entity arrived
        if #Data < Data.Index then
            if  Logic.IsSettler(Data.Entity) == 1
            and Logic.GetEntityType(Data.Entity) ~= Entities.D_X_TradeShip then
                Logic.SetTaskList(Data.Entity, TaskLists.TL_NPC_IDLE);
                if Data.LookAt then
                    API.LookAt(Data.Entity, Data.LookAt);
                end
                if Data.Callback then
                    Data:Callback();
                end
            end
            API.SendScriptEvent(QSB.ScriptEvents.EntityArrived, Data.Entity, GetID(Data[#Data]), _Index);
            Logic.ExecuteInLuaLocalState(string.format(
                [[API.SendScriptEvent(QSB.ScriptEvents.EntityArrived, %d, %d, %d)]],
                Data.Entity, GetID(Data[#Data]), _Index
            ));
            return true;
        end

        -- Check reachablility
        local x1,y1,z1 = Logic.EntityGetPos(Data.Entity);
        local x2,y2,z2;
        if type(Data[Data.Index]) == "table" then
            x2 = Data[Data.Index].X;
            y2 = Data[Data.Index].Y;
        else
            x2,y2,z2 = Logic.EntityGetPos(GetID(Data[Data.Index]));
        end
        local PlayerID = Logic.EntityGetPlayer(Data.Entity);
        local SectorType = Logic.GetEntityPlayerSectorType(Data.Entity);
        local Sector1 = Logic.GetPlayerSectorID(PlayerID, SectorType, x1, y1);
        local Sector2 = Logic.GetPlayerSectorID(PlayerID, SectorType, x2, y2);
        if Sector1 ~= Sector2 then
            if Logic.IsSettler(Data.Entity) == 1 then
                Logic.SetTaskList(Data.Entity, TaskLists.TL_NPC_IDLE);
            end
            CanMove = false;
        end

        -- Move entity
        if CanMove then
            if Data.IgnoreBlocking then
                if  Logic.IsSettler(Data.Entity) == 1
                and Logic.GetEntityType(Data.Entity) ~= Entities.D_X_TradeShip then
                    Logic.SetTaskList(Data.Entity, TaskLists.TL_NPC_WALK);
                end
                Logic.MoveEntity(Data.Entity, x2, y2);
            else
                Logic.MoveSettler(Data.Entity, x2, y2);
            end
        end
    end

    -- Send movement failed event
    if not CanMove then
        API.SendScriptEvent(QSB.ScriptEvents.EntityStuck, Data.Entity, GetID(Data[Data.Index]), _Index);
        Logic.ExecuteInLuaLocalState(string.format(
            [[API.SendScriptEvent(QSB.ScriptEvents.EntityStuck, %d, %d, %d)]],
            Data.Entity, GetID(Data[Data.Index]), _Index
        ));
        return true;
    end
end

-- -------------------------------------------------------------------------- --

function ModuleEntityMovement.Local:OnGameStart()
    QSB.ScriptEvents.EntityArrived = API.RegisterScriptEvent("Event_EntityArrived");
    QSB.ScriptEvents.EntityStuck = API.RegisterScriptEvent("Event_EntityStuck");
    QSB.ScriptEvents.EntityAtCheckpoint = API.RegisterScriptEvent("Event_EntityAtCheckpoint");

    QSB.ScriptEvents.PathFindingFinished = API.RegisterScriptEvent("Event_PathFindingFinished");
    QSB.ScriptEvents.PathFindingFailed = API.RegisterScriptEvent("Event_PathFindingFailed");
end

function ModuleEntityMovement.Local:OnEvent(_ID, _Name, ...)
end

-- - Path Finder ------------------------------------------------------------ --

Pathfinder = {
    NodeDistance = 300;
    StepsPerTurn = 1;

    m_PathCounter = 0;
    m_Paths = {};
    m_ProcessedPaths = {};
}

function Pathfinder:Insert(_Start, _End, _NodeDistance, _StepsPerTick, _Filter, ...)
    local Start = self:GetClosestPositionOnNodeMap(_Start, _NodeDistance);
    if not Start then
        return 0;
    end
    local End = self:GetClosestPositionOnNodeMap(_End, _NodeDistance);
    if not _End then
        return 0;
    end

    self.m_PathCounter = self.m_PathCounter +1;
    self.m_ProcessedPaths[self.m_PathCounter] = {
        NodeDistance = _NodeDistance or 300,
        StepsPerTick = _StepsPerTick or 1,
        StartNode = Start,
        TargetNode = End,
        Suspended = false,
        Closed = {},
        ClosedMap = {},
        Open = {},
        OpenMap = {};
        AcceptMethode = _Filter,
        AcceptArgs = arg,
    };

    Start.ID = "ID_"..Start.X.."_"..Start.Y;
    table.insert(self.m_ProcessedPaths[self.m_PathCounter].Open, 1, Start);
    self.m_ProcessedPaths[self.m_PathCounter].OpenMap[Start.ID] = true;

    return self.m_PathCounter;
end

function Pathfinder:Controller()
    for k, v in pairs(self.m_ProcessedPaths) do
        if v.Suspended == false then
            self:Step(k);
        end
    end
end

function Pathfinder:SendPathingSucceedEvent(_Index)
    API.SendScriptEvent(QSB.ScriptEvents.PathFindingFinished, _Index);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.PathFindingFinished, %d)]],
        _Index
    ));
end

function Pathfinder:SendPathingFailedEvent(_Index)
    API.SendScriptEvent(QSB.ScriptEvents.PathFindingFailed, _Index);
    Logic.ExecuteInLuaLocalState(string.format(
        [[API.SendScriptEvent(QSB.ScriptEvents.PathFindingFailed, %d)]],
        _Index
    ))
end

function Pathfinder:SetSuspended(_ID, _Flag)
    if self.m_ProcessedPaths[_ID] then
        self.m_ProcessedPaths[_ID].Suspended = _Flag == true;
    end
end

function Pathfinder:Step(_Index)
    if not self.m_ProcessedPaths[_Index] then
        self.m_ProcessedPaths[_Index] = nil;
        self.m_Paths[_Index] = nil;
        self:SendPathingFailedEvent(_Index);
        return true;
    end
    for i= 1, self.m_ProcessedPaths[_Index].StepsPerTick, 1 do
        if #self.m_ProcessedPaths[_Index].Open == 0 then
            self.m_ProcessedPaths[_Index] = nil;
            self.m_Paths[_Index] = nil;
            self:SendPathingFailedEvent(_Index);
            return true;
        end
        local removed = table.remove(self.m_ProcessedPaths[_Index].Open, 1);
        self.m_ProcessedPaths[_Index].OpenMap[removed.ID] = nil;
        if  removed.X == self.m_ProcessedPaths[_Index].TargetNode.X
        and removed.Y == self.m_ProcessedPaths[_Index].TargetNode.Y then
            local LastNode = removed;
            local path = {}
            local prev = LastNode;
            while (prev) do
                table.insert(path, prev);
                local tmp = LastNode.Father;
                LastNode = prev;
                prev = self:GetNodeByID(_Index, tmp);
                if not prev.Father then
                    table.insert(path, prev);
                    break;
                end
            end
            self.m_Paths[_Index] = PathModel:New(path);
            self.m_ProcessedPaths[_Index] = nil;
            self:SendPathingSucceedEvent(_Index);
            return true;
        else
            self:Expand(_Index, removed);
        end
    end
    return false;
end

function Pathfinder:Expand(_Index, _Node)
    local x = _Node.X;
    local y = _Node.Y;

    -- Regular nodes
    local FatherNodeID = _Node.ID;
    local SuccessorNodes = {};
    local Distance = self.m_ProcessedPaths[_Index].NodeDistance;
    for i= x-Distance, x+Distance, Distance do
        for j= y-Distance, y+Distance, Distance do
            if not (i == x and j == y) then
                if  not self.m_ProcessedPaths[_Index].OpenMap["ID_"..i.."_"..j] 
                and not self.m_ProcessedPaths[_Index].ClosedMap["ID_"..i.."_"..j] then
                    -- Insert node
                    table.insert(SuccessorNodes, {
                        ID = "ID_"..i.."_"..j,
                        X = i,
                        Y = j,
                        Father = FatherNodeID,
                        Distance1 = API.GetDistance(_Node, self.m_ProcessedPaths[_Index].TargetNode),
                        Distance2 = API.GetDistance(self.m_ProcessedPaths[_Index].StartNode, _Node)
                    });
                end
            end
        end
    end

    -- Check successor nodes and put into open list
    self:AcceptSuccessors(_Index, SuccessorNodes);
    -- Sort open list
    self:SortOpenList(_Index);
    -- Insert current node to closed list
    table.insert(self.m_ProcessedPaths[_Index].Closed, _Node);
    self.m_ProcessedPaths[_Index].OpenMap[_Node.ID] = true;
end

function Pathfinder:AcceptSuccessors(_Index, _SuccessorList)
    local SuccessorList = {};
    for k,v in pairs(_SuccessorList) do
        if not self.m_ProcessedPaths[_Index].ClosedMap["ID_"..v.X.."_"..v.Y] then
            if not self.m_ProcessedPaths[_Index].OpenMap["ID_"..v.X.."_"..v.Y] then
                table.insert(SuccessorList, v);
            end
        end
    end
    for k,v in pairs(SuccessorList) do
        local useNode = true;
        if self.m_ProcessedPaths[_Index].AcceptMethode then
            useNode = useNode and self.m_ProcessedPaths[_Index].AcceptMethode(
                v, SuccessorList, unpack(self.m_ProcessedPaths[_Index].AcceptArgs)
            );
        end
        if useNode then
            table.insert(self.m_ProcessedPaths[_Index].Open, v);
            self.m_ProcessedPaths[_Index].OpenMap[v.ID] = true;
            -- Visialize (debug only)
            -- Logic.CreateEntity(Entities.XD_CoordinateEntity, v.X, v.Y, 0, 0);
        end
    end
end

function Pathfinder:SortOpenList(_Index)
    local comp = function(v,w)
        return v.Distance1 < w.Distance1 and v.Distance2 < w.Distance2;
    end
    table.sort(self.m_ProcessedPaths[_Index].Open, comp);
end

function Pathfinder:GetClosestPositionOnNodeMap(_Position, _NodeDistance)
    if type(_Position) ~= "table" then
        _Position = GetPosition(_Position);
    end
    local Distance = _NodeDistance;
    local X = math.floor(_Position.X + 0.5);
    local XMod = (X % Distance);
    local bx = (XMod > Distance/2 and (X + (Distance - XMod))) or X - XMod;
    local Y = math.floor(_Position.Y + 0.5);
    local YMod = (Y % Distance);
    local by = (YMod > Distance/2 and (Y + (Distance - YMod))) or Y - YMod;
    return {X= bx, Y= by};
end

function Pathfinder:GetNodeByID(_Index, _ID)
    local node;
    for i=1, #self.m_ProcessedPaths[_Index].Closed do
        if self.m_ProcessedPaths[_Index].Closed[i].ID == _ID then
            node = self.m_ProcessedPaths[_Index].Closed[i];
        end
    end
    return node;
end

function Pathfinder:IsPathExisting(_ID)
    return self.m_Paths[_ID] ~= nil;
end

function Pathfinder:IsPathStillCalculated(_ID)
    return self.m_ProcessedPaths[_ID] ~= nil;
end

function Pathfinder:GetPath(_ID)
    if self:IsPathExisting(_ID) then
        return table.copy(self.m_Paths[_ID]);
    end
end

-- - Path ------------------------------------------------------------------- --

PathModel = {
    m_Nodes = {};
};

function PathModel:New(_Nodes)
    local Instance = table.copy(self);
    Instance.m_Nodes = _Nodes;
    return Instance;
end

function PathModel:FromList(_List)
    local path = PathModel:New({});
    local father = nil;

    local Start = _List[1];
    local End   = _List[#_List];

    for i= 1, #_List, 1 do
        local ID = GetID(_List[i]);
        local x,y,z = Logic.EntityGetPos(ID);
        table.insert(path.m_Nodes, {
            ID        = "ID_" ..ID,
            Marker    = 0,
            Father    = father,
            Visited   = false,
            X         = x,
            Y         = y,
            Distance1 = API.GetDistance(ID, End),
            Distance2 = API.GetDistance(Start, ID),
        });
        father = "ID_" ..ID;
    end
    return path;
end

function PathModel:AddNode(_Node)
    local n = #self.m_Nodes;
    if n > 1 then
        _Node.Father = self.m_Nodes[n-1].ID;
    else
        _Node.Father = nil;
    end
    table.insert(self.m_Nodes, _Node);
end

function PathModel:Merge(_Other)
    if _Other and #_Other.m_Nodes > 0 and #self.m_Nodes > 0 then
        _Other.m_Nodes[1].Father = self.m_Nodes[#self.m_Nodes].ID;
        for i= 1, #_Other.m_Nodes, 1 do
            table.insert(self.m_Nodes, _Other.m_Nodes[i]);
        end
    end
end

function PathModel:Reduce(_By)
    local Reduced = table.copy(self);
    local n = #Reduced.m_Nodes;
    for i= n, 1, -1 do
        if i ~= 1 and i ~= n and i % _By ~= 0 then
            Reduced.m_Nodes[i+1].Father = Reduced.m_Nodes[i-1].Father;
            table.remove(Reduced.m_Nodes, i);
        end
    end
    return Reduced;
end

function PathModel:Reset()
    for k,v in pairs(self.m_Nodes) do
        self.m_Nodes[k].Visited = false;
    end
end

function PathModel:Reverse()
    return PathModel:New(table.invert(self.m_Nodes));
end

function PathModel:Next()
    local Node, ID = self:GetCurrentWaypoint();
    if Node then
        self.m_Nodes[ID].Visited = true;
    end
end

function PathModel:GetCurrentWaypoint()
    local lastWP;
    local id = 1;
    repeat
        lastWP = self.m_Nodes[id];
        id = id +1;
    until ((not self.m_Nodes[id]) or self.m_Nodes[id].Visited == false);
    if not self.m_Nodes[id] then
        id = id -1;
    end
    return lastWP, id;
end

function PathModel:Convert()
    if self.m_Nodes then
        local nodes = {};
        for k,v in pairs(self.m_Nodes) do
            local eID = Logic.CreateEntity(
                Entities.XD_ScriptEntity,
                self.m_Nodes.X,
                self.m_Nodes.Y,
                0,
                0
            );
            table.insert(nodes, eID);
        end
        return nodes;
    end
end

function PathModel:Show()
    if #self.m_Nodes > 0 then
        for i=1, #self.m_Nodes do
            local ID = Logic.CreateEntity(
                Entities.XD_ScriptEntity,
                self.m_Nodes[i].X,
                self.m_Nodes[i].Y,
                0,
                0
            );
            Logic.SetModel(ID, Models.Doodads_D_X_Flag);
            Logic.SetVisible(ID, true);
            self.m_Nodes[i].Marker = ID;
        end
    end
end

function PathModel:Hide()
    for k, v in pairs(self.m_Nodes) do
        DestroyEntity(v.Marker);
        self.m_Nodes[k].Marker = 0;
    end
end

-- -------------------------------------------------------------------------- --

Swift:RegisterModule(ModuleEntityMovement);

