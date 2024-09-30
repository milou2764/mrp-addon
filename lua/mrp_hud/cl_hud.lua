local hide = {
	["CHudHealth"] = true,
	["CHudAmmo"] = true,
	["CHudCrosshair"] = true,
	["CHudBattery"] = true
}

hook.Add( "HUDShouldDraw", "MRP_HUDShouldDraw", function( name )
	if ( hide[name] ) then
		return false
	end
end )
