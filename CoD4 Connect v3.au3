#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icons\connect.ico
#AutoIt3Wrapper_Outfile=Bin\CoD4 Connect v3.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region Includes
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
#EndRegion Includes


#Region Variables
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
#EndRegion Variables

If IniRead("Settings.ini", "Settings", "Debug", "False") = "False" Then
	$iDebugMode = False
Else
	$iDebugMode = True
EndIf
If FileExists("Debug.txt") Then FileDelete("Debug.txt")
#Region Updater
Global Const $sProgramVersion = "3.1.3"


FileInstall("Updater.exe", @ScriptDir & "\Updater.exe", 1)
If Ping("www.monk3y666.bplaced.net") <> 0 And @Compiled Then ;Auf Internet pr�fen
	If $iDebugMode Then _Debug("Ping zu www.monk3y666.bplaced.net erfolgreich")
	HttpSetUserAgent("Monkey")
	$iInetGet = InetGet("http://monk3y666.bplaced.net/filemanager/Autoit/Fertige%20Scripte/COD4/Version.txt", @TempDir & "\Version.txt")
	If $iDebugMode Then _Debug("Return von InetGet: " & $iInetGet)
	HttpSetUserAgent("")
	$sOnlineVersion = FileRead(@TempDir & "\Version.txt")
	If $iDebugMode Then _Debug("Return von FileRead: " & $sOnlineVersion)
	If _VersionCompare($sProgramVersion, $sOnlineVersion) = -1 Then
		If $iDebugMode Then _Debug("Die Version auf dem FTP-Server ist neuer.")
		$iMsgBox = MsgBox(68, "Update", "Es ist ein Update f�r das Programm verf�gbar!" & @CRLF & "Jetzt updaten?")
		If $iMsgBox = 6 Then
			If $iDebugMode Then _Debug("Starte Updater.exe.")
			Exit ShellExecute(@ScriptDir & "\Updater.exe", '"' & @ScriptFullPath & '" ' & $iDebugMode, @ScriptDir)
		EndIf
	EndIf
EndIf
#EndRegion Updater



Opt("GUIOnEventMode", 1)


#Region Ini Check
If Not FileExists("Settings.ini") Then
	IniWrite("Settings.ini", "Settings", "Gamepath", "")
	IniWrite("Settings.ini", "Anzahl", "Zahl", 0)
EndIf
#EndRegion Ini Check

#Region GUI
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
$Label2 = GUICtrlCreateLabel("Versuche:", 10, 240, 55, 17)
$Label6 = GUICtrlCreateLabel("0", 70, 240, 90, 17)
$Label7 = GUICtrlCreateLabel("Ping avg.", 184, 240, 49, 17)
$Label8 = GUICtrlCreateLabel("0", 240, 240, 30, 17)
$Label9 = GUICtrlCreateLabel("Servername:", 8, 48, 67, 17)
$Input2 = GUICtrlCreateInput("", 88, 48, 161, 21)
$Button3 = GUICtrlCreateButton("+", 272, 48, 25, 25, $WS_GROUP)
GUICtrlSetOnEvent(-1, "_add")
GUICtrlSetTip(-1, "Server speichern")
GUICtrlSetFont(-1, 10, 400, 0, "Arial")
$Combo1 = GUICtrlCreateCombo("", 8, 8, 297, 25, $CBS_DROPDOWNLIST)
GUICtrlSetOnEvent(-1, "_Combo")
GUICtrlCreateLabel("v" & $sProgramVersion, 10, 260)
$Button4 = GUICtrlCreateButton(">>", 325, 125)
GUICtrlSetOnEvent(-1, "_Stats_Gui")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

#Region Gamepath setzen
If FileExists("Settings.ini") Then
	$sRead = IniRead("Settings.ini", "Settings", "Gamepath", "")
	GUICtrlSetData($Input4, $sRead)
	If StringInStr(@ScriptFullPath, StringTrimRight($sRead, 10)) Then
		Exit MsgBox(48, "Error!", "Kopiere das Programm in ein anderes Verzeichnis, weil es sonst zu Problemen mit dem Punkbuster kommen kann.")
	EndIf
EndIf
#EndRegion Gamepath setzen
#Region UserSleepWert auslesen
$iConnetSleepTime = IniRead("Settings.ini", "Settings", "ConnectSleepTime", "")
If $iConnetSleepTime = "" Then
	IniWrite("Settings.ini", "Settings", "ConnectSleepTime", 500)
	$iConnetSleepTime = 500
EndIf

#EndRegion UserSleepWert auslesen

#Region ini -> Combo
If IniRead("Settings.ini", "Anzahl", "Zahl", "") <> 0 Then
	For $i = 1 To IniRead("Settings.ini", "Anzahl", "Zahl", "")
		GUICtrlSetData($Combo1, "Server " & $i & " (" & IniRead("Settings.ini", $i, "Name", "") & ")")
	Next
EndIf
#EndRegion ini -> Combo




