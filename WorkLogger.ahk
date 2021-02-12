#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance , force
#include %A_ScriptDir%\notifylockunlock.ahk
notify_lock_unlock()

;Script for logging all work performed.
;Example use = determining how long spent on each task

;Version	Date		Author		Notes
;	0.1		17-MAR-2017	Staid03		Initial
;	0.2		08-APR-2017	Staid03		Including username on logon (could be any user on the computer)
;	0.3		05-MAR-2019	Staid03		Adding workstation lock and unlock events
;	0.4		12-FEB-2021	Staid03		Trimming the window so it removes unnecessary whitespace

computerName := getComputerName()
userName := getUser()

outputFolder = d:\startup\
ifnotexist , %outputFolder%
filecreatedir , %outputFolder%

workLoggerOutputFile = %outputFolder%workLogger_%computerName%.csv
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
	WinGetActiveTitle , activeWin
	activeWindow := Trim(activeWin)
}
Return

compareWindow:
{
	IfNotEqual , activeWindow , %previousWindow%
	{
		previousWindow = %activeWindow%
		WinGet , process , ProcessName , A
		outLine = %process%,%activeWindow%
		appendLog(outLine)
	}
}
Return

on_lock()
{
	userName := getUser()
	action = LOCKED_WS,%userName%
	appendLog(action)
}

on_unlock()
{
	userName := getUser()
	action = UNLOCKED_WS,%userName%
	appendLog(action)
}

appendLog(input)
{
	global workLoggerOutputFile
	FormatTime , ddate , , dd/MM/yy
	FormatTime , ttime , , HH:mm:ss
	DateTimeStamp = %ddate%,%ttime%
	FileAppend , %DateTimeStamp%`,%input%`n , %workLoggerOutputFile%
}
Return

getUser()
{
	EnvGet , userName , USERNAME
	Return userName
}
Return

getComputerName()
{
	EnvGet ,computerName , COMPUTERNAME
	Return computerName
}
Return