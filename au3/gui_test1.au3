#include-once
#include <GUIConstantsEx.au3>
#include "gui_rgb_group.au3"
Opt("GUIOnEventMode", 1) ; Change to OnEvent mode
;;;;;;;;;;;;;;;
;;; Main GUI
;;;;;;;;;;;;;;;
Global $hGui = GUICreate("hello world", 500, 400, 100, 100)
GUISetOnEvent($GUI_EVENT_CLOSE, "guiClose")

;;;;;;;;;;;;;;;
;;; GUI Control
;;;;;;;;;;;;;;;
createGroupRGB(0,0,200,120)

;;;;;;;;;;;;;;;
GUISetState(@SW_SHOW, $hGui)

While 1
	Sleep(100)
WEnd

Func guiClose()
	Exit
EndFunc   ;==>guiClose

