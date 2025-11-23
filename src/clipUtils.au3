; ===============================================================================================================================
;
; AutoIt v3 - Password manager by Jyukat
; Modified in 21/11/2025
;
; ===============================================================================================================================

#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: _clippa
; Description ...: Copy a password and reset clipboard after 10 second
; Syntax ........: _clippa($field)
; Parameters ....: $field               - a field value.
; Return values .: None
; Author ........: Jykat
; Modified ......: None
; Remarks .......: None
; Related .......: None
; Link ..........: None
; Example .......: No
; ===============================================================================================================================
Func _clippa($field) ; Copy a password in the clipboard
	ClipPut(StringEncrypt(False, $field, $key))
	AdlibRegister(_resetclip, 10000)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _resetclip
; Description ...: Clean the clipboard
; Syntax ........: _resetclip()
; Parameters ....: None
; Return values .: None
; Author ........: Jyukat
; Modified ......: None
; Remarks .......: None
; Related .......: None
; Link ..........: None
; Example .......: No
; ===============================================================================================================================
Func _resetclip() ; Clean the clipboard
	ClipPut(Null)
	AdlibUnRegister(_resetclip)
EndFunc
