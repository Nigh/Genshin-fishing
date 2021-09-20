
# dependency:
# autohotkey in PATH
# ahk2exe in PATH
# 7z in PATH
# mpress in ahk2exe path

.PHONY: default dist build help
default: dist

GenshinFishing.exe:
	ahk2exe.exe /in GenshinFishing.ahk /out GenshinFishing.exe /icon icon.ico /compress 1
version.txt:
	autohotkey.exe .\GenshinFishing.ahk --out=version

dist: GenshinFishing.exe version.txt
	RMDIR /S /Q dist
	MKDIR dist
	7z a -r GenshinFishing.zip .\assets .\GenshinFishing.exe
	MOVE /Y GenshinFishing.zip .\dist
	MOVE /Y version.txt .\dist
	DEL /Q .\GenshinFishing.exe

build: GenshinFishing.exe
