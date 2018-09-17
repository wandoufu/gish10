#include-once
#include <WindowsConstants.au3>
#include <WinApiRes.au3>
#include "gui_fishbuff.au3"

#cs
	钓鱼脚本
	描述：甩竿，找鱼漂，提竿
	特性：
	*   在方框内扫描鱼漂，方框可配置（ESC）
	*   支持加鱼饵等多个buff操作（GUI可配置）
	*   监视鱼漂的红色点，判断并提竿


	;更新记录
	2018-09-17 09:55:49

	;	更多的计时器(可配置)
	;		2分钟	-啤酒
	;		10分钟	-魔法鱼饵
	;		10分钟	-一般鱼饵
	;		30分钟	-大鱼漂
	;	固定的鱼漂tooltip（小窗口，右边两个动作条）

#ce

;选项配置
Opt("GUIOnEventMode", 1) ; Change to OnEvent mode
Opt('MustDeclareVars', 1) ; 变量必须被预先定义dim local global
Opt('GUICloseOnESC', 0) ; ESC 不是退出

;热键设置
; ESC 选坐标, 运行中停止
HotKeySet("{Esc}", "escGetPos")

;全局控件
; Lable: 左上，右下的坐标显示 (可能不是很准确，有个标题栏的误差)
Global $l_wow_pos1, $l_wow_pos2
; Radio: 允许左上，右下的坐标设置(移动鼠标，按ESC)
Global $r_wow_pos1, $r_wow_pos2
; Button: 启动、停止
Global $b_start_stop
Global $_gid_status


;全局变量
; 运行: 可以用鼠标点按钮，或者空格键
Global $running = 0

; 左上、右下变量(默认值)
Global $wow_x1 = 723
Global $wow_y1 = 217

Global $wow_x2 = 1055
Global $wow_y2 = 378

Global $step = 30

;计时器 TimerDiff
Global $begin = TimerInit()
Global $max_time = 22000

Global $good = 0, $bad = 0

;
;主程序
_gish10()

While 1

	Sleep(100)

WEnd

Func _gish10()
	;置顶窗口
	GUICreate("Press Esc to Get Pos", 200, 380, 10, 10, -1, $WS_EX_TOPMOST)
	GUISetOnEvent($GUI_EVENT_CLOSE, "guiClose")

	;;;;;;;;;;;;;;;
	;;; GUI Control
	;;;;;;;;;;;;;;;
	Local $x = 10, $y = 10
	_fishbuff_Main($x, $y)
	$y += 200
	_fishrect_Create($x, $y)
	$y += 100

	;开始和停止的按钮
	$b_start_stop = GUICtrlCreateButton("开始", $x, $y, 180)
	GUICtrlSetOnEvent(-1, "ToggleRunning")
	$y += 40

	$_gid_status = GUICtrlCreateLabel("status:", $x, $y, 180)

	GUISetState()
EndFunc   ;==>_gish10

; a group for fish rectangle
Func _fishrect_Create($x = 0, $y = 0)
	;单选按钮，选中后按ESC可以获得坐标设置
	GUICtrlCreateGroup("ESC选择渔区", $x, $y, 180, 80)
	$r_wow_pos1 = GUICtrlCreateRadio("渔区左上", $x + 10, $y + 20, 70)
	$r_wow_pos2 = GUICtrlCreateRadio("渔区右下", $x + 80, $y + 20, 70)

	;坐标的标签
	$l_wow_pos1 = GUICtrlCreateLabel($wow_x1 & "," & $wow_y1, $x + 20, $y + 50)
	$l_wow_pos2 = GUICtrlCreateLabel($wow_x2 & "," & $wow_y2, $x + 90, $y + 50)
	GUICtrlCreateGroup("", -99, -99)
EndFunc   ;==>_fishrect_Create


Func doFishing()
	GUICtrlSetData($_gid_status, "启动钓鱼 ... ")
	$good = 0
	$bad = 0

	;move to left side and active window
	MouseMove($wow_x1, $wow_y1)
	Sleep(1000)
	MouseClick("left")

	While $running
		;review/add fishbuff
		GUICtrlSetData($_gid_status, "检查鱼饵...")
		_fishbuff_TimerCheck()

		GUICtrlSetData($_gid_status, "开始钓鱼 ... ")
		scanPop2()

		GUICtrlSetData($b_start_stop, "GOOD:" & $good & " BAD:" & $bad)
	WEnd
EndFunc   ;==>doFishing


Func monitorPop()
	GUICtrlSetData($_gid_status, "寻找红点 ...")
	; tips: avoid last shade out
	While TimerDiff($begin) < 2000
		Sleep(500)
	WEnd

	;Find dark red point
	Local $first_color = findPixelAtMouse(0x602020, 50, 30, 1)
	If @error Then
		$bad += 1
		GUICtrlSetData($_gid_status, "寻找红点 - 失败")
		Send("{SPACE}")
		Return
	EndIf

	;Keep monitor
	GUICtrlSetData($_gid_status, "监视红点 ... ")
	While (1)
		Sleep(100)
		Local $next_color = findPixelAtMouse($first_color, 5, 10) ;narrow search
		If @error Then
			GUICtrlSetData($_gid_status, "监视红点 ... 消失，点击")
			$good += 1
			MouseClick("left") ;
			Sleep(1000)
			ExitLoop ;got it
		EndIf
		If TimerDiff($begin) >= $max_time Then
			GUICtrlSetData($_gid_status, "监视红点 ... 超时")
			$bad += 1
			ExitLoop
		EndIf
	WEnd

