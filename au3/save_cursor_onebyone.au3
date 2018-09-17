#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <ScreenCapture.au3>
#include <WinAPIHObj.au3>

HotKeySet("{ESC}", "saveCursor")
Global $hGUI, $cnt=0, $cnt_max=13 ,$hGraphics, $hBitmap
Global Const $iWidth = 80, $iHeight = 150

Example()

Func Example()
   _GDIPlus_Startup() ;initialize GDI+
   
   $hGUI = GUICreate("GDI+ Example (" & @ScriptName & ")", $iWidth*$cnt_max, $iHeight,0,0) ;create a test GUI
   
   $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGUI) ;create a graphics object from a window handle

;saveCursor()
   GUISetState(@SW_SHOW)

	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	;cleanup GDI+ resources
		_WinAPI_DeleteObject($hBitmap) ;release GDI bitmap resource because not needed anymore

	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_Shutdown()
	GUIDelete($hGUI)
EndFunc   ;==>Example

Func saveCursor()

   Local $hHBmp
	Local $aPos = MouseGetPos()
	Local $x1,$y1,$x2,$y2
	$x1 = $aPos[0]-$iWidth/2
	$y1 = $aPos[1]-$iHeight/2
	$x2 = $x1 + $iWidth/2
	$y2 = $y1 + $iHeight/2
tooltip($x1&"x"&$y1)

	  $hHBmp = _ScreenCapture_Capture("", $x1, $y1, $x2, $y2, false) ;create a GDI bitmap by capturing an area on desktop
	  $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBmp) ;convert GDI to GDI+ bitmap
	  _GDIPlus_GraphicsDrawImage($hGraphics, $hBitmap, $cnt*$iWidth, 0) ;copy negative bitmap to graphics object (GUI)


	_WinAPI_DeleteObject($hHBmp) ;release GDI bitmap resource because not needed anymore
	$cnt+=1
	if $cnt>$cnt_max Then $cnt=0

EndFunc