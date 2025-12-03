; ===============================================================================================================================
;
; AutoIt v3 - Password manager by Jyukat
;
; ===============================================================================================================================

#AutoIt3Wrapper_Res_HiDpi=Y ;HiDpi

#include <Crypt.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <APIFilesConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <GuiListView.au3>
#include <GuiButton.au3>
#include <StaticConstants.au3>
#include <WinAPIFiles.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>

If Not (@Compiled ) Then DllCall("User32.dll","bool","SetProcessDPIAware") ;HiDpi

_Crypt_Startup() ; Initialize the Crypt library, to improve performance
Opt("TrayMenuMode", 1) ; Enable tray menu

#region Global variables and constants
Global $username, $stored_salt, $g_hKey
Global $loginUI, $MainUI, $ReadRecGUI, $ListView, $sh, $hide

Global Const $settingfile	 = 		@LocalAppDataDir & "\OPMtest\config.ini"
Global Const $sInitDir		 = 		"::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
Global Const $name			 = 		"Open Password Manager"
Global Const $tempFolder	 = 		@TempDir & "\"
Global Const $trayico		 = 		TraySetIcon(@ScriptFullPath, 201)

Global $Height = 220, $top = 16, $left = 16

Global $restore 	= 	TrayCreateItem("Show window")
Global $reboot 		= 	TrayCreateItem("Restart application")
Global $exititem 	= 	TrayCreateItem("Exit")
#EndRegion

#include "userUtils.au3"
#include "configUtils.au3"
#include "databaseUtils.au3"
#include "clipUtils.au3"
#include "uiUtils.au3"

;Check if a user file exist
Do
	If Not FileExists($settingfile) Then
		$iMsgBoxAnswer = MsgBox(64, $name, _
								"No account found!" & @CRLF & _
								"Create a new account or import an existing one." & @CRLF & _
								"Press YES to create a new user" & @CRLF & _
								"Press NO to import a configuration file")
		Select
			Case $iMsgBoxAnswer = 6 ;Yes
				SignInWindow()
				ExitLoop
			Case $iMsgBoxAnswer = 7 ;No
				If Import() Then ExitLoop
			EndSelect
	Else
		ExitLoop
	EndIf
Until False

#Region login window
$hLoginUI =	 GUICreate("Log In", 250, 280, -1, -1)
GUISetFont(10, 400, 0, "Segoe UI")

$label_user			 =	 GUICtrlCreateLabel("User", 16, 24, 31, 21)
$in_username		 =	 GUICtrlCreateInput("", 16, 44, 217, 25, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER))
$label_masterPass	 =	 GUICtrlCreateLabel("Master Password", 16, 75, 105, 21)
$in_masterpass		 =	 GUICtrlCreateInput("", 16, 95, 217, 25, BitOR($GUI_SS_DEFAULT_INPUT, $ES_CENTER, $ES_PASSWORD))

GUISetFont(10, 700, 0, "Segoe UI")
$bnt_login		 =	 GUICtrlCreateButton("Log In", 16, 140, 217, 25)

GUISetFont(10, 400, 2, "Segoe UI")
$Label_reg		 =	 GUICtrlCreateLabel("New user? register an account now", 17, 208, 217, 21, $SS_CENTER)
GUICtrlSetColor		(-1, 0x0066CC)
GUICtrlSetCursor	(-1, 0)

GUISetFont(10, 700, 0, "Segoe UI")
$btnabout	 =	 GUICtrlCreateButton("About", 16, 238, 217, 25)

GUISetState(@SW_SHOW, $hLoginUI)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Quit()

		Case $bnt_login
			$username = GUICtrlRead($in_username)
			$masterpassword = GUICtrlRead($in_masterpass)

			If CheckUser($username, $masterpassword) Then
				$stored_salt = IniRead($settingfile, "User", "salt", "")
				$g_hKey = _Crypt_DeriveKey($masterpassword & $stored_salt, $CALG_AES_256)
				$masterpassword = Null
				ExitLoop
			Else
				MsgBox(16, "Error", "Username or Master Password not correct.")
			EndIf

		Case $Label_reg
			SignInWindow()

		Case $btnabout
			About()

		Local $msg = TrayGetMsg()
			Select
			Case $msg = $restore
				GUISetState(@SW_SHOW, $loginUI)
			Case $msg = $exititem
				Quit()
			Case $msg = $reboot
				Reboot()
			EndSelect
	EndSwitch
WEnd

