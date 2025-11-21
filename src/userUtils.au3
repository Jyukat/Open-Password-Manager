;~ funzione registrazione e controllo utente
; #FUNCTION# ====================================================================================================================
; Name ..........: _checkreg
; Description ...:
; Syntax ........: _checkreg($iUser, $iPass)
; Parameters ....: $iUser               - an integer value.
;                  $iPass               - an integer value.
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _checkreg($iUser, $iPass)

	Local $vReturn = ""

	If $iUser == "" And $iPass == "" Then
		SetError(1)
		Return $vReturn
	EndIf

	;Leggo settings.ini Sezione User
	Local $uRead	 	=	 IniRead($settingfile, "User", "username", "Default Value")
	Local $mkRead		=	 IniRead($settingfile, "User", "key", "Default Value")
	Local $uEncrypted	=	 StringEncrypt(True, $iUser, $iPass)
	Local $mkEncrypted	=	 _checkhashdata($iPass) ;Local $mkEncrypted	= StringEncrypt(True, $iPass, $iPass)

	;checking data
	If $uRead <> $uEncrypted Or $mkEncrypted = False Then
		$vReturn = False
		SetError(2)
	Else
		$vReturn = True
	EndIf

	Return $vReturn

EndFunc

Func _reg()

$reggui = GUICreate("Registration", 298, 277, -1, -1)
GUISetFont(8, 400, 0, "Segoe UI")

$userreg = GUICtrlCreateInput("Insert your username", 16, 24, 265, 25)
GUICtrlSetFont(-1, 10, 400, 2, "Segoe UI")

$masterpassreg = GUICtrlCreateInput("Insert master password", 16, 64, 265, 25)
GUICtrlSetFont(-1, 10, 400, 2, "Segoe UI")

$Label1 = GUICtrlCreateLabel("If you don't remember this password, you cannot access to your account!", 18, 108, 266, 50, $SS_CENTER)
GUICtrlSetFont(-1, 10, 400, 6, "Segoe UI")
GUICtrlSetColor(-1, 0x0066CC)

$Register = GUICtrlCreateButton("Register", 16, 174, 265, 25)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

$Back = GUICtrlCreateButton("Back", 16, 210, 265, 25)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

$importa = GUICtrlCreateButton("Import", 208, 248, 73, 17)
GUICtrlSetColor(-1, 0x0066CC)

GUISetState(@SW_SHOW,$reggui)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $Back
			GUISwitch($login)
			ExitLoop
		Case $Register
			_writereg()
			If @error Then
				MsgBox(16,"-.-","Insert User and Password")
			Else
				MsgBox(64,$name,"Registration Complete!")
				GUISwitch($login)
				ExitLoop
			EndIf
		Case $importa
			_Import()
			_reboot()
	EndSwitch
WEnd

GUIDelete($reggui)

EndFunc

Func _writereg()

	Local $user = GUICtrlRead($userreg)
	Local $masterkey = GUICtrlRead($masterpassreg)

	If $user == "" And $masterkey == "" Then
		SetError(1)
		Return
	EndIf

	Local $uEncrypted = StringEncrypt(True, $user, $key)
	;Local $mkEncrypted = StringEncrypt(True, $masterkey, $key)
	Local $mkEncrypted = _Crypt_HashData($masterkey, $CALG_SHA_512)

	;Creo il file setting.ini nella script directory
	If Not _FileCreate($settingfile) Then
		MsgBox($MB_SYSTEMMODAL, "Error", " Error Creating/Resetting.      error:" & @error)
	EndIf

	;Write Data
	IniWrite($settingfile, "User", "username", $uEncrypted)
	IniWrite($settingfile, "User", "key", $mkEncrypted)

	MsgBox($MB_SYSTEMMODAL, "WARNING", "Do not forget this info, print it or write it or remember it in mind." & @CRLF & _
			"You will have no wat to access your passwords forgetting user and master password." & @CRLF & @CRLF & _
			"User: " & $user & @CRLF & _
			"Master Password: " & $masterkey)

	;Destroy data
	$user		 = Null
	$masterkey	 = Null
	$uEncrypted	 = Null
	$mkEncrypted = Null

EndFunc

