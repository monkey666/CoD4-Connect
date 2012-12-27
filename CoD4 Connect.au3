#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=Icons\connect.ico
#AutoIt3Wrapper_outfile=CoD4 Connect.exe
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
#region Includes
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ComboConstants.au3>
#include<string.au3>
#include<misc.au3>
#include <ListviewConstants.au3>
#include<array.au3>
#include <GuiListView.au3>
#endregion Includes


#region Variables
Dim $sDefault = ""
Dim $iVersuche = 0
Dim $iping_show = 0
Dim $iping_sum = 0
Dim $fConnect = 0
Dim $fStats_Gui = False
Dim $hStats_Gui
Dim $fGetStatus = False
Dim $aListViewItem[70]
Dim $sPlayerName = ""
Dim $hPlayersLable
Dim $hStats_Gui_StatusLable
Dim $iConnetSleepTime
Dim $iDebugMode = False
Dim $iGameStartUpTime
Dim $iUpdateServer
#endregion Variables
$iDebugMode = IniRead("Settings.ini", "Settings", "Debug", "False")
If $iDebugMode = "False" Or $iDebugMode = 0 Then
	$iDebugMode = False
ElseIf $iDebugMode = "True" Or $iDebugMode = 1 Then
	$iDebugMode = True
Else
	$iDebugMode = False
EndIf
If FileExists("Debug.txt") Then FileDelete("Debug.txt")
#region Updater
Global Const $sProgramVersion = "3.2.2"

FileInstall("Updater.exe", @ScriptDir & "\Updater.exe", 1)
If Ping("www.github.com") <> 0 And @Compiled Then ;Auf Internet pruefen
	If $iDebugMode Then _Debug("Succesfully pinged www.github.com")
	HttpSetUserAgent("Monkey")
	$iInetRead = BinaryToString(InetRead("https://github.com/monkey666/CoD4-Connect", 1))
	If $iDebugMode Then _Debug("Return from InetGet: " & $iInetRead)
	If $iInetRead <> "" Then
		HttpSetUserAgent("")
		$aRegExp = StringRegExp($iInetRead, "\QVersion: \E(\d+?\.\d+?\.\d+?)\s+?\QDownload-Link: \E(.+?)\s", 3)
		$sOnlineVersion = $aRegExp[0]
		$sDownloadLink=$aRegExp[1]
		If $iDebugMode Then _Debug("Return from StringRegExp: " & $sOnlineVersion)
		If _VersionCompare($sProgramVersion, $sOnlineVersion) = -1 Then
			If $iDebugMode Then _Debug("The Version on Github is newer.")
			$iMsgBox = MsgBox(68, "Update", "There is a newer version of this Tool available!" & @CRLF & "Update now?")
			If $iMsgBox = 6 Then
				If $iDebugMode Then _Debug("Starting Updater.exe.")
				Exit ShellExecute(@ScriptDir & "\Updater.exe", '"' & @ScriptFullPath & '" ' & $iDebugMode & " " & $sDownloadLink, @ScriptDir);CMDLine	[1]|Scriptpath	[2]|Debugmode	[3]|DL-Link
			EndIf
		EndIf
	EndIf
EndIf
#endregion Updater



Opt("GUIOnEventMode", 1)


#region Ini Check
If Not FileExists("Settings.ini") Then
	IniWrite("Settings.ini", "Settings", "Gamepath", "")
	IniWrite("Settings.ini", "Anzahl", "Zahl", 0)
EndIf
#endregion Ini Check

