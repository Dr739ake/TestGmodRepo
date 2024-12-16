if (SERVER) then 
	AddCSLuaFile("autorun/cl_decals.lua")
end

-- Decals Clean Up
function ulx.decals(ply)
	umsg.Start("ulx.decals")
	umsg.End()
	ulx.fancyLogAdmin(ply,"#A cleaned up decals.")
end

local decals = ulx.command("Utility","ulx decals",ulx.decals,"!decals")
decals:defaultAccess(ULib.ACCESS_ADMIN)
decals:help("Cleans up all decals and ragdolls in the server.")