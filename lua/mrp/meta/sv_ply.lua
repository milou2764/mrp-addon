local plyMeta = FindMetaTable("Player")

function plyMeta:EquipHelmet(helmet)
    local mrpid = MRP.ClassID[helmet.ClassName]
    self:SetNWInt("HelmetArmor", helmet.Armor)
    self:SetNWInt("Helmet", mrpid)
    helmet:Remove()
end

function plyMeta:ChangeHelmet(newHelmet)
    local oldHelmet = ents.Create(MRP.EntityTable(self:GetNWInt("Helmet")).className)
    oldHelmet.Armor = self:GetNWInt("HelmetArmor")
    oldHelmet:Spawn()
    oldHelmet:SetPos( self:EyePos() - Vector(0, 0, 10) )

    self:EquipHelmet(newHelmet)
end

function plyMeta:EquipGasmask(gasmask)
    local mrpid = MRP.ClassID[gasmask.ClassName]
    self:SetNWInt("Gasmask", mrpid)
    local faction = self:MRPFaction()
    local model = self:MRPModel()
    local bodyGroup = gasmask.BodyGroup[faction][model][1]
    local bodyId = gasmask.BodyGroup[faction][model][2]
    self:SetBodygroup(bodyGroup, bodyId)
    sql.Query(
        "UPDATE mrp_characters " ..
        "SET Gasmask = " .. mrpid .. " " ..
        "WHERE CharacterID = " .. self:GetCharacterID()
    )
    MRP.SaveBodyGroupsData(self)
    gasmask:Remove()
end

function plyMeta:ChangeGasmask(newGasmask)
    local oldGasmask = ents.Create(MRP.EntityClass(self:MRPGasmask()).className)
    oldGasmask:Spawn()
    oldGasmask:SetPos( self:EyePos() - Vector(0, 0, 10) )

    self:EquipGasmask(newGasmask)
end

function plyMeta:EquipRucksack(rucksack)
    local mrpid = MRP.ClassID[rucksack.ClassName]
    self:SetNWInt( "Rucksack", mrpid )
    for k = rucksack.StartingIndex, rucksack.StartingIndex + rucksack.Capacity - 1 do
        self:SetNWInt("Inventory" .. k, rucksack["Slot" .. k])
        if MRP.EntityTable(rucksack["Slot" .. k]).Ammo then
            local ammo = rucksack["Slot" .. k .. "Rounds"]
            local ammoType = MRP.EntityTable(rucksack["Slot" .. k]).Ammo
            self:GiveAmmo(ammo, ammoType)
            self:SetNWInt("Inventory" .. k .. "Rounds", ammo)
        end
    end
    rucksack:Remove()
end

function plyMeta:ChangeRucksack(newRucksack)
    local oldRucksack = ents.Create(MRP.EntityTable(self:GetNWInt("Rucksack")).ClassName)
    for k = oldRucksack.StartingIndex, oldRucksack.StartingIndex + oldRucksack.Capacity - 1 do
        oldRucksack["Slot" .. 20-k] = self:GetNWInt("Inventory" .. k)
        if MRP.EntityTable(self:GetNWInt("Inventory" .. (20-k))).Ammo then
            local ammo = self:GetNWInt("Inventory" .. (20-k) .. "Rounds")
            local ammoType = MRP.EntityTable(self:GetNWInt("Inventory" .. (20-k))).Ammo
            oldRucksack["Slot" .. (20-k) .. "Rounds"] = ammo
            self:RemoveAmmo(ammo, ammoType)
        end
        self:SetNWInt("Inventory" .. (20-k), 1)
    end
    oldRucksack:Spawn()
    oldRucksack:SetPos(self:EyePos() - Vector(0, 0, 10))

    self:EquipRucksack(newRucksack)
end

function plyMeta:MRPInventoryPickup(ent)
    for k = 1, 20 do
        if self:GetNWInt("Inventory" .. k) == 1 then
            local mrpid = MRP.ClassID[ent.ClassName]
            self:SetNWInt( "Inventory" .. k, mrpid )
            self:SetNWInt( "Inventory" .. k .. "Armor", ent.Armor )
            ent:Remove()
            return
        end
    end
end

function plyMeta:pickupGear(gear)
    local mrpid = MRP.ClassID[gear.ClassName]
    self:SetNWInt(gear.MRPCategory, mrpid)
    net.Start("PlayerEquipGear")
    net.WriteUInt(mrpid, 7)
    net.WriteEntity(self)
    net.Broadcast()
    gear:Remove()
end