#region GUI
$Form1_1 = GUICreate("CoD4 Connect v3", 350, 283)
GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")
$Label1 = GUICtrlCreateLabel("IP:Port :", 8, 80, 49, 17)
$Input1 = GUICtrlCreateInput("", 64, 80, 201, 21)
$Label3 = GUICtrlCreateLabel("Slots:", 8, 112, 30, 17)
$Input3 = GUICtrlCreateInput("", 48, 112, 41, 21)
$Button1 = GUICtrlCreateButton("Connect! / Abort", 192, 136, 113, 41, $WS_GROUP)
GUICtrlSetOnEvent(-1, "_Connect")
$Label4 = GUICtrlCreateLabel("Game Path:", 8, 184, 60, 17)
$Input4 = GUICtrlCreateInput("", 8, 208, 241, 21)
$Button2 = GUICtrlCreateButton("...", 264, 208, 25, 25, $WS_GROUP)
GUICtrlSetOnEvent(-1, "_path")
$Label5 = GUICtrlCreateLabel("Password:", 8, 144, 53, 17)
$Input5 = GUICtrlCreateInput("", 72, 144, 89, 21)
$Label2 = GUICtrlCreateLabel("Attempts:", 10, 240, 55, 17)
$Label6 = GUICtrlCreateLabel("0", 70, 240, 90, 17)
$Label7 = GUICtrlCreateLabel("Ping avg.", 184, 240, 49, 17)
$Label8 = GUICtrlCreateLabel("0", 240, 240, 30, 17)
$Label9 = GUICtrlCreateLabel("Servername:", 8, 48, 67, 17)
$Input2 = GUICtrlCreateInput("", 88, 48, 161, 21)
$Button3 = GUICtrlCreateButton("+", 272, 48, 25, 25, $WS_GROUP)
GUICtrlSetOnEvent(-1, "_add")
GUICtrlSetTip(-1, " Save Server")
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
$Combo1 = GUICtrlCreateCombo("", 8, 8, 297, 25, $CBS_DROPDOWNLIST)
GUICtrlSetOnEvent(-1, "_Combo")
GUICtrlCreateLabel("v" & $sProgramVersion, 10, 260)
$Button4 = GUICtrlCreateButton(">>", 325, 125)
GUICtrlSetOnEvent(-1, "_Stats_Gui")
$Button5=GUICtrlCreateButton("About", 280, 250, 65, 28)
GUICtrlSetOnEvent(-1, "_About")
GUISetState(@SW_SHOW)
#endregion ### END Koda GUI section ###

#region Gamepath setzen
If FileExists("Settings.ini") Then
	$sRead = IniRead("Settings.ini", "Settings", "Gamepath", "")
	GUICtrlSetData($Input4, $sRead)
	If StringInStr(@ScriptFullPath, StringTrimRight($sRead, 10)) Then
		Exit MsgBox(48, "Error!", "Copy this Tool in another directory, otherwise ther could be problems with PunkBuster.")
	EndIf
EndIf
#endregion Gamepath setzen
#region UserSleepWert auslesen
$iConnetSleepTime = IniRead("Settings.ini", "Settings", "ConnectSleepTime", "")
If $iConnetSleepTime = "" Then
	IniWrite("Settings.ini", "Settings", "ConnectSleepTime", 500)
	$iConnetSleepTime = 500
EndIf
#endregion UserSleepWert auslesen

#region UserStartTime auslesen
$iGameStartUpTime = IniRead("Settings.ini", "Settings", "GameStartupTime", 10000)
#endregion UserStartTime auslesen

#region ini -> Combo
If IniRead("Settings.ini", "Anzahl", "Zahl", "") <> 0 Then
	For $i = 1 To IniRead("Settings.ini", "Anzahl", "Zahl", "")
		GUICtrlSetData($Combo1, "Server " & $i & " (" & IniRead("Settings.ini", $i, "Name", "") & ")")
	Next
EndIf
#endregion ini -> Combo


UDPStartup()

