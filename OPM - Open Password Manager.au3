#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=icon\icon.ico
#AutoIt3Wrapper_Outfile=Release\OPM x86.Exe
#AutoIt3Wrapper_Outfile_x64=Release\OPM x64.Exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=Un semplice ma efficace Password Manager
#AutoIt3Wrapper_Res_Fileversion=0.8.5.2
#AutoIt3Wrapper_Res_CompanyName=hacktooth
#AutoIt3Wrapper_Res_LegalCopyright=hacktooth
#AutoIt3Wrapper_Res_Language=1040
#Au3Stripper_Parameters=/pe /sf /mo /rm
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; Filename[,ResNumber[,LanguageCode]] of ICO to be added.
; Add extra ICO files to the resources
; Use full path of the ico files to be added
;~ ‪F:\Autoit\passwordmanager\icon\icon.ico, 301
; ResNumber is a numeric value used to access the icon: TraySetIcon(@ScriptFullPath, ResNumber)
; If no ResNumber is specified, the added icons are numbered from 201 up


;Password manager beta version
;26/12/2021
;by hacktooth

#comments-start

Bug fix e implementazione di funzionalità
	-------------------------------------------------------------------------------------------------
Legenda implementazione di funzionalità
+++ = Priorità massima
++ = Priorità media
+ = Priorità bassa (non è detto che venga aggiunta)
	-------------------------------------------------------------------------------------------------
Legenda Bug fix
*** = Critico ( da attribuire solo per motivi di sicurezza dei dati )
** = Grave
* = Lieve
	-------------------------------------------------------------------------------------------------
IMPLEMENTAZIONE FUNZIONALITA'
	++ Implementare la categorizzazione degli Accounts per tipo esempio (Email, Shopping, Socials, Games, etc ...)
		+ Orientare il funzionamento del Software su soluzioni in Cloud
		+ Nella finestra principale [GUI_main()] visualizzare i records degli Accounts solo dopo aver premuto INVIO
		  e non più tramite Click DX del mouse
	-------------------------------------------------------------------------------------------------
BUG NOTI
* Altezza di GUI_readrec() non è sempre proporzionale al numero totale di records su un Account
	Come generare il bug :
	Da GUI_main() selezionare un Account con records totali superiori a 3

#comments-end

#include <File.au3>
#include <FileConstants.au3>
#include <APIFilesConstants.au3>
#include <WinAPIFiles.au3>
#include <Crypt.au3>
#include <Clipboard.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

Opt("TrayMenuMode", 1)

;Dichiaro le variabili e le costanti globali
Global $userreg, $masterpassreg, $login, $username, $masterpass, $user, $masterkey, $nameuser, $Main, $login, $List1, $vListItem, $insrec, $Checkbox1, $Checkbox2, $recName, $recName1
Global $recValue, $recValue1, $sh, $hide, $ReadRecGUI, $sAccount, $sEmail, $sUser, $sPass, $attdisatt, $avvcheck, $key
Global Const $settingfile = @LocalAppDataDir & "\OPM\data\config\settings.ini"
Global Const $sInitDir = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
Global Const $name = "OPM - Open Password Manager"
Global Const $tempFolder = @TempDir & "\"
Global Const $Height = 75, $top = 16, $left = 16
Global Const $trayico = TraySetIcon(@ScriptFullPath, 201)
Global $restore = TrayCreateItem("Ripristina")
Global $reboot = TrayCreateItem("Riavvia")
Global $exititem = TrayCreateItem("Chiudi")

Global Enum $NARRAY, $FIELD1, $FIELD2, $VALUE1, $VALUE2
Global $aRead[5]

_Crypt_Startup() ; To optimize performance start the crypt library, though the same results will be shown if it isn't.

_login()

