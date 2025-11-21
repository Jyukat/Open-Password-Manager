#comments-start

	AutoIt v3 - Password manager by Jyukat
	Created in 21/11/2025

#comments-end

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

Opt("TrayMenuMode", 1)

;Dichiaro le variabili e le costanti globali
#region variables and constants
Global $userreg, $masterpassreg, $login, $username, $masterpass, $user, $masterkey, $nameuser
Global $MainUI, $loginUI, $List1, $vListItem, $insrec, $Checkbox1, $Checkbox2, $recName, $recName1
Global $recValue, $recValue1, $sh, $hide, $ReadRecGUI, $sAccount, $sEmail, $sUser, $sPass, $attdisatt
Global $avvcheck, $key

Global Const $settingfile	 = 		@LocalAppDataDir & "\OPM\data\config\settings.ini"
Global Const $sInitDir		 = 		"::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
Global Const $name			 = 		"Open Password Manager"
Global Const $tempFolder	 = 		@TempDir & "\"
Global Const $Height		 = 		220, $top = 16, $left = 16
Global Const $trayico		 = 		TraySetIcon(@ScriptFullPath, 201)

Global $restore 	= 	TrayCreateItem("Show window")
Global $reboot 		= 	TrayCreateItem("Restart application")
Global $exititem 	= 	TrayCreateItem("Exit")


Global Enum $NARRAY, $FIELD1, $FIELD2, $VALUE1, $VALUE2 ;~ array size, first field, second field, first value, second value
Global $aRead[5]
#EndRegion

_Crypt_Startup() ; Initialize the Crypt library

_login()

Func _login() ;UI Login

	Do
		;Check if a user file exist, else i ask to register
		If Not FileExists($settingfile) Then
			$iMsgBoxAnswer = MsgBox(262196, $name, "No account found!" & @CRLF & @CRLF & _
					"Create a new account or import an existing one." & @CRLF & "Press YES to create a new account" & _
					@CRLF & "Press NO  to import a configuration file account")
			Select
				Case $iMsgBoxAnswer = 6 ;Yes
					_reg()
					_login()
				Case $iMsgBoxAnswer = 7 ;No
					_Import()
					_login()
				EndSelect
		Else
			ExitLoop
		EndIf
	Until False

	$loginUI = GUICreate("Sign In", 250, 290, -1, -1)
	GUISetFont(10, 400, 0, "Segoe UI")

	$Label1		 =	 GUICtrlCreateLabel("User", 16, 24, 31, 21)
	$username	 =	 GUICtrlCreateInput("", 16, 48, 217, 25, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
	GUICtrlSetFont(-1, 10, 400, 2, "Segoe UI")

	$Label2		 =	 GUICtrlCreateLabel("Master Password", 16, 88, 105, 21)
	$masterpass	 =	 GUICtrlCreateInput("", 16, 112, 217, 25, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_PASSWORD))
	GUICtrlSetFont(-1, 10, 400, 2, "Segoe UI")

	$sign		 =	 GUICtrlCreateButton("Sign In", 16, 168, 217, 25, $BS_DEFPUSHBUTTON)
	$reg		 =	 GUICtrlCreateLabel("New user? register an account now", 17, 208, 217, 21, $SS_CENTER)
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetFont(-1, 10, 400, 4, "Segoe UI")
	GUICtrlSetColor(-1, 0x0066CC)

	$btnabout	 =	 GUICtrlCreateButton("About", 16, 248, 217, 25)


	GUISetState(@SW_SHOW, $loginUI)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				_esci()
			Case $sign ;$sign
				_checkreg(GUICtrlRead($username), GUICtrlRead($masterpass))
				If @error = "2" Then
					MsgBox(262160, $name, "Incorrect User and Password, Retry please...")
				ElseIf @error = "1" Then
					MsgBox(16, "Errore", "Insert User and Password.")
				Else
					$nameuser = GUICtrlRead($username)
					$key = GUICtrlRead($masterpass)
					GUIDelete($loginUI)
					ExitLoop
				EndIf
			Case $reg
				_reg()
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
	_winmain()

EndFunc   ;==>_login


