#SingleInstance, ignore
SetWorkingDir, %A_ScriptDir%

RunWait, powershell -command "Expand-Archive -Force GenshinFishing.zip .",, Hide
FileDelete, "./GenshinFishing.zip"
Run, "./GenshinFishing.exe"

ExitApp
