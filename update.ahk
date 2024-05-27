
mirrorList:=["https://github.com"
,"https://mirror.ghproxy.com/https://github.com"]
updatemirrorTried:=Array()
today:=A_MM . A_DD

if(autoUpdate) {
	if(lastUpdate!=today) {
		log("Getting Update",0)
		update()
	} else {
		IniRead, version_str, setting.ini, update, ver, "0"
		if(version_str!=version) {
			IniWrite, % version, setting.ini, update, ver
			MsgBox, % version "`nUpdate log`n更新日志`n`n" update_log
		}
	}
} else {
	log("Update Skiped",0)
	TrayTip, Update,Update Skiped`n跳过升级`n`nCurrent version`n当前版本`nv%version%
}

update(){
	global
	req := ComObjCreate("MSXML2.ServerXMLHTTP")
	updateMirror:=updateMirror+0
	if(updateMirror > mirrorList.Length() or updateMirror <= 0) {
		updateMirror := 1
	}
	updateSite:=mirrorList[updateMirror]
	; MsgBox, % "GET:" . updateSite "/Nigh/Genshin-fishing/releases/latest/download/version.txt"
	updateReqDone:=0
	req.open("GET", updateSite "/Nigh/Genshin-fishing/releases/latest/download/version.txt", true)
	req.onreadystatechange := Func("updateReady")
	req.send()
	SetTimer, updateTimeout, -10000
	Return

	updateTimeout:
	tryNextUpdate()
	Return
}

tryNextUpdate()
{
	global mirrorList, updateMirror, updatemirrorTried
	updatemirrorTried.Push(updateMirror)
	SetTimer, updateTimeout, Off
	For k, v in mirrorList
	{
		tested:=False
		for _, p in updatemirrorTried
		{
			if(p=k) {
				tested:=True
				break
			}
		}
		if not tested {
			updateMirror:=k
			update()
			Return
		}
	}
	TrayTip, , % "Update failed`n`n更新失败",, 0x3
}
; with MSXML2.ServerXMLHTTP method, there would be multiple callback called

updateReady(){
	global req, version, updateReqDone, updateSite
	log("update req.readyState=" req.readyState, 1)
    if (req.readyState != 4){  ; Not done yet.
        return
	}
	if(updateReqDone){
		; log("state already changed", 1)
		Return
	}
	updateReqDone := 1
	log("update req.status=" req.status, 1)
    if (req.status == 200 and StrLen(req.responseText)<=64){ ; OK.
		SetTimer, updateTimeout, Off
        ; MsgBox % "Latest version: " req.responseText
		RegExMatch(version, "(\d+)\.(\d+)\.(\d+)", verNow)
		RegExMatch(req.responseText, "^(\d+)\.(\d+)\.(\d+)$", verNew)
		if(verNow1*10000+verNow2*100+verNow3<verNew1*10000+verNew2*100+verNew3) {
			MsgBox, 0x24, Download, % "Found new version " req.responseText ", download?`n`n发现新版本 " req.responseText " 是否下载?"
			IfMsgBox Yes
			{
				UrlDownloadToFile, % updateSite "/Nigh/Genshin-fishing/releases/latest/download/GenshinFishing.zip", ./GenshinFishing.zip
				if(ErrorLevel) {
					log("Err[" ErrorLevel "]Download failed", 0)
					MsgBox, 16,, % "Err" ErrorLevel "`n`nDownload failed`n下载失败"
				} else {
					MsgBox, ,, % "File saved as GenshinFishing.zip`n更新下载完成 GenshinFishing.zip`n`nProgram will restart now`n软件即将重启", 3
					IniWrite, % A_MM A_DD, setting.ini, update, last
					FileInstall, updater.exe, updater.exe, 1
					Run, updater.exe
					ExitApp
				}
			}
		} else {
			; MsgBox, ,, % "Current version: v" version "`n`nIt is the latest version`n`n软件已是最新版本", 2
			IniWrite, % A_MM A_DD, setting.ini, update, last
		}
	} else {
		tryNextUpdate()
		; TrayTip, , % "Update failed`n`n更新失败`n`nStatus=" req.status,, 0x3
	}
}
