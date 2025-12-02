#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GUIScrollBars.au3>
#include <ScrollBarConstants.au3>
#include <StructureConstants.au3>

; Simuliamo dei dati (array di 50 elementi per forzare lo scroll)
Local $iNum = 50
Global $aLabel[$iNum + 1], $aInput[$iNum + 1]
Global $aReadSect[$iNum + 1][2]
For $x = 1 To $iNum
    $aReadSect[$x][0] = "Etichetta Record " & $x
    $aReadSect[$x][1] = "Valore " & $x
Next

; Variabili di posizionamento
Local $top = 10
Local $left = 10
Local $iBlockHeight = 48 ; Altezza totale di (Label + Input + Spazi)

; 1. Creiamo la GUI principale con stile ridimensionabile
Global $hGUI = GUICreate("Form Dinamico con Scroll", 550, 400, -1, -1, BitOR($WS_MINIMIZEBOX, $WS_CAPTION, $WS_POPUP, $WS_SYSMENU, $WS_SIZEBOX))

; 2. Generiamo i controlli (il tuo codice ottimizzato)
For $i = 1 To $iNum
    ; Calcolo matematico della posizione Y
    Local $iCurrentY = $top + (($i - 1) * $iBlockHeight)

    $aLabel[$i] = GUICtrlCreateLabel($aReadSect[$i][0], $left, $iCurrentY, 489, 24)
    GUICtrlSetColor(-1, 0x0066CC)

    $aInput[$i] = GUICtrlCreateInput($aReadSect[$i][1], $left, $iCurrentY + 24, 489, 21)
Next

; 3. Calcoliamo l'altezza virtuale totale necessaria
;    boh 3 moltiplicato per i numeri di elementi inseriti sembra andare bene
Local $iTotalVirtualHeight = ($iNum * 3)

; 4. Inizializziamo le Scrollbar
_GUIScrollBars_Init($hGUI)

; Configuriamo la Scrollbar Verticale ($SB_VERT)
; Impostiamo il massimo scorrimento in base all'altezza calcolata
_GUIScrollBars_ShowScrollBar($hGUI, $SB_VERT, True)
_GUIScrollBars_SetScrollInfoMax($hGUI, $SB_VERT, $iTotalVirtualHeight)

; 5. Registriamo il messaggio di Windows per lo scroll verticale
;    Questo dice ad AutoIt: "Quando qualcuno tocca la scrollbar, esegui la funzione WM_VSCROLL"
GUIRegisterMsg($WM_VSCROLL, "WM_SIZE")
GUIRegisterMsg($WM_VSCROLL, "WM_VSCROLL")

;~ _GUIScrollBars_Init($hGUI)

GUISetState(@SW_SHOW)

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
    EndSwitch
WEnd

Func WM_SIZE($hWnd, $iMsg, $wParam, $lParam)
	#forceref $iMsg, $wParam
	Local $iIndex = -1, $iCharY, $iCharX, $iClientMaxX, $iClientX, $iClientY, $iMax
	For $x = 0 To UBound($__g_aSB_WindowInfo) - 1
		If $__g_aSB_WindowInfo[$x][0] = $hWnd Then
			$iIndex = $x
			$iClientMaxX = $__g_aSB_WindowInfo[$iIndex][1]
			$iCharX = $__g_aSB_WindowInfo[$iIndex][2]
			$iCharY = $__g_aSB_WindowInfo[$iIndex][3]
			$iMax = $__g_aSB_WindowInfo[$iIndex][7]
			ExitLoop
		EndIf
	Next
	If $iIndex = -1 Then Return 0

	Local $tSCROLLINFO = DllStructCreate($tagSCROLLINFO)

	; Retrieve the dimensions of the client area.
	$iClientX = BitAND($lParam, 0x0000FFFF)
	$iClientY = BitShift($lParam, 16)
	$__g_aSB_WindowInfo[$iIndex][4] = $iClientX
	$__g_aSB_WindowInfo[$iIndex][5] = $iClientY

	; Set the vertical scrolling range and page size
	DllStructSetData($tSCROLLINFO, "fMask", BitOR($SIF_RANGE, $SIF_PAGE))
	DllStructSetData($tSCROLLINFO, "nMin", 0)
	DllStructSetData($tSCROLLINFO, "nMax", $iMax)
	DllStructSetData($tSCROLLINFO, "nPage", $iClientY / $iCharY)
	_GUIScrollBars_SetScrollInfo($hWnd, $SB_VERT, $tSCROLLINFO)

	; Set the horizontal scrolling range and page size
	DllStructSetData($tSCROLLINFO, "fMask", BitOR($SIF_RANGE, $SIF_PAGE))
	DllStructSetData($tSCROLLINFO, "nMin", 0)
	DllStructSetData($tSCROLLINFO, "nMax", 2 + $iClientMaxX / $iCharX)
	DllStructSetData($tSCROLLINFO, "nPage", $iClientX / $iCharX)
	_GUIScrollBars_SetScrollInfo($hWnd, $SB_HORZ, $tSCROLLINFO)

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_SIZE

