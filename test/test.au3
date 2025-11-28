#include <Crypt.au3>

_Crypt_Startup()

; ===== REGISTRAZIONE =====
Local $masterpass = "miapassword"
Local $username = "giuseppe"

; Genera un salt casuale (16 bytes)
Local $tSalt = DllStructCreate("byte[16]")
_Crypt_GenRandom($tSalt, DllStructGetSize($tSalt))
Local $salt = DllStructGetData($tSalt, 1)

; Crea hash della master password + salt per verifica
Local $hash_verify = _Crypt_HashData($masterpass & $salt, $CALG_SHA_256)

; Deriva chiave per cifrare i dati (usando password + salt)
Local $key = _Crypt_DeriveKey($masterpass & $salt, $CALG_AES_256)
Local $encrypted_user = _Crypt_EncryptData($username, $key, $CALG_USERKEY)

; Salva nel INI
IniWrite("config.ini", "User", "salt", $salt)
IniWrite("config.ini", "User", "hash", $hash_verify)
IniWrite("config.ini", "User", "username", $encrypted_user)

_Crypt_DestroyKey($key)

; ===== LOGIN =====
Local $input_pass = InputBox("Login", "Inserisci master password")

; Recupera salt e hash salvati
Local $stored_salt = IniRead("config.ini", "User", "salt", "")
Local $stored_hash = IniRead("config.ini", "User", "hash", "")

; Calcola hash della password inserita + salt
Local $input_hash = _Crypt_HashData($input_pass & $stored_salt, $CALG_SHA_256)

If $input_hash = $stored_hash Then
    ; Password corretta - deriva la chiave e decifra
    Local $key2 = _Crypt_DeriveKey($input_pass & $stored_salt, $CALG_AES_256)
    Local $encrypted_data = IniRead("config.ini", "User", "username", "")
    Local $decrypted = _Crypt_DecryptData($encrypted_data, $key2, $CALG_USERKEY)

    MsgBox(0, "Successo", "Username: " & BinaryToString($decrypted))

    _Crypt_DestroyKey($key2)
Else
    MsgBox(16, "Errore", "Password errata!")
EndIf

MsgBox(0, "Successo", "pass generata: " & _RandomString(12))

Func _RandomString($iLength = Default)
	If $iLength = Default Then $iLength = 8
;~ 	SRandom(@SEC + $iLength)
    Local $sResult = ""
    Local $sChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<>()=.,:;_-+$!?@#/^?'!°*\|"
    For $i = 1 To $iLength
        $sResult &= StringMid($sChars, Random(1, StringLen($sChars), 1), 1)
    Next
    Return $sResult
EndFunc

_Crypt_Shutdown()