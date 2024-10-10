MRP.AmmoLimits = {
    ["PG-7VM Grenade"] = 1,
    ["Frag Grenades"] = 2,
    ["Smoke Grenades"] = 2,
}

hook.Add(
    "PlayerAmmoChanged",
    "MRP_ammolimit",
    function(ply, ammoID, _, newCount)
        local tb = MRP.AmmoLimits
        local name = game.GetAmmoName(ammoID)
        if tb[name] and newCount > tb[name] then
            ply:RemoveAmmo(newCount - tb[name], name)
        end
    end
)
