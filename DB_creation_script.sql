--create database for File Stocktake
--create database if not exists 'File_Stocktake';
-- USE 'File_Stocktake';
--
-- Version	Date		Author 			Notes
--	0.1		14-MAR-2017	Staid03			initial
--	0.2		20-MAR-2017	Staid03			adding md5Checksum field




DROP TABLE 'Files';

CREATE TABLE IF NOT EXISTS 'Files' (
	-- 'ID' int(8) NOT NULL,
	'ScriptTimeStamp' int(8) DEFAULT NULL,
	'DriveName' varchar(20) DEFAULT NULL,
	'FileLocation' varchar(100) DEFAULT NULL,
	'FileLocationCleanRequired' int(1) DEFAULT NULL,
	'FileName' varchar(100) DEFAULT NULL,
	'FileNameCleanRequired' int(1) DEFAULT NULL,
	'FileExt' varchar(10) DEFAULT NULL,
	'FileExtCleanRequired' int(1) DEFAULT NULL,
	'FileSizeBytes' int(8) DEFAULT NULL,
	'MD5Checksum' varchar(32) DEFAULT NULL,
	'FileTimeModified' int(8) DEFAULT NULL,
	'FileTimeCreated' int(8) DEFAULT NULL	
);