;~ funzioni interfaccia
Func _winmain() ;Interfaccia principale

	$MainUI		 =	 GUICreate("Welcome " & $nameuser, 426, 500, @DesktopWidth - 260, @DesktopHeight - 380)
	$Menu		 =	 GUICtrlCreateMenu("&Menù")
	$new		 =	 GUICtrlCreateMenuItem("New" & @TAB & "Shift+Ctrl+F17", $Menu)
	$settings	 =	 GUICtrlCreateMenuItem("Settings" & @TAB & "Ctrl+Space", $Menu)
	$about		 =	 GUICtrlCreateMenuItem("About", $Menu)
	$List1		 =	 GUICtrlCreateList("", 0, 0, 425, 329)
	GUICtrlSetData(-1, "")
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

	$addRec	= GUICtrlCreateButton("Add Record", 224, 344, 177, 33)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

	$backUp	= GUICtrlCreateButton("Backup", 16, 344, 177, 33)
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

Func _updategui() ;Aggiorna la GUI principale

	;Flush lista
	GUICtrlSetData($List1, "")
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
		MsgBox(16, "Error", "Deletetion or setting file was moved")
	EndIf

EndFunc   ;==>_updategui

Func _settingGUI() ;Interfaccia Impostazioni

$Impostazioni = GUICreate("Settings", 554, 492, -1, -1, -1, BitOR($WS_EX_TOOLWINDOW,$WS_EX_WINDOWEDGE), $MainUI)
GUISetFont(12, 400, 0, "Segoe UI")
GUICtrlSetColor(-1, 0x0066CC)

