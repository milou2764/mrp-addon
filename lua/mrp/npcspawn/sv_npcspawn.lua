MRP.NPCSpawnDelay = 20
local nextSpawnTime = 0
local minSpawnDistance = 4000
local maxSpawnDistance = 6000
local npcCount = 0
local npcLimit = 10
local map
local cat = "npcs"

local function initTable(map)
    map = game.GetMap()
    if not MRP.Spawns[map] then MRP.Spawns[map] = {} end
    if not MRP.Spawns[map][cat] then
        MRP.Spawns[map][cat] = {}
    end
end

MRP.Commands.npcs = {}
MRP.Commands.npcs.list = function(ply) MRP.ListSpawns(ply, cat) end
MRP.Commands.npcs.rm = function(ply, id) MRP.RemoveSpawn(cat, id) end
MRP.Commands.npcs.add = function(ply, entClass)
    map = game.GetMap()
    initTable()
    table.insert(
        MRP.Spawns[map][cat],
        {
            pos = ply:GetPos(),
            ang = ply:GetAngles(),
        }
    )
    MRP.SaveSpawns()
end
MRP.Commands.npcs.max = function(ply, limit)
    local n = tonumber(limit)
    ply:ChatPrint("default is " .. npcLimit)
    if n==nil then
        ply:ChatPrint("usage: mrp npcs max <number>")
    else
        npcLimit = n
    end
end
MRP.Commands.npcs.maxdist = function(ply, limit)
    local n = tonumber(limit)
    ply:ChatPrint("default is " .. maxSpawnDistance)
    if n==nil then
        ply:ChatPrint("usage: mrp npcs maxdist <number>")
    else
        maxSpawnDistance = n
    end
end

local function setEnemy(ply)
    local platforms = MRP.Spawns[game.GetMap()][cat]
    for _, platform in pairs(platforms) do
        if IsValid(platform.npc) then
            -- for regular npcs
            platform.npc:AddEntityRelationship(ply, D_HT, 99)
            -- fo VJ npcs
            table.RemoveByValue(platform.npc.VJ_AddCertainEntityAsFriendly, ply)
        end
    end
end

local function setFriendly(ply)
    local platforms = MRP.Spawns[game.GetMap()][cat]
    for _, platform in pairs(platforms) do
        if IsValid(platform.npc) then
            -- for regular npcs
            platform.npc:AddEntityRelationship(ply, D_LI, 99)
            -- fo VJ npcs
            local tb = platform.npc.VJ_AddCertainEntityAsFriendly
            if not table.HasValue(tb, ply) then
                table.insert(tb, ply)
            end
        end
    end
end

local npcWep =
    {
        {"weapon_vj_ak47", 50},
        {"weapon_vj_spas12", 65},
        {"weapon_vj_mp40", 85},
        {"weapon_vj_9mmpistol", 95},
        {"weapon_vj_rpg", 100},
    }

local randomWep = function()
    local rd = math.random(0, 100)
    local i = 1
    local wep = npcWep[i]
    while rd > wep[2] do
        i = i + 1
        wep = npcWep[i]
    end
    return wep[1]
end

local npcs = {
    "npc_vj_cpmcblah",
    "npc_vj_cpmcblamaskh",
    "npc_vj_cpmcblaleaderh",
}

local function platformCanSpawn(platform)
    for _, p in pairs( player.GetAll() ) do
        local distance = p:GetPos():Distance( platform.pos )
        local close = distance < minSpawnDistance
        local far = distance > maxSpawnDistance
        local underLimit = npcCount < npcLimit
        local bluFor = p:MRPFaction()==1
        local canSpawn = not close and not far and underLimit and bluFor
        if canSpawn then return true end
    end
    return false
end

local function platformTooFar(platform)
    for _, p in pairs( player.GetAll() ) do
        local distance = p:GetPos():Distance( platform.pos )
        local far = distance > maxSpawnDistance
        if far then
            Log.d("npcs", "npc far " .. tonumber(distance))
            return true
        end
    end
    return false
end

local function NPCSpawnSystem()
    for _, platform in pairs( MRP.Spawns[game.GetMap()][cat] ) do
        if not platform.npc or not IsValid(platform.npc) then
            if platformCanSpawn(platform) then
                platform.npc = ents.Create(table.Random(npcs))
                if not IsValid(platform.npc) then return end
                platform.npc:SetPos(platform.pos)
                platform.npc:SetAngles(platform.ang)
                local equipment = randomWep()
                platform.npc:SetKeyValue( "additionalequipment", equipment )
                platform.npc.Equipment = equipment
                platform.npc:Spawn()
                platform.npc:Activate()
                npcCount = npcCount + 1
                for _,p in pairs(player.GetAll()) do
                    if p:MRPFaction()==1 then
                        setEnemy(p)
                    else
                        setFriendly(p)
                    end
                end
            end
        elseif platformTooFar(platform) then
            platform.npc:Remove()
            npcCount = npcCount - 1
        end
    end
end

hook.Add(
    "EntityNetworkedVarChanged",
    "MRP_npcs_FactionChanged",
    function(ent, name, oldval, newval)
        if name == "MRP_Faction" then
            local relation
            if newval==1 then
                -- ent:RemoveFlags(FL_NOTARGET)
                setEnemy(ent)
            else
                -- ent:AddFlags(FL_NOTARGET)
                setFriendly(ent)
            end
        end
    end
)

hook.Add("Initialize", "InitNPCSpawn", function()
    local map = game.GetMap()
    if MRP.Spawns[map] and MRP.Spawns[map][cat] and #MRP.Spawns[map][cat] > 0 then
        timer.Create("MRP_NPCSys", MRP.NPCSpawnDelay, 0, NPCSpawnSystem)
    end
end)

MRP.Commands.npcs.toggle = function(ply)
    if timer.Exists("MRP_NPCSys") then
        timer.Remove("MRP_NPCSys")
        ply:ChatPrint("NPC Spawn System Disabled")
    else
        local map = game.GetMap()
        if MRP.Spawns[map].npcs and #MRP.Spawns[map].npcs > 0 then
            timer.Create("MRP_NPCSys", MRP.NPCSpawnDelay, 0, NPCSpawnSystem)
            ply:ChatPrint("NPC Spawn System Enabled")
            return
        end
        ply:ChatPrint("No NPC Spawns Found")
    end
end

hook.Add("OnNPCKilled", "UpdateNPCCount", function()
    npcCount = npcCount - 1
end)

hook.Add("PostCleanupMap", "ResetNPCCount", function()
    npcCount = 0
end)
