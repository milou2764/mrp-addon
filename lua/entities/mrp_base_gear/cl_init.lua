include("shared.lua")

function ENT:dropFromInventoryPanel(entPanel)
    if entPanel:GetName() == self.MRPCategory then
        local mrpid = MRP.ClassID[self.ClassName]
        net.Start("mrp_gear_drop")
        net.WriteUInt(mrpid, 7)
        net.WriteEntity(entPanel.owner)
        net.WriteString(entPanel:GetName())
        net.SendToServer()
        --entPanel.Model:Remove()
        entPanel:switchOff()
    else
        baseclass.Get("mrp_base_entity").dropFromInventoryPanel(self, entPanel)
    end
end

function ENT:getGearModelPath()
    return self.Model
end

function ENT:createCSModel(target)
    local modelPath = self:getGearModelPath()
    local model = ClientsideModel(modelPath)
    model:SetParent(target)
    model:AddEffects(EF_BONEMERGE)
    model:SetIK(false)
    model:SetTransmitWithParent(true)

    return model
end

function ENT:unmount(target)
    local userid
    if target.UserID then
        userid = target:UserID()
    else
        userid = target:EntIndex()
    end
    MRP.mountedGear[userid] = MRP.mountedGear[userid] or {}
    local model = MRP.mountedGear[userid][self.MRPCategory]
    if IsValid(model) and model.Remove then
        table.RemoveByValue(MRP.mountedGear[userid], model)
        model:Remove()
    end
end

function ENT:makeDroppable(slotPanel, slotName)
    slotPanel:Receiver(slotName, function(dest, panels, bDoDrop, _, _, _)
        if bDoDrop and not dest.entPanel then
            gear = self
            for _, v in pairs(panels) do
                local origin = v:GetParent()
                if origin.owner ~= dest.owner then
                    net.Start("ItemSwitchOwner")
                    net.WriteEntity(origin.owner)
                    net.WriteString(origin:GetName())
                    net.WriteEntity(dest.owner)
                    net.WriteString(dest:GetName())
                    net.SendToServer()
                else
                    net.Start("ItemSwitchSlot")
                    net.WriteEntity(origin.owner)
                    net.WriteString(origin:GetName())
                    net.WriteString(dest:GetName())
                    net.SendToServer()
                end
                if dest:GetName() == gear.MRPCategory then
                    local mrpid = MRP.ClassID[v.gear.ClassName]
                    net.Start("mrp_gear_dndrp_mnt")
                    net.WriteUInt(mrpid, 7)
                    net.WriteEntity(dest.owner)
                    net.SendToServer()
                    if
                        origin.owner:IsPlayer() and
                        origin:GetName() == v.gear.MRPCategory
                    then
                        net.Start("mrp_gear_dndrp_umnt")
                        net.WriteUInt(mrpid, 7)
                        net.WriteEntity(origin.owner)
                        net.SendToServer()
                        v.Model:SetParent(dest:GetParent().pmodel.Entity)
                    else
                        dest:GetParent().pmodel.Entity:AddGear(v)
                    end
                end
                v:SetParent(dest)
                v:SetName(dest:GetName())
                dest.entPanel = v
                v:switchOwner(dest)
            end
        end
    end)
end
