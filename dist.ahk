; # dependency:
; # autohotkey in PATH
; # ahk2exe in PATH
; # mpress in ahk2exe path

#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

if FileExist("GenshinFishing.exe")
{
	FileDelete, GenshinFishing.exe
}

if FileExist("version.txt")
{
	FileDelete, version.txt
}

if InStr(FileExist("dist"), "D")
{
	FileRemoveDir, dist, 1
}

FileCreateDir, dist

; Generate fileinstalls
img_list:=Object("bar",Object("filename","bar.png")
,"casting",Object("filename","casting.png")
,"cur",Object("filename","cur.png")
,"left",Object("filename","left.png")
,"ready",Object("filename","ready.png")
,"reel",Object("filename","reel.png")
,"right",Object("filename","right.png"))
fip:=FileOpen("fileinstalls.ahk", "w")
Loop, Files, .\assets\*, D
{
	; MsgBox, % A_LoopFileLongPath "`n" A_LoopFileShortPath "`n" A_LoopFileName 
	fip.WriteLine("`r`nFileCreateDir, % A_Temp ""\genshinfishing\" A_LoopFileName """")
	for k, v in img_list
	{
		; MsgBox, % A_LoopFileShortPath "\" v.filename "`n" A_Temp "\genshinfishing\" A_LoopFileName "\" v.filename
		; FileInstall, % A_LoopFileShortPath "\" v.filename, % A_Temp "\genshinfishing\" A_LoopFileName "\" v.filename, 1
		fip.WriteLine("FileInstall, " A_LoopFileShortPath "\" v.filename ", % A_Temp ""\genshinfishing\" A_LoopFileName "\" v.filename """, 1")
	}
}
fip.Close()

RunWait, ahk2exe.exe /in GenshinFishing.ahk /out GenshinFishing.exe /icon icon.ico /compress 1
If (ErrorLevel)
{
	MsgBox, % "ERROR CODE=" ErrorLevel
	ExitApp
}
RunWait, autohotkey.exe .\GenshinFishing.ahk --out=version
If (ErrorLevel)
{
	MsgBox, % "ERROR CODE=" ErrorLevel
	ExitApp
}
RunWait, powershell -command "Compress-Archive -Path .\GenshinFishing.exe -DestinationPath GenshinFishing.zip",, Hide
If (ErrorLevel)
{
	MsgBox, % "compress`nERROR CODE=" ErrorLevel
	ExitApp
}
FileDelete, GenshinFishing.exe
FileMove, GenshinFishing.zip, dist\GenshinFishing.zip, 1
FileMove, version.txt, dist\version.txt, 1
MsgBox, Build Finished