#Region Main Loop
While Sleep(50)
	#Region Combo -> Inputfeldern
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
	#EndRegion Combo -> Inputfeldern
	#Region StatsGUI folgt MainGUI
	If $fStats_Gui Then; Stats_Gui soll Main_Gui folgen
		$aMainGUI_Pos = WinGetPos($Form1_1)
		$aStatsGUI_Pos = WinGetPos($hStats_Gui)
		If IsArray($aMainGUI_Pos) And IsArray($aStatsGUI_Pos) Then
			If $aStatsGUI_Pos[0] <> $aMainGUI_Pos[0] + $aMainGUI_Pos[2] Or $aStatsGUI_Pos[1] <> $aMainGUI_Pos[1] + 20 Then WinMove($hStats_Gui, "", $aMainGUI_Pos[0] + $aMainGUI_Pos[2], $aMainGUI_Pos[1] + 20, Default, Default, 1)
		EndIf

	EndIf
	#EndRegion StatsGUI folgt MainGUI
	#Region ListView bef�llen
	If $fStats_Gui And $fGetStatus Then;Stats_Gui soll bef�llt werden
		If GUICtrlRead($Input1) = "" Or GUICtrlRead($Input3) = "" Then
			MsgBox(64, "Fehler", "Sie m�ssen mindestens eine IP und die Anzahl der Slots eintragen.")

		Else
			$aSplit = StringSplit(GUICtrlRead($Input1), ":")
			If @error Then
				MsgBox(64, "Fehler", "Sie haben keine g�ltige IP eingetragen.")
			Else
				GUICtrlSetData($hStats_Gui_StatusLable, "Getting data...")
				$sHeader = "���� getstatus" & @CRLF & _
						"." & @CRLF & @CRLF
				UDPStartup()
				$aSocket = UDPOpen($aSplit[1], $aSplit[2])

				$hTimer = TimerInit()
				UDPSend($aSocket, $sHeader)

				Do
					$sRecv = UDPRecv($aSocket, 2048)
				Until $sRecv <> "" Or TimerDiff($hTimer) > 1000
				UDPCloseSocket($aSocket)
				UDPShutdown()
				For $i = 0 To 69
					GUICtrlSetData($aListViewItem[$i], " | | |")
				Next
				If $sRecv = "" Then
					MsgBox(64, "Fehler", "Server Stats konnten nicht ausgelesen werden.")
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
	#EndRegion ListView bef�llen





	If _IsPressed("0D") And WinActive("CoD4 Connect v3") Then Call("_Connect")
	#Region Verbinden
	If $fConnect Then
		$aIpPort = StringSplit(GUICtrlRead($Input1), ":")
		$ip = $aIpPort[1]
		$port = $aIpPort[2]
		$slots = GUICtrlRead($Input3)
		$path = GUICtrlRead($Input4)

		$sHeader = "���� getstatus" & @CRLF & _
				"." & @CRLF & @CRLF
		If $fConnect = 1 Then
			UDPStartup()
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
						Exit
					Else
						Sleep($iConnetSleepTime)
						ShellExecute($path, "+ connect " & $ip & ":" & $port, StringTrimRight($path, 9))
						Exit
					EndIf
				EndIf
			EndIf
			UDPCloseSocket($iSocket)
			UDPShutdown()
			$iping_sum += $iPing
			$iVersuche += 1
			$iping_show = Round($iping_sum / $iVersuche, 2)
			GUICtrlSetData($Label8, $iping_show)
			GUICtrlSetData($Label6, $iVersuche)
			Sleep($iConnetSleepTime);hier den userwert eintragen
		EndIf
	EndIf
	#EndRegion Verbinden
WEnd
#EndRegion Main Loop



#Region Funktionen
Func _add()
	If GUICtrlRead($Input1) = "" Or GUICtrlRead($Input3) = "" Or GUICtrlRead($Input2) = "" Then
		MsgBox(64, "Fehler", "Bitte alle Felder ausf�llen")
	Else
		IniWrite("Settings.ini", IniRead("Settings.ini", "Anzahl", "Zahl", "") + 1, "IP", GUICtrlRead($Input1))
		IniWrite("Settings.ini", IniRead("Settings.ini", "Anzahl", "Zahl", "") + 1, "Slots", GUICtrlRead($Input3))
		IniWrite("Settings.ini", IniRead("Settings.ini", "Anzahl", "Zahl", "") + 1, "Name", GUICtrlRead($Input2))
		IniWrite("Settings.ini", IniRead("Settings.ini", "Anzahl", "Zahl", "") + 1, "Pass", GUICtrlRead($Input5))
		IniWrite("Settings.ini", "Anzahl", "Zahl", IniRead("Settings.ini", "Anzahl", "Zahl", "") + 1)
		$iMSG = MsgBox(68, "Neustarten?", "Das Programm muss neugestartet werden, damit der Server in der Liste angezeigt wird." & @CRLF & _
				"Jetzt neustarten?")
		If $iMSG = 6 Then Exit Run(@ScriptFullPath)
	EndIf
EndFunc   ;==>_add

Func _Connect()
	If GUICtrlRead($Input1) = "" Or GUICtrlRead($Input3) = "" Or GUICtrlRead($Input4) = "" Then
		MsgBox(64, "Fehler", "Bitte alle Felder ausf�llen")
	Else
		If $fConnect = 0 Then
			$fConnect = 1
		ElseIf $fConnect = 1 Then
			$fConnect = 0
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
	ElseIf $fStats_Gui Then;Stats GUI l�schen
		GUIDelete($hStats_Gui)
	EndIf
	$fStats_Gui = Not $fStats_Gui

EndFunc   ;==>_Stats_Gui

Func _Getstats()
	$fGetStatus = Not $fGetStatus
EndFunc   ;==>_Getstats

Func _Exit()
	Exit
EndFunc   ;==>_Exit

Func _Combo()
	If $fConnect Then
		$fConnect = Not $fConnect
	EndIf
EndFunc   ;==>_Combo

Func _Debug($sText)
	FileWrite(@ScriptDir & "\Debug.txt", @HOUR & ":" & @MIN & ":" & @SEC & "		" & @ScriptName & " | " & $sText & @CRLF)
EndFunc   ;==>_Debug

#EndRegion Funktionen