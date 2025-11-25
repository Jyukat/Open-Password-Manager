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
; Parameters ....: $pass, $hash_ini, $salt_ini   - a string values.
; Return values .: $result                       - a boolean value.
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _checkhash($pass, $hash_ini, $salt_ini)
	Local $result

	$hash = _Crypt_HashData($pass & $salt_ini, $CALG_SHA_256)

	If $hash = $hash_ini Then
		$result = True
	Else
		$result = False
	EndIf

	Return $result
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: StringEncrypt
; Description ...: Decrypt/Encrypt a string value
; Syntax ........: StringEncrypt($bEncrypt, $sData, $sPassword)
; Parameters ....: $bEncrypt            - a boolean value: True Encrypt, False Decrypt,
;                  $sData               - a string value.
;                  $sPassword           - a string value.
; Return values .: $data 				- a string value.
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
    Local $sChars = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<>()=.;_-+$!?@#/"
    For $i = 1 To $iLength
        $sResult &= StringMid($sChars, Random(1, StringLen($sChars), 1), 1)
    Next
    Return $sResult
EndFunc
