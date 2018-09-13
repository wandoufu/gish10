#include-once
#include <GUIConstantsEx.au3>
#include "gui_rgb_group.au3"
#include "gui_cursor_icon.au3"
Opt("GUIOnEventMode", 1) ; Change to OnEvent mode
;;;;;default GDI+ startup
_GDIPlus_Startup()
;;;;;;;;;;;;;;;
;;; Main GUI
;;;;;;;;;;;;;;;
Global $hGui = GUICreate("hello world", 500, 400, 100, 100)
GUISetOnEvent($GUI_EVENT_CLOSE, "guiClose")

;;;;;;;;;;;;;;;
;;; GUI Control
;;;;;;;;;;;;;;;
createGroupRGB(0, 0, 200, 120)
createCursorButton( 10, 200)

;;;;;;;;;;;;;;;
GUISetState(@SW_SHOW, $hGui)

While 1
	Sleep(100)
WEnd

Func guiClose()
	_GDIPlus_Shutdown()
	Exit
EndFunc   ;==>guiClose

