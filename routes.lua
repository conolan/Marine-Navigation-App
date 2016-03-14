	local RT = {}
local http = require("socket.http")
local ltn12 = require("ltn12")

function RT.startRoute(isLoaded,isShow)
--called from checkMark on first route point only
	clearPanel()
	if routeGroup.numChildren>0 then 
		emptyGroup(routeGroup)
		routeTable={}
		routePix={}
		routeGroup=nil 
		routePos=0
		routeGroup=display.newGroup()
		mapContainer:insert(routeGroup)
	end
	local theLat=navMaths.getPixelsFromLat(MD.markLat)-MD.mapH/2
	local theLong=navMaths.getPixelsFromLong(MD.markLong)-MD.mapW/2
	MD.pixY=navMaths.getPixelsFromLat(MD.markLat)
	MD.pixX=navMaths.getPixelsFromLong(MD.markLong)
	routeGroup.alpha=1
	isRoute=true
	if (not isLoaded) then
		thePanel=ui.makeNewPanel("route saveclear",rightEdge-275,140,200,260,false,"greenbutton","Save Route",routes.saveTheRoute,"redbutton","Clear Route",routes.clearRoute,"yellowbutton","Clear Last",routes.clearLast) 
		screenGroup:insert(thePanel)
	end
	newRoute=display.newGroup()
	newInfoRoute=display.newGroup()
	newRouteLine=display.newGroup()
	
	-- local nodeInfoGroup=display.newGroup()
	-- local rect = display.newRoundedRect(nodeInfoGroup,theLong-12,theLat-12, 180,80,5 )
	-- rect:setFillColor(1,1,1,0.8)
	-- rect.anchorX=0
	-- rect.anchorY=0
	-- local textOptions={parent=nodeInfoGroup, text=MD.markLat.."\n"..MD.markLong,x=10+theLong,y=theLat,width=150,height=60,font=native.systemFont,fontSize=18}
	-- local wpText = display.newText(textOptions)
	-- wpText:setTextColor(0,0,1)
	-- wpText.anchorX = 0
	-- wpText.anchorY = 0
	routeGroup:insert(newRouteLine)
	-- newInfoRoute:insert(nodeInfoGroup)
	routeGroup:insert(newInfoRoute)
	routeGroup:insert(newRoute)
	routePos=routePos+1
	if (not isLoaded) or (isShow) then
		makeWayPoint(theLat,theLong,MD.markLat,MD.markLong,newRoute,"rt",false,0)
		local myHide = function() if (routeGroup[2][1]~=nil) then routeGroup[2][1].alpha=0 end end
		MD.hTime=timer.performWithDelay( shortTimeOut, myHide, 1 )
	else
		wpGroup=display.newGroup()
		newRoute:insert(wpGroup)
		MD.pixY=navMaths.getPixelsFromLat(MD.markLat)
		MD.pixX=navMaths.getPixelsFromLong(MD.markLong)
		local newPoint={}
		local newPix={}
		table.insert(newPix,MD.pixX)
		table.insert(newPix,MD.pixY)
		table.insert(newPoint,MD.markLat)
		table.insert(newPoint,MD.markLong)
		
		table.insert(newPoint,dist)
		table.insert(routeTable,newPoint) 
		table.insert(routePix,newPix) 
	end
	if (not isLoaded) then doMessage("First route point has been recorded. Click&hold again for your next route point",",",2,3000) end
	return true
end

