local init={}

function init.calculateDelta( previousTouches, event )
	local id,touch = next( previousTouches )
	if event.id == id then
		id,touch = next( previousTouches, id )
		assert( id ~= event.id )
	end

	local dx = touch.x - event.x
	local dy = touch.y - event.y

	midX=math.abs((touch.x + event.x)/2)
	midY=math.abs((touch.y + event.y)/2)
	
	offX=mapContainer.x-midX
	offY=mapContainer.y-midY
	
	return dx, dy,midX,midY,offX,offY
end

function init.initChart(chartPointer)
	--called from startChart(chartBack,subListener)
	if finger~=nil then finger.alpha=0 end
	currentChart=chartPointer
	local myMessage
	if (chartPointer~=1) then myMessage="Loading" end
	if (mapContainer~=nil) then 
		if (mapContainer.numChildren~=nil) then
		oldChartNum=chartNum
		emptyGroup(mapContainer) 
		end
	end
	if menuGroup~=nil then menuGroup.alpha=0 end
	local chartImage
	chartNum=chartInfo[chartPointer][1]
	chartFile=chartInfo[chartPointer][2]
	
	chartName=chartInfo[chartPointer][3]
	chartOffSet=chartInfo[chartPointer][5]:split(",")
	chartScale=tonumber(chartInfo[chartPointer][4])
	MD.mapW=tonumber(chartInfo[chartPointer][11])
	MD.mapH=tonumber(chartInfo[chartPointer][12])
	mapContainer=display.newContainer(MD.mapW,MD.mapH)
	chartFolder="charts/"..chartInfo[chartPointer][14].."/"
		
	-- chartImage=dec.showEncryptedImage(chartFolder..chartFile..".png",MD.mapW,MD.mapH)
	chartImage=display.newImageRect(chartFile..".png",MD.mapW,MD.mapH)
	mapContainer:insert(chartImage)
	if (chartPointer~=1) then doMessage("Loading","Loading",1,2000) end

	if chartPointer~=1 then 
		if chartBackButton~=nil then chartBackButton.alpha=1 end
	end

	MD.multiplier=1
	mapContainer:addEventListener( "touch", mapContainer )

	mapContainer.x=512
	mapContainer.y=386
	mapContainer.anchorChildren = true
	screenGroup:insert(mapContainer)

	prevX=mapContainer.x
	prevY=mapContainer.y
	
	MD.topLat=tonumber(chartInfo[chartPointer][7])
	MD.topLong=tonumber(chartInfo[chartPointer][8])
	MD.bottomLat=tonumber(chartInfo[chartPointer][9])
	MD.bottomLong=tonumber(chartInfo[chartPointer][10])
	MD.latSize=math.abs(MD.topLat-MD.bottomLat)
	MD.longSize=math.abs(MD.topLong-MD.bottomLong)
		
	MD.longUnit=math.abs(MD.mapW/MD.longSize)
	MD.latUnit=math.abs(MD.mapH/MD.latSize)
	MD.worldWidth=360/MD.longSize*MD.mapW
	MD.chartTop=navMaths.getTopPixelShift ( MD.worldWidth, MD.topLat)
	MD.chartBottom=navMaths.getTopPixelShift ( MD.worldWidth, MD.bottomLat)

	waypGroup=display.newGroup()
	lightGroup=display.newGroup()
	trackGroup=display.newGroup()
	subGroup=display.newGroup()
	lineGroup=display.newGroup()
	markGroup=display.newGroup()
	routeGroup=display.newGroup()
	nmGroup=display.newGroup()
	harbourGroup=display.newGroup()
	scGroup=display.newGroup()
	tideGroup=display.newGroup()
	gotoGroup=display.newGroup()

	routeGroup.alpha=0
	waypGroup.alpha=0
	lightGroup.alpha=0
	trackGroup.alpha=0
	harbourGroup.alpha=0
	scGroup.alpha=0
	tideGroup.alpha=0
		
	boatIcon = display.newImageRect( "images/boatIcon.png", 15/MD.multiplier,30/MD.multiplier )
	boatIcon.alpha=0
	
	mapContainer:insert(subGroup)
	mapContainer:insert(harbourGroup)
	mapContainer:insert(scGroup)
	mapContainer:insert(tideGroup)
	mapContainer:insert(nmGroup)
	mapContainer:insert(waypGroup)
	mapContainer:insert(lineGroup)
	mapContainer:insert(gotoGroup)
	mapContainer:insert(routeGroup)
	mapContainer:insert(markGroup)
	mapContainer:insert(trackGroup)	
	mapContainer:insert(boatIcon)
	mapContainer:insert(lightGroup)	
	mapContainer:toBack()
	backRect:toBack()
	isMulti=false	
	init.displaySubs()
	loc.updatePos()

	if (MD.mapW>4000) or (MD.mapH>4000) then zoom.zoomOut("init") end
	if (MD.mapW>2000) and (MD.mapH>2000) then zoom.zoomOut("init") end
	if (MD.mapW>1000) then zoom.zoomOut("init") end
	if (chartScale<100000) then 
		if tideView then loadTidePorts() end	
		if doHarbour and hbView then loadHarbours() end
		if (chartPointer~=1) then doMessage("Loading","Loading",1,2000) end
	end
	if (chartScale<60000) then 
		if doLight and lightView then 
			--loadLights("marks")
			loadLights("lights")
		end
		if scView then loadSailingClubs() end
	else
		if doLight and lightView then loadLights("lights") end
	end

	if doNM and nmView and (chartPointer~=1) then loadNM() end
	if wpView then loadWayPoints() end
	loadedList="Loaded -"
	if tdLoaded~=0 and tdLoaded~=nil then loadedList=loadedList.." Tides:"..tdLoaded end
	if hLoaded~=0 and hLoaded~=nil then loadedList=loadedList.." Harbours:"..hLoaded end
	if scLoaded~=0 and scLoaded~=nil then loadedList=loadedList.." Clubs:"..scLoaded end
	if wpLoaded~=0 and wpLoaded~=nil then loadedList=loadedList.." Waypoints:"..wpLoaded end
	if lLoaded~=0 and lLoaded~=nil then loadedList=loadedList.." Lights:"..lLoaded end

	if (chartScale<6000) and ((MD.mapW<1000) and (MD.mapH<1000)) then init.displayLines() end		
	
	menu.makeMenu()
	if (startX==nil) then startX=512 end
	if (startY==nil) then startY=376 end
		
	function mapContainer:touch( event )
		if isFinger then finger.alpha=1 end
		maxScale,minScale=2,0.1
		if MD.mapH<2000 and MD.mapW<2000 then minScale=0.5 end
		if MD.mapH<3000 and MD.mapW<3000 then minScale=0.3 end
		if MD.mapH<1000 and MD.mapW<1000 then minScale=0.7 end
		display.remove(buttonText)
		local scale
		local result = true
		clearMessage()
		if (not isRoute) and (not canMoveRoute) then clearPanel() end
		if (not isMoveWP) and (not canMoveRoute) then--and (not markOn) then
			local phase = event.phase
			local previousTouches = self.previousTouches

			local numTotalTouches = 1
			if ( previousTouches ) then
				-- add in total from previousTouches, subtract one if event is already in the array
				numTotalTouches = numTotalTouches + self.numPreviousTouches
				if previousTouches[event.id] then
					numTotalTouches = numTotalTouches - 1
				end
			end
			if "began" == phase then
				-- Very first "began" event
				mapContainer.xScaleOriginal=mapContainer.xScale
				if ( not self.isFocus ) then
					-- Subsequent touch events will target button even if they are outside the contentBounds of button
					display.getCurrentStage():setFocus( self )
					self.isFocus = true
					previousTouches = {}
					self.previousTouches = previousTouches
					self.numPreviousTouches = 0
					----ADDED BY CON TO ORIGINAL PINCHZOOM CODE
					startX=event.x
					startY=event.y
					if isFinger then
						finger.x=event.x
						finger.y=event.y
					end
					--------------------------------
					
				elseif ( not self.distance ) then
					local dx,dy
					isMulti=true
					if previousTouches and ( numTotalTouches ) >= 2 then
						
						dx,dy,midX,midY,MD.offX,MD.offY = init.calculateDelta( previousTouches, event )
					end
					if isFinger then
						finger2.alpha=1
						finger2.x=event.x
						finger2.y=event.y
					end
					-- initialize to distance between two touches
					if ( dx and dy ) then
						local d = math.sqrt( dx*dx + dy*dy )
						if ( d > 0 ) then
							
							mapContainer.distance = d
							offCX=(mapContainer.width*mapContainer.xScale/2)-mapContainer.x
							offCY=(mapContainer.height*mapContainer.yScale/2)-mapContainer.y
							local newAnchorY=(midY+offCY)/(mapContainer.height*mapContainer.yScale)
							local newAnchorX=(midX+offCX)/(mapContainer.width*mapContainer.xScale)
							
							mapContainer.anchorX=newAnchorX
							mapContainer.anchorY=newAnchorY							
							mapContainer.x=mapContainer.x-MD.offX
							mapContainer.y=mapContainer.y-MD.offY
							local textOptions={text="",x=midX,y=midY,width=204,height=40,font=native.systemFont,fontSize=36,align="center"}
							zoomText = display.newText(textOptions)
							zoomText:setTextColor(1,0,0)		
						end
					end
				end
				
				if not previousTouches[event.id] then
					self.numPreviousTouches = self.numPreviousTouches + 1
				end
				previousTouches[event.id] = event

			elseif self.isFocus then
				if "moved" == phase and (not locked) then
					if ( mapContainer.distance ) then
						local dx,dy
						if previousTouches and ( numTotalTouches ) >= 2 then
							dx,dy = init.calculateDelta( previousTouches, event )
						end
			
						if ( dx and dy ) then
							local newDistance = math.sqrt( dx*dx + dy*dy )
							MD.modScale = newDistance / mapContainer.distance
							if ( MD.modScale > 0 ) then
								----MODIFIED BY CON
								local newScale=mapContainer.xScaleOriginal * MD.modScale
								if (newScale>maxScale) then 
									doMessage("Maximum Zoom","",1,1000) 
									newScale=maxScale 
								end
								if (newScale<minScale) then 
									doMessage("Minimum Zoom","",1,1000) 
									newScale=minScale 
								end
								zoomText.text=navMaths.makeNumD(newScale*100,0).."%"
								mapContainer.xScale = newScale
								mapContainer.yScale = newScale
								-----------------------------
								----ADDED BY CON TO ORIGINAL PINCHZOOM CODE
								MD.multiplier=newScale
								-----------------------------------------
							end
						end
					----ADDED BY CON TO ORIGINAL PINCHZOOM CODE
					if isFinger then
						finger2.x=finger2.x-0.5
						--finger2.y=previousTouches[event.id].y
						finger.x=finger.x+0.5
						--finger.y=event.y
					end
						loc.updatePos()
					else							
						local deltaX = prevX+event.x - startX
						local deltaY = prevY+event.y - startY
						if isFinger then
							finger.x=event.x
							finger.y=event.y
						end
						mapContainer.x = deltaX
						mapContainer.y = deltaY	
						--limits on chart movement													
						loc.updatePos()
						local limit=300
						local bounds = mapContainer.contentBounds 
						if (bounds.xMin>512+limit) then mapContainer.x=mapContainer.x-100 end
						if (bounds.yMin>376+limit) then mapContainer.y=mapContainer.y-100 end							
						if (bounds.xMax<512-limit) then mapContainer.x=mapContainer.x+100 end
						if (bounds.yMax<376-limit) then mapContainer.y=mapContainer.y+100 end
					---------------------------------
					end
					if not previousTouches[event.id] then
						self.numPreviousTouches = self.numPreviousTouches + 1
					end
					previousTouches[event.id] = event
					newChartPointer=0
				elseif "ended" == phase or "cancelled" == phase then									
					display.remove(zoomText)
					if previousTouches[event.id] then
						self.numPreviousTouches = self.numPreviousTouches - 1
						previousTouches[event.id] = nil
					end
					if (mapContainer.anchorX~=0.5) then
						
						axOff=mapContainer.anchorX-0.5
						ayOff=mapContainer.anchorY-0.5
						mapContainer.anchorX=0.5
						mapContainer.anchorY=0.5

						mapContainer.x=mapContainer.x-(axOff*(mapContainer.width*mapContainer.xScale))--+offCX/mapContainer.xScale
						mapContainer.y=mapContainer.y-(ayOff*(mapContainer.height*mapContainer.yScale))--+offCY/mapContainer.xScale

					end
					if ( #previousTouches > 0 ) then
						-- must be at least 2 touches remaining to pinch/zoom
						self.distance = nil
						----ADDED BY CON TO ORIGINAL PINCHZOOM CODE
						
						------------------------------------
					else
						-- previousTouches is empty so no more fingers are touching the screen
						-- Allow touch events to be sent normally to the objects they "hit"
						display.getCurrentStage():setFocus( nil )
						self.isFocus = false
						self.distance = nil
						-- reset array
						self.previousTouches = nil
						self.numPreviousTouches = nil
						if isFinger then
							finger.x=event.x
							finger.y=event.y
							myTimer=timer.performWithDelay(200,function() transition.to(finger,{time=200,y=event.y+20}) end)
							fTimer=timer.performWithDelay(1000,function() 
								transition.to(finger,{time=100,alpha=0})
								transition.to(finger2,{time=100,alpha=0})
							end)
						end
		
						----ADDED BY CON TO ORIGINAL PINCHZOOM CODE
						if (math.abs(startX-event.x)<12) and (math.abs(startY-event.y)<12) and (not isMulti) then submitMarkForPositioning(event.x,event.y) end
						if finger~=nil then uiGroup:toFront() end
							-- mapContainer.x = event.x
							-- mapContainer.y = event.y
							loc.updatePos()
							zoom.doZoomChecks()
						----------------------------
					end
				end
			end
		end
		isMulti=false
		return result
	end
	if (loadedList~="Loaded -") and (loadedList~="") and (chartPointer~=1) then 
		doMessage("Loading",loadedList,3,3000)
		loadedList=""
		tdLoaded,hLoaded,wpLoaded,lLoaded,scLoaded=0,0,0,0,0
	end
	locGroup.alpha=0
end

function init.displaySubs()
	--called from initChart
	subOn=false
	subList=display.newGroup()
	subList.alpha=0
	subGroup:insert(subList)
	viewButtons[1]=true
	for i =1,#chartInfo do	
		local contents = chartInfo[i][6]
		local chartTable = contents:split(",")
		for j=1,#chartTable do
			if (chartNum==chartTable[j]) then
				local top=(navMaths.getPixelsFromLat(chartInfo[i][7]))
				local left=(navMaths.getPixelsFromLong(chartInfo[i][8]))
				local bottom=(navMaths.getPixelsFromLat(chartInfo[i][9]))
				local right=(navMaths.getPixelsFromLong(chartInfo[i][10]))
				local height=(bottom-top)
				local width=(right-left)
				local arrow
				local subRect = display.newRect(-MD.mapW/2+left,-MD.mapH/2+top,width,height)
				if (chartScale<75000) then
					if (top<0) then
						--top=0
						arrow=display.newImageRect("images/redarrow.png",150,150)						
						arrow.x=-MD.mapW/2+left+width/2
						arrow.rotation=90
						arrow.y=-MD.mapH/2+80
						subGroup:insert(arrow)
					elseif (left<0) then
						-- left=0
						arrow=display.newImageRect("images/redarrow.png",150,150)
						--arrow.anchorX=0.5
						arrow.x=-MD.mapW/2+80
						arrow.rotation=0
						arrow.y=-MD.mapH/2+top+height/2
						subGroup:insert(arrow)
					elseif (bottom>mapContainer.height) then 
						-- bottom=mapContainer.height 
						arrow=display.newImageRect("images/redarrow.png",150,150)
						--arrow.anchorX=0.5
						arrow.x=-MD.mapW/2+left+width/2
						arrow.rotation=270
						arrow.y=MD.mapH/2-80
						subGroup:insert(arrow)
					elseif (right>mapContainer.width) then 
						-- right=mapContainer.width 
						arrow=display.newImageRect("images/redarrow.png",150,150)
						arrow.anchorX=0
						arrow.x=-MD.mapW/2+left+width-80
						arrow.rotation=180
						arrow.y=-MD.mapH/2+top+height/2
						subGroup:insert(arrow)
					end
					if arrow~=nil then arrow.alpha=0.5 end
				end
				
				subRect:setFillColor(1,0,1,0)
				subRect.strokeWidth = 3/MD.multiplier
				subRect:setStrokeColor( 1, 0, 1 )
				subRect.anchorX=0
				subRect.anchorY=0
				subRect.touch = subListener
				subRect:addEventListener( "touch", subRect )
				subRect.chart=i
				subRect.isHitTestable = true				
				subList:insert(subRect)
			end
		end
	end
	timer.performWithDelay(1000,function() subList.alpha=1 end)
end

function init.displayLines()
	local topLine=math.floor(MD.topLat)
	local bottomLine=math.ceil(MD.bottomLat)
	local var=0.02
	local latVar=0
	local chartRange=MD.topLat-MD.bottomLat
	local latVar=var*(1-(bottomLine-MD.bottomLat)/chartRange)

	if (topLine<bottomLine) then
		for i=bottomLine-1,bottomLine+1,1/300 do		
			local latLine=(navMaths.getPixelsFromLat ( i)-MD.mapH/2)-latVar

			local textOptions={parent=lineGroup,text=navMaths.ddd2dmm(i)[1].." "..navMaths.makeNumD(navMaths.ddd2dmm(i)[2],2),x=-MD.mapW/2+10,y=latLine-10,font=native.systemFont,fontSize=18,align="left"}
			numText = display.newText(textOptions)
			numText.anchorX=0
			numText:setTextColor(1,0,0)
		end
	end
	local leftLine=math.floor(MD.topLong)
	local rightLine=math.ceil(MD.bottomLong)

	for i=leftLine-1,leftLine+1,1/300 do			
		local longLine=(navMaths.getPixelsFromLong ( i)-MD.mapW/2)

		local myLine = display.newLine(lineGroup, longLine,0,longLine,50 )
		myLine:setStrokeColor( 0, 0, 0, 0.5 )
		myLine.y=-MD.mapH/2
		myLine.strokeWidth = 2
		local textOptions={parent=lineGroup,text=navMaths.ddd2dmm(i)[1].." "..navMaths.makeNumD(navMaths.ddd2dmm(i)[2],2),y=-MD.mapH/2+20,x=longLine+10,font=native.systemFont,fontSize=18,align="left"}
		numText = display.newText(textOptions)
		numText.anchorX=0
		numText:setTextColor(1,0,0)
	end
end

function init.displaySubsTest()
	--use for visual check of boxes. Not used in delivered application
	subOn=false
	subList=display.newGroup()
	for i =#chartInfo,2,-1 do	
		--if (chartNum==chartInfo[i][6]) then
			local contents = chartInfo[i][6]
			local top=(navMaths.getPixelsFromLat(chartInfo[i][7]))
			local left=(navMaths.getPixelsFromLong(chartInfo[i][8]))
			local bottom=(navMaths.getPixelsFromLat(chartInfo[i][9]))
			local right=(navMaths.getPixelsFromLong(chartInfo[i][10]))
			local scale=tonumber(chartInfo[i][4])
		-- if scale>51000 and scale > 5000 then
		if  (scale<501000) or contents=="*" then
			if (top<0) then top=0 end
			if (left<0) then left=0 end
			if (bottom>mapContainer.height) then bottom=mapContainer.height end
			if (right>mapContainer.width) then right=mapContainer.width end
			local height=(bottom-top)
			local width=(right-left)
			local subRect = display.newRect(-MD.mapW/2+left,-MD.mapH/2+top,width,height)

			subRect:setFillColor(1,0,1,0)
			subRect.strokeWidth = 2
			subRect.alpha = 0.5
			subRect:setStrokeColor( 1, 0, 0 )
			
			if scale<75000 and scale > 25000 then subRect:setStrokeColor( 0, 0, 1 ) end
			-- if scale==40000 then subRect:setStrokeColor( 0, 1, 1 ) end
			-- if scale==35000 then subRect:setStrokeColor( 1, 1, 1 ) end
			-- if scale==30000 then subRect:setStrokeColor( 1, .5, 0 ) end
			-- if scale<26000 then subRect:setStrokeColor( 0, 1, 0 ) end
			if contents=="*" then subRect:setStrokeColor( 0, 0, 0 ) end
			subRect.anchorX=0
			subRect.anchorY=0
			subRect.touch = init.subListener
			subRect:addEventListener( "touch", subRect )
			local textOptions={parent=subList,text=chartInfo[i][1],x=-MD.mapW/2+left+5,y=-MD.mapH/2+top+height-5,font=native.systemFont,fontSize=24,align="center"}
			numText = display.newText(textOptions)
			numText:setTextColor(1,0,0)
			if scale==75000 then numText:setTextColor( 0.5, 0.5, 0 ) end
			if scale<75000 and scale > 25000 then numText:setTextColor( 0, 0, 1 ) end
			if contents=="*" then numText:setTextColor( 0, 0, 0 ) end
			numText.anchorX=0
			numText.anchorY=1
			subRect.chart=i
			subRect.chartnum=chartInfo[i][1]
			subRect.isHitTestable = true
			subList:insert(subRect)
		end
		--end
	end
	--subGroup.alpha=0
	subGroup:insert(subList)
end

return init