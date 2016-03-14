local zoom = {}

function zoom.zoomIn()
	--called from menu button
	local mulChange
	if  (MD.multiplier<.25) then
		mulChange=.25/MD.multiplier
		mapContainer.x = (mapContainer.x)*mulChange-512*MD.multiplier
		mapContainer.y = (mapContainer.y)*mulChange-376*MD.multiplier
		MD.multiplier=.25
	else
		if (MD.multiplier==2) then doMessage("Maximum Zoom","",1,1000) end
		if  (MD.multiplier~=2) then
			MD.multiplier=MD.multiplier*2	
			if (MD.multiplier>2) then MD.multiplier=2 end		
			-- mapContainer.x = (mapContainer.x)*2-512
			-- mapContainer.y = (mapContainer.y)*2-376
		elseif (MD.multiplier>2) then 
			MD.multiplier=2 
		end
	end
	zoom.doZoomChecks()
	return true
end

function zoom.zoomOut(source)
	--called from menu button and single tap

		if (MD.mapW>MD.mapH) then -- greater width

			-- if  (MD.mapW*MD.multiplier>2048) then
				MD.multiplier=MD.multiplier/2
				mapContainer.x = (mapContainer.x-512)/2+512
				mapContainer.y = (mapContainer.y-376)/2+376
			-- else
				-- MD.multiplier=1024/MD.mapW
				-- mapContainer.x = 512
				-- mapContainer.y = 376
			-- end
			
		else -- greaterheight

			-- if  (MD.mapH*MD.multiplier>1536) then
				
				MD.multiplier=MD.multiplier/2
				mapContainer.x = (mapContainer.x-512)/2+512
				mapContainer.y = (mapContainer.y-376)/2+376
			-- else
				-- MD.multiplier=768/MD.mapH
				-- mapContainer.x = 512
				-- mapContainer.y = 376
			-- end
		end
		prevX = mapContainer.x --MUST keep this
		prevY = mapContainer.y
		if (MD.multiplier>2) then MD.multiplier=2 end
		if MD.mapH>4000 or MD.mapW>4000 then
			if (MD.multiplier<.15) then MD.multiplier=.15 end
			if (MD.multiplier<0.15) and (source~="init") then doMessage("Fully zoomed out","",1,1000) end
		else
			if (MD.multiplier<.2) then MD.multiplier=.2 end
			if (MD.multiplier<0.25) and (source~="init") then doMessage("Fully zoomed out","",1,1000) end
		end
		zoom.doZoomChecks()
		return true

end

function zoom.doZoomChecks()
	--called from zoomIn,zoomOut
	mapContainer.xScale=MD.multiplier
	mapContainer.yScale=MD.multiplier
	prevX = mapContainer.x
	prevY = mapContainer.y
	zoom.checkZoomEffects()
	loc.updatePos()
	local limit=400
	local bounds = mapContainer.contentBounds 
	if (bounds.xMin>512+limit) then mapContainer.x=mapContainer.x-100 end
	if (bounds.yMin>376+limit) then mapContainer.y=mapContainer.y-100 end							
	if (bounds.xMax<512-limit) then mapContainer.x=mapContainer.x+100 end
	if (bounds.yMax<376-limit) then mapContainer.y=mapContainer.y+100 end
end

function zoom.checkZoomEffects()
	--called from doZoomChecks
	local hitSize, pointSize=40,30
	if (isPhone) then
		hitSize=50
		--pointSize=40
	end
	if (subList~=null) then
		for i=1,subList.numChildren do
			subList[i].strokeWidth=3/MD.multiplier
		end
	end
	if (newRouteLine~=null) then
		if (newRouteLine.numChildren~=null) then
		for i=1,newRouteLine.numChildren do
			newRouteLine[i].strokeWidth=4/MD.multiplier
		end
		end
	end
	if (waypGroup.numChildren~=0) then
		for i=1,waypGroup.numChildren do
			waypGroup[i][1][1].width=pointSize/MD.multiplier
			waypGroup[i][1][1].height=pointSize/MD.multiplier
			waypGroup[i][1][2].width=hitSize/MD.multiplier
			waypGroup[i][1][2].height=hitSize/MD.multiplier
		end
	end
	if (trackGroup.numChildren~=0) then
		for i=1,trackGroup.numChildren do
			trackGroup[i].width=10/MD.multiplier
			trackGroup[i].height=10/MD.multiplier
		end
	end
	if (routeGroup.numChildren~=0) then
		for i=1,routeGroup[3].numChildren do
			if(routeGroup[3][i][1]~=nil) then
				routeGroup[3][i][1].width=pointSize/MD.multiplier
				routeGroup[3][i][1].height=pointSize/MD.multiplier
				routeGroup[3][i][2].width=hitSize/MD.multiplier
				routeGroup[3][i][2].height=hitSize/MD.multiplier
			end
		end
	end
	if (harbourGroup.numChildren~=0) then
		for i=1,harbourGroup.numChildren do
			harbourGroup[i][1][1].width=pointSize/MD.multiplier
			harbourGroup[i][1][1].height=pointSize/MD.multiplier
			harbourGroup[i][1][2].width=pointSize/MD.multiplier
			harbourGroup[i][1][2].height=pointSize/MD.multiplier
		end
	end
	if (scGroup.numChildren~=0) then
		for i=1,scGroup.numChildren do
			scGroup[i][1][1].width=pointSize/MD.multiplier
			scGroup[i][1][1].height=pointSize/MD.multiplier
			scGroup[i][1][2].width=pointSize/MD.multiplier
			scGroup[i][1][2].height=pointSize/MD.multiplier
		end
	end
	if (tideGroup.numChildren~=0) then
		for i=1,tideGroup.numChildren do
			tideGroup[i][1][1].width=pointSize/MD.multiplier
			tideGroup[i][1][1].height=pointSize/MD.multiplier
			tideGroup[i][1][2].width=pointSize/MD.multiplier
			tideGroup[i][1][2].height=pointSize/MD.multiplier
		end
	end
	if (lightGroup.numChildren~=0) then
		for i=1,lightGroup.numChildren do
			lightGroup[i].width=40/MD.multiplier
			lightGroup[i].height=40/MD.multiplier
		end
	end
	if (nmGroup.numChildren~=0) then
		for i=1,nmGroup.numChildren do
			nmGroup[i].width=hitSize/MD.multiplier
			nmGroup[i].height=hitSize/MD.multiplier
		end
	end
	if (gotoGroup.numChildren~=0) then
		gotoGroup[1].width=pointSize*2/MD.multiplier
		gotoGroup[1].height=pointSize*2/MD.multiplier
		gotoGroup[2].width=hitSize*2/MD.multiplier
		gotoGroup[2].height=hitSize*2/MD.multiplier
	end
	--if boatIcon.alpha==1 then
		boatIcon.width=15/MD.multiplier
		boatIcon.height=30/MD.multiplier
	--end
end

function zoom.zoomOutMax()
	if  (MD.mapW*MD.multiplier>2048) then zoom.zoomOut() end
	if  (MD.mapW*MD.multiplier>2048) then zoom.zoomOut() end
	if  (MD.mapW*MD.multiplier>2048) then zoom.zoomOut() end
end

return zoom
