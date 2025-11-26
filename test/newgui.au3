#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <GuiListView.au3>
#include <WindowsConstants.au3>

Global $hGUI = GUICreate("ListView con Menu Contestuale", 500, 400)
Global $ListView1 = GUICtrlCreateListView("Nome|Tipo|Dimensione", 5, 5, 490, 350, _
    $LVS_REPORT + $LVS_SINGLESEL, $LVS_EX_FULLROWSELECT + $LVS_EX_GRIDLINES + $LVS_EX_DOUBLEBUFFER)

; Configura colonne
_GUICtrlListView_SetColumnWidth($ListView1, 0, 200)
_GUICtrlListView_SetColumnWidth($ListView1, 1, 150)
_GUICtrlListView_SetColumnWidth($ListView1, 2, 120)

; Aggiungi dati di esempio
_GUICtrlListView_AddItem($ListView1, "Documento1.txt", 0)
_GUICtrlListView_AddSubItem($ListView1, 0, "Documento di testo", 1)
_GUICtrlListView_AddSubItem($ListView1, 0, "2.5 KB", 2)

_GUICtrlListView_AddItem($ListView1, "Immagine.jpg", 1)
_GUICtrlListView_AddSubItem($ListView1, 1, "Immagine JPEG", 1)
_GUICtrlListView_AddSubItem($ListView1, 1, "1.2 MB", 2)

_GUICtrlListView_AddItem($ListView1, "Video.mp4", 2)
_GUICtrlListView_AddSubItem($ListView1, 2, "Video MP4", 1)
_GUICtrlListView_AddSubItem($ListView1, 2, "45.8 MB", 2)

_GUICtrlListView_AddItem($ListView1, "Archivio.zip", 3)
_GUICtrlListView_AddSubItem($ListView1, 3, "Archivio compresso", 1)
_GUICtrlListView_AddSubItem($ListView1, 3, "8.3 MB", 2)

; Crea menu contestuale
Global $ContextMenu = GUICtrlCreateContextMenu($ListView1)
Global $MenuItem_Apri = GUICtrlCreateMenuItem("Apri", $ContextMenu)
Global $MenuItem_Modifica = GUICtrlCreateMenuItem("Modifica", $ContextMenu)
GUICtrlCreateMenuItem("", $ContextMenu) ; Separatore
Global $MenuItem_Copia = GUICtrlCreateMenuItem("Copia", $ContextMenu)
Global $MenuItem_Incolla = GUICtrlCreateMenuItem("Incolla", $ContextMenu)
GUICtrlCreateMenuItem("", $ContextMenu) ; Separatore
Global $MenuItem_Elimina = GUICtrlCreateMenuItem("Elimina", $ContextMenu)
GUICtrlCreateMenuItem("", $ContextMenu) ; Separatore
Global $MenuItem_Proprieta = GUICtrlCreateMenuItem("Proprietà", $ContextMenu)

GUISetState(@SW_SHOW)
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")

While 1
    $msg = GUIGetMsg()
    Switch $msg
        Case $GUI_EVENT_CLOSE
            Exit

        Case $MenuItem_Apri
            Apri()

        Case $MenuItem_Modifica
            Modifica()

        Case $MenuItem_Copia
            Copia()

        Case $MenuItem_Incolla
            Incolla()

        Case $MenuItem_Elimina
            Elimina()

        Case $MenuItem_Proprieta
            MostraProprieta()
    EndSwitch
WEnd

; Gestisce doppio click
Func WM_NOTIFY($hWnd, $iMsg, $wParam, $lParam)
    Local $tNMHDR = DllStructCreate($tagNMHDR, $lParam)
    Local $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    Local $iCode = DllStructGetData($tNMHDR, "Code")

    If $hWndFrom = GUICtrlGetHandle($ListView1) Then
        Switch $iCode
            Case $NM_DBLCLK ; Doppio click
                Apri()
        EndSwitch
    EndIf
    Return $GUI_RUNDEFMSG
EndFunc

; Funzioni del menu contestuale
Func Apri()
    Local $selectedIndex = _GUICtrlListView_GetNextItem($ListView1)
	ConsoleWrite($selectedIndex & @CRLF)
    If $selectedIndex <> -1 Then
        Local $itemText = _GUICtrlListView_GetItemText($ListView1, $selectedIndex, 0)
        MsgBox(64, "Apri", "Apertura di: " & $itemText)
    EndIf
EndFunc

Func Modifica()
    Local $selectedIndex = _GUICtrlListView_GetNextItem($ListView1)
		ConsoleWrite($selectedIndex & @CRLF)
    If $selectedIndex <> -1 Then
        Local $itemText = _GUICtrlListView_GetItemText($ListView1, $selectedIndex, 0)
        MsgBox(64, "Modifica", "Modifica di: " & $itemText)
    EndIf
EndFunc

Func Copia()
    Local $selectedIndex = _GUICtrlListView_GetNextItem($ListView1)
		ConsoleWrite($selectedIndex & @CRLF)
    If $selectedIndex <> -1 Then
        Local $itemText = _GUICtrlListView_GetItemText($ListView1, $selectedIndex, 0)
        ClipPut($itemText)
        MsgBox(64, "Copia", "Copiato negli appunti: " & $itemText)
    EndIf
EndFunc

Func Incolla()
    Local $clipText = ClipGet()
    If $clipText <> "" Then
        Local $newIndex = _GUICtrlListView_GetItemCount($ListView1)
        _GUICtrlListView_AddItem($ListView1, $clipText, $newIndex)
        _GUICtrlListView_AddSubItem($ListView1, $newIndex, "Nuovo elemento", 1)
        _GUICtrlListView_AddSubItem($ListView1, $newIndex, "0 KB", 2)
        MsgBox(64, "Incolla", "Elemento incollato: " & $clipText)
    Else
        MsgBox(48, "Incolla", "Appunti vuoti!")
    EndIf
EndFunc

Func Elimina()
    Local $selectedIndex = _GUICtrlListView_GetNextItem($ListView1)
		ConsoleWrite($selectedIndex & @CRLF)
    If $selectedIndex <> -1 Then
        Local $itemText = _GUICtrlListView_GetItemText($ListView1, $selectedIndex, 0)
        Local $risposta = MsgBox(4 + 32, "Elimina", "Sei sicuro di voler eliminare: " & $itemText & "?")
        If $risposta = 6 Then ; Yes
            _GUICtrlListView_DeleteItem($ListView1, $selectedIndex)
            MsgBox(64, "Elimina", "Elemento eliminato!")
        EndIf
    EndIf
EndFunc

Func MostraProprieta()
    Local $selectedIndex = _GUICtrlListView_GetNextItem($ListView1)
		ConsoleWrite($selectedIndex & @CRLF)
    If $selectedIndex <> -1 Then
        Local $nome = _GUICtrlListView_GetItemText($ListView1, $selectedIndex, 0)
        Local $tipo = _GUICtrlListView_GetItemText($ListView1, $selectedIndex, 1)
        Local $dimensione = _GUICtrlListView_GetItemText($ListView1, $selectedIndex, 2)

        MsgBox(64, "Proprietà", _
            "Nome: " & $nome & @CRLF & _
            "Tipo: " & $tipo & @CRLF & _
            "Dimensione: " & $dimensione)
    EndIf
EndFunc