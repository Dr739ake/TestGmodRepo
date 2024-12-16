------------------------ CHANGELOG ------------------------
-- 
-----------------------------------------------------------

local CATEGORY_NAME = "DarkRP"

// !addmoney
function ulx.addMoney( calling_ply, target_ply, amount )
	local total = target_ply:getDarkRPVar("money") + math.floor(amount)
	total = hook.Call("playerWalletChanged", GAMEMODE, target_ply, amount, target_ply:getDarkRPVar("money")) or total
	target_ply:setDarkRPVar("money", total)
	if target_ply.DarkRPUnInitialized then return end
	DarkRP.storeMoney(target_ply, total)
	ulx.fancyLogAdmin( calling_ply, "#A gave #T #s", target_ply, DarkRP.formatMoney(amount) )
end
local addMoney = ulx.command( CATEGORY_NAME, "ulx addmoney", ulx.addMoney, "!addmoney" )
addMoney:addParam{ type=ULib.cmds.PlayerArg }
addMoney:addParam{ type=ULib.cmds.NumArg, min=-2000000, max=3000000, default=1000, hint="money" }
addMoney:defaultAccess( ULib.ACCESS_SUPERADMIN )
addMoney:help( "Adds money to players DarkRP wallet." )

// !setname
function ulx.setName( calling_ply, target_ply, name )
	target_ply:setRPName( name )
	ulx.fancyLogAdmin( calling_ply, "#A set #T's RP Name to #s", target_ply, name )
end
local setName = ulx.command( CATEGORY_NAME, "ulx setname", ulx.setName, "!setname" )
setName:addParam{ type=ULib.cmds.PlayerArg }
setName:addParam{ type=ULib.cmds.StringArg, hint="new name", ULib.cmds.takeRestOfLine }
setName:defaultAccess( ULib.ACCESS_ADMIN )
setName:help( "Sets target's RPName." )

// !setjob
function ulx.setJob( calling_ply, target_ply, job )
    local newjob = nil
	if RPExtraTeams == nil then
		ULib.tsayError( calling_ply, "Something went wrong, are your jobs correct?", true )
		return
	end	
	if tonumber(job) then --by id
		newjob = RPExtraTeams[tonumber(job)] --way faster! you just need to know the jobs teamnumber (better for other lua scripts to use it)
	else
		for i,v in pairs( RPExtraTeams ) do
			if	string.lower( v.name ) == string.lower( job ) or 
				string.lower( v.command ) == string.lower( job ) or
				string.lower( "vote"..v.command ) == string.lower( job )
			then --exact match
				newjob = v
				break
			elseif 	string.find( string.lower( v.name ), string.lower( job ) ) != nil or
					string.find( string.lower( "vote"..v.command ), string.lower( job ) ) != nil
			then
				if not newjob or (newjob and string.len(v.name) < string.len(newjob.name)) then --always take the matching job with the shortest name else "Civil Protection" could end up with "Civil Protection Chief"
					newjob = v
				end
			end
		end
	end
	if newjob == nil then
		ULib.tsayError( calling_ply, "That job does not exist!", true )
		return 
	end
	if newjob.customCheck and isfunction(newjob.customCheck) and not newjob.customCheck(calling_ply) then
		local errorMsg = "You don't have permission to set to this job!"
		if newjob.CustomCheckFailMsg then
			errorMsg = (isstring(newjob.CustomCheckFailMsg) and newjob.CustomCheckFailMsg) or (isfunction(newjob.CustomCheckFailMsg) and newjob.CustomCheckFailMsg(calling_ply, newjob)) or errorMsg
		end
		ULib.tsayError( calling_ply, errorMsg, true )
		return 
	end	
	local SetTeam = target_ply.changeTeam or target_ply.SetTeam --uses darkrps own functions now
	SetTeam(target_ply, newjob.team, true)
	ulx.fancyLogAdmin( calling_ply, "#A set #T's job to #s", target_ply, newjob.name )
end
local setJob = ulx.command( CATEGORY_NAME, "ulx setjob", ulx.setJob, "!setjob" )
setJob:addParam{ type=ULib.cmds.PlayerArg }
setJob:addParam{ type=ULib.cmds.StringArg, hint="new job", ULib.cmds.takeRestOfLine }
setJob:defaultAccess( ULib.ACCESS_ADMIN )
setJob:help( "Sets target's Job." )