#region Main Loop
While Sleep(50)
	#region Combo -> Inputfeldern
	If GUICtrlRead($Combo1) <> $sDefault Then
		$aZahl = _StringBetween(GUICtrlRead($Combo1), "Server ", " (")
		If IsArray($aZahl) Then
			$iZahl = $aZahl[0]
			GUICtrlSetData($Input1, IniRead("Settings.ini", $iZahl, "IP", ""))
			GUICtrlSetData($Input3, IniRead("Settings.ini", $iZahl, "Slots", ""))
			GUICtrlSetData($Input5, IniRead("Settings.ini", $iZahl, "Pass", ""))
			GUICtrlSetData($Input2, IniRead("Settings.ini", $iZahl, "Name", ""))
			$sDefault = GUICtrlRead($Combo1)
		EndIf
	EndIf
	#endregion Combo -> Inputfeldern
	#region StatsGUI folgt MainGUI
	If $fStats_Gui Then; Stats_Gui soll Main_Gui folgen
		$aMainGUI_Pos = WinGetPos($Form1_1)
		$aStatsGUI_Pos = WinGetPos($hStats_Gui)
		If IsArray($aMainGUI_Pos) And IsArray($aStatsGUI_Pos) Then
			If $aStatsGUI_Pos[0] <> $aMainGUI_Pos[0] + $aMainGUI_Pos[2] Or $aStatsGUI_Pos[1] <> $aMainGUI_Pos[1] + 20 Then WinMove($hStats_Gui, "", $aMainGUI_Pos[0] + $aMainGUI_Pos[2], $aMainGUI_Pos[1] + 20, Default, Default, 1)
		EndIf

	EndIf
	#endregion StatsGUI folgt MainGUI
	#region ListView befuellen
	If $fStats_Gui And $fGetStatus Then;Stats_Gui soll befuellt werden
		If GUICtrlRead($Input1) = "" Or GUICtrlRead($Input3) = "" Then
			MsgBox(64, "Error", "You have to enter at least a Server IP and the number of Slots.")

		Else
			$aSplit = StringSplit(GUICtrlRead($Input1), ":")
			If @error Then
				MsgBox(64, "Error", "You have to enter a valid IP address")
			Else
				GUICtrlSetData($hStats_Gui_StatusLable, "Getting data...")
				$sHeader = "����getstatus" & @CRLF & _
						"." & @CRLF & @CRLF

				$aSocket = UDPOpen($aSplit[1], $aSplit[2])

				$hTimer = TimerInit()
				UDPSend($aSocket, $sHeader)

				Do
					$sRecv = UDPRecv($aSocket, 2048)
				Until $sRecv <> "" Or TimerDiff($hTimer) > 1000
				UDPCloseSocket($aSocket)

				For $i = 0 To 69
					GUICtrlSetData($aListViewItem[$i], " | | |")
				Next
				If $sRecv = "" Then
					MsgBox(64, "Error", "Unable to receive data from Server")
				Else
					$sRecv = StringTrimRight($sRecv, 1)
					$aSplit = StringSplit($sRecv, @LF)
					GUICtrlSetData($hPlayersLable, "Player: " & $aSplit[0] - 2 & "\" & GUICtrlRead($Input3))
					For $i = 3 To $aSplit[0]
						$aPlayerSplit = StringSplit($aSplit[$i], " ")
						GUICtrlSetData($aListViewItem[$i - 3], "||" & $aPlayerSplit[2] & "|");Hier wird der Ping ins Listview eingetragen
						GUICtrlSetData($aListViewItem[$i - 3], "|" & $aPlayerSplit[1] & "||")
						$sPlayerName = ""
						For $o = 3 To $aPlayerSplit[0]
							$sPlayerName &= $aPlayerSplit[$o]
						Next
						Opt("GUIDataSeparatorChar", "�")
						GUICtrlSetData($aListViewItem[$i - 3], $sPlayerName & "���")
						Opt("GUIDataSeparatorChar", "|")
					Next
				EndIf
				GUICtrlSetData($hStats_Gui_StatusLable, "")
			EndIf

		EndIf
		$fGetStatus = Not $fGetStatus
	EndIf
	#endregion ListView befuellen





	If _IsPressed("0D") And WinActive("CoD4 Connect v3") Then Call("_Connect")
	#region Verbinden
	If $fConnect Then
		$aIpPort = StringSplit(GUICtrlRead($Input1), ":")
		$ip = $aIpPort[1]
		$port = $aIpPort[2]
		$slots = GUICtrlRead($Input3)
		$path = GUICtrlRead($Input4)

		$sHeader = "���� getstatus" & @CRLF & _
				"." & @CRLF & @CRLF
		If $fConnect = 1 Then

			$iSocket = UDPOpen($ip, $port)
			UDPSend($iSocket, $sHeader)
			$iPing_Timer = TimerInit()
			$iTimer = TimerInit()
			Do
				$sRecv = UDPRecv($iSocket, 2048)
				If TimerDiff($iTimer) > 1000 Then
					ExitLoop
				EndIf
			Until $sRecv <> ""
			$iPing = TimerDiff($iPing_Timer)
			If $iPing > 999 Then $iPing = 999
			If $sRecv <> "" Then
				$sRecv = StringTrimRight($sRecv, 1)
				$aSplit = StringSplit($sRecv, @LF)
				$iplayers = $aSplit[0] - 2
				If $iplayers < $slots Then
					If GUICtrlRead($Input5) <> "" Then
						$Pass = GUICtrlRead($Input5)
						Sleep($iConnetSleepTime)
						ShellExecute($path, "+ connect " & $ip & ":" & $port & " + password " & $Pass, StringTrimRight($path, 9))
						$hGameStartUpTimer = TimerInit()
						Do
							If WinExists("Im abgesicherten Modus starten?", "Modern Warfare") Then ControlClick("Im abgesicherten Modus starten?", "Modern Warfare", "[CLASS:Button; INSTANCE:2]")
							If WinExists("Optimale Einstellungen vornehmen?", "Modern Warfare") Then ControlClick("Optimale Einstellungen vornehmen?", "Modern Warfare", "[CLASS:Button; INSTANCE:2]")
						Until TimerDiff($hGameStartUpTimer) > $iGameStartUpTime
						_Exit()
					Else
						Sleep($iConnetSleepTime)
						ShellExecute($path, "+ connect " & $ip & ":" & $port, StringTrimRight($path, 9))
						$hGameStartUpTimer = TimerInit()
						Do
							If WinExists("Im abgesicherten Modus starten?", "Modern Warfare") Then ControlClick("Im abgesicherten Modus starten?", "Modern Warfare", "[CLASS:Button; INSTANCE:2]")
							If WinExists("Optimale Einstellungen vornehmen?", "Modern Warfare") Then ControlClick("Optimale Einstellungen vornehmen?", "Modern Warfare", "[CLASS:Button; INSTANCE:2]")
						Until TimerDiff($hGameStartUpTimer) > $iGameStartUpTime
						_Exit()
					EndIf
				EndIf
			EndIf
			UDPCloseSocket($iSocket)

			$iping_sum += $iPing
			$iVersuche += 1
			$iping_show = Round($iping_sum / $iVersuche, 2)
			GUICtrlSetData($Label8, $iping_show)
			GUICtrlSetData($Label6, $iVersuche)
			Sleep($iConnetSleepTime);hier den userwert eintragen
		EndIf
	EndIf
	#endregion Verbinden
WEnd
#endregion Main Loop



#region Funktionen
Func _add()
	If GUICtrlRead($Input1) = "" Or GUICtrlRead($Input3) = "" Or GUICtrlRead($Input2) = "" Then
		MsgBox(64, "Error", "Please enter all fields")
	Else
		IniWrite("Settings.ini", IniRead("Settings.ini", "Anzahl", "Zahl", "") + 1, "IP", GUICtrlRead($Input1))
		IniWrite("Settings.ini", IniRead("Settings.ini", "Anzahl", "Zahl", "") + 1, "Slots", GUICtrlRead($Input3))
		IniWrite("Settings.ini", IniRead("Settings.ini", "Anzahl", "Zahl", "") + 1, "Name", GUICtrlRead($Input2))
		IniWrite("Settings.ini", IniRead("Settings.ini", "Anzahl", "Zahl", "") + 1, "Pass", GUICtrlRead($Input5))
		IniWrite("Settings.ini", "Anzahl", "Zahl", IniRead("Settings.ini", "Anzahl", "Zahl", "") + 1)
		$iMSG = MsgBox(68, "Restart?", "The Tool has to be restartet to show the added Server in the List." & @CRLF & _
				"Restart now?")
		If $iMSG = 6 Then Exit Run(@ScriptFullPath)
	EndIf
EndFunc   ;==>_add

Func _Connect()
	If GUICtrlRead($Input1) = "" Or GUICtrlRead($Input3) = "" Or GUICtrlRead($Input4) = "" Then
		MsgBox(64, "Error", "Please enter all fields")
	Else
		If $fConnect = 0 Then
			$fConnect = 1
			GUICtrlSetState($Combo1, $GUI_DISABLE)
			GUICtrlSetState($Input1, $GUI_DISABLE)
			GUICtrlSetState($Input3, $GUI_DISABLE)
			GUICtrlSetState($Input4, $GUI_DISABLE)
			GUICtrlSetState($Input5, $GUI_DISABLE)
			GUICtrlSetState($Input2, $GUI_DISABLE)
			GUICtrlSetState($Button2, $GUI_DISABLE)
		ElseIf $fConnect = 1 Then
			$fConnect = 0
			GUICtrlSetState($Combo1, $GUI_ENABLE)
			GUICtrlSetState($Input1, $GUI_ENABLE)
			GUICtrlSetState($Input3, $GUI_ENABLE)
			GUICtrlSetState($Input4, $GUI_ENABLE)
			GUICtrlSetState($Input5, $GUI_ENABLE)
			GUICtrlSetState($Input2, $GUI_ENABLE)
			GUICtrlSetState($Button2, $GUI_ENABLE)
		EndIf
	EndIf
EndFunc   ;==>_Connect

Func _path()
	$path = FileOpenDialog("Choos iw3mp.exe", @ScriptDir & "\", "Applications (*.exe)", "", "iw3mp.exe")
	IniWrite(@ScriptDir & "\Settings.ini", "Settings", "Gamepath", $path)
	GUICtrlSetData($Input4, $path)
EndFunc   ;==>_path

Func _Stats_Gui()
	Local $i
	If Not $fStats_Gui Then ;Stats GUI erstellen
		$aPos = WinGetPos(@GUI_WinHandle)
		$hStats_Gui = GUICreate("", 250, 283, $aPos[0] + $aPos[2], $aPos[1] + 20, $WS_PopUp, Default, $Form1_1)
		$hListView = GUICtrlCreateListView("Player|Score|Ping|", 3, 5, 245, 200, Default, $LVS_EX_GRIDLINES)
		_GUICtrlListView_SetColumnWidth(-1, 0, 100)
		For $i = 0 To 69
			$aListViewItem[$i] = GUICtrlCreateListViewItem("|||", $hListView)
		Next
		GUICtrlCreateButton("Get Stats", 50, 220)
		GUICtrlSetOnEvent(-1, "_Getstats")
		$hPlayersLable = GUICtrlCreateLabel("Players: 0/0", 115, 225)
		$hStats_Gui_StatusLable = GUICtrlCreateLabel("", 90, 250, 100, 25)
		GUISetState(@SW_SHOW, $hStats_Gui)
	ElseIf $fStats_Gui Then;Stats GUI loeschen
		GUIDelete($hStats_Gui)
	EndIf
	$fStats_Gui = Not $fStats_Gui

EndFunc   ;==>_Stats_Gui

Func _Getstats()
	$fGetStatus = Not $fGetStatus
EndFunc   ;==>_Getstats

Func _Exit()
	UDPShutdown()
	Exit
EndFunc   ;==>_Exit

Func _Combo()
	If $fConnect Then
		$fConnect = Not $fConnect
	EndIf
EndFunc   ;==>_Combo

Func _Debug($sText)
	FileWrite(@ScriptDir & "\Debug.txt", StringFormat("%.2i:%.2i:%.2i%40s | %s\n", @HOUR, @MIN, @SEC, @ScriptName, $sText))
EndFunc   ;==>_Debug

Func _About()
	Local $sAboutText="CoD4 Connect"&@CRLF& _
"Version: "&$sProgramVersion&@CRLF& _
""&@CRLF& _
"This programm was written by Monkey form Codebot.de"&@CRLF& _
"There is also a Thread that can be in the Forum"&@CRLF& _
"http://www.codebot.de/board111-release-area/board114-anderes/3209-cod-4-connect/"&@CRLF& _
""&@CRLF& _
"The Source-Code can be found at Github.com"&@CRLF& _
"https://github.com/monkey666/CoD4-Connect"
	MsgBox(64, "About", $sAboutText, Default, $Form1_1)
EndFunc


#endregion Funktionen