Func _login() ;Login

	Do
		;Controllo se esiste un file Utente, altrimenti chiedo di effettuare la registrazione
		If Not FileExists($settingfile) Then
			$iMsgBoxAnswer = MsgBox(262196, $name, "I nostri cani altamente addrestrati hanno scoperto che non è stato registrato nessun account! Woof" & @CRLF & @CRLF & _
					"Vuoi creare un nuovo account o vuoi importare un vecchio account esistente?" & @CRLF & "Premi Sì per creare un nuovo utente" & _
					@CRLF & "Premi No per Importare un file di configurazione")
			Select
				Case $iMsgBoxAnswer = 6 ;Yes
					_reg()
					ExitLoop
				Case $iMsgBoxAnswer = 7 ;No
					_Import()
					ExitLoop
			EndSelect
		Else
			ExitLoop
		EndIf
	Until False

	$login = GUICreate("OPM Login", 251, 301, -1, -1, -1)
	GUISetFont(10, 400, 0, "Segoe UI")
	$Label1 = GUICtrlCreateLabel("User", 16, 24, 31, 21)
	$username = GUICtrlCreateInput("", 16, 48, 217, 25, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
	GUICtrlSetFont(-1, 10, 400, 2, "Segoe UI")
	$Label2 = GUICtrlCreateLabel("Master Password", 16, 88, 105, 21)
	$masterpass = GUICtrlCreateInput("", 16, 112, 217, 25, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_PASSWORD))
	GUICtrlSetFont(-1, 10, 400, 2, "Segoe UI")
	$sign = GUICtrlCreateButton("Sign In", 16, 168, 217, 25)
	$reg = GUICtrlCreateLabel("New user? register an account now", 17, 208, 217, 21, $SS_CENTER)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetFont(-1, 10, 400, 4, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)
	GUISetState(@SW_SHOW, $login)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				_esci()
			Case $sign
				_checkreg(GUICtrlRead($username), GUICtrlRead($masterpass))
				If @error = "2" Then
					MsgBox(262160, $name, "Username o MasterKey errati! Riprova")
				ElseIf @error = "1" Then
					MsgBox(16, "-.-", "Dai amico prova almeno a inserire User o Password ;)")
				Else
					$nameuser = GUICtrlRead($username)
					$key = GUICtrlRead($masterpass)
					GUIDelete($login)
					ExitLoop
				EndIf
			Case $reg
				_reg()
			Local $msg = TrayGetMsg()
				Select
				Case $msg = $restore
					GUISetState(@SW_SHOW, $Main)
				Case $msg = $exititem
					_esci()
				Case $msg = $reboot
					_reboot()
				EndSelect
		EndSwitch
	WEnd

	_main()

EndFunc   ;==>_login

