local composer = require( "composer" )
local scene = composer.newScene()
composer.removeHidden() 

display.setStatusBar( display.HiddenStatusBar )
local widget = require("widget")
loc = require( "loc" )
menu = require( "menu" )
MD = require( "mydata" )
IO = require( "datainout" )
CI = require( "chartinfo" )
NT=require( "navtide" )
ui = require( "ui" )
notes = require( "notes" )
navMaths = require( "navmaths" )
zoom = require( "zoom" )
routes = require( "routes" )
init = require( "init" )
picker = require( "datepicker" )
dec = require ("decrypt_chart")
reg = require ("reg")

isBasic=false

doTrack,doHarbour,doTide,doLight,doNM,doCS,doSC=false,false,false,true,false,false,false
-- isDemo=true
productName="realchart_us"
versionNum="1.0.8"
productDisplayName="DEMO VERSION - Chesapeake"
region="chesapeake"
topC=50.9228
botC=50.5
chartH=topC-botC

chartChooseFile="chartchooser_"..region

moveAwayCount=0 -- used in tracking
isGPS=true
local platform=system.getInfo( "architectureInfo" )
if (platform =="iPad2,1") or (platform =="iPad2,5")  or (platform =="iPad3,1")  or (platform =="iPad3,4")  or (platform =="iPad4,4") then isGPS=false end

theDate=os.date( "%Y".."-".."%m".."-".."%d" )
theTime=os.time( t )
splashPage="splash"

environment = system.getInfo( "environment" )
platformName=system.getInfo( "platformName" )
isPhone=(system.getInfo("model")=="iPhone")

if platformName=="Android" then
	local approximateDpi = system.getInfo("androidDisplayApproximateDpi")
	local widthInInches = display.pixelWidth / approximateDpi
	local heightInInches = display.pixelHeight / approximateDpi
	local diagonal= math.sqrt((heightInInches*heightInInches)+(widthInInches*widthInInches))
	if diagonal<7 then isPhone=true end
end

local lfs = require( "lfs" )
local folderList={"tides","importedGPX","dataout","routes","info","help","data"}
for i=1, 7 do
	local docs_path = system.pathForFile( "", system.DocumentsDirectory )
	local success = lfs.chdir( docs_path ) --returns 'true' on success
	local new_folder_path

	local dname = folderList[i]
	if ( success ) then
		lfs.mkdir( dname )
		new_folder_path = lfs.currentdir() .. "/" .. dname
	end
end

local myInstallDate=IO.loadFile("appinstall.txt")	
local errorInfo=IO.loadFile("data/error.txt")
local regInfo=IO.loadFile("reg.txt")
local ortInfo=IO.loadFile("ort.txt")
if errorInfo~=nil and errorInfo[1]==1 then errorReporting=true end
if regInfo~=nil then isReg=true end
ort="V"
if ortInfo~=nil then ort=ortInfo[1] end
xmlFile=region.."_rc"

composer.gotoScene( "splash")



