local composer = require( "composer" )
local scene = composer.newScene()
composer.removeHidden() 

local widget = require("widget")
local http = require("socket.http")
local ltn12 = require("ltn12")

leftEdge,rightEdge,topEdge,bottomEdge,screenHeight,screenWidth=display.screenOriginX, display.contentWidth-display.screenOriginX, display.screenOriginY,display.contentHeight -display.screenOriginY,display.contentHeight-display.screenOriginY*2,display.contentWidth-display.screenOriginX*2

local background,cName
local subOn,inputName,waypNum,mainInfogroup
local deleteWP,waypEdit,getWPText,makeMark,clearLast,cancelWP
local startWayPoint,checkMark,chartOut,startChart
local switchday,switchLock,switchTracking,isTide,isMoveWP
local appName = system.getInfo( "appName" )

segDist=0
MD.multiplier=1
myWayPoints,tdTable,tdNameTable,hbTable,hbNameTable,scNameTable,markTable,markNameTable,routeTable,routeNameTable,routePix,gotoTable={},{},{},{},{},{},{},{},{},{},{},{},{},{}
viewButtons,toolButtons={false,false,false,false,false,false,false,false},{false,false,false,false,false,false}
-- chartOutlines,waypoits, routes,tides,harbours,lights,nm,clubs - night,lock,screencap,writenotes,prefs,readnotes
routePos,waypNum=0,0
local wR,wG,wB =1,0,0 --waypoint colour
local rR,rG,rB =0,0,1 --routpoint colour
local lR,lG,lB =0,1,0 --routline colour
local nightMode,optionMessageOn=false,true
canEditRoute,markOn=false,false
veryShortTimeOut,shortTimeOut,longTimeOut= 1000,3000,50000

system.activate( "multitouch" )

newChartPointer=0
if (lastChart==nil) then lastChart={1} end

local onSystem = function( event )
    if event.type == "applicationStart" then

    elseif event.type == "applicationExit" then

    elseif event.type == "applicationSuspend" then
		IO.saveOverFile("appsuspend.txt",theTime)
    elseif event.type == "applicationResume" then
        local mySuspentDate=IO.loadFile("appsuspend.txt")
		local hoursSinceRun=(theTime-mySuspentDate[1])/60/60
		if (hoursSinceRun>23) then composer.gotoScene( splashPage) end
    end
end

prevTime=system.getTimer()

Runtime:addEventListener( "system", onSystem )

local function myUnhandledErrorListener( event )

    local iHandledTheError = true
    if iHandledTheError then
	--alert = native.showAlert(  "Handling the unhandled error", event.errorMessage, { "NEXT" } )
	--doMessage(event.errorMessage)
	if lastPanel==nil then lastPanel="none" end
	IO.uploadError(string.gsub(event.errorMessage,"'",""),lastPanel)
	--captureScreenError(event.errorMessage)
	init.initChart(1)
    else
		alert = native.showAlert(  "Not handling the unhandled error", event.errorMessage, { "NEXT" } )
    end
    return iHandledTheError
end

-- if environment ~= "simulator" then Runtime:addEventListener("unhandledError", myUnhandledErrorListener) end
if errorReporting then Runtime:addEventListener("unhandledError", myUnhandledErrorListener) end

function scene:create( event )	

	screenGroup = self.view
	uiGroup=display.newGroup()
	backRect = display.newRect(leftEdge,topEdge,screenWidth,screenHeight)

	backRect:setFillColor(.7968,.7968,.7968)
	-- backRect:setFillColor(.6,.6,.6)
	backRect.anchorX = 0
	backRect.anchorY = 0
	screenGroup:insert(backRect)
	mainInfogroup=ui.getInfoGroup(leftEdge)
	uiGroup:insert(mainInfogroup)
	
	locGroup=display.newGroup()
	local textOptions, behindRect 
	if (isPhone) then 
		behindRect = display.newRect(locGroup,165,0,880,130)
		textOptions={parent=locGroup,text=system.getInfo( "architectureInfo"),x=190,y=0,width=900,height=120,font=native.systemFont,fontSize=48,align="left"}
	else
		behindRect= display.newRect(locGroup,110,0,880,70)
		textOptions={parent=locGroup,text=system.getInfo( "architectureInfo"),x=140,y=0,width=500,height=40,font=native.systemFont,fontSize=24,align="left"}
		textOptions2={parent=locGroup,text="",x=700,y=0,width=400,height=60,font=native.systemFont,fontSize=24,align="left"}
		targetIcon = display.newImageRect(locGroup, "images/marks/target.png", 40,40 )
		targetIcon.x,targetIcon.y=650,30
	end
	
	behindRect:setFillColor(1,1,1,0.8)
	behindRect.anchorX = 0
	behindRect.anchorY = 0
	boat = display.newImageRect(locGroup, "images/boatIcon.png", 20,40 )
	boat.x,boat.y=125,35
	if (isPhone) then boat.x,boat.y=180,25 end
	
	locInfo = display.newText(textOptions)
	locInfo:setTextColor(.2,.2,.2,1)
	locInfo.anchorX = 0
	locInfo.anchorY = 0
	if (not isPhone) then 
		targetInfo = display.newText(textOptions2)
		targetInfo:setTextColor(.2,.2,.2,1)
		targetInfo.anchorX = 0
		targetInfo.anchorY = 0
	end
	--locGroup.alpha=0
	uiGroup:insert(locGroup)
		
	wpInfoGroup=display.newGroup()
	local behindRect = display.newRoundedRect(wpInfoGroup,rightEdge-245,520,240,160,10)
	behindRect:setFillColor(1,1,1,0.8)
	behindRect:setStrokeColor(.5,.5,.5)
	behindRect.strokeWidth = 2
	behindRect.anchorX = 0
	behindRect.anchorY = 0
	
	local textOptions={parent=uiGroup, text="realcharts.net "..productName.." "..versionNum,x=rightEdge-285,y=5,width=280,height=15, font=native.systemFont,fontSize=12}
	rcInfo = display.newText(textOptions)
	rcInfo:setFillColor(0,0,0)
	rcInfo.alpha=0.6
	rcInfo.anchorX = 0
	rcInfo.anchorY = 0
	
	local textOptions={parent=wpInfoGroup, text="",x=rightEdge-235,y=525,width=220,height=150, font=native.systemFont,fontSize=24, align=center}
	wpInfo = display.newText(textOptions)
	wpInfo:setFillColor(0,0,1)
	wpInfo.anchorX = 0
	wpInfo.anchorY = 0
	uiGroup:insert(wpInfoGroup)
	wpInfoGroup.alpha=0
	wpInfoGroup.touch = switchInfoListener
	wpInfoGroup:addEventListener( "touch", wpInfoGroup )
	chartInfo=CI.getList()
	if (chartPointer==nil) then chartPointer=1 end
	init.initChart(chartPointer)
	if chartPointer~=1 then chartBackButton.alpha=1 end
	crossContainer=display.newGroup()
	local crossH = display.newLine(crossContainer, 512,336,512,416 )
	crossH:setStrokeColor( 1, 0, 0, 1 )
	crossH.strokeWidth = 2
	crossContainer:insert(crossH)
	local crossV = display.newLine(crossContainer, 472,384,552,384 )
	crossV:setStrokeColor( 1, 0, 0, 1 )
	crossV.strokeWidth = 2
	crossContainer:insert(crossV)
	crossContainer.alpha=0.5
	uiGroup:insert(crossContainer)
	if isFinger then
		finger=display.newImageRect("images/righthand.png",218,300)
		finger.anchorX=0.2
		finger.anchorY=0.15
		uiGroup:insert(finger)
		finger.alpha=0
		
		finger2=display.newImageRect("images/lefthand.png",218,300)
		finger2.anchorX=0.2
		finger2.anchorY=0.15
		uiGroup:insert(finger2)
		finger2.alpha=0
	end
	screenGroup:insert(uiGroup)	
	
	nightGroup=display.newGroup()
	local n = display.newRect(leftEdge,topEdge,screenWidth,screenHeight)
	n.anchorX = 0
	n.anchorY = 0
	screenGroup:insert(n)
	n:setFillColor(0,0,0,0.5)
	nightGroup:insert(n)
	nightGroup.alpha=0
	return screenGroup	
	
end

function emptyGroup(theGroup,num)
	local start=num or 1
	if (theGroup~=nil) and (theGroup.numChildren~=0) then
		for i=1,theGroup.numChildren do
			display.remove(theGroup[1])
		end
	end
end
-- functions on chart
function chartBack()
	clearPanel()		
	table.remove(lastChart)
	chartPointer=lastChart[table.maxn(lastChart)]
	if isRoute then routes.clearRoute() end
	init.initChart(chartPointer)
	if chartPointer~=1 then chartBackButton.alpha=1 end
end

function subListener(self,touch)
-- called from touch on rects created in displayRect
-- move to subChart
	--if (thePanel==nil) then
		local phase = touch.phase
		if ( phase == "began" ) then				
			-- these variables read in submitmarkforpositioning
			if (newChartPointer==0) then
				self.alpha=0.4
				self.strokeWidth=6/MD.multiplier
				timer.performWithDelay(1000,function() self.alpha=1 self.strokeWidth=3/MD.multiplier end)
				newChartOut=chartInfo[self.chart][6]
				newChartPointer=self.chart
				newChartNum=chartInfo[self.chart][1]	
			end
		elseif phase=="moved" then
			newChartPointer=0
		elseif phase=="ended" or phase=="cancelled" then
			newChartPointer=0
		end
	--end
	--if (not isRoute) then return true end
end

function chartIn()
	-- chartPointer=newChartPointer
	-- newChartPointer=0
	clearPanel()
	table.insert(lastChart,chartPointer)
	init.initChart(chartPointer)
	if daysSinceInstall<1 then
		chartBackButton.xScale=2
		chartBackButton.yScale=2
		chartBackButton.alpha=1
		transition.to(chartBackButton,{time=500,xScale=1,yScale=1})
	else
		chartBackButton.alpha=1
	end
	return true
end

function chartIn_co()
	init.initChart(chartPointer)
end

function nextChart()
	
end

function selectChart()
	clearPanel()
	composer.gotoScene( chartChooseFile)
end