function RT.addRouteNode(isShow,numOnRoute)
	local theLat=navMaths.getPixelsFromLat(MD.markLat)-MD.mapH/2
	local theLong=navMaths.getPixelsFromLong(MD.markLong)-MD.mapW/2
	local amLast=false
	routePos=routePos+1
	if (numOnRoute~=nil) then
		if (routePos==numOnRoute-1) then amLast=true end
	end
	local segDist=navMaths.getDistance(routeTable[routePos-1][1],routeTable[routePos-1][2],MD.markLat,MD.markLong)

	
	if (isShow) then
		MD.pixY=navMaths.getPixelsFromLat(MD.markLat)
		MD.pixX=navMaths.getPixelsFromLong(MD.markLong)
		makeWayPoint(theLat,theLong,MD.markLat,MD.markLong,newRoute,"rt",false,navMaths.makeNumD(segDist,1,true),0,"",amLast)
		local totalDist=measureDistance()
		wpInfo.text="Node "..routePos.."\n"..routeTable[routePos][3].."nm\nTotal: "..totalDist.."\n"..routeTable[routePos][1].."\n"..routeTable[routePos][2]
		local myLine=display.newLine(newRouteLine, -MD.mapW/2+(MD.pixX),-MD.mapH/2+(MD.pixY),-MD.mapW/2+(routePix[routePos-1][1]),-MD.mapH/2+(routePix[routePos-1][2]))
		myLine:setStrokeColor( 1, 0, 0, 0.7 )
		myLine.strokeWidth = 4/MD.multiplier
		wpInfoGroup.alpha=1

		-- local nodeInfoGroup=display.newGroup()
		-- local rect = display.newRoundedRect(nodeInfoGroup,theLong-12,theLat-12, 180,80,5 )
		-- rect:setFillColor(1,1,1,0.8)
		-- rect.anchorX=0
		-- rect.anchorY=0
		-- local textOptions={parent=nodeInfoGroup, text=navMaths.makeNumD(segDist,1,true).."nm\nTotal: "..totalDist.."\n"..MD.markLat.."\n"..MD.markLong,x=10+theLong,y=theLat,width=150,height=60,font=native.systemFont,fontSize=18}
		-- local wpText = display.newText(textOptions)
		-- wpText:setTextColor(0,0,1)
		-- wpText.anchorX = 0
		-- wpText.anchorY = 0
		-- newInfoRoute:insert(nodeInfoGroup)
	else
		wpGroup=display.newGroup()
		newRoute:insert(wpGroup)
		MD.pixY=navMaths.getPixelsFromLat(MD.markLat)
		MD.pixX=navMaths.getPixelsFromLong(MD.markLong)
		local newPoint={}
		local newPix={}
		table.insert(newPix,MD.pixX)
		table.insert(newPix,MD.pixY)
		table.insert(newPoint,MD.markLat)
		table.insert(newPoint,MD.markLong)
		
		table.insert(newPoint,dist)
		table.insert(routeTable,newPoint) 
		table.insert(routePix,newPix) 
	end
	local myHide = function() 
		if  (routeGroup.numChildren~=0) then
			if (routeGroup[2].numChildren~=nil) then
				for i=1,routeGroup[2].numChildren do-- hiding info, after lines made first level
					routeGroup[2][i].alpha=0 
				end
			end
			wpInfoGroup.alpha=0
		end
	end
	MD.hTime=timer.performWithDelay( shortTimeOut, myHide, 1 )
end

function RT.addNode()
	--called from route button panel
	local numWP=routeGroup.numChildren
	
	local newLat=(routeTable[currentWP-1][1]+routeTable[currentWP][1])/2
	local newLong=(routeTable[currentWP-1][2]+routeTable[currentWP][2])/2
	local newDist=routeTable[currentWP][3]/2
	routeTable[currentWP+1][3]=newDist
	local newPoint={}
	local newPix={}
	
	for i=currentWP,table.maxn(routeTable) do
		routeGroup[3][i][2].num=i+1
	end
	pixY=navMaths.getPixelsFromLat(newLat)
	pixX=navMaths.getPixelsFromLong(newLong)
	table.insert(newPix,pixX)
	table.insert(newPix,pixY)
	table.insert(newPoint,newLat)
	table.insert(newPoint,newLong)
		
	table.insert(newPoint,newDist)
	table.insert(routeTable,currentWP,newPoint) 
	table.insert(routePix,currentWP,newPix) 
	routes.redrawRoute()
	routes.updateTheRoute()
	clearPanel()
	wpInfoGroup.alpha=0
	return true
end

function RT.extendRoute()
	--blink the end pos
	doMessage("Your next click will extend the route from the end point","",2,3000)
	isRoute=true
	routePos=table.maxn(routeTable)
	oldRoutePos=routePos
	clearPanel()
	thePanel=ui.makeNewPanel("extendroute",rightEdge-235,140,200,220,false,"greenbutton","Accept\nchange is kept",routes.extendDone,"greybutton","cancel",routes.cancelMod)
	screenGroup:insert(thePanel)

