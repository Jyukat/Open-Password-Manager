; ===============================================================================================================================
;
; AutoIt v3 - Password manager by Jyukat
; Modified in 21/11/2025
;
; ===============================================================================================================================

#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: _insrec
; Description ...: Insert an account on the database using _addrec
; Syntax ........: _insrec()
; Parameters ....: None
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _insRec()

	$insrec = GUICreate("Add Account", 514, 330, -1, -1, Null, Null, $MainUI)
	GUISetFont(10, 400, 0, "Segoe UI")

	$Group1 = GUICtrlCreateGroup("New account", 16, 8, 481, 305)
	$Label10 = GUICtrlCreateLabel("Account name :", 48, 48, 110, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)

	$sAccount = GUICtrlCreateInput("", 160, 48, 305, 25)
	$Label11 = GUICtrlCreateLabel("Email :", 109, 96, 50, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)

	$sEmail = GUICtrlCreateInput("", 160, 96, 305, 25)
	$Label12 = GUICtrlCreateLabel("Username :", 76, 144, 82, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)

	$sUser = GUICtrlCreateInput("(optional)", 160, 144, 305, 25)
	$Label13 = GUICtrlCreateLabel("Password :", 81, 192, 78, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)

	$sPass = GUICtrlCreateInput("", 160, 192, 305, 25, BitOR($GUI_SS_DEFAULT_INPUT, $ES_PASSWORD))
	$btn_cancel = GUICtrlCreateButton("Cancel", 336, 264, 129, 33)
	$addrecs = GUICtrlCreateButton("Add Account", 192, 264, 129, 33)
	GUICtrlCreateGroup("", -99, -99, 1, 1)

	$tip = GUICtrlCreateLabel("To create other records you must first register these required fields.", 44, 232, 440, 25)
	GUISetFont(10, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0xFF0000)

	GUISetState(@SW_SHOW, $insrec)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $btn_cancel
				ExitLoop

			Case $addrecs
				_addrec(GUICtrlRead($sAccount), GUICtrlRead($sUser), GUICtrlRead($sEmail), GUICtrlRead($sPass))
				_updategui()
				ExitLoop
		EndSwitch
	WEnd

GUIDelete($insrec)
GUISwitch($MainUI)

EndFunc   ;==>_insrec

; #FUNCTION# ====================================================================================================================
; Name ..........: _addrec
; Description ...: Add an account in the database
; Syntax ........: _addrec($account, $user, $email, $pass)
; Parameters ....: $account             - string value of account name.
;                  $uRec                - an string value.
;                  $email               - an string value.
;                  $pRec                - a string value.
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _addrec($account, $user, $email, $pass) ;Aggiungi i record e se necessario oscurarli

	If $account = "" Then
		MsgBox(16, "Error", "Nothing to add...", 1)
		Return
	EndIf

	Local $uEncrypted = StringEncrypt(True, $user, $g_hKey)
	Local $pEncrypted = StringEncrypt(True, $pass, $g_hKey)

	IniWrite($settingfile, $account, "Username", $uEncrypted)
	IniWrite($settingfile, $account, "Email", $email)
	IniWrite($settingfile, $account, "Password", $pEncrypted)

	MsgBox(64, "Success", "Record saved successfully!")

EndFunc   ;==>_addrec

; #FUNCTION# ====================================================================================================================
; Name ..........: _addField
; Description ...: Add new field in the exists accounts
; Syntax ........: _addField()
; Parameters ....:
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _addField() ;Aggiungi nuovi records

	$addrecGUI = GUICreate("Add Records", 515, 294, -1, -1, $WS_EX_TOPMOST)
	$recLabel1 = GUICtrlCreateLabel("Record #1", 16, 16, 72, 25)
;~ 	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)

	$recName	 =	 GUICtrlCreateInput("Insert the record name", 16, 48, 481, 21)
	$recValue	 =	 GUICtrlCreateInput("Insert the record", 16, 80, 481, 21)
	$recLabel2	 =	 GUICtrlCreateLabel("Record #2", 16, 120, 72, 25)
