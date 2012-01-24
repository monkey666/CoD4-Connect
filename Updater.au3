#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Icons\updater.ico
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

HttpSetUserAgent("Monkey")
if $CmdLine[0]="" Then Exit
If Ping("www.github.com", 250)=0 then
	If $CmdLine[2]<>"False" Then _Debug("Failed to ping to www.github.com")
	Exit Run($CmdLine[1])
EndIf

$iInetGet=InetGet("https://github.com/downloads/monkey666/CoD4-Connect/CoD4%20Connect%20v3.exe", $CmdLine[1], 1)
If $CmdLine[2]<>"False" Then _Debug("Return from InetGet: "&$iInetGet)
Exit Run($CmdLine[1])


Func _Debug($sText)
	FileWrite(@ScriptDir&"\Debug.txt", @HOUR&":"&@MIN&":"&@SEC&"		"&@ScriptName&" | "&$sText&@CRLF)
EndFunc