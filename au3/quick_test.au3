
Local $t 
ConsoleWrite($t)
if ($t) then 
   ConsoleWrite("it is defined"&@CRLF)
Else
   ConsoleWrite("it is not defined"&@CRLF)
EndIf

$t = TimerInit()
ConsoleWrite($t)
if ($t) then 
   ConsoleWrite("it is defined"&@CRLF)
Else
   ConsoleWrite("it is not defined"&@CRLF)
EndIf

Sleep(1000)

ConsoleWrite(TimerDiff($t) &@CRLF)
$t = TimerInit()
ConsoleWrite($t)
if ($t) then 
   ConsoleWrite("it is defined"&@CRLF)
Else
   ConsoleWrite("it is not defined"&@CRLF)
EndIf