Func WM_VSCROLL($hWnd, $iMsg, $wParam, $lParam)
	#forceref $iMsg, $wParam, $lParam
	Local $iScrollCode = BitAND($wParam, 0x0000FFFF)
	Local $iIndex = -1, $iCharY, $iPosY
	Local $iMin, $iMax, $iPage, $iPos, $iTrackPos

	For $x = 0 To UBound($__g_aSB_WindowInfo) - 1
		If $__g_aSB_WindowInfo[$x][0] = $hWnd Then
			$iIndex = $x
			$iCharY = $__g_aSB_WindowInfo[$iIndex][3]
			ExitLoop
		EndIf
	Next
	If $iIndex = -1 Then Return 0

	; Get all the vertical scroll bar information
	Local $tSCROLLINFO = _GUIScrollBars_GetScrollInfoEx($hWnd, $SB_VERT)
	$iMin = DllStructGetData($tSCROLLINFO, "nMin")
	$iMax = DllStructGetData($tSCROLLINFO, "nMax")
	$iPage = DllStructGetData($tSCROLLINFO, "nPage")
	; Save the position for comparison later on
	$iPosY = DllStructGetData($tSCROLLINFO, "nPos")
	$iPos = $iPosY
	$iTrackPos = DllStructGetData($tSCROLLINFO, "nTrackPos")

	Switch $iScrollCode
		Case $SB_TOP ; user clicked the HOME keyboard key
			DllStructSetData($tSCROLLINFO, "nPos", $iMin)

		Case $SB_BOTTOM ; user clicked the END keyboard key
			DllStructSetData($tSCROLLINFO, "nPos", $iMax)

		Case $SB_LINEUP ; user clicked the top arrow
			DllStructSetData($tSCROLLINFO, "nPos", $iPos - 1)

		Case $SB_LINEDOWN ; user clicked the bottom arrow
			DllStructSetData($tSCROLLINFO, "nPos", $iPos + 1)

		Case $SB_PAGEUP ; user clicked the scroll bar shaft above the scroll box
			DllStructSetData($tSCROLLINFO, "nPos", $iPos - $iPage)

		Case $SB_PAGEDOWN ; user clicked the scroll bar shaft below the scroll box
			DllStructSetData($tSCROLLINFO, "nPos", $iPos + $iPage)

		Case $SB_THUMBTRACK ; user dragged the scroll box
			DllStructSetData($tSCROLLINFO, "nPos", $iTrackPos)
	EndSwitch

	; // Set the position and then retrieve it.  Due to adjustments
	; //   by Windows it may not be the same as the value set.

	DllStructSetData($tSCROLLINFO, "fMask", $SIF_POS)
	_GUIScrollBars_SetScrollInfo($hWnd, $SB_VERT, $tSCROLLINFO)
	_GUIScrollBars_GetScrollInfo($hWnd, $SB_VERT, $tSCROLLINFO)
	;// If the position has changed, scroll the window and update it
	$iPos = DllStructGetData($tSCROLLINFO, "nPos")

	If ($iPos <> $iPosY) Then
		_GUIScrollBars_ScrollWindow($hWnd, 0, $iCharY * ($iPosY - $iPos))
		$iPosY = $iPos
	EndIf

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_VSCROLL