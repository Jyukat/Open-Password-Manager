; ===============================================================================================================================
;
; AutoIt v3 - Password manager by Jyukat
; Modified in 21/11/2025
;
; ===============================================================================================================================

#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: Clippa
; Description ...: Copy a password and reset clipboard after 10 second
; Syntax ........: Clippa($string)
; Parameters ....: $string               - a string value.
; Return values .: None
; Author ........: Jykat
; Modified ......: None
; Remarks .......: None
; Related .......: None
; Link ..........: None
; Example .......: No
; ===============================================================================================================================
Func Clippa($string) ; Copy a password in the clipboard
	ClipPut(StringEncrypt(False, $string, $g_hKey))
	AdlibRegister(ResetClip, 10000) ; Delete Clipboard after 10 seconds.
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: ResetClip
; Description ...: Clean the clipboard
; Syntax ........: ResetClip()
; Parameters ....: None
; Return values .: None
; Author ........: Jyukat
; Modified ......: None
; Remarks .......: None
; Related .......: None
; Link ..........: None
; Example .......: No
; ===============================================================================================================================
Func ResetClip() ; Clean the clipboard
	ClipPut(Null)
	AdlibUnRegister(ResetClip)
EndFunc
