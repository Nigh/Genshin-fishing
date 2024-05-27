#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force
#Persistent
SetBatchLines, -1

supported_resolutions:="
(
1280 x 720
1440 x 900
1600 x 900
1920 x 1080
1920 x 1200
2560 x 1080
2560 x 1440
2560 x 1600
3440 x 1440
3840 x 2160
)"

update_log:="
(

> 新增2560x1600分辨率支持
> Added 2560x1600 resolution support

)"

version:="0.2.10"

isCNServer:=0
; 出现了一个国际服玩家UI位置与国服不一致的情况。尚不能确定是服务器间差异或是其他的客户端差异所造成。暂时先令所有的图标搜索范围均扩大。
isWorking:=False

;@Ahk2Exe-IgnoreBegin
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
;@Ahk2Exe-IgnoreEnd

;@Ahk2Exe-SetCompanyName HelloWorks
;@Ahk2Exe-SetName Genshin Fishing Automata
;@Ahk2Exe-SetDescription Genshin Fishing Automata
;@Ahk2Exe-SetVersion %version%
;@Ahk2Exe-SetMainIcon icon.ico
;@Ahk2Exe-ExeName GenshinFishing

for objItem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
{
	mac_addr:=objItem.MACAddress
	Break
}
#Include regist.ahk
if(isRegisted()){
	g_regist := true
} else {
	g_regist := false
}


#Include menu.ahk

UAC()
#include notice.ahk

IniRead, logLevel, setting.ini, update, log, 0
IniRead, lastUpdate, setting.ini, update, last, 0
IniRead, autoUpdate, setting.ini, update, autoupdate, 1
IniRead, updateMirror, setting.ini, update, mirror, 1
IniWrite, % updateMirror, setting.ini, update, mirror
IniRead, debugmode, setting.ini, update, debug, 0
Gosub, log_init
log("Start at " A_YYYY "-" A_MM "-" A_DD)
IfExist, updater.exe
{
	FileDelete, updater.exe
}
#include update.ahk

TrayTip, % "Genshin Fishing Automata", % "Genshin Fishing Automata Start`nv" version "`n原神钓鱼人偶启动"

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

; #Include, Gdip_ImageSearch.ahk
; #Include, Gdip.ahk
; pToken := Gdip_Startup()

#include, fileinstalls.ahk


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
lastLogWrite:=A_TickCount
Return

log(txt,level=0)
{
	global logLevel, pLogfile
	if(logLevel >= level) {
		pLogfile.WriteLine(A_Hour ":" A_Min ":" A_Sec "." A_MSec "[" level "]:" txt)
		if(A_TickCount - lastLogWrite > 10000) {
			pLogfile.Close()
			Gosub, log_init
		}
	}
}