// !shipment
function ulx.shipment(calling_ply, item_name, item_amount)
    local found, foundKey = DarkRP.getShipmentByName(item_name)
    if ( isnumber( foundKey ) ) then
		local trace = {}
		trace.start = calling_ply:EyePos()
		trace.endpos = trace.start + calling_ply:GetAimVector() * 85
		trace.filter = calling_ply

		local crate = ents.Create(found.shipmentClass or "spawned_shipment")
		crate.SID = calling_ply.SID
		crate:Setowning_ent(calling_ply)
		crate:SetContents(foundKey,item_amount)

		crate:SetPos(util.TraceLine(trace).HitPos)
		crate.nodupe = true
		crate.ammoadd = found.spareammo
		crate.clip1 = found.clip1
		crate.clip2 = found.clip2
		crate:Spawn()
		crate:SetPlayer(calling_ply)

		local phys = crate:GetPhysicsObject()
		phys:Wake()
		if found.weight then
			phys:SetMass(found.weight)
		end

		ulx.fancyLogAdmin( calling_ply, "#A spawned shipment #s with an amount of #s.", item_name, item_amount )
	else
	    ULib.tsayError(calling_ply, "Unable to find Shipment named: " ..item_name.. "!", true)
    end
end
local shipment = ulx.command(CATEGORY_NAME, "ulx shipment", ulx.shipment, "!shipment", true)
shipment:addParam{ type = ULib.cmds.StringArg, hint = "shipment name" }
shipment:addParam{ type=ULib.cmds.NumArg, min=1, max=1000, default=10, hint="amount", ULib.cmds.round, ULib.cmds.optional }
shipment:defaultAccess( ULib.ACCESS_SUPERADMIN )
shipment:help("Spawns a shipment.")

// !jobban
function ulx.jobBan( calling_ply, target_ply, job , ban_time )
	local newnum = nil
    local newname = nil
	if RPExtraTeams == nil then
		ULib.tsayError( calling_ply, "Something went wrong, are your jobs correct?", true )
		return
	end	
	for i,v in pairs( RPExtraTeams ) do
		if	string.lower( v.name ) == string.lower( job ) or 
			string.lower( v.command ) == string.lower( job ) or
			string.lower( "vote"..v.command ) == string.lower( job )
		then --exact match
			newnum = i
			newname = v.name
			break
		elseif 	string.find( string.lower( v.name ), string.lower( job ) ) != nil or
				string.find( string.lower( "vote"..v.command ), string.lower( job ) ) != nil
		then
			if not newjob or (newjob and string.len(v.name) < string.len(newjob.name)) then --always take the matching job with the shortest name else "Civil Protection" could end up with "Civil Protection Chief"
				newnum = i
				newname = v.name
			end
		end
	end
	if newnum == nil then
		ULib.tsayError( calling_ply, "That job does not exist!", true )
		return
	end
	target_ply:teamBan( newnum, ban_time )
	ulx.fancyLogAdmin( calling_ply, "#A has banned #T for #s from job #s", target_ply, ban_time, newname )
end
local jobBan = ulx.command( CATEGORY_NAME, "ulx jobban", ulx.jobBan, "!jobban" )
jobBan:addParam{ type=ULib.cmds.PlayerArg }
jobBan:addParam{ type=ULib.cmds.StringArg, hint="job" }
jobBan:addParam{ type=ULib.cmds.NumArg, min=0, max=360000, default=0, hint="time in seconds (0 = forever)", ULib.cmds.round, ULib.cmds.optional }
jobBan:defaultAccess( ULib.ACCESS_ADMIN )
jobBan:help( "Bans target from specified job." )

