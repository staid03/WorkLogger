#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance , force

;Script for logging all work performed.
;Example use = determining how long spent on each task

;Version	Date		Author		Notes
;	0.1		17-MAR-2017	Staid03		Initial
;	0.2		08-APR-2017	Staid03		Including username on logon (could be any user on the computer)

EnvGet , computerName , COMPUTERNAME
EnvGet , userName , USERNAME

workLoggerOutputFile = workLogger_%computerName%.csv
fileappend , Login by %USERNAME%`n, %workLoggerOutputFile%
sleepTimeSeconds = 4
sleepTime := sleepTimeSeconds * 1000
previousWindow = null

main:
{
	loop ,
	{
		GoSub , getWindow
		GoSub , compareWindow
		Sleep , %sleepTime%		
	}
}
Return

getWindow:
{
	WinGetActiveTitle , activeWindow
}
Return

compareWindow:
{
	IfNotEqual , activeWindow , %previousWindow%
	{
		previousWindow = %activeWindow%
		FormatTime , ddate , , dd/MM/yy
		FormatTime , ttime , , HH:mm:ss
		WinGet , process , ProcessName , A
		outLine = %ddate%,%ttime%, %process% , %activeWindow%
		FileAppend , %outline%`n , %workLoggerOutputFile%
	}
}
Return 