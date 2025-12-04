#include <MsgBoxConstants.au3>

; La stringa da verificare (il tuo input utente)
Local $sInput1 = "nome=valore"    ; Contiene '=' -> DEVE trovare
Local $sInput2 = "array[indice]"  ; Contiene '[' e ']' -> DEVE trovare
Local $sInput3 = "SoloTesto"      ; Non contiene nulla -> NON DEVE trovare
Local $sInput4 = "[Errore]"       ; Contiene '[' e ']' -> DEVE trovare

; L'espressione regolare per la classe di caratteri: = o [ o ]
Local $sPattern = "[=\[\]]"

; --- Verifica Esempio 1 ---
CheckInput($sInput1, $sPattern)
; --- Verifica Esempio 2 ---
CheckInput($sInput2, $sPattern)
; --- Verifica Esempio 3 ---
CheckInput($sInput3, $sPattern)
; --- Verifica Esempio 4 ---
CheckInput($sInput4, $sPattern)


Func CheckInput($sString, $sRegExp)
    ; StringRegExp ritorna 1 se trova la corrispondenza, 0 altrimenti.
    Local $iResult = StringRegExp($sString, $sRegExp, 0)

    If $iResult = 1 Then
        MsgBox($MB_ICONERROR, "Verifica Input", "L'input '" & $sString & "' contiene un carattere non valido (=, [ o ]).")
    Else
        MsgBox($MB_ICONINFORMATION, "Verifica Input", "L'input '" & $sString & "' è valido.")
    EndIf
EndFunc