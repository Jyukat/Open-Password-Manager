; ===============================================================================================================================
;
; AutoIt v3 - Password manager by Jyukat
; Modified in 21/11/2025
;
; ===============================================================================================================================

#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: PasswordGeneratorUI
; Description ...: minimal Password Generator UI
; Syntax ........: PasswordGeneratorUI()
; Parameters ....: None
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func PasswordGeneratorUI()
	$PassGenUI = GUICreate("Password Generator", 456, 43, -1, -1, -1, BitOR($WS_EX_TOOLWINDOW,$WS_EX_WINDOWEDGE), $MainUI)
	$BTN_generate = GUICtrlCreateButton("Generate", 352, 8, 57, 25)
	$BTN_copy = GUICtrlCreateButton("Copy", 416, 8, 33, 25)
	$input_password = GUICtrlCreateInput("", 8, 8, 281, 25, $ES_READONLY)
	GUICtrlSetBkColor(-1, 0xFFBB20)
	$input_n = GUICtrlCreateInput("12", 296, 8, 40, 25, $ES_NUMBER)
	$hUpdown = GUICtrlCreateUpdown($input_n)
	GUICtrlSetLimit($hUpdown, 64, 12) ; to limit the entry to 64 chars

	GUICtrlSetData($input_password, _RandomString(GUICtrlRead($input_n)))

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
				If GUICtrlRead($input_n) > 15 Then
					GUICtrlSetBkColor($input_password, 0x00EB50)
				Else
					GUICtrlSetBkColor($input_password, 0xFFBB20)
				EndIf
				GUICtrlSetData($input_password, _RandomString(GUICtrlRead($input_n)))
		EndSwitch
	WEnd

	GUIDelete($PassGenUI)
	Return $input_password
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: UpdateList
; Description ...: Update the account list
; Syntax ........: UpdateList($hList)
; Parameters ....: $hList 	- a handle value
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func UpdateList($hList)
	_GUICtrlListView_DeleteAllItems($hList)
	$account_list = GetAccountList($settingfile)
	If Not @error Then
		For $i = 2 To $account_list[0]
			$username = IniRead($settingfile, $account_list[$i],"Username", "")
			$email = IniRead($settingfile, $account_list[$i],"Email", "")
			_GUICtrlListView_AddItem($hList, $account_list[$i], 0)
			_GUICtrlListView_AddSubItem($hList, $i - 2, $username, 1)
			_GUICtrlListView_AddSubItem($hList, $i - 2, $email, 2)
		Next
		_GUICtrlListView_SimpleSort($hList, False, 0, False)
	Else
		MsgBox(16, "Error", "Something bad happen.")
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: SettingUI
; Description ...: Settings UI
; Syntax ........: SettingUI()
; Parameters ....:
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func SettingUI()

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
			ExitLoop
		Case $import
			Import()
			Reboot()
		Case $export
			Export()
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
GUISwitch($MainUI)

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _IsChecked
; Description ...: Check if a control is checked or not
; Syntax ........: _IsChecked($idControlID)
; Parameters ....: $idControlID         - an handle value.
; Return values .: Boolean
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func IsChecked($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

; #FUNCTION# ====================================================================================================================
; Name ..........: About
; Description ...: About Dialog
; Syntax ........: About()
; Parameters ....:
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func About() ;About
Local $iOldOpt = Opt("GUICoordMode", 1)

Local $aboutUI = GUICreate("About", 480, 146, 192, -1, -1, $WS_EX_TOOLWINDOW)
$appnamelb = GUICtrlCreateLabel("Open Password Manager", 224, 8, 256, 32)
GUICtrlSetFont(-1, 16, 400, 0, "Segoe UI")

$createdbylb = GUICtrlCreateLabel("Created by Giuseppe Catania 'Jyukat'", 144, 48, 268, 19)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

$reasonlb = GUICtrlCreateLabel("Reason: too boored too poor to pay any password manager service", 144, 72, 424, 19)
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

EndFunc