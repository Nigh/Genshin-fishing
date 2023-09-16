

if(!g_regist) {
	
	notice_en:="This software is completely free, if you are purchased to get this software, please refund immediately"
	notice_zh:="本软件完全免费，如果你是通过其他途径购买得到的本软件，请立即退款"

	Random, onetwothree, 1, 3
	Random, notice_countdown, 2, 5

	freeversion_en:="The free version of the software needs to wait a few seconds to start, please press the button " onetwothree " to start the software after the countdown is over"
	freeversion_zh:="免费版本的软件需要等待数秒钟才能启动，请在倒计时结束后按下按钮 " onetwothree " 启动软件"

	Gui, notice:New, -MinimizeBox -Resize, Genshin Impact Fishing Automata - 原神钓鱼自动人偶

	Gui, Font, s22 bold, Verdana
	Gui, add, Text, x20 w700 center, Genshin Impact Fishing Automata
	Gui, add, Text, y+0 x20 w700 center, 原神钓鱼自动人偶
	Gui, Font, s12 norm cblue underline, Verdana
	Gui, add, Text, y+0 x20 w700 center gpages, https://github.com/Nigh/Genshin-fishing

	Gui, Font, s12 norm cblack, Verdana
	Gui, add, Text, y+30 x20 w700, % notice_en
	Gui, add, Text, y+5 w700, % freeversion_en

	Gui, add, Text, y+15 w700, % notice_zh
	Gui, add, Text, y+5 w700, % freeversion_zh

	Gui, Font, s22 bold cRed, Verdana
	Gui, add, Text, y+15 w700 center vcountdown, % notice_countdown
	Gui, Font, s16 bold, Verdana
	Gui, add, Button, y+15 w200 vbtn1 gbtn disabled, 1
	Gui, add, Button, x+50 w200 vbtn2 gbtn disabled, 2
	Gui, add, Button, x+50 w200 vbtn3 gbtn disabled, 3

	Gui, Font, s8 bold cgray, Verdana
	Gui, add, Text, x20 y+5 w700 right, Sponsor to get the version without waiting
	Gui, add, Text, y+5 w700 right, 赞助作者获取无需等待的注册版
	Gui, add, Edit, x430 y+5 h20 w160 right ReadOnly, % mac_addr
	Gui, add, Button, x+5 h20 w40 gcopymac, Copy
	Gui, add, Button, x+5 h20 w80 gregist, Reg 注册

	Gui, show, w740
	SetTimer, notice_cd, 1000
	Return
} else {
	ttm("自动钓鱼人偶注册版已启动！`n感谢您的注册！`n`nGenshin Fishing Automata registed version is up!`nThank you for registering!", 1500)
	goto notice_end
}

copymac:
Clipboard:=mac_addr
Return

notice_cd:
notice_countdown-=1
GuiControl,notice:, countdown, % notice_countdown
if(notice_countdown=0)
{
	GuiControl, notice:Enable, btn1
	GuiControl, notice:Enable, btn2
	GuiControl, notice:Enable, btn3
	SetTimer, notice_cd, Off
}
Return

GuiClose:
Gui, Hide
MsgBox, , Exiting, Software is going to exit`n软件即将退出, 2
ExitApp

btn:
if(A_GuiControl!="btn" onetwothree)
{
	Goto, GuiClose
}
Gui, Hide

notice_end:
