#SingleInstance, ignore
SetWorkingDir, %A_ScriptDir%

FileDelete, "./GenshinFishing.exe"
RunWait, powershell -command "Expand-Archive -Force GenshinFishing.zip .",, Hide
FileDelete, "./GenshinFishing.zip"
Run, "./GenshinFishing.exe"

ExitApp