;~ 	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)

	$recName1	 =	 GUICtrlCreateInput("Insert the record name", 16, 152, 481, 21)
	$recValue1	 =	 GUICtrlCreateInput("Insert the record", 16, 184, 481, 21)
	$Checkbox1	 =	 GUICtrlCreateCheckbox("Crypt Record", 408, 16, 89, 25)
	$Checkbox2	 =	 GUICtrlCreateCheckbox("Crypt Record", 408, 120, 89, 25)
	$okButton	 =	 GUICtrlCreateButton("Save Records", 197, 224, 121, 33)
	$cancelButton1 = GUICtrlCreateButton("Cancel", 376, 224, 121, 33)
	GUISetState(@SW_SHOW, $addrecGUI)


	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $cancelButton1
				ExitLoop

			Case $okButton
				_writeField()
				ExitLoop
		EndSwitch
	WEnd

GUIDelete($addrecGUI)
GUISwitch($ReadRecGUI)

EndFunc   ;==>_addField

; #FUNCTION# ====================================================================================================================
; Name ..........: _readrec
; Description ...: Read the field of a account
; Syntax ........: _readrec()
; Parameters ....:
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _readrec() ;Leggi records

	$hide = 1

	Local $top1 = $top
	Local $guiHeight = $Height
	Local $iPosition, $dNum
	Local $guiHeightxrow = 55

	$vListItem = GUICtrlRead($List1)

	If $vListItem = "" Then Return

	;Read the keys and its values
	Local $aReadSect = IniReadSection($settingfile, $vListItem)

	$aLabel = $aReadSect[0][0]
	$aInput = $aReadSect[0][0]

	;calcolo altezza gui complessiva
	Local $iNum = UBound($aReadSect)
	Local $dNum = $iNum -1

	;Bug fix UI
	If $dNum > 3 Then
		$guiHeightxrow *= $dNum
		$guiHeight = $guiHeightxrow + 40
	EndIf

	Local $aLabel[$iNum]
	Local $aInput[$iNum]

	If $sh = 1 Then
		For $i = 1 To $dNum
			$iPosition = StringInStr($aReadSect[$i][1], "0x")
			If $iPosition = 1 Then
				$aReadSect[$i][1] = StringEncrypt(False, $aReadSect[$i][1], $g_hKey)
			EndIf
		Next
		$sh = 0
		$hide = 0
	EndIf

	If $sh = "" Then $ReadRecGUI = GUICreate($vListItem, 585, $guiHeight, -1, -1, -1, BitOR($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE), $MainUI)

	;Ridimensionamento GUI in base alla quantità di record esistenti
	For $i = 1 To $dNum
		$aLabel[$i] = GUICtrlCreateLabel(($aReadSect[$i][0]), $left, $top1, 489, 24)
;~ 		GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
		GUICtrlSetColor(-1, 0x0066CC)
		$top1 += 24
		$aInput[$i] = GUICtrlCreateInput(($aReadSect[$i][1]), $left, $top1, 489, 21)
		$top1 += 24
	Next

	Local $copyToClip = GUICtrlCreateButton("Copia", 520, 24, 49, 49, $BS_ICON)
	GUICtrlSetTip($copyToClip, "Copy the password on clipboard")

	Local $show = GUICtrlCreateButton("Mostra", 520, 87, 49, 49, $BS_ICON)
	GUICtrlSetTip($show, "Show the Crypt records")

	$remButton = GUICtrlCreateButton("Remove account", 336, $guiHeight - 52, 113, 41)
	$cancelButton = GUICtrlCreateButton("Close", 456, $guiHeight - 52, 113, 41)
	$addNewField = GUICtrlCreateButton("Add Records", 216, $guiHeight - 52, 113, 41)

	GUISetState(@SW_SHOW, $ReadRecGUI)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $cancelButton
				ExitLoop

			Case $copyToClip
				_clippa($aReadSect[3][1])
				TrayTip($name, "Password copied!", 1)

			Case $addNewField
				_addField()
				GUISetState(@SW_HIDE, $ReadRecGUI)
				_readrec() ;Aggiorno la GUI per visualizzare le nuove voci
				ExitLoop

			Case $show
				If $hide = 1 Then $sh = 1
				GUISetState(@SW_HIDE, $ReadRecGUI)
				_readrec() ;Update GUI
				ExitLoop

			Case $remButton
				_remove($vListItem)
				ExitLoop
		EndSwitch
	WEnd

