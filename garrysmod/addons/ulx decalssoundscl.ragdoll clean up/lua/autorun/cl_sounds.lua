local function ulx_sounds()
	RunConsoleCommand("stopsound")
end
usermessage.Hook("ulx.sounds",ulx_sounds)
