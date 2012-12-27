#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Icons\updater.ico
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
HttpSetUserAgent("Monkey")
If $CmdLine[0] = "" Then Exit

$aRegExp=StringRegExp($CmdLine[3], "http(?:s{0,}):\/\/([\w\.]+?)\/", 3)
$sHost=$aRegExp[0]
If Ping($sHost, 250) = 0 Then
	If $CmdLine[2] <> "False" Then _Debug("Failed to ping "&$sHost)
	Exit Run($CmdLine[1])
EndIf

$iInetGet = InetGet($CmdLine[3], $CmdLine[1], 1)
If $CmdLine[2] <> "False" Then _Debug("Return from InetGet: " & $iInetGet)
Exit Run($CmdLine[1])


Func _Debug($sText)
	FileWrite(@ScriptDir & "\Debug.txt", @HOUR & ":" & @MIN & ":" & @SEC & "		" & @ScriptName & " | " & $sText & @CRLF)
EndFunc   ;==>_Debug
