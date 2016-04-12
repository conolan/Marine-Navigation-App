local M = {}  --create the local module table (this will hold our functions and data)
local http = require("socket.http")
local ltn12 = require("ltn12")
local urlOperations = require("socket.url")
local urlEncode = urlOperations.escape

function M.saveRoute(name,theRoute)
	local filename = name..".txt"
	local path = system.pathForFile( "routes/"..filename, system.DocumentsDirectory )
	local file = io.open(path, "w")
	if ( file ) then

		file:write( theRoute )
		io.close( file )
		doMessage("File saved "..filename,",",2,3000)
		return true
	else
		doMessage( "Error: could not save ".. filename,",",2,3000 )
		return false
	end
end

function M.deleteRoute(name)
	if (name~=nil) then
		local results, reason = os.remove( system.pathForFile( "routes/"..name..".txt", system.DocumentsDirectory  ) )
	end
end

function M.saveNotes(fileName,data)
	local filename =fileName
	local path = system.pathForFile( filename, system.DocumentsDirectory )
	local file = io.open(path, "a")
	if ( file ) then

		file:write( data )
		io.close( file )
		return true
	else
		print( "Error: could not read ", filename, "." )
		return false
	end
end

function M.saveOverFile(fileName,data)
	local filename =fileName
	local path = system.pathForFile( filename, system.DocumentsDirectory )
	local file = io.open(path, "w")
	if ( file ) then
		file:write( data )
		io.close( file )
		return true
	else
		print( "Error: could not read ", filename, "." )
		return false
	end
end

function M.appendFile(fileName,data)
	local filename =fileName
	local path = system.pathForFile( filename, system.DocumentsDirectory )
	local file = io.open(path, "w")
	if ( file ) then
		file:write( data )
		io.close( file )
		return true
	else
		print( "Error: could not read ", filename, "." )
		return false
	end
end

function M.saveTrack(theTrack)
	local filename = "myTracks.txt"
	local path = system.pathForFile( filename, system.DocumentsDirectory )
	local file = io.open(path, "a")
	if ( file ) then
		file:write( theTrack )
		io.close( file )
		return true
	else
		print( "Error: could not read ", filename, "." )
		return false
	end
end

function M.saveWayPoints()
	local filename = "myWayPoints.txt"
	local thePoints=""
	if (table.maxn(myWayPoints)>1) then
		for i=1,table.maxn(myWayPoints)-1 do
			--local fileTable = myWayPoints[i]:split(",")
			thePoints=thePoints..table.concat(myWayPoints[i],",").."\n"
		end
	end
	if (table.maxn(myWayPoints)>0) then
		thePoints=thePoints..table.concat(myWayPoints[table.maxn(myWayPoints)],",")
	end
	local path = system.pathForFile( filename, system.DocumentsDirectory )
	local file = io.open(path, "w")
	if ( file ) then
		file:write( thePoints )
		io.close( file )
		return true
	else
		print( "Error: could not read ", filename, "." )
		return false
	end
end

function M.saveMarks(thePoints)
	local filename = "myMarks.txt"
	local path = system.pathForFile( filename, system.DocumentsDirectory )
	local file = io.open(path, "a")
	if ( file ) then
		file:write( thePoints )
		io.close( file )
		return true
	else
		print( "Error: could not read ", filename, "." )
		return false
	end
end

function string:split( inSplitPattern, outResults )

   if not outResults then
      outResults = { }
   end
   local theStart = 1
   local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   while theSplitStart do
      table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
      theStart = theSplitEnd + 1
      theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
   end
   table.insert( outResults, string.sub( self, theStart ) )
   return outResults
end

function M.loadFile(fileName,directory)
	baseDir=directory or system.DocumentsDirectory
	local path = system.pathForFile( fileName, baseDir )
	local contents = ""
	local file = io.open( path, "r" )
	if ( file ) then
	  -- read all contents of file into a string
	  local contents = file:read( "*a" )
	  local fileTable = contents:split("\n")
	  io.close( file )
	  return fileTable
	else
	  print( "Error: could not read ", fileName, "." )
	  return nil
	end
   --return nil
end

