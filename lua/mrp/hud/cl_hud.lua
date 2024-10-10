local hide = {
	["CHudHealth"] = true,
	["CHudAmmo"] = true,
	["CHudCrosshair"] = true,
	["CHudBattery"] = true,
	["CHudZoom"] = true,
}
RunConsoleCommand("mp_show_voice_icons", "0")

hook.Add("HUDShouldDraw", "MRP_HUDShouldDraw", function(name)
	if hide[name] then
		return false
	end
end)

hook.Add("HUDDrawPickupHistory", "MRP_HUDDrawPickupHistory", function()
	return true 
end)

hook.Add( "HUDItemPickedUp", "MRP_HUDItemPickedUp", function()
    return true
end)
