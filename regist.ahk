
#include Maths.ahk
rsa_d := "2089290937"
rsa_n := "8570480201"
b64Decode(string)
{
    if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", 0, "uint*", size, "ptr", 0, "ptr", 0))
        throw Exception("CryptStringToBinary failed", -1)
    VarSetCapacity(buf, size, 0)
    if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", &buf, "uint*", size, "ptr", 0, "ptr", 0))
        throw Exception("CryptStringToBinary failed", -1)
    return StrGet(&buf, size, "UTF-8")
}

SM_rsa(a, b, c) {
	ans:="1"
	while(SM_Greater(b, 0)) {
		if(SM_Mod(b, 2)="1") {
			ans := SM_Mod(SM_Multiply(ans, a), c)
			b := SM_Add(b, "-1")
		}
		b := SM_Divide(b, 2, 0)
		a := SM_Mod(SM_Multiply(a, a), c)
	}
	Return ans
}

RSA_decode_MAC(mac3) {
	global rsa_d, rsa_n
	array:=[]
	Loop, Parse, mac3, `,
	{
		array.Push(A_LoopField+0)
	}
	output:=""
	loop, % array.Length()
	{
		output.=Format("{:04X}", SM_rsa(array[A_Index] "", rsa_d, rsa_n))
	}
	return output
}

isRegisted() {
	IniRead, regcode, setting.ini, regist, code, ""
	return isRegCodeValid(regcode)
}

isRegCodeValid(regcode) {
	global mac_addr
	if(StrLen(regcode)<2){
		return False
	}
	try {
		b64:=b64Decode(regcode)
	} catch {
		Return False
	}
	decode:=RSA_decode_MAC(b64)
	mac1:=Format("{:U}", StrReplace(mac_addr, ":"))
	mac2:=Format("{:U}", decode)
	if(InStr(mac2, mac1)) {
		return True
	}
	Return False
}
