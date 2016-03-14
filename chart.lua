local chart = {}
local IO = require( "datainout" )
local MD = require( "mydata" )
local ui = require( "ui" )
local navMaths = require( "navmaths" )
local CI = require( "chartinfo" )
local chartInfo=CI.getList()
local menu=require("menu")
local notes=require("notes")


function chart.initChart(chartPointer)
	--called from startChart(chartBack,subListener)
	display.remove(MD.mapContainer)
	MD.chartNum=chartInfo[chartPointer][1]
	MD.chartFile=chartInfo[chartPointer][2]
	MD.chartName=chartInfo[chartPointer][3]
	MD.multiplier=1
	MD.mapContainer=display.newGroup()
	MD.mapW=tonumber(chartInfo[chartPointer][11])
	MD.mapH=tonumber(chartInfo[chartPointer][12])

	if environment == "simulator" then	
		-- local chartImage = display.newImage("charts/"..chartFile..".png")
		-- if (chartImage.width~=MD.mapW) or (chartImage.height~=MD.mapH) then
			-- local alert = native.showAlert( "problem", "Image size wrong",{ "NEXT" })	
		-- end
		-- display.remove(chartImage)
		-- chartImage=nil
	end
	local chartImage = display.newImageRect("charts/"..MD.chartFile..".png",MD.mapW,MD.mapH)

	chartImage.anchorX = 0.5
	chartImage.anchorY = 0.5
	MD.mapContainer:insert(chartImage)
	
	MD.mapContainer:addEventListener( "touch", MD.mapContainer )

	-- mapContainer.tap=mapTapListener
	-- mapContainer:addEventListener( "tap", mapContainer )
	MD.mapContainer.x=512
	MD.mapContainer.y=376
	MD.mapContainer.anchorChildren = true
	MD.screenGroup:insert(MD.mapContainer)

	prevX=MD.mapContainer.x
	prevY=MD.mapContainer.y
	
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

	MD.waypGroup=display.newGroup()
	MD.lightGroup=display.newGroup()
	MD.trackGroup=display.newGroup()
	MD.subGroup=display.newGroup()
	MD.markGroup=display.newGroup()
	MD.routeGroup=display.newGroup()
	MD.nmGroup=display.newGroup()

	MD.routeGroup.alpha=0
	MD.waypGroup.alpha=0
	MD.lightGroup.alpha=0
	MD.trackGroup.alpha=0
	
	MD.nightGroup=display.newGroup()
	local n = display.newRect(0,0,MD.mapW,MD.mapH)
	n.anchorX = 0.5
	n.anchorY = 0.5
	n:setFillColor(1,0,0,0.5)
	MD.nightGroup:insert(n)
	MD.nightGroup.alpha=0
	
	MD.boatGroup=display.newGroup()

	local vertices = { 0,-7, 7,0, 6,8, 6,15, -6,15, -6,8,  -7,0, }

	boatIcon = display.newPolygon( 0,0, vertices )
	boatIcon:setFillColor( 0, 1, 0 )
	boatIcon.strokeWidth = 2
	boatIcon:setStrokeColor( 0,0, 0 )
	MD.boatGroup:insert(boatIcon)
	MD.boatGroup.alpha=0

	MD.mapContainer:insert(MD.routeGroup)
	MD.mapContainer:insert(MD.waypGroup)
	MD.mapContainer:insert(MD.markGroup)
	MD.mapContainer:insert(MD.nmGroup)
	MD.mapContainer:insert(MD.trackGroup)
	MD.mapContainer:insert(MD.boatGroup)
	
	MD.mapContainer:insert(MD.nightGroup)
	
	MD.mapContainer:insert(MD.lightGroup)
	MD.mapContainer:insert(MD.subGroup)
	
	MD.mapContainer:toBack()
	MD.backRect:toBack()
	-- if (zoomButton~=nil) then 
		-- zoomButton.alpha=1
		-- if (MD.mapW<1024) or (MD.mapH<768) then	zoomButton.alpha=0.5 end
	-- end
	MD.wpNameTable,MD.wpTable,MD.routeTable,MD.markTable,MD.markNameTable,MD.routeNameTable={},{},{},{},{},{}

	menu.makeMenu()
	if (startX==nil) then startX=512 end
	if (startY==nil) then startY=376 end
	-- event1x=0
	-- event1y=0
	-- event2x=0
	-- event2y=0
	-- event3x=0
	-- event3y=0
	-- event4x=0
	-- event4y=0
	-- eventY=0
	-- eventX=0
	-- numClicks=0
	-- function mapContainer:touch( event )
		-- local phase = event.phase
		-- if "ended" == phase then
			-- numClicks=numClicks+1
			 -- event4x=event3x
			 -- event3x=event2x
			 -- event2x=event1x
			 -- event1x=event.x
			 -- event4y=event3y
			 -- event3y=event2y
			 -- event2y=event1y
			 -- event1y=event.y


			 -- if numClicks==4 then
				-- print(event1x,event1y,event2x,event2y,event3x,event3y,event4x,event4y)
				-- midX=math.abs((event1x+event2x)/2)
				-- midY=math.abs((event1y+event2y)/2)
				-- offX=mapContainer.x-midX
				-- offY=mapContainer.y-midY
				-- diffX=(event1x-event2x)
				-- diffY=(event1y-event2y)
				-- diff2X=(event3x-event4x)
				-- diff2Y=(event3y-event4y)
				
				
				-- numClicks=0
				-- local oldDistance = math.sqrt( diffX*diffX + diffY*diffY )
				-- local newDistance = math.sqrt( diff2X*diff2X + diff2Y*diff2Y )
				-- local scale = oldDistance / newDistance
				-- print(diffX,diff2X,diffY,diff2Y,scale)
				-- mapContainer.xScaleOriginal = mapContainer.xScale
				-- mapContainer.yScaleOriginal = mapContainer.yScale
				-- local newScale=mapContainer.xScaleOriginal * scale
				-- mapContainer.xScale = newScale
				-- mapContainer.yScale = newScale
				-- MD.multiplier=newScale
				-- doMessage(scale.." : "..mapContainer.xScaleOriginal.." : "..offX.." : "..offY)			

						-- mapContainer.x=mapContainer.x-offX+(offX*scale)
						-- mapContainer.y=mapContainer.y-offY+(offY*scale)

				-- updatePos()
			-- end
		 -- end
	 -- end	
	
	function MD.mapContainer:touch( event )
		local scale
		local result = true
		if (not isRoute) then clearPanel() end
		if (not isMoveWP) then
			local phase = event.phase
			local isMulti=false

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
					startTime=system.getTimer()
					--------------------------------
					
				elseif ( not self.distance ) then
					local dx,dy

					if previousTouches and ( numTotalTouches ) >= 2 then
						dx,dy,midX,midY,MD.offX,MD.offY = calculateDelta( previousTouches, event )
					end
					
					-- initialize to distance between two touches
					if ( dx and dy ) then
						local d = math.sqrt( dx*dx + dy*dy )
						if ( d > 0 ) then
							MD.mapContainer.distance = d
							MD.mapContainer.xScaleOriginal = MD.mapContainer.xScale
							MD.mapContainer.yScaleOriginal = MD.mapContainer.yScale	
						end
					end
				end

				if not previousTouches[event.id] then
					self.numPreviousTouches = self.numPreviousTouches + 1
				end
				previousTouches[event.id] = event

			elseif self.isFocus then
				if "moved" == phase and (not locked) then
					if ( MD.mapContainer.distance ) then
						local dx,dy
						if previousTouches and ( numTotalTouches ) >= 2 then
							dx,dy,midX,midY,MD.offX,MD.offY = calculateDelta( previousTouches, event )
						end
			
						if ( dx and dy ) then
							local newDistance = math.sqrt( dx*dx + dy*dy )
							MD.modScale = newDistance / MD.mapContainer.distance
							--doMessage(dx.." "..dy.." "..newDistance)
							if ( MD.modScale > 0 ) then
								----MODIFIED BY CON

								local newScale=MD.mapContainer.xScaleOriginal * MD.modScale
								if (newScale>maxScale) then newScale=maxScale end
								if (newScale<minScale) then newScale=minScale end
									
								MD.mapContainer.xScale = newScale
								MD.mapContainer.yScale = newScale

								isMulti=true
		
								-----------------------------
								----ADDED BY CON TO ORIGINAL PINCHZOOM CODE
								
								MD.multiplier=newScale
								-----------------------------------------
							end
						end
					----ADDED BY CON TO ORIGINAL PINCHZOOM CODE
						chart.updatePos()
					else
							local deltaX = prevX+event.x - startX
							local deltaY = prevY+event.y - startY
							--isMulti=false
							
							--limits on chart movement
							-- local limit=30
							-- if (deltaX>limit+MD.mapW/2*MD.multiplier) then deltaX=limit+MD.mapW/2*MD.multiplier end
							-- if (deltaY>limit+MD.mapH/2*MD.multiplier) then deltaY=limit+MD.mapH/2*MD.multiplier end
							-- if (deltaX<-(MD.mapW/2*MD.multiplier)+924) then deltaX=(-MD.mapW/2*MD.multiplier)+924 end
							-- if (deltaY<-(MD.mapH/2*MD.multiplier)+718) then deltaY=-(MD.mapH/2*MD.multiplier)+718 end
							
							MD.mapContainer.x = deltaX
							MD.mapContainer.y = deltaY							
							chart.updatePos()
					---------------------------------
					end

					if not previousTouches[event.id] then
						self.numPreviousTouches = self.numPreviousTouches + 1
					end
					previousTouches[event.id] = event

				elseif "ended" == phase or "cancelled" == phase then
					----ADDED BY CON TO ORIGINAL PINCHZOOM CODE
					prevX = MD.mapContainer.x
					prevY = MD.mapContainer.y
					if (MD.offX==nil) then
						MD.offX=1
						MD.offY=1
						MD.modScale=1 
					end
						MD.mapContainer.x=MD.mapContainer.x-MD.offX+(MD.offX*MD.modScale)
						MD.mapContainer.y=MD.mapContainer.y-MD.offY+(MD.offY*MD.modScale)
						MD.offX=1
						MD.offY=1
						MD.modScale=1 
						isMulti=false
					
					------------------------------------
					if previousTouches[event.id] then
						self.numPreviousTouches = self.numPreviousTouches - 1
						previousTouches[event.id] = nil
						
					end

					if ( #previousTouches > 0 ) then
						-- must be at least 2 touches remaining to pinch/zoom
						self.distance = nil
						
							
					else
						-- previousTouches is empty so no more fingers are touching the screen
						-- Allow touch events to be sent normally to the objects they "hit"
						isMulti=false
						display.getCurrentStage():setFocus( nil )

						self.isFocus = false
						self.distance = nil
						MD.mapContainer.xScaleOriginal = nil
						MD.mapContainer.yScaleOriginal = nil

						-- reset array
						self.previousTouches = nil
						self.numPreviousTouches = nil
						
						----ADDED BY CON TO ORIGINAL PINCHZOOM CODE
						if (math.abs(startX-event.x)<12) and (math.abs(startY-event.y)<12)  then submitMarkForPositioning(event.x,event.y) end
							
							-- MD.mapContainer.x = event.x
							-- MD.mapContainer.y = event.y
							chart.updatePos()
							doZoomChecks()
						----------------------------
					end
				end
			end
		end
		return result
	end

	trackingOn=false
	prevPoint={0,0}
	--if environment == "simulator" then
		-- Runtime:removeEventListener( "enterFrame", moveBoat )
		-- Runtime:addEventListener( "enterFrame", moveBoat )
		-- currentPoint={52.145992,-7.0013897}
		
	--else
		--Runtime:removeEventListener( "location", locationHandler )
		
	--end	
end

function chart.updatePos()
	--called from initChart, mapTouchListener, zoomIn, zoomOut
	--currentLat=navMaths.getLatitude(MD.worldWidth,MD.chartTop-4-((MD.mapH/2*MD.multiplier)-MD.mapContainer.y+(376))/MD.multiplier)
	--NEW CALCULATION done. CALCULATE OFFSET OF TOP LAT AND BOTTOM LAT WHERE AT 62DEG 1 PIXEL, 49DEG 9 PIXELS
	local var=9.5
	local latVar=0
	local chartRange=MD.topLat-MD.bottomLat
	
	currentLat=navMaths.getLatitude(MD.worldWidth,MD.chartTop-latVar-((MD.mapH/2*MD.multiplier)-MD.mapContainer.y+(376))/MD.multiplier)
	local latVar=var*(1-(currentLat-MD.bottomLat)/chartRange)

	currentLat=navMaths.getLatitude(MD.worldWidth,MD.chartTop-latVar-((MD.mapH/2*MD.multiplier)-MD.mapContainer.y+(376))/MD.multiplier)
	currentLong=MD.topLong+(((((MD.mapW/2*MD.multiplier)-MD.mapContainer.x))+512)/(MD.longUnit*MD.multiplier))
	local latLen=string.len(math.floor(math.abs(currentLat)))
	local longLen=string.len(math.floor(math.abs(currentLong)))
	
	local latDMS=navMaths.ddd2dmm(currentLat)[1].."_"..navMaths.ddd2dmm(currentLat)[2]
	local longDMS=navMaths.ddd2dmm(currentLong)[1].."_"..navMaths.ddd2dmm(currentLong)[2]
	if (currentLong<0) then longLen=longLen+1 end
	latLong.text=string.sub(currentLat,1,latLen+5).."N "..string.sub(currentLong,1,longLen+5).."W".." - zoom: "..math.round((MD.multiplier*100)).."% "..string.sub(latDMS,1,latLen+6).." "..string.sub(longDMS,1,latLen+6)
	MD.cName.text=MD.chartNum..":"..MD.chartName
	
	--navMaths.dmm2dms(currentLong)
end

return chart