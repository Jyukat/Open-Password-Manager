; ===============================================================================================================================
;
; AutoIt v3 - Password manager by Jyukat
; Modified in 21/11/2025
;
; ===============================================================================================================================

#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: _passGen
; Description ...: minimal Password Generator UI
; Syntax ........: _passGen()
; Parameters ....: None
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _passGen()
	$PassGenUI = GUICreate("Password Generator", 456, 43, -1, -1, -1, BitOR($WS_EX_TOOLWINDOW,$WS_EX_WINDOWEDGE), $MainUI)
	$BTN_generate = GUICtrlCreateButton("Generate", 352, 8, 57, 25)
	$BTN_copy = GUICtrlCreateButton("Copy", 416, 8, 33, 25)
	$input_password = GUICtrlCreateInput("", 8, 8, 281, 25, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
	$input_n = GUICtrlCreateInput("8", 296, 8, 40, 25, BitOR($GUI_SS_DEFAULT_INPUT,$ES_NUMBER))
	GUICtrlCreateUpdown($input_n)
	GUICtrlSetLimit($input_n, 8, 64) ; to limit the entry to 64 chars

	GUISetState(@SW_SHOW, $PassGenUI)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUISwitch($MainUI)
			ExitLoop
		Case $BTN_copy
			ClipPut(GUICtrlRead($input_password))
			Case $BTN_generate
				GUICtrlSetData($input_password, _RandomString(GUICtrlRead($input_n)))
			Case $input_n
				GUICtrlSetData($input_password, _RandomString(GUICtrlRead($input_n)))
		EndSwitch
	WEnd

	GUIDelete($PassGenUI)
	Return $input_password
EndFunc


; #FUNCTION# ====================================================================================================================
; Name ..........: UpdateList
; Description ...: Update the main account list
; Syntax ........: UpdateList()
; Parameters ....:
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func UpdateList() ;Aggiorna la GUI principale

	;Flush list
	GUICtrlSetData($List1, "")

	Local $aArray = IniReadSectionNames($settingfile)
	If Not @error Then
		For $i = 2 To $aArray[0]
			GUICtrlSetData($List1, $aArray[$i] & "|")
		Next
	Else
		MsgBox(16, "Error", "Deletetion or setting file was moved")
	EndIf

EndFunc   ;==>_updategui

; #FUNCTION# ====================================================================================================================
; Name ..........: _settingGUI
; Description ...: Settings UI
; Syntax ........: _settingGUI()
; Parameters ....:
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _settingGUI()

$Impostazioni = GUICreate("Settings", 554, 492, -1, -1, -1, BitOR($WS_EX_TOOLWINDOW,$WS_EX_WINDOWEDGE), $MainUI)
GUISetFont(12, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x0066CC)

$groupsett	 =	 GUICtrlCreateGroup("Export / Import Configuration file account", 16, 112, 521, 121, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
$import		 =	 GUICtrlCreateButton("Import", 32, 192, 153, 30)
GUICtrlSetColor(-1, 0x0066CC)

$export	= GUICtrlCreateButton("Export", 368, 192, 153, 30)
GUICtrlSetColor(-1, 0x0066CC)

$Input1	= GUICtrlCreateInput("(cooming soon)", 32, 152, 489, 29)
GUICtrlSetColor(-1, 0x0066CC)
GUICtrlCreateGroup("", -99, -99, 1, 1)

$avv	 =	 GUICtrlCreateGroup("Startup", 16, 16, 521, 81, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
$avvLab	 =	 GUICtrlCreateLabel("Add to Windows Startup", 24, 48, 189, 25)
GUICtrlSetColor(-1, 0x0066CC)

$on_start = GUICtrlCreateCheckbox("", 224, 48, 17, 25)
GUICtrlSetTip(-1, "Yes / No")

$attdisatt = GUICtrlCreateLabel("", 256, 48, 78, 25)

	If FileExists(@StartupDir &"\"& $name &".lnk") Then
		GUICtrlSetState($on_start, $GUI_CHECKED)
		GUICtrlSetData($attdisatt,"Activated")
		GUICtrlSetColor($attdisatt, 0x008000)
	Else
		GUICtrlSetData($attdisatt, "Disactived")
		GUICtrlSetColor(-1, 0xFF0000)
	EndIf

GUICtrlCreateGroup("", -99, -99, 1, 1)

$Group1	 =	 GUICtrlCreateGroup("Change Master Password (cooming soon)", 16, 248, 521, 201)
GUICtrlSetColor(-1, 0x0066CC)

$Label4		 =	 GUICtrlCreateLabel("Old Password", 32, 288, 128, 25)
$Input2		 =	 GUICtrlCreateInput("Input2", 160, 288, 361, 29, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
$Label5		 =	 GUICtrlCreateLabel("New Password", 32, 328, 121, 25)
$Input3		 =	 GUICtrlCreateInput("Input2", 160, 328, 361, 29, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
$Label6		 =	 GUICtrlCreateLabel("Repeat Password", 32, 368, 115, 25)
$Input4		 =	 GUICtrlCreateInput("Input2", 160, 368, 361, 29, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
$changePass	 =	 GUICtrlCreateButton("Change Master Password", 168, 408, 249, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUISetState(@SW_SHOW, $Impostazioni)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			GUISwitch($MainUI)
			ExitLoop
		Case $import
			_Import()
			_reboot()
		Case $export
			_Export()
		Case $on_start
			If AddToStartup($on_start) Then
				GUICtrlSetData($attdisatt, "Activated")
				GUICtrlSetColor($attdisatt, 0x008000)
			Else
				GUICtrlSetData($attdisatt, "Disactived")
				GUICtrlSetColor($attdisatt, 0xFF0000)
			EndIf
		Case $changePass
			MsgBox("","Cooming soon","Function not implemented")
	EndSwitch
WEnd

GUIDelete($Impostazioni)

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _IsChecked
; Description ...: Check if a control is checked or not
; Syntax ........: _IsChecked($idControlID)
; Parameters ....: $idControlID         - an integer value.
; Return values .: Boolean
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _IsChecked($idControlID) ;Controlla se le checkbox sono spuntate o meno
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

; #FUNCTION# ====================================================================================================================
; Name ..........: _about
; Description ...: About Dialog
; Syntax ........: _about()
; Parameters ....:
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _about() ;About
Local $iOldOpt = Opt("GUICoordMode", 1)

Local $aboutUI = GUICreate("About", 588, 146, 192, 124, -1, $WS_EX_TOOLWINDOW)
$Icon1 = GUICtrlCreateIcon(300, -1, 8, 8, 129, 129)
$appnamelb = GUICtrlCreateLabel("Open Password Manager", 224, 8, 256, 32)
GUICtrlSetFont(-1, 16, 400, 0, "Segoe UI")

$createdbylb = GUICtrlCreateLabel("Created by Giuseppe Catania a.k.a. hacktooth", 144, 48, 268, 19)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

$reasonlb = GUICtrlCreateLabel("Reasons: too boored too poor to pay any other password manager service", 144, 72, 424, 19)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

$sourcecodelb = GUICtrlCreateLabel("Source code available on github.com/Jyukat/Open-Password-Manager", 144, 96, 424, 19)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

$Label1 = GUICtrlCreateLabel("Version 0.9b", 504, 120, 76, 19)
GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
GUISetState(@SW_SHOW, $aboutUI)

While 1

;animations
For $y = 150 To - 110 Step -0.5
	GUICtrlSetPos($appnamelb, 224, $y)
	GUICtrlSetPos($createdbylb, 144, $y + 40)
	GUICtrlSetPos($reasonlb, 144, $y + 64)
	GUICtrlSetPos($sourcecodelb, 144, $y + 88)
	Sleep(10)
	If GUIGetMsg() == $GUI_EVENT_CLOSE Then ExitLoop 2
next
Sleep (1000)
WEnd

Opt("GUICoordMode", $iOldOpt)

GUIDelete($aboutUI)

EndFunc   ;==>_about