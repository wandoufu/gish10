#include <GUIConstantsEx.au3>
Opt("GUIOnEventMode", 1) ; Change to OnEvent mode
;;;;;;;;;;;;;;;
;;; Main GUI
;;;;;;;;;;;;;;;
Global $hGui = GUICreate("hello world", 500, 400, 100, 100)

;;;;;;;;;;;;;;;
;;; GUI Control
;;;;;;;;;;;;;;;
;Group rgb setting
Global $rgb, $id_rroup_rgb, $id_input_r, $id_input_g, $id_input_b, $id_label_rgb
Global $radio_rgb[3], $id_radio_rgb[3]
;RGB group start
$id_rroup_rgb = GUICtrlCreateGroup("RGB Setting", 10, 10, 180, 150)
;input
$id_input_r = GUICtrlCreateInput("000", 30, 32, 30, 20)
$id_input_g = GUICtrlCreateInput("255", 60, 32, 30, 20)
$id_input_b = GUICtrlCreateInput("0x80", 90, 32, 30, 20)
;label show color
$id_label_rgb = GUICtrlCreateLabel("", 120, 32, 50, 20)

;
$radio_rgb[0] = 0x0000FF
$radio_rgb[1] = 0x00FF00
$radio_rgb[2] = 0xFF0000
createRadioRGB()
;RGB group done
GUICtrlCreateGroup("", -99, -99, 1, 1)



;ctrl event: rgb setting
GUICtrlSetOnEvent($id_input_r, "updateRGB2")
GUICtrlSetOnEvent($id_input_g, "updateRGB2")
GUICtrlSetOnEvent($id_input_b, "updateRGB2")

;init
updateRGB()

;;;;;;;;;;;;;;;
;Main GUI
;;;;;;;;;;;;;;;
;set event start
GUISetOnEvent($GUI_EVENT_CLOSE, "guiClose")
GUISetState(@SW_SHOW, $hGui)

While 1
	Sleep(100)
WEnd

Func guiClose()
	Exit
EndFunc   ;==>guiClose


;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;


Func readInputRGB()
	Local $R = Number(GUICtrlRead($id_input_r))
	$R = BitShift(BitAND(0xFF, $R), -16)
	Local $G = Number(GUICtrlRead($id_input_g))
	$G = BitShift(BitAND(0xFF, $G), -8)
	Local $B = Number(GUICtrlRead($id_input_b))
	$B = BitAND(0xFF, $B)
	$rgb = BitOR($R, $G, $B)

EndFunc   ;==>readInputRGB

;read input, update color,
Func updateRGB2()
	updateRGB()
	clearRadioRGB()
EndFunc   ;==>updateRGB2

;	radio unchecked(default)
Func updateRGB()
	readInputRGB() ;global $rgb
	GUICtrlSetData($id_rroup_rgb, "RGB Setting 0x" & Hex($rgb, 6))
	GUICtrlSetBkColor($id_label_rgb, $rgb)
EndFunc   ;==>updateRGB

; radio change
Func radioSetRGB()
	Local $num = UBound($radio_rgb) - 1
	Local $color = 0
	For $i = 0 To $num
		If GUICtrlRead($id_radio_rgb[$i]) = $GUI_CHECKED Then
			$color = $radio_rgb[$i]
			ExitLoop
		EndIf
	Next
	If $color = $rgb Then Return

	;writeInputRGB
	$rgb = $color
	Local $R = decodeRGB()
	GUICtrlSetData($id_input_r, $R[2])
	GUICtrlSetData($id_input_g, $R[1])
	GUICtrlSetData($id_input_b, $R[0])
	updateRGB()

EndFunc   ;==>radioSetRGB

;decode global $rgb to $rgb[3]
Func decodeRGB()
	Local $color[3]
	$color[0] = BitAND(0xFF, $rgb)
	$color[1] = BitAND(0xFF, BitShift($rgb, 8))
	$color[2] = BitAND(0xFF, BitShift($rgb, 16))
	Return $color
EndFunc   ;==>decodeRGB


Func createRadioRGB()
	Local $num = UBound($radio_rgb) - 1
	For $i = 0 To $num
		$id_radio_rgb[$i] = GUICtrlCreateRadio("0x" & Hex($radio_rgb[$i], 6), 30, 60 + 20 * $i, 70)
		GUICtrlSetOnEvent($id_radio_rgb[$i], "radioSetRGB")
	Next
EndFunc   ;==>createRadioRGB
Func clearRadioRGB()
	Local $num = UBound($radio_rgb) - 1
	For $i = 0 To $num
		GUICtrlSetState($id_radio_rgb[$i], $GUI_UNCHECKED)
	Next

EndFunc   ;==>clearRadioRGB
