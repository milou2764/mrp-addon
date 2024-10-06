MRP.NPCSpawnDelay = 20
nextSpawnTime = 0
minSpawnDistance = 1968
maxSpawnDistance = 20000
npcCount = 0
npcLimit = 20
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

local function NPCSpawnSystem()
    for _, platform in pairs( MRP.Spawns[game.GetMap()][cat] ) do
        if not platform.npc or not IsValid(platform.npc) then
            local canSpawn = true
            for _, p in pairs( player.GetAll() ) do
                local distance = p:GetPos():Distance( platform.pos )
                local tooClose = distance < minSpawnDistance
                local tooFar = distance > maxSpawnDistance
                local limitReached = npcCount >= npcLimit
                local notBluFor = p:MRPFaction()~=1
                if tooClose or tooFar or limitReached or notBluFor then
                    canSpawn = false
                end
            end
            if canSpawn then
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
            end
        end
    end
end

hook.Add("Initialize", "InitNPCSpawn", function()
    local map = game.GetMap()
    if MRP.Spawns[map] and MRP.Spawns[map][cat] and #MRP.Spawns[map][cat] > 0 then
        timer.Create("MRP_NPCSys", MRP.NPCSpawnDelay, 0, NPCSpawnSystem)
    end
end)

MRP.Commands.npcs.toggle = function(ply)
    if hook.GetTable().Think.NPCSpawn then
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
