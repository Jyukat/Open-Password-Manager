; ===============================================================================================================================
;
; AutoIt v3 - Password manager by Jyukat
;
; ===============================================================================================================================

#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: ListView_Get_Selected_Item
; Description ...: Retrive the first item on the row selected
; Syntax ........: ListView_Get_Selected_Item()
; Parameters ....: None
; Return values .: $itemText		- a string value.
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func ListView_Get_Selected_Item()
	Local $itemText
	Local $selectedIndex = _GUICtrlListView_GetNextItem($ListView)
	If $selectedIndex <> -1 Then
		$itemText = _GUICtrlListView_GetItemText($ListView, $selectedIndex, 0)
		ConsoleWrite($itemText)
		Return $itemText
	Else
		Return $itemText = ""
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: WM_NOTIFY
; Description ...: Notify windows message
; Syntax ........: WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
; Parameters ....: $hWnd                - a handle value.
;                  $iMsg                - an integer value.
;                  $wParam              - an unknown value.
;                  $lParam              - an unknown value.
; Return values .: None
; Author ........: None - WinAPI
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
	#forceref $hWnd, $iMsg, $wParam
	Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
	Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
	Local $iCode = DllStructGetData($tNMHDR, "Code")
	If $hWndFrom = GUICtrlGetHandle($ListView) Then
		Switch $iCode
			Case $NM_DBLCLK ; Double click
                Local $iIndex = ListView_Get_Selected_Item()
                GUICtrlSendToDummy($g_hDummy, $iIndex)
		EndSwitch
	EndIf
	Return $GUI_RUNDEFMSG
EndFunc

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
	$PassGenUI = GUICreate("Password Generator", 456, 43, -1, -1, -1, BitOR($WS_EX_TOOLWINDOW,$WS_EX_WINDOWEDGE, $WS_EX_TOPMOST), $MainUI)
	GUICtrlSetBkColor(-1, 0x202020)
	$BTN_generate = GUICtrlCreateButton("Generate", 352, 8, 57, 25)
	$BTN_copy = GUICtrlCreateButton("Copy", 416, 8, 33, 25)
	$input_password = GUICtrlCreateInput("", 8, 8, 281, 25, $ES_READONLY + $ES_CENTER)
	GUICtrlSetBkColor(-1, 0xFFBB20)
	$input_n = GUICtrlCreateInput("12", 296, 8, 40, 25, $ES_NUMBER)
	$hUpdown = GUICtrlCreateUpdown($input_n)
	GUICtrlSetLimit($hUpdown, 64, 12) ; to limit the length max to 64 chars and min at 12 chars

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
Func UpdateList()
	_GUICtrlListView_DeleteAllItems($ListView)
	$account_list = GetAccountList($settingfile)
	If Not @error Then
		For $i = 2 To $account_list[0]
			$username = IniRead($settingfile, $account_list[$i],"Username", "")
			$email = IniRead($settingfile, $account_list[$i],"Email", "")
			_GUICtrlListView_AddItem($ListView, $account_list[$i], 0)
			_GUICtrlListView_AddSubItem($ListView, $i - 2, $username, 1)
			_GUICtrlListView_AddSubItem($ListView, $i - 2, $email, 2)
		Next
		_GUICtrlListView_SimpleSort($ListView, False, 0, False)
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
	$AboutUI = GUICreate("Open Password Manager", 425, 434, -1, -1, -1, -1)
	$Label1 = GUICtrlCreateLabel("Open Password Manager", 8, 8, 179, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	$Label2 = GUICtrlCreateLabel("Stable Version", 8, 32, 72, 17)
	$Tab1 = GUICtrlCreateTab(8, 64, 409, 361)
	$TabInfo = GUICtrlCreateTabItem("Info")
	$Info = GUICtrlCreateEdit("", 12, 273, 401, 145, $ES_READONLY)

	GUICtrlSetData(-1, "Windows Version : " & @OSVersion & @CRLF,1)
	GUICtrlSetData(-1, "Windows Build : " & @OSBuild & @CRLF,1)
	GUICtrlSetData(-1, "-------------------------------" & @CRLF,1)
	GUICtrlSetData(-1, "Computer Name : " & @ComputerName & @CRLF,1)
	GUICtrlSetData(-1, "CPU architecture : " & @CPUArch & @CRLF,1)
	GUICtrlSetData(-1, "AutoIt Version : " & @AutoItVersion & @CRLF,1)
	GUICtrlSetData(-1, "AutoIt x64 : " & @AutoItX64 & @CRLF,1)
	GUICtrlSetData(-1, "-------------------------------" & @CRLF,1)
	GUICtrlSetData(-1, "Executable Path : " & @AutoItExe & @CRLF,1)
	GUICtrlSetData(-1, "Process identifier (PID) : " & @AutoItPID & @CRLF,1)

	$Label3 = GUICtrlCreateLabel("Author : Giuseppe 'Jyukat' Catania", 20, 97, 166, 17)
	$Label4 = GUICtrlCreateLabel("AutoIt Version : " & @AutoItVersion, 20, 121, 160, 17)
	$Label5 = GUICtrlCreateLabel("GitHub : https://github.com/Jyukat/Open-Password-Manager", 20, 145, 342, 17)
			  GUICtrlSetColor	(-1, 0x0066CC)
			  GUICtrlSetCursor	(-1, 0)
	$Label6 = GUICtrlCreateLabel("Why? : Too boored too poor to pay for a Password manager service :(", 20, 169, 342, 17)
	$Label7 = GUICtrlCreateLabel("Consider to Donate some coffee or biscuits to support this software !", 20, 193, 352, 17)
	$Input1 = GUICtrlCreateInput("bc1q47p3q7um7u0eptjx6f30rlxmjxqqmhx8hpmstg", 28, 233, 369, 21, $ES_READONLY + $ES_CENTER)
	$Group1 = GUICtrlCreateGroup("Bitcoin address", 16, 216, 393, 49)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW,$AboutUI)

	Do
		$nMsg = GUIGetMsg($AboutUI)
		Switch $nMsg
			Case $Label5
				ShellExecute ("https://github.com/Jyukat/Open-Password-Manager",1)
		EndSwitch

	Until $nMsg = $GUI_EVENT_CLOSE

	GUIDelete($aboutUI)

EndFunc