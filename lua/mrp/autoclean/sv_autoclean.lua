local CleanupDelay = 0
local function MRPCleanup()
    for _, ent in pairs(ents.GetAll()) do
        ent:RemoveAllDecals()
        --ragdoll cleanup
        --if TempTable[k]:IsRagdoll() then
            --TempTable[k]:Remove()
        --end
    end
end

concommand.Add("mrp_cleanup", MRPCleanup)

local function AutoCleanup()
    if CurTime() > CleanupDelay then
        CleanupDelay = CurTime() + 500
        MRPCleanup()
    end
end

hook.Add("Think", "AutoClean", AutoCleanup)


