#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <ScreenCapture.au3>
#cs
	save mouse position
#ce
Global Const $iWidth = 50, $iHeight = 50, $iX = 8, $iY = 3, $iWait = 500
;-50,-50 ~ +50,+50
Global $hGUI, $hGraphics
Global $running = 0, $x = 0, $y = 0

Opt("GUIOnEventMode", 1) ; Change to OnEvent mode
Opt('MustDeclareVars', 1) ; 变量必须被预先定义dim local global
Opt('GUICloseOnESC', 0) ; ESC 不是退出

HotKeySet("{Esc}", "saveMousePic")
HotKeySet("!{Esc}", "toggleRunning")

Example()

Func Example()
	_GDIPlus_Startup() ;initialize GDI+

	Local $title = "ESC to capture mouse, alt-ESC continue capture mouse"
	$hGUI = GUICreate($title, $iWidth * ($iX * 2 + 1), $iHeight * ($iY * 2 + 1), 0, 0, -1, $WS_EX_TOPMOST) ;create a test GUI
	GUISetOnEvent($GUI_EVENT_CLOSE, "guiClose")
	GUISetState(@SW_SHOW)

	$hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGUI) ;create a graphics object from a window handle

	While (1)
		If $running = 1 Then saveMousePic()
		Sleep($iWait)
	WEnd

EndFunc   ;==>Example

Func guiClose()
	;cleanup GDI+ resources
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_Shutdown()
	GUIDelete($hGUI)
	Exit
EndFunc   ;==>guiClose

Func toggleRunning()
	$running = BitXOR($running, 1)
	If $running Then
		ToolTip("running", 0, 0)
	Else
		ToolTip("")
	EndIf
EndFunc   ;==>toggleRunning

Func saveMousePic()
	Local $aPos = MouseGetPos()
	Local $x1, $y1, $x2, $y2
	$x1 = $aPos[0] - $iWidth
	If $x1 < 0 Then $x1 = 0
	$y1 = $aPos[1] - $iHeight
	If $y1 < 0 Then $y1 = 0
	$x2 = $aPos[0] + $iWidth
	$y2 = $aPos[1] + $iHeight

	Local $mouse	; save screen with mouse?
	If $running = 0 Then
		;ToolTip($aPos[0] & "x" & $aPos[1], $aPos[0], $aPos[1])
		;Sleep(100)
		$mouse = True
	Else
		$mouse = False
	EndIf

	Local $hHBmp, $hBitmap
	$hHBmp = _ScreenCapture_Capture("", $x1, $y1, $x2, $y2, $mouse) ;create a GDI bitmap by capturing an area on desktop
	$hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBmp) ;convert GDI to GDI+ bitmap
	_WinAPI_DeleteObject($hHBmp) ;release GDI bitmap resource because not needed anymore

	_GDIPlus_GraphicsDrawImage($hGraphics, $hBitmap, $x * $iWidth * 2, $y * $iHeight * 2) ;copy negative bitmap to graphics object (GUI)
	$x += 1
	If $x = $iX Then
		$x = 0
		$y += 1
		If $y = $iY Then $y = 0
	EndIf


EndFunc   ;==>saveMousePic

