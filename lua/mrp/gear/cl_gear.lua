net.Receive("mrp_gear_playerspawn", function()
    local target = net.ReadEntity()

    MRP.LoadPlayerGear(target)
end)

net.Receive("mrp_gear_mnt", function()
    local mrpid = net.ReadUInt(7)
    local MRPEnt = MRP.EntityTable(mrpid)
    local target = net.ReadEntity()
    local userid
    if target.UserID then
        userid = target:UserID()
    else
        userid = target:EntIndex()
    end
    MRP.mountedGear[userid] = MRP.mountedGear[userid] or {}
    MRP.mountedGear[userid][MRPEnt.MRPCategory] = MRPEnt:createCSModel(target)
end)

net.Receive("mrp_gear_umnt", function()
    local mrpid = net.ReadUInt(7)
    local MRPEnt = MRP.EntityTable(mrpid)
    local target = net.ReadEntity()
    MRPEnt:unmount(target)
end)

function MRP.LoadPlayerGear(p)
    if not IsValid(p) then return end
    local getID = p.MRPGetID
    local userid
    if p.UserID then
        userid = p:UserID()
    else
        userid = p
    end
    MRP.mountedGear[userid] = MRP.mountedGear[userid] or {}
    for _, gear in pairs(MRP.mountedGear[userid]) do
        if gear.Remove then
            gear:Remove()
        end
    end
    if p:MRPHas("NVGs") then
        MRP.mountedGear[userid]["NVGs"] =
            MRP.EntityTable(p:GetNWInt("NVGs")):createCSModel(p)
    end
    if p:MRPHas("Helmet") then
        MRP.mountedGear[userid]["Helmet"] =
            MRP.EntityTable(p:GetNWInt("Helmet")):createCSModel(p)
    end
    if p:MRPHas("Gasmask") then
        MRP.mountedGear[userid]["Gasmask"] =
            MRP.EntityTable(p:GetNWInt("Gasmask")):createCSModel(p)
    end
    if p:MRPHas("Rucksack") then
        MRP.mountedGear[userid]["Rucksack"] =
            MRP.EntityTable(p:GetNWInt("Rucksack")):createCSModel(p)
    end
    if p:MRPHas("Vest") then
        MRP.mountedGear[userid]["Vest"] =
            MRP.EntityTable(p:GetNWInt("Vest")):createCSModel(p)
    end
end
hook.Add("InitPostEntity", "MRP_Gear_Init", function()
    timer.Simple(10, function()
        for _, v in pairs(player.GetAll()) do
            MRP.LoadPlayerGear(v)
        end
    end)
end)

hook.Add("NotifyShouldTransmit", "MRPNotifyShouldTransmitGear", function(ent, shouldTransmit)
    if ent:IsPlayer() and ent.UserID then
        if MRP.mountedGear[ent:UserID()] then
            for _, v in pairs(MRP.mountedGear[ent:UserID()]) do
                if IsValid(v) and shouldTransmit then
                    v:SetNoDraw(false)
                    v:SetParent(ent)
                    v:AddEffects(EF_BONEMERGE)
                    v:SetIK(false)
                elseif IsValid(v) then
                    v:SetNoDraw(true)
                end
            end
        else
            MRP.LoadPlayerGear(ent)
        end
    end
end)

local function unmountGear(userid)
    MRP.mountedGear = MRP.mountedGear or {}
    MRP.mountedGear[userid] = MRP.mountedGear[userid] or {}
    for _, v in pairs(MRP.mountedGear[userid]) do
        if v.Remove then v:Remove() end
    end
end
gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "MRP_RemovePlayerGear", function(data)
    unmountGear(data.userid)
end)
