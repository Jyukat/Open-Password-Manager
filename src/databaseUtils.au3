; ===============================================================================================================================
;
; AutoIt v3 - Password manager by Jyukat
;
; ===============================================================================================================================

#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: NewAccountUI
; Description ...: Insert an account on the database using _addrec
; Syntax ........: NewAccountUI()
; Parameters ....: None
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func NewAccountUI()
	$hNewAccountGUI = GUICreate("New Account", 436, 258, -1, -1)
	GUISetFont(10, 400, 0, "Segoe UI")

	$Group1 = GUICtrlCreateGroup("Account Details", 8, 8, 417, 240, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
	$Label10 = GUICtrlCreateLabel("Account name :", 16, 32, 110, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)

	$sAccount = GUICtrlCreateInput("", 128, 32, 289, 25)
	$Label11 = GUICtrlCreateLabel("Email :", 77, 64, 50, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)

	$sEmail = GUICtrlCreateInput("", 128, 64, 289, 25)
	$Label12 = GUICtrlCreateLabel("Username :", 44, 96, 82, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)

	$sUser = GUICtrlCreateInput("", 128, 96, 289, 25)
	$Label13 = GUICtrlCreateLabel("Password :", 49, 128, 78, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)

	$sPass = GUICtrlCreateInput("", 128, 128, 289, 25, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
	$tip = GUICtrlCreateLabel("To create other records you must register these required fields.", 20, 208, 392, 25, $SS_CENTER)
	GUICtrlSetColor(-1, 0xFF0000)

	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$btn_cancel = GUICtrlCreateButton("Cancel", 328, 168, 89, 25)
	$btn_confirm = GUICtrlCreateButton("Confirm", 128, 168, 89, 25)

	GUISetState(@SW_SHOW, $hNewAccountGUI)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $btn_cancel
				ExitLoop

			Case $btn_confirm
				AddAccount(GUICtrlRead($sAccount), GUICtrlRead($sUser), GUICtrlRead($sEmail), GUICtrlRead($sPass))
				ExitLoop
		EndSwitch
	WEnd

GUIDelete($hNewAccountGUI)
GUISwitch($MainUI)

EndFunc   ;==>NewAccountUI

; #FUNCTION# ====================================================================================================================
; Name ..........: GetAccountList
; Description ...: Retrive account list and store in one array
; Syntax ........: GetAccountList($file)
; Parameters ....: $file                - a string value.
; Return values .: $aAccountList 		- a string array.
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func GetAccountList($file)
	Local $aAccountList = IniReadSectionNames($file)
	Return $aAccountList
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: AddAccount
; Description ...: Add an account in the database
; Syntax ........: AddAccount($account, $user, $email, $pass)
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
Func AddAccount($account, $user, $email, $pass)
	If $account = "" Then
		MsgBox(16, "Error", "Nothing to add...", 1)
		Return
	EndIf

	Local $passEncrypted = StringEncrypt(True, $pass, $g_hKey)

	IniWrite($settingfile, $account, "Username", $user)
	IniWrite($settingfile, $account, "Email", $email)
	IniWrite($settingfile, $account, "Password", $passEncrypted)
EndFunc   ;==>AddAccount

; #FUNCTION# ====================================================================================================================
; Name ..........: AddField
; Description ...: Add new field in the exists accounts
; Syntax ........: AddField()
; Parameters ....:
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func AddField($account) ;Aggiungi nuovi records
	$addrecGUI	 = GUICreate("Add Fields", 515, 294, -1, -1, $WS_EX_TOPMOST)
	$recLabel1	 = GUICtrlCreateLabel("Title #1", 16, 16, 72, 25)
	$recLabel2	 = GUICtrlCreateLabel("Title #2", 16, 120, 72, 25)
;~ 	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)

	$recName	 =	 GUICtrlCreateInput("Enter Title", 16, 48, 481, 21)
	$recValue	 =	 GUICtrlCreateInput("Enter Data", 16, 80, 481, 21)
	$recName1	 =	 GUICtrlCreateInput("Enter Title", 16, 152, 481, 21)
	$recValue1	 =	 GUICtrlCreateInput("Enter Data", 16, 184, 481, 21)
;~ 	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)

	$Checkbox1	 =	 GUICtrlCreateCheckbox("Crypt Record", 408, 16, 89, 25)
	$Checkbox2	 =	 GUICtrlCreateCheckbox("Crypt Record", 408, 120, 89, 25)
	$okButton	 =	 GUICtrlCreateButton("Save", 197, 224, 121, 33)
	$cancelButton1 = GUICtrlCreateButton("Cancel", 376, 224, 121, 33)
	GUISetState(@SW_SHOW, $addrecGUI)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $cancelButton1
				ExitLoop

			Case $okButton
				WriteField($account, _
						GuiCtrlRead($recName), _
						GuiCtrlRead($recName1), _
						GuiCtrlRead($recValue), _
						GuiCtrlRead($recValue1), _
						IsChecked($Checkbox1), _
						IsChecked($Checkbox2))
				ExitLoop
		EndSwitch
	WEnd

