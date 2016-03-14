local loc = {}
	

function loc.updatePos()
	--called from initChart, mapTouchListener, zoomIn, zoomOut
	local tempLat=navMaths.getLatitude(MD.worldWidth,MD.chartTop-((MD.mapH/2*MD.multiplier)-mapContainer.y+(384))/MD.multiplier)
	
	local disTop=topC-tempLat
	local disTopChart=topC-MD.topLat

	local varDown=disTop/chartH
	local varDownTop=disTopChart/chartH
	
	local latOffVar=chartOffSet[2]
	local longOff=chartOffSet[1]
	local latOff=0
	if (chartOffSet[3]~=nil) then latOff=chartOffSet[3] end

	local latVar=latOff+(2.8+latOffVar)*(varDown-varDownTop)
	--local latVar=0

	local currentLat=navMaths.makeNumD((navMaths.getLatitude(MD.worldWidth,MD.chartTop-latVar-((MD.mapH/2*MD.multiplier)-mapContainer.y+(384))/MD.multiplier)),4)
	
	thePer=((MD.topLat-MD.bottomLat)/2*30)
	theMod=math.abs(math.abs(((MD.mapH/2-((mapContainer.y-(384))/MD.multiplier))/MD.mapH)-0.5)-0.5)*2*thePer
	currentLat=navMaths.makeNumD((MD.topLat-(MD.topLat-MD.bottomLat)*(MD.mapH/2-((mapContainer.y-(384)+theMod)/MD.multiplier))/MD.mapH),4)

	local currentLong=navMaths.makeNumD(MD.topLong+(((((MD.mapW/2*MD.multiplier)+longOff-mapContainer.x))+512)/(MD.longUnit*MD.multiplier)),4)
	local latLen=string.len(math.floor(math.abs(currentLat)))
	local longLen=string.len(math.floor(math.abs(currentLong)))
	
	local latDMS1=navMaths.ddd2dmm(currentLat)[1]
	local latDMS2=navMaths.makeNumD(navMaths.ddd2dmm(currentLat)[2],2)
	local longDMS1=navMaths.ddd2dmm(currentLong)[1]
	local longDMS2=navMaths.makeNumD(navMaths.ddd2dmm(currentLong)[2],2)
	if (currentLong<0) then longLen=longLen+1 end
	local preLong="E "
	if (currentLong<0) then 
		preLong="W " 
		currentLong=-currentLong
	end
	latLongD1.text="N "..currentLat.."  "
	latLongD2.text=preLong.." "..currentLong
	latLongZoom.text="zoom: "..math.round((MD.multiplier*100)).."%"

	latLongM1.text=latDMS1--string.sub(latDMS,1,latLen+1)
	latLongM2.text=latDMS2--string.sub(latDMS,3,latLen+7)
	latLongM3.text=longDMS1--string.sub(longDMS,1,latLen+1)
	latLongM4.text=longDMS2--string.sub(longDMS,3,latLen+7)

	if ort=="V" then
		MD.cName.text=chartNum..": "..chartName.." Scale: "..chartScale
	else
		MD.cName.text=chartNum..": "..chartName.."\nScale: "..chartScale
	end
end