function M.checkRouteFiles()
	local routeList = {}
	local lfs = require "lfs"
	local doc_path = system.pathForFile( "routes/", system.DocumentsDirectory)
	for file in lfs.dir(doc_path) do
	   --file is the current file or directory name
	   if (file~=".") and (file~="..") then table.insert(routeList,file) end
	end
	if #routeList==0 then doMessage("No routes saved",",",2,3000) end
	return routeList
end

function M.loadLightFile(fileName)
	local path = system.pathForFile( fileName, system.DocumentsDirectory )
	local contents = ""
	local file = io.open( path, "r" )
	if ( file ) then
	  -- read all contents of file into a string
	  local contents = file:read( "*a" )
	  local fileTable = contents:split("\n")
	  io.close( file )
	  return fileTable
	else
	  print( "Error: could not read ", path )
	  return nil
	end
   --return nil
end

function M.checkFile(fileName)
	local path = system.pathForFile( fileName, system.DocumentsDirectory )
	local contents = ""
	local file = io.open( path, "r" )
	if ( file ) then
	  io.close( file )
	  return true
	else
	  return nil
	end
end

function M.makeHexCode()
	local myCode=""
	local hex={"a","b","c","d","e","f"}
	for i=1,8 do
		local x=math.random(15)
		if x>9 then x=hex[x-9] end
		myCode=myCode..x
	end
	return myCode
end

function M.shareWPg7t()
	myWayPoints=M.loadFile("myWayPoints.txt")
	local g7t="Version 2:G7T\nD WGS-84\nM DMM\n\n"
	for i=1,#myWayPoints do
		if (myWayPoints[i]~="") then 
			local fileTable = myWayPoints[i]:split(",")
			local dmmLat=navMaths.ddd2dmm(tonumber(fileTable[3]))
			local dmmLong=navMaths.ddd2dmm(tonumber(fileTable[4]))
			local wp1=fileTable[2]
			local lenWP=string.len(wp1)
			for i = 1,16-lenWP do
				wp1=wp1.." "
			end
			
			local wp2=math.abs(dmmLat[2])
			local lenWP=string.len(wp2)
			for i = 1,8-lenWP do
				wp2=wp2.." "
			end
			
			local wp3=math.abs(dmmLong[1])
			local lenWP=string.len(wp3)
			for i = 1,3-lenWP do
				wp3="0"..wp3
			end
			
			local newWP="W  "..wp1.."N"..dmmLat[1].." "..wp2.."W"..wp3.." "..dmmLong[2].."\n"
			g7t=g7t..newWP
		end
	end

	clearPanel()
	M.saveOverFile("waypoints.g7t",g7t)
	M.sendEmail("","Waypoints file from ChartsNav","Files from Chartsnav","waypoints.g7t","txt","No email options. File not sent")
	newHex=M.makeHexCode()
	
	-- Access Google over SSL:
	network.request( "http://www.realcharts.net/dataops/placeG7T.php?code="..newHex.."&wpinfo="..g7t, "GET", networkListener )
	doMessage("This is your unique code for downloading your waypoint file\n\n"..newHex.."\n\nYou can access this at www.chartsnav.com/getwaypoint",",",2,5000)
end

function M.shareWPgpx()
	local myWayPoints=M.loadFile("myWayPoints.txt")
	local gpx="<?xml version='1.0' encoding='UTF-8' standalone='no' ?><gpx version='1.1' creator='realcharts.net'> "
	local tail="<sym>Waypoint</sym></wpt>"
	for i=1,#myWayPoints do
		if (myWayPoints[i]~="") then 
			local fileTable = myWayPoints[i]:split(",")
			local wLat=fileTable[3]
			local wLong=fileTable[4]
			local wp1=fileTable[2]
						
			local newWP="<wpt lat='"..wLat.."' lon='"..wLong.."'><time>"..fileTable[5].."</time><name>"..fileTable[2].."</name><cmt>"..fileTable[1].."</cmt><desc></desc>"..tail
			gpx=gpx..newWP
		end
	end
	gpx=gpx.."</gpx>"
	clearPanel()
	M.saveOverFile("dataout/waypoints.gpx",gpx)
	--M.sendEmail("","Waypoints file from ChartsNav","Files from Chartsnav","waypoints.gpx","txt","No email options. File not sent")
	newHex=M.makeHexCode()	
	network.request( "http://www.realcharts.net/dataops/placeGPX.php?code="..newHex.."&wpinfo="..gpx, "GET", networkListener )
	local rtemsg="This is your unique code for downloading your waypoint file\n\n"..newHex.."\n\nYou can access this at www.realcharts.net/getroute"
	thePanel=ui.makeReadNotesPanel(110,10,600,250,rtemsg,"greybutton","Done",clearPanel)
	screenGroup:insert(thePanel)
