local function save()
    file.Write(
        "mrp/spawns.txt",
        util.TableToJSON(MRP.Spawns, true)
    )
end

MRP.Commands.vehic = {}
MRP.Commands.vehic.add = function(ply, class)
    local map = game.GetMap()
    if not MRP.Spawns then MRP.Spawns = {} end
    if not MRP.Spawns[map] then MRP.Spawns[map] = {} end
    if not MRP.Spawns[map]["vehicles"] then
        MRP.Spawns[map]["vehicles"] = {}
    end
	local cat
	if string.find(class, "simfphys") or string.find(class, "sim_fphys") then
		cat = "simfphys"
	else
		cat = "wac"
	end
    table.insert(
		MRP.Spawns[map]["vehicles"],
		{
			pos = ply:GetPos(),
		        ang = ply:GetAngles(),
                        class = class,
			cat = cat,
		}
	)
    save()
    ply:ChatPrint(class .. " spawn added")
end

MRP.Commands.vehic.list = function(ply)
    local map = game.GetMap()
    local tb = MRP.Spawns[map]["vehicles"]
    for id,row in ipairs(tb) do
        ply:ChatPrint("ID: "..id)
        ply:ChatPrint(util.TableToJSON(row, true))
    end
end

MRP.Commands.vehic.rm = function(ply, id)
    local map = game.GetMap()
    table.remove(MRP.Spawns[map]["vehicles"], id)
    save()
end
