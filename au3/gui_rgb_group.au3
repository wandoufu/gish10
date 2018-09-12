#include-once
#include <GUIConstantsEx.au3>
#cs
support the global $rgb with ctrl:
   input: user define: R,G,B
   radio: pre-define: rgb
#ce

Global $rgb=0, $id_rroup_rgb, $id_input_rgb[3], $id_label_rgb
Global $g_radio_rgb[3], $id_radio_rgb[3]

;sevearl predefined rgb:
$g_radio_rgb[0] = 0x0000FF
$g_radio_rgb[1] = 0x00FF00
$g_radio_rgb[2] = 0xFF0000

;RGB group create and init { 3 input, 1 label, 3 radio
Func createGroupRGB($rgb_x=0,$rgb_y=0,$rgb_width=180,$rgb_height=150)
   ;group start
   $id_rroup_rgb = GUICtrlCreateGroup("RGB Setting", $rgb_x+10,$rgb_y+10, $rgb_width, $rgb_height)

   ;add 3 inputs to set RGB, and set Event
   For $i = 0 To 2 Step +1
      $id_input_rgb[$i] = GUICtrlCreateInput(100*$i+$i+5, $rgb_x+30+30*$i, $rgb_y+32, 30, 20)
      GUICtrlSetOnEvent($id_input_rgb[$i], "updateRGB2")
   Next

   ;add label to show color
   $id_label_rgb = GUICtrlCreateLabel("", $rgb_x+120,$rgb_y+32, 50, 20)

   ;add predefined rgb as radio, and set Event
	Local $num = UBound($g_radio_rgb) - 1
	For $i = 0 To $num
		$id_radio_rgb[$i] = GUICtrlCreateRadio("0x" & Hex($g_radio_rgb[$i], 6), $rgb_x+30, $rgb_y+60+20*$i, 70)
		GUICtrlSetOnEvent($id_radio_rgb[$i], "readRadioRGB")
	Next

   ;RGB group done 
   GUICtrlCreateGroup("", -99, -99, 1, 1)

   ;init
   readInputRGB()
   writeLableRGB()

EndFunc
;}


;;;;;;;;;;;;;;;;;;;;;;;
; Ctrl operations:
;;;;;;;;;;;;;;;;;;;;;;;
; input -> rgb
Func readInputRGB()
   Local $input_rgb=0
   For $i = 0 To 2
	   Local $in = Number(GUICtrlRead($id_input_rgb[$i]))
	   $input_rgb = BitOR($input_rgb,BitShift( BitAND(0xFF, $in), 8*($i-2)))
      ;MsgBox(64,"input rgb",$in &" "& hex($input_rgb,6))
   Next

   If ($rgb = $input_rgb) Then
      Return 0
   Else
      $rgb = $input_rgb
      Return 1
   EndIf
EndFunc   ;==>readInputRGB

;rgb -> input
Func writeInputRGB()
   For $i = 0 To 2
	   Local $color = BitAND(0xFF, BitShift($rgb, $i*8))
	   GUICtrlSetData($id_input_rgb[2-$i], $color)
   Next
EndFunc   ;==>writeInputRGB

;rgb -> label
Func writeLableRGB()
	GUICtrlSetData($id_rroup_rgb, "RGB Setting 0x" & Hex($rgb, 6))
	GUICtrlSetBkColor($id_label_rgb, $rgb)
EndFunc

; uncheck radio, when input event happend
Func clearRadioRGB()
	Local $num = UBound($g_radio_rgb) - 1
	For $i = 0 To $num
		GUICtrlSetState($id_radio_rgb[$i], $GUI_UNCHECKED)
	Next
EndFunc   ;==>clearRadioRGB

; (Radio EVENT) read radio, set input, refresh label
Func readRadioRGB()
	Local $num = UBound($g_radio_rgb) - 1
	Local $color = 0
	For $i = 0 To $num
		If GUICtrlRead($id_radio_rgb[$i]) = $GUI_CHECKED Then
			$color = $g_radio_rgb[$i]
			ExitLoop
		EndIf
	Next
	If $color = $rgb Then Return

	;writeInputRGB
	$rgb = $color
	writeInputRGB()
   writeLableRGB()
EndFunc   ;==>readRadioRGB


;(Input EVENT)read input, update color, clear radio
Func updateRGB2()
	Local $chg = readInputRGB()
   If $chg = 1 Then writeLableRGB()
	clearRadioRGB()
EndFunc   ;==>updateRGB2