end

local function routeListener(event)
	if ( event.isError ) then
		doMessage( "Network error! Either you don't have a network connection or the server is down","",2)
	else
		local rtemsg="This is your unique code for downloading your route/track file\n\n"..newHex.."\n\nYou can access this at www.realcharts.net/getroute"
		thePanel=ui.makeReadNotesPanel(110,10,600,250,rtemsg,"greybutton","Done",clearPanel)
		screenGroup:insert(thePanel)
	end
end
	
function M.shareRTgpx()
	clearPanel()
	local whichRoute=routeNameTable[1]
	local myRoute=M.loadFile("routes/"..whichRoute..".txt")
	local gpx="<?xml version='1.0' encoding='UTF-8' standalone='no' ?><gpx version='1.1' creator='realcharts.net'><metadata><time>"
	local tail="<sym>Waypoint</sym></rtept>"
	
	if (myRoute~="") then 	
		local fileTable = myRoute[1]:split(",")
		gpx=gpx..fileTable[2].."</time><author>realcharts.net customer</author></metadata><rte><name>"..fileTable[1].."</name><time>"..fileTable[2].."</time>"
		for i = 2,#myRoute do
			fileTable = myRoute[i]:split(",")
			local newWP="<rtept lat='"..fileTable[2].."' lon='"..fileTable[3].."'><name>"..fileTable[1].."</name><cmt>"..fileTable[1].."</cmt><desc></desc>"..tail
			gpx=gpx..newWP
		end
		gpx=gpx.."</rte></gpx>"
		
		--M.saveOverFile("dataout/"..whichRoute..".gpx",gpx)
		--M.sendEmail("","Waypoints file from ChartsNav","Files from Chartsnav","waypoints.gpx","txt","No email options. File not sent")
		newHex=M.makeHexCode()
		
		gpx = urlEncode(gpx)
		local urlString="http://www.realcharts.net/dataops/placeGPX.php?code="..newHex.."&wpinfo="..gpx
		network.request(urlString , "GET", routeListener )
	else
		doMessage("No Route","",2)
	end
end