function loc.locationHandler(event)

	if event.errorCode then
		native.showAlert( "GPS Location Error", event.errorMessage, {"OK"} )
		boatIcon.alpha=0
		locInfo.text="No location info" 
	else
		
		if (MD.nextPoint==nil) then MD.nextPoint={50,-1} end
		local offLat,offLong=0,0
		if isSetOffset then
			offLat=-1.412
			offLong=5.557
		end
		
		if environment == "simulator" then 
			currentPoint={50.3,-1.4} 
		else
			currentPoint={tonumber(string.format( '%.5f', event.latitude ))+offLat,tonumber(string.format( '%.5f', event.longitude ))+offLong}
		end
		if (prevPoint==nil) then prevPoint={tonumber(string.format( '%.5f', event.latitude )),tonumber(string.format( '%.5f', event.longitude ))} end
		local mySpeed = tonumber(navMaths.makeNumD((string.format( '%.3f', event.speed )/0.51444),2,true))
		local directionText = navMaths.makeNumD(event.direction,0)
		local latLen=string.len(math.floor(math.abs(currentPoint[1])))
		local longLen=string.len(math.floor(math.abs(currentPoint[2])))
		if avgSpeed==nil then avgSpeed=0 end
		locInfo.text=navMaths.makeNumD(currentPoint[1],4,true).."\n"..navMaths.makeNumD(currentPoint[2],4,true)
		
		if (event.errorCode~=NIL) then 
			locInfo.text="No location info" 
		elseif (currentPoint[1]>tonumber(MD.topLat)) or (currentPoint[1]<tonumber(MD.bottomLat)) or (currentPoint[2]<tonumber(MD.topLong)) or (currentPoint[2]>tonumber(MD.bottomLong)) then
			boatIcon.alpha=0
			targetInfo.text="Location is outside this chart"
		elseif trackingOn then	
			boatIcon.alpha=1
			-- if (theLocationTimer<system.getTimer()) then
				-- theLocationTimer=system.getTimer()+locUpdate
				
				bearing=navMaths.makeNumD(navMaths.getBearing(currentPoint[1],currentPoint[2],MD.nextPoint[1],MD.nextPoint[2]),0)
				
				-- toTarget=navMaths.makeNumD(navMaths.getDistance(currentPoint[1],currentPoint[2],MD.nextPoint[1],MD.nextPoint[2]),1)
				
				-- local checkMiss=true
				
				-- if (checkMiss) and (gotoList~=nil) and (gotoPoint<table.maxn(gotoList)) then 
			
					-- next1Point=gotoList[gotoPoint+1]
					-- nextGotoDist=navMaths.getDistance(currentPoint[1],currentPoint[2],next1Point[1],next1Point[2])
					-- nextBearing=navMaths.makeNumD(navMaths.getBearing(currentPoint[1],currentPoint[2],next1Point[1],next1Point[2]),0)
					-- if (mySpeed>2) and (math.abs(directionText-nextBearing)<20) and (math.abs(directionText-bearing)>90) then doMessage("Moving towards next - passed previous\n"..math.abs(directionText-nextBearing).." "..math.abs(directionText-bearing)) end
				-- end
				-- if (toTarget<0.5) then toTarget=toTarget.." - ARRIVED "
					-- if (gotoList~=nil) then
						-- if (gotoPoint<table.maxn(gotoList)) then
							-- gotoPoint=gotoPoint+1
							-- MD.nextPoint=gotoList[gotoPoint]
							-- gotoGroup[1].y=navMaths.getPixelsFromLat(gotoList[gotoPoint][1])-MD.mapH/2
							-- gotoGroup[1].x=navMaths.getPixelsFromLong(gotoList[gotoPoint][2])-MD.mapW/2
							-- gotoGroup[2].y=navMaths.getPixelsFromLat(gotoList[gotoPoint][1])-MD.mapH/2
							-- gotoGroup[2].x=navMaths.getPixelsFromLong(gotoList[gotoPoint][2])-MD.mapW/2
							-- loc.getNextPoint()

						-- else
							-- doMessage("Course Complete")
						-- end
					-- end			
				-- end
				
				distLast=navMaths.getDistance(currentPoint[1],currentPoint[2],prevPoint[1],prevPoint[2])
				if (distDone==nil) then distDone=0 end
				distDone=distDone+distLast
				table.remove( avgSpeedList, 1 )				
				avgSpeedList[#avgSpeedList + 1] = mySpeed
				avgSpeed=0
				for i=1,10 do
					avgSpeed=avgSpeed+avgSpeedList[i]
				end
				avgSpeed=navMaths.makeNumD(avgSpeed/10,2)
				prevPoint={currentPoint[1],currentPoint[2]}
				local timeText = string.format( '%.0f', event.time )
				IO.saveTrack(currentPoint[1]..","..currentPoint[2]..","..timeText..","..mySpeed..","..avgSpeed.."\n")
				-- if (math.abs(directionText-bearing)>10) then tWarning="OFF TRACK" end
				-- if (math.abs(directionText-bearing)>90) and (mySpeed>1) then 
					-- tWarning="MOVING AWAY"
					-- moveAwayCount=moveAwayCount+1
				-- else
					-- moveAwayCount=0
				-- end
				-- if (moveAwayCount==5) then
					-- doMessage("You are moving away from your next target.")
					-- moveAwayCount=0
				-- end
				
				boatIcon.y=-MD.mapH/2+navMaths.getPixelsFromLat(currentPoint[1])
				boatIcon.x=-MD.mapW/2+navMaths.getPixelsFromLong(currentPoint[2])
				boatIcon.rotation=directionText
				local trackPoint=display.newImageRect(trackGroup,"images/marks/rt.png",10/MD.multiplier,10/MD.multiplier)
				trackPoint.x=boatIcon.x
				trackPoint.y=boatIcon.y
			if (tWarning==nil) then tWarning="+" end

			if (isPhone) then 
				locInfo.text=navMaths.makeNumD(currentPoint[1],4,true).."\n"..navMaths.makeNumD(currentPoint[2],4,true)
				targetInfo.text="SOG "..mySpeed.."kn  Av: "..avgSpeed.."\nDir: "..directionText--.."\nToTgt: "..toTarget.."kn Brg "..bearing.." "..tWarning 
			else
				locInfo.text=navMaths.makeNumD(currentPoint[1],4,true).."\n"..navMaths.makeNumD(currentPoint[2],4,true)
				targetInfo.text="SOG "..mySpeed.."kn  Av: "..avgSpeed.."\nDir: "..directionText--.."\nToTgt: "..toTarget.."kn Brg "..bearing.." "..tWarning 
			end			
		end
		
	end
end

function loc.getNextPoint()
ui.makeMiniButton(500,700,50,50,"minus","",loc.toPort)
ui.makeMiniButton(560,700,50,50,"plus","",loc.toStar)
		initDist=navMaths.makeNumD(navMaths.getDistance(currentPoint[1],currentPoint[2],MD.nextPoint[1],MD.nextPoint[2]),1)
		initBearing=navMaths.makeNumD(navMaths.getBearing(currentPoint[1],currentPoint[2],MD.nextPoint[1],MD.nextPoint[2]),0)
		xMod,yMod=1,1
-- print(initBearing)
		theMoveY=0.00003---math.cos(math.rad(initBearing))/300
		theMoveX=-0.000025--math.sin(math.rad(initBearing))/300
end

function loc.toStar()
	theMoveY=theMoveY-0.000003
	theMoveX=theMoveX-0.000003
end

function loc.toPort()
	theMoveY=theMoveY+0.000003
	theMoveX=theMoveX+0.000003
end

function loc.moveBoat()
	--local theMoveX,theMoveY
	if (theMoveX==nil) then
		theMoveX,theMoveY=0.001,0.001
		currentPoint={startLat,startLong} 
	end
	if (MD.nextPoint==nil) then MD.nextPoint={50,-1} end
	if (prevPoint==nil) then prevPoint={startLat,startLong} end

	if (initDist==nil) then
		loc.getNextPoint()		
	end
	avgSpeed=0
	
	local latLen=string.len(math.floor(math.abs(currentPoint[1])))
	local longLen=string.len(math.floor(math.abs(currentPoint[2])))
	-- use makeNumD here
	if (currentPoint[2]<0) then longLen=longLen+1 end	

	--locInfo.text=string.sub(currentPoint[1],1,latLen+5).." "..string.sub(currentPoint[2],1,longLen+5).." SOG:"

	--if (currentPoint[1]>tonumber(MD.topLat)) or (currentPoint[1]<tonumber(MD.bottomLat)) or (currentPoint[2]<tonumber(MD.topLong)) or (currentPoint[2]>tonumber(MD.bottomLong)) then
		--display.remove(boatIcon)
	--else

		-- if (theLocationTimer<system.getTimer()) then
			-- theLocationTimer=system.getTimer()+locUpdate
			currentPoint={currentPoint[1]-theMoveY,currentPoint[2]-theMoveX} 
			distLast=navMaths.getDistance(currentPoint[1],currentPoint[2],prevPoint[1],prevPoint[2])
			--loc.getNextPoint()
			mySpeed = navMaths.makeNumD(distLast*12*60,2)--navMaths.makeNumD((math.round(0.000539957*tonumber(string.format( '%.3f', distLast ))*100)/100),2,true)
			
			if (distDone==nil) then distDone=0 end
			distDone=distDone+distLast
			toTarget=navMaths.makeNumD(navMaths.getDistance(currentPoint[1],currentPoint[2],MD.nextPoint[1],MD.nextPoint[2]),1)
			if (toTarget<2) then toTarget=toTarget.." - ARRIVED"
				if (gotoList~=nil) then
					if (gotoPoint<table.maxn(gotoList)) then
						gotoPoint=gotoPoint+1
						MD.nextPoint=gotoList[gotoPoint]
						gotoGroup[1].y=navMaths.getPixelsFromLat(gotoList[gotoPoint][1])-MD.mapH/2
						gotoGroup[1].x=navMaths.getPixelsFromLong(gotoList[gotoPoint][2])-MD.mapW/2
						gotoGroup[2].y=navMaths.getPixelsFromLat(gotoList[gotoPoint][1])-MD.mapH/2
						gotoGroup[2].x=navMaths.getPixelsFromLong(gotoList[gotoPoint][2])-MD.mapW/2
						loc.getNextPoint()
					else
						doMessage("Course Complete")
					end
				end			
			end
			bearing=navMaths.makeNumD(navMaths.getBearing(currentPoint[1],currentPoint[2],MD.nextPoint[1],MD.nextPoint[2]),0)
			directionText=navMaths.makeNumD(navMaths.getBearing(prevPoint[1],prevPoint[2],currentPoint[1],currentPoint[2]),0)
			table.remove( avgSpeedList, 1 )				
			avgSpeedList[#avgSpeedList + 1] = mySpeed
			avgSpeed=0
			for i=1,10 do
				avgSpeed=avgSpeed+avgSpeedList[i]
			end
			avgSpeed=avgSpeed/10
			prevPoint={currentPoint[1],currentPoint[2]}
			local timeText = os.date( "%Y".."%m".."%d".."%H".."%M".."%S" )
			IO.saveTrack(currentPoint[1]..","..currentPoint[2]..","..timeText..","..mySpeed..","..avgSpeed.."\n")
			prevPoint={currentPoint[1],currentPoint[2]}
			
			local trackPoint=display.newImageRect(trackGroup,"images/marks/tr.png",10/MD.multiplier,10/MD.multiplier)
			trackPoint.x=boatIcon.x
			trackPoint.y=boatIcon.y
			trackPoint.anchorX=0.5
			trackPoint.anchorY=0.5
			tWarning=""
			if (math.abs(directionText-bearing)>10) then tWarning="OFF TRACK" end

		
		boatIcon.y=-MD.mapH/2+navMaths.getPixelsFromLat(currentPoint[1])
		boatIcon.x=-MD.mapW/2+navMaths.getPixelsFromLong(currentPoint[2])
		boatIcon.rotation=directionText
		if (directionText==nil) then directionText="" end
		if (mySpeed==nil) then mySpeed="" end
		if (tWarning==nil) then tWarning="" end

		-- if (bearing==nil) then
			-- locInfo.text=navMaths.makeNumD(currentPoint[1],2,true).." "..navMaths.makeNumD(currentPoint[2],2,true).." SOG "..mySpeed.."kn  Dir: "..directionText.." ToTgt:"
		-- else
			if (isPhone) then 
				locInfo.text=""..navMaths.makeNumD(currentPoint[1],4,true).."\n"..navMaths.makeNumD(currentPoint[2],4,true)
				targetInfo.text="SOG "..mySpeed.."kn  Av: "..avgSpeed.."\nDir: "..directionText--.."\nToTgt: "..toTarget.."kn Brg "..bearing.." "..tWarning 
			else
				locInfo.text=""..navMaths.makeNumD(currentPoint[1],4,true).."\n"..navMaths.makeNumD(currentPoint[2],4,true)
				targetInfo.text="SOG "..mySpeed.."kn  Av: "..avgSpeed.."\nDir: "..directionText--.."\nToTgt: "..toTarget.."kn Brg "..bearing.." "..tWarning 
			end
		-- end
		-- end
	--end	
end

return loc