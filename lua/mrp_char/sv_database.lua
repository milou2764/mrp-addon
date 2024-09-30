local tbName = MRP.TABLE_CHAR

local schema =
    "CREATE TABLE " .. SQLStr(tbName) .. "(" ..
    "CharacterID INTEGER PRIMARY KEY autoincrement," ..
    "SteamID64 BIGINT NOT NULL," ..
    "Faction INT," ..
    "Regiment INT," ..
    "Rank INT DEFAULT '1'," ..
    "RPName TEXT," ..
    "ModelIndex INT," ..
    "Size SMALLINT NOT NULL," ..
    "Skin TINYINT," ..
    "BodyGroups TEXT" ..
    ")"


MRP.UpdateTable(MRP.TABLE_CHAR, schema)