GUIDelete($addrecGUI)
GUISwitch($ReadRecGUI)

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: ReadFields
; Description ...: Read the field of a account
; Syntax ........: ReadFields()
; Parameters ....: $accountName - a string value
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func ReadFields($accountName)

	If $accountName = "" Then Return

	Local $hide = 1
	Local $iPosition
	Local $guiHeightxrow = 55

	;Read the keys and its values in the ini file.
	;Read the fields of an account.
	Local $aNewFieldsSect = IniReadSection($settingfile, $accountName)

;~ 	$aLabel = $aNewFieldsSect[0][0]
;~ 	$aInput = $aNewFieldsSect[0][0]

	;calcolo altezza gui complessiva
	Local $iNum = UBound($aNewFieldsSect) ; Numero di campi totali

	;Bug fix UI
	If ($iNum - 1) > 3 Then
		$guiHeightxrow *= ($iNum - 1)
		$Height = $guiHeightxrow + 40
	EndIf

	Local $aLabel[$iNum]
	Local $aInput[$iNum]

	If $sh = 1 Then
		For $i = 1 To $iNum - 1
			$iPosition = StringInStr($aNewFieldsSect[$i][1], "0x")
			If $iPosition = 1 Then
				$aNewFieldsSect[$i][1] = StringEncrypt(False, $aNewFieldsSect[$i][1], $g_hKey)
			EndIf
		Next
		$sh = 0
		$hide = 0
	EndIf

	If $sh = "" Then $ReadRecGUI = GUICreate($accountName, 585, $Height, -1, -1, -1, BitOR($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE), $MainUI)

	For $i = 1 To $iNum - 1
        ; Calcolo l'offset Y [($i - 1) * 48].
        Local $iOffsetY = ($i - 1) * 48

        ; Posizione Label: $top + offset calcolato
        $aLabel[$i] = GUICtrlCreateLabel(($aNewFieldsSect[$i][0]), $left, $top + $iOffsetY, 489, 24)
        GUICtrlSetColor(-1, 0x0066CC)

        ; Posizione Input: $top + offset calcolato + 24
        $aInput[$i] = GUICtrlCreateInput(($aNewFieldsSect[$i][1]), $left, $top + $iOffsetY + 24, 489, 21)
    Next

	Local $copyToClip = GUICtrlCreateButton("Copy", 520, 24, 49, 49, $BS_ICON)
	GUICtrlSetTip($copyToClip, "Copy the password on clipboard")

	Local $show = GUICtrlCreateButton("Show", 520, 87, 49, 49, $BS_ICON)
	GUICtrlSetTip($show, "Show the Crypt records")

	$remButton = GUICtrlCreateButton("Remove account", 336, $Height - 52, 113, 41)
	$cancelButton = GUICtrlCreateButton("Close", 456, $Height - 52, 113, 41)
	$addNewField = GUICtrlCreateButton("Add Records", 216, $Height - 52, 113, 41)

	GUISetState(@SW_SHOW, $ReadRecGUI)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $cancelButton
				ExitLoop

			Case $copyToClip
				Clippa($aNewFieldsSect[3][1])
				TrayTip($name, "Password copied!", 1)

			Case $addNewField
				GUISetState(@SW_HIDE, $ReadRecGUI)
				AddField($accountName)
				ReadFields($accountName) ;Aggiorno la GUI per visualizzare le nuove voci
				ExitLoop

			Case $show ;pulsante Mostra
				;TODO: inserire qui la logica di decriptazione dei dati sensibili
				;      evitando cosi di nascondere la finestra e riaprirla eseguendo codice non necessario.
				If $hide = 1 Then $sh = 1
				GUISetState(@SW_HIDE, $ReadRecGUI)
				ReadFields($accountName) ;Update GUI
				ExitLoop ;non esce dal loop in questa maniera

			Case $remButton
				RemoveAccount($accountName)
				ExitLoop
		EndSwitch
	WEnd