function markListener(touch, event)
	--attached to all waypoints , marks and route dots
	local myType=event.target.type
	local markNum=event.target.num	

	if finger~=nil then 
		uiGroup:toFront()
		if (fTimer~=nil) then timer.cancel( fTimer ) end
		transition.to(finger,{time=50,alpha=1})
		transition.to(finger,{time=200,x=event.x,y=event.y})
		fTimer=timer.performWithDelay(1000,function() transition.to(finger,{time=200,alpha=0}) end)
	end
	
	if isRouteConvert then 
		if ( event.phase == "ended" ) then
			MD.markLat=myWayPoints[markNum][3]
			MD.markLong=myWayPoints[markNum][4]
			routes.addRouteNode(true)
		end
	elseif (not thePanel) or (canMoveRoute) or (isMoveWP) or (isMoveGT) then
		currentWP=markNum
		currentType=myType
		if (not isRoute) then	

			if (isMoveWP) then -- moving waypoint after created
				if ( event.phase == "began" ) then
					startX=event.x
					startY=event.y			
				elseif ( event.phase == "moved" ) then
					local deltaX = event.x - startX	
					local deltaY = event.y - startY
					waypGroup[markNum].x=waypGroup[markNum].x+deltaX/MD.multiplier
					waypGroup[markNum].y=waypGroup[markNum].y+deltaY/MD.multiplier
					startX=event.x
					startY=event.y
					MD.touchX=event.x
					MD.touchY=event.y
				elseif ( event.phase == "ended" ) then
					if isFinger then
						myTimer=timer.performWithDelay(200,function() transition.to(finger,{time=200,y=event.y+30+30}) end)
						fTimer=timer.performWithDelay(2000,function() transition.to(finger,{time=200,alpha=0}) end)
					end
				end
				return true
			elseif (isMoveGT) then -- moving goto after created
				if ( event.phase == "began" ) then
					startX=event.x
					startY=event.y
				elseif ( event.phase == "moved" ) then
			
					local deltaX = event.x - startX	
					local deltaY = event.y - startY
					gotoGroup[1].x=gotoGroup[1].x+deltaX/MD.multiplier
					gotoGroup[1].y=gotoGroup[1].y+deltaY/MD.multiplier
					gotoGroup[2].x=gotoGroup[2].x+deltaX/MD.multiplier
					gotoGroup[2].y=gotoGroup[2].y+deltaY/MD.multiplier
					startX=event.x
					startY=event.y
					MD.touchX=event.x
					MD.touchY=event.y
				end
				return true
			elseif (canMoveRoute) then -- moving waypoint after created
				if ( event.phase == "began" ) then
					startX=event.x
					startY=event.y
				elseif ( event.phase == "moved" ) then		
					local deltaX = event.x - startX	
					local deltaY = event.y - startY
					routeGroup[2][markNum].x=routeGroup[2][markNum].x+deltaX/MD.multiplier
					routeGroup[2][markNum].y=routeGroup[2][markNum].y+deltaY/MD.multiplier
					routeGroup[3][markNum].x=routeGroup[3][markNum].x+deltaX/MD.multiplier
					routeGroup[3][markNum].y=routeGroup[3][markNum].y+deltaY/MD.multiplier
					startX=event.x
					startY=event.y
					MD.touchX=event.x
					MD.touchY=event.y
				end
				return true
			else--initiating waypoint touch options
			
				if ( event.phase == "ended" ) then		
					--clearPanel()
					
					if (myType=="wp") then--or (myType=="mk") then
						
						clearPanel()
						blinkingCircle=waypGroup[markNum][2][2]
						blinkingCircle.alpha=1
						transition.blink( blinkingCircle, { time=1000, tag="transTag" } )
						local myHide = function() waypGroup[markNum][1].alpha=0 end
						MD.hTime=timer.performWithDelay( shortTimeOut, myHide, 1 )
						waypEdit(markNum,myType)
						
						wpInfo.text=waypGroup[markNum][1][2].text
						if (MD.multiplier<1) then wpInfoGroup.alpha=1 else waypGroup[markNum][1].alpha=1 end

					elseif (myType=="rt") then
						clearPanel()
						blinkingCircle=nil
						blinkingCircle=routeGroup[3][markNum][2] -- this is missing
						blinkingCircle.alpha=1
						transition.blink( blinkingCircle, { time=1000, tag="transTag" } )
						if (markNum==table.maxn(routeTable)) then
							thePanel=ui.makeNewPanel("routepanel",rightEdge-205,140,200,220,false,"redbutton","Delete\nremoves saved data",routes.clearRoute,"redbutton","Delete node",deleteWP,"bluebutton","Edit\non number pad",editWP,"bluebutton","Move nodes\nany route nodes",routes.moveRoute,"greenbutton","Extend\nadd nodes to end",routes.extendRoute,"greybutton","cancel",clearPanel)
						elseif (markNum==1) then
							thePanel=ui.makeNewPanel("routepanel",rightEdge-205,140,200,220,false,"redbutton","Delete\nremoves saved data",routes.clearRoute,"redbutton","Delete node",deleteWP,"bluebutton","Edit\non number pad",editWP,"bluebutton","Move nodes\nany route nodes",routes.moveRoute,"greybutton","cancel",clearPanel)
						else
							thePanel=ui.makeNewPanel("routepanel",rightEdge-205,140,200,220,false,"greenbutton","Insert\nnode astern",routes.addNode,"redbutton","Delete node",deleteWP,"bluebutton","Edit\non number pad",editWP,"bluebutton","Move nodes\nany route nodes",routes.moveRoute,"greybutton","cancel",clearPanel)
						end
						screenGroup:insert(thePanel)
						MD.hTime=timer.performWithDelay(longTimeOut,function() clearPanel() end)
						local myHide = function() routeGroup[2][markNum].alpha=0 end
						infoTimer=timer.performWithDelay( shortTimeOut, myHide, 1 )
						wpInfo.text=routeNameTable[1].."."..markNum.."\n"..routeTable[markNum][3].."nm\n"..routeTable[markNum][1].."\n"..routeTable[markNum][2]
						if (MD.multiplier<1) then wpInfoGroup.alpha=1 else routeGroup[2][markNum].alpha=1 end
					elseif (myType=="hb") then
						local fileTable = harbourList[markNum]:split(",")	
						local myNotes=fileTable[3].."\n\nWaypoint: "..fileTable[4].."\n\nCharts: "..fileTable[5].."\n\nRules & Regs\n"..fileTable[6].."\n\nHazards\n"..fileTable[7].."\n\nTides: "..fileTable[8]
						local theUrl=fileTable[9]
						thePanel=ui.makeReadNotesPanel(110,10,900,620,myNotes,"vmhlogo","",function() goUrl(theUrl) end,"greybutton","Done",clearPanel)
						screenGroup:insert(thePanel)
					elseif (myType=="sc") then
						local fileTable = scList[markNum]:split("|")	
						local myNotes=string.gsub(fileTable[1].."\n\nInformation: "..fileTable[4].."\n\nContact: "..fileTable[5].."\n\nFacilites\n"..fileTable[6],"~","\n")
						local theUrl=fileTable[7]
						thePanel=ui.makeReadNotesPanel(110,10,900,600,myNotes,"greenbutton","club website",function() goUrl(theUrl) end,"greybutton","Done",clearPanel)
						screenGroup:insert(thePanel)
					elseif (myType=="td") then						
						local fileTable = myTidePorts[markNum]:split(",")						
						loadTide(event.target.data)
					elseif (myType=="goto") then
						blinkingCircle=gotoGroup[2]
						blinkingCircle.alpha=1
						transition.blink( blinkingCircle, { time=1000, tag="transTag" } )
						wpInfo.text="GoTo\n"..gotoTable[1].."\n"..gotoTable[2]
						wpInfoGroup.alpha=1
						waypEdit(1,"goto")
					end
					if isFinger then
						myTimer=timer.performWithDelay(200,function() transition.to(finger,{time=200,y=event.y+30+30}) end)
						fTimer=timer.performWithDelay(2000,function() transition.to(finger,{time=200,alpha=0}) end)
					end
				end
			end
		end
	end
	-- uiGroup:toFront()
	return true
end

function cancelTrans()
	transition.cancel( "transTag" )
	blinkingCircle.alpha=0
end
-- waypoints
function submitMarkForPositioning(mX,mY)
	--called from mapTouchListener *2	
	MD.touchX=mX
	MD.touchY=mY
	MD.pixX=MD.mapW/2+MD.touchX/MD.multiplier-mapContainer.x/MD.multiplier--MD.mapW/2-mapContainer.x+mX
	MD.pixY=MD.mapH/2+MD.touchY/MD.multiplier-mapContainer.y/MD.multiplier
	MD.markLong=navMaths.makeNumD(navMaths.getLongFromPixels(MD.pixX),4)
	MD.markLat=navMaths.makeNumD(navMaths.getLatFromPixels(MD.pixY),4)

	if isRoute then
		routes.addRouteNode(true)
	elseif isGo then
		makeGoto()
	else
		if (not thePanel) then
			if (newChartPointer~=0) then
				
				chartOut=newChartOut
				-- chartPointer=newChartPointer
				-- newChartPointer=0
				thePanel=ui.makeNewPanel("waypoint,mark,route",ui.checkXForPanel(MD.touchX,200,50),ui.checkYForPanel(MD.touchY,-100),200,220,false,"greenbutton","Move to\nChart "..newChartNum,chartIn,"bluebutton","Waypoint",startWayPoint,"bluebutton","Start Route",routes.startRoute,"greybutton","cancel",clearPanel)
			else
				thePanel=ui.makeNewPanel("waypoint,mark,route",ui.checkXForPanel(MD.touchX,200,50),ui.checkYForPanel(MD.touchY,-100),200,220,false,"bluebutton","Waypoint",startWayPoint,"bluebutton","Start Route",routes.startRoute,"greybutton","cancel",clearPanel)
			end
			screenGroup:insert(thePanel)
			MD.hTime=timer.performWithDelay(longTimeOut,function() clearPanel() end)
		else 
			if (thePanel.name~=nil) then
				local alert = native.showAlert( "NOTE", "The panel ("..thePanel.name..") must be closed first" ,{ "NEXT" }) 
			end
		end
	end
	if newChartPointer~=o then chartPointer=newChartPointer end
	newChartPointer=0
end

function measureDistance()
	local lDist=0
	for i=2,#routeTable do
		segDist=navMaths.getDistance(routeTable[i-1][1],routeTable[i-1][2],routeTable[i][1],routeTable[i][2])
		lDist=lDist+segDist
	end
	return lDist
end

function enterWPb()
	makeNumPanelDMM()
end

function enterWPw()
	clearPanel()
	getPanelType="pickerPanel" 
	thePanel=ui.pickerPanelDMM(110,200,690,420,"bluebutton","Submit",getDMM,"greybutton","cancel",clearPanel)
	screenGroup:insert(thePanel)
	return true
end

function showmarkerOptions()
--called from checkmark. markSelected function receives variable in ui function
	-- clearPanel()
	-- thePanel=ui.makeMarkPanel(ui.checkXForPanel(MD.touchX,200,50),ui.checkYForPanel(MD.touchY,-100),200,220,6,markSelected,"greybutton","cancel",clearPanel)
	-- screenGroup:insert(thePanel)
	-- MD.hTime=timer.performWithDelay(longTimeOut,function() clearPanel() end)
	-- return true
end

function markSelected(num)
	--sets icon image then call startWayPoint
	-- clearPanel()
	-- currentType="mk"
	-- startWayPoint(num,false,"","","mk")-- num comes from ui.makeMarkPanel
end

function startWayPoint(markNum,isLoaded,wpName,wpNum,wpType,wNum,tideData)
--called from checkMark button panel, numinputpanels, loadWayPoints, loadRoutes (maybe), used for waypoints and markers
--variables passed only needed when loading saved waypoints or making an icon mark
--startWayPoint(0,true,fileTable[2],i)
	--waypButton.alpha=1
	waypGroup.alpha=1
	waypNum=waypNum+1
	markOn=true
	local theLat=navMaths.getPixelsFromLat(MD.markLat)-MD.mapH/2
	local theLong=navMaths.getPixelsFromLong(MD.markLong)-MD.mapW/2
	local newWay=display.newGroup()
	local nodeInfoGroup=display.newGroup()
	local rect = display.newRoundedRect(nodeInfoGroup,theLong-12,theLat-12, 180,85,5 )
	rect:setFillColor(1,1,1,0.8)
	rect.anchorX=0
	rect.anchorY=0
	local textOptions={parent=nodeInfoGroup, text=navMaths.dmmStringBreak(MD.markLat,MD.markLong).."\n"..theDate,x=20+theLong,y=theLat-5,width=150,height=80,font=native.systemFont,fontSize=16}
	local wpText = display.newText(textOptions)
	wpText:setTextColor(0,0,1)
	wpText.anchorX = 0
	wpText.anchorY = 0
	nodeInfoGroup.alpha=0
	newWay:insert(nodeInfoGroup)
	MD.pixY=navMaths.getPixelsFromLat(MD.markLat) --needed because not in saved waypoints
	MD.pixX=navMaths.getPixelsFromLong(MD.markLong)
	
	--clearPanel()
	if (markNum==nil) then
	--standard waypoint from click or text input
		theType="wp"
		waypGroup:insert(newWay)
		wNum=table.maxn(myWayPoints)+1
		makeWayPoint(theLat,theLong,MD.markLat,MD.markLong,newWay,theType,true,0,wNum)
		getWPText()

	elseif (wpType=="mk") then
	-- marker
		-- waypGroup:insert(newWay)
		-- makeMarker(theLat,theLong,newWay,wpType,markNum)
		-- getWPText()

	elseif (wpType=="wp") then
	--loaded waypoints

		waypGroup:insert(newWay)
		makeWayPoint(theLat,theLong,MD.markLat,MD.markLong,newWay,wpType,false,0,wpNum)

		if (waypGroup[wpNum][1]~=nil) then
			waypGroup[wpNum][1][2].text=wpName.."\n"..waypGroup[wpNum][1][2].text-- error nil value
			waypGroup[wpNum][1].alpha=0
		end
	elseif (wpType=="tr") then
	--loaded track

		trackGroup:insert(newWay)
		makeWayPoint(theLat,theLong,MD.markLat,MD.markLong,newWay,wpType,false,0,wpNum)

	elseif (wpType=="hb") then
		harbourGroup.alpha=1
		harbourGroup:insert(newWay)
	--loaded harbours
		makeWayPoint(theLat,theLong,MD.markLat,MD.markLong,newWay,wpType,false,0,wNum)
		table.insert(hbNameTable,wpName)
		harbourGroup[table.maxn(hbNameTable)][1][2].text=wpName.."\n"..harbourGroup[table.maxn(hbNameTable)][1][2].text
		harbourGroup[wpNum][1].alpha=0
	elseif (wpType=="sc") then
		scGroup.alpha=1
		scGroup:insert(newWay)
		makeWayPoint(theLat,theLong,MD.markLat,MD.markLong,newWay,wpType,false,0,wNum)
		table.insert(scNameTable,wpName)
		scGroup[table.maxn(scNameTable)][1][2].text=wpName.."\n"..scGroup[table.maxn(scNameTable)][1][2].text
		scGroup[wpNum][1].alpha=0
	elseif (wpType=="td") then
		tideGroup.alpha=1
		tideGroup:insert(newWay)
	--loaded tides
		makeWayPoint(theLat,theLong,MD.markLat,MD.markLong,newWay,wpType,false,0,wNum,tideData)
		table.insert(tdNameTable,wpName)
		tideGroup[table.maxn(tdNameTable)][1][2].text=wpName.."\n"..tideGroup[table.maxn(tdNameTable)][1][2].text
		tideGroup[wpNum][1].alpha=0
	end
	return true
