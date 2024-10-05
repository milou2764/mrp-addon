MRP = MRP or {}
-- Function to load files based on their prefix
local function LoadFiles(module)
    local folderPath = "mrp/" .. module .. "/"
    local files, directories = file.Find(folderPath .. "*.lua", "LUA")

    for _, fileName in ipairs(files) do
        local filePath = folderPath .. fileName

        if string.StartWith(fileName, "sv_") then
            -- Load server-only files
            if SERVER then
                include(filePath)
                print("[SERVER] Loaded: " .. filePath)
            end
        elseif string.StartWith(fileName, "cl_") then
            -- Load client-only files
            if SERVER then
                AddCSLuaFile(filePath)
                print("[SERVER] Sent to client: " .. filePath)
            elseif CLIENT then
                include(filePath)
                print("[CLIENT] Loaded: " .. filePath)
            end
        elseif string.StartWith(fileName, "sh_") then
            -- Load shared files (both server and client)
            if SERVER then
                AddCSLuaFile(filePath)
            end
            include(filePath)
            print("[SHARED] Loaded: " .. filePath)
        end
    end
end

local modules = {
    "log",
    "config",
    "autoclean",
    "base",
    "hud",
    "rank",
    "scoreboard",
    "char",
    "gear",
    "inv",
    "meta",
    "npcspawn",
    "regwl",
    "vehiclespawn",
    "vgui",
}
for _,v in ipairs(modules) do
    LoadFiles(v)
end