GUIDelete($ReadRecGUI)
GUISwitch($MainUI)

EndFunc   ;==>ReadFields

; #FUNCTION# ====================================================================================================================
; Name ..........: RemoveAccount
; Description ...: Remove a exist account form the database
; Syntax ........: RemoveAccount($vRem)
; Parameters ....: $vRem                - a string value.
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func RemoveAccount($account) ;Rimuovi accounts
	If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
	$iMsgBoxAnswer = MsgBox(262452,"","Are you sure?")
	Select
		Case $iMsgBoxAnswer = 6 ;Yes
			IniDelete($settingfile, $account)
			TrayTip($name, $account & " Account Removed!", 1)
			Return
		Case $iMsgBoxAnswer = 7 ;No
			Return
	EndSelect
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: WriteField
; Description ...: Write a new field on an account
; Syntax ........: WriteField($firstTitle, $secondTitle, $firstValue, $secondValue)
; Parameters ....: $firstTitle          - a string point value.
;                  $secondTitle         - a string value.
;                  $firstValue          - a string point value.
;                  $secondValue         - a string value.
;                  $bCrypt1		        - a boolean value.
;                  $bCrypt2		        - a boolean value.
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func WriteField($account, $firstTitle, $secondTitle, $firstValue, $secondValue, $bCrypt1, $bCrypt2)
	; Definizione delle stringhe di default per evitare errori di battitura
	Local $sDefName = "Enter Title"
	Local $sDefVal  = "Enter Data"

	; array size, first field, second field, first value, second value
	Local Enum $NARRAY, $FIELD1, $FIELD2, $VALUE1, $VALUE2
	Local $aNewFields[5]

	$aNewFields[$NARRAY] = UBound($aNewFields)	 ;Numero dimensioni array
	$aNewFields[$FIELD1] = $firstTitle			 ;Legge il Nome del Record 1
	$aNewFields[$FIELD2] = $secondTitle			 ;Legge il Nome del Record 2
	$aNewFields[$VALUE1] = $firstValue			 ;Legge il Valore del Record 1
	$aNewFields[$VALUE2] = $secondValue			 ;Legge il Valore del Record 2

	;Controllo se il primo campo sia stato inserito, se così non fosse termino la funzione
	If $aNewFields[$FIELD1] = "" Or $aNewFields[$FIELD1] = $sDefName Then
		MsgBox(48, "", "Enter a valid value !", 1)
	EndIf

	;Controllo se è presente un valore da inserire diverso dal testo di Default
	If $aNewFields[$VALUE1] = "" Or $aNewFields[$VALUE1] = $sDefVal Then
		MsgBox(48, "", "Enter a valid value !", 1)
	EndIf

	;Controllo se devo criptare il primo valore altrimenti lo scrivo in chiaro
	If $bCrypt1 Then
		Local $vEn1 = StringEncrypt(True, $aNewFields[$VALUE1], $g_hKey)
		IniWrite($settingfile, $account, $aNewFields[$FIELD1], $vEn1)
	Else
		IniWrite($settingfile, $account, $aNewFields[$FIELD1], $aNewFields[$VALUE1])
	EndIf

	;Controllo se il secondo campo sia stato inserito, se così non fosse termino la funzione
	If $aNewFields[$FIELD2] = "" Or $aNewFields[$FIELD2] = $sDefName Then
		MsgBox(64, "Nice", "Data added successfully!", "", $MB_TOPMOST)
		Return
	EndIf

	;Controllo se è presente un valore da inserire diverso dal testo di Default
	If $aNewFields[$VALUE2] = "" Or $aNewFields[$VALUE2] = $sDefVal Then
		MsgBox(48, "", "A valid value has not been entered for the record #2", "", $MB_TOPMOST)
		Return
	EndIf

	;Controllo se devo criptare il secondo valore altrimenti lo scrivo in chiaro
	If $bCrypt2 Then
		Local $vEn2 = StringEncrypt(True, $aNewFields[$VALUE2], $g_hKey)
		IniWrite($settingfile, $account, $aNewFields[$FIELD2], $vEn2)
	Else
		IniWrite($settingfile, $account, $aNewFields[$FIELD2], $aNewFields[$VALUE2])
	EndIf
EndFunc