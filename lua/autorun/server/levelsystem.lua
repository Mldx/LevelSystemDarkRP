--SERVER SCRIPT
util.AddNetworkString("xp")	

local function tables_exist()
	--sql.Query("DROP TABLE players_levelsystem;")
	if sql.TableExists("players_levelsystem") then
		MsgC( Color( 0, 255, 0 ), "Level System: ")
		print("Using existing database.")

	else
		query = "CREATE TABLE players_levelsystem (steamid varchar(255),level int,xp int,xpneeded int, UNIQUE(steamid))";
		result = sql.Query(query)
		if (sql.TableExists("players_levelsystem")) then
			MsgC( Color( 0, 255, 0 ), "Level System: ")
			print("The database was successfully created.")
		else
			MsgC( Color( 0, 255, 0 ), "Level System: ")
			print("Failed to create the database.")
			print(sql.LastError(result))
		end
	end
end

local function sql_getvalues (pl)
	pl:SetNWInt("level", sql.QueryValue("SELECT level FROM players_levelsystem WHERE steamid = '"..steamID.."'"))
	pl:SetNWInt("xp", sql.QueryValue("SELECT xp FROM players_levelsystem WHERE steamid = '"..steamID.."'"))
	pl:SetNWInt("xpneeded", sql.QueryValue("SELECT xpneeded FROM players_levelsystem WHERE steamid = '"..steamID.."'"))
	MsgC( Color( 0, 255, 0 ), "Level System (sql_getvalues): ")
	print("Level = " ..pl:GetNWInt("level").. "   Xp = " ..pl:GetNWInt("xp").. "   Xpneeded = "..pl:GetNWInt("xpneeded"))
end

local function new_player(pl)
	steamID = pl:SteamID()
	sql.Query("INSERT OR IGNORE INTO players_levelsystem (`steamid`, `level`, `xp`, `xpneeded`) VALUES ('"..steamID.."', '1', '0', '200')")
	result = sql.Query("SELECT steamid, level, xp, xpneeded FROM players_levelsystem WHERE steamid = '"..steamID.."'")
	if (result) then
		sql_getvalues(pl)
	else
		MsgC( Color( 0, 255, 0 ), "Level System: ")
		print("Something went wrong creating the new player.")
		print(sql.LastError(result))
	end
end

--local function player_exists(pl)
--	steamID = pl:GetNWString("SteamID")
--	result = sql.Query("SELECT steamid, level, xp, xpneeded FROM players_levelsystem WHERE steamid = '"..steamID.."'")
--	if (result) then
--		sql_levelsystem(pl)
--		print("Level System: An already existing user joined the server.")
--	else
--		new_player(steamID, pl)
--	end
--end

local function savelevel(pl)
	unique_id = pl:SteamID()
	level = pl:GetNWInt("level")
	xp = pl:GetNWInt("xp")
	xpneeded = pl:GetNWInt("xpneeded")
	MsgC( Color( 0, 255, 0 ), "Level System (savelevel): ")
	print("steamid = "..unique_id.."   level = "..level.."   xp = "..xp.."   xpneeded = "..xpneeded)
	sql.Query("UPDATE players_levelsystem SET level = "..level..", xp = "..xp..", xpneeded = "..xpneeded.." WHERE steamid = '"..unique_id.."'")
end

hook.Add("PlayerInitialSpawn", "MyXP_FirstSpawn", function(pl) 
	pl:SetNWInt("xp", 0)
	pl:SetNWInt("level", 1)
	pl:SetNWInt("xpneeded", 200)
end)

local function InitialSpawnDB(pl)
	timer.Create("Steam_id_delay", 1, 1, function() --Sets up a little delay cause otherwise the steamid wont be available yet
		new_player(pl) --Calls our player exists local function
	end)
end

hook.Add( "PlayerInitialSpawn", "InitialSpawnDB", InitialSpawnDB )	


timer.Create("XPTimer", 10, 0, function()  --Sync Database with the server, and Sync Client with server.

	for k, v in pairs(player.GetAll()) do
	
		v:SetNWInt("xp", v:GetNWInt("xp") + 10)
		if tonumber(v:GetNWInt("xp")) >= tonumber(v:GetNWInt("xpneeded")) then 
			v:SetNWInt("xp", 0)
			v:SetNWInt("level", v:GetNWInt("level")+1)
			v:SetNWInt("xpneeded", v:GetNWInt("xpneeded")+100)
			PrintMessage( HUD_PRINTTALK, v:GetName() .. " just leveled up to level " .. v:GetNWInt("level") .. "!" )
		end
		
		savelevel(v)

		net.Start("xp")
		net.WriteInt(v:GetNWInt("level"), 32)
		net.WriteInt(v:GetNWInt("xp"), 32)
		net.WriteInt(v:GetNWInt("xpneeded"), 32)
		net.Send(v)
		
	end
	
end)

tables_exist()	