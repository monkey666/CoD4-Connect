#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Icons\updater.ico
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

HttpSetUserAgent("Monkey")
If $CmdLine[0] = "" Then Exit

Switch $CmdLine[3]
	Case 0;Github
		If Ping("www.github.com", 250) = 0 Then
			If $CmdLine[2] <> "False" Then _Debug("Failed to ping to www.github.com")
			Exit Run($CmdLine[1])
		EndIf

		$iInetGet = InetGet("https://github.com/downloads/monkey666/CoD4-Connect/CoD4%20Connect.exe", $CmdLine[1], 1)
		If $CmdLine[2] <> "False" Then _Debug("Return from InetGet: " & $iInetGet)
		Exit Run($CmdLine[1])
	Case 1;FTP Server
		If Ping("www.monk3y666.bplaced.net", 250) = 0 Then
			If $CmdLine[2] <> "False" Then _Debug("Failed to ping to www.monk3y666.bplaced.net")
			Exit Run($CmdLine[1])
		EndIf

		$iInetGet = InetGet("http://monk3y666.bplaced.net/filemanager/Autoit/Fertige%20Scripte/COD4/CoD4%20Connect.exe", $CmdLine[1], 1)
		If $CmdLine[2] <> "False" Then _Debug("Return from InetGet: " & $iInetGet)
		Exit Run($CmdLine[1])
EndSwitch


Func _Debug($sText)
	FileWrite(@ScriptDir & "\Debug.txt", @HOUR & ":" & @MIN & ":" & @SEC & "		" & @ScriptName & " | " & $sText & @CRLF)
EndFunc   ;==>_Debug
