#include <AutoItConstants.au3>
;2018-09-13
; a dynamic global var create and used, 
; it can work, but not easy used
; KISS, take care about it

createGlobalVar()
createGlobalVar("new")
createGlobalVar()
MsgBox(64,"", " my_1 ="&eval("my_1") & " new_3="& eval("new_3"))

Func createGlobalVar($prefix="my")
   Local $vVar, $status
   For $i = 0 To 5 Step +1
      $vVar = $prefix & "_" & $i
      $status = IsDeclared($vVar)   ; $DECLARED_GLOBAL $DECLARED_LOCAL $DECLARED_UNKNOWN
      If Not $status Then
         ConsoleWrite("decalre gloabl "&$vVar&@CRLF)
         Assign($prefix&"_"&$i, $i, $ASSIGN_FORCEGLOBAL )
      ElseIf $status = $DECLARED_LOCAL Then
         ConsoleWrite("error: "&$vVar & " has been declared:DECLARED_LOCAL" & @CRLF)
      ElseIf $status = $DECLARED_GLOBAL Then
         ConsoleWrite("error: "&$vVar & " has been declared:DECLARED_GLOBAL " & @CRLF)
      Endif
   Next
EndFunc