end

function RT.extendDone()
	routes.redrawRoute()
	routes.updateTheRoute()
end

function RT.saveTheRoute()
	--called from startRoute button panel Not used for saving data
	--routeGroup[2][routePos].alpha=0
	clearPanel()
	isRoute=false
	isRouteConvert=false
	canEditRoute=false
	local theDate=os.date("%d%m%Y" )
	MD.defaultText="Route "..string.gsub(theDate,"-","")
	routePos=0
	if (isPhone) then
		thePanel=ui.makeNewPanel("routename",rightEdge-415,100,400,180,true,"greenbutton","Submit",routes.getRouteName,"greybutton","Cancel",routes.cancelRoute)
	else
		thePanel=ui.makeNewPanel("routename",rightEdge-315,140,300,180,true,"greenbutton","Submit",routes.getRouteName,"greybutton","Cancel",routes.cancelRoute)
	end
	screenGroup:insert(thePanel)
	return true
end

function RT.cancelRoute()
-- same as clearroute, might merge
	doMessage("Route cleared without saving","",2,3000)
	display.remove(newInfoRoute)
	display.remove(newRoute)
	display.remove(newRouteLine)
	newRouteLine=nil
	newRoute=nil
	newInfoRoute=nil
	routeTable={}
	routePix={}
	isRoute=false
	isRouteConvert=false
	routePos=0
	clearPanel()
end

function RT.cancelMod()
	-- needs to loop through if more than one
	-- or reload route
	doMessage("No changes made to route","",2,3000)
	for i=oldRoutePos+1, routePos do
		routes.clearLast()
	end
	--routePos=OldRoutePos
	isRoute=false
	isRouteConvert=false
	clearPanel()
end

function RT.getRouteName()
	--called from saveTheRoute button panel
	local InputName
	table.insert(routeNameTable,inputField.text) 
	inputName=inputField.text

	clearPanel()
	local routeData=inputName
	local theDate=os.date("%d%m%Y" )
	routeData=routeData..","..theDate.."\n"
	for i=1,#routeTable-1 do
		routeData=routeData..inputName.."-"..i..","..table.concat(routeTable[i], ", ").."\n"
	end
	routeData=routeData..inputName.."-"..#routeTable..","..table.concat(routeTable[#routeTable], ", ")
	IO.saveRoute(inputName,routeData)
	routes.redrawRoute()
	--routes.updateTheRoute()
	viewButtons[3]=true
	-- check clearpanel usage
end

function RT.clearRoute(message)
	--called from setRoute button panel
	local theMessage=message or "Route cleared"
	doMessage(theMessage)
	display.remove(newInfoRoute)
	display.remove(newRoute)
	display.remove(newRouteLine)
	routeTable={}
	routePix={}
	isRoute=false
	isRouteConvert=false
	routePos=0
	clearPanel()
	wpInfoGroup.alpha=0
	IO.deleteRoute(routeNameTable[1])
	return true
end

function RT.clearLast()
	--called from setRoute button panel
	display.remove(newInfoRoute[routePos])
	display.remove(newRoute[routePos])
	display.remove(newRouteLine[routePos-1])
	table.remove(routeTable) -- this is probably right
	table.remove(routePix) -- this is probably right
	routePos=routePos-1
	if (routePos==0) then
		routes.clearRoute()		
	else
		local totalDist=measureDistance()
		if (wpInfo~= nil) then wpInfo.text="Node "..routePos.."nm\nTotal: "..totalDist.."\n"..routeTable[routePos][3].."nm\n"..routeTable[routePos][1].."\n"..routeTable[routePos][2] end
		
	end
end

function RT.editRoute()
	--called from setRoute button panel
	doMessage("Click to delete any route node","",2,3000)
	isRoute=false
	isRouteConvert=false
	canEditRoute=true
	clearPanel()
	thePanel=ui.makeNewPanel("route options",rightEdge-270,100,200,260,false,"greenbutton","Save Route",routes.updateTheRoute,"redbutton","Clear Route",routes.clearRoute,"greybutton","cancel",cancelEditRoute)
	screenGroup:insert(thePanel)
	return true
