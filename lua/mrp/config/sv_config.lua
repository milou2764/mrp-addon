MRP.SpawnsFile = "mrp/spawns.json"
local spawnData = file.Read(MRP.SpawnsFile, "DATA")
MRP.SpawnEnts = MRP.SpawnEnts or {}
MRP.Spawns = {}
if spawnData then
    MRP.Spawns = util.JSONToTable(spawnData) or {}
end
