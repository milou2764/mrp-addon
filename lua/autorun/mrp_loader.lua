MRP = MRP or {}

if SERVER then
    include("mrp_config/sh_debug_state.lua")
    include("mrp_log/sh_log.lua")
    AddCSLuaFile("mrp_config/sh_debug_state.lua")
    AddCSLuaFile("mrp_log/sh_log.lua")

    include("mrp_base/sv_functions.lua")

    include("mrp_config/sh_ammo.lua")
    include("mrp_config/sh_config.lua")
    include("mrp_config/sh_debug_state.lua")
    include("mrp_config/sv_config.lua")
    include("mrp_config/sh_1rec.lua")
    include("mrp_config/sh_2rep.lua")
    include("mrp_config/sh_5rhc.lua")
    include("mrp_config/sh_factions.lua")
    AddCSLuaFile("mrp_config/cl_config.lua")
    AddCSLuaFile("mrp_config/sh_ammo.lua")
    AddCSLuaFile("mrp_config/sh_config.lua")
    AddCSLuaFile("mrp_config/sh_debug_state.lua")
    AddCSLuaFile("mrp_config/sh_1rec.lua")
    AddCSLuaFile("mrp_config/sh_2rep.lua")
    AddCSLuaFile("mrp_config/sh_5rhc.lua")
    AddCSLuaFile("mrp_config/sh_factions.lua")

    include("mrp_meta/sh_entity.lua")
    include("mrp_meta/sh_ply.lua")
    include("mrp_meta/sv_ply.lua")
    AddCSLuaFile("mrp_meta/sh_entity.lua")
    AddCSLuaFile("mrp_meta/sh_ply.lua")

    include("mrp_gear/sv_gear.lua")
    AddCSLuaFile("mrp_gear/cl_gear.lua")

    include("mrp_rank/sv_rank.lua")

    include("mrp_char/sv_database.lua")
    include("mrp_char/sv_character.lua")
    include("mrp_char/sv_net.lua")
    AddCSLuaFile("mrp_char/cl_character.lua")

    include("mrp_inv/sv_database.lua")
    include("mrp_inv/sv_inventory.lua")
    include("mrp_inv/sh_inventory.lua")
    AddCSLuaFile("mrp_inv/sh_inventory.lua")
    AddCSLuaFile("mrp_inv/cl_inventory.lua")

    include("mrp_wl/sv_net.lua")
    include("mrp_wl/sv_database.lua")
    include("mrp_wl/sv_commands.lua")
    AddCSLuaFile("mrp_wl/cl_functions.lua")

    AddCSLuaFile("mrp_hud/cl_hud.lua")
    AddCSLuaFile("mrp_vgui/cl_vgui.lua")

elseif CLIENT then
    include("mrp_config/sh_debug_state.lua")

    include("mrp_log/sh_log.lua")

    include("mrp_config/cl_config.lua")
    include("mrp_config/sh_ammo.lua")
    include("mrp_config/sh_config.lua")
    include("mrp_config/sh_debug_state.lua")
    include("mrp_config/sh_1rec.lua")
    include("mrp_config/sh_2rep.lua")
    include("mrp_config/sh_5rhc.lua")
    include("mrp_config/sh_factions.lua")

    include("mrp_char/cl_character.lua")

    include("mrp_meta/sh_entity.lua")
    include("mrp_meta/sh_ply.lua")

    include("mrp_gear/cl_gear.lua")

    include("mrp_inv/sh_inventory.lua")
    include("mrp_inv/cl_inventory.lua")

    include("mrp_wl/cl_functions.lua")

    include("mrp_hud/cl_hud.lua")
    include("mrp_vgui/cl_vgui.lua")
end