function M.shareTrack()
	clearPanel()
	local whichRoute=routeNameTable[1]
	local myTrack=M.loadFile("myTracks.txt")
	local myTrackData=""
	for i=1,#myTrack-1 do
		myTrackData=myTrackData..myTrack[i].."\n"
	end
	myTrackData=myTrackData..myTrack[#myTrack]
	
	if (myTrack~="") then 	
		myTrackData = urlEncode(myTrackData)
		newHex=M.makeHexCode()
		local urlString="http://www.realcharts.net/dataops/placeTrack.php?code="..newHex.."&wpinfo="..myTrackData
		network.request(urlString , "GET", routeListener )
	else
		doMessage("No Track","",2)
	end
	
end

function M.emailTrack()
	local myTracks=M.loadFile("myTracks.txt")
	local trackData=""
	for i=1,#myTracks do
		trackData=trackData..myTracks[i].."\n"
	end
	clearPanel()
	M.sendEmail("","Tracks file from ChartsNav","Tracks from Chartsnav","myTracks.txt","txt","No email options. File not sent")
	newHex=M.makeHexCode()	
	-- Access Google over SSL:
	--network.request( "http://www.realcharts.net/dataops/placeTrack.php?code="..newHex.."&wpinfo="..trackData, "GET", networkListener )
	--doMessage("This is your unique code for downloading your track file\n\n"..newHex.."\n\nYou can access this at www.chartsnav.com/gettrack")
end

function M.loadTrack()
	clearPanel()
	loginGroup=display.newGroup()
	local nR,nG,nB,w,h=.5,.6,1,840,400
	local panelRect = display.newRoundedRect(120,20,w,h,10)
	panelRect:setFillColor(nR,nG,nB)
	panelRect:setStrokeColor(nR-0.3,nG-0.3,nB-0.3)
	panelRect.strokeWidth = 2
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	local textWidth=w-20
	local textheight=h-20
	loginGroup:insert(panelRect)
	local textOptions={parent=loginGroup, text="This is your means of importing a Track file that you have uploaded to Realcharts.net.\nIf you haven't uploaded a file in the last 24 hours, please click cancel.",x=512,y=60,width=800,height=100,font=native.systemFont,fontSize=20,align="center"}
	disText = display.newText(textOptions)
	disText:setFillColor(0,0,0)
	disText.anchorX = 0.5
	disText.anchorY = 0
	local textOptions={parent=loginGroup, text="Please enter your Track reference number in the field below\nThe reference number is a combination of 8 letters and numbers",x=512,y=180,width=800,height=100,font=native.systemFont,fontSize=24,align="center"}
	disText = display.newText(textOptions)
	disText:setFillColor(1,1,1)
	disText.anchorX = 0.5
	disText.anchorY = 0
	screenGroup:insert(loginGroup)
	
	inputField1 = native.newTextField( 512, 150, 180, 60 )
	loginGroup:insert(inputField1)
	inputField1.font = native.newFont( native.systemFont )
	inputField1.userInput = codeHandler
	inputField1.placeholder="code"
	inputField1.size = 36
	
	subButton=ui.makeButton(512-90,300,180,60,"bluebutton","Send Login",M.importTrack)
	loginGroup:insert(subButton)
	cancelButton=ui.makeButton(740,340,180,60,"greybutton","cancel",clearLogin)
	loginGroup:insert(cancelButton)
	screenGroup:insert(loginGroup)
end

local function textListener( event )
	if ( event.isError ) then
			doMessage( "Network error!","",2)
	else
		thePanel=ui.makeReadNotesPanel(110,10,600,250,"An error has occured and a report sent to Realcharts.net\nWe hope this has not inconvenienced you\nAn update may be available soon to rectify the issue","greybutton","Done",clearPanel)
		screenGroup:insert(thePanel)
	end
end

function M.uploadError(errorM,lastP)

	local errorM = urlEncode(errorM)
	if lastP=="" or lastP==nil then lastP="None" end
	local netString="http://www.realcharts.net/dataops/logerror.php?error="..errorM.."&panel="..lastP
	network.request( netString, "GET", textListener,params )
end

function M.parseGPX(fileName)	
	local routexml = xmlapi:loadFile(fileName,system.DocumentsDirectory)
	--local routexml = xmlapi:loadFile("FileOut.gpx")
	local waypData,waypLineData,routeData={},{},{}
	for i=1, #routexml.child do
		if (routexml.child[i].name=="wpt") then
			waypLineData={0}
			
			for j=1,#routexml.child[i].child do
				
				if (routexml.child[i].child[j].name=="name") then table.insert(waypLineData,routexml.child[i].child[j].value) end
				-- if (routexml.child[i].child[j].name=="cmt") then table.insert(waypData,routexml.child[i].child[j].value) end
				-- if (routexml.child[i].child[j].name=="desc") then table.insert(waypData,routexml.child[i].child[j].value) end
				-- if (routexml.child[i].child[j].name=="sym") then table.insert(waypData,routexml.child[i].child[j].value) end
				-- if (routexml.child[i].child[j].name=="extensions") then 
					-- for k=1,#routexml.child[i].child[j].child do
						-- for l=1,#routexml.child[i].child[j].child[k].child do
							-- print(routexml.child[i].child[j].child[k].child[l].value)
						-- end
					-- end
				-- end
				
			end
			table.insert(waypLineData,routexml.child[i].properties["lat"])
			table.insert(waypLineData,routexml.child[i].properties["lon"])
			table.insert(waypData,waypLineData)
		end
		
		if (routexml.child[i].name=="rte") then
			local routeOutput,routeLoc={},{}
			routeText=""
			routeName="noname"
			if (routexml.child[i].child[1].name=="name") then 
				routeName=routexml.child[i].child[1].value
				routeText=routeText..routexml.child[i].child[1].value..","
			else
				routeName="unnamed"
				routeText=routeText.."unnamed,"
			end
			if (routexml.child[i].child[2].name=="time") then 
				routeText=routeText..routexml.child[i].child[2].value.."\n"
			else
				routeText=routeText.."notime\n"
			end

			for j=1,#routexml.child[i].child do
				if (routexml.child[i].child[j].name=="rtept") then
					local routeLocData={}
					table.insert(routeLocData,routexml.child[i].child[j].properties["lat"])
					table.insert(routeLocData,routexml.child[i].child[j].properties["lon"])
					
					
					for k=1,#routexml.child[i].child[j].child do
						if (routexml.child[i].child[j].child[k].name=="name") then 
							table.insert(routeLocData,routexml.child[i].child[j].child[k].value) 
							routeText=routeText..routexml.child[i].child[j].child[k].value..","
						end
						-- if (routexml.child[i].child[j].child[k].name=="cmt") then table.insert(routeData,routexml.child[i].child[j].child[k].value) end
						-- if (routexml.child[i].child[j].child[k].name=="desc") then table.insert(routeData,routexml.child[i].child[j].child[k].value) end
						-- if (routexml.child[i].child[j].child[k].name=="sym") then table.insert(routeData,routexml.child[i].child[j].child[k].value) end
					end
					routeText=routeText..routexml.child[i].child[j].properties["lat"]..","
					routeText=routeText..routexml.child[i].child[j].properties["lon"]..",\n"
					table.insert(routeLoc,routeLocData)
				end
				table.insert(routeOutput,routeName)
				table.insert(routeOutput,routeLoc)
			end
			table.insert(routeData,routeOutput)
		end
	end
	return waypData,routeText,routeName
end

local codeHandler = function( event )
	--called from input text on panels
	if "began" == event.phase then

	elseif "editing" == event.phase then
									
	elseif "ended" == event.phase then
		native.setKeyboardFocus( nil )
	elseif "submitted" == event.phase then
		native.setKeyboardFocus( nil )
	end
end

function M.loadGPX()
	clearPanel()
	loginGroup=display.newGroup()
	local nR,nG,nB,w,h=.5,.6,1,840,400
	local panelRect = display.newRoundedRect(120,20,w,h,10)
	panelRect:setFillColor(nR,nG,nB)
	panelRect:setStrokeColor(nR-0.3,nG-0.3,nB-0.3)
	panelRect.strokeWidth = 2
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	local textWidth=w-20
	local textheight=h-20
	loginGroup:insert(panelRect)
	local textOptions={parent=loginGroup, text="This is your means of importing a GPX file that you have uploaded to Realcharts.net.\nIf you haven't uploaded a file in the last 24 hours, please click cancel.",x=512,y=60,width=800,height=100,font=native.systemFont,fontSize=20,align="center"}
	-- local textOptions={parent=loginGroup, text="This is your means of importing a GPX file that you have uploaded to Realcharts.net.\nNot yet available.",x=512,y=160,width=800,height=100,font=native.systemFont,fontSize=20,align="center"}
	disText = display.newText(textOptions)
	disText:setFillColor(0,0,0)
	disText.anchorX = 0.5
	disText.anchorY = 0
	local textOptions={parent=loginGroup, text="Please enter your GPX reference number in the field below\nThe reference number is a combination of 8 letters and numbers",x=512,y=180,width=800,height=100,font=native.systemFont,fontSize=24,align="center"}
	disText = display.newText(textOptions)
	disText:setFillColor(1,1,1)
	disText.anchorX = 0.5
	disText.anchorY = 0
	screenGroup:insert(loginGroup)
	
	inputField1 = native.newTextField( 512, 150, 180, 60 )
	loginGroup:insert(inputField1)
	inputField1.font = native.newFont( native.systemFont )
	inputField1.userInput = codeHandler
	inputField1.placeholder="code"
	inputField1.size = 36
	
	subButton=ui.makeButton(512-90,300,180,60,"bluebutton","Send Login",M.importGPX)
	loginGroup:insert(subButton)
	cancelButton=ui.makeButton(740,340,180,60,"greybutton","cancel",clearLogin)
	loginGroup:insert(cancelButton)
	screenGroup:insert(loginGroup)
end

function clearLogin()
	display.remove(loginGroup)
end

local function fileListener( event )					
	if ( event.isError ) then
		doMessage( "Network error - download failed" ,",",2,3000)
		return nil			
	elseif ( event.phase == "ended" ) then				 
		if event.status ~= 200 then doMessage("Error - connected to the server but download failed\nPlease check your code",",",2,3000); return; end
		doMessage( "Download complete",",",2,3000 ) 	   
		myWayPoints,routeText,routeName=M.parseGPX(theFile)
		
		if routeText~="" or routeText~=nil then

			IO.saveRoute(routeName,routeText)			
			routes.loadRoutes(routeName..".txt")
		end
		if #myWayPoints>0 then
			M.saveWayPoints()
			loadWayPoints()
		end
	end
end

local function trackListener( event )					
	if ( event.isError ) then
		doMessage( "Network error - download failed" ,",",2,3000)
		return nil			
	elseif ( event.phase == "ended" ) then				 
		if event.status ~= 200 then doMessage("Error - connected to the server but download failed\nPlease check your code",",",2,3000); return; end
		doMessage( "Download complete",",",2,3000 ) 	   
		
			loadTracks()
			return true
	end
end

function M.importGPX()
	local pCode=inputField1.text
	if environment == "simulator" then pCode="db851263" end
	theFile="importedGPX/"..pCode..".gpx"
	network.download( "http://www.realcharts.net/dataops/wpfiles/"..pCode..".gpx", "GET", fileListener, theFile,system.DocumentsDirectory)
	display.remove(loginGroup)
end

function M.importTrack()
	local pCode=inputField1.text
	if environment == "simulator" then pCode="fe9374d4" end
	theFile="myTracks.txt"
	network.download( "http://www.realcharts.net/dataops/wpfiles/"..pCode..".txt", "GET", trackListener, theFile,system.DocumentsDirectory)
	display.remove(loginGroup)
end


function M.sendEmail(fTo,fSub,message,fFile,fType,errorMessage)
	local options
	if ( native.canShowPopup( "mail" ) ) then
		if (fFile~="") then
			options =
			{	
			to=fTo,
			subject = fSub,
			body = message,
			attachment = { baseDir=system.DocumentsDirectory,filename=fFile, type=fType },
			}
		else
			options =
			{	
			to=fTo,
			subject = fSub,
			body = message,
			}
		end
		native.showPopup("mail", options)
	else
		doMessage(errorMessage,"",1)
	end
end
 
function M.deleteRouteFiles()
	local lfs = require "lfs"
	local doc_path = system.pathForFile( "routes/", system.DocumentsDirectory)
	for file in lfs.dir(doc_path) do
	   --file is the current file or directory name
		if (file~=".") and (file~="..") then 
			local results, reason = os.remove( system.pathForFile( "routes/"..file, system.DocumentsDirectory  ) )
			emptyGroup(routeGroup)
			routes.clearRoute()
			if results then doMessage("Route files deleted","",2) end
		end
	end
end

function M.deleteAppFiles()
	local lfs = require "lfs"
	local doc_path = system.pathForFile( "", system.DocumentsDirectory)
	for file in lfs.dir(doc_path) do
	   --file is the current file or directory name
		if (file~=".") and (file~="..") then 
			local results, reason = os.remove( system.pathForFile( file, system.DocumentsDirectory  ) ) 
			if results then doMessage("Application files deleted. Go to start to reload charts and data will be downloaded","",2) end
		end
	end
end

function M.deleteDataFile()
	local results, reason = os.remove( system.pathForFile( "datainstall.txt", system.DocumentsDirectory  ) ) 
	if results then doMessage("Data files deleted. Go to start to reload data","",2) end
end

function M.deleteTideFile()
	local results, reason = os.remove( system.pathForFile( "tideinstall.txt", system.DocumentsDirectory  ) ) 
	if results then doMessage("Data files deleted. Go to start to reload data","",2) end
end

function M.deleteWPFile()
	local filename = "myWayPoints.txt"
	local results, reason = os.remove( system.pathForFile( filename, system.DocumentsDirectory  ) )
end

return M