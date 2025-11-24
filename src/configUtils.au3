; ===============================================================================================================================
;
; AutoIt v3 - Password manager by Jyukat
; Modified in 21/11/2025
;
; ===============================================================================================================================

#include-once

; #FUNCTION# ====================================================================================================================
; Name ..........: _Import
; Description ...: Import the configuration file
; Syntax ........: _Import()
; Parameters ....:
; Return values .: Boolean
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Import() ;Importa file config

	; Create a constant variable in Local scope of the message to display in FileOpenDialog
	Local Const $sMess = "Select the configuration account file"

	; Display an open dialog to select a list of file(s).
	Local $sFileOpenDialog = FileOpenDialog($sMess, @DocumentsCommonDir & "\", "config (*.dat;*.ini)", $FD_FILEMUSTEXIST)
	If @error Then
		; Display the error message.
		MsgBox($MB_SYSTEMMODAL, "Error", "No file selected!")

		; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
		FileChangeDir(@ScriptDir)
		Return False
	Else
		; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
		FileChangeDir(@ScriptDir)

		; Replace instances of "|" with @CRLF in the string returned by FileOpenDialog.
		$sFileOpenDialog = StringReplace($sFileOpenDialog, "|", @CRLF)

		FileCopy($sFileOpenDialog, $settingfile, $FC_OVERWRITE + $FC_CREATEPATH)

		; Display the list of selected files.
		MsgBox($MB_SYSTEMMODAL, "Success", "The configuration account file was imported successfully!")
		Return True
	EndIf
EndFunc   ;==>_Import

; #FUNCTION# ====================================================================================================================
; Name ..........: _Export
; Description ...: Export the configuration file
; Syntax ........: _Export()
; Parameters ....:
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Export() ;Esporta file config
	; Create a constant variable in Local scope of the message to display in FileSaveDialog.
	Local Const $sMessage = "Choice the file name"

	; Display a save dialog to select a file.
	Local $sFileSaveDialog = FileSaveDialog($sMessage, $sInitDir, "settings (*.ini)", $FD_PATHMUSTEXIST)
	If @error Then
		; Display the error message.
		MsgBox($MB_SYSTEMMODAL, "", "No file saved.")
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

		FileCopy($settingfile, $sFileSaveDialog, $FC_OVERWRITE)
		; Display the saved file.
		MsgBox($MB_SYSTEMMODAL, "", "You saved the following file:" & @CRLF & $sFileSaveDialog)
	EndIf

EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _backup
; Description ...: Create a backup of the configuration file
; Syntax ........: _backup()
; Parameters ....: None
; Return values .: None
; Author ........: Jyukat
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _backup()
	; Create a constant variable in Local scope of the message to display in FileSelectFolder.
	Local Const $sMessage_1 = "Choice where to save the backup file"

	; Display an open dialog to select a file.
	Local $sFileSelectFolder = FileSelectFolder($sMessage_1, "")
	If @error Then
		; Display the error message.
		MsgBox($MB_SYSTEMMODAL, "", "No folder selected!")
	Else
		Local $sTempFile_1 = _TempFile($sFileSelectFolder & "\", "backup_" & @HOUR & "-" & @MIN & "-" & @SEC, ".dat", Default)
		FileCopy($settingfile, @TempDir & "\tmpbak\", $FC_OVERWRITE + $FC_CREATEPATH)
		FileMove(@TempDir & "\tmpbak\settings.ini", $sTempFile_1, $FC_CREATEPATH)
		FileDelete(@TempDir & "\tmpbak\settings.ini")
		Sleep(200)
		ShellExecute($sFileSelectFolder)
	EndIf

EndFunc
