#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#singleinstance , force

;Script for creating a CSV containing all file details from a specified location

;Version	Date		Author		Notes
;	0.1		14-MAR-2017	Staid03		Initial
;	0.2		15-MAR-2017	Staid03		Updating for C drive. Fixed an issue with Y flags not cleaning up the FileLocation.
;	0.3		19-MAR-2017	Staid03		Added md5checksum retrieval and addition to JSON file

formattime , atime ,, yyyyMMdd_HHmmss

infolder = d:\
givenNameForTheDrive = laptop_c
outputFile = FileStockTake_%givenNameForTheDrive%_%atime%.json
jsonProgram = "C:\Program Files (x86)\Notepad++\notepad++.exe"
md5checksumProgram = fciv.exe
checksumoutfile = ~checksumoutfile.xml
md5checksum = null				;if the md5checksumProgram doesn't exist or can't be found then md5checksum will equal "null" string
exclusionExt = xls|doc|png		;just examples
exclusionExtArray := StrSplit(exclusionExt, "|")
exclusionDir = $RECYCLE.BIN|system|System32|Program Files|DIAD|eSupport|Logs|NVIDIA|PerfLogs|Users|Windows|Boot|ProgramData
exclusionDirArray := StrSplit(exclusionDir, "|")

testlimit = 2
anum = 1

main:
;declare a main body
{
	FormatTime , nTimeStamp , , yyyyMMddHHmm
	;begin looping through each file from the specified source folder
	oDirCheck = 
	gosub , beginJSONFile					;create the JSON file and the first few lines
	loop , %infolder%*.* , 0 , 1
	{
		;search through the specified folder for files to collect metadata on		
		gosub , resetVars					;reset the variables
		SplitPath , a_loopfilefullpath , oFileName , oDir , oExt , oNameNoExt , oDrive
		gosub , excludedFileCheck			;check if this file/folder has been excluded from being recorded
		ifequal , excluded , y				;if it has been returned to exclude this file/folder, then move onto the next file
		{
			continue
		}
		ifnotequal , oDirCheck , %oDir%
		{
			oDirCheck = %oDir%
			DRVarClean = N
			if oDir is not space 
			{
				varToClean = DRClean_%oDir%
				gosub , cleanVar		
				oDir = %cleanVarOut%
			}
			ifgreater , anum , 1
			{
				gosub , fileLocationJSON
			}
			else 
			{

				gosub , newfileLocationJSON
			}
		}
		FileGetSize , oSize , %a_loopfilefullpath% , 
		FileGetTime , oModifiedTimeRaw , %a_loopfilefullpath% , M
		FileGetTime , oCreatedTimeRaw , %a_loopfilefullpath% , C
		{
			FNVarClean = N
			if oFileName is not space
			{
				varToClean = FNClean_%oFileName%
				gosub , cleanVar		
				oFileName = %cleanVarOut%
			}
			
			EXVarClean = N
			if oExt is not space
			{
				varToClean = EXClean_%oExt%
				gosub , cleanVar
				oExt = %cleanVarOut%
			}		
		}	
		ifexist , %md5checksumProgram%				;if it doesn't exist or can't be found it will equal "null" string
		{
			gosub , generateMD5Checksum
		}		
		gosub , createJSON
		ifequal , anum , %testlimit%				;break the loop upon reaching testlimit variable loop times
		{
			break
		}
		anum++
	}
	gosub , endJSONFile
	run , %jsonProgram% %outputFile%
}
return

resetVars:
;reset the variables for the next iteration of the loop
{
	oFileName = 
	oDir = 
	oExt = 
	oSize = 
	oModifiedTimeRaw = 
	oCreatedTimeRaw = 
	excluded = n
}
return

excludedFileCheck:
;check for any excluded file types
{
	Loop % exclusionDirArray.MaxIndex()
	{
		exclusionDir := exclusionDirArray[a_index]
		ifinstring , oDir , %exclusionDir%
		{
			excluded = y
			break
		}
	}	
}
return 

cleanVar:
;runs through the vars that could have talking marks in them to remove the talking marks for JSON file
;creates a record of which variable was required to be cleaned
{
	cleanVarOut = 
	ifinstring , varToClean , "		;"
	{
		msgbox ,,, file found with talking marks - %a_loopfilefullpath%
		stringreplace , cleanVarOut , varToClean , " , - , A		;"
		stringleft , cleanedVarType , varToClean , 2
		ifequal , cleanedVarType , FN
		{
			FNVarClean = Y
		}
		ifequal , cleanedVarType , DR
		{
			DRVarClean = Y
		}
		ifequal , cleanedVarType , EX
		{
			EXVarClean = Y
		}
	}
	
	ifinstring , varToClean , '
	{
		msgbox ,,, file found with single talking mark - %a_loopfilefullpath%
		stringreplace , cleanVarOut , varToClean , ' , - , A		;"
		stringleft , cleanedVarType , varToClean , 2
		ifequal , cleanedVarType , FN
		{
			FNVarClean = Y
		}
		ifequal , cleanedVarType , DR
		{
			DRVarClean = Y
		}
		ifequal , cleanedVarType , EX
		{
			EXVarClean = Y
		}
	}
		stringtrimleft , cleanVarOut , varToClean , 8
}
return 

generateMD5Checksum:
{
	filedelete , %checksumoutfile%
	runwait , %comspec% /c fciv.exe "%a_loopfilefullpath%" > %checksumoutfile% ,, hide
	sleep , 10
	filereadline , md5line , %checksumoutfile% , 4
	stringleft , md5checksum , md5line , 32
}
return

beginJSONFile:
{
	outputline = {`n
	outputline = %outputline%	"ScriptTimeStamp": "%nTimeStamp%"`n
	outputline = %outputline%	"DriveName": "%givenNameForTheDrive%"`n
	outputline = %outputline%	"FileLocationDetails": `n	{
	
	fileappend , %outputline% , %outputFile%
}
return 

fileLocationJSON:
{
	outputline = `n
	outputline = %outputline%	}`n
	outputline = %outputline%	"FileLocationDetails": `n	{
	
	fileappend , %outputline% , %outputFile%
}

newfileLocationJSON:
{
	outputline = `n
	outputline = %outputline%		"FileLocation": "%oDir%"`n
	outputline = %outputline%		"FileLocationCleanRequired": "%DRVarClean%"
	
	fileappend , %outputline% , %outputFile%
}
return

createJSON:
;create the JSON file
{
	;outputline = 	{`n
	outputline = `n
	outputline = %outputline%		"FileDetails": `n		{`n
	outputline = %outputline%			"FileName": "%oFileName%"`n
	outputline = %outputline%			"FileNameCleanRequired": "%FNVarClean%"`n
	outputline = %outputline%			"FileExt": "%oExt%"`n
	outputline = %outputline%			"FileExtCleanRequired": "%EXVarClean%"`n
	outputline = %outputline%			"FileSizeBytes": "%oSize%"`n
	outputline = %outputline%			"FileTimeModified": "%oModifiedTimeRaw%"`n
	outputline = %outputline%			"FileTimeCreated": "%oCreatedTimeRaw%"`n
	outputline = %outputline%			"md5checksum": "%md5checksum%"`n
	outputline = %outputline%		}
	
	fileappend , %outputline% , %outputFile%
}
return 

endJSONFile:
{
	outputline = 
	outputline = `n	}`n}
	
	fileappend , %outputline% , %outputFile%
}
return 