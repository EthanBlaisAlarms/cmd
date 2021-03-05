'EBA Command Center 7.3
'Copyright EBA Tools 2021
'
'NOTICE:
'Editing the script below is a violation of EBA Command Center terms of service.
'If you wish to make any modifications, you must first contact ethanblaisalarms@gmail.com for approval.
'Want more info about EBA Command Center? Check the bottom of this script.
Option Explicit
On Error Resume Next

'Variables - Objects
Dim fs : Set fs = CreateObject("Scripting.FileSystemObject")
Dim cmd : Set cmd = CreateObject("Wscript.shell")
Dim runAdmin : Set runAdmin = CreateObject("Shell.Application")
Dim WMI : Set WMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
Dim objHttps : Set objHttps = CreateObject("MSXML2.XMLHTTP.6.0")
Dim sys,forVar,objShort,objOS

'Variables - Constants
Const ver = 7.3
Const setNum = 2

'Variables - Dimmed Constants
Dim programLoc
Dim nls : nls = vblf & vblf
Dim dataLoc : dataLoc = cmd.ExpandEnvironmentStrings("%APPDATA%") & "\EBA"
Dim scriptLoc : scriptLoc = Wscript.ScriptFullName
Dim scriptDir :  scriptDir = fs.GetParentFolderName(scriptLoc)
Dim line : line = vbLf & "---------------------------------------" & vbLf
Dim logDir : logDir = dataLoc & "\EBA.log"
Dim startupType : startupType = "install"
Dim title : title = "EBA Command Center Debug"
Dim desktop : desktop = cmd.SpecialFolders("AllUsersDesktop")
Dim startMenu : startMenu = cmd.SpecialFolders("AllUsersStartMenu") & "\EBA"
Dim isAdmin : isAdmin = True
Dim htmlContent

If foldExists("C:\Program Files (x86)") Then
	programLoc = "C:\Program Files (x86)\EBA"
Else
	programLoc = "C:\Program Files\EBA"
End If

'Variables - System Defined Strings
Dim exeValue : exeValue = "eba.null"
Dim exeValueExt : exeValueExt = "eba.null"
Dim status : status = "EBA Command Center"
Dim nowTime,nowDate,logData,data,fileDir

'Variables - Web Defined Strings
Dim curVer
Dim curSetNum

'Variables - User Defined Strings
Dim logIn : logIn = "false"
Dim logInType : logInType = "false"
Dim uName,pWord,eba,importData

'Variables - Boolean and Integers
Dim missFiles : missFiles = False
Dim logging : logging = False
Dim isDev : isDev = False
Dim saveLogin : saveLogin = False
Dim shutdownTimer : shutdownTimer = 10
Dim secureShutdown : secureShutdown = False
Dim progress : progress = 0
Dim isInstalled : isInstalled = False
Dim skipDo : skipDo = False

'Variables - Arrays
Dim temp(9),count(3),auth(5),lines(30)
Call clearTemps
Call clearCounts
Call clearLines
count(0) = 0
auth(0) = "ETHANBLAISALARMS"
auth(1) = "379-EBA-30194-ET"
auth(2) = "692-EBA-59204-JD"
auth(3) = "582-EBA-48592-HF"
auth(4) = "930-EBA-49602-KD"
auth(5) = "290-EBA-85829-YT"