GUIDelete($hLoginUI)
#EndRegion

WinMain()

Func WinMain()
	$MainUI		 =	 GUICreate("Welcome " & $username, 490, 420, -1, -1)
	$Menu		 =	 GUICtrlCreateMenu("&Menù")
	$New		 =	 GUICtrlCreateMenuItem("Add account" & @TAB & "Ctrl+N", $Menu)
	$PassGen	 =	 GUICtrlCreateMenuItem("Password Generator" & @TAB & "Ctrl+1", $Menu)
	$Settings	 =	 GUICtrlCreateMenuItem("Settings" & @TAB & "Ctrl+Space", $Menu)
	$About		 =	 GUICtrlCreateMenuItem("About", $Menu)
	$ListView	 = 	 GUICtrlCreateListView("", 2, 2, 485, 320)
	_GUICtrlListView_SetExtendedListViewStyle($ListView, $LVS_EX_FULLROWSELECT + $LVS_EX_DOUBLEBUFFER)

	; Add columns
	_GUICtrlListView_InsertColumn($ListView, 0, "Name", 160)
	_GUICtrlListView_InsertColumn($ListView, 1, "Username", 160)
	_GUICtrlListView_InsertColumn($ListView, 2, "Email", 160)

	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

	$addRec	= GUICtrlCreateButton("Add Record", 220, 344, 120, 33)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

	$backUp	= GUICtrlCreateButton("Backup", 16, 344, 120, 33)
	GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

	UpdateList() ;popola la lista

	; Crea menu contestuale
	Global $ContextMenu = GUICtrlCreateContextMenu($ListView)
	Global $MenuItem_Open = GUICtrlCreateMenuItem("Open", $ContextMenu)
	Global $MenuItem_Modify = GUICtrlCreateMenuItem("Add Fields", $ContextMenu)
	GUICtrlCreateMenuItem("", $ContextMenu) ; Separatore
	Global $MenuItem_Copy = GUICtrlCreateMenuItem("Copy Password", $ContextMenu)
	GUICtrlCreateMenuItem("", $ContextMenu) ; Separatore
	Global $MenuItem_Delete = GUICtrlCreateMenuItem("Delete Account", $ContextMenu)

	GUISetState(@SW_SHOW, $MainUI)
	GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY") ; Double Click Message

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				Quit()

			Case $MenuItem_Open
				ReadFields(ListView_Get_Selected_Item())
				UpdateList()

			Case $MenuItem_Modify
				AddField(ListView_Get_Selected_Item())

			Case $MenuItem_Copy
				$accountSelected = IniReadSection($settingfile, ListView_Get_Selected_Item())
				$password = $accountSelected[3][1] ; $accountSelected[3][1] Account Password field
				Clippa($password)
				$password = Null

			Case $MenuItem_Delete
				RemoveAccount(ListView_Get_Selected_Item())
				UpdateList()

			Case $New, $addRec
				NewAccountUI()
				UpdateList()

			Case $PassGen
				PasswordGeneratorUI()

			Case $Settings
				SettingUI()

			Case $About
				About()

			Case $backUp
				Backup()

		EndSwitch

		Local $msg = TrayGetMsg()
		Select
			Case $msg = $restore
				GUISetState(@SW_SHOW, $MainUI)
			Case $msg = $exititem
				Quit()
			Case $msg = $reboot
				Reboot()
		EndSelect
	WEnd

EndFunc

Func AddToStartup($vSwitch) ; Run on windows startup working on winXP and later.
	Local $ShortcutFile = @StartupDir &"\"& $name &".lnk"

	If IsChecked($vSwitch) Then
		; Crea il collegamento
		FileCreateShortcut(@ScriptFullPath, $ShortcutFile)
		Return True
    Else
		FileDelete($ShortcutFile)
		Return False
	EndIf

EndFunc

Func Reboot()
	_Crypt_DestroyKey($g_hKey) 	; Destroy Key
	_Crypt_Shutdown() 		   	; Shutdown the crypt library.
	Run (@ScriptFullPath)		; Call itself
	Exit
EndFunc

Func Quit()
	Local $iMsgBoxAnswer = MsgBox(36, "Exit?", "Are you sure?")
	Select
		Case $iMsgBoxAnswer = 6 ;Sì
			If $g_hKey <> Null Then _Crypt_DestroyKey($g_hKey) ; Destroy Key
			_Crypt_Shutdown() ; Shutdown the crypt library.
			Exit
	EndSelect
EndFunc