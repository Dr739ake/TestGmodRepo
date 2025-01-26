local CATEGORY_NAME = "Colin's ULX Zeug"

--enums
local ALL = 0;

function ulx.Rundfunk( calling_ply, txt )
  if !txt then
    Msg( "FEHLER! ULX versucht eine Sprachdurchsage ohne Text abzuspielen!!\n" )
    return false
  end

  net.Start( "sloth_rundfunk" )
    net.WriteString( tostring(txt) );
  net.Broadcast()
end;

local rundfunk = ulx.command( CATEGORY_NAME, "ulx rundfunk", ulx.Rundfunk, "!rundfunk" )
  rundfunk:addParam{ type=ULib.cmds.StringArg, hint="Text" }
  rundfunk:defaultAccess( ULib.ACCESS_ADMIN )
  rundfunk:help( "Sendet eine Sprachdurchsage an alle Spieler." )

if CLIENT then

  net.Receive( "sloth_rundfunk", function( len, ply )
  	 local s = net.ReadString()

     if (!s) then s = "Es wurde kein Text angegeben!" end;

     if IsValid(sloth.CurrentDurchsage) then
       sloth.CurrentDurchsage:stop()
       --timer.Remove( "SLOTH_DURCHSAGETIMER" )
     end

     local betterstring = string.Replace(s, "ä", "ae")
     betterstring = string.Replace(betterstring, "ö", "oe")
     betterstring = string.Replace(betterstring, "ü", "ue")
     betterstring = string.Replace(betterstring, "ß", "ss")

     local link = "http://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q="..betterstring.."&tl=de"

     local ss = sloth.MediaLib.load("media").service("webaudio")

     sloth.CurrentDurchsage = ss:load(link)
     sloth.CurrentDurchsage:play()
     chat.AddText(  Color( 255, 255, 51 ), "**RUNDFUNK**: "..s)
  end )
end;