// !jobunban
function ulx.jobUnBan( calling_ply, target_ply, job )
	local newnum = nil
    local newname = nil
	if RPExtraTeams == nil then
		ULib.tsayError( calling_ply, "Something went wrong, are your jobs correct?", true )
		return
	end	
	for i,v in pairs( RPExtraTeams ) do
		if	string.lower( v.name ) == string.lower( job ) or 
			string.lower( v.command ) == string.lower( job ) or
			string.lower( "vote"..v.command ) == string.lower( job )
		then --exact match
			newnum = i
			newname = v.name
			break
		elseif 	string.find( string.lower( v.name ), string.lower( job ) ) != nil or
				string.find( string.lower( "vote"..v.command ), string.lower( job ) ) != nil
		then
			if not newjob or (newjob and string.len(v.name) < string.len(newjob.name)) then --always take the matching job with the shortest name else "Civil Protection" could end up with "Civil Protection Chief"
				newnum = i
				newname = v.name
			end
		end
	end
	if newnum == nil then
		ULib.tsayError( calling_ply, "That job does not exist!", true )
		return
	end
	target_ply:teamUnBan( newnum )
	ulx.fancyLogAdmin( calling_ply, "#A has unbanned #T from job #s", target_ply, newname, time )
end
local jobUnBan = ulx.command( CATEGORY_NAME, "ulx jobunban", ulx.jobUnBan, "!jobunban" )
jobUnBan:addParam{ type=ULib.cmds.PlayerArg }
jobUnBan:addParam{ type=ULib.cmds.StringArg, hint="job" }
jobUnBan:defaultAccess( ULib.ACCESS_ADMIN )
jobUnBan:help( "Unbans target from specified job." )

// !selldoor
function ulx.sellDoor( calling_ply )
	local trace = util.GetPlayerTrace( calling_ply )
	local traceRes = util.TraceLine( trace )
	local tEnt = traceRes.Entity
	if tEnt != nil and tEnt:isDoor() then	
		if tEnt:isKeysOwned() then
			tEnt:keysUnOwn( tEnt:getDoorOwner() )
			ulx.fancyLogAdmin( calling_ply, "#A sold a door" )
		else
			ULib.tsayError( calling_ply, "The door must be owned!" )
		end
	else
		ULib.tsayError( calling_ply, "You're not looking at a door!" )
	end
end
local sellDoor = ulx.command( CATEGORY_NAME, "ulx selldoor", ulx.sellDoor, "!selldoor" )
sellDoor:defaultAccess( ULib.ACCESS_ADMIN )
sellDoor:help( "Unowns door you are looking at." )

// !doorowner
function ulx.doorOwner( calling_ply, target_ply )
	local trace = util.GetPlayerTrace( calling_ply )
	local traceRes = util.TraceLine( trace )
	local tEnt = traceRes.Entity
	if tEnt != nil and tEnt:isDoor() then
		if tEnt:isKeysOwned() then tEnt:keysUnOwn( tEnt:getDoorOwner() ) end
		tEnt:keysOwn( target_ply )
		ulx.fancyLogAdmin( calling_ply, "#A set the owner of a door to #T", target_ply )
	else
		ULib.tsayError( calling_ply, "You're not looking at a door!" )
	end
end
local doorOwner = ulx.command( CATEGORY_NAME, "ulx doorowner", ulx.doorOwner, "!doorowner" )
doorOwner:addParam{ type=ULib.cmds.PlayerArg }
doorOwner:defaultAccess( ULib.ACCESS_ADMIN )
doorOwner:help( "Sets the door owner of the door you are looking at." )

// !arrest
function ulx.arrest( calling_ply, target_ply, jail_time )
	target_ply:arrest( jail_time or GM.Config.jailtimer, calling_ply )
	ulx.fancyLogAdmin( calling_ply, "#A force arrested #T for #i seconds", target_ply, jail_time or GAMEMODE.Config.jailtimer )
end
local Arrest = ulx.command( CATEGORY_NAME, "ulx arrest", ulx.arrest, "!arrest" )
Arrest:addParam{ type=ULib.cmds.PlayerArg }
Arrest:addParam{ type=ULib.cmds.NumArg, hint="arrest time", min=0, ULib.cmds.optional }
Arrest:defaultAccess( ULib.ACCESS_ADMIN )
Arrest:help( "Force arrest someone." )

// !unarrest
function ulx.unArrest( calling_ply, target_ply )
	if target_ply:isArrested() then target_ply:unArrest( calling_ply ) else
		ULib.tsayError( calling_ply, "The target needs to be arrested in the first place!" )
		return
	end
	ulx.fancyLogAdmin( calling_ply, "#A force unarrested #T", target_ply )
end
local unArrest = ulx.command( CATEGORY_NAME, "ulx unarrest", ulx.unArrest, "!unarrest" )
unArrest:addParam{ type=ULib.cmds.PlayerArg }
unArrest:defaultAccess( ULib.ACCESS_ADMIN )
unArrest:help( "Force unarrest someone." )

