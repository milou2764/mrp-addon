AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include('shared.lua')

local TAG = 'mrp_base_gear'

function ENT:CanBeEquipped(ply)
    local cat = self.MRPCategory
    Log.d(TAG, 'CanBeEquipped')
    local status = ply:GetNWInt(cat)
    Log.d(TAG, cat .. ' ' .. status)

    if ply:GetNWInt(self.MRPCategory) == 1 then
        return true
    end
    return false
end

function ENT:equip(ply)
    Log.d(self.ClassName, 'ENT:equip')
    local mrpid = MRP.ClassID[self.ClassName]
    ply:SetNWInt(self.MRPCategory, mrpid)
    net.Start('mrp_gear_mnt')
    net.WriteUInt(mrpid, 7)
    net.WriteEntity(ply)
    net.Broadcast()
    self:Remove()
end

function ENT:Use(activator, _, _, _)
    if self:CanBeEquipped(activator) then
        Log.d(TAG, 'equip')
        self:equip(activator)
    else
        Log.d(TAG, 'store')
        activator:MRPInventoryPickup(self)
    end
end


function ENT:drop(slotName, target, activator)
    if target.mountedGear and target.mountedGear[slotName] then
        target.mountedGear[slotName]:Remove()
    end
    return baseclass.Get('mrp_base_entity').drop(self, slotName, target, activator)
end

function ENT:createServerModel(target)
    local model = ents.Create('prop_dynamic')
    model:SetModel(self.Model)
    model:SetParent(target)
    model:AddEffects(EF_BONEMERGE)

    return model
end
