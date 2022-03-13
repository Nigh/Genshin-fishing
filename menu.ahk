Menu, Tray, NoStandard
Menu, Tray, Add, % "v" version,donothing
Menu, Tray, Add
if(g_regist){
	Menu, Tray, Add, Registed 已注册, donothing
}else{
	Menu, Tray, Add, Unregistered 未注册, donothing
	Menu, Tray, Add, Unregistered 未注册, donothing
	Menu, Tray, Add, Unregistered 未注册, donothing
}
Menu, Tray, Add
Menu, Tray, Add, Pages 页面, pages
Menu, Tray, Add, Donate 捐助, donate
Menu, Tray, Add, Exit, Exit
Menu, Tray, Click, 1
