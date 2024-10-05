local TAG = "Utils"

MRP.SaveSpawns = function()
    file.Write(
        MRP.SpawnsFile,
        util.TableToJSON(MRP.Spawns, true)
    )
end

concommand.Add("mrp", function(ply, _, args)
    if ply:IsAdmin() then
        MRP.Commands[args[1]][args[2]](ply, args[3], args[4], args[5])
    end
end)

MRP.ListSpawns = function(ply, cat)
    local map = game.GetMap()
    local tb = MRP.Spawns[map][cat]
    for id, row in ipairs(tb) do
        ply:ChatPrint("ID: "..id)
        ply:ChatPrint(util.TableToJSON(row, true))
    end
end

MRP.RemoveSpawn = function(cat, id)
    local map = game.GetMap()
    table.remove(MRP.Spawns[map][cat], id)
    MRP.SaveSpawns()
end

MRP.FindPlayer = function(info)
    Log.d("findPlayer", "triggered")
    if not info or info == "" then
        Log.d("findPlayer", "no id provided")
        return nil
    end
    for _, p in ipairs( player.GetAll() ) do
        if p:SteamID() == info then
            return p
        end
        local rpname = string.lower(p:RPName())
        Log.d("findPlayer", rpname)
        if string.find(rpname, string.lower(tostring(info)), 1, true) ~= nil then
            return p
        end
    end
end

MRP.CreateTable = function(schema)
    local TAG = "TableCreation"
    Log.d(TAG, schema)
    local ret = sql.Query(schema)
    if ret == false then
        Log.d(TAG, "error")
        Log.d(TAG, sql.LastError())
    end
end

MRP.UpdateTable = function(name, schema)
    local existingTable =
        sql.QueryValue(
            "SELECT sql FROM sqlite_master " ..
            "WHERE name = " .. SQLStr(name)
        )
    if existingTable == nil then
        Log.d(TAG, "creating " .. name)
        MRP.CreateTable(schema)
    elseif existingTable ~= schema then
        Log.d(TAG, name .. " TABLE CHANGED SINCE LAST TIME")
        Log.d(TAG, existingTable)
        Log.d(TAG, "DELETING ...")
        sql.Query("DROP TABLE " .. SQLStr(name))
        sql.Query(schema)
    else
        Log.d(TAG, "TABLE " .. name .. " DID NOT CHANGED")
    end
end

MRP.SQLRequest = function(request)
    local TAG = "SQLReq"
    local sqlret = sql.Query(request)
    if sqlret == false then
        Log.d(TAG, "error in SQL request")
        Log.d(TAG, request)
        Log.d(TAG, sql.LastError())
    end
end


