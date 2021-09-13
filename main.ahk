#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Include, Gdip_ImageSearch.ahk
#Include, Gdip.ahk

pToken := Gdip_Startup()

DllCall("QueryPerformanceFrequency", "Int64P", freq)
freq/=1000
genshin_window_exist()
{
	genshinHwnd := WinExist("ahk_exe GenshinImpact.exe")
	if not genshinHwnd
	{
		genshinHwnd := WinExist("ahk_exe YuanShen.exe")
	}
	return genshinHwnd
}
CoordMode, Pixel, Client
state:="unknown"
statePredict:="unknown"
statePredictConfi:=0
SetTimer, test, -100
Return


tt(txt, delay=1000)
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

getState:
ImageSearch, X, Y, winW*0.825, winH*0.875, winW, winH, *32 *TransFuchsia assets\ready.png
if(!ErrorLevel){
	state:="ready"
	statePredict:=state
	return
}
ImageSearch, X, Y, winW*0.825, winH*0.875, winW, winH, *32 *TransFuchsia assets\reel.png
if(!ErrorLevel){
	state:="reel"
	statePredict:=state
	return
}
ImageSearch, X, Y, winW*0.825, winH*0.875, winW, winH, *32 *TransFuchsia assets\casting.png
if(!ErrorLevel){
	state:="casting"
	statePredict:=state
	return
}
statePredictConfi += 1
state:="unknown"
if(statePredictConfi>=5){
	statePredict:="unknown"
}
Return

test:
genshin_hwnd := genshin_window_exist()
if(!genshin_hwnd){
	SetTimer, test, -1000
	Return
}
if(WinExist("A") != genshin_hwnd)
{
	SetTimer, test, -500
	Return
}
WinGetPos, _, _, winW, winH, ahk_id %genshin_hwnd%
if(statePredict=="unknown" || statePredict=="ready")
{
	Gosub, getState
	tt("state = " statePredict "`n" winW "," winH)
	if(statePredict=="reel"){
		SetTimer, test, -40
	} else {
		barY := 0
		SetTimer, test, -1000
	}
	Return
} else if(statePredict=="casting") {
	Gosub, getState
	tt("state = " statePredict)
	if(statePredict=="reel") {
		Click, Down
		SetTimer, test, -40
	} else{
		SetTimer, test, -200
	}
	Return
} else if(statePredict=="reel") {
	Click, Up
	if(!barY) {
		ImageSearch, _, barY, 0.25*winW, 0, 0.75*winW, 0.3*winH, *20 *TransFuchsia assets\bar.png
		if(ErrorLevel){
			barY := 0
		}
	} else {
		DllCall("QueryPerformanceCounter", "Int64P",  startTime)
		ImageSearch, leftX, leftY, 0.25*winW, barY-10, 0.75*winW, barY+30, *16 *TransFuchsia assets\left.png
		if(ErrorLevel){
			leftX := 0
			leftY := "Null"
		} else {
			leftPredictX := 2*leftX - leftXOld
			leftXOld := leftX
		}
		ImageSearch, rightX, rightY, 0.25*winW, barY-10, 0.75*winW, barY+30, *16 *TransFuchsia assets\right.png
		if(ErrorLevel){
			rightX := 0
			rightY := "Null"
		} else {
			rightPredictX := 2*rightX - rightXOld
			rightXOld := rightX
		}
		ImageSearch, curX, curY, 0.25*winW, barY-10, 0.75*winW, barY+30, *16 *TransFuchsia assets\cur.png
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
			}
		}
		DllCall("QueryPerformanceCounter", "Int64P",  endTime)
		lastTime := (endTime-startTime)//freq
		tt("barY = " barY "`n" "leftX = " leftX "`n" "rightX = " rightX "`n" "curX = " curX "`n" "barMove = " (leftX+rightX)-(leftXOld+rightXOld) "`n" state "`n" lastTime "ms")
	}
	SetTimer, test, -100
	Return
}

Return

F5::ExitApp
F6::Reload
