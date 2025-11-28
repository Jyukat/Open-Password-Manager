; ===============================================================================================================================
;
; AutoIt v3 - Password manager by Jyukat
; Modified in 21/11/2025
;
; ===============================================================================================================================

#include-once
#include "cryptUtils.au3"

; #FUNCTION# ====================================================================================================================
; Name ..........: CheckUser
; Description ...: Check the config file
; Syntax ........: CheckUser($iUser, $iPass)
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
Func CheckUser($User, $Password)
	;Leggo Sezione User
	Local $stored_user	=	 IniRead($settingfile, "User", "username", "")
	Local $stored_hash	=	 IniRead($settingfile, "User", "hash"	 , "")
	Local $stored_salt	=	 IniRead($settingfile, "User", "salt"	 , "")

	;Check hash
	Local $result 	= 	 _checkhash($Password, $stored_hash, $stored_salt)
	Return $result
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: SignInWindow
; Description ...: Perform a registration routine for the user
; Syntax ........: SignInWindow()
; Parameters ....: None
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func SignInWindow()

$hSignInGUI = GUICreate("Registration", 298, 277, -1, -1)
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

GUISetState(@SW_SHOW,$hSignInGUI)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE, $btn_back
			ExitLoop

		Case $btn_register
			CreateUser(GUICtrlRead($in_user), GUICtrlRead($in_masterpass))
			If @error Then
				MsgBox(16,"Error","Insert User and Password")
			Else
				MsgBox(64,"Success","Registration Complete!")
				ExitLoop
			EndIf

		Case $importa
			If _Import() Then _reboot()
	EndSwitch
WEnd

GUIDelete($hSignInGUI)
GUISwitch($loginUI)

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: CreateUser
; Description ...: Write in the disk the configuration file
; Syntax ........: CreateUser($username, $masterpass)
; Parameters ....: $username, $masterpass - String values
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func CreateUser($username, $masterpass)

	If $username == "" And $masterpass == "" Then
		SetError(1)
		Return
	EndIf

	; Genera un salt casuale (16 bytes)
	Local $tSalt = DllStructCreate("byte[16]")
	_Crypt_GenRandom($tSalt, DllStructGetSize($tSalt))
	Local $salt = DllStructGetData($tSalt, 1)

	; Crea hash della master password + salt per verifica
	Local $hash_verify 		 = _Crypt_HashData($masterpass & $salt, $CALG_SHA_256)
	Local $key 				 = _Crypt_DeriveKey($masterpass & $salt, $CALG_AES_256)
	Local $encrypted_user	 = _Crypt_EncryptData($username, $key, $CALG_USERKEY)

	;Create file and write data
	IniWrite($settingfile, "User", "username", $encrypted_user)
	IniWrite($settingfile, "User", "hash"	 , $hash_verify)
	IniWrite($settingfile, "User", "salt"	 , $salt)

	MsgBox($MB_SYSTEMMODAL, "WARNING", "Do not forget this info, print it or write it somewhere." & @CRLF & _
							"You will have no way to access your passwords forgetting User and Master Password." & @CRLF & _
							"--------------------------------------------------------" & @CRLF & _
							"User: " & $username & @CRLF & _
							"Master Password: " & $masterpass)

	;Destroy data
	$tSalt 				= Null
	$username			= Null
	$masterpass			= Null
	$encrypted_user		= Null
	$hash_verify		= Null
	$salt 				= Null

	_Crypt_DestroyKey($key)

EndFunc