end

function makeWayPoint(wX,wY,markLat,markLong,theGroup,theType,isNew,dist,wNum,tideData,isLast)
	--called from checkMark, startWayPoint, setRoute
	-- NOT used for markers
	currentType=theType
	local hitCircle
	local wpGroup=display.newGroup()

	if (theType=="rt") and (routePos==1) then
		theWP=display.newImageRect("images/marks/"..theType.."_start.png",30/MD.multiplier,30/MD.multiplier)
	elseif (theType=="rt") and (isLast) then
		theWP=display.newImageRect("images/marks/"..theType.."_end.png",30/MD.multiplier,30/MD.multiplier)
	else
		theWP=display.newImageRect("images/marks/"..theType..".png",30/MD.multiplier,30/MD.multiplier)
	end
	theWP.x=wY
	theWP.y=wX
	local hitSize=40
	if (isPhone) then hitSize=50 end
	wpGroup:insert(theWP)
	if (theType~="tr") then
		if (theType~="hb") then
			hitCircle = display.newImageRect(wpGroup,"images/marks/hit.png",hitSize*1.5/MD.multiplier,hitSize*1.5/MD.multiplier)
		else
			hitCircle = display.newImageRect(wpGroup,"images/marks/hit.png",hitSize/MD.multiplier,hitSize/MD.multiplier)
		end
		hitCircle.alpha=0
		hitCircle.x=wY
		hitCircle.y=wX
		hitCircle.type=theType
		hitCircle.isHitTestable = true
		hitCircle.touch = markListener
		hitCircle:addEventListener( "touch", hitCircle )
	end
	theGroup:insert(wpGroup)
	local newPoint={}
	local newPix={}
	table.insert(newPix,MD.pixX)
	table.insert(newPix,MD.pixY)
	table.insert(newPoint,markLat)
	table.insert(newPoint,markLong)
	if theType=="wp" then 
		newPoint={chartNum,""}
		table.insert(newPoint,markLat)
		table.insert(newPoint,markLong)
		if isNew then table.insert(myWayPoints,newPoint) end
		hitCircle.num=wNum
	elseif theType=="rt" then
		table.insert(newPoint,dist)
		table.insert(routeTable,newPoint) 
		table.insert(routePix,newPix) 
		hitCircle.num=routePos
	elseif theType=="hb" then
		table.insert(hbTable,newPoint) 
		hitCircle.num=wNum
	elseif theType=="sc" then
		table.insert(scTable,newPoint) 
		hitCircle.num=wNum
	elseif theType=="td" then
		table.insert(tdTable,newPoint) 
		hitCircle.num=wNum
		hitCircle.data=tideData
	end
end

function makeGoto(isFromWP,lat,long)
	clearPanel()
	local myLat=lat or MD.markLat
	local myLong=long or MD.markLong
	local theLat,theLong
	if (isFromWP) then
		theLat=navMaths.getPixelsFromLat(lat)-MD.mapH/2
		theLong=navMaths.getPixelsFromLong(long)-MD.mapW/2
	else
		theLat=navMaths.getPixelsFromLat(MD.markLat)-MD.mapH/2
		theLong=navMaths.getPixelsFromLong(MD.markLong)-MD.mapW/2
	end
	theGoto=display.newImageRect("images/marks/target.png",40/MD.multiplier,40/MD.multiplier)
	theGoto.x=theLong
	theGoto.y=theLat
	emptyGroup(gotoGroup)
	gotoGroup:insert(theGoto)
	local hitCircle
	hitCircle = display.newImageRect(gotoGroup,"images/marks/hit.png",50/MD.multiplier,50/MD.multiplier)
	hitCircle.alpha=0
	hitCircle.type="goto"
	hitCircle.x=theLong
	hitCircle.y=theLat
	hitCircle.isHitTestable = true
	hitCircle.touch = markListener
	hitCircle:addEventListener( "touch", hitCircle )
	isGo=false
	MD.nextPoint={myLat,myLong}

	table.insert(gotoTable,myLat) 
	table.insert(gotoTable,myLong) 
end

function selGotoRT()
	clearPanel()
	local rLat=routeTable[1][1]
	local rLong=routeTable[1][2]
	gotoList=routeTable
	gotoPoint=1
	makeGoto(true,rLat,rLong)
	return true
end

function placeGoto()
	isGo=true
	clearPanel()
	thePanel=ui.makeNewPanel("goto panel",rightEdge-205,160,200,180,false,"greybutton","Cancel",cancelGoto)
	screenGroup:insert(thePanel)
	doMessage("Click on the chart to place the GOTO mark","",2,3000)
end

function makeMarker(wX,wY,theGroup,theType,mNum)
	--called from startWayPoint
	-- NOTE: markers have their own info table, but are part of waypGroup for display
	-- local mkGroup=display.newGroup()
	-- theMarker=display.newImageRect("images/marks/mark"..mNum..".png",20/MD.multiplier,20/MD.multiplier)
	-- theMarker.x=wY
	-- theMarker.y=wX
	-- mkGroup:insert(theMarker)
	-- local hitCircle = display.newImageRect(mkGroup,"images/marks/hit.png",30/MD.multiplier,30/MD.multiplier)
	-- hitCircle.alpha=0
	-- hitCircle.type=theType
	-- hitCircle.x=wY
	-- hitCircle.y=wX
	-- hitCircle.isHitTestable = true
	-- hitCircle.touch = markListener
	-- hitCircle:addEventListener( "touch", hitCircle )

	-- theGroup:insert(mkGroup)
	-- theGroup.alpha=1
	-- local newPoint={}
	-- table.insert(newPoint,MD.pixX)
	-- table.insert(newPoint,MD.pixY)
	-- table.insert(newPoint,MD.markLat)
	-- table.insert(newPoint,MD.markLong)
	-- MD.nextPoint={MD.markLat,MD.markLong}
	-- if theType=="mk" then 
		-- table.insert(markTable,newPoint) 
		-- hitCircle.num=waypGroup.numChildren
	-- end
end

function cancelWP()
	--called from getWPText text input panel
--CHECK IF RIGHT, MAY NEED TO MODIFY NOT REMOVE TABLE ALSO NAMETABLE
	clearPanel()
	display.remove(waypGroup[waypGroup.numChildren])
	table.remove(myWayPoints)
	markOn=false
	return true
end

function cancelGoto()
	--called from getWPText text input panel
--CHECK IF RIGHT, MAY NEED TO MODIFY NOT REMOVE TABLE ALSO NAMETABLE
	clearPanel()
	isGo=false
	return true
end

function getWPText()
	--called from startWayPoint, used for waypoints and markers
	clearPanel()
	if (currentType=="wp") then MD.defaultText="Waypoint "..waypNum end
	-- if (currentType=="mk") then MD.defaultText="Marker "..waypNum end
	
	if (isPhone) then
		thePanel=ui.makeNewPanel("waypointname",rightEdge-415,100,400,180,true,"greenbutton","Submit",getWayPointName,"greybutton","Cancel",cancelWP)
	else
		thePanel=ui.makeNewPanel("waypointname",rightEdge-305,140,300,180,true,"greenbutton","Submit",getWayPointName,"greybutton","Cancel",cancelWP)
	end
	--MD.hTime=timer.performWithDelay(longTimeOut,function() cancelWP() end)
	screenGroup:insert(thePanel)
end

