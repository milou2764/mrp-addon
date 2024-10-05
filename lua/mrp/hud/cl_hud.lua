local hide = {
	["CHudHealth"] = true,
	["CHudAmmo"] = true,
	["CHudCrosshair"] = true,
	["CHudBattery"] = true
}
RunConsoleCommand("mp_show_voice_icons", "0")

hook.Add( "HUDShouldDraw", "MRP_HUDShouldDraw", function( name )
	if hide[name] then
		return false
	end
end )
