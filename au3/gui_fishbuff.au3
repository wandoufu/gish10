#include <GUIConstantsEx.au3>
;finial, use the fishbuff to control key press
Global $__g_fishbuff[5][5]

;desc, en,time,twice
Global $__g_default_buff[5][4] = [ _
		["2:酒", 1, "3 min", 0], _
		["3:叉", 1, "10 min", 1], _
		["4:竿", 1, "10 min", 0], _
		["5:帽", 1, "10 min", 0], _
		["6:大", 0, "30 min", 0] _
		]

;GUICtrl Id: enable, time, twice
Global $__gid_fishbuff[5][3], $__gid_fishbuff_toggle


;_fishbuff_Main(50, 100)

Func _fishbuff_Main($ix, $iy)
	GUICtrlCreateGroup("鱼饵配置：", $ix, $iy, 180, 180)

	;5 group, each 4 items
	For $i = 0 To 4
		_fishbuff_CreateCtrl($i, $ix + 10, $iy + 20 + $i * 25)
	Next

	_fishbuff_ToggleCtrlEnable() ;disable

	$__gid_fishbuff_toggle = GUICtrlCreateButton("Toggle and Lock", $ix + 20, $iy + 140, 120)
	GUICtrlSetOnEvent(-1, "_fishbuff_ToggleCtrlEnable")

	GUICtrlCreateGroup("", -99, -99)
EndFunc   ;==>_fishbuff_Main

Func _fishbuff_CreateCtrl($id, $ix, $iy)
	;desc + enable
	Local $desc = $__g_default_buff[$id][0]
	$__gid_fishbuff[$id][0] = GUICtrlCreateCheckbox($desc, $ix, $iy)
	If $__g_default_buff[$id][1] Then GUICtrlSetState(-1, $GUI_CHECKED)

	;add time select
	Local $t = $__g_default_buff[$id][2]
	$__gid_fishbuff[$id][1] = GUICtrlCreateCombo("3 min", $ix + 50, $iy, 60)
	GUICtrlSetData($__gid_fishbuff[$id][1], "10 min|30 min", $t)

	;if twice press
	$__gid_fishbuff[$id][2] = GUICtrlCreateCheckbox("twice", $ix + 110, $iy)
	If $__g_default_buff[$id][3] Then GUICtrlSetState(-1, $GUI_CHECKED)

	;GUICtrlSetOnEvent($__gid_fishbuff[$id][0], "_fishbuff_UpdateBuff")
	;GUICtrlSetOnEvent($__gid_fishbuff[$id][1], "_fishbuff_UpdateBuff")
	;GUICtrlSetOnEvent($__gid_fishbuff[$id][2], "_fishbuff_UpdateBuff")

EndFunc   ;==>_fishbuff_CreateCtrl

Func _fishbuff_UpdateBuff()
	;defaut: 2:3min, 3:10min+twice,
	For $i = 0 To 4
		Local $enable = 0
		If GUICtrlRead($__gid_fishbuff[$i][0]) = $GUI_CHECKED Then $enable = 1
		Local $key = $i + 2
		Local $time = Number(GUICtrlRead($__gid_fishbuff[$i][1])) * 60 * 1000
		Local $twice = 0
		If GUICtrlRead($__gid_fishbuff[$i][2]) = $GUI_CHECKED Then $twice = 1

		ConsoleWrite("Key:" & $key & ", enalbe=" & $enable & ", time=" & $time & ", twice=" & $twice & @CRLF)
		$__g_fishbuff[$i][0] = $enable
		$__g_fishbuff[$i][1] = $key
		$__g_fishbuff[$i][2] = $time
		$__g_fishbuff[$i][3] = $twice
		;$__g_fishbuff[$i][3]   not define[4] timerinit
	Next
EndFunc   ;==>_fishbuff_UpdateBuff

Func _fishbuff_SetStatus($sts)
	For $i = 0 To 4
		For $j = 0 To 2
			GUICtrlSetState($__gid_fishbuff[$i][$j], $sts)
		Next
	Next
EndFunc   ;==>_fishbuff_SetStatus

Func _fishbuff_ToggleCtrlEnable()
	;If GUICtrlGetState($__gid_fishbuff[0][0])
	Local $sts = GUICtrlGetState($__gid_fishbuff[0][0])
	Local $isEnable = BitAND($sts, $GUI_ENABLE)

	If $isEnable Then
		_fishbuff_UpdateBuff()
		_fishbuff_SetStatus($GUI_DISABLE)
	Else
		_fishbuff_SetStatus($GUI_ENABLE)
	EndIf

EndFunc   ;==>_fishbuff_ToggleCtrlEnable

Func _fishbuff_IsTimeOut($id)
	Local $timer = $__g_fishbuff[$id][2]

	;timerinit
	If Not $__g_fishbuff[$id][4] Then
		Return 1
	ElseIf TimerDiff($__g_fishbuff[$id][4]) >= $timer Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>_fishbuff_IsTimeOut

Func _fishbuff_PressKey($id, $wait = 2000, $wait2 = 1000)
	Local $key = $__g_fishbuff[$id][1]
	Local $twice = $__g_fishbuff[$id][3]
	ConsoleWrite("Press" & $key & " twice=" & $twice & @CRLF)
	Send($key)
	Sleep($wait)

	If $twice = 1 Then
		Send($key)
		Sleep($wait2)
	EndIf
EndFunc   ;==>_fishbuff_PressKey

Func _fishbuff_ResetTimer($id)
	$__g_fishbuff[$id][4] = TimerInit()
EndFunc   ;==>_fishbuff_ResetTimer

Func _fishbuff_TimerCheck()
	For $i = 0 To 4
		If $__g_fishbuff[$i][0] = 1 Then ;enable
			If _fishbuff_IsTimeOut($i) Then
				_fishbuff_PressKey($i)
				_fishbuff_ResetTimer($i)
			EndIf
		EndIf
	Next
EndFunc   ;==>_fishbuff_TimerCheck

#cs
	fishbuff, enable add more buff for fishing
	buff info:
	key      2,3,4,5,6
	enable   if the buff is valid
	time     how often add buff (3/10/30minutes)
	isTwice  press 2 time to make sure the buff work

	A common fish buff:
	(2) 3min drawf wine
	(3) 10min panda fork, need press 2 to use it
	(4) + need use fish pole
	(5) 10min fish hat
	(6) 30min big fish bubble
#ce

;GUICtrlSetState
;$GUI_ENABLE (64) Control will be enabled.
;$GUI_DISABLE (128) Control will be greyed out.