Func _reg() ;Registrazione

	$reggui = GUICreate("Registration", 298, 277, -1, -1)
	GUISetFont(8, 400, 0, "Segoe UI")
	$userreg = GUICtrlCreateInput("Insert your username", 16, 24, 265, 25)
	GUICtrlSetFont(-1, 10, 400, 2, "Segoe UI")
	$masterpassreg = GUICtrlCreateInput("Insert master password", 16, 64, 265, 25)
	GUICtrlSetFont(-1, 10, 400, 2, "Segoe UI")
	$Label1 = GUICtrlCreateLabel("Ricorda questa password o scrivila su un foglio, senza di essa non sarai in grado di accedere ai tuoi account, e si se lo dimentichi sei un Asino!", 18, 108, 266, 50, $SS_CENTER)
	GUICtrlSetFont(-1, 10, 400, 6, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)
	$Register = GUICtrlCreateButton("Register", 16, 174, 265, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")
	$Back = GUICtrlCreateButton("Back", 16, 210, 265, 25)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")
	$importa = GUICtrlCreateButton("Importa", 208, 248, 73, 17)
	GUICtrlSetColor(-1, 0x0066CC)

	GUISetState(@SW_SHOW, $reggui)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $Back
				GUIDelete($reggui)
				GUISwitch($login)
				ExitLoop
			Case $Register
				_writereg()
				If @error Then
					MsgBox(16, "-.-", "Dai amico prova almeno a inserire User o Password ;)")
				Else
					MsgBox(64, $name, "Registrazione completata!")
					GUIDelete($reggui)
					GUISwitch($login)
					ExitLoop
				EndIf
			Case $importa
				_Import()
		EndSwitch
	WEnd

EndFunc   ;==>_reg

Func _main() ;Interfaccia principale

	$Main = GUICreate("Benvenuto " & $nameuser, 426, 413, -1, -1)
	$Menu = GUICtrlCreateMenu("&Menù")
	$new = GUICtrlCreateMenuItem("New" & @TAB & "Shift+Ctrl+F17", $Menu)
	$settings = GUICtrlCreateMenuItem("Settings" & @TAB & "Ctrl+Space", $Menu)
	$about = GUICtrlCreateMenuItem("About", $Menu)
	$List1 = GUICtrlCreateList("", 0, 0, 425, 329)
	GUICtrlSetData(-1, "")
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")
	$addRec = GUICtrlCreateButton("Aggiungi Accounts", 224, 344, 177, 33)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")
	$backUp = GUICtrlCreateButton("Esegui Backup", 16, 344, 177, 33)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

	_updategui()

	GUISetState(@SW_SHOW, $Main)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				_esci()
			Case $new, $addRec
				_insrec()
			Case $settings
				_settingGUI()
			Case $about
				_about()
			Case $backUp
				_backup()
			Case $List1
				_readrec()
		EndSwitch
			Local $msg = TrayGetMsg()
			Select
			Case $msg = $restore
				GUISetState(@SW_SHOW, $Main)
			Case $msg = $exititem
				_esci()
			Case $msg = $reboot
				_reboot()
			EndSelect
	WEnd

EndFunc   ;==>_main

Func _backup()

	; Create a constant variable in Local scope of the message to display in FileSelectFolder.
	Local Const $sMessage_1 = "Scegli dove eseguire il Backup"

	; Display an open dialog to select a file.
	Local $sFileSelectFolder = FileSelectFolder($sMessage_1, "")
	If @error Then
		; Display the error message.
		MsgBox($MB_SYSTEMMODAL, "", "Nessuna cartella selezionata.")
	Else
		Local $sTempFile_1 = _TempFile($sFileSelectFolder & "\", "backup_" & @HOUR & "-" & @MIN & "-" & @SEC, ".dat", Default)
		FileCopy($settingfile, @TempDir & "\tmpbak\", $FC_OVERWRITE + $FC_CREATEPATH)
		FileMove(@TempDir & "\tmpbak\settings.ini", $sTempFile_1, $FC_CREATEPATH)
		FileDelete(@TempDir & "\tmpbak\settings.ini")
		Sleep(200)
		ShellExecute($sFileSelectFolder)
	EndIf

EndFunc

Func _reboot() ;Riavvio
	Run (@ScriptFullPath)
	Sleep(100)
	Exit
EndFunc

Func _insrec() ;Inserisce un Account

	$insrec = GUICreate("Aggiungi Account", 514, 330, -1, -1)
	GUISetFont(10, 400, 0, "Segoe UI")
	$Group1 = GUICtrlCreateGroup("Nuovo Account", 16, 8, 481, 305)
	$Label10 = GUICtrlCreateLabel("Account name :", 48, 48, 110, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)
	$sAccount = GUICtrlCreateInput("", 160, 48, 305, 25)
	$Label11 = GUICtrlCreateLabel("Email :", 109, 96, 50, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)
	$sEmail = GUICtrlCreateInput("", 160, 96, 305, 25)
	$Label12 = GUICtrlCreateLabel("Username :", 76, 144, 82, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)
	$sUser = GUICtrlCreateInput("(facoltativo)", 160, 144, 305, 25)
	$Label13 = GUICtrlCreateLabel("Password :", 81, 192, 78, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)
	$sPass = GUICtrlCreateInput("", 160, 192, 305, 25, BitOR($GUI_SS_DEFAULT_INPUT, $ES_PASSWORD))
	$annulla = GUICtrlCreateButton("Cancel", 336, 264, 129, 33)
	$addrecs = GUICtrlCreateButton("Aggiungi Account", 192, 264, 129, 33)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$tip = GUICtrlCreateLabel("Per creare altri record bisogna prima registrare questi campi obbligatori", 44, 232, 440, 25)
	GUISetFont(10, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0xFF0000)
	GUISetState(@SW_SHOW, $insrec)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $annulla
				GUIDelete($insrec)
				GUISwitch($Main)
				ExitLoop
			Case $addrecs
				_addrec(GUICtrlRead($sAccount), GUICtrlRead($sUser), GUICtrlRead($sEmail), GUICtrlRead($sPass))
				_updategui()
				GUIDelete($insrec)
				GUISwitch($Main)
				ExitLoop
		EndSwitch
	WEnd

EndFunc   ;==>_insrec

Func _settingGUI() ;Interfaccia Impostazioni

$Impostazioni = GUICreate("Impostazioni", 554, 492, -1, -1, -1, BitOR($WS_EX_TOOLWINDOW,$WS_EX_WINDOWEDGE))
	GUISetFont(12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)
$groupsett = GUICtrlCreateGroup("Esporta / Importa File Configurazione", 16, 112, 521, 121, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
$import = GUICtrlCreateButton("Importa", 32, 192, 153, 30)
GUICtrlSetColor(-1, 0x0066CC)
$export = GUICtrlCreateButton("Esporta", 368, 192, 153, 30)
GUICtrlSetColor(-1, 0x0066CC)
$Input1 = GUICtrlCreateInput("(cooming soon)", 32, 152, 489, 29)
GUICtrlSetColor(-1, 0x0066CC)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
$avv = GUICtrlCreateGroup("Avvio", 16, 16, 521, 81, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
$avvLab = GUICtrlCreateLabel("Avvia all'avvio di Windows (solo Windows 7)", 24, 48, 189, 25)
	GUICtrlSetColor(-1, 0x0066CC)
$avvcheck = GUICtrlCreateCheckbox("", 224, 48, 17, 25)
	GUICtrlSetTip(-1, "Sì / No")
$attdisatt = GUICtrlCreateLabel("Attivato", 256, 48, 78, 25)
	GUICtrlSetColor(-1, 0x008000)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group1 = GUICtrlCreateGroup("Modifica Password (cooming soon)", 16, 248, 521, 201)
	GUICtrlSetColor(-1, 0x0066CC)
$Label4 = GUICtrlCreateLabel("Vecchia Password", 32, 288, 128, 25)
$Input2 = GUICtrlCreateInput("Input2", 160, 288, 361, 29, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
$Label5 = GUICtrlCreateLabel("Nuova Password", 32, 328, 121, 25)
$Input3 = GUICtrlCreateInput("Input2", 160, 328, 361, 29, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
$Label6 = GUICtrlCreateLabel("Ripeti Password", 32, 368, 115, 25)
$Input4 = GUICtrlCreateInput("Input2", 160, 368, 361, 29, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
$changePass = GUICtrlCreateButton("Cambia Password", 168, 408, 249, 25)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUISetState(@SW_SHOW, $Impostazioni)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			GUIDelete($Impostazioni)
			GUISwitch($Main)
			ExitLoop
		Case $import
			_Import()
			_reboot()
		Case $export
			_Export()
		Case $avvcheck
			_StartOnStartup($avvcheck)
		Case $changePass
	EndSwitch
WEnd

EndFunc

Func _Import() ;Importa file config

	; Create a constant variable in Local scope of the message to display in FileOpenDialog
	Local Const $sMess = "Seleziona il file di configurazione"

	; Display an open dialog to select a list of file(s).
	Local $sFileOpenDialog = FileOpenDialog($sMess, @DocumentsCommonDir & "\", "config (*.dat;*.ini)", $FD_FILEMUSTEXIST)
	If @error Then
		; Display the error message.
		MsgBox($MB_SYSTEMMODAL, "", "Nessun File selezionato")

		; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
		FileChangeDir(@ScriptDir)
	Else
		; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
		FileChangeDir(@ScriptDir)

		; Replace instances of "|" with @CRLF in the string returned by FileOpenDialog.
		$sFileOpenDialog = StringReplace($sFileOpenDialog, "|", @CRLF)

		FileCopy($sFileOpenDialog, $settingfile, $FC_OVERWRITE + $FC_CREATEPATH)

		; Display the list of selected files.
		MsgBox($MB_SYSTEMMODAL, "", "Il file di configurazione è stato importato con successo")
	EndIf
EndFunc   ;==>_Import

Func _Export() ;Esporta file config

	; Create a constant variable in Local scope of the message to display in FileSaveDialog.
	Local Const $sMessage = "Scegli il nome del file"

	; Display a save dialog to select a file.
	Local $sFileSaveDialog = FileSaveDialog($sMessage, $sInitDir, "settings (*.ini)", $FD_PATHMUSTEXIST)
	If @error Then
		; Display the error message.
		MsgBox($MB_SYSTEMMODAL, "", "No file was saved.")
	Else
		; Retrieve the filename from the filepath e.g. Example.au3.
		Local $sFileName = StringTrimLeft($sFileSaveDialog, StringInStr($sFileSaveDialog, "\", $STR_NOCASESENSEBASIC, -1))

		; Check if the extension .au3 is appended to the end of the filename.
		Local $iExtension = StringInStr($sFileName, ".", $STR_NOCASESENSEBASIC)

		; If a period (dot) is found then check whether or not the extension is equal to .ini.
		If $iExtension Then
			; If the extension isn't equal to .ini then append to the end of the filepath.
			If Not (StringTrimLeft($sFileName, $iExtension - 1) = ".ini") Then $sFileSaveDialog &= ".ini"
		Else
			; If no period (dot) was found then append to the end of the file.
			$sFileSaveDialog &= ".ini"
		EndIf

		;Esporta file nella destinazione scelta
		FileCopy($settingfile, $sFileSaveDialog, $FC_OVERWRITE)

		; Display the saved file.
		MsgBox($MB_SYSTEMMODAL, "", "You saved the following file:" & @CRLF & $sFileSaveDialog)
	EndIf

EndFunc

Func _updategui() ;Aggiorna la GUI principale

	GUICtrlSetData($List1, "") ;Flush lista
	GUICtrlSetData($sAccount, "")
	GUICtrlSetData($sEmail, "")
	GUICtrlSetData($sUser, "")
	GUICtrlSetData($sPass, "")
	Local $aArray = IniReadSectionNames($settingfile)
	If Not @error Then
		For $i = 2 To $aArray[0]
			GUICtrlSetData($List1, $aArray[$i] & "|")
		Next
	Else
		MsgBox(16, "Errore", "Possibili cause:" & @CRLF & "Cancellazione o spostamento del file settings")
	EndIf

EndFunc   ;==>_updategui

Func _readrec() ;Leggi records

	$hide = 1

	Local $top1 = $top
	Local $guiHeight = $Height
	Local $iPosition

	$vListItem = GUICtrlRead($List1)

	If $vListItem = "" Then Return

	;Read the keys and its values
	Local $aReadSect = IniReadSection($settingfile, $vListItem)

	$aLabel = $aReadSect[0][0]
	$aInput = $aReadSect[0][0]

	$iNum = UBound($aReadSect)

	;Ridimensionamento GUI in base alla quantità di record esistenti
	$guiHeight = ($iNum - 1) * $Height

	Local $aLabel[$iNum]
	Local $aInput[$iNum]

	If $sh = 1 Then
		For $i = 1 To $iNum - 1
			$iPosition = StringInStr($aReadSect[$i][1], "0x")
			If $iPosition = 1 Then
				$aReadSect[$i][1] = StringEncrypt(False, $aReadSect[$i][1], $key)
			EndIf
		Next
		$sh = 0
		$hide = 0
	EndIf

	If $sh = "" Then $ReadRecGUI = GUICreate($vListItem, 585, $guiHeight, -1, -1, -1, $WS_EX_TOPMOST)

	For $i = 1 To $iNum - 1
		$aLabel[$i] = GUICtrlCreateLabel(($aReadSect[$i][0]), $left, $top1, 489, 24)
		GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
		GUICtrlSetColor(-1, 0x0066CC)
		$aInput[$i] = GUICtrlCreateInput(($aReadSect[$i][1]), $left, $top1 + 24, 489, 21)
		$top1 += 50
	Next
	Local $copyToClip = GUICtrlCreateButton("", 520, 24, 49, 49, $BS_ICON)
	GUICtrlSetTip($copyToClip, "Copia Password nella clipboard")
	GUICtrlSetImage($copyToClip, @ScriptFullPath, 202)
	Local $show = GUICtrlCreateButton("", 520, 87, 49, 49, $BS_ICON)
	GUICtrlSetImage($show, @ScriptFullPath, 201)
	$remButton = GUICtrlCreateButton("Rimuovi account", 336, $guiHeight - 52, 113, 41)
	$cancelButton = GUICtrlCreateButton("Chiudi", 456, $guiHeight - 52, 113, 41)
	$addNewField = GUICtrlCreateButton("Aggiungi Records", 216, $guiHeight - 52, 113, 41)
	GUISetState(@SW_SHOW, $ReadRecGUI)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $cancelButton
				GUIDelete($ReadRecGUI)
				GUISwitch($Main)
				ExitLoop
			Case $copyToClip
				_clippa($aReadSect[3][1])
				TrayTip($name, "Password copiata!", 1)
			Case $addNewField
				_addField()
				GUISetState(@SW_HIDE, $ReadRecGUI)
				_readrec() ;Aggiorno la GUI per visualizzare le nuove voci
				ExitLoop
			Case $show
				If $hide = 1 Then $sh = 1
				GUISetState(@SW_HIDE, $ReadRecGUI)
				_readrec() ;Update GUI
				ExitLoop
			Case $remButton
				GUIDelete($ReadRecGUI)
				_remove($vListItem)
				GUISwitch($Main)
				ExitLoop
		EndSwitch
	WEnd

EndFunc   ;==>_readrec

Func _remove($vRem) ;Rimuovi accounts

	If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
	$iMsgBoxAnswer = MsgBox(262452,"","Sei sicuro di eliminare l'account : ")
	Select
		Case $iMsgBoxAnswer = 6 ;Yes
			IniDelete($settingfile, $vRem)
			_updategui()
			TrayTip($name, $vRem & " Account Rimosso!", 1)
			Return
		Case $iMsgBoxAnswer = 7 ;No
			Return
	EndSelect

EndFunc

Func _addField() ;Aggiungi nuovi records

	$addrecGUI = GUICreate("Aggiungi Records", 515, 294, -1, -1, $WS_EX_TOPMOST)
	$recLabel1 = GUICtrlCreateLabel("Record 1°", 16, 16, 72, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)
	$recName = GUICtrlCreateInput("Inserisci il nome del Record", 16, 48, 481, 21)
	$recValue = GUICtrlCreateInput("Inserisci il valore del Record", 16, 80, 481, 21)
	$recLabel2 = GUICtrlCreateLabel("Record 2°", 16, 120, 72, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)
	$recName1 = GUICtrlCreateInput("Inserisci il nome del Record", 16, 152, 481, 21)
	$recValue1 = GUICtrlCreateInput("Inserisci il valore del Record", 16, 184, 481, 21)
	$Checkbox1 = GUICtrlCreateCheckbox("Cripta Record", 408, 16, 89, 25)
	$Checkbox2 = GUICtrlCreateCheckbox("Cripta Record", 408, 120, 89, 25)
	$okButton = GUICtrlCreateButton("Salva Records", 197, 224, 121, 33)
	$cancelButton1 = GUICtrlCreateButton("Annulla", 376, 224, 121, 33)
	GUISetState(@SW_SHOW, $addrecGUI)


	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $cancelButton1
				GUIDelete($addrecGUI)
				GUISwitch($ReadRecGUI)
				ExitLoop
			Case $okButton
				_writeField()
				GUIDelete($addrecGUI)
				GUISwitch($ReadRecGUI)
				ExitLoop
		EndSwitch
	WEnd

EndFunc   ;==>_addField

Func _writeField() ;Scrivi records

	Local $vEn1, $vEn2

	$aRead[$NARRAY] = UBound($aRead)                 ;Numero dimensioni array
	$aRead[$FIELD1] = GUICtrlRead($recName)         ;Legge il Nome del Record 1
	$aRead[$FIELD2] = GUICtrlRead($recName1)         ;Legge il Nome del Record 2
	$aRead[$VALUE1] = GUICtrlRead($recValue)         ;Legge il Valore del Record 1
	$aRead[$VALUE2] = GUICtrlRead($recValue1)         ;Legge il Valore del Record 2

	;Controllo se il primo campo sia stato inserito, se così non fosse termino la funzione
	If $aRead[$FIELD1] = "" Or $aRead[$FIELD1] = "Inserisci il nome del Record" Then Return

	;Controllo se è presente un valore da inserire diverso dal testo di Default
	If $aRead[$VALUE1] = "" Or $aRead[$VALUE1] = "Inserisci il valore del Record" Then
		MsgBox(48, "", "Non è stato inserito un valore valido per il Record")
		Return
	EndIf

	;Controllo se devo criptare il primo valore altrimenti lo scrivo in chiaro
	If _IsChecked($Checkbox1) Then
		$vEn1 = StringEncrypt(True, $aRead[$VALUE1], $key)
		IniWrite($settingfile, $vListItem, $aRead[$FIELD1], $vEn1)

	Else
		IniWrite($settingfile, $vListItem, $aRead[$FIELD1], $aRead[$VALUE1])
	EndIf

	;Controllo se il secondo campo sia stato inserito, se così non fosse termino la funzione
	If $aRead[$FIELD2] = "" Or $aRead[$FIELD2] = "Inserisci il nome del Record" Then
		MsgBox(64, "Okay", "Dati aggiunti con successo!")
		Return
	EndIf

	;Controllo se è presente un valore da inserire diverso dal testo di Default
	If $aRead[$VALUE2] = "" Or $aRead[$VALUE2] = "Inserisci il valore del Record" Then
		MsgBox(48, "", "Non è stato inserito un valore valido per il Record N°2")
		Return
	EndIf

	;Controllo se devo criptare il secondo valore altrimenti lo scrivo in chiaro
	If _IsChecked($Checkbox2) Then
		$vEn2 = StringEncrypt(True, $aRead[$VALUE2], $key)
		IniWrite($settingfile, $vListItem, $aRead[$FIELD2], $vEn2)

	Else
		IniWrite($settingfile, $vListItem, $aRead[$FIELD2], $aRead[$VALUE2])
	EndIf

	MsgBox(64, "Okay", "Dati aggiunti con successo!")

EndFunc   ;==>_writeField

Func _addrec($account, $uRec, $email, $pRec) ;Aggiungi i record e se necessario oscurarli

	If $account = "" Then
		MsgBox(16, "", "Nothing to add -.-", 1)
		Return
	EndIf

	Local $uEncrypted = StringEncrypt(True, $uRec, $key)
	Local $pEncrypted = StringEncrypt(True, $pRec, $key)

	IniWrite($settingfile, $account, "Username", $uEncrypted)
	IniWrite($settingfile, $account, "Email", $email)
	IniWrite($settingfile, $account, "Password", $pEncrypted)

	MsgBox(64, "Aggiunto", "Record salvati con successo.")

EndFunc   ;==>_addrec

Func _writereg() ;Scrivi registrazione utente

	Local $user = GUICtrlRead($userreg)
	Local $masterkey = GUICtrlRead($masterpassreg)

	If $user == "" And $masterkey == "" Then
		SetError(1)
		Return
	EndIf

	Local $uEncrypted = StringEncrypt(True, $user, $masterkey)
	Local $mkEncrypted = _Crypt_HashData($masterkey, $CALG_SHA_512)

	;Creo il file setting.ini nella directory
	If Not _FileCreate($settingfile) Then
		MsgBox($MB_SYSTEMMODAL, "Error", " Error Creating/Resetting.      error:" & @error)
	EndIf

	;Write Data
	IniWrite($settingfile, "User", "username", $uEncrypted)
	IniWrite($settingfile, "User", "key", $mkEncrypted)

	MsgBox($MB_SYSTEMMODAL, "Attenzione", "Non dimenticare mai queste info, stampale se necessario oppure scrivilo" & _
			" o ricordalo a mente, non avrai modo di accedere alle tue password dimenticando la questa Password." & @CRLF & @CRLF & _
			"User: " & $user & @CRLF & _
			"Master Key: " & $masterkey)

	;Destroy data
	$user = Null
	$masterkey = Null
	$uEncrypted = Null
	$mkEncrypted = Null

EndFunc   ;==>_writereg

Func StringEncrypt($bEncrypt, $sData, $sPassword)

	Local $vReturn = ""

	If $sData == "" Then Return

	If $bEncrypt Then
		$vReturn = _Crypt_EncryptData($sData, $sPassword, $CALG_AES_256)
	Else
		$vReturn = BinaryToString(_Crypt_DecryptData($sData, $sPassword, $CALG_AES_256))
	EndIf

	Return $vReturn

EndFunc   ;==>StringEncrypt

Func _checkreg($iUser, $iPass) ;Controllo Registrazione

	Local $vReturn = ""

	If $iUser == "" And $iPass == "" Then
		SetError(1)
		Return $vReturn
	EndIf

	;Leggo settings.ini Sezione User
	Local $uRead = IniRead($settingfile, "User", "username", "default")
	Local $mkRead = IniRead($settingfile, "User", "key", "default")

	Local $uEncrypted = StringEncrypt(True, $iUser, $iPass)
	Local $mkEncrypted = _hashdata($iPass)

	;checking data
	If $uRead <> $uEncrypted Or $mkEncrypted = False Then
		$vReturn = False
		SetError(2)
	Else
		$vReturn = True
	EndIf

	Return $vReturn
EndFunc   ;==>_checkreg

Func _clippa($field) ;Copia nella clipboard
	ClipPut(StringEncrypt(False, $field, $key))
	AdlibRegister(_resetclip, 30000)
EndFunc

Func _resetclip()
	_ClipBoard_Empty()
	AdlibUnRegister(_resetclip)
EndFunc



Func _IsChecked($idControlID) ;Controlla se le checkbox sono spuntate o meno
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

Func _about() ;About
	MsgBox(64, "About", "OPM Open Password Manager created by : Giuseppe 'hacktooth' Catania" & @CRLF & "Reason : Too bored, too poor for pay Dashline LOL" & @CRLF & "When: on december 2021")
EndFunc   ;==>_about

Func _StartOnStartup($vSwitch) ;Lancia all'avvio

	If _IsChecked($vSwitch) Then
	RegWrite("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RUN", "OPM.beta","REG_SZ", @ScriptDir & "\" & @ScriptName)
		If @error Then
			GUICtrlSetData($attdisatt, "Disattivato")
			GUICtrlSetColor(-1, 0xFF0000)
			MsgBox("", "Error", "Qualcosa è andato storto")
		Else
			GUICtrlSetData($attdisatt, "Attivato")
			GUICtrlSetColor(-1, 0x008000)
		EndIf

	Else
		GUICtrlSetData($attdisatt, "Disattivato")
		GUICtrlSetColor(-1, 0xFF0000)
		RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RUN", "OPM.beta")
	EndIf

EndFunc

Func _hashdata($skey)

	Local $vData = ""
	Local $bPasswordHash = IniRead($settingfile, "User", "key", "default")

	If _Crypt_HashData($skey, $CALG_SHA_512) = $bPasswordHash Then
		$vData = True
	Else
		$vData = False
	EndIf

	Return $vData

EndFunc

Func _esci() ;Esci dal programma

	If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
	$iMsgBoxAnswer = MsgBox(36, "Esci", "Sei sicuro di uscire dal programma :(")
	Select
		Case $iMsgBoxAnswer = 6 ;Sì
			_Crypt_Shutdown() ; Shutdown the crypt library.
			Exit
	EndSelect


EndFunc   ;==>_esci