end

function RT.moveRoute()
	--called from setRoute button panel
	doMessage("Click and drag any route node","",2,3000)
	isRoute=false
	isRouteConvert=false
	canMoveRoute=true
	clearPanel()
	thePanel=ui.makeNewPanel("move routenode",rightEdge-235,140,200,220,false,"greenbutton","Accept\nchange is kept",reposWP,"greybutton","cancel",cancelMove)
	screenGroup:insert(thePanel)
	MD.oldY=routeGroup[3][currentWP].y
	MD.oldX=routeGroup[3][currentWP].x
	return true
end

function RT.cancelEditRoute()
	clearPanel()
	canEditRoute=false
	canMoveRoute=false
end

function RT.updateTheRoute() --needed
	--rebuilds data from last route edited and resaves it
	canEditRoute=false
	canMoveRoute=false
	isRoute=false
	isRouteConvert=false
	local routeName=routeNameTable[table.maxn(routeNameTable)]
	if routeName==nil then routeName=theTime end
	local routeData=routeName
	local theDate=os.date("%d%m%Y" )
	routeData=routeData..","..theDate.."\n"
	for i=1,#routeTable-1 do
		routeData=routeData..routeName.."-"..i..","..table.concat(routeTable[i], ", ").."\n"
	end
	routeData=routeData..routeName.."-"..#routeTable..","..table.concat(routeTable[#routeTable], ", ")
	IO.saveRoute(routeNameTable[table.maxn(routeNameTable)],routeData)
	routeData=""
	clearPanel() 
end

function RT.checkRoutes()
	-- if (routeGroup.numChildren>0) then
		-- routeGroup.isVisible =not(routeGroup.isVisible)
	-- else
		-- RT.loadRoutes()
	-- end
end

