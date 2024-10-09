util.AddNetworkString("mrp_nvg_toggle")

concommand.Add("nvg_toggle", function(ply)
    if not ply:Alive() then return end
    if not ply:HasNVGs() then return end
    ply:SetNW2Bool("NVGsOn", not ply:GetNW2Bool("NVGsOn"))
    net.Start("mrp_nvg_toggle")
    net.WriteUInt(ply:UserID(), 16)
    net.Broadcast()
end)