$groupsett	 =	 GUICtrlCreateGroup("Export / Import Configuration file account", 16, 112, 521, 121, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
$import		 =	 GUICtrlCreateButton("Import", 32, 192, 153, 30)
GUICtrlSetColor(-1, 0x0066CC)

$export	= GUICtrlCreateButton("Export", 368, 192, 153, 30)
GUICtrlSetColor(-1, 0x0066CC)

$Input1	= GUICtrlCreateInput("(cooming soon)", 32, 152, 489, 29)
GUICtrlSetColor(-1, 0x0066CC)
GUICtrlCreateGroup("", -99, -99, 1, 1)

$avv	 =	 GUICtrlCreateGroup("Startup", 16, 16, 521, 81, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
$avvLab	 =	 GUICtrlCreateLabel("Add to Windows Startup", 24, 48, 189, 25)
GUICtrlSetColor(-1, 0x0066CC)

$avvcheck = GUICtrlCreateCheckbox("", 224, 48, 17, 25)
GUICtrlSetTip(-1, "Yes / No")

$attdisatt = GUICtrlCreateLabel("", 256, 48, 78, 25)

	If FileExists(@StartupDir &"\"& $name &".lnk") Then
		GUICtrlSetState($avvcheck, $GUI_CHECKED)
		GUICtrlSetData($attdisatt,"Activated")
		GUICtrlSetColor($attdisatt, 0x008000)
	Else
		GUICtrlSetData($attdisatt, "Disactived")
		GUICtrlSetColor(-1, 0xFF0000)
	EndIf

GUICtrlCreateGroup("", -99, -99, 1, 1)

$Group1	 =	 GUICtrlCreateGroup("Change Master Password (cooming soon)", 16, 248, 521, 201)
GUICtrlSetColor(-1, 0x0066CC)

$Label4		 =	 GUICtrlCreateLabel("Old Password", 32, 288, 128, 25)
$Input2		 =	 GUICtrlCreateInput("Input2", 160, 288, 361, 29, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
$Label5		 =	 GUICtrlCreateLabel("New Password", 32, 328, 121, 25)
$Input3		 =	 GUICtrlCreateInput("Input2", 160, 328, 361, 29, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
$Label6		 =	 GUICtrlCreateLabel("Repeat Password", 32, 368, 115, 25)
$Input4		 =	 GUICtrlCreateInput("Input2", 160, 368, 361, 29, BitOR($GUI_SS_DEFAULT_INPUT,$ES_PASSWORD))
$changePass	 =	 GUICtrlCreateButton("Change Master Password", 168, 408, 249, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)

GUISetState(@SW_SHOW, $Impostazioni)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			GUISwitch($MainUI)
			ExitLoop
		Case $import
			_Import()
			_reboot()
		Case $export
			_Export()
		Case $avvcheck
			If AddToStartup($avvcheck) Then
				GUICtrlSetData($attdisatt, "Activated")
				GUICtrlSetColor($attdisatt, 0x008000)
			Else
				GUICtrlSetData($attdisatt, "Disactived")
				GUICtrlSetColor($attdisatt, 0xFF0000)
			EndIf
		Case $changePass
			MsgBox("","Cooming soon","Function not implemented")
	EndSwitch
WEnd

GUIDelete($Impostazioni)

EndFunc

Func _IsChecked($idControlID) ;Controlla se le checkbox sono spuntate o meno
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

Func _about() ;About

Local $iOldOpt = Opt("GUICoordMode", 1)

Local $aboutUI = GUICreate("About", 588, 146, 192, 124, -1, $WS_EX_TOOLWINDOW)
$Icon1 = GUICtrlCreateIcon(300, -1, 8, 8, 129, 129)
$appnamelb = GUICtrlCreateLabel("Open Password Manager", 224, 8, 256, 32)
GUICtrlSetFont(-1, 16, 400, 0, "Segoe UI")

$createdbylb = GUICtrlCreateLabel("Created by Giuseppe Catania a.k.a. hacktooth", 144, 48, 268, 19)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

$reasonlb = GUICtrlCreateLabel("Reasons: too boored too poor to pay any other password manager service", 144, 72, 424, 19)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

$sourcecodelb = GUICtrlCreateLabel("Source code available on github.com/Jyukat/Open-Password-Manager", 144, 96, 424, 19)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

$Label1 = GUICtrlCreateLabel("Version 0.9b", 504, 120, 76, 19)
GUICtrlSetFont(-1, 8, 400, 0, "Segoe UI")
GUISetState(@SW_SHOW, $aboutUI)

While 1

;animations
For $y = 150 To - 110 Step -0.5
	GUICtrlSetPos($appnamelb, 224, $y)
	GUICtrlSetPos($createdbylb, 144, $y + 40)
	GUICtrlSetPos($reasonlb, 144, $y + 64)
	GUICtrlSetPos($sourcecodelb, 144, $y + 88)
	Sleep(10)
	If GUIGetMsg() == $GUI_EVENT_CLOSE Then ExitLoop 2
next
Sleep (1000)
WEnd

Opt("GUICoordMode", $iOldOpt)

GUIDelete($aboutUI)

EndFunc   ;==>_about



;funzioni di criptazione
Func _checkhashdata($skey)

	Local $vData = ""
	Local $bPasswordHash = IniRead($settingfile, "User", "key", "default")

	If _Crypt_HashData($skey, $CALG_SHA_512) = $bPasswordHash Then
		$vData = True
	Else
		$vData = False
	EndIf

	Return $vData

EndFunc

Func StringEncrypt($bEncrypt, $sData, $sPassword) ;Funzione di criptaggio

	Local $vReturn = ""

	If $sData == "" Then Return

	If $bEncrypt Then
		$vReturn = _Crypt_EncryptData($sData, $sPassword, $CALG_AES_256)
	Else
		$vReturn = BinaryToString(_Crypt_DecryptData($sData, $sPassword, $CALG_AES_256))
	EndIf

	Return $vReturn

EndFunc   ;==>StringEncrypt


;~ funzioni clipboard
Func _clippa($field) ;Copia nella clipboard
	ClipPut(StringEncrypt(False, $field, $key))
	AdlibRegister(_resetclip, 30000)
EndFunc

Func _resetclip() ;Resetta la clipboard
	ClipPut(Null)
	AdlibUnRegister(_resetclip)
EndFunc



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



#cs
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

Func _RandomString($iLength)
    Local $sResult = ""
    Local $sChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@/"
    For $i = 1 To $iLength
        $sResult &= StringMid($sChars, Random(1, StringLen($sChars), 1), 1)
    Next
    Return $sResult
EndFunc
#ce