function getWayPointName()
	--called from startWayPoint
	if "Win" == system.getInfo( "platformName" ) then
		inputName=currentType..table.maxn(myWayPoints)+1
	else
		inputName=inputField.text
	end
	-- in waypGroup [n][1] is display rect and text.
	-- waypGroup [n][2] is the dot
	waypGroup[waypGroup.numChildren][1][2].text=inputName.."\n"..waypGroup[waypGroup.numChildren][1][2].text
	--local waypoint=chartNum..","..inputName
	if (currentType=="wp") then
		myWayPoints[table.maxn(myWayPoints)][2]=inputName
		myWayPoints[table.maxn(myWayPoints)][5]=theDate
		IO.saveWayPoints()
	elseif (currentType=="mk") then
		-- waypoint=waypoint..","..table.concat(markTable[#markTable], ",")..","..theDate.."\n"
		-- IO.saveMarks(waypoint)
	end
	clearPanel()
	if (table.maxn(myWayPoints)>1) then waypGroup[table.maxn(myWayPoints)-1][1].alpha=0 end
	local myHide = function() waypGroup[table.maxn(myWayPoints)][1].alpha=0 end --error here nil value
	--infoTimer=timer.performWithDelay( shortTimeOut, myHide, 1 )
	markOn=false
	return true
end

function waypEdit(mNum,mType)
	--called from markListener, used for marks and wp
	clearPanel()
	thePanel=ui.makeNewPanel("deletewp",800,140,200,220,false,"redbutton","Delete",deleteWP,"bluebutton","Edit\non number pad",editWP,"bluebutton","Move\ndrag waypoint",moveWP,"bluebutton","Start Route\nfrom waypoint",startRouteWP,"greybutton","cancel",clearPanel)
	MD.hTime=timer.performWithDelay(longTimeOut,function() clearPanel() end)
	screenGroup:insert(thePanel)
	currentWP=mNum
	currentType=mType
end

function moveWP()
-- when points are moved manually
	clearPanel()		
	thePanel=ui.makeNewPanel("movewp",800,140,200,220,false,"greenbutton","Accept\nchange is kept",reposWP,"greybutton","cancel",cancelMove)
	screenGroup:insert(thePanel)
	doMessage("Click the waypoint and drag it to a new position","",2,3000) 
	if (currentType=="goto") then
		isMoveGT=true
		MD.oldY=gotoGroup[1].y
		MD.oldX=gotoGroup[1].x
	else
		isMoveWP=true
		MD.oldY=waypGroup[currentWP].y
		MD.oldX=waypGroup[currentWP].x
	end
	return true
end

function reposWP()
	local myMessage
	-- Moves moved point and updates tables to reflect new coordinates
	local pixX=MD.mapW/2+MD.touchX/MD.multiplier-mapContainer.x/MD.multiplier
	local pixY=MD.mapH/2+MD.touchY/MD.multiplier-mapContainer.y/MD.multiplier
	local newLong=navMaths.makeNumD(navMaths.getLongFromPixels(pixX),4)
	local newLat=navMaths.makeNumD(navMaths.getLatFromPixels(pixY),4)
	-- MD.touchX,MD.touchY=0,0
	if (isMoveWP) then 
		isMoveWP=false
		myMessage="Waypoint moved to new position"
		if currentType=="wp" then
			myWayPoints[currentWP][3]=newLat
			myWayPoints[currentWP][4]=newLong
			IO.saveWayPoints()
			loadWayPoints()
		end
		-- if currentType=="mk" then
			-- markTable[currentWP][1]=newLat
			-- markTable[currentWP][2]=newLong
		-- end
		waypGroup[currentWP][1][2].text=myWayPoints[currentWP][2].."\n"..newLat.."\n"..newLong.."\n"..theDate
	end
	
	if (isMoveGT) then 
		isMoveGT=false		
		gotoTable[1]=newLat
		gotoTable[2]=newLong
		MD.nextPoint={newLat,newLong}
		myMessage="GOTO moved to new position"
	end
	
	if (canMoveRoute) then
		canMoveRoute=false
		routePix[currentWP][1]=MD.pixX
		routePix[currentWP][2]=MD.pixY
		routeTable[currentWP][1]=newLat
		routeTable[currentWP][2]=newLong
		routes.redrawRoute()
		routes.updateTheRoute()
		myMessage="Route node moved to new position"
	end
	clearPanel()
	doMessage(myMessage,"",2,3000)
end

function cancelMove()
-- places points back where they were before move
	if (isMoveWP) then 
		isMoveWP=false
		waypGroup[currentWP].x=MD.oldX
		waypGroup[currentWP].y=MD.oldY
	elseif (canMoveRoute) then 
		routeGroup[2][currentWP].x=MD.oldX
		routeGroup[2][currentWP].y=MD.oldY
		routeGroup[3][currentWP].x=MD.oldX
		routeGroup[3][currentWP].y=MD.oldY
		canMoveRoute=false
		routes.redrawRoute()
	elseif (isMoveGT) then 
		gotoGroup[1].x=MD.oldX
		gotoGroup[1].y=MD.oldY
		gotoGroup[2].x=MD.oldX
		gotoGroup[2].y=MD.oldY
		isMoveGT=false
	end
	MD.oldX,MD.oldY=0,0
	clearPanel()
	cancelTrans() --stops blinking
	doMessage("Waypoint Reset","",2,3000)
end

function deleteWP()
	--called from waypEdit button panel
	local numWP
	if (currentType=="wp") then--or (currentType=="mk") then
		local numWP=table.maxn(myWayPoints)
		for i=currentWP+1,numWP do
			waypGroup[i][2][2].num=i-1
		end		
		if (numWP==1) then
			myWayPoints={}
			IO.deleteWPFile()
		else
			table.remove(myWayPoints,currentWP)
			IO.saveWayPoints()
		end
		display.remove(waypGroup[currentWP])
	elseif (currentType=="rt") then
		local numWP=routeGroup.numChildren
		for i=currentWP+1,table.maxn(routeTable) do
			routeGroup[3][i][2].num=i-1
		end
		if (numWP==1) then
			routeTable={}
			routePix={}
		else
			table.remove(routeTable,currentWP)
			table.remove(routePix,currentWP)
		end
		routes.redrawRoute()
	elseif (currentType=="goto") then
		emptyGroup(gotoGroup)
	end
	
	if (waypGroup.numChildren==0) then 
		--waypButton.alpha=0.4
		--waypGroup.alpha=0
	end
	clearPanel()
	wpInfoGroup.alpha=0
	return true
end

function deleteAllWP()
	myWayPoints={}
	waypGroup.alpha=0
	IO.deleteWPFile()
	emptyGroup(waypGroup)
	clearPanel()
end

function startRouteWP()
	
	MD.markLat=myWayPoints[currentWP][3]
	MD.markLong=myWayPoints[currentWP][4]
	routes.startRoute()
	isRouteConvert=true
	doMessage("This waypoint is now the first node of the new route. The waypoint still exists but is hidden","",2,3000)
	--routeGroup:toFront()
end

function editWP()
	local theLat,theLong
	if (currentType=="wp") then
		theLat=myWayPoints[currentWP][3]
		theLong=myWayPoints[currentWP][4]
	elseif (currentType=="rt") then
		theLat=routeTable[currentWP][1]
		theLong=routeTable[currentWP][2]
	elseif (currentType=="mk") then
		-- theLat=markTable[currentWP][1]
		-- theLong=markTable[currentWP][2]
	elseif (currentType=="goto") then
		theLat=gotoTable[1]
		theLong=gotoTable[2]
	end
	clearPanel()
	thePanel=ui.latLongPanel("edit wp",rightEdge-305,100,300,120,navMaths.makeNumD(theLat,4),navMaths.makeNumD(theLong,4),makePlusLat,makeMinusLat,makePlusLong,makeMinusLong,"bluebutton","Submit",updateWP,"greybutton","cancel",unDoWP)
	screenGroup:insert(thePanel)	
	return true
end

function updateWP()
	--called when lalLong panel is completed
	local newLat=tonumber(thePanel[2][11][1].text.."."..thePanel[2][11][2].text..thePanel[2][11][3].text..thePanel[2][11][4].text..thePanel[2][11][5].text)
	local newLong=tonumber(thePanel[3][11][1].text.."."..thePanel[3][11][2].text..thePanel[3][11][3].text..thePanel[3][11][4].text..thePanel[3][11][5].text)
	if (currentType=="wp") then		
		myWayPoints[currentWP][3]=newLat
		myWayPoints[currentWP][4]=newLong
		waypGroup[currentWP][1].alpha=0
		IO.saveWayPoints()
		shiftWayPoint(currentWP,newLat,newLong)
	elseif (currentType=="rt") then		
		routeTable[currentWP][1]=newLat
		routeTable[currentWP][2]=newLong
		--routeGroup[routePos][1].alpha=0
		routes.updateTheRoute()
		routes.redrawRoute()
	elseif (currentType=="mk") then
		-- shiftWayPoint(currentWP,newLat,newLong)
		-- markTable[currentWP][1]=newLat
		-- markTable[currentWP][2]=newLong
		-- waypGroup[currentWP][1].alpha=0
	elseif (currentType=="goto") then
		shiftWayPoint(1,newLat,newLong)
		gotoTable[1]=newLat
		gotoTable[2]=newLong		
	end
	clearPanel()
end

function makePlusLat(i)
	if (i==1) then
		thePanel[2][11][i].text=tostring(tonumber(thePanel[2][11][i].text)+1)
	else
		thePanel[2][11][i].text=tostring(minMax(tonumber(thePanel[2][11][i].text)+1))
	end
	tempShift(currentWP)
end

function minMax(x)
	if (x==-1) then x=9 end
	if (x==10) then x=0 end
	return x
end

function makePlusLong(i)
	if (i==1) then
		thePanel[3][11][i].text=tostring(tonumber(thePanel[3][11][i].text)+1)
	else
		thePanel[3][11][i].text=tostring(minMax(tonumber(thePanel[3][11][i].text)+1))
	end
	tempShift(currentWP)
end

function makeMinusLat(i)
	thePanel[2][11][i].text=tostring(minMax(tonumber(thePanel[2][11][i].text)-1))
	tempShift(currentWP)
end

function makeMinusLong(i)
	if (i==1) then
		thePanel[3][11][i].text=tostring(tonumber(thePanel[3][11][i].text)-1)
	else
		thePanel[3][11][i].text=tostring(minMax(tonumber(thePanel[3][11][i].text)-1))
	end
	tempShift(currentWP)
end

function tempShift(num)
--called from plus and minus buttons on edit panel. Moves only the visible button, not the covering hitcircle
	local theLat=navMaths.getPixelsFromLat(tonumber(thePanel[2][11][1].text.."."..thePanel[2][11][2].text..thePanel[2][11][3].text..thePanel[2][11][4].text..thePanel[2][11][5].text))-MD.mapH/2
	local theLong=navMaths.getPixelsFromLong(tonumber(thePanel[3][11][1].text.."."..thePanel[3][11][2].text..thePanel[3][11][3].text..thePanel[3][11][4].text..thePanel[3][11][5].text))-MD.mapW/2
	if (currentType=="wp") then--or (currentType=="mk") then
		waypGroup[num][2][1].x=theLong
		waypGroup[num][2][1].y=theLat
	elseif (currentType=="rt") then
		routeGroup[3][num][1].x=theLong
		routeGroup[3][num][1].y=theLat
	elseif (currentType=="goto") then
		gotoGroup[1].x=theLong
		gotoGroup[1].y=theLat
		gotoGroup[2].x=theLong
		gotoGroup[2].y=theLat
	end
end

function unDoWP()
--called if wp move is cancelled. Moves only the visible button, not the covering hitcircle
	local oldLat,oldLong
	if (currentType=="wp") then
		oldLat=navMaths.getPixelsFromLat(myWayPoints[currentWP][3])-MD.mapH/2
		oldLong=navMaths.getPixelsFromLong(myWayPoints[currentWP][4])-MD.mapW/2
		waypGroup[currentWP][2][1].x=oldLong
		waypGroup[currentWP][2][1].y=oldLat
		waypGroup[currentWP][1].alpha=0
	elseif (currentType=="mk") then
		-- oldLat=navMaths.getPixelsFromLat(markTable[currentWP][1])-MD.mapH/2 -- CHECK FOR ERROR HERE - currentWP
		-- oldLong=navMaths.getPixelsFromLong(markTable[currentWP][2])-MD.mapW/2
		-- waypGroup[currentWP][2][1].x=oldLong
		-- waypGroup[currentWP][2][1].y=oldLat
	elseif (currentType=="goto") then
		oldLat=navMaths.getPixelsFromLat(gotoTable[1])-MD.mapH/2 -- CHECK FOR ERROR HERE - currentWP
		oldLong=navMaths.getPixelsFromLong(gotoTable[2])-MD.mapW/2
		gotoGroup[1].x=oldLong
		gotoGroup[1].y=oldLat
		gotoGroup[2].x=oldLong
		gotoGroup[2].y=oldLat
	end
	
	clearPanel()
end

function shiftWayPoint(num,lat,long)
--called from updateWP

	local theLat=navMaths.getPixelsFromLat(lat)-MD.mapH/2
	local theLong=navMaths.getPixelsFromLong(long)-MD.mapW/2
	local oldLat,oldLong
	if (currentType=="wp") then
		oldLat=navMaths.getPixelsFromLat(myWayPoints[currentWP][3])-MD.mapH/2
		oldLong=navMaths.getPixelsFromLong(myWayPoints[currentWP][4])-MD.mapW/2
	elseif (currentType=="mk") then
		-- oldLat=navMaths.getPixelsFromLat(markTable[currentWP][1])-MD.mapH/2
		-- oldLong=navMaths.getPixelsFromLong(markTable[currentWP][2])-MD.mapW/2
	elseif (currentType=="goto") then
		oldLat=navMaths.getPixelsFromLat(gotoTable[1])-MD.mapH/2
		oldLong=navMaths.getPixelsFromLong(gotoTable[2])-MD.mapW/2
	end
	local shiftX=oldLong-theLong
	local shiftY=oldLat-theLat
	if (currentType=="wp") then
		waypGroup[num][1][2].text=myWayPoints[num][2].."\n"..lat.."\n"..long.."\n"..theDate
	elseif (currentType=="mk") then
		--waypGroup[num][1][2].text=lat.."\n"..long -- add marker name
	end
	if (currentType=="wp")then-- or (currentType=="mk") then
		-- waypGroup[num][2][1].x=waypGroup[num][2][1].x+shiftX--oldLong--changehere
		-- waypGroup[num][2][1].y=waypGroup[num][2][1].y+shiftY--oldLat--changehere
		loadWayPoints()
		-- for i=1,2 do--changehere
			-- for j=1,2 do
				-- waypGroup[num][i][j].x=waypGroup[num][i][j].x-shiftX
				-- waypGroup[num][i][j].y=waypGroup[num][i][j].y-shiftY
			-- end
		-- end
		-- waypGroup[num].x=waypGroup[num].x-shiftX
		-- waypGroup[num].y=waypGroup[num].y-shiftY
		waypGroup[num][1].alpha=0
	elseif (currentType=="goto") then
		gotoGroup[1].x=theLong
		gotoGroup[1].y=theLat
		gotoGroup[2].x=theLong
		gotoGroup[2].y=theLat
	end
end

function loadWayPoints()
	--called from switchMark
	emptyGroup(waypGroup)
	myWayPoints=IO.loadFile("myWayPoints.txt")
	MD.topLat=tonumber(chartInfo[currentChart][7])
	MD.topLong=tonumber(chartInfo[currentChart][8])
	MD.bottomLat=tonumber(chartInfo[currentChart][9])
	MD.bottomLong=tonumber(chartInfo[currentChart][10])
	wpLoaded=0
	if (myWayPoints~=nil) and (string.len(myWayPoints[1])>4) then
		for i=1,#myWayPoints do --error here
			if (myWayPoints[i]~="") then 
				local fileTable = myWayPoints[i]:split(",")
				myWayPoints[i]=fileTable
				MD.markLat=(tonumber(fileTable[3]))
				MD.markLong=(tonumber(fileTable[4]))
				if (MD.markLat<MD.topLat) and (MD.markLat>MD.bottomLat) and (MD.markLong>MD.topLong) and (MD.markLong<MD.bottomLong) then
					startWayPoint(0,true,fileTable[2],i,"wp")
					wpLoaded=wpLoaded+1
				else
					startWayPoint(0,true,fileTable[2],i,"wp")
				end
			end
			if wpLoaded > 0 then viewButtons[2]=true end
		end
	else
		myWayPoints={}
	end
end

function goUrl(theUrl)
	system.openURL( theUrl)
end

-- panels
function showMarkPanel()
	clearPanel()
	local leftPos=leftEdge+140
	if (ort=="H") then leftPos=leftEdge+10 end
	if (waypGroup.numChildren>0) then
		thePanel=ui.makeNewPanel("waypoint options",leftPos,300,200,180,false,"bluebutton","Enter WP\nusing pickerwheel",enterWPw,"redbutton","Delete\nall waypoints",deleteAllWP,"mauvebutton","Import WP\nDISABLED",clearPanel,"greybutton","Cancel",clearPanel)
	else
		thePanel=ui.makeNewPanel("waypoint options",leftPos,300,200,180,false,"bluebutton","Enter WP\nusing pickerwheel",enterWPw,"redbutton","Delete\nall waypoints",deleteAllWP,"mauvebutton","Import WP\nDISABLED",clearPanel,"greybutton","Cancel",clearPanel)
	end
	screenGroup:insert(thePanel)
	MD.hTime=timer.performWithDelay( 5000,function() clearPanel() end)
end

function showRoutePanel() --checkRoutes has to go somewhere
	clearPanel()
	local leftPos=leftEdge+140
	if (ort=="H") then leftPos=leftEdge+10 end
	if (routeGroup.numChildren>0) then
		thePanel=ui.makeNewPanel("route options",leftPos,300,200,20,false,"bluebutton","Route List\nsaved routes",setRouteLoadPanel,"mauvebutton","Import Route\nDISABLED",clearPanel,"mauvebutton","Share Route\nDISABLED",clearPanel,"greybutton","cancel",clearPanel)
	else
		thePanel=ui.makeNewPanel("route options",leftPos,300,200,20,false,"bluebutton","Route List\nsaved routes",setRouteLoadPanel,"mauvebutton","Import Route\nDISABLED",clearPanel,"greybutton","cancel",clearPanel)
	end
	screenGroup:insert(thePanel)
	MD.hTime=timer.performWithDelay( 3000,function() clearPanel() end)
	return true
end

function showGotoPanel() --checkRoutes has to go somewhere
	clearPanel()
	local leftPos=leftEdge+140
	if (ort=="H") then leftPos=leftEdge+10 end
	if (waypGroup.numChildren==0) and (routeGroup.numChildren>0) then 
		thePanel=ui.makeNewPanel("goto options",leftPos,300,200,20,false,"greenbutton","New GoTo",placeGoto,"bluebutton","Use Route\ncurrent route",selGotoRT,"greybutton","cancel",clearPanel)
	end
	if (routeGroup.numChildren==0) and (waypGroup.numChildren>0) then 
	thePanel=ui.makeNewPanel("goto options",leftPos,300,200,20,false,"greenbutton","New GoTo",placeGoto,"bluebutton","Select WP\nfrom existing",setWPListPanel,"greybutton","cancel",clearPanel)
	end
	if (routeGroup.numChildren==0) and (waypGroup.numChildren==0) then 
	thePanel=ui.makeNewPanel("goto options",leftPos,300,200,20,false,"greenbutton","New GoTo",placeGoto,"greybutton","cancel",clearPanel)
	end
	if (routeGroup.numChildren>0) and (waypGroup.numChildren>0) then 
	thePanel=ui.makeNewPanel("goto options",leftPos,300,200,20,false,"greenbutton","New GoTo",placeGoto,"bluebutton","Select WP\nfrom existing",setWPListPanel,"bluebutton","Use Route\ncurrent route",selGotoRT,"greybutton","cancel",clearPanel)
	end
	screenGroup:insert(thePanel)
	MD.hTime=timer.performWithDelay( 5000,function() clearPanel() end)
end

function showTrackPanel() --checkRoutes has to go somewhere
	clearPanel()
	local leftPos=leftEdge+140
	if (ort=="H") then leftPos=leftEdge+10 end
	if (trackingOn) then
		thePanel=ui.makeNewPanel("trackingoff",800,300,200,260,false,"redbutton","Tracking Off",trackToggle,"greybutton","cancel",clearPanel)
	else
		thePanel=ui.makeNewPanel("track options",leftPos,300,200,20,false,"greenbutton","Tracking On",trackToggle,"bluebutton","Show/Hide Track",switchTrackView,"greybutton","cancel",clearPanel)
	end
	screenGroup:insert(thePanel)
	MD.hTime=timer.performWithDelay( 5000,function() clearPanel() end)
end

function wayPointOps() -- has been dropped
	clearPanel()
	if (waypGroup.numChildren>0) then
		thePanel=ui.makeNewPanel("waypoint loadsave",120,140,200,180,false,"redbutton","Delete\nall waypoints",deleteAllWP,"mauvebutton","Share WP\nemail or cloud",IO.shareWPgpx,"mauvebutton","Import WP\nfrom cloud",IO.importWaypoint,"greybutton","Cancel",clearPanel)
	else
		thePanel=ui.makeNewPanel("waypoint loadsave",120,140,200,180,false,"mauvebutton","Import WP\nfrom cloud",IO.importWaypoint,"greybutton","Cancel",clearPanel)
	end
	screenGroup:insert(thePanel)
	return true
end

function trackOps()
	clearPanel()	
	thePanel=ui.makeNewPanel("waypoint loadsave",120,140,200,180,false,"redbutton","Delete\nrecorded track",routes.deleteTrack,"greenbutton","Load Track\nfrom server",IO.loadTrack,"bluebutton","Share Track\nvia cloud",IO.shareTrack,"greybutton","Cancel",clearPanel)
	screenGroup:insert(thePanel)
	return true
end

function showToolsPanel()
	clearPanel()
	local leftPos=leftEdge+140
	if (ort=="H") then leftPos=leftEdge+10 end
	if (IO.checkFile("chart"..chartNum.."_notes.txt")) then
		thePanel=ui.makeMiniPanel(leftPos,300,150,150,"night","",switchDay,"locked","",switchLock,"capbutton","",capScreen,"writenote","",notes.makeNotes,"pref","",makePref,"note","",notes.readNotes)
	else	
		thePanel=ui.makeMiniPanel(leftPos,300,150,150,"night","",switchDay,"locked","",switchLock,"capbutton","",capScreen,"writenote","",notes.makeNotes,"pref","",makePref)
	end
	if (isBasic) then
		thePanel=ui.makeMiniPanel(leftPos,300,150,150,"night","",switchDay,"locked","",switchLock,"capbutton","",capScreen)
	elseif (isPhone) then
		thePanel=ui.makeMiniPanel(leftPos,300,150,150,"night","",switchDay,"locked","",switchLock,"capbutton","",capScreen,"pref","",makePref,"info","",showInfoPanel,"help","",showHelpPanel)
	end
	if (isPhone) then 
		thePanel.xScale=1.8
		thePanel.yScale=1.8
	end
	screenGroup:insert(thePanel)
	for i=1,2 do
		if (not toolButtons[i]) then thePanel[i+1].alpha=0.6 end
	end
	MD.hTime=timer.performWithDelay(shortTimeOut,function() clearPanel() end)
	return true
end

function showInfoPanel()
	clearPanel()
	infoList=IO.loadFile("info/info.txt",system.ResourceDirectory)
	infoPos=IO.loadFile("info/pos.txt",system.ResourceDirectory)
	infoPos=infoPos[1]:split(",")
	if isReg then
		nextInfo()
	else		
		local theText=string.gsub(infoList[1],"~","\n")
		thePanel=ui.makeReadInfoPanel(0,0,1024,768,tonumber(infoPos[1]),tonumber(infoPos[2]),theText,"info1","info","bluebutton","Register",showRegister,"bluebutton","Skip",nextInfo,"greybutton","Done",clearPanel)
		screenGroup:insert(thePanel)
	end
	return true
end

function nextInfo()
	clearPanel()
	local theText=string.gsub(infoList[2],"~","\n")
	thePanel=ui.makeReadInfoPanel(0,0,1024,768,tonumber(infoPos[3]),tonumber(infoPos[4]),theText,"info2","info","bluebutton","Contact",contactEmail,"bluebutton","Website",function() goRealChartsWeb(region) end,"greybutton","Done",clearPanel)
	screenGroup:insert(thePanel)
	return true
end

function lastInfo()
	clearPanel()
	local theText=string.gsub(infoList[3],"~","\n")
	thePanel=ui.makeReadInfoPanel(0,0,1024,768,tonumber(infoPos[5]),tonumber(infoPos[6]),theText,"info3","info","greybutton","Done",clearPanel)
	screenGroup:insert(thePanel)
	return true
end

function goRealChartsWeb(link)
	system.openURL( "http://www.realcharts.net/"..link )
end

function makePref()
	clearPanel()
	prefText={"Switch menu style (vertical to horizontal or viceversa)","Go to start screen","Delete route files - only use if there is an error loading files","Delete data files (only use if instructed by support staff)","Delete all system files (only use if instructed by support staff)"}
	prefButtons={{"bluebutton","Switch Menu",switchMenu},{"greenbutton","Go to Start",goStart},{"redbutton","Delete\nroute files",IO.deleteRouteFiles},{"redbutton","Delete\ndata file",IO.deleteDataFile},{"redbutton","Delete\nall system files ",IO.deleteAppFiles}}
	prefs=ui.makePrefPanel(120,100,800,600,10,10,prefText,prefButtons)
	screenGroup:insert(prefs)
end

function goStart()
	composer.gotoScene(splashPage)
end

function switchMenu()
	if (ort=="V") then
		ort="H"
		IO.saveOverFile("ort.txt","H")
		doMessage("Menus will now be on bottom of screen","",2,3000)
	else
		ort="V"
		IO.saveOverFile("ort.txt","V")
		doMessage("Menus will now be on left side of screen","",2,3000)
	end
	display.remove(mainInfogroup)
	mainInfogroup=ui.getInfoGroup(leftEdge)
	uiGroup:insert(mainInfogroup)
	loc.updatePos()
	menu.makeMenu()
end

function showHelpPanel()
	clearPanel()
	infoPos=IO.loadFile("help/pos.txt",system.ResourceDirectory)
	infoPos=infoPos[1]:split(",")
	helpList=IO.loadFile("help/help.txt",system.ResourceDirectory)
	local theText=string.gsub(helpList[1],"~","\n")
	thePanel=ui.makeReadInfoPanel(0,0,1024,768,tonumber(infoPos[1]),tonumber(infoPos[2]),theText,"help1","help","bluebutton","Next",nextHelp,"greybutton","Done",clearPanel)
	screenGroup:insert(thePanel)
	return true
end

function nextHelp()
	clearPanel()	
	local theText=string.gsub(helpList[2],"~","\n")
	thePanel=ui.makeReadInfoPanel(0,0,1024,768,tonumber(infoPos[3]),tonumber(infoPos[4]),theText,"help2","help","bluebutton","Next",lastHelp,"greybutton","Done",clearPanel)
	screenGroup:insert(thePanel)
	return true
end

function lastHelp()
	clearPanel()
	local theText=string.gsub(helpList[3],"~","\n")
	thePanel=ui.makeReadInfoPanel(0,0,1024,768,tonumber(infoPos[5]),tonumber(infoPos[6]),theText,"help3","help","greybutton","Done",clearPanel)
	screenGroup:insert(thePanel)
	return true
end

function showRegister()
	reg.showRegister()
end

function contactEmail()
	IO.sendEmail("contact@realcharts.net","Contact from RealChart App","","","","Email not available")
end

function showViewPanel()
	if (not isRoute) then
		clearPanel()
		local leftPos=leftEdge+140
		if (ort=="H") then leftPos=leftEdge+10 end

		panelButtons={true,true,true,doTide,doharbour,doLight,false,doSC}

		thePanel=ui.makeMiniPanel(leftPos,200,150,150,"showsub","",switchSub,"showmark","",switchMark,"showroute","",switchRoute,"showtides","",switchTides,"showharbour","",switchHarbours,"showlights","",switchLights,"shownm","",switchNM,"showsc","",switchSC)
		
		-- if (doTrack) then
			-- if doHarbour then
				-- thePanel=ui.makeMiniPanel(leftPos,200,150,150,"showsub","",switchSub,"showmark","",switchMark,"showroute","",switchRoute,"showtides","",switchTides,"showharbour","",switchHarbours,"showlights","",switchLights,"shownm","",switchNM,"showtrack","",switchTrackView)
			-- else
				-- thePanel=ui.makeMiniPanel(leftPos,200,150,150,"showsub","",switchSub,"showmark","",switchMark,"showroute","",switchRoute,"showtides","",switchTides,"showsc","",switchSC"showlights","",switchLights,"shownm","",switchNM,"showtrack","",switchTrackView)
			-- end
		-- elseif (isBasic) then
			-- thePanel=ui.makeMiniPanel(leftPos,200,150,150,"showsub","",switchSub,"showmark","",switchMark,"showroute","",switchRoute)
		-- else
			-- thePanel=ui.makeMiniPanel(leftPos,200,150,150,"showsub","",switchSub,"showmark","",switchMark,"showroute","",switchRoute,"showtides","",switchTides,"showharbour","",switchHarbours,"showlights","",switchLights,"shownm","",switchNM,"showsc","",switchSC)
		-- end	
		if (isPhone) then 
			thePanel.xScale=1.8
			thePanel.yScale=1.8
		end
		screenGroup:insert(thePanel)			
		for i=1,thePanel.numChildren-1 do
			if (not viewButtons[i]) then thePanel[i+1].alpha=0.6 end
		end
		
		for i=1,thePanel.numChildren-1 do
			if (not panelButtons[i]) then thePanel[i+1].alpha=0 end
		end

		MD.hTime=timer.performWithDelay(shortTimeOut,function() clearPanel() end)
	else
		doMessage("Save route first, then come back and extend or edit the route","",2,3000)
	end
	return true
end

function clearPanel()
	--called from most buttons
	clearMessage()
	display.remove(thePanel)
	display.remove(thePanel)
	if (MD.hTime~=nil) then timer.cancel( MD.hTime ) end
	if (infoTimer~=nil) then timer.cancel( infoTimer ) end
	isMoveWP=false
	isMoveGT=false
	thePanel=nil
	wpInfoGroup.alpha=0
	if (currentWP~=nil) and (waypGroup[currentWP]~=nil) then waypGroup[currentWP][1].alpha=0 end
	if (blinkingCircle~=nil) then cancelTrans() end
	return true
end

function clearPanel2()
	--called from most buttons
	display.remove(thePanel2)
	thePanel2=nil
end

function mynetworkListener( event )
    if ( event.isError ) then
        doMessage( "Network error!","",2,3000 )
    else
        doMessage ( "RESPONSE: " .. event.response)
    end
end

local fieldHandler = function( event )
	--called from input text on panels
	if "began" == event.phase then
		
	elseif "editing" == event.phase then
									
	elseif "ended" == event.phase then
		native.setKeyboardFocus( nil )
	elseif "submitted" == event.phase then
		native.setKeyboardFocus( nil )
	end
end

function string:split( inSplitPattern, outResults )
	--called from loadWayPoints, loadRoutes
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

function loadHarbours()
	--called from viewpanel
	clearPanel()
	hbTable={}
	emptyGroup(harbourGroup)
	harbourList=IO.loadFile("data/harbours_"..region..".txt",system.DocumentsDirectory)
	if (harbourList~=nil) then
		hbNameTable={}
		MD.topLat=tonumber(chartInfo[chartPointer][7])
		MD.topLong=tonumber(chartInfo[chartPointer][8])
		MD.bottomLat=tonumber(chartInfo[chartPointer][9])
		MD.bottomLong=tonumber(chartInfo[chartPointer][10])
		hLoaded=0
		for i=1,table.maxn(harbourList)	do
			local fileTable = harbourList[i]:split(",")
			MD.markLat=(tonumber(fileTable[1]))
			MD.markLong=(tonumber(fileTable[2]))
			if (MD.markLat<MD.topLat) and (MD.markLat>MD.bottomLat) and (MD.markLong>MD.topLong) and (MD.markLong<MD.bottomLong) then
				hLoaded=hLoaded+1
				startWayPoint(hLoaded,true,fileTable[3],hLoaded,"hb",i)
				viewButtons[5]=true
				if (hbView==false) then 
					harbourGroup.alpha=0
					viewButtons[5]=false
				end
			end		
		end
	end
end

function loadSailingClubs()
	--called from init.lua
	clearPanel()
	scTable={}
	emptyGroup(scGroup)
	scList=IO.loadFile("data/sailingclubs_"..region..".txt",system.DocumentsDirectory)
	if (scList~=nil) then
		scNameTable={}
		MD.topLat=tonumber(chartInfo[chartPointer][7])
		MD.topLong=tonumber(chartInfo[chartPointer][8])
		MD.bottomLat=tonumber(chartInfo[chartPointer][9])
		MD.bottomLong=tonumber(chartInfo[chartPointer][10])
		scLoaded=0
		for i=1,table.maxn(scList) do
			local fileTable = scList[i]:split("|")
			MD.markLat=(tonumber(fileTable[2]))
			MD.markLong=(tonumber(fileTable[3]))
			if (MD.markLat<MD.topLat) and (MD.markLat>MD.bottomLat) and (MD.markLong>MD.topLong) and (MD.markLong<MD.bottomLong) then
				scLoaded=scLoaded+1
				startWayPoint(scLoaded,true,fileTable[3],scLoaded,"sc",i)
				viewButtons[5]=true
				if (scView==false) then 
					scGroup.alpha=0
					viewButtons[8]=false
				end
			end		
		end
	end
end

function loadTidePorts()	
	clearPanel()
	tdTable={}
	tdNameTable={}
	emptyGroup(tideGroup)
	
	-- if isDemo then 
		-- myTidePorts=IO.loadFile("tides/tideports_"..region.."free.csv",system.DocumentsDirectory)
	-- else
		myTidePorts=IO.loadFile("tides/tideports_"..region..".csv",system.DocumentsDirectory)
	-- end
	doMessage(#myTidePorts,"",2)
	MD.topLat=tonumber(chartInfo[chartPointer][7])
	MD.topLong=tonumber(chartInfo[chartPointer][8])
	MD.bottomLat=tonumber(chartInfo[chartPointer][9])
	MD.bottomLong=tonumber(chartInfo[chartPointer][10])
	tdLoaded=0
	if (myTidePorts~=nil) then
		for i=1,#myTidePorts do
			if (myTidePorts[i]~="") then 
				local fileTable = myTidePorts[i]:split(",")
				MD.markLat=(tonumber(fileTable[3]))
				MD.markLong=(tonumber(fileTable[4]))
				print(MD.markLat,MD.markLong)
				local tideName=(fileTable[2])
				local tideSite=(fileTable[5])
				local tideSun=(fileTable[6])
				local tideScale=(tonumber(fileTable[7]))
				local tideMid=(tonumber(fileTable[8]))
				local tideData={tideName,tideSite,tideSun,tideScale,tideMid}
				if (MD.markLat<MD.topLat) and (MD.markLat>MD.bottomLat) and (MD.markLong>MD.topLong) and (MD.markLong<MD.bottomLong) then
					viewButtons[4]=true
					tdLoaded=tdLoaded+1
					startWayPoint(tdLoaded,true,fileTable[2],tdLoaded,"td",i,tideData)
					if (tideView==false) then 
						tideGroup.alpha=0
						viewButtons[4]=false
					end
				end
			end
		end
	end
end

function loadNM()
	local myNMs=IO.loadFile("data/nm.txt",system.DocumentsDirectory)
	nmTable={}
	if myNMs~=nil then
		for i=1,#myNMs do
			if (myNMs[i]~="") then 
				local fileTable = myNMs[i]:split(",")
				local nmHead=fileTable[1]
				local markLat=(tonumber(fileTable[2]))
				local markLong=(tonumber(fileTable[3]))
				if (markLat<MD.topLat) and (markLat>MD.bottomLat) and (markLong>MD.topLong) and (markLong<MD.bottomLong) then
					viewButtons[7]=true
					local lInfo=fileTable[4]
					showNM(nmHead,markLat,markLong,lInfo)
				end
			end
		end
	end
end

function showNM(nmHead,markLat,markLong,lInfo)
	newNM=display.newImageRect("images/nm.png",40/MD.multiplier,40/MD.multiplier)
	newNM.name=nmHead
	newNM.touch=nmListener
	newNM:addEventListener( "touch", newNM )
	newNM.info=nmHead.."\n\n"..lInfo.."\n\n"..navMaths.dmmString(markLat,markLong)
	local theLat=navMaths.getPixelsFromLat(markLat)-MD.mapH/2
	local theLong=navMaths.getPixelsFromLong(markLong)-MD.mapW/2
	newNM.x,newNM.y=theLong,theLat
	newNM.alpha=1
	nmGroup:insert(newNM)
	if (nmView==false) then 
		nmGroup.alpha=0
		viewButtons[7]=false
	end
end

function nmListener(self,touch)
	local phase = touch.phase
	if (phase=="began") then
		if finger~=nil then 
			uiGroup:toFront()
			if (fTimer~=nil) then timer.cancel( fTimer ) end
			transition.to(finger,{time=50,alpha=1})
			transition.to(finger,{time=200,x=touch.x,y=touch.y})
			fTimer=timer.performWithDelay(1000,function() transition.to(finger,{time=200,alpha=0}) end)
		end
	end
	if (phase=="ended") then
		thePanel=ui.makeReadNotesPanel(110,10,600,350,self.info,"greybutton","Done",clearPanel)
		screenGroup:insert(thePanel)
	end
	return true
end

function loadLights(LorM)
	myLights=IO.loadFile("lights_"..region..".txt",system.ResourceDirectory)
	lightTable={}
	lLoaded=0
	MD.topLat=tonumber(chartInfo[chartPointer][7])
	MD.topLong=tonumber(chartInfo[chartPointer][8])
	MD.bottomLat=tonumber(chartInfo[chartPointer][9])
	MD.bottomLong=tonumber(chartInfo[chartPointer][10])
	if myLights~=nil then
		for i=1,#myLights do
			if (myLights[i]~="") then 
				local fileTable = myLights[i]:split(",")
				local lightName=fileTable[1]
				local lightColour="W"
				if fileTable[6]~="" then lightColour=fileTable[6] end
				local markLat=(tonumber(fileTable[2]))
				local markLong=(tonumber(fileTable[3]))
				if (markLat<MD.topLat) and (markLat>MD.bottomLat) and (markLong>MD.topLong) and (markLong<MD.bottomLong) then
					lLoaded=lLoaded+1
					lightGroup.alpha=1
					viewButtons[6]=true
					local lInfo=fileTable[4].."	"..fileTable[5].." "..fileTable[6].." "..fileTable[7].." "..fileTable[8].." "..fileTable[9]
					showLight(lightName,lightColour,markLat,markLong,lInfo,"lights")
				end
			end
		end
	end
end

function showLight(lightName,lightColour,markLat,markLong,lInfo,LorM)

	isLights=true
	newLight=display.newImageRect("images/"..lightColour..LorM..".png",40/MD.multiplier,40/MD.multiplier)
	newLight.name=lightName
	newLight.touch=lightListener
	newLight:addEventListener( "touch", newLight )
	newLight.info=lightName.."\n"..lInfo.."\n\n"..navMaths.dmmString(markLat,markLong)
	local theLat=navMaths.getPixelsFromLat(markLat)-MD.mapH/2
	local theLong=navMaths.getPixelsFromLong(markLong)-MD.mapW/2
	newLight.x,newLight.y=theLong,theLat
	newLight.alpha=1
	lightGroup:insert(newLight)
	if (lightView==false) then 
		lightGroup.alpha=0
		viewButtons[6]=false
	end
end

function lightListener(self,touch)
	local phase = touch.phase
	if (phase=="began") then
		if finger~=nil then 
			uiGroup:toFront()
			if (fTimer~=nil) then timer.cancel( fTimer ) end
			transition.to(finger,{time=50,alpha=1})
			transition.to(finger,{time=200,x=touch.x,y=touch.y})
			fTimer=timer.performWithDelay(1000,function() transition.to(finger,{time=200,alpha=0}) end)
		end
	end
	if (phase=="ended") then
		clearPanel()
		thePanel=ui.makeReadNotesPanel(220,10,420,180,self.info,"greybutton","Done",clearPanel)
		screenGroup:insert(thePanel)
	end
	return true
end

function loadTracks()
	myTracks=IO.loadFile("myTracks.txt")
	trackGroup.alpha=1
	for i=1,#myTracks do
		if (myTracks[i]~="") then 
			local fileTable = myTracks[i]:split(",")
			MD.markLat=(tonumber(fileTable[1]))
			MD.markLong=(tonumber(fileTable[2]))
			-- if (MD.markLat<MD.topLat) and (MD.markLat>MD.bottomLat) and (MD.markLong>MD.topLong) and (MD.markLong<MD.bottomLong) then
				startWayPoint(0,true,fileTable[3],i,"tr")
			-- else

			-- end
		end
	end
end

function switchSub(x)
	--called from menu button
		if (subGroup.alpha==1) then
			subGroup.alpha=0
			viewButtons[x]=false
			doMessage("Subchart display OFF","",2,2000)
		else
			subGroup.alpha=1
			viewButtons[x]=true
			doMessage("Subchart display ON","",2,2000)
		end
		clearPanel()
		return true
end

function switchRoute(x)
	--called from menu button	
		if (routeGroup.alpha==1) then
			routeGroup.alpha=0
			viewButtons[x]=false
			doMessage("Route display OFF","",2,2000)
		else
			routeGroup.alpha=1
			viewButtons[x]=true
			doMessage("Route display ON","",2,2000)
		end
		clearPanel()
		return true
end

function switchTides(x)
	clearPanel()
	if (tideGroup.alpha==1) then
		tideGroup.alpha=0
		viewButtons[x]=false
		doMessage("Tide locations display OFF","",2,2000)
		tideView=false
	else
		loadTidePorts()
		tideGroup.alpha=1
		viewButtons[x]=true
		doMessage("Tide locations display ON","",2,2000)
		tideView=true
	end
	return true
end

function switchNM(x)
	clearPanel()
	if (nmGroup.alpha==1) then
		nmGroup.alpha=0
		viewButtons[x]=false
		doMessage("Notice to Mariners display OFF","",2,2000)
		nmView=false
	else
		loadNM()
		nmGroup.alpha=1
		viewButtons[x]=true
		doMessage("Notice to Mariners display ON","",2,2000)
		nmView=true
	end
	return true
end

function switchHarbours(x)
	clearPanel()
	if (harbourGroup.alpha==1) then
		harbourGroup.alpha=0
		viewButtons[x]=false
		doMessage("Harbours display OFF","",2,2000)
		hbView=false
	else
		loadHarbours()
		harbourGroup.alpha=1
		viewButtons[x]=true
		doMessage("Harbours display ON","",2,2000)
		hbView=true
	end
	return true
end

function switchLights()
	clearPanel()
	if (lightGroup.alpha==1) then
		lightGroup.alpha=0
		viewButtons[6]=false
		doMessage("Lights display OFF","",2,2000)
		lightView=false
	else
		if (chartScale<60000) then 
			loadLights("marks")
			loadLights("lights")
			doMessage("Lights and Marks display ON","",2,2000)
		else
			loadLights("lights")
			doMessage("Lights display ON","",2,2000)
		end
		lightGroup.alpha=1
		viewButtons[6]=true
		
		lightView=true
	end
	return true
end

function switchSC()
	clearPanel()
	if (scGroup.alpha==1) then
		scGroup.alpha=0
		viewButtons[8]=false
		doMessage("Sailing Club display OFF","",2,2000)
		scView=false
	else
		loadSailingClubs()
		scGroup.alpha=1
		viewButtons[8]=true
		doMessage("Sailing Club  display ON","",2,2000)
		scView=true
	end
	return true
end

function switchMark(x)
	--called from menu button
	clearPanel()
	if (waypGroup.alpha==1) then
		waypGroup.alpha=0
		viewButtons[x]=false
		wpView=false
		doMessage("Marks display OFF","",2,2000)
	else
		-- if (waypGroup.numChildren==0) then
			loadWayPoints()
			-- viewButtons[x]=true
			
		-- else
			waypGroup.alpha=1
			viewButtons[x]=true
			doMessage("Marks display ON","",2,2000)
			wpView=true
		-- end
	end
	
	return true
end

function switchTracking()
	--called from menu button
	-- clearPanel()
	-- if (trackingOn) then
		-- boatIcon.alpha=1
		-- thePanel=ui.makeNewPanel("trackingoff",800,500,200,260,false,"redbutton","Tracking Off",trackToggle,"greybutton","cancel",clearPanel)
		-- screenGroup:insert(thePanel)
	-- else
		-- thePanel=ui.makeNewPanel("trackingon",800,140,200,260,false,"greenbutton","Tracking On",trackToggle,"bluebutton","Show/Hide Track",switchTrackView,"bluebutton","Email track",sendTrack,"greybutton","cancel",clearPanel)
		-- screenGroup:insert(thePanel)
		-- boatIcon.alpha=1
	-- end
	-- return true
end

function switchTrackView(x)
	clearPanel()
	if (trackGroup.alpha==1) then
		trackGroup.alpha=0
		boatIcon.alpha=0
		--viewButtons[x]=false
		doMessage("Track display OFF","",2,2000)
	else
		trackGroup.alpha=1
		boatIcon.alpha=1
		--viewButtons[x]=true
		doMessage("Track display ON","",2,2000)
	end
	
	return true
end

function doTrackOps()
	thePanel=ui.makeNewPanel("track save",800,140,200,260,false,"greenbutton","Send Track",saveTheTrack,"redbutton","Clear Track",clearTrack,"yellowbutton","Load Track",loadTracks,"greybutton","cancel",clearPanel)
	screenGroup:insert(thePanel)
end

function trackToggle()
	if (trackingOn) then
		trackingOn=false
		locGroup.alpha=0
		Runtime:removeEventListener( "location", loc.locationHandler )
		Runtime:removeEventListener( "enterFrame", loc.moveBoat )
		system.setIdleTimer( true )
	else
		trackingOn=true
		locGroup.alpha=1
		trackGroup.alpha=1
		boatIcon.alpha=1
		if environment == "simulator" then
			startLat=currentLat
			startLong=currentLong
			theLocationTimer=system.getTimer()+500
			Runtime:addEventListener( "enterFrame", loc.moveBoat )
		else
			theLocationTimer=system.getTimer()+5000
			Runtime:addEventListener( "location", loc.locationHandler )
		end
		system.setIdleTimer( false )
	end
	clearPanel()
end

function doMessage(text1,text2,size,timeOut)
	local size=size or 2
	clearMessage()
	messageBox=display.newGroup()	
	local behindRect = display.newRoundedRect(messageBox,190,80,644,110,20)
	behindRect:setFillColor(0,0,.7,0.7)
	behindRect.anchorX = 0
	behindRect.anchorY = 0
	local textOptions={parent=messageBox,text="",x=200,y=120,width=624,height=100,font=native.systemFont,fontSize=24,align="center"}
	messageText = display.newText(textOptions)
	messageText:setTextColor(1,1,1,1)
	messageText.anchorX=0
	messageText.anchorY=0
	local textOptions={parent=messageBox,text="",x=200,y=80,width=624,height=70,font=native.systemFont,fontSize=36,align="center"}
	messageTextBig = display.newText(textOptions)
	messageTextBig:setTextColor(1,1,1,1)
	messageTextBig.anchorX=0
	messageTextBig.anchorY=0
	screenGroup:insert(messageBox)

	if (mTimer~=nil) then timer.cancel( mTimer ) end
	
	if (optionMessageOn) then
		myTimeOut=timeOut or 5000
		--messageBox.alpha=1
		--called from initChart and various functions
		
		if (size==1) then 
			messageBox[3].text=text1
			messageBox.y=200
		end
		if (size==2) then 
			messageBox[2].text=text1
			messageBox.y=40
		end
		if (size==3) then 
			messageBox[2].text=text2
			messageBox[3].text=text1
			messageBox.y=40
		end
		mTimer=timer.performWithDelay(myTimeOut,clearMessage)
	end
end

function clearMessage()
	-- if (messageBox~=nil) then
	-- if (messageBox[2]~=nil) then messageBox[2].text="" end
	-- if (messageBox[3]~=nil) then messageBox[3].text="" end
	-- messageBox.alpha=0
	-- end
	display.remove(messageBox)
end

function menuListener(self, touch) 
	return true
end

function capScreen()
-- capture screen panel
	--if (thePanel==nil) then 
		--capButton.alpha=1
		clearPanel()
		thePanel=ui.makeNewPanel("capturescreen",120,140,200,20,false,"bluebutton","Screen grab\nfor emailing",captureScreen,"greybutton","cancel",clearPanel)
		--MD.hTime=timer.performWithDelay(shortTimeOut,function() clearPanel() end)
		screenGroup:insert(thePanel)
	--else local alert = native.showAlert( "NOTE", "The panel must be closed first" ,{ "NEXT" }) end
	return true
end

function zoomPanel()
	if (thePanel==nil) then
		--if (MD.mapW>1024) or (MD.mapH>768) then
			zoomButton.alpha=1
			thePanel=ui.makeNewPanel("zoom",leftEdge+140,140,200,20,false,"bluebutton","Zoom in",zoom.zoomIn,"bluebutton","Zoom out",zoom.zoomOut,"greybutton","cancel",clearPanel)
			screenGroup:insert(thePanel)
			MD.hTime=timer.performWithDelay(longTimeOut,function() clearPanel() end)
		--end
	else
		local alert = native.showAlert( "NOTE", "The panel ("..thePanel.name..") must be closed first" ,{ "NEXT" }) --need to add panelname
	end
	return true
end

function captureScreen()
	clearPanel()
	menuGroup.alpha=0
	uiGroup.alpha=0
	if (subGroup.alpha==1) then subGroup.alpha=0 end
	local watermark=display.newImageRect("images/watermark.png",1024,768)
	watermark.anchorX,watermark.anchorY=0,0
	watermark.alpha=0.1
	local screenCap = display.captureScreen( true )
	watermark:removeSelf()
	watermark=0
	
	display.save( screenCap, { filename="chartsNav.jpg", baseDir=system.DocumentsDirectory, isFullResolution=true, backgroundColor={0, 0, 0, 0} } )
	
    screenCap:removeSelf()
	menuGroup.alpha=1
	uiGroup.alpha=1
	doMessage("Screen captured and saved to pictures folder","",2)
	if ( native.canShowPopup( "mail" ) ) then
		local options =
		{
		subject = "ChartsNav Chart Screenshot -"..chartNum,
		body = "Chart "..chartName,
		attachment = { baseDir=system.DocumentsDirectory,
		filename="chartsNav.jpg", type="jpg" },
		}
		native.showPopup("mail", options)
	else
		doMessage("Screen captured and saved to pictures folder. No email options available","",2)
	end
end

function sendTrack()
	if ( native.canShowPopup( "mail" ) ) then
		local options =
		{
		subject = "ChartsNav track",
		body = "Track",
		attachment = { baseDir=system.DocumentsDirectory,
		filename="myTracks.txt", type="txt" },
		}
		native.showPopup("mail", options)
	else
		doMessage("No email options available","",1)
	end
end

function sendSysInfo()
	if ( native.canShowPopup( "mail" ) ) then
		local sysInfo=system.getInfo( "deviceID" ).."\n"..system.getInfo( "architectureInfo")
		local options =
		{
		to = "tech@realcharts.net",
		subject = "sysInfo",
		body = sysInfo,
		}
		native.showPopup("mail", options)
	end
end

function captureScreenError(errorText)
	
	local screenCap = display.captureScreen( true )
	
	display.save( screenCap, { filename="chartsNav.jpg", baseDir=system.DocumentsDirectory, isFullResolution=true, backgroundColor={0, 0, 0, 0} } )
	
    screenCap:removeSelf()
	menuGroup.alpha=1
	uiGroup.alpha=1
	if environment ~= "simulator" then
	local options =
	{
	to = "conor@onolan.com",
	subject = "error",
	body = errorText,
	attachment = { baseDir=system.DocumentsDirectory,
	filename="chartsNav.jpg", type="jpg" },
	}
	native.showPopup("mail", options)
	end
end

function switchLock(x)
	--called from menu button
	clearPanel()
	if (locked) then
		locked=false
		doMessage("Chart unlocked","",1)
		toolButtons[x]=false
	else
		locked=true
		toolButtons[x]=true
		doMessage("Chart locked, can't move","",1)
	end
	return true
end

function switchDay(x)
	--called from menu button
	clearPanel()
	if (nightMode) then
		nightMode=false
		toolButtons[x]=false
		nightGroup.alpha=0
		doMessage("Night Mode OFF","",2,2000)
	else
		nightMode=true
		toolButtons[x]=true
		nightGroup.alpha=1
		doMessage("Night Mode ON","",2,2000)
	end
	
	return true
	--end
end

function switchInfoListener()--NEEDED???
	wpInfoGroup.alpha=0
end

function makeMOBPanel()
	isMOB=true
	mobPanel=ui.makeMOBPanel(rightEdge-610,bottomEdge-310,600,200,280,50,36,"greybutton","cancel",clearPanel,"redbutton","cancel",checkCancelMOB,"greybutton","cancel",clearPanel)
	screenGroup:insert(mobPanel)
	mobPanel.touch=mobListener
	mobPanel:addEventListener( "touch", mobPanel )
end

function mobListener(self,touch)
	local phase = touch.phase
	if ( phase == "ended" ) then
		if (mobPanel.xScale==1) then
			mobPanel.xScale=0.5
			mobPanel.yScale=0.5
			mobPanel.x=mobPanel.x+300
			mobPanel.y=mobPanel.y+160
		else
			mobPanel.xScale=1
			mobPanel.yScale=1
			mobPanel.x=mobPanel.x-300
			mobPanel.y=mobPanel.y-160
		end
	end
	return true
end

function checkCancelMOB()
	thePanel=ui.makeNewPanel("cancelMOB",200,500,200,20,false,"redbutton","Cancel MOB\nare you sure",cancelMOB,"greenbutton","Keep MOB",clearPanel)
	screenGroup:insert(thePanel)
end

function cancelMOB()
	clearPanel()
	display.remove(mobPanel)
	mobPanel=nil
	isMOB=false
end

function loadTide(tideData)
	
	if (not thePanel) then
		isTide=true
		thePanel=NT.startTide(tideData)
		thePanel.x=230
		thePanel.y=80
		screenGroup:insert(thePanel)
	end
	return true
end

function hideTide()
	isTide=false 
	clearPanel()
	return true
end

function slideInfo(self,touch)
	if (ort=="V") then
		if mainInfoGroup.x==0 then 
			transition.to( infoClose1, { time=500, alpha=0 })
			transition.to( infoClose, { time=500, x=-90 })
			transition.to( mainInfoGroup, { time=500, x=840-leftEdge} )
		else
			infoClose1.alpha=1
			infoClose.x=0
			transition.to( mainInfoGroup, { time=500, x=0 } )
		end
	else
		if mainInfoGroup.x==0 then 
			infoClose1.alpha=0
			transition.to( infoClose, { time=500, x=-70 })
			transition.to( mainInfoGroup, { time=200, x=440} )
			
		else
			infoClose1.alpha=1
			infoClose.x=0
			transition.to( mainInfoGroup, { time=500, x=0 } )
		end
	
	end
	return true
end

function setRouteLoadPanel()
	clearPanel()
	local routeNames=IO.checkRouteFiles()
	if (table.maxn(routeNames)~=0) then
		thePanel=ui.makeListPanel("route list",120,150,270,200,6,routes.loadRoutes,routeNames,"greybutton","cancel",clearPanel)
		screenGroup:insert(thePanel)
		MD.hTime=timer.performWithDelay( 3000,function() clearPanel() end)
	end
	return true
end

function setWPListPanel()
	clearPanel()
	local wpList={}
	for i=1,table.maxn(myWayPoints) do
		local getDist=navMaths.getDistance(currentLat,currentLong,myWayPoints[i][3],myWayPoints[i][4],1)
		wpList[i]={getDist,myWayPoints[i][2],myWayPoints[i][3],myWayPoints[i][4]}
	end
	wpList=sortTable(wpList)
	thePanel=ui.makeListPanel(120,150,270,200,6,setGoto,wpList,"greybutton","cancel",clearPanel)
	screenGroup:insert(thePanel)	
	return true
end

function sortTable(t)
	local lowest = 100000
	local temp = {} 	
	v = 0		
		for c=1, #t do		
			for i =1, #t do						
			   if tonumber(t[i][1]) < lowest then	
	   
					lowest = t[i][1]
					v = i
			   end
			end
		temp[c] = t[v]
		table.remove( t, v ) 
		lowest = 1000000
		end
	return temp 
end

function setGoto(data)-- data comes from ui.makeListPanel 
	clearPanel()
	makeGoto(true,data[3],data[4])
end

function makeNumPanelDDD()
	thePanel= ui.inputNumPanelDDD(140,120,220,300,numInputDDD,"bluebutton","Submit",clearPanel,"greybutton","cancel",clearPanel)
	theNumSlot=6
	screenGroup:insert(thePanel)	
	return true
end

function makeNumPanelDMM()
	clearPanel()
	getPanelType="numPanel" 
	thePanel= ui.inputNumPanelDMM(rightEdge-275,80,270,300,latDir,longDir,numInputDMM,tabInput,"redbutton","Clear",clearInput,"bluebutton","Submit",getDMM,"greybutton","cancel",clearPanel)
	theNumSlot,theInputSlot=3,1
	theLatDir,theLongDir=1,1
	screenGroup:insert(thePanel)
	return true
end

function latDir()
	theLatDir=-theLatDir
	thePanel[6][2].alpha=theLatDir
end

function longDir()
	theLongDir=-theLongDir
	thePanel[6][4].alpha=theLongDir
end

function getDMM()
	local newLatD,newLatMM,newLongD,newLongMM
	--local theLatDir,theLongDir=1,1
	if (theLatDir==nil) then theLatDir=1 end
	if (theLongDir==nil) then theLongDir=1 end
	currentType="wp"
	if (getPanelType=="numPanel") then
		newLatD=tonumber(thePanel[2][1].text..thePanel[2][2].text..thePanel[2][3].text)
		newLatMM=tonumber(thePanel[3][1].text..thePanel[3][2].text.."."..thePanel[3][3].text..thePanel[3][4].text)
		newLongD=tonumber(thePanel[4][1].text..thePanel[4][2].text..thePanel[4][3].text)
		newLongMM=tonumber(thePanel[5][1].text..thePanel[5][2].text.."."..thePanel[5][3].text..thePanel[5][4].text)
	else
		local pickLat=pickerWheelLat:getValues()
		local pickLong=pickerWheelLong:getValues()
		if (tonumber(pickLat[1].value)<0) then theLatDir=-1 end
		if (tonumber(pickLong[1].value)<0) then theLongDir=-1 end

		newLatD=math.abs(tonumber(pickLat[1].value))
		newLatMM=tonumber(pickLat[2].value.."."..pickLat[3].value)
		newLongD=math.abs(tonumber(pickLong[1].value))
		newLongMM=tonumber(pickLong[2].value.."."..pickLong[3].value)
	end
	--CANNOT PASS MINUS TO navMaths.dmm2ddd, MINUS ADDED AFTER
	MD.markLat=theLatDir*navMaths.dmm2ddd(newLatD,newLatMM)
	MD.markLong=theLongDir*navMaths.dmm2ddd(newLongD,newLongMM)
	MD.pixY=navMaths.getPixelsFromLat(MD.markLat)
	MD.pixX=navMaths.getPixelsFromLong(MD.markLong)
	if chartPointer==0 then chartPointer=1 end
	MD.topLat=tonumber(chartInfo[chartPointer][7])
	MD.topLong=tonumber(chartInfo[chartPointer][8])
	MD.bottomLat=tonumber(chartInfo[chartPointer][9])
	MD.bottomLong=tonumber(chartInfo[chartPointer][10])
	clearPanel()
	
	startWayPoint()
	if (MD.markLat<MD.topLat) and (MD.markLat>MD.bottomLat) and (MD.markLong>MD.topLong) and (MD.markLong<MD.bottomLong) then
		doMessage("Placing waypoint","",2,2000)
	else
		doMessage("Placing waypoint outside this chart","",2,3000)
	end
	
end

function makeKeyboardPanel()
	-- receiving function needed
	thePanel=ui.keyPanel(120,400,800,300,textInput,"numbutton","space",textInput,"greybutton","cancel",clearPanel)
	screenGroup:insert(thePanel)
	return true
end

function textInput()
	local keyTable={"1","2","3","4","5","6","7","8","9","0","-","Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","@","Z","X","C","V","B","N","M",".","_","'"}
end

function tabInput(self, touch)
-- called from makeNumPanelDMM. Used for num input on numInputDMM (numInputDDD)?
	local phase=touch.phase
	if (phase=="ended") then
		theInputSlot=self.num
		if (theInputSlot==1) then
			thePanel[2].alpha=1
			thePanel[3].alpha=0.5
			thePanel[4].alpha=0.5
			thePanel[5].alpha=0.5
			theNumSlot=3
		elseif (theInputSlot==2) then

			thePanel[2].alpha=0.5
			thePanel[3].alpha=1
			thePanel[4].alpha=0.5
			thePanel[5].alpha=0.5
			theNumSlot=4
		elseif (theInputSlot==3) then

			thePanel[2].alpha=0.5
			thePanel[3].alpha=0.5
			thePanel[4].alpha=1
			thePanel[5].alpha=0.5
			theNumSlot=3
		else

			thePanel[2].alpha=0.5
			thePanel[3].alpha=0.5
			thePanel[4].alpha=0.5
			thePanel[5].alpha=1
			theNumSlot=4
		end
	end
end

function numInputDMM(x)
	local numTable={"1","2","3","4","5","6","7","8","9","-","0","."}
	if (x==10) and ((theInputSlot==2)or(theInputSlot==4)) then
		local alert = native.showAlert( "Problem", "Minus only for Degree number", { "NEXT" } )
	else
		if (theInputSlot==1) then
			if (theNumSlot<3) then
				for i=1,2 do
					thePanel[2][i].text=thePanel[2][i+1].text
				end
			end
			thePanel[2][3].text=numTable[x]
			if (x==10) then
				thePanel[2][1].text=""
				thePanel[2][2].text=""
			end
			theNumSlot=theNumSlot-1
		elseif (theInputSlot==2) then
			if (theNumSlot<5) then
				for i=1,3 do
					thePanel[3][i].text=thePanel[3][i+1].text
				end
			end
			thePanel[3][4].text=numTable[x]
			theNumSlot=theNumSlot-1
		elseif (theInputSlot==3) then
			if (theNumSlot<3) then
				for i=1,2 do
					thePanel[4][i].text=thePanel[4][i+1].text
				end
			end
			thePanel[4][3].text=numTable[x]
			if (x==10) then
				thePanel[4][1].text=""
				thePanel[4][2].text=""
			end
			theNumSlot=theNumSlot-1
		else
			if (theNumSlot<5) then
				for i=1,3 do
					thePanel[5][i].text=thePanel[5][i+1].text
				end
			end
			thePanel[5][4].text=numTable[x]
			theNumSlot=theNumSlot-1
		end
	end
end

function clearInput()
	thePanel[theInputSlot+1][1].text=0
	thePanel[theInputSlot+1][2].text=0
	thePanel[theInputSlot+1][3].text=0
	if (theInputSlot==2) or (theInputSlot==4) then thePanel[theInputSlot+1][4].text=0 end
end

function numInputDDD(x)
	local numTable={"1","2","3","4","5","6","7","8","9","-","0","."}
	if (theNumSlot<7) then
	for i=1,6 do
		thePanel[2][i].text=thePanel[2][i+1].text
	end
	end
	thePanel[2][7].text=numTable[x]

	theNumSlot=theNumSlot-1
end

function checkGroup(theGroup)
print("theGroup.numChildren",theGroup.numChildren)
	for i=1, theGroup.numChildren do
		print("level ["..i.."]",theGroup[i].numChildren)
		if (theGroup[i].numChildren>1) then
			for j=1, theGroup[i].numChildren do
				print("level ["..i.."]["..j.."]",theGroup[i][j].numChildren,theGroup[i],theGroup[i][j])
				-- if (theGroup[i][j].numChildren>1) then
					-- for k=1, theGroup[i][j].numChildren do
						-- print("level 1.3",theGroup[i][j][k].numChildren)
					-- end
				-- end
			end
		end
	end
end

function print_r ( t )  
--print out table contents
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end



---------------------------------------------------------------------------------
-- END OF IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "create", scene )
scene:addEventListener( "destroy", scene )

return scene
