; ===============================================================================================================================
;
; AutoIt v3 - Password manager by Jyukat
; Modified in 21/11/2025
;
; ===============================================================================================================================

#include-once
#include "cryptUtils.au3"

; #FUNCTION# ====================================================================================================================
; Name ..........: _checkreg
; Description ...: Check the config file
; Syntax ........: _checkreg($iUser, $iPass)
; Parameters ....: $iUser               - an string value.
;                  $iPass               - an string value.
; Return values .: Boolean
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _checkreg($iUser, $iPass)

	Local $vReturn

	If $iUser == "" Or $iPass == "" Then
		SetError(1)
		Return $vReturn
	EndIf

	;Leggo settings.ini Sezione User
	Local $userINI	 	=	 IniRead($settingfile, "User", "username", "Default Value")
	Local $mkRead		=	 IniRead($settingfile, "User", "key", "Default Value")
	Local $uEncrypted	=	 StringEncrypt(True, $iUser, $iPass)
	Local $mkEncrypted	=	 _checkhash($iPass)

	;checking data
	If $userINI <> $uEncrypted Or $mkEncrypted = False Then
		$vReturn = False
		SetError(2)
	Else
		$vReturn = True
	EndIf

	Return $vReturn

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _reg
; Description ...: Perform a registration routine for the user
; Syntax ........: _reg()
; Parameters ....: None
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _reg()

$regGUI = GUICreate("Registration", 298, 277, -1, -1)
GUISetFont(8, 400, 0, "Segoe UI")

$in_user = GUICtrlCreateInput("Insert your username", 16, 24, 265, 25)
GUICtrlSetFont(-1, 10, 400, 2, "Segoe UI")

$in_masterpass = GUICtrlCreateInput("Insert master password", 16, 64, 265, 25)
GUICtrlSetFont(-1, 10, 400, 2, "Segoe UI")

$Label_warning = GUICtrlCreateLabel("If you don't remember this password, you cannot access to your account!", 18, 108, 266, 50, $SS_CENTER)
GUICtrlSetFont(-1, 10, 400, 6, "Segoe UI")
GUICtrlSetColor(-1, 0x0066CC)

$btn_register = GUICtrlCreateButton("Register", 16, 174, 265, 25)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

$btn_back = GUICtrlCreateButton("Back", 16, 210, 265, 25)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

$importa = GUICtrlCreateButton("Import", 208, 248, 73, 17)
GUICtrlSetColor(-1, 0x0066CC)

GUISetState(@SW_SHOW,$regGUI)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $btn_back
			GUISwitch($login)
			ExitLoop
		Case $btn_register
			_writereg(GUICtrlRead($in_user), GUICtrlRead($in_masterpass))
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

GUIDelete($regGUI)

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _writereg
; Description ...: Write in the disk the configuration file
; Syntax ........: _writereg()
; Parameters ....: None
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _writereg($user, $masterpass)

	If $user == "" And $masterpass == "" Then
		SetError(1)
		Return
	EndIf

	Local $key = _Crypt_DeriveKey($masterpass, $CALG_AES_256)
	Local $hkey = _Crypt_HashData($key, $CALG_SHA_256)

	Local $userEncrypted = StringEncrypt(True, $user, $hMasterPassword)

	;Local $uEncrypted = StringEncrypt(True, $user, $key)
	;Local $mkEncrypted = _Crypt_HashData($masterkey, $CALG_SHA_512)

	;Create file setting.ini
	If Not _FileCreate($settingfile) Then
		MsgBox($MB_SYSTEMMODAL, "Error", " Error Creating/Resetting.      error:" & @error)
	EndIf

	;Write Data
	IniWrite($settingfile, "User", "username", $userEncrypted)
	IniWrite($settingfile, "User", "key", $hMasterPassword)

	MsgBox($MB_SYSTEMMODAL, "WARNING", "Do not forget this info, print it or write it or remember it in mind." & @CRLF & _
							"You will have no wat to access your passwords forgetting user and master password." & @CRLF & _
							"User: " & $user & @CRLF & _
							"Master Password: " & $masterkey)

	;Destroy data
	$user				= Null
	$masterkey			= Null
	$userEncrypted		= Null
	$hMasterPassword	= Null

EndFunc

