local tbName = MRP.TABLE_CHAR
local TAG = "sv_character"

hook.Add("CanChangeRPName", "MRP_CanChangeRPName", function()
    return false, "c'est comme ça"
end)

local function getPlayerData(ply)
    local data =
        sql.Query(
            "SELECT * FROM " .. SQLStr(tbName) ..
            " WHERE SteamID64 = " .. ply:SteamID64() .. ";"
        )
    return data
end

function MRP.SpawnPlayer(ply)
    ply:Spawn()
    ply:SetShouldServerRagdoll(true)
end

function MRP.SaveProgress(ply)
    if ply:MRPFaction()==0 then return end
    local cid = ply:MRPCharacterID()
    hook.Run("MRP_SaveProgress", ply, cid)
    sql.Query(
        "UPDATE " .. tbName ..
        " SET " ..
            "Rank = " .. ply:GetNWInt("Rank") ..
        " WHERE CharacterID = " .. cid .. ";"
    )
end

gameevent.Listen("player_disconnect")

hook.Add("player_disconnect", "MRP_player_disconnect", function(userdata)
    Log.d("player_disconnect", "called")
    MRP.SaveProgress(Player(userdata.userid))
end)

hook.Add("ShutDown", "ServerShuttingDown", function()
    for _, ply in pairs(player.GetAll()) do
        MRP.SaveProgress(ply)
    end
end)

function MRP.SaveBodyGroupsData(ply)
    local BodyGroups = ply:GetBodygroup(0)

    for k = 1, ply:GetNumBodyGroups() - 1 do
        BodyGroups = BodyGroups .. "," .. ply:GetBodygroup(k)
    end

    sql.Query(
        "UPDATE " .. tbName .. " SET BodyGroups = " .. SQLStr(BodyGroups) ..
        " WHERE CharacterID = " .. ply:MRPCharacterID()
    )
end