EndFunc   ;==>monitorPop


Func findPixelAtMouse($color, $range = 50, $shade = 30, $move = 0)
	Local $pos = MouseGetPos()
	Local $x1 = $pos[0] - $range
	Local $y1 = $pos[1] - $range
	Local $x2 = $pos[0] + $range
	Local $y2 = $pos[1] + $range

	Local $pop_pos = PixelSearch($x1, $y1, $x2, $y2, $color, $shade)
	If Not @error Then
		Local $color2 = PixelGetColor($pop_pos[0], $pop_pos[1])
		ToolTip("found " & Hex($color, 6) & @CRLF & Hex($color2, 6) & " " & $pop_pos[0] & "x" & $pop_pos[1], 0, 0)
		If $move = 1 Then MouseMove($pop_pos[0], $pop_pos[1])
		Return $color2
	Else
		ToolTip("not found", 0, 0)
		SetError(1)
		Return 0
	EndIf

EndFunc   ;==>findPixelAtMouse

; use getcursorinfo to handle pop
Func scanPop2()
	Local $dif, $cursor1, $cursor2, $cur, $pre
	Local $step2 = $step

	;reset position/timer
	MouseMove($wow_x1, $wow_y1, 0)
	$begin = TimerInit()

	;init cursor
	$cursor1 = _WinAPI_GetCursorInfo()
	$pre = $cursor1[2]

	Send(1) ;throwPole
	Sleep(1000)

	;scan pop
	GUICtrlSetData($_gid_status, "扫描鱼漂 ... ")
	For $y = $wow_y1 To $wow_y2 Step $step2
		For $x = $wow_x1 To $wow_x2 Step $step2
			MouseMove($x, $y, 0)
			Sleep(Random(60, 110, 1))

			$cursor2 = _WinAPI_GetCursorInfo()
			$cur = $cursor2[2]

			If $cur <> $pre Or $running = 0 Or TimerDiff($begin) > $max_time Then
				ExitLoop (2)
			EndIf
		Next
		$step2 = $step2 + 1
	Next

	If $cur <> $pre Then
		monitorPop()
	Else
		$bad += 1
	EndIf
EndFunc   ;==>scanPop2







Func drawAllPos()
	drawWowPos()
	Sleep(500)
EndFunc   ;==>drawAllPos

Func drawWowPos()
	MouseMove($wow_x1, $wow_y1, 0)
	MouseMove($wow_x2, $wow_y1)
	MouseMove($wow_x2, $wow_y2)
	MouseMove($wow_x1, $wow_y2)
	MouseMove($wow_x1, $wow_y1)
EndFunc   ;==>drawWowPos


Func ToggleRunning()
	If $running = 0 Then
		$running = 1
	Else
		$running = 0
	EndIf

	If $running = 1 Then
		GUICtrlSetState($r_wow_pos1, $GUI_DISABLE)
		GUICtrlSetState($r_wow_pos2, $GUI_DISABLE)
		GUICtrlSetData($b_start_stop, "停止")
		doFishing()
	Else
		GUICtrlSetState($r_wow_pos1, $GUI_ENABLE)
		GUICtrlSetState($r_wow_pos2, $GUI_ENABLE)
		GUICtrlSetData($b_start_stop, "开始")
	EndIf
EndFunc   ;==>ToggleRunning


;ESC hit
Func escGetPos()
	;如果在钓鱼，按ESC就退出
	If $running = 1 Then
		ToggleRunning()
		Return
	EndIf

	;Local $a = GUIGetCursorInfo()
	Local $a = MouseGetPos()

	Select
		Case BitAND(GUICtrlRead($r_wow_pos1), $GUI_CHECKED) = $GUI_CHECKED
			GUICtrlSetData($l_wow_pos1, $a[0] & "," & $a[1])
			$wow_x1 = $a[0]
			$wow_y1 = $a[1]
			GUICtrlSetState($r_wow_pos2, $GUI_CHECKED)
		Case BitAND(GUICtrlRead($r_wow_pos2), $GUI_CHECKED) = $GUI_CHECKED
			GUICtrlSetData($l_wow_pos2, $a[0] & "," & $a[1])
			$wow_x2 = $a[0]
			$wow_y2 = $a[1]
			GUICtrlSetState($r_wow_pos2, $GUI_UNCHECKED)
			drawAllPos()
			GUICtrlSetState($b_start_stop, $GUI_FOCUS)
	EndSelect
EndFunc   ;==>escGetPos


Func guiClose()
	Exit
EndFunc   ;==>guiClose
