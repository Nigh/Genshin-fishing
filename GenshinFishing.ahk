#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, ignore
#Persistent
SetBatchLines, -1

update_log:="
(
Add resolution support below
新增分辨率支持如下
1280x720
1600x900

Tooltip messages are turned off by default, specify debug=1 in setting.ini to turn on
提示信息默认关闭，在setting.ini中指定debug=1开启

Add logs, specify log=1 or log=2 in setting.ini to start logs with different levels of detail and save them in the genshinfishing.log file
增加log，在setting.ini中指定log=1或log=2启动不同详细程度的log，保存在genshinfishing.log文件中

You can turn off automatic updates by specifying autoupdate=0 in setting.ini
在setting.ini中可以指定autoupdate=0来关闭自动更新
)"

if A_IsCompiled
debug:=0
Else
debug:=1

version:="0.1.0"
if A_Args.Length() > 0
{
	for n, param in A_Args
	{
		RegExMatch(param, "--out=(\w+)", outName)
		if(outName1=="version") {
			f := FileOpen("version.txt","w")
			f.Write(version)
			f.Close()
			ExitApp
		}
	}
}


#Include menu.ahk

UAC()

IniRead, logLevel, setting.ini, update, log, 0
IniRead, lastUpdate, setting.ini, update, last, 0
IniRead, autoUpdate, setting.ini, update, autoupdate, 1
IniRead, debugmode, setting.ini, update, debug, 0
Gosub, log_init
log("Start at " A_YYYY "-" A_MM "-" A_DD)
today:=A_MM . A_DD
if(autoUpdate) {
	if(lastUpdate!=today) {
		log("Getting Update",0)
		MsgBox,,Update,Getting Update`n获取最新版本,2
		update()
	} else {
		IniRead, version_str, setting.ini, update, ver, "0"
		if(version_str!=version) {
			IniWrite, % version, setting.ini, update, ver
			MsgBox, % version "`nUpdate log`n更新日志`n`n" update_log
		}
		ttm("Genshin Fishing automata Start`nv" version "`n原神钓鱼人偶启动")
	}
} else {
	log("Update Skiped",0)
	MsgBox,,Update,Update Skiped`n跳过升级`n`nCurrent version`n当前版本`nv%version%,2
}

#Include, Gdip_ImageSearch.ahk
#Include, Gdip.ahk

pToken := Gdip_Startup()

img_list:=Object("bar",Object("filename","bar.png")
,"casting",Object("filename","casting.png")
,"cur",Object("filename","cur.png")
,"left",Object("filename","left.png")
,"ready",Object("filename","ready.png")
,"reel",Object("filename","reel.png")
,"right",Object("filename","right.png"))
; for k, v in img_list
; {
; 	pBitmap := Gdip_CreateBitmapFromFile( v.path )
; 	v.w:= Gdip_GetImageWidth( pBitmap )
; 	v.h:= Gdip_GetImageHeight( pBitmap )
; 	Gdip_DisposeImage( pBitmap )
; 	msgbox, % k "`n" v.path "`nw[" v.w "]`nh[" v.h "]"
; }

DllCall("QueryPerformanceFrequency", "Int64P", freq)
freq/=1000
CoordMode, Pixel, Client
state:="unknown"
statePredict:="unknown"
stateUnknownStart:=0
isResolutionValid:=0
OnExit, exit
SetTimer, main, -100
Return

log_init:
pLogfile:=FileOpen("genshinfishing.log", "a")
Return

log(txt,level=0)
{
	global logLevel, pLogfile
	if(logLevel >= level) {
		pLogfile.WriteLine(A_Hour ":" A_Min ":" A_Sec "." A_MSec "[" level "]:" txt)
	}
}

genshin_window_exist()
{
	genshinHwnd := WinExist("ahk_exe GenshinImpact.exe")
	if not genshinHwnd
	{
		genshinHwnd := WinExist("ahk_exe YuanShen.exe")
	}
	return genshinHwnd
}

ttm(txt, delay=1500)
{
	ToolTip, % txt
	SetTimer, kttm, % -delay
	Return
	kttm:
	ToolTip,
	Return
}

tt(txt, delay=2000)
{
	ToolTip, % txt, 1, 1
	SetTimer, ktt, % -delay
	Return
	ktt:
	ToolTip,
	Return
}
; 图标位置
; 右下角 w 82.5% h 87.5%
; Bar
; w 25%~75%
; h 0%~30%
; 浮漂
; w 25%~75%
; h 由 bar 参数 barY-10 ~ barY+30

genshin_hwnd := genshin_window_exist()
if(genshin_hwnd)
{
	; pBitmap:=Gdip_BitmapFromHWND(genshin_hwnd)
	; Gdip_SaveBitmapToFile(pBitmap, "output.jpg")
	; MsgBox, DONE

	hdc := GetDC(genshin_hwnd)
	CreateCompatibleDC(hdc)
	; Gdip_GraphicsFromHDC
	; Gdip_CreateBitmapFromHBITMAP
	; Gdip_SetBitmapToClipboard
}

getClientSize(hWnd, ByRef w := "", ByRef h := "")
{
	VarSetCapacity(rect, 16, 0)
	DllCall("GetClientRect", "ptr", hWnd, "ptr", &rect)
	w := NumGet(rect, 8, "int")
	h := NumGet(rect, 12, "int")
}

getState:
; k:=(((winW**2)+(winH**2))**0.5)/(((1920**2)+(1080**2))**0.5)
ImageSearch, X, Y, winW-winH*0.34, winH*0.85, winW, winH, % "*32 *TransFuchsia ./assets/" winW winH "/" img_list.ready.filename
if(!ErrorLevel){
	state:="ready"
	statePredict:=state
	stateUnknownStart := 0
	log("state->" statePredict, 1)
	return
}
ImageSearch, X, Y, winW-winH*0.34, winH*0.85, winW, winH, % "*32 *TransFuchsia ./assets/" winW winH "/" img_list.reel.filename
if(!ErrorLevel){
	state:="reel"
	statePredict:=state
	stateUnknownStart := 0
	log("state->" statePredict, 1)
	return
}
ImageSearch, X, Y, winW-winH*0.34, winH*0.85, winW, winH, % "*32 *TransFuchsia ./assets/" winW winH "/" img_list.casting.filename
if(!ErrorLevel){
	state:="casting"
	statePredict:=state
	stateUnknownStart := 0
	log("state->" statePredict, 1)
	return
}
state:="unknown"
if(stateUnknownStart == 0) {
	stateUnknownStart := A_TickCount
}
if(statePredict!="unknown" && A_TickCount - stateUnknownStart>=2000){
	statePredict:="unknown"
	; Click, Up
	log("state->" statePredict, 1)
}
Return

main:
genshin_hwnd := genshin_window_exist()
if(!genshin_hwnd){
	SetTimer, main, -800
	Return
}
if(WinExist("A") != genshin_hwnd)
{
	SetTimer, main, -500
	Return
}
getClientSize(genshin_hwnd, winW, winH)

if(oldWinW!=winW || oldWinH!=winH) {
	log("Get dimension=" winW "x" winH,1)
	if(InStr(FileExist("./assets/" winW winH), "D")) {
		fileCount:=0
		for k, v in img_list
		{
			if(FileExist("./assets/" winW winH "/" v.filename)) {
				fileCount += 1
			}
		}
		if(fileCount < img_list.Count()) {
			isResolutionValid:=0
		} else {
			isResolutionValid:=1
		}
	} else {
		isResolutionValid:=0
	}
}
oldWinW:=winW
oldWinH:=winH
if(!isResolutionValid) {
	tt("Unsupported resolution`n不支持的分辨率`n" winW "x" winH)
	SetTimer, main, -800
	Return
}

if(statePredict=="unknown" || statePredict=="ready")
{
	Gosub, getState
	if(statePredict!="unknown" && debugmode){
		tt("state = " state "`nstatePredict = " statePredict "`n" winW "," winH)
	}
	if(statePredict=="reel"){
		SetTimer, main, -40
	} else {
		barY := 0
		SetTimer, main, -800
	}
	Return
} else if(statePredict=="casting") {
	Gosub, getState
	if(debugmode){
		tt("state = " statePredict)
	}
	if(statePredict=="reel") {
		Click, Down
		SetTimer, main, -40
	} else{
		SetTimer, main, -200
	}
	Return
} else if(statePredict=="reel") {
	DllCall("QueryPerformanceCounter", "Int64P",  startTime)
	if(!barY) {
		ImageSearch, _, barY, 0.33*winW, 0, 0.66*winW, 0.3*winH, % "*20 *TransFuchsia ./assets/" winW winH "/" img_list.bar.filename
		if(ErrorLevel){
			barY := 0
		} else {
			Click, Up
			avrDetectTime:=[]
			leftX:=0
			rightX:=0
			curX:=0
			log("get barY=" barY,2)
		}
		DllCall("QueryPerformanceCounter", "Int64P",  endTime)
	} else {
		if(leftX > 0) {
			ImageSearch, leftX, leftY, leftX-25, barY-10, leftX+25+12, barY+30, % "*16 *TransFuchsia ./assets/" winW winH "/" img_list.left.filename
		} else {
			ImageSearch, leftX, leftY, 0.33*winW, barY-10, 0.66*winW, barY+30, % "*16 *TransFuchsia ./assets/" winW winH "/" img_list.left.filename
		}
		if(ErrorLevel){
			leftX := 0
			leftY := "Null"
		} else {
			leftPredictX := 2*leftX - leftXOld
			leftXOld := leftX
		}
		
		if(rightX > 0) {
			ImageSearch, rightX, rightY, rightX-25, barY-10, rightX+25+12, barY+30, % "*16 *TransFuchsia ./assets/" winW winH "/" img_list.right.filename
		} else {
			ImageSearch, rightX, rightY, 0.33*winW, barY-10, 0.66*winW, barY+30, % "*16 *TransFuchsia ./assets/" winW winH "/" img_list.right.filename
		}
		if(ErrorLevel){
			rightX := 0
			rightY := "Null"
		} else {
			rightPredictX := 2*rightX - rightXOld
			rightXOld := rightX
		}

		if(curX > 0) {
			ImageSearch, curX, curY, curX-50, barY-10, curX+50+11, barY+30, % "*16 *TransFuchsia ./assets/" winW winH "/" img_list.cur.filename
		} else {
			ImageSearch, curX, curY, 0.33*winW, barY-10, 0.66*winW, barY+30, % "*16 *TransFuchsia ./assets/" winW winH "/" img_list.cur.filename
		}
		if(ErrorLevel){
			curX := 0
			curY := "Null"
		} else {
			curPredictX := 2*curX - curXOld
			curXOld := curX
		}
		if(leftY == "Null" && rightY == "Null" && curY == "Null") {
			Gosub, getState
			Click, Up
		} else {
			if(leftX+rightX < leftXOld+rightXOld) {
				k := 0.2
			} else if(leftX+rightX > leftXOld+rightXOld) {
				k:= 0.8
			} else {
				k = 0.4
			}
			if(curPredictX<(k*rightPredictX + (1-k)*leftPredictX)){
				Click, Down
			} else {
				Click, Up
			}
		}
		DllCall("QueryPerformanceCounter", "Int64P",  endTime)

		detectTime:=(endTime-startTime)//freq
		if(avrDetectTime.Length()<8){
			avrDetectTime.Push(detectTime)
		} else {
			avrDetectTime.Pop()
			avrDetectTime.Push(detectTime)
		}
		sum := 0
		For index, value in avrDetectTime
			sum += value

		avrDetectMs := sum//avrDetectTime.Length()

		log("dt=" detectTime "ms`tleftX="leftX "`trightX="rightX "`t" "curX="curX "`tleftXpre="leftPredictX "`trightXpre="rightPredictX "`tcurXpre="curPredictX,2)
		if(debugmode){
			tt("barY = " barY "`n" "leftX = " leftX "`n" "rightX = " rightX "`n" "curX = " curX "`n" "barMove = " (leftX+rightX)-(leftXOld+rightXOld) "`n" state "`n" avrDetectMs "ms")
		}
	}
	lastTime:=(endTime-startTime)//freq
	if(lastTime>60) {
		SetTimer, main, -10
	} else {
		SetTimer, main, % lastTime-70
	}
	Return
}

Return

donate:
Run, https://ko-fi.com/xianii
Return
pages:
Run, https://github.com/Nigh/Genshin-fishing
Return
exit:
pLogfile.Close()
ExitApp
donothing:
Return

#If debug
F5::ExitApp
F6::Reload
#If

update(){
	global
	req := ComObjCreate("MSXML2.ServerXMLHTTP")
	; https://download.fastgit.org/Nigh/Genshin-fishing/releases/latest/download/version.txt
	; https://github.com/Nigh/Genshin-fishing/releases/latest/download/version.txt
	req.open("GET", "https://download.fastgit.org/Nigh/Genshin-fishing/releases/latest/download/version.txt", true)
	req.onreadystatechange := Func("updateReady")
	req.send()
}

; with MSXML2.ServerXMLHTTP method, there would be multiple callback called
updateReqDone:=0
updateReady(){
	global req, version, updateReqDone
	log("update req.readyState=" req.readyState, 1)
    if (req.readyState != 4){  ; Not done yet.
        return
	}
	if(updateReqDone){
		log("state already changed", 1)
		Return
	}
	updateReqDone := 1
	log("update req.status=" req.status, 1)
    if (req.status == 200){ ; OK.
        ; MsgBox % "Latest version: " req.responseText
		RegExMatch(version, "(\d+)\.(\d+)\.(\d+)", verNow)
		RegExMatch(req.responseText, "(\d+)\.(\d+)\.(\d+)", verNew)
		if(verNow1*10000+verNow2*100+verNow3<verNew1*10000+verNew2*100+verNew3) {
			MsgBox, 0x24, Download, % "Found new version " req.responseText ", download?`n`n发现新版本 " req.responseText " 是否下载?"
			IfMsgBox Yes
			{
				UrlDownloadToFile, https://download.fastgit.org/Nigh/Genshin-fishing/releases/latest/download/GenshinFishing.zip, ./GenshinFishing.zip
				if(ErrorLevel) {
					MsgBox, 16,, % "Download failed`n下载失败"
				} else {
					MsgBox, ,, % "File saved as GenshinFishing.zip`n更新下载完成 GenshinFishing.zip`n`nProgram will exit now`n软件即将退出", 2
					IniWrite, % A_MM A_DD, setting.ini, update, last
					ExitApp
				}
			}
		} else {
			MsgBox, ,, % "Current version: v" version "`n`nIt is the latest version`n`n软件已是最新版本", 2
			IniWrite, % A_MM A_DD, setting.ini, update, last
		}
	} else {
        MsgBox, 16,, % "Update failed`n`n更新失败`n`nStatus=" req.status
	}
}

UAC()
{
	full_command_line := DllCall("GetCommandLine", "str")
	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
	{
		try
		{
			if A_IsCompiled
				Run *RunAs "%A_ScriptFullPath%" /restart
			else
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
		}
		ExitApp
	}
}