local function sendCharacterData(data)
    net.WriteUInt(#data, 5)

    for _, v in pairs(data) do
        local cid = tonumber(v["CharacterID"])
        net.WriteUInt(cid, 32)
        net.WriteUInt(v.Faction, 2)
        net.WriteUInt(v.Regiment, 4)
        net.WriteUInt(v.Rank, 5)
        net.WriteString(v.RPName)
        net.WriteUInt(v.ModelIndex, 5)
        net.WriteUInt(v.Size, 8)
        net.WriteUInt(v.Skin, 5)
        net.WriteString(v.BodyGroups)
        local invData = sql.Query(
            "SELECT * FROM " .. MRP.TABLE_INV ..
            " WHERE CharacterID = " .. cid
            )[1]
        net.WriteUInt(invData.NVGs, 7)
        net.WriteUInt(invData.Helmet, 7)
        net.WriteUInt(invData.Gasmask, 7)
        net.WriteUInt(invData.Rucksack, 7)
        net.WriteUInt(invData.Vest, 7)
    end
end


local function handlePlayerData(ply, data, spawn)
    --PrintTable(data)
    if data == false then
        Log.e(TAG, "error selecting characters")
        Log.e(TAG, sql.LastError())
    elseif data == nil then
        net.Start("mrp_characters_creation")
        net.Send(ply)
    elseif spawn then
        net.Start("mrp_characters_selection")
        Log.d(TAG, "character selection")
        sendCharacterData(data)
        net.Send(ply)
    else
        net.Start("mrp_characters_update")
        sendCharacterData(data)
        net.Send(ply)
    end
end

local function equipPlayer(ply)
    ply:StripWeapons()
    for _, cat in pairs(MRP.WeaponCat) do
        if ply:MRPHas(cat) then
            local entTable = ply:MRPEntityTable(cat)
            local ent = ply:Give(entTable.WeaponClass)
            local rounds = ply[cat .. "Rounds"]
            Log.d("equipPlayer", cat .. " " .. rounds)
            ent:SetClip1(ply[cat .. "Rounds"])
        end
    end

    for k = 1, 20 do
        local entityTable = ply:MRPEntityTable("Inventory" .. k)
        if entityTable.Ammo then
            local ammo = ply:GetNWInt("Inventory" .. k .. "Rounds")
            local ammoType = entityTable.Ammo
            ply:GiveAmmo(ammo, ammoType, true)
        elseif entityTable.WeaponClass then
            ply:Give(entityTable.WeaponClass)
        end
    end
    ply:Give("weapon_fists")
    ply:Give("gmod_tool")
    ply:Give("re_hands")
    ply:Give("aradio")
    ply:Give("weapon_physgun")
    ply:Give("cross_arms_swep")
    ply:Give("cross_arms_infront_swep")
    ply:Give("surrender_animation_swep")
    ply:Give("french_salute")
    ply:Give("raise_your_hand")
end

MRP.PlyModels = {}

local originalSetModel = FindMetaTable("Entity").SetModel
local meta = FindMetaTable("Player")
function meta:SetModel(model)
    local mdl = MRP.PlyModels[self] or "models/player/barney.mdl"
    originalSetModel(self, mdl)
end

MRP.IsSetup = {}
hook.Add("PlayerSpawn", "MRP_char_PlayerSpawn", function( ply )
    Log.d(TAG, "PlayerSpawn hook")
    if not MRP.IsSetup[ply] then
        local data = getPlayerData(ply)
        handlePlayerData(ply, data, true)
        MRP.IsSetup[ply] = true
    else
        ply:setRPName(ply:MRPRankShort().." - "..ply:MRPName())
        local teamNums = {
            [1] = TEAM_FR,
            [2] = TEAM_REBELS,
        }
        ply:changeTeam(teamNums[ply:MRPFaction()], true)
        local mdl = MRP.PlayerModels[ply:MRPFaction()][ply:MRPModel()].Model
        MRP.PlyModels[ply] = mdl
        ply:SetModel(mdl)
        ply:SetModelScale(ply:GetNWInt("Size") / 180, 0)
        ply:SetViewOffset(Vector(0, 0, 64 * ply:GetNWInt("Size") / 180))
        ply:SetSkin(ply:GetNWInt("Skin"))

        for k, v in pairs(ply.BodyGroups) do
            ply:SetBodygroup(k - 1, v)
        end

        ply:SetupHands() -- Create the hands and call MRP:PlayerSetHandsModel
        equipPlayer(ply)
        return
    end

end )

net.Receive("CharacterInformation", function(_, ply)
    ply:MRPSetFaction(net.ReadUInt(2))
    ply:SetNWInt("Regiment", net.ReadUInt(4))
    ply:SetNWInt("Rank", 1)
    ply:SetNWString("RPName", net.ReadString())
    ply:SetNWInt("ModelIndex", net.ReadUInt(5))
    ply:SetNWInt("Size", net.ReadUInt(8))
    ply:SetNWInt("Skin", net.ReadUInt(5))
    ply:SetNWInt("Gasmask", 1)
    ply.BodyGroups = net.ReadString()
    ply:SetNWBool("GasmaskOn", false)
    ply:SetNWInt("PrimaryWep", 1)
    ply:SetNWInt("SecondaryWep", 1)
    ply:SetNWInt("RocketLauncher", 1)
    ply:SetNWInt("Vest", 1)
    ply:SetNWInt("VestArmor", 0)
    ply:SetNWInt("Rucksack", 1)
    ply:SetNWInt("Radio", 1)
    ply:SetNWInt("Gasmask", 1)
    ply:SetNWInt("Helmet", 1)
    ply:SetNWInt("HelmetArmor", 0)
    ply:SetNWInt("NVGs", 1)

    for k = 1, 5 do
        ply:SetNWInt("Inventory" .. k, 1)
        ply:SetNWInt("Inventory" .. k .. "Rounds", 0)
    end

    for k = 6, 20 do
        ply:SetNWInt("Inventory" .. k, 0)
        ply:SetNWInt("Inventory" .. k .. "Rounds", 0)
    end

    request =
        "INSERT INTO " .. MRP.TABLE_CHAR .. "(" ..
            "SteamID64, " ..
            "Faction, " ..
            "Regiment, " ..
            "RPName, " ..
            "ModelIndex, " ..
            "Size, " ..
            "Skin, " ..
            "BodyGroups)\n" ..
        "VALUES\n(" ..
            ply:SteamID64() .. ", " ..
            ply:MRPFaction() .. ", " ..
            ply:MRPRegiment() .. ", " ..
            SQLStr(ply:GetNWString("RPName")) .. ", " ..
            ply:GetNWInt("ModelIndex") .. ", " ..
            ply:GetNWInt("Size") .. ", " ..
            ply:GetNWInt("Skin") .. ", " ..
            SQLStr(ply.BodyGroups) .. ");"
    local sqlret = sql.Query(request)
    if sqlret == false then
        Log.d("SVCharacters", "error in character insertion")
        Log.d("SVCharacters", sql.LastError())
    else
        Log.d("SVCharacters", "### MRP character insertion succeed")
    end
    sqlret =
        sql.Query(
            "SELECT * " ..
            "FROM " .. MRP.TABLE_CHAR .. " " ..
            "WHERE SteamID64 = " .. ply:SteamID64() .. " " ..
            "AND RPName = " .. SQLStr(ply:GetNWString("RPName"))
        )
    if sqlret == false then
        Log.d("SVCharacters", "error could not get character CharacterID")
        Log.d("SVCharacters", sql.LastError())
    elseif sqlret == nil then
        Log.d("SVCharacters", "could not get character CharacterID")
    else
        Log.d("SVCharacters", "successfully got the character CharacterID")
        local cid = tonumber(sqlret[#sqlret]["CharacterID"])
        ply:SetNWInt("CharacterID", cid)

        hook.Run("CharacterRegistration", ply, cid)
        ply.BodyGroups = string.Split(ply.BodyGroups, ",")

        MRP.SpawnPlayer(ply)
    end
    local data = getPlayerData(ply)
    handlePlayerData(ply, data)
end)


net.Receive("mrp_characters_deletion", function(_, ply)
    local uid = net.ReadUInt(32)
    sql.Query("DELETE FROM " .. tbName .. " WHERE CharacterID = " .. uid)
    local data = getPlayerData(ply)
    handlePlayerData(ply, data)
end)

net.Receive("mrp_char_selected", function(_, ply)
    local uid = net.ReadUInt(32)
    local Character =
        sql.QueryRow(
            "SELECT * FROM " .. tbName .. " WHERE CharacterID = " .. tostring(uid)
        )
    ply:SetNWInt("CharacterID", tonumber(uid))
    hook.Run("MRP_CharacterSelected", ply, uid)
    Character.Faction = tonumber(Character.Faction)
    ply:SetNWString("RPName", Character.RPName)
    ply:MRPSetFaction(tonumber(Character.Faction))
    ply:SetNWInt("Regiment", tonumber(Character.Regiment))
    ply:SetNWInt("Rank", tonumber(Character.Rank))
    ply:SetNWInt("ModelIndex", tonumber(Character.ModelIndex))
    ply:SetNWInt("Size", tonumber(Character.Size))
    ply:SetNWInt("Skin", tonumber(Character.Skin))
    ply.Size = tonumber(Character.Size)
    ply.Skin = tonumber(Character.Skin)
    ply.BodyGroups = string.Split(Character.BodyGroups, ",")
    ply:SetNWBool("GasmaskOn", false)

    MRP.SpawnPlayer(ply)
end)
