; ===============================================================================================================================
;
; AutoIt v3 - Password manager by Jyukat
; Modified in 21/11/2025
;
; ===============================================================================================================================

#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: _checkhashdata
; Description ...: Compare two hash string data using SHA-256 bit
; Syntax ........: _checkhashdata($skey)
; Parameters ....: $hash                - a string value.
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _checkhash($key)
	Local $vData
	Local $hash_ini = IniRead($settingfile, "User", "key", "default")
	Local $salt_ini = IniRead($settingfile, "User", "salt", "default")

	$hKey = _Crypt_DeriveKey($key, $CALG_AES_256)
	$hash = _Crypt_HashData($hKey, $CALG_SHA_256)

	If  Then
		$vData = True
	Else
		$vData = False
	EndIf

	_Crypt_DestroyKey($hKey)

	Return $vData
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: StringEncrypt
; Description ...: Decrypt/Encrypt a string value
; Syntax ........: StringEncrypt($bEncrypt, $sData, $sPassword)
; Parameters ....: $bEncrypt            - a boolean value: True Encrypt, False Decrypt,
;                  $sData               - a string value.
;                  $sPassword           - a string value.
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func StringEncrypt($bEncrypt, $sData, $hkey)
	Local $data = ""

	If $sData == "" Then Return

	If $bEncrypt Then
		$data = _Crypt_EncryptData($sData, $hkey, $CALG_USERKEY)
	Else
		$data = BinaryToString(_Crypt_DecryptData($sData, $hkey, $CALG_USERKEY))
	EndIf

	Return $data
EndFunc   ;==>StringEncrypt

; #FUNCTION# ====================================================================================================================
; Name ..........: _RandomString
; Description ...: Create a random string to create strong password
; Syntax ........: _RandomString($iLength)
; Parameters ....: $iLength             - an integer value: Default 8.
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _RandomString($iLength = Default)
	If $iLength = Default Then $iLength = 8
    Local $sResult = ""
    Local $sChars = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<>()=.;_-+$!?@°#/"
    For $i = 1 To $iLength
        $sResult &= StringMid($sChars, Random(1, StringLen($sChars), 1), 1)
    Next
    Return $sResult
EndFunc