// !flockdown
function ulx.flockdown( calling_ply )
	for k,v in pairs(player.GetAll()) do
		v:ConCommand("play npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav\n")
	end
	DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_started"))
	RunConsoleCommand("darkrp lockdown", 1)
	ulx.fancyLogAdmin( calling_ply, "#A forced a lockdown" )
end
local flockdown = ulx.command( CATEGORY_NAME, "ulx flockdown", ulx.flockdown, "!flockdown" )
flockdown:defaultAccess( ULib.ACCESS_ADMIN )
flockdown:help( "Force a lockdown." )

// !unflockdown
function ulx.unfLockdown( calling_ply )
	DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_ended"))
	RunConsoleCommand("darkrp lockdown", 0)
	ulx.fancyLogAdmin( calling_ply, "#A force removed the lockdown" )
end
local unfLockdown = ulx.command( CATEGORY_NAME, "ulx unflockdown", ulx.unfLockdown, "!unflockdown" )
unfLockdown:defaultAccess( ULib.ACCESS_ADMIN )
unfLockdown:help( "Force remove the lockdown." )

// !tellall
function ulx.tellall( calling_ply , message)
	RunConsoleCommand("darkrp", "admintellall", message)
	ulx.fancyLogAdmin( calling_ply, "#A showed a message to all players" )
end
local tellall = ulx.command( CATEGORY_NAME, "ulx tellall", ulx.tellall, "!tellall" )
tellall:addParam{ type=ULib.cmds.StringArg, hint="message" }
tellall:defaultAccess( ULib.ACCESS_ADMIN )
tellall:help( "Show a message to every player." )

// !jobveto
function ulx.jobveto( calling_ply )
	DarkRP.destroyLastVote()
	ulx.fancyLogAdmin( calling_ply, "#A called veto on the last DarkRP vote." )
end
local jobveto = ulx.command( CATEGORY_NAME, "ulx jobveto", ulx.jobveto, "!jobveto" )
jobveto:defaultAccess( ULib.ACCESS_ADMIN )
jobveto:help( "Stop the latest RP vote." )

// !resetlaws
function ulx.resetlaws( calling_ply )
	DarkRP.resetLaws()
	ulx.fancyLogAdmin( calling_ply, "#A reseted the laws." )
end
local resetlaws = ulx.command( CATEGORY_NAME, "ulx resetlaws", ulx.resetlaws, "!resetlaws" )
resetlaws:defaultAccess( ULib.ACCESS_ADMIN )
resetlaws:help( "Reset the current laws." )

// !setjailpos
function ulx.setjailpos( calling_ply )
	RunConsoleCommand("darkrp", "jailpos")
	ulx.fancyLogAdmin( calling_ply, "#A reseted all jail positions and set a new one on his position." )
end
local setjailpos = ulx.command( CATEGORY_NAME, "ulx setjailpos", ulx.setjailpos, "!setjailpos" )
setjailpos:defaultAccess( ULib.ACCESS_SUPERADMIN )
setjailpos:help( "Reset all jail positions and set a new one at your location." )

// !addjailpos
function ulx.addjailpos( calling_ply )
	RunConsoleCommand("darkrp", "addjailpos")
	ulx.fancyLogAdmin( calling_ply, "#A added a jail position." )
end
local addjailpos = ulx.command( CATEGORY_NAME, "ulx addjailpos", ulx.addjailpos, "!addjailpos" )
addjailpos:defaultAccess( ULib.ACCESS_ADMIN )
addjailpos:help( "Add a jail position at your location." )

// !setwanted
function ulx.setwanted( calling_ply, target_ply, reason )
	target_ply:wanted(calling_ply, reason)
	ulx.fancyLogAdmin( calling_ply, "#A made #T wanted (Reason: #s).", target_ply, reason )
end
local setwanted = ulx.command( CATEGORY_NAME, "ulx setwanted", ulx.setwanted, "!setwanted" )
setwanted:addParam{ type=ULib.cmds.PlayerArg }
setwanted:addParam{ type=ULib.cmds.StringArg, hint="reason" }
setwanted:defaultAccess( ULib.ACCESS_ADMIN )
setwanted:help( "Make a player wanted by police." )