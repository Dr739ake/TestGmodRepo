sloth = sloth or {};
sloth.Rundfunk = sloth.Rundfunk or {};

if (SERVER) then
  util.AddNetworkString( "sloth_rundfunk" )
end;

if CLIENT then
	AddCSLuaFile("thirdparty/medialib.lua")
end

sloth.MediaLib = include("thirdparty/medialib.lua")
