; ===============================================================================================================================
;
; AutoIt v3 - Password manager by Jyukat
; Modified in 21/11/2025
;
; ===============================================================================================================================

#include <Crypt.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <APIFilesConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiButton.au3>
#include <StaticConstants.au3>
#include <WinAPIFiles.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>

_Crypt_Startup() ; Initialize the Crypt library, to improve performance

Opt("TrayMenuMode", 1) ; Enable tray menu

#region Global variables and constants
Global $login, $user, $masterkey, $username
Global $MainUI, $List1, $vListItem, $insrec, $Checkbox1, $Checkbox2, $recName, $recName1
Global $recValue, $recValue1, $sh, $hide, $ReadRecGUI, $sAccount, $sEmail, $sUser, $sPass

Global $iAlgorithm = $CALG_AES_256

Global Const $settingfile	 = 		@LocalAppDataDir & "\OPM\data\config\config.ini"
Global Const $sInitDir		 = 		"::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
Global Const $name			 = 		"Open Password Manager"
Global Const $tempFolder	 = 		@TempDir & "\"
Global Const $Height		 = 		220, $top = 16, $left = 16
Global Const $trayico		 = 		TraySetIcon(@ScriptFullPath, 201)

Global $restore 	= 	TrayCreateItem("Show window")
Global $reboot 		= 	TrayCreateItem("Restart application")
Global $exititem 	= 	TrayCreateItem("Exit")

;~ array size, first field, second field, first value, second value
Global Enum $NARRAY, $FIELD1, $FIELD2, $VALUE1, $VALUE2
Global $aRead[5]
#EndRegion

#include "userUtils.au3"
#include "configUtils.au3"
#include "databaseUtils.au3"
#include "clipUtils.au3"
#include "uiUtils.au3"

;Check if a user config file exist
Do
	If Not FileExists($settingfile) Then
		$iMsgBoxAnswer = MsgBox(262196, $name, _
								"No account found!" & @CRLF & _
								"Create a new account or import an existing one." & @CRLF & "Press YES to create a new user" & @CRLF & _
								"Press NO to import a configuration file")
		Select
			Case $iMsgBoxAnswer = 6 ;Yes
				_reg()
				ExitLoop
			Case $iMsgBoxAnswer = 7 ;No
				If _Import() Then ExitLoop
			EndSelect
	Else
		ExitLoop
	EndIf
Until False

$loginUI = GUICreate("Log In", 250, 290, -1, -1)
;GUISetFont(10, 400, 0, "Segoe UI")

$label_user		 =	 GUICtrlCreateLabel("User", 16, 24, 31, 21)
$in_username	 =	 GUICtrlCreateInput("", 16, 48, 217, 25, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
;GUICtrlSetFont($label_user, 10, 400, 2, "Segoe UI")

$label_masterPass	 =	 GUICtrlCreateLabel("Master Password", 16, 88, 105, 21)
$in_masterpass	 =	 GUICtrlCreateInput("", 16, 112, 217, 25, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_PASSWORD))
;GUICtrlSetFont($label_masterPass, 10, 400, 2, "Segoe UI")

$bnt_sign		 =	 GUICtrlCreateButton("Sign In", 16, 168, 217, 25, $BS_DEFPUSHBUTTON)
$Label_reg		 =	 GUICtrlCreateLabel("New user? register an account now", 17, 208, 217, 21, $SS_CENTER)

GUICtrlSetCursor	(-1, 0)
;GUICtrlSetFont		(-1, 10, 400, 4, "Segoe UI")
GUICtrlSetColor		(-1, 0x0066CC)

$btnabout	 =	 GUICtrlCreateButton("About", 16, 248, 217, 25)

