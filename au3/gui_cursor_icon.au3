
#cs
	copy current cursor and put it in a icon control
	GUICtrlSendMsg


	Func createIcon
	GUICtrlCreateIcon()
	EndFunc
#ce

#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <GDIPlus.au3>

Global $id_gui_icon, $id_gui_btn , $cur_xor_sum=0

#cs
_GDIPlus_Startup()
GUICreate("My GUI") ; will create a dialog box that when displayed is centered

createCursorButton(50,50)

GUISetState(@SW_SHOW)

	; Loop until the user exits.
	While 1
		Switch GUIGetMsg()
			Case $id_gui_btn
				putButtonCursor()
			Case $GUI_EVENT_CLOSE
				_GDIPlus_Shutdown()
				ExitLoop

		EndSwitch
	WEnd
#ce


Func createCursorButton($x=0,$y=0)
   GUICtrlCreateGroup("Capture Cursor with Button",$x,$y, 150,70)
	   $id_gui_icon = GUICtrlCreateIcon("", 0, $x+10, $y+30)
	   $id_gui_btn = GUICtrlCreateButton("OK", $x+50, $y+30, 80);, 32, $BS_ICON)
	   GUICtrlSetOnEvent($id_gui_btn, "putButtonCursor")
   GUICtrlCreateGroup("",-99,-99)

   ConsoleWrite("create cursor button done"&@CRLF)
EndFunc   ;==>createCursorButton

;
Func calBitmapId($hBmp)
	Local $tSIZE = _WinAPI_GetBitmapDimension($hBmp)
	Local $W = DllStructGetData($tSIZE, 'X')
	Local $H = DllStructGetData($tSIZE, 'Y')

	Local $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hBmp) ;convert GDI to GDI+ bitmap

	Local $sum = $W*256+$H ;bitxor($W,$H)
	For $x = 0 To $W - 1 Step 5
		For $y = 0 To $H - 1 Step 5
			Local $pixel = _GDIPlus_BitmapGetPixel($hBitmap, $x, $y)
			$sum = BitXOR($sum, $pixel)
		Next
	Next
	Return BitAND(0xFFFFFF,$sum)
EndFunc   ;==>calBitmapId

;match cur_xor_sum
Func getCursorSum()
	Local $aCursor = _WinAPI_GetCursorInfo()
   Local $sum = 0
	If Not @error And $aCursor[1] Then
	   Local $hIcon = _WinAPI_CopyIcon($aCursor[2])
	   Local $aIcon = _WinAPI_GetIconInfo($hIcon)
		If Not @error Then
	      $sum = calBitmapId($aIcon[5])
	      _WinAPI_DeleteObject($aIcon[4]) ; delete bitmap mask return by _WinAPI_GetIconInfo()
	      If $aIcon[5] <> 0 Then _WinAPI_DeleteObject($aIcon[5]) ; delete bitmap hbmColor return by _WinAPI_GetIconInfo()
      EndIf
	   _WinAPI_DestroyIcon($hIcon)
   EndIf
   ConsoleWrite("get cursor sum done:"&hex($sum)&@CRLF)
   Return $sum
EndFunc

Func compareCursor()
	Local $sum = getCursorSum()
   If $sum <> $cur_xor_sum Then
      return 0
   Else
      return 1
   EndIf
EndFunc

Func putButtonCursor()
   ;we can copy cursor to icon directly
	Local $aCursor = _WinAPI_GetCursorInfo()
   consoleWrite("putButtonCursor start" & $aCursor[2]&@CRLF)
	GUICtrlSendMsg($id_gui_icon, $STM_SETIMAGE, 1, $aCursor[2])

	Local $sum = getCursorSum()
   If $sum <> $cur_xor_sum Then
		GUICtrlSetData($id_gui_btn, Hex($sum, 6))
      $cur_xor_sum = $sum
   EndIf

EndFunc   ;==>putButtonCursor

