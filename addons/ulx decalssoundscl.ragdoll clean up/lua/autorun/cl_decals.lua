local function ulx_decals()
	RunConsoleCommand("r_cleardecals")
	RunConsoleCommand("r_cleardecals")
	for _,ent in pairs(ents.GetAll()) do
		if (ent:GetClass() == "class C_ClientRagdoll") then
			ent:Remove()
		end
	end
end
usermessage.Hook("ulx.decals",ulx_decals)