cmd.RegRead("HKEY_USERS\s-1-5-19\")
If Not Err.Number = 0 Then
	isAdmin = False
Else
	isAdmin = True
End If
Err.Clear
'On Error GoTo 0

'Check OS
temp(0) = LCase(checkOS())
If Left(temp(0),18) = "microsoft windows " Then
	temp(0) = Replace(temp(0),"microsoft windows ","")
	If Left(temp(0),2) = "10" or Left(temp(0),3) = "8.1" or Left(temp(0),1) = "8" Then
		Call clearTemps
	Else
		Call giveWarn("Your operating system might not be compatible with EBA Command Center." & vblf & checkOS())
	End If
Else
	Call giveWarn("Your operating system might not be compatible with EBA Command Center." & vblf & checkOS())
End If

'Check for imports
For each forVar In Wscript.Arguments
 importData = forVar
Next

'Startup
If fExists(dataLoc & "\settings\logging.ebacmd") Then
	Call read(dataLoc & "\settings\logging.ebacmd","l")
	logging = data
Else
	logging = "true"
End If
If fExists(dataLoc & "\settings\saveLogin.ebacmd") Then
	Call read(dataLoc & "\settings\saveLogin.ebacmd","l")
	saveLogin = data
Else
	saveLogin = "false"
End If
If fExists(dataLoc & "\settings\shutdownTimer.ebacmd") Then
	Call read(dataLoc & "\settings\shutdownTimer.ebacmd","l")
	shutdownTimer = data
Else
	shutdownTimer = 10
End If

If fExists(programLoc & "\EBA.vbs") Then
	If LCase(scriptLoc) = LCase(programLoc & "\EBA.vbs") Then
		If fExists(dataLoc & "\startupType.ebacmd") Then
			Call read(dataLoc & "\startupType.ebacmd","n")
			startupType = data
		Else
			startupType = "normal"
		End If
	Else
		startupType = "update"
	End If
Else
	startupType = "install"
End If

If LCase(Right(importData, 10)) = ".ebaimport" Then
	eba = msgbox("EBA Command Center detected an import request. Review this request?",4+48,title)
	If eba = vbYes Then
		Call readLines(importData,1)
		If lines(1) = "Type: Startup Key" Then
			Call readLines(importData,2)
			If lines(2) = "Data: eba.recovery" Then
				eba = msgbox("Start EBA Command Center in recovery mode?",4+32,title)
				If eba = vbYes Then startupType = "recovery"
			Else
				Call giveError("Import file contains errors or is corrupt.")
			End If
		Elseif lines(1) = "Type: Command" Then
			Call readLines(importData,5)
			eba = msgbox("Import this command?" & line & "Name: " & lines(2) & vblf & "Type: " & lines(3) & vblf & "Target: " & lines(4) & vblf & "Require Login: " & lines(5),4+32,title)
			If eba = vbYes Then
				If fExists(dataLoc & "\Commands\" & lines(2) & ".ebacmd") Then
					Call giveError("Import failed. File already exists: " & dataLoc & "\Commands\" & lines(2) & ".ebacmd")
				Else
					fileDir = dataLoc & "\Commands\" & lines(2) & ".ebacmd"
					Call append(fileDir,lines(4))
					Call append(fileDir,lines(3))
					Call append(fileDir,lines(5))
					Call endOp("n")
				End If
			End If
		Else
			Call giveError("Import file contains errors or is corrupt.")
		End If
	End If
Elseif importData = "" Then
	importData = False
Else
	Call giveError("EBA Command Center detected an import request, but the request is invalid." & line & importData)
End If



If scriptRunning() Then
	Call giveError("EBA Command Center is already running.")
	Call endOp("s")
End If

'Run
Do
	If startupType = "normal" Then
		title = "EBA Command Center " & ver
		
		'Data File Checks
		Call dataExists(programLoc & "\EBA.vbs")
		Call dataExists(dataLoc & "\isLoggedIn.ebacmd")
		Call dataExistsW(dataLoc & "\settings\logging.ebacmd")
		Call dataExistsW(dataLoc & "\settings\saveLogin.ebacmd")
		Call dataExistsW(dataLoc & "\settings\shutdownTimer.ebacmd")
		Call dataExists(dataLoc & "\secureShutdown.ebacmd")
		Call dataExists(dataLoc & "\startupType.ebacmd")
		Call dataExistsW(dataLoc & "\Commands\admin.ebacmd")
		Call dataExists(dataLoc & "\Commands\config.ebacmd")
		Call dataExistsW(dataLoc & "\Commands\crash.ebacmd")
		Call dataExists(dataLoc & "\Commands\dev.ebacmd")
		Call dataExists(dataLoc & "\Commands\end.ebacmd")
		Call dataExistsW(dataLoc & "\Commands\export.ebacmd")
		Call dataExistsW(dataLoc & "\Commands\help.ebacmd")
		Call dataExistsW(dataLoc & "\Commands\import.ebacmd")
		Call dataExists(dataLoc & "\Commands\login.ebacmd")
		Call dataExistsW(dataLoc & "\Commands\logout.ebacmd")
		Call dataExistsW(dataLoc & "\Commands\logs.ebacmd")
		Call dataExistsW(dataLoc & "\Commands\read.ebacmd")
		Call dataExistsW(dataLoc & "\Commands\refresh.ebacmd")
		Call dataExistsW(dataLoc & "\Commands\run.ebacmd")
		Call dataExistsW(dataLoc & "\Commands\shutdown.ebacmd")
		Call dataExistsW(dataLoc & "\Commands\uninstall.ebacmd")
		Call dataExistsW(dataLoc & "\Commands\write.ebacmd")
		
		'Get data from EBA Command Center website
		Err.Clear
		Call clearTemps
		temp(1) = 1
		Do until temp(0) = True
			objHttps.open "get", "https://ethanblaisalarms.github.io/cmd", True
			objHttps.send
			htmlContent = objHttps.responseText
			If Err.Number = 0 Then
				temp(0) = True
			End If
			If temp(1) = 5 Then
				Call giveWarn("There was a problem contacting EBA Services, and we were unable to check for updates. Restart EBA Command Center or check your internet connection and try again.")
				htmlContent = line & vblf & ver
				temp(0) = True
			End If
			wscript.sleep 200
			temp(1) = temp(1) + 1
		Loop
		Err.Clear
		Call write(dataLoc & "\htmlData.ebacmd",htmlContent)
		Call readLines(dataLoc & "\htmlData.ebacmd",4)
		fs.DeleteFile(dataLoc & "\htmlData.ebacmd")
		curVer = CDbl(lines(4))
		If ver < curVer Then
			Call giveNote("An update for EBA Command Center is available! Download the update using the command 'update'.")
		End If
		If Not missFiles = false Then
			skipDo = True
			eba = msgbox("EBA Command Center did not start correctly. Open recovery options?",4+48,title)
			If eba = vbYes Then
				eba = LCase(inputbox("Select recovery options:" & line & "'START': Bypass this menu and start EBA Command Center" & vblf & "'RETRY': Restart EBA Command Center" & vblf & "'RECOVERY': Start EBA Command Center in Recovery Mode." & vblf & "'AUTO': Start automatic repair.",title))
				If eba = "retry" Then
					Call endOp("r")
				Elseif eba = "recovery" Then
					startupType = eba
					skipDo = True
				Elseif eba = "auto" Then
					startupType = "repair"
					skipDo = True
				Elseif eba = "start" Then
					eba = msgbox("Warning:" & line & "EBA Command Center didnt start correctly. We recommend running recovery options instead of starting. Continue anyways?",4+48,title)
					If eba = vbYes Then skipDo = False
				End If
			Else
				Call endOp("c")
			End If
		End If
		
		If skipDo = False Then
			
			'Startup
			If Not fExists(logDir) Then
				Call log("Log File Created")
			End If
			
			Call read(dataLoc & "\secureShutdown.ebacmd","l")
			secureShutdown = data
			
			If saveLogin = "false" Then Call write(dataLoc & "\isLoggedIn.ebacmd","" & vblf & "")
			
			If fExists(dataLoc & "\susActivity.ebacmd") Then
				Call read(dataLoc & "\susActivity.ebacmd","n")
				Call giveWarn("We cannot start EBA Command Center due to suspicious activity. The last time EBA Command Center was used, the following event happened:" & line & data & line & "Please login to the account that was created on setup on the next screen.")
				Do until Not logIn = "false"
					eba = inputbox("Enter the username that was created on setup:",title)
					If fExists(dataLoc & "\Users\" & eba & ".ebacmd") Then
						Call readLines(dataLoc & "\Users\" & eba & ".ebacmd",2)
						If lines(2) = "owner" Then
							pWord = inputbox("Enter password:",title)
							If pWord = lines(1) Then
								logIn = eba
							Else
								Call giveError("Password is incorrect.")
							End If
						Else
							Call giveWarn("That username exists, but is not the account that was created on setup.")
						End If
					Else
						Call giveError("That username does not exist.")
					End If
				Loop
				fs.DeleteFile(dataLoc & "\susActivity.ebacmd")
				Call endOp("n")
			End If
			If secureShutdown = "false" Then
				msgbox "EBA Command Center failed to shut down correctly last time it was used. Make sure you shut down EBA Command Center correctly next time!", 48, "EBA Crash Handler"
				Call endOp("n")
			End If
			
			'EBA Command Center Runtime
			eba = msgbox("Start " & title & "?", 4+32, title)
			If eba = vbNo Then Call endOp("c")
			Call log(title & " started up")
			Call write(dataLoc & "\secureShutdown.ebacmd","false")
		End If
		
		Do
			If skipDo = True Then Exit Do
			Call dataExists(programLoc & "\EBA.vbs")
			Call dataExists(dataLoc & "\isLoggedIn.ebacmd")
			Call dataExists(dataLoc & "\secureShutdown.ebacmd")
			Call dataExists(dataLoc & "\startupType.ebacmd")
			Call dataExists(dataLoc & "\Commands\config.ebacmd")
			Call dataExists(dataLoc & "\Commands\dev.ebacmd")
			Call dataExists(dataLoc & "\Commands\end.ebacmd")
			Call dataExists(dataLoc & "\Commands\login.ebacmd")
			
			If Not missFiles = false Then
				eba = msgbox("EBA Command Center ran into a problem it couldn't handle. We recommend closing EBA Command Center to prevent damage to EBA data. Close now?",4+16,"EBA Crash Handler")
				If eba = vbYes Then
					Call endOp("c")
				End If
			End If
			Call readLines(dataLoc & "\isLoggedIn.ebacmd",2)
			logIn = lines(1)
			loginType = lines(2)
			If logIn = "" Then
				status = "Not Logged In"
			Else
				status = "Logged in as " & logIn
			End If
			
			
			
			'User Input
			eba = LCase(inputbox("Enter Command Below:" & vblf & "EBA" & line & status, title))
			exeValue = "eba.null"
			If eba = "" Then eba = "end"
			If fExists(dataLoc & "\Commands\" & eba & ".ebacmd") Then
				Call readLines(dataLoc & "\Commands\" & eba & ".ebacmd",3)
				If LCase(lines(2)) = "short" Then
					eba = lines(1)
					If fExists(dataLoc & "\Commands\" & lines(1) & ".ebacmd") Then
						Call readLines(dataLoc & "\Commands\" & lines(1) & ".ebacmd",3)
					Else
						Call giveError("That command contains invalid data or is corrupt.")
					End If
				End If
				If LCase(lines(3)) = "no" Then
					temp(0) = True
				Elseif logInType = "admin" or logInType = "owner" Then
					temp(0) = True
				Else
					temp(0) = False
				End If
				If LCase(lines(2)) = "exe" Then
					If temp(0) = True Then
						If InStr(lines(1)," ") Then
							exeValue = LCase(Left(lines(1),InStr(lines(1)," ")-1))
							exeValueExt = LCase(Replace(lines(1),exeValue & " ",""))
						Else
							exeValue = LCase(lines(1))
						End If
					Else
						Call giveError("That command requires a quick login to an administrator account. You can do so by running 'login'.")
					End If
				Elseif LCase(lines(2)) = "cmd" Then
					If temp(0) = True Then
						cmd.run lines(1)
					Else
						Call giveError("That command requires a quick login to an administrator account. You can do so by running 'login'.")
					End If
				Elseif LCase(lines(2)) = "file" Then
					If temp(0) = True Then
						cmd.run DblQuote(lines(1))
					Else
						Call giveError("That command requires a quick login to an administrator account. You can do so by running 'login'.")
					End If
				Elseif LCase(lines(2)) = "url" Then
					Set objShort = cmd.CreateShortcut(dataLoc & "\temp.url")
					With objShort
						.TargetPath = lines(1)
						.Save
					End With
					cmd.run DblQuote(dataLoc & "\temp.url")
				Else
					Call giveError("That command contains invalid data or is corrupt.")
				End If
			Else
				Call giveError("That command could not be found or is corrupt.")
			End If
			Call log("Command Executed: " & eba)
			
			'Execution Values
			If exeValue = "eba.admin" Then
				If isAdmin = False Then
					Call endOp("ra")
				End If
				Call giveNote("EBA Command Center is already running as administrator.")
			Elseif exeValue = "eba.config" Then
				If exeValueExt = "eba.cmd" Then
					eba = "cmd"
				Elseif exeValueExt = "eba.cmdnew" Then
					eba = "cmd"
				Elseif exeValueExt = "eba.cmdedit" Then
					eba = "cmd"
				Elseif exeValueExt = "eba.acc" Then
					eba = "acc"
				Elseif exeValueExt = "eba.accnew" Then
					eba = "acc"
				Elseif exeValueExt = "eba.accedit" Then
					eba = "acc"
				Elseif exeValueExt = "eba.logs" Then
					eba = "logs"
				Elseif exeValueExt = "eba.savelogin" Then
					eba = "savelogin"
				Elseif exeValueExt = "eba.shutdowntimer" Then
					eba = "shutdowntimer"
				Elseif exeValueExt = "eba.null" Then
					eba = LCase(inputbox("EBA Config:" & vblf & "EBA > Config" & line & status, title))
				Else
					Call giveError("Unknown Exe Value Extension." & vblf & exeValueExt)
				End If
				If eba = "cmd" Then
					If exeValueExt = "eba.cmd" or exeValueExt = "eba.null" Then
						eba = LCase(inputbox("Modify Commands:" & vblf & "EBA > Config > Commands" & line & status, title))
					Elseif exeValueExt = "eba.cmdnew" Then
						eba = "new"
					Elseif exeValueExt = "eba.cmdedit" Then
						eba = "edit"
					Else
						Call giveError("Unknown Error")
					End If
					If eba = "new" Then
						status = "This is what you will type to execute the command."
						eba = LCase(inputbox("Create Command Below:" & vblf & "EBA > Config > Commands > New" & line & status, title))
						If fExists(dataLoc & "\Commands\" & eba & ".ebacmd") Then
							Call giveError("That command already exists.")
						ElseIf inStr(1,eba,"\") > 0 Then
							Call giveWarn("""\"" is not allowed in command names!")
						Elseif inStr(1,eba,"/") > 0 Then
							Call giveWarn("""/"" is not allowed in command names!")
						Elseif inStr(1,eba,":") > 0 Then
							Call giveWarn(""":"" is not allowed in command names!")
						Elseif inStr(1,eba,"*") > 0 Then
							Call giveWarn("""*"" is not allowed in command names!")
						Elseif inStr(1,eba,"?") > 0 Then
							Call giveWarn("""?"" is not allowed in command names!")
						Elseif inStr(1,eba,"""") > 0 Then
							Call giveWarn("' "" ' is not allowed in command names!")
						Elseif inStr(1,eba,"<") > 0 Then
							Call giveWarn("""<"" is not allowed in command names!")
						Elseif inStr(1,eba,">") > 0 Then
							Call giveWarn(""">"" is not allowed in command names!")
						Elseif inStr(1,eba,"|") > 0 Then
							Call giveWarn("""|"" is not allowed in command names!")
						Else
							temp(0) = false
							temp(3) = eba
							eba = LCase(inputbox("What is the type?" & line & "'CMD': Execute a command" & vblf & "'FILE': Execute a file" & vblf & "'URL': Web shortcut" & vblf & "'SHORT': Shortcut to another command", title))
							If eba = "cmd" Then
								temp(0) = True
								temp(1) = "cmd"
								temp(2) = LCase(inputbox("Type the command to execute:",title))
							Elseif eba = "file" Then
								temp(1) = "file"
								temp(2) = LCase(inputbox("Type the target file:",title))
								If fExists(temp(2)) or foldExists(temp(2)) Then
									temp(0) = True
								Else
									Call giveError("The target file was not found.")
								End If
							Elseif eba = "url" Then
								temp(0) = True
								temp(1) = "url"
								temp(2) = LCase(inputbox("Type the URL below. Include https://",title,"https://example.com"))
							Elseif eba = "short" Then
								temp(1) = "short"
								temp(2) = LCase(inputbox("Type the target command below:",title))
								If fExists(dataLoc & "\Commands\" & temp(2) & ".ebacmd") Then
									temp(0) = True
								Else
									Call giveError("The target command was not found or is corrupt.")
								End If
							Elseif eba = "exe" Then
								temp(0) = True
								temp(1) = "exe"
								temp(2) = LCase(inputbox("Type the execution value below:",title))
							End If
							If temp(0) = False Then
								Call giveWarn("The command could not be created.")
							Else
								If temp(1) = "short" Then
									temp(4) = "no"
								Else
									eba = msgbox("Require administrator login to execute?",4+32,title)
									If eba = vbNo Then
										temp(4) = "no"
									Else
										temp(4) = "yes"
									End If
								End If
								eba = msgbox("Confirm the command:" & line & "Name: " & temp(3) & vblf & "Type: " & temp(1) & vblf & "Target: " & temp(2) & vblf & "Login Required: " & temp(4),4+32,title)
								If eba = vbNo Then
									Call giveWarn("Creation of command canceled.")
								Else
									Call log("Command Created: " & temp(3))
									Call write(dataLoc & "\Commands\" & temp(3) & ".ebacmd",temp(2) & vblf & temp(1) & vblf & temp(4) & vblf & "no")
								End If
							End If
						End If
					Elseif eba = "edit" Then
						eba = LCase(inputbox("Enter Command Below:" & vblf & "EBA > Config > Commands > Modify" & line & status, title))
						If fExists(dataLoc & "\Commands\" & eba & ".ebacmd") Then
							temp(1) = eba
							Call readLines(dataLoc & "\Commands\" & eba & ".ebacmd",4)
							temp(0) = True
							If LCase(lines(4)) = "builtin" Then
								eba = msgbox("Warning:" & line & "That is a built-in command. If you modify this command, it could mess up EBA Command Center. Continue?",4+48,title)
								If eba = vbNo Then temp(0) = False
							End If
							If temp(0) = True Then
								eba = LCase(inputbox("What do you want to modify?" & line & "'TARGET': Edit the target" & vblf & "'NAME': Rename the command" & vblf & "'LOGIN': Change login requirements" & vblf & "'DELETE': Delete the command.",title))
								If eba = "target" Then
									temp(2) = "target"
									temp(3) = LCase(inputbox("Enter new target:",title,lines(1)))
									lines(1) = temp(3)
									temp(4) = True
								Elseif eba = "name" Then
									temp(2) = "name"
									temp(3) = LCase(inputbox("Enter new name:",title,temp(1)))
									temp(4) = True
								Elseif eba = "login" Then
									temp(2) = "login"
									temp(3) = msgbox("Require login to execute?",4+32,title)
									If temp(3) = vbNo Then
										temp(3) = "no"
									Else
										temp(3) = "yes"
									End If
									lines(3) = temp(3)
									temp(4) = True
								Elseif eba = "delete" Then
									temp(2) = "delete"
									eba = msgbox("Warning:" & line & "Deleting a command cannot be undone. Delete anyways?",4+48,title)
									If eba = vbYes Then
										fs.DeleteFile(dataLoc & "\Commands\" & temp(1) & ".ebacmd")
										Call log("Command deleted: " & temp(1))
										temp(4) = True
									End If
								End If
								If temp(4) = True Then
									If Not temp(2) = "delete" Then
										eba = msgbox("Confirm command modification:" & line & "Modification: " & temp(2) & vblf & "New Value: " & temp(3),4+32,title)
										If eba = vbYes Then
											If temp(2) = "name" Then
												fs.MoveFile dataLoc & "\Commands\" & temp(1) & ".ebacmd", dataLoc & "\Commands\" & temp(3) & ".ebacmd"
												Call log("Command renamed from " & temp(1) & " to " & temp(3))
											Else
												Call write(dataLoc & "\Commands\" & temp(1) & ".ebacmd",lines(1) & vblf & lines(2) & vblf & lines(3) & vblf & lines(4))
												Call log("Command Modified: " & temp(1))
											End If
										End If
									End If
								Else
									Call giveWarn("The command could not be modified.")
								End If
							End If
						Else
							Call giveError("Command not found.")
						End If
					Else
						Call giveError("Config option not found.")
					End If
				Elseif eba = "acc" or eba = "account" Then
					If exeValueExt = "eba.acc" or exeValueExt = "eba.null" Then
						eba = LCase(inputbox("Modify Accounts:" & vblf & "EBA > Config > Accounts" & line & status, title))
					Elseif exeValueExt = "eba.accnew" Then
						eba = "new"
					Elseif exeValueExt = "eba.accedit" Then
						eba = "edit"
					Else
						Call giveError("Unknown Error")
					End If
					If eba = "new" Then
						eba = inputbox("Create a username:",title)
						uName = eba
						If fExists(dataLoc & "\Users\" & eba & ".ebacmd") Then
							Call giveError("That user already exists.")
						Elseif Len(uName) < 3 Then
							Call giveWarn("That username is too short!")
						Elseif Len(uName) > 15 Then
							Call giveWarn("That username is too long!")
						Elseif inStr(1,uName,"\") > 0 Then
							Call giveWarn("""\"" is not allowed in usernames!")
						Elseif inStr(1,uName,"/") > 0 Then
							Call giveWarn("""/"" is not allowed in usernames!")
						Elseif inStr(1,uName,":") > 0 Then
							Call giveWarn(""":"" is not allowed in usernames!")
						Elseif inStr(1,uName,"*") > 0 Then
							Call giveWarn("""*"" is not allowed in usernames!")
						Elseif inStr(1,uName,"?") > 0 Then
							Call giveWarn("""?"" is not allowed in usernames!")
						Elseif inStr(1,uName,"""") > 0 Then
							Call giveWarn("' "" ' is not allowed in usernames!")
						Elseif inStr(1,uName,"<") > 0 Then
							Call giveWarn("""<"" is not allowed in usernames!")
						Elseif inStr(1,uName,">") > 0 Then
							Call giveWarn(""">"" is not allowed in usernames!")
						Elseif inStr(1,uName,"|") > 0 Then
							Call giveWarn("""|"" is not allowed in usernames!")
						Else
							pWord = inputbox("Create a password for " & uName,title)
							If pWord = "" Then
								eba = msgbox("Continue without a password?",4+48,title)
								If eba = vbYes Then
									eba = msgbox("Make this an administrator account?",4+32+256,title)
									If eba = vbYes Then
										Call write(dataLoc & "\Users\" & uName & ".ebacmd",pWord & vblf & "admin")
										Call log("New administrator account created: " & uName)
									Else
										Call write(dataLoc & "\Users\" & uName & ".ebacmd",pword & vblf & "general")
										Call log("New account created: " & uName)
									End If
								End If
							Elseif Len(pWord) < 8 Then
								Call giveWarn("Password is too short.")
							Elseif Len(pWord) > 30 Then
								Call giveWarn("Password is too long.")
							Elseif InStr(1,lcase(pWord),"password") > 0 or Instr(1,pword,"1234") > 0 Then
								Call giveWarn("Ok, really..." & nls & "Ok, that password is too easy to figure out. Choose a strong password with a mix of letters and numbers.")
							Else
								eba = inputbox("Confirm password:",title)
								If eba = pWord Then
									eba = msgbox("Make this an administrator account?",4+32+256,title)
									If eba = vbYes Then
										Call write(dataLoc & "\Users\" & uName & ".ebacmd",pWord & vblf & "admin")
										Call log("New administrator account created: " & uName)
									Else
										Call write(dataLoc & "\Users\" & uName & ".ebacmd",pword & vblf & "general")
										Call log("New account created: " & uName)
									End If
								Else
									Call giveError("Passwords do not match.")
								End If
							End If
						End If
					Elseif eba = "edit" Then
						eba = inputbox("Enter the username:",title)
						If fExists(dataLoc & "\Users\" & eba & ".ebacmd") Then
							Call readLines(dataLoc & "\Users\" & eba & ".ebacmd",2)
							temp(0) = eba
							eba = LCase(inputbox("What do you want to modify?" & line & "'PWORD': Change password" & vblf & "'ADMIN': Change admin status" & vblf & "'DELETE': Delete account",title))
							If eba = "pword" Then
								eba = inputbox("Enter current password:",title)
								If eba = lines(1) Then
									pWord = inputbox("Create new password:",title)
									If pWord = "" Then
										eba = msgbox("Continue without a password?",4+48,title)
										If eba = vbYes Then
											Call write(dataLoc & "\Users\" & temp(0) & ".ebacmd",pWord & vblf & lines(2))
											Call log("Password changed for " & temp(0))
										End If
									Elseif Len(pWord) < 8 Then
										Call giveWarn("Password is too short.")
									Elseif Len(pWord) > 30 Then
										Call giveWarn("Password is too long.")
									Elseif InStr(1,lcase(pWord),"password") > 0 or Instr(1,pword,"1234") > 0 Then
										Call giveWarn("Ok, really..." & nls & "Ok, that password is too easy to figure out. Choose a strong password with a mix of letters and numbers.")
									Else
										eba = inputbox("Confirm password:",title)
										If eba = pWord Then
											Call write(dataLoc & "\Users\" & temp(0) & ".ebacmd",pWord & vblf & lines(2))
											Call log("Password changed for " & temp(0))
										Else
											Call giveError("Passwords did not match.")
										End If
									End If
								Else
									Call giveError("Incorrect password.")
								End If
							Elseif eba = "admin" Then
								If lines(2) = "owner" Then
									Call giveWarn("That modification cannot be applied to this account. This is the account that was created on setup.")
								Else
									eba = msgbox("Make this account an administrator?",4+32+256,title)
									If eba = vbNo Then
										Call write(dataLoc & "\Users\" & temp(0) & ".ebacmd",lines(1) & vblf & "general")
										Call log("Made " & temp(0) & " a general account.")
									Else
										Call write(dataLoc & "\Users\" & temp(0) & ".ebacmd",lines(1) & vblf & "admin")
										Call log("Made " & temp(0) & " an administrator.")
									End If
								End If
							Elseif eba = "delete" Then
								If lines(2) = "owner" Then
									Call giveWarn("That modification cannot be applied to this account. This is the account that was created on setup.")
								Else
									eba = msgbox("Confirm delete?",4+32+256,title)
									If eba = vbYes Then
										fs.DeleteFile(dataLoc & "\Users\" & temp(0) & ".ebacmd")
										Call log("Account deleted: " & temp(0))
									End If
								End If
							Else
								Call giveError("Config option not found.")
							End If
						Else
							Call giveError("Username not found.")
						End If
					Else
						Call giveError("Config option not found.")
					End If
				Elseif eba = "logs" Then
					eba = msgbox("Logs are set to " & logging & ". Would you like to enable EBA Logs? (EBA Command Center will restart)", 4+32, title)
					If eba = vbYes Then
						Call write(dataLoc & "\settings\logging.ebacmd","true")
						Call log("Logging enabled by " & logIn)
					Else
						Call write(dataLoc & "\settings\logging.ebacmd","false")
						Call log("Logging disabled by " & logIn)
					End If
					Call endOp("r")
				Elseif eba = "savelogin" Then
					eba = msgbox("Save Login are set to " & saveLogin & ". Would you like to enable Save Login? (EBA Command Center will restart)", 4+32, title)
					If eba = vbYes Then
						Call write(dataLoc & "\settings\saveLogin.ebacmd","true")
						Call log("Save Login enabled by " & logIn)
					Else
						Call write(dataLoc & "\settings\saveLogin.ebacmd","false")
						Call log("Save Login disabled by " & logIn)
					End If
					Call endOp("r")
				Elseif eba = "shutdowntimer" Then
					eba = inputbox("Shutdown Timer is currently set to " & shutdownTimer & ". Please set a new value (must be at least 0, and must be an integer). EBA Command Center will restart.",title,10)
					If eba = "" Then eba = 0
					Call checkWscript
					If CInt(eba) > -1 Then
						If Err.Number = 0 Then
							Call write(dataLoc & "\settings\shutdownTimer.ebacmd",eba)
							Call endOp("r")
						Else
							Call giveWarn("A WScript Error occurred while converting that value to an integer. Your settings were not changed.")
						End If
					Else
						Call giveWarn("That value didnt work. " & eba & " is not a positive integer.")
					End If
				Else
					Call giveError("Config option not found.")
				End If
			Elseif exeValue = "eba.crash" Then
				wscript.sleep 2500
				msgbox "EBA Command Center just crashed! Please restart EBA Command Center.",16,"EBA Crash Handler"
				Call endOp("c")
			Elseif exeValue = "eba.dev" Then
				If isDev = true Then
					isDev = false
					Call log("Dev mode disabled")
					Call giveWarn("Developer Mode has been disabled. EBA Command Center will now restart.")
					Call endOp("r")
				ElseIf isDev = false Then
					isDev = true
					title = "EBA Command Center - Developer Mode"
					Call log("Dev mode enabled")
					Call giveWarn("Developer Mode has been enabled.")
				End If
			Elseif exeValue = "eba.end" Then
				eba = msgbox("Exit EBA Command Center?",4+32,title)
				If eba = vbYes Then Call endOp("s")
			Elseif exeValue = "eba.error" Then
				Call giveWarn("WScript Errors have been enabled. If you encounter a WScript error, EBA Command Center will crash. To disable WScript Errors, restart EBA Command Center.")
				On Error GoTo 0
			Elseif exeValue = "eba.export" Then
				eba = LCase(inputbox("EBA Config:" & vblf & "EBA > Export" & line & status, title))
				If fExists(dataLoc & "\Commands\" & eba & ".ebacmd") Then
					temp(0) = eba
					eba = inputbox("Where do you want the exported file?",title,desktop)
					If foldExists(eba) Then
						Call readLines(dataLoc & "\Commands\" & temp(0) & ".ebacmd",3)
						Call write(eba & "\EBA_Export.ebaimport","Type: Command" & vblf & temp(0) & vblf & lines(2) & vblf & lines(1) & vblf & lines(3))
						Call log("Command Exported: " & temp(0))
					Else
						Call giveError("Cannot export to the given location.")
					End If
				Else
					Call giveError("Command does not exist.")
				End If
			Elseif exeValue = "eba.help" Then
				Call giveNote("The online tutorial is available at:" & vblf & "https://sites.google.com/view/ebatools/home/cmd/support")
			Elseif exeValue = "eba.import" Then
				Call giveNote("To import a file, drag and drop the .ebaimport file on the desktop icon.")
			Elseif exeValue = "eba.login" Then
				uName = inputbox("Enter your username:",title)
				If fExists(dataLoc & "\Users\" & uName & ".ebacmd") Then
					Call readLines(dataLoc & "\Users\" & uName & ".ebacmd",2)
					If Not lines(1) = "" Then
						pWord = inputbox("Enter the password:",title)
						If pWord = lines(1) Then
							Call log("Logged in: " & uName)
							Call giveNote("Logged in as " & uName)
							Call write(dataLoc & "\isLoggedIn.ebacmd",uName & vblf & lines(2))
						Else
							Call log("Failed to log in: " & uName)
							Call giveError("Incorrect Password.")
						End If
					Else
						Call log("Logged in: " & uName)
						Call giveNote("Logged in as " & uName)
						Call write(dataLoc & "\isLoggedIn.ebacmd",uName & vblf & lines(2))
					End If
				Else
					Call giveError("Username not found.")
				End If
			Elseif exeValue = "eba.logout" Then
				Call write(dataLoc & "\isLoggedIn.ebacmd","" & vblf & "")
				Call log("Logged out all accounts")
				Call giveNote("Logged out.")
			Elseif exeValue = "eba.null" Then
				exeValue = "eba.null"
			Elseif exeValue = "eba.read" Then
				If isDev = false Then
					Call giveError("This command can only be ran in EBA Developer Mode!")
				Else
					eba = inputbox("EBA > Read", title)
					If fExists(eba) Then
						Call read(eba,"n")
						Call log("File read: " & eba)
						msgbox "EBA > Read > " & eba & line & data,0,title
					Else
						Call log("Failed to read " & eba)
						Call giveError("File " & eba & " not found!")
					End If
				End If
			Elseif exeValue = "eba.refresh" Then
				If isDev = false Then
					Call giveError("This command can only be used in EBA Developer Mode!")
				Else
					eba = msgbox("EBA Command Center will restart and open in reinstall mode.", 48, title)
					Call write(dataLoc & "\startupType.ebacmd","refresh")
					Call endOp("r")
				End If
			Elseif exeValue = "eba.restart" Then
				Call endOp("r")
			Elseif exeValue = "sys.run" Then
				eba = inputbox("Enter the file path of the file you would like to run:", title)
				If fExists(eba) Then
					cmd.run DblQuote(eba)
					Call log("File Executed: " & eba)
				Else
					Call giveError(eba & " was not found on this PC.")
				End If
			Elseif exeValue = "sys.shutdown" Then
				If exeValueExt = "eba.null" Or exeValueExt = "eba.shutdown" Then
					eba = msgbox("Are you sure you want to shut down your PC? All unsaved data will be lost!", 4+32, title)
					If eba = vbYes Then
						Call write(dataLoc & "\secureShutdown.ebacmd","true")
						cmd.run "shutdown /s /t " & shutdownTimer & " /f /c ""You requested a system shutdown through EBA Command Center."""
						Call giveWarn("Your PC will shut down in " & shutdownTimer & " seconds. Press OK to cancel")
						cmd.run "shutdown /a"
						Call write(dataLoc & "\secureShutdown.ebacmd","false")
					End If
				Elseif exeValueExt = "eba.restart" Then
					eba = msgbox("Are you sure you want to restart your PC? All unsaved data will be lost!", 4+32, title)
					If eba = vbYes Then
						Call write(dataLoc & "\secureShutdown.ebacmd","true")
						cmd.run "shutdown /r /t " & shutdownTimer & " /f /c ""You requested a system restart through EBA Command Center."""
						Call giveWarn("Your PC will restart in " & shutdownTimer & " seconds. Press OK to cancel")
						cmd.run "shutdown /a"
						Call write(dataLoc & "\secureShutdown.ebacmd","false")
					End If
				Else
					Call giveError("Unknown Exe Value Extension.")
				End If
			Elseif exeValue = "eba.uninstall" Then
				If isDev = false Then
					Call giveError("This command can only be ran in EBA Developer Mode!")
				Else
					eba = msgbox("Warning:" & line & "This will unistall EBA Command Center completely! Your EBA Command Center data will be erased! Uninstallation will require a system restart. Continue?", 4+48, title)
					Call addWarn
					If eba = vbYes Then
						Call createUninstallFile
						Call giveWarn("EBA Command Center has been uninstalled. You will need to restart to finish uninstallation")
						Call endOp("c")
					End If
					Call giveNote("Uninstallation canceled!")
				End If
			Elseif exeValue = "eba.write" Then
				If isDev = false Then
					Call giveError("This command can only be ran in EBA Developer Mode!")
				Else
					eba = inputbox("EBA > Write", title)
					If fExists(eba) Then
						temp(0) = eba
						eba = inputbox("EBA > Write > " & eba,title)
						If Lcase(eba) = "cancel" Then
							Call giveNote("Operation Canceled")
						Else
							Call log("Wrote data to " & temp(0) & ": " & eba)
							Call write(temp(0),eba)
						End If
					Else
						Call log("Failed to write to " & eba)
						Call giveError("File " & eba & " not found!")
					End If
				End If
			Else
				Call giveError("The Execution Value is not valid." & vblf & exeValue)
			End If
			Call endOp("n")
		Loop
	Elseif startupType = "repair" Then
		title = "EBA Command Center " & ver & " Recovery"
		eba = msgbox("Are you sure you want to run automatic repair? Running automatic repair will reset your preferences.",4+48,title)
		If eba = vbYes Then
			If programLoc = scriptDir Then
				newFolder(programLoc & "\Plugins")
				newFolder(dataLoc)
				newFolder(dataLoc & "\Users")
				newFolder(dataLoc & "\Commands")
				newFolder(dataLoc & "\Settings")
				If foldExists(dataLoc) Then
					Call updateCommands
					Call update(dataLoc & "\isLoggedIn.ebacmd","" & vblf & "","overwrite")
					Call update(dataLoc & "\settings\logging.ebacmd","true","overwrite")
					Call update(dataLoc & "\settings\saveLogin.ebacmd","false","overwrite")
					Call update(dataLoc & "\settings\shutdownTimer.ebacmd","10","overwrite")
					Call update(dataLoc & "\secureShutdown.ebacmd","true","overwrite")
					Call update(dataLoc & "\startupType.ebacmd","firstrepair","overwrite")
					Call giveNote("Automatic repair has completed. EBA Command Center will now restart.")
					Call endOp("r")
				Else
					Call giveError("Automatic repair failed to complete. Try running it again.")
					Call endOp("r")
				End If
			Else
				Call giveError("Automatic repair cannot run because EBA Command Center is not being ran at " & programLoc)
				Call endOp("c")
			End If
		End If
		startupType = "normal"
	Elseif startupType = "install" Then
		title = "EBA Installer"
		
		If isAdmin = False Then
			Call endOp("fa")
		End If
		
		'Search for Legacy Installations
		If foldExists("C:\EBA") Then isInstalled = True
		If foldExists("C:\EBA-Installer") Then isInstalled = True
		If isInstalled = True Then
			eba = msgbox("A legacy EBA Command Center (6.1 and below) installation was found on your system. When you update, this installation will be erased. Continue?", 4+48, title)
			If eba = vbNo Then Call endOp("c")
		End If
		
		'Legal Stuff
		eba = msgbox("By installing EBA Command Center, you understand that:"& line &_
		"1. EBA Command Center is not to be used in a malicious way," & nls &_
		"2. Releasing or modifying the source code is prohibited," & nls &_
		"3. Plugins are allowed, but reproduction of plugins is prohibited (this includes EBA plugins, and third party plugins), and" & nls &_
		"4. There is a slim chance that EBA Command Center may break another program/file on your PC. Please understand we cannot be held responsible for such an event." & line &_
		"Do you understand and agree to the terms of service?", 4+64, title)
		If eba = vbNo Then
			Call giveError("You cannot install EBA Command Center because you did not agree to the terms of service.")
			Call endOp("c")
		End If
		
		'Install Setup
		eba = msgbox("EBA Command Center " & ver & " is ready to install! We'll install to:" & vblf & programLoc & nls & "Is this ok?", 4+64, title)
		If eba = vbNo Then Call endOp("c")
		eba = msgbox("EBA Command Center data will be stored at " & vblf & dataLoc & nls & "Is this OK?",4+64,title)
		If eba = vbNo Then Call endOp("c")
		
		'Folders
		If foldExists("C:\EBA") Then fs.DeleteFolder("C:\EBA")
		If foldExists("C:\EBA-Installer") Then fs.DeleteFolder("C:\EBA-Installer")
		If foldExists(programLoc) Then fs.DeleteFolder(programLoc)
		If foldExists(dataLoc) Then fs.DeleteFolder(dataLoc)
		newFolder(programLoc)
		newFolder(programLoc & "\Plugins")
		newFolder(dataLoc)
		newFolder(dataLoc & "\Users")
		newFolder(dataLoc & "\Commands")
		newFolder(dataLoc & "\Settings")
		
		'Create Command Files
		Call updateCommands
		
		'Data Files
		Call update(dataLoc & "\isLoggedIn.ebacmd","" & vblf & "","")
		Call update(dataLoc & "\settings\logging.ebacmd","true","")
		Call update(dataLoc & "\settings\saveLogin.ebacmd","false","")
		Call update(dataLoc & "\settings\shutdownTimer.ebacmd","10","")
		Call update(dataLoc & "\secureShutdown.ebacmd","true","")
		
		'Apply Setup Options
		If Not fExists(logDir) Then Call log("Log File Created")
		Call log("Installed EBA Command Center " & ver)
		Call update(dataLoc & "\startupType.ebacmd","firstrun","overwrite")
		
		'Installation Complete
		eba = msgbox("Create a Desktop icon?", 4+32, title)
		If eba = vbYes Then
			Set objShort = cmd.CreateShortcut(desktop & "\EBA Command.lnk")
			With objShort
				.TargetPath = programLoc & "\EBA.vbs"
				.IconLocation = "C:\Windows\System32\imageres.dll, 5323"
				.Save
			End With
		End If
		eba = msgbox("Create a Start Menu icon?", 4+32, title)
		If eba = vbYes Then
			newFolder(startMenu)
			Set objShort = cmd.CreateShortcut(startMenu & "\EBA Command.lnk")
			With objShort
				.TargetPath = programLoc & "\EBA.vbs"
				.IconLocation = "C:\Windows\System32\imageres.dll, 5323"
				.Save
			End With
		End If
		eba - msgbox("EBA Command Center has finished installing! Would you like to start setup?",4+64,title)
		If eba = vbYes Then Call endOp("r")
		Call endOp("c")
	Elseif startupType = "update" Then
		title = "EBA Updater"
		
		If isAdmin = False Then
			Call endOp("fa")
		End If
		
		'Legal Stuff
		eba = msgbox("By updating EBA Command Center, you understand that:"& nls &_
		"1. EBA Command Center is not to be used in a malicious way," & nls &_
		"2. Releasing or modifying the source code is prohibited," & nls &_
		"3. Plugins are allowed, but reproduction of plugins is prohibited (this includes EBA plugins, and third party plugins), and" & nls &_
		"4. There is a slim chance that EBA Command Center may break another program/file on your PC. Please understand we cannot be held responsible for such an event." & line &_
		"Do you understand and agree to the terms of service?", 4+64, title)
		If eba = vbNo Then
			Call giveError("You cannot update EBA Command Center because you did not agree to the terms of service.")
			Call endOp("c")
		End If
		
		'Folders
		newFolder(programLoc)
		newFolder(programLoc & "\Plugins")
		newFolder(dataLoc)
		newFolder(dataLoc & "\Users")
		newFolder(dataLoc & "\Commands")
		newFolder(dataLoc & "\Settings")
		
		'Create Command Files
		Call updateCommands
		
		'Data Files
		Call update(dataLoc & "\isLoggedIn.ebacmd","" & vblf & "","")
		Call update(dataLoc & "\settings\logging.ebacmd","true","")
		Call update(dataLoc & "\settings\saveLogin.ebacmd","false","")
		Call update(dataLoc & "\settings\shutdownTimer.ebacmd","10","")
		Call update(dataLoc & "\secureShutdown.ebacmd","true","")
		If fExists(dataLoc & "\settings.ebacmd") Then fs.DeleteFile(dataLoc & "\settings.ebacmd")
		
		'Apply Setup Options
		Call log("Installed EBA Command Center " & ver & " as an update")
		Call update(dataLoc & "\startupType.ebacmd","normal","overwrite")
		Call giveNote("EBA Command Center " & ver & " was successfully installed!")
		Call endOp("s")
	Elseif startupType = "refresh" Then
		
		If isAdmin = False Then
			Call endOp("fa")
		End If
		
		eba = msgbox("Reinstalling EBA Command Center can fix issues you might have. On the next screen, you will choose what to keep. Continue with reinstallation?", 4+48, title)
		If eba = vbNo Then
			Call write(dataLoc & "\startupType.ebacmd","null")
			Call endOp("r")
		End If
		
		temp(0) = "no"
		temp(1) = "no"
		eba = LCase(inputbox("Enter reinstallation type:" & line & "'KEEP': Preserves users, commands, and settings." & vblf & "'REFRESH': Preserves commands and settings." & vblf & "'FULL': Does not preserve data.",title,"refresh"))
		If eba = "keep" or eba = "refresh" or eba = "full" Then
			If eba = "keep" Then
				temp(0) = "yes"
				temp(1) = "yes"
			Elseif eba = "refresh" Then
				temp(1) = "yes"
			End If
			eba = msgbox("Preserved data:" & line & "Script: Yes" & vblf & "Users: " & temp(0) & vblf & "Plugins: No" & vblf & "Commands: " & temp(1) & vblf & "Settings: " & temp(1) & line & "Start reinstallation?", 4+48, title)
			If eba = vbNo Then endOp("c")
		Else
			Call giveError("Invalid value.")
		End If
		
		eba = msgbox("Warning:" & line & "Customized reinstallations are not available at this time. If you continue with reinstallation, you will lose all data. Proceed?",4+48,title)
		If eba = vbNo Then Call endOp("c")
		
		'Prep
		fs.MoveFile scriptLoc, "C:\eba.temp"
		If foldExists(programLoc) Then fs.DeleteFolder(programLoc)
		If foldExists(dataLoc) Then fs.DeleteFolder(dataLoc)
		newFolder(programLoc)
		fs.MoveFile "C:\eba.temp", programLoc & "\EBA.vbs"
		
		'Folders
		newFolder(programLoc & "\Plugins")
		newFolder(dataLoc)
		newFolder(dataLoc & "\Users")
		newFolder(dataLoc & "\Commands")
		newFolder(dataLoc & "\Settings")
		
		'Create Command Files
		Call updateCommands
		
		'Data Files
		Call update(dataLoc & "\isLoggedIn.ebacmd","" & vblf & "","")
		Call update(dataLoc & "\settings\logging.ebacmd","true","")
		Call update(dataLoc & "\settings\saveLogin.ebacmd","false","")
		Call update(dataLoc & "\settings\shutdownTimer.ebacmd","10","")
		Call update(dataLoc & "\secureShutdown.ebacmd","true","")
		
		'Apply Setup Options
		If Not fExists(logDir) Then Call log("Log File Created")
		Call log("Reinstalled EBA Command Center " & ver)
		Call update(dataLoc & "\startupType.ebacmd","firstrun","overwrite")
		
		Call giveNote("EBA Command Center is almost done reinstalling! We'll just need to start EBA Command Center from " & programLoc & " to finish reinstallation.")
		Call endOp("r")
	Elseif startupType = "recovery" Then
		title = "EBA Command Center " & ver & " Recovery"
		
		Call giveWarn("EBA Command Center is starting in recovery mode.")
		
		temp(4) = True
		Do while temp(4) = True
			eba = LCase(inputbox("EBA-Cmd > Recovery",title))
			If eba = "repair" Then
				eba = LCase(inputbox("EBA-Cmd > Recovery > Repair",title))
				If eba = "file" Then
					eba = LCase(inputbox("EBA-Cmd > Recovery > Repair > File",title))
					Call fileRepair(eba)
				Elseif eba = "refresh" Then
					Call write(dataLoc & "\startupType.ebacmd","refresh")
					Call endOp("r")
				End If
			Elseif eba = "startup" Then
				If fExists(dataLoc & "\startupType.ebacmd") Then
					eba = LCase(inputbox("EBA-Cmd > Recovery > Startup",title))
					Call write(dataLoc & "\startupType.ebacmd",eba)
				Else
					Call fileRepair(dataLoc & "\startupType.ebacmd")
				End If
			Elseif eba = "auto" Then
				startupType = "repair"
				Exit Do
			Elseif Len(eba) = 0 Then
				Call endOp("c")
			End If
		Loop
	Elseif startupType = "firstrun" Then
		title = "EBA Command Center " & ver & " Setup"
		Call giveNote("Welcome!")
		Call giveNote("We're about to set up EBA Command Center!")
		Call giveNote("You can access the tutorial with the command 'help'.")
		Call giveNote("Now, lets get to the setup!")
		progress = 1
		
		'Username
		Do while progress = 1
			uName = inputbox("Lets create your first User Account! Create your username below:", title)
			If Len(uName) < 3 Then
				Call giveWarn("That username is too short!")
			Elseif Len(uName) > 15 Then
				Call giveWarn("That username is too long!")
			Else
				If inStr(1,uName,"\") > 0 Then
					Call giveWarn("""\"" is not allowed in usernames!")
				Elseif inStr(1,uName,"/") > 0 Then
					Call giveWarn("""/"" is not allowed in usernames!")
				Elseif inStr(1,uName,":") > 0 Then
					Call giveWarn(""":"" is not allowed in usernames!")
				Elseif inStr(1,uName,"*") > 0 Then
					Call giveWarn("""*"" is not allowed in usernames!")
				Elseif inStr(1,uName,"?") > 0 Then
					Call giveWarn("""?"" is not allowed in usernames!")
				Elseif inStr(1,uName,"""") > 0 Then
					Call giveWarn("' "" ' is not allowed in usernames!")
				Elseif inStr(1,uName,"<") > 0 Then
					Call giveWarn("""<"" is not allowed in usernames!")
				Elseif inStr(1,uName,">") > 0 Then
					Call giveWarn(""">"" is not allowed in usernames!")
				Elseif inStr(1,uName,"|") > 0 Then
					Call giveWarn("""|"" is not allowed in usernames!")
				Else
					progress = 2
				End If
			End If
		Loop
		
		'Password
		Do while progress = 2
			pWord = inputbox("Create a password for " & uName, title)
			If pWord = "" Then
				eba = msgbox("Continue without a password?", 4+48, title)
				If eba = vbYes Then
					progress = 3
				End If
			Elseif Len(pWord) < 8 Then
				Call giveWarn("Password is too short.")
			Elseif Len(pWord) > 30 Then
				Call giveWarn("Password is too long.")
			Elseif InStr(1,lcase(pWord),"password") > 0 or Instr(1,pword,"1234") > 0 Then
				Call giveWarn("Ok, really..." & nls & "Ok, that password is too easy to figure out. Choose a strong password with a mix of letters and numbers.")
			Else
				temp(0) = inputbox("Confirm password:", title)
				If temp(0) = pword Then
					progress = 3
				Else
					Call giveWarn("Those passwords did not match.")
				End If
			End If
		Loop
		
		'Config
		Call giveNote("You have set up your user account! Now lets edit your settings.")
		eba = msgbox("Do you want to enable EBA Logs (Logs your EBA Command Center data)?" & vblf & "**Recommended**",4+32,title)
		If eba = vbYes Then
			Call write(dataLoc & "\settings\logging.ebacmd","true")
		Else
			Call write(dataLoc & "\settings\logging.ebacmd","false")
		End If
		eba = msgbox("Do you want to save your login information when EBA Command Center closes?" & vblf & "**Not Recommended**",4+32,title)
		If eba = vbYes Then
			Call write(dataLoc & "\settings\saveLogin.ebacmd","true")
		Else
			Call write(dataLoc & "\settings\saveLogin.ebacmd","false")
		End If
		
		
		Call write(dataLoc & "\Users\" & uName & ".ebacmd",pWord & vblf & "owner")
		Call log("New administrator account created: " & uName)
		If fExists(dataLoc & "\startupType.ebacmd") Then Call write(dataLoc & "\startupType.ebacmd","normal")
		Call giveNote("EBA Command Center has been setup and installed!")
		Call endOp("r")
	Elseif startupType = "firstrepair" Then
		title = "EBA Command Center " & ver & " Recovery"
		Call giveNote("EBA Command Center was recently repaired.")
		Call giveNote("Your preferences were reset during the repair process.")
		Call giveNote("We recommend going through initial setup again, just to ensure automatic repair did its job.")
		eba = msgbox("Run initial setup?",4+32,title)
		If eba = vbYes Then
			Call giveNote("We need to quickly uninstall a few files, to force EBA Command Center to boot into initial setup. Do not worry, your data will not be affected.")
			Call endOp("n")
			startupType = "firstrun"
		Else
			Call giveNote("EBA Command Center has been repaired!")
			Call write(dataLoc & "\Users\" & uName & ".ebacmd",pWord & vblf & "owner")
			Call log("New administrator account created: " & uName)
			If fExists(dataLoc & "\startupType.ebacmd") Then Call write(dataLoc & "\startupType.ebacmd","normal")
			Call endOp("r")
		End If
	Else
		Call giveError("Your startup type is not valid. Your startup type will be reset.")
		If fExists(dataLoc & "\startupType.ebacmd") Then Call write(dataLoc & "\startupType.ebacmd","normal")
		Call log("Invalid startup type was reset to normal: " & startupType)
		Call endOp("c")
	End If
Loop


'Subs
Sub read(dir,args)
	If fExists(dir) Then
		Set sys = fs.OpenTextFile (dir,1)
		data = sys.ReadAll
		Call cutDataEnd
		sys.Close
		If args = "l" Then data = LCase(data)
		If args = "u" Then data = UCase(data)
	Else
		Call giveWarn("Given file not found." & line & "Exit code: eba.err.readall" & vblf & "Path: " & dir & vblf & "Given Args: " & args)
	End If
	End Sub
Sub readLines(dir,lineInt)
	If fExists(dir) Then
		Set sys = fs.OpenTextFile (dir, 1)
		For forVar = 1 to lineInt
			lines(forVar) = sys.ReadLine
		Next
		sys.Close
	Else
		Call giveWarn("Given file not found." & line & "Exit code: eba.err.readlines" & vblf & "Path: " & dir & vblf & "Given Args: " & lineInt)
	End If
	End Sub
Sub cutDataEnd
	data = Left(data, Len(data) - 2)
	End Sub
Sub getTime
	nowDate = DatePart("m",Date) & "/" & DatePart("d",Date) & "/" & DatePart("yyyy",Date)
	nowTime = Right(0 & Hour(Now),2) & ":" & Right(0 & Minute(Now),2) & ":" & Right(0 & Second(Now),2)
	End Sub
Sub getTimeFilename
	nowDate = DatePart("m",Date) & "-" & DatePart("d",Date) & "-" & DatePart("yyyy",Date)
	nowTime = Right(0 & Hour(Now),2) & "." & Right(0 & Minute(Now),2) & "." & Right(0 & Second(Now),2)
	End Sub
Sub endOp(args)
	If args = "c" Then wscript.quit
	Call checkWscript
	If args = "f" then
		Call write(dataLoc & "\secureShutdown.ebacmd","true")
		Call log("EBA Command Center was forced to shut down")
		wscript.quit
	End If
	If args = "fa" Then
		runAdmin.ShellExecute "wscript.exe", DblQuote(scriptLoc), "", "runas", 1
		wscript.quit
	End If
	count(0) = count(0) + 1
	msgbox "Operation " & count(0) & " Completed:" & nls & "Errors: " & count(3) & vblf & "Warnings: " & count(2) & vblf & "Notices: " & count(1), 64, title
	Call clearCounts
	Call clearTemps
	Call clearLines
	If count(0) >= 30 Then Call write(dataLoc & "\susActivity.ebacmd","Operation count was " & count(0))
	If args = "s" Then
		Call write(dataLoc & "\secureShutdown.ebacmd","true")
		Call log("EBA Command Center was shut down")
		wscript.quit
	End If
	If args = "r" Then
		Call write(dataLoc & "\secureShutdown.ebacmd","true")
		Call log("EBA Command Center was restarted")
		cmd.run DblQuote(programLoc & "\EBA.vbs")
		wscript.quit
	End If
	If args = "ra" Then
		runAdmin.ShellExecute "wscript.exe", DblQuote(scriptLoc), "", "runas", 1
		wscript.quit
	End If
	End Sub
Sub write(dir,writeData)
	If fExists(dir) Then
		Set sys = fs.OpenTextFile (dir, 2)
		sys.WriteLine writeData
		sys.Close
	Else
		Set sys = fs.CreateTextFile (dir, 2)
		sys.WriteLine writeData
		sys.Close
	End If
	End Sub
Sub append(dir,writeData)
	If fExists(dir) Then
		Set sys = fs.OpenTextFile (dir, 8)
		sys.WriteLine writeData
		sys.Close
	Else
		Set sys = fs.CreateTextFile (dir, 8)
		sys.WriteLine writeData
		sys.Close
	End If
	End Sub
Sub log(logInput)
	If logging = "true" Then
		Call getTime
		logData = "[" & nowTime & " - " & nowDate & "] " & logInput
		Call append(logDir,logData)
	End If
	End Sub
Sub addError
	count(3) = count(3) + 1
	End Sub
Sub addWarn
	count(2) = count(2) + 1
	End Sub
Sub addNote
	count(1) = count(1) + 1
	End Sub
Sub clearCounts
	count(1) = 0
	count(2) = 0
	count(3) = 0
	End Sub
Sub clearTemps
	temp(0) = false
	temp(1) = false
	temp(2) = false
	temp(3) = false
	temp(4) = false
	temp(5) = false
	temp(6) = false
	temp(7) = false
	temp(8) = false
	temp(9) = false
	exeValue = "eba.null"
	exeValueExt = "eba.null"
	End Sub
Sub clearLines
	lines(0) = False
	lines(1) = False
	lines(2) = False
	lines(3) = False
	lines(4) = False
	lines(5) = False
	End Sub
Sub giveError(msg)
	msgbox "Error:" & line & msg, 16, title
	Call addError
	End Sub
Sub giveWarn(msg)
	msgbox "Warning:" & line & msg, 48, title
	Call addWarn
	End Sub
Sub giveNote(msg)
	msgbox "Notice:" & line & msg, 64, title
	Call addNote
	End Sub
Sub update(dir,writeData,args)
	If LCase(args) = "overwrite" Then
		Call write(dir,writeData)
	Elseif LCase(args) = "append" Then
		Call append(dir,writeData)
	Else
		If Not fExists(dir) Then
			Call write(dir,writeData)
		End If
	End If
	End Sub
Sub dataExists(dir)
	If Not fExists(dir) Then
		missFiles = dir
	End If
	End Sub
Sub dataExistsW(dir)
	If Not fExists(dir) Then
		Call giveWarn("A data file was not found:" & line & dir)
	End If
	End Sub
Sub fileRepair(dir)
	Call giveWarn("EBA File Repair is no longer available. Try EBA Automatic Repair. You can access this with EBA Recovery Mode, using the command 'auto'.")
	End Sub
Sub updateCommands
	fs.CopyFile scriptLoc, programLoc & "\EBA.vbs"
	
	fileDir = dataLoc & "\Commands\admin.ebacmd"
	Call update(fileDir,"eba.admin","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\config.ebacmd"
	Call update(fileDir,"eba.config","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"yes","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\crash.ebacmd"
	Call update(fileDir,"eba.crash","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"yes","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\dev.ebacmd"
	Call update(fileDir,"eba.dev","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\end.ebacmd"
	Call update(fileDir,"eba.end","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\error.ebacmd"
	Call update(fileDir,"eba.error","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\export.ebacmd"
	Call update(fileDir,"eba.export","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\help.ebacmd"
	Call update(fileDir,"eba.help","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\import.ebacmd"
	Call update(fileDir,"eba.import","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\login.ebacmd"
	Call update(fileDir,"eba.login","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\logout.ebacmd"
	Call update(fileDir,"eba.logout","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\logs.ebacmd"
	Call update(fileDir,logDir,"overwrite")
	Call update(fileDir,"file","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\update.ebacmd"
	Call update(fileDir,"https://sites.google.com/view/ebatools/home/cmd","overwrite")
	Call update(fileDir,"url","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\read.ebacmd"
	Call update(fileDir,"eba.read","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\refresh.ebacmd"
	Call update(fileDir,"eba.refresh","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"yes","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\restart.ebacmd"
	Call update(fileDir,"eba.restart","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\run.ebacmd"
	Call update(fileDir,"sys.run","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\shutdown.ebacmd"
	Call update(fileDir,"sys.shutdown","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\uninstall.ebacmd"
	Call update(fileDir,"eba.uninstall","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"yes","append")
	Call update(fileDir,"builtin","append")
	
	fileDir = dataLoc & "\Commands\write.ebacmd"
	Call update(fileDir,"eba.write","overwrite")
	Call update(fileDir,"exe","append")
	Call update(fileDir,"no","append")
	Call update(fileDir,"builtin","append")
	End Sub
Sub createUninstallFile
	temp(0) = "Option Explicit"
	temp(0) = temp(0) & vblf & "Dim eba,fs,title,dataLoc"
	temp(0) = temp(0) & vblf & "Dim cmd : Set cmd = CreateObject(""Wscript.shell"")"
	temp(0) = temp(0) & vblf & "Dim runAdmin : Set runAdmin = CreateObject(""Shell.Application"")"
	temp(0) = temp(0) & vblf & "Set fs = CreateObject(""Scripting.FileSystemObject"")"
	temp(0) = temp(0) & vblf & "dataLoc = cmd.ExpandEnvironmentStrings(""%APPDATA%"") & ""\EBA"""
	temp(0) = temp(0) & vblf & "On Error Resume Next"
	temp(0) = temp(0) & vblf & "cmd.RegRead(""HKEY_USERS\s-1-5-19\"")"
	temp(0) = temp(0) & vblf & "If Not err.number = 0 Then"
	temp(0) = temp(0) & vblf & "eba = msgbox(""EBA Command Center needs to be ran as administrator to continue uninstallation."",32,title)"
	temp(0) = temp(0) & vblf & "runAdmin.ShellExecute ""wscript.exe"", Chr(34) & Wscript.scriptfullname & Chr(34), """", ""runas"", 1"
	temp(0) = temp(0) & vblf & "wscript.quit"
	temp(0) = temp(0) & vblf & "End If"
	temp(0) = temp(0) & vblf & "title = ""EBA Command Center Uninstallation"""
	temp(0) = temp(0) & vblf & "eba = msgbox(""EBA Command Center is about to be uninstalled. Continue?"",4+48,""Warning"")"
	temp(0) = temp(0) & vblf & "If eba = vbNo Then"
	temp(0) = temp(0) & vblf & "msgbox ""Your EBA Command Center data has been restored."",64,""Important"""
	temp(0) = temp(0) & vblf & "Else"
	temp(0) = temp(0) & vblf & "fs.deletefolder(""C:\Program Files (x86)\EBA"")"
	temp(0) = temp(0) & vblf & "fs.deletefolder(dataLoc)"
	temp(0) = temp(0) & vblf & "msgbox ""EBA Command Center was uninstalled."",48,title"
	temp(0) = temp(0) & vblf & "End if"
	temp(0) = temp(0) & vblf & "fs.DeleteFile(Wscript.scriptfullname)"
	Call write(cmd.SpecialFolders("Startup") & "\eba.vbs",temp(0))
	End Sub
Sub checkWscript
	If Not Err.Number = 0 Then
		temp(0) = Err.Description
		If Err.Number = -2147024894 Then
			temp(0) = "File not found"
		Elseif Err.Number = -2147024891 Then
			temp(0) = "Failed to read registry (usually an error while checking if EBA Command Center was ran as administrator)"
		Elseif Err.Number = 70 Then
			temp(0) = "EBA Command Center tried to access a file on your system, but the system denied access (file might be open in another program, or your antivirus is blocking EBA Command Center)"
		Else
			temp(0) = temp(0) & " (EBA Command Center did not recognize the error code)"
		End If
		Call giveError("A WScript Error occurred during operation " & (count(0) + 1) & line & "Error Code: " & Err.Number & vblf & "Description: " & temp(0) & line & "Dev Description: " & Err.Description)
		Err.Clear
	End If
End Sub

'Functions
Function fExists(dir)
	fExists = fs.FileExists(dir)
	End Function
Function foldExists(dir)
	foldExists = fs.FolderExists(dir)
	End Function
Function newFolder(dir)
	If Not foldExists(dir) Then
		newFolder = fs.CreateFolder(dir)
	End If
	End Function
Function DblQuote(str)
	DblQuote = Chr(34) & str & Chr(34)
	End Function
Function scriptRunning()
	With WMI 
		With .ExecQuery("SELECT * FROM Win32_Process WHERE CommandLine LIKE " & "'%" & Replace(WScript.ScriptFullName,"\","\\") & "%'" & " AND CommandLine LIKE '%WScript%' OR CommandLine LIKE '%cscript%'")
			scriptRunning = (.Count > 1)
		End With
	End With
	End Function
Function checkOS()
	Set objOS = WMI.ExecQuery("Select * from Win32_OperatingSystem")
	For Each forVar in objOS
		checkOS = forVar.Caption
	Next
End Function
'EBA Command Center 7.3
'Copyright EBA Tools 2021
'
'
'More Info about EBA Command Center:
'
'EBA Command Center is mapped out as follows:
'Variable Setup
'Startup tests (Check OS, Check Imports, Get Startup Type, Check if already running)
'Startup Types (normal, repair, install, update, refresh, recovery, firstrun, firstrepair)
'Subs
'Functions
'More Info
'
'Startup Types:
'normal: EBA Command Center starts normally with "Start EBA Command Center?", or can start with "Settings file is corrupt" or even "EBA Command Center did not start correctly."
'repair: EBA Command Center starts Automatic Repair.
'install: EBA Command Center was not found on the device. EBA Command Center will be installed.
'update: EBA Command Center is about to be updated.
'refresh: EBA Command Center is about to be reinstalled.
'recovery: EBA Command Center ran into a problem, or a startup key was used. EBA Recovery Mode starts.
'firstrun: EBA Command Center was ran for the first time after installing/reinstalling. Initial setup is done.
'firstrepair: EBA Command Center was ran for the first time after automatic repair finished. You can add a broken user account back.
'
'Startup Tests:
'Check OS: Runs function checkOS() to see if your operating system is compatible.
'Check Imports: Checks for import requests.
'Get Startup Type: Gathers data (where script was ran, is EBA Cmd installed, does startupType.ebacmd exist) to set startup type.
'Check if already running: Runs function scriptRunning() to see if EBA Command Center is already running.
'
'
'File Formats (%EBA% is %AppData%\EBA)
'
'.ebacmd User File
'Directory: %EBA%\Users\{username}.ebacmd
'Line 1: {password}
'Line 2: {account type}
'
'.ebacmd Built-in Command File
'Directory: %EBA%\Commands\{cmd}.ebacmd
'Line 1: {target}
'Line 2: {cmd type}
'Line 3: {need admin}
'Line 4: builtin
'
'.ebacmd Custom Command File
'Directory: %EBA%\Commands\{cmd}.ebacmd
'Line 1: {target}
'Line 2: {cmd type}
'Line 3: {need admin}
'Line 4: no
'
'.ebaimport Startup Key
'Line 1: Type: Startup Key
'Line 2: Data: {startup exe value}
'
'.ebaimport Command File
'Line 1: Type: Command
'Line 2: {cmd}
'Line 3: {cmd type}
'Line 4: {target}
'Line 5: {need admin}
'
'Variables:
'{username}: The given username
'{password}: {username}'s password
'{account type}: {usernames}'s account type [general|admin|owner]
'{cmd}: Given command name
'{target}: Commands target (file, website, system command, eba command, or exe value)
'{cmd type}: Commands type [file|url|cmd|short|exe]
'{need admin}: Does the command require admin login? [yes|no]
'{startup exe value}: Exe value for startup (ex: eba.recovery)