GUISetState(@SW_SHOW, $loginUI)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_esci()
		Case $bnt_sign

			$username = GUICtrlRead($in_username)
			$masterpassword = GUICtrlRead($in_masterpass)

			If $iUser == "" Or $iPass == "" Then
				SetError(1)
			Return $vReturn
			EndIf

			_checkreg(GUICtrlRead($in_username), GUICtrlRead($in_masterpass))
			$in_masterpass = Null

			If @error = "2" Then
				MsgBox(262160, $name, "Incorrect User and Password, Retry please...")
			ElseIf @error = "1" Then
				;errore no pass no user insered
			Else
				GUIDelete($loginUI)
				ExitLoop
			EndIf
		Case $bnt_sign
			_signIn()
		Case $btnabout
			_about()
		Local $msg = TrayGetMsg()
			Select
			Case $msg = $restore
				GUISetState(@SW_SHOW, $loginUI)
			Case $msg = $exititem
				_esci()
			Case $msg = $reboot
				_reboot()
			EndSelect
	EndSwitch
WEnd

GUIDelete($loginUI)
WinMain()


;~ funzioni interfaccia
Func WinMain() ;Interfaccia principale

	$MainUI		 =	 GUICreate("Welcome " & $username, 350, 420, -1, -1)
	$Menu		 =	 GUICtrlCreateMenu("&Menù")
	$new		 =	 GUICtrlCreateMenuItem("Add account" & @TAB & "Ctrl+N", $Menu)
	$passGen	 =	 GUICtrlCreateMenuItem("Passoword Generator" & @TAB & "Ctrl+1", $Menu)
	$settings	 =	 GUICtrlCreateMenuItem("Settings" & @TAB & "Ctrl+Space", $Menu)
	$about		 =	 GUICtrlCreateMenuItem("About", $Menu)
	$List1		 =	 GUICtrlCreateList("", 5, 5, 340, 320)
	GUICtrlSetData(-1, "")
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

	$addRec	= GUICtrlCreateButton("Add Record", 220, 344, 120, 33)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

	$backUp	= GUICtrlCreateButton("Backup", 16, 344, 120, 33)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

	_updategui()

	GUISetState(@SW_SHOW, $MainUI)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				_esci()
			Case $new, $addRec
				_insrec()
			Case $passGen
				_passGen()
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
					GUISetState(@SW_SHOW, $MainUI)
				Case $msg = $exititem
					_esci()
				Case $msg = $reboot
					_reboot()
			EndSelect
	WEnd

EndFunc   ;==>_main

;~ altre funzioni minori
Func AddToStartup($vSwitch) ; Aggiunge un'applicazione alla cartella di avvio di Windows

	Local $ShortcutFile = @StartupDir &"\"& $name &".lnk"

	If _IsChecked($vSwitch) Then
		; Crea il collegamento
		FileCreateShortcut(@ScriptFullPath, $ShortcutFile)
		Return True
    Else
		FileDelete($ShortcutFile)
		Return False
	EndIf

EndFunc

Func _reboot() ;Riavvio
	_Crypt_Shutdown()
	Run (@ScriptFullPath)
	Sleep(100)
	Exit
EndFunc

Func _esci() ;Esci dal programma

	If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
	$iMsgBoxAnswer = MsgBox(36, "Exit", "Are you sure?")
	Select
		Case $iMsgBoxAnswer = 6 ;Sì
			_Crypt_Shutdown() ; Shutdown the crypt library.
			Exit
	EndSelect

EndFunc   ;==>_esci



#cs not implemented
Func _crypt()
Local $password = GUICtrlRead($stringlb)
Local $salt = "123456789abcdefg" ;_RandomString(16) ; Genera una stringa casuale di 16 caratteri come salt
Local $iterations = GUICtrlRead($iteredit) ; Numero di iterazioni

GUICtrlSetData($log, "Stringa: " & $password & @CRLF & "Salt: " & $salt & @CRLF & "Iterazioni: " & $iterations & @CRLF)

Local $hashedPassword = _Crypt_HashData($password & $salt, $CALG_SHA_512)

For $i = 0 to $iterations
$hashedPassword = _Crypt_HashData($hashedPassword, $CALG_SHA_512)
Next

$storedPass = $password
$storedHashedPassword = $hashedPassword
$storedIterations = $iterations
$storedsalt = $salt

GUICtrlSetData($log, "Stringa criptata: " & $storedHashedPassword & @CRLF & "Salt salvata: " & $storedsalt & @CRLF & "Iterazioni effettuate: " & $storedIterations & @CRLF)

EndFunc
#ce