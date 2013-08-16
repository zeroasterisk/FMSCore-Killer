; Demonstrates StdoutRead()
#include <Constants.au3>

Global $adminPass = "xxxxxxxxxx"

Local $foo = RunAs("Administrator","",$adminPass,4,@ComSpec & " /c " & '"c:\Windows\system32\pv.exe" -qb -l *flvplayer*app*  FMSCore*', @SystemDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
;sleep(2000)
Local $line
While 1
    $line = StdoutRead($foo)
    If @error Then ExitLoop
	If $line <> "" Then
		;MsgBox(0, "STDOUT read:", "LINE = [" & StringStripCR($line) & "]")
		; // crazy split needed to split on the ASCI chars 10 & 13
		Local $splitWithASCII[2]
		$splitWithASCII[0]="10"
		$splitWithASCII[1]="13"
		$splitWith = StringFromASCIIArray($splitWithASCII)
		; // split lines
		$lines = StringSplit($line, $splitWith)
		FOR $pid IN $lines
			If $line <> "" AND $pid > 100 Then
				; // if PID seems valid,
				MsgBox(0, "STDOUT read:", "Looking At PID = [" & $pid & "]",2)
				ParseAndKillOnPID($pid)
			EndIf
		NEXT
	EndIf
Wend

While 1
    $line = StderrRead($foo)
    If @error Then ExitLoop
	If $line <> "" Then
		MsgBox(0, "STDERR read:", "ERROR: " & $line,5)
	EndIf
Wend


Func ParseAndKillOnPID($thePID)
	Local $pattern = 'FMSCore\s{0,}(\d{0,})\s{0,}\d{0,}\s{0,}\d{0,}\s{0,}\d{0,}\s{0,}\d{0,}\s{0,}\d{0,}:\d{0,}:\d{0,}.\d{0,}\s{0,}(\d{0,}):'
	Local $maxHoursToRun = 5

	;Local $foo = RunWait(@ComSpec & " /c " & '"c:\Program Files (x86)\SysinternalsSuite\pslist.exe" FMSCore', @SystemDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	Local $foo = Run(@ComSpec & " /c " & '"c:\Windows\system32\pslist.exe" ' & $thePID, @SystemDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
	Local $line
	While 1
		$line = StdoutRead($foo)
		If @error Then ExitLoop
		If $line <> "" Then
			;MsgBox(0, "Match:", '[' & StringRegExp($line,$pattern) & '] -- ' & $pattern)
			$asResult = StringRegExp($line,$pattern,1)
			If @error == 0 Then
				MsgBox(0, "Top FMSCoreProcess", "PID: " & $asResult[0] & " Running For: " & $asResult[1] & " Hours",2)
				;// If running for more than $maxHoursToRun hours, Kill it
				if ($asResult[1] > $maxHoursToRun AND $asResult[1] < 12) Then
					MsgBox(0, "Ready to Kill:", "Ready to kill " & $asResult[0],2)
					Local $fooKill = RunAs("Administrator","",$adminPass,4,@ComSpec & " /c " & '"c:\Windows\system32\pskill.exe" ' & $asResult[0], @SystemDir, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
					Local $lineKill
					While 1
						$lineKill = StdoutRead($fooKill)
						If @error Then ExitLoop
						If $lineKill <> "" Then
							MsgBox(0, "STDOUT read:", $lineKill,2)
						EndIf
					Wend
				Else
					MsgBox(0, "No Kill:", "Not Going to kill " & $asResult[0],2)
				EndIf
			EndIf
		EndIf
	Wend
EndFunc

MsgBox(0, "Debug", "Exiting...",3)
Exit
