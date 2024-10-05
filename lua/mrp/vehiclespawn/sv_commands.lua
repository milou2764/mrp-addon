MRP.Commands.vehic = {}
local cat = "vehic"
MRP.Commands.vehic.add = function(ply, class)
    local map = game.GetMap()
    if not MRP.Spawns then MRP.Spawns = {} end
    if not MRP.Spawns[map] then MRP.Spawns[map] = {} end
    if not MRP.Spawns[map][cat] then
        MRP.Spawns[map][cat] = {}
    end
	local cat
	if string.find(class, "simfphys") or string.find(class, "sim_fphys") then
		cat = "simfphys"
	else
		cat = "wac"
	end
    table.insert(
		MRP.Spawns[map][cat],
		{
			pos = ply:GetPos(),
		        ang = ply:GetAngles(),
                        class = class,
			cat = cat,
		}
	)
    MRP.SaveSpawns()
    ply:ChatPrint(class .. " spawn added")
end

MRP.Commands.vehic.list = function(ply) MRP.ListSpawns(ply, cat) end
MRP.Commands.vehic.rm = function(ply, id) MRP.RemoveSpawn(cat, id) end
