#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <ScreenCapture.au3>
#include <WinAPIHObj.au3>

Example()

Func Example()
   _GDIPlus_Startup() ;initialize GDI+
   Local Const $iWidth = 80, $iHeight = 150, $cnt = 20
   Local $hGUI = GUICreate("GDI+ Example (" & @ScriptName & ")", $iWidth*$cnt, $iHeight,0,0) ;create a test GUI
   GUISetState(@SW_SHOW)
   Local $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGUI) ;create a graphics object from a window handle

   Local $iColor = 0
   Local $hHBmp, $hBitmap
   For $i=0 To $cnt
	Local $aPos = MouseGetPos()
	Local $x1,$y1,$x2,$y2
	$x1 = $aPos[0]
	$y1 = $aPos[1]
	$x2 = $x1 + $iWidth
	$y2 = $y1 + $iHeight


	  $hHBmp = _ScreenCapture_Capture("", $x1, $y1, $x2, $y2, false) ;create a GDI bitmap by capturing an area on desktop
	  $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBmp) ;convert GDI to GDI+ bitmap
	  _GDIPlus_GraphicsDrawImage($hGraphics, $hBitmap, $i*($x2-$x1), 0) ;copy negative bitmap to graphics object (GUI)
	  Sleep(500)
   Next


	_WinAPI_DeleteObject($hHBmp) ;release GDI bitmap resource because not needed anymore
#cs
	For $iY = 0 To $iHeight - 1
		For $iX = 0 To $iWidth - 1
			$iColor = _GDIPlus_BitmapGetPixel($hBitmap, $iX, $iY) ;get current pixel color
			_GDIPlus_BitmapSetPixel($hBitmap, $iX, $iY, BitXOR(0x00FFFFFF, $iColor)) ;invert RGB pixel color only
		Next
	Next
#ce


	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE

	;cleanup GDI+ resources
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_Shutdown()
	GUIDelete($hGUI)
EndFunc   ;==>Example