genshin_window_exist()
{
	; global isCNServer
	genshinHwnd := WinExist("ahk_exe GenshinImpact.exe")
	; isCNServer := 0
	if not genshinHwnd
	{
		genshinHwnd := WinExist("ahk_exe YuanShen.exe")
		; isCNServer := 1
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

	; hdc := GetDC(genshin_hwnd)
	; CreateCompatibleDC(hdc)
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

dLinePt(p)
{
	global dLine
	return Ceil(p*dLine)
}

; iconSize = dLinePt(0.0353) * dLinePt(0.0442)

getState:
if(isCNServer) {
	iconLeftPt := 0.167
} else {
	iconLeftPt := 0.222
}
iconTopPt := 0.084
iconBottomPt := 0
iconRightPt := 0

if(last_iconX>0) {
	last_iconLeftPt := (winW - last_iconX)/dLine
	last_iconTopPt := (winH - last_iconY)/dLine
	
	iconBottomPt := (winH - last_iconY - dLinePt(0.0442*1.5))/dLine
	iconRightPt := (winW - last_iconX - dLinePt(0.0353*1.5))/dLine
	if(iconBottomPt<0){
		iconBottomPt := 0
	}
	if(iconRightPt<0){
		iconRightPt := 0
	}
	iconLeftPt := last_iconLeftPt + (0.0353*0.5)
	iconTopPt := last_iconTopPt + (0.0442*0.5)
	log("lastIcon=" last_iconX ", " last_iconY "  dLine=" dLine, 3)
}
; log("search from [" winW-dLinePt(iconLeftPt) ", " winH-dLinePt(iconTopPt) "] to [" winW-dLinePt(iconRightPt) ", " winH-dLinePt(iconBottomPt) "]", 3)
; k:=(((winW**2)+(winH**2))**0.5)/(((1920**2)+(1080**2))**0.5)
searchX0:=winW-dLinePt(iconLeftPt)
searchY0:=winH-dLinePt(iconTopPt)
searchX1:=winW-dLinePt(iconRightPt)
searchY1:=winH-dLinePt(iconBottomPt)
ImageSearch, iconX, iconY, searchX0, searchY0, searchX1, searchY1, % "*32 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.ready.filename
if(!ErrorLevel){
	last_iconX := iconX
	last_iconY := iconY
	state:="ready"
	statePredict:=state
	stateUnknownStart := 0
	log("state->" statePredict, 1)
	return
} else {
	log("[" ErrorLevel "] not in ready state [" searchX0 "," searchY0 "," searchX1 "," searchY1 "]", 3)
}
ImageSearch, iconX, iconY, searchX0, searchY0, searchX1, searchY1, % "*32 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.reel.filename
if(!ErrorLevel){
	last_iconX := iconX
	last_iconY := iconY
	state:="reel"
	statePredict:=state
	stateUnknownStart := 0
	log("state->" statePredict, 1)
	return
} else {
	log("[" ErrorLevel "] not in reel state [" searchX0 "," searchY0 "," searchX1 "," searchY1 "]", 3)
}
ImageSearch, iconX, iconY, searchX0, searchY0, searchX1, searchY1, % "*32 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.casting.filename
if(!ErrorLevel){
	last_iconX := iconX
	last_iconY := iconY
	state:="casting"
	statePredict:=state
	stateUnknownStart := 0
	log("state->" statePredict, 1)
	return
} else {
	log("[" ErrorLevel "] not in casting state [" searchX0 "," searchY0 "," searchX1 "," searchY1 "]", 3)
}
state:="unknown"
if(stateUnknownStart == 0) {
	stateUnknownStart := A_TickCount
}
if(statePredict!="unknown" && A_TickCount - stateUnknownStart>=2000){
	last_iconX := 0
	last_iconY := 0
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
if(WinExist("A") != genshin_hwnd) {
	isWorking:=False
	SetTimer, main, -500
	Return
}
getClientSize(genshin_hwnd, winW, winH)
if(oldWinW!=winW || oldWinH!=winH) {
	log("Get dimension=" winW "x" winH,1)
	if(InStr(FileExist(A_Temp "/genshinfishing/" winW winH), "D")) {
		fileCount:=0
		for k, v in img_list
		{
			if(FileExist(A_Temp "/genshinfishing/" winW winH "/" v.filename)) {
				fileCount += 1
			}
		}
		if(fileCount < img_list.Count()) {
			isResolutionValid:=0
		} else {
			isResolutionValid:=1
			dline:=Ceil(((winW**2)+(winH**2))**0.5)
			barR_left:=dLinePt(0.27)
			barR_top:=dLinePt(0.03)
			barR_right:=dLinePt(0.59)
			barR_bottom:=dLinePt(0.1)
			
			delta_left:=dLinePt(0.025)
			delta_top:=dLinePt(0.005)
			delta_right:=dLinePt(0.035)
			delta_bottom:=dLinePt(0.014)

			barS_left:=dLinePt(0.22)
			barS_right:=dLinePt(0.64)
		}
	} else {
		isResolutionValid:=0
	}
}
oldWinW:=winW
oldWinH:=winH
if(!isResolutionValid) {
	tt("Unsupported resolution`n不支持的分辨率`n" winW "x" winH "`n`nThe supported resolutions are as follows`n支持的分辨率如下`n" supported_resolutions)
	SetTimer, main, -800
	Return
} else {
	if(isWorking==False) {
		tt("Genshin Fishing Automata is working`n自动钓鱼人偶正常工作中")
		log("Genshin Window Active",1)
	}
}
isWorking:=True

if(statePredict=="unknown" || statePredict=="ready") {
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
	if(barY<2) {
		ImageSearch, _, barY, barR_left, barR_top, barR_right, barR_bottom, % "*20 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.bar.filename
		if(ErrorLevel){
			if(barY == 0) {
				barY := 1
				Click, Down
			} else if(barY == 1) {
				barY := 0
				Click, Up
			}
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
			ImageSearch, leftX, leftY, leftX-delta_left, barY-delta_top, leftX+delta_right, barY+delta_bottom, % "*16 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.left.filename
		} else {
			ImageSearch, leftX, leftY, barS_left, barY-delta_top, barS_right, barY+delta_bottom, % "*16 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.left.filename
		}
		if(ErrorLevel){
			leftX := 0
			leftY := "Null"
		} else {
			leftPredictX := 2*leftX - leftXOld
			leftXOld := leftX
		}
		
		if(rightX > 0) {
			ImageSearch, rightX, rightY, rightX-delta_left, barY-delta_top, rightX+delta_right, barY+delta_bottom, % "*16 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.right.filename
		} else {
			ImageSearch, rightX, rightY, barS_left, barY-delta_top, barS_right, barY+delta_bottom, % "*16 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.right.filename
		}
		if(ErrorLevel){
			rightX := 0
			rightY := "Null"
		} else {
			rightPredictX := 2*rightX - rightXOld
			rightXOld := rightX
		}

		if(curX > 0) {
			ImageSearch, curX, curY, curX-delta_left, barY-delta_top, curX+delta_right, barY+delta_bottom, % "*16 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.cur.filename
		} else {
			ImageSearch, curX, curY, barS_left, barY-delta_top, barS_right, barY+delta_bottom, % "*16 *TransFuchsia " A_Temp "/genshinfishing/" winW winH "/" img_list.cur.filename
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

regist:
Gui, notice:+OwnDialogs 
InputBox, regcode_input, Regist 注册, Please input regist code:`n请输入注册码:
if !ErrorLevel
{
	if(isRegCodeValid(regcode_input)){
		IniWrite, % regcode_input, setting.ini, regist, code
		MsgBox, 0x40,, Regist success! 注册成功!
		Reload
	} else {
		MsgBox, 16,, Invalid regist code 无效的注册码
	}
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

;@Ahk2Exe-IgnoreBegin
F5::ExitApp
F6::Reload
;@Ahk2Exe-IgnoreEnd

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