GUIDelete($ReadRecGUI)
GUISwitch($MainUI)

EndFunc   ;==>_readrec

; #FUNCTION# ====================================================================================================================
; Name ..........: _remove
; Description ...: Remove a exist account form the database
; Syntax ........: _remove($vRem)
; Parameters ....: $vRem                - a variant value.
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _remove($vRem) ;Rimuovi accounts

	If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
	$iMsgBoxAnswer = MsgBox(262452,"","Are you sure? : ")
	Select
		Case $iMsgBoxAnswer = 6 ;Yes
			IniDelete($settingfile, $vRem)
			_updategui()
			TrayTip($name, $vRem & " Account Removed!", 1)
			Return
		Case $iMsgBoxAnswer = 7 ;No
			Return
	EndSelect

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _writeField
; Description ...: Write fields of the account
; Syntax ........: _writeField()
; Parameters ....:
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _writeField() ;Scrivi records

	Local $vEn1, $vEn2

	$aRead[$NARRAY] = UBound($aRead)                ;Numero dimensioni array
	$aRead[$FIELD1] = GUICtrlRead($recName)         ;Legge il Nome del Record 1
	$aRead[$FIELD2] = GUICtrlRead($recName1)        ;Legge il Nome del Record 2
	$aRead[$VALUE1] = GUICtrlRead($recValue)        ;Legge il Valore del Record 1
	$aRead[$VALUE2] = GUICtrlRead($recValue1)       ;Legge il Valore del Record 2

	;Controllo se il primo campo sia stato inserito, se così non fosse termino la funzione
	If $aRead[$FIELD1] = "" Or $aRead[$FIELD1] = "Insert the record name" Then Return

	;Controllo se è presente un valore da inserire diverso dal testo di Default
	If $aRead[$VALUE1] = "" Or $aRead[$VALUE1] = "Insert the record" Then
		MsgBox(48, "", "A valid value has not been entered for the record")
		Return
	EndIf

	;Controllo se devo criptare il primo valore altrimenti lo scrivo in chiaro
	If _IsChecked($Checkbox1) Then
		$vEn1 = StringEncrypt(True, $aRead[$VALUE1], $g_hKey)
		IniWrite($settingfile, $vListItem, $aRead[$FIELD1], $vEn1)

	Else
		IniWrite($settingfile, $vListItem, $aRead[$FIELD1], $aRead[$VALUE1])
	EndIf

	;Controllo se il secondo campo sia stato inserito, se così non fosse termino la funzione
	If $aRead[$FIELD2] = "" Or $aRead[$FIELD2] = "Insert the record name" Then
		MsgBox(64, "Nice", "Data added successfully!", "", $MB_TOPMOST)
		Return
	EndIf

	;Controllo se è presente un valore da inserire diverso dal testo di Default
	If $aRead[$VALUE2] = "" Or $aRead[$VALUE2] = "Insert the record" Then
		MsgBox(48, "", "A valid value has not been entered for the record #2", "", $MB_TOPMOST)
		Return
	EndIf

	;Controllo se devo criptare il secondo valore altrimenti lo scrivo in chiaro
	If _IsChecked($Checkbox2) Then
		$vEn2 = StringEncrypt(True, $aRead[$VALUE2], $g_hKey)
		IniWrite($settingfile, $vListItem, $aRead[$FIELD2], $vEn2)

	Else
		IniWrite($settingfile, $vListItem, $aRead[$FIELD2], $aRead[$VALUE2])
	EndIf

	MsgBox(64, "Nice", "Data added successfully!", "", $MB_TOPMOST)

EndFunc   ;==>_writeField
