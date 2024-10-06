util.AddNetworkString("mrp_gear_playerspawn")
util.AddNetworkString("mrp_gear_drop")
util.AddNetworkString("mrp_gear_mnt")
util.AddNetworkString("mrp_gear_umnt")
util.AddNetworkString("mrp_gear_dndrp_mnt")
util.AddNetworkString("mrp_gear_dndrp_umnt")

hook.Add("PlayerSpawn", "MRP_Gear_PlayerSpawn", function(ply)
    -- Player is not alive right away and there is no better hook
    -- PlayerSetModel does not work either
    timer.Simple(3, function()
        net.Start("mrp_gear_playerspawn")
        net.WriteEntity(ply)
        net.Broadcast()
    end)
end)

net.Receive("mrp_gear_drop", function(_, ply)
    local mrpid = net.ReadUInt(7)
    local target = net.ReadEntity()
    local slotName = net.ReadString()
    net.Start("mrp_gear_umnt")
    net.WriteUInt(mrpid, 7)
    net.WriteEntity(target)
    net.Broadcast()
    MRP.EntityTable(mrpid):drop(slotName, target, ply)
end)

net.Receive("mrp_gear_dndrp_mnt", function(_, _)
    local mrpid = net.ReadUInt(7)
    local target = net.ReadEntity()
    net.Start("mrp_gear_mnt")
    net.WriteUInt(mrpid, 7)
    net.WriteEntity(target)
    net.Broadcast()
end)

net.Receive("mrp_gear_dndrp_umnt", function(_, _)
    local mrpid = net.ReadUInt(7)
    local target = net.ReadEntity()
    net.Start("mrp_gear_umnt")
    net.WriteUInt(mrpid, 7)
    net.WriteEntity(target)
    net.Broadcast()
end)

hook.Add("ScalePlayerDamage", "MRP_Gear_SPD", function(ply, hitgroup, dmginfo)
    local gear
    local function ScaleDamage()
        local baseArmor = MRP.EntityTable(ply:GetNWInt(gear)).Armor
        local newArmor =
            math.Clamp(
                math.floor(ply:GetNWInt(gear .. "Armor") - dmginfo:GetDamage()),
                0,
                baseArmor
            )
        ply:SetNWInt(gear .. "Armor", newArmor)
        dmginfo:SetDamage(
            dmginfo:GetDamage() * (1 - ply:GetNWInt(gear .. "Armor") / baseArmor)
        )
    end

    if hitgroup == HITGROUP_HEAD and ply:MRPHas("Helmet") then
        gear = "Helmet"
        ScaleDamage()
    elseif hitgroup == HITGROUP_CHEST and ply:MRPHas("Vest") then
        gear = "Vest"
        ScaleDamage()
    end
end)