function RT.loadRoutes(routeName,fileNameGPX)
	clearPanel()
	routePos=0
	routeNameTable,routeTable,routePix={},{},{}
	local myRoute
	if (routeName~=nil) then
		myRoute=IO.loadFile("routes/"..routeName,system.DocumentsDirectory)
	elseif (fileNameGPX~=nil) then 
		myRoute=IO.loadFile(fileNameGPX..".txt") 
	end
	if (myRoute~=nil) then
		currentType="rt"
		MD.topLat=tonumber(chartInfo[chartPointer][7])
		MD.topLong=tonumber(chartInfo[chartPointer][8])
		MD.bottomLat=tonumber(chartInfo[chartPointer][9])
		MD.bottomLong=tonumber(chartInfo[chartPointer][10])

		local fileTable = myRoute[1]:split(",")
		pLoaded=0
		emptyGroup(routeGroup)		
		table.insert(routeNameTable,fileTable[1])
		fileTable = myRoute[2]:split(",")
		MD.markLong=(tonumber(fileTable[3]))
		MD.markLat=(tonumber(fileTable[2]))

		MD.pixY=navMaths.getPixelsFromLat(MD.markLat) --needed because not in saved waypoints
		MD.pixX=navMaths.getPixelsFromLong(MD.markLong)
			
		if (MD.markLat<MD.topLat) and (MD.markLat>MD.bottomLat) and (MD.markLong>MD.topLong) and (MD.markLong<MD.bottomLong) then
			pLoaded=1
			routes.startRoute(true,true)
		else
			routes.startRoute(true,false)
		end
		routePos=1
		
		for i=3,#myRoute do
			fileTable = myRoute[i]:split(",")
			if fileTable[2]~=nil and fileTable[2]~="" then
			-- print(fileTable[2],fileTable[3])
				MD.markLong=(tonumber(fileTable[3]))
				MD.markLat=(tonumber(fileTable[2]))
				-- print(MD.markLat,MD.markLong)
				MD.pixY=navMaths.getPixelsFromLat(MD.markLat) --needed because not in saved waypoints
				MD.pixX=navMaths.getPixelsFromLong(MD.markLong)
				-- print(MD.pixY,MD.pixX)
				if (MD.markLat<MD.topLat) and (MD.markLat>MD.bottomLat) and (MD.markLong>MD.topLong) and (MD.markLong<MD.bottomLong) then
					pLoaded=pLoaded+1
					--print(pLoaded)
					routes.addRouteNode(true,#myRoute)
				else
					routes.addRouteNode(true,#myRoute)
				end	
			end			
		end
		isRoute=false
		isRouteConvert=false
		if (pLoaded==0) then 
			doMessage("Route accessed - no points on this chart","",2,3000)
			wpInfoGroup.alpha=0
			emptyGroup(routeGroup)
			routeNameTable,routeTable,routePix={},{},{}
			routePos=0
			if (MD.hTime~=nil) then timer.cancel( MD.hTime ) end
		else
			doMessage("Route Loaded - "..routePos.." points\nOn This chart - "..pLoaded.." points","",2,3000)
			viewButtons[3]=true
			routes.redrawRoute()
			
		end
	else
		doMessage("No routes available. Create a route by touching the screen",",",2,3000) 
	end
	return true
end

function RT.redrawRoute()
	--called from deleteWP
	display.remove(newRouteLine)
	display.remove(newInfoRoute)
	display.remove(newRoute)
	newRouteLine=display.newGroup()
	newInfoRoute=display.newGroup()
	newRoute=display.newGroup()
	routeGroup:insert(newRouteLine)
	routeGroup:insert(newInfoRoute)
	routeGroup:insert(newRoute)
	local tempRouteTable=routeTable
	local tempRoutePix=routePix

	routeTable={}
	routePix={}
	local amLast=false
	for i = 1,table.maxn(tempRouteTable) do
		routePos=i
		if (i==table.maxn(tempRouteTable)) then amLast=true end
		local segDist=0
		if (i>1) then
		--print(-MD.mapW/2+tempRoutePix[i-1][1],-MD.mapH/2+tempRoutePix[i-1][2],-MD.mapW/2+(tempRoutePix[i][1]),-MD.mapH/2+(tempRoutePix[i][2]))
			local myLine=display.newLine(-MD.mapW/2+tempRoutePix[i-1][1],-MD.mapH/2+tempRoutePix[i-1][2],-MD.mapW/2+(tempRoutePix[i][1]),-MD.mapH/2+(tempRoutePix[i][2]) )
			myLine:setStrokeColor( 1, 0, 0, 0.7 )
			myLine.strokeWidth = 4/MD.multiplier
			newRouteLine:insert(myLine)
			segDist=navMaths.getDistance(tempRouteTable[i-1][1],tempRouteTable[i-1][2],tempRouteTable[i][1],tempRouteTable[i][2])-- is this used??
		end

		local theLat=navMaths.getPixelsFromLat(tempRouteTable[i][1])-MD.mapH/2
		local theLong=navMaths.getPixelsFromLong(tempRouteTable[i][2])-MD.mapW/2
		MD.pixY=theLat+MD.mapH/2--needed because not in saved waypoints
		MD.pixX=theLong+MD.mapW/2
		makeWayPoint(theLat,theLong,tempRouteTable[i][1],tempRouteTable[i][2],newRoute,"rt",false,navMaths.makeNumD(segDist,2),0,"",amLast)

		-- local totalDist=measureDistance()		
		-- local nodeInfoGroup=display.newGroup()
		-- local rect = display.newRoundedRect(nodeInfoGroup,theLong-12,theLat-12, 180,80,5 )
		-- rect:setFillColor(1,1,1,0.8)
		-- rect.anchorX=0
		-- rect.anchorY=0
		-- local textOptions={parent=nodeInfoGroup, text=navMaths.makeNumD(segDist,2,true).."nm\n"..tempRouteTable[i][1].."\n"..tempRouteTable[i][2],x=10+theLong,y=theLat,width=150,height=60,font=native.systemFont,fontSize=18}
		-- local wpText = display.newText(textOptions)
		-- wpText:setTextColor(0,0,1)
		-- wpText.anchorX = 0
		-- wpText.anchorY = 0
		-- newInfoRoute:insert(nodeInfoGroup)
		-- nodeInfoGroup.alpha=0
	end
end

return RT