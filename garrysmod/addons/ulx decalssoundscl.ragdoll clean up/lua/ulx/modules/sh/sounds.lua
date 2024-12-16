if (SERVER) then 
	AddCSLuaFile("autorun/cl_sounds.lua") 
end

-- Sounds Clean Up
function ulx.sounds(ply)
	umsg.Start("ulx.sounds")
	umsg.End()
	ulx.fancyLogAdmin(ply,"#A cleaned up sounds.")
end

local decals = ulx.command("Utility","ulx sounds",ulx.sounds,"!sounds")
decals:defaultAccess(ULib.ACCESS_ADMIN)
decals:help("Cleans up all sounds in the server.")