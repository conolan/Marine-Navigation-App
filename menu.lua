local menu = {}
local menuWidth

function menu.makeMenu()
-- called from init

	display.remove(menuGroup)
	menuGroup=display.newGroup()
	local buttonSize=70
	local menuTop,menuBot, menuLeft,menuRight,menuHeight
	if (ort=="V") then
		menuTop,menuBot=0,768
		menuWidth=buttonSize+30
		menuHeight=768
	else
		menuTop,menuBot=0,600
		menuLeft,menuRight=0,600
		menuWidth=610
		menuHeight=80
	end
	
	local menuRect
	if (isPhone) then  
		buttonSize=100 
		menuWidth=buttonSize+30
		menuRect = display.newRect(menuGroup,leftEdge,menuTop,menuWidth,menuBot)
	else
		if (ort=="V") then
			menuRect = display.newRect(menuGroup,leftEdge,menuTop,menuWidth,menuBot)
		else
			menuRect = display.newRoundedRect(menuGroup,leftEdge-30,bottomEdge-80,menuWidth,80,30)
		end
	end
	menuRect:setFillColor(.7,.5,.5,0.9)
	menuRect.anchorX = 0
	menuRect.anchorY = 0
	menuRect.touch = menuListener
	menuRect:addEventListener( "touch", menuRect )
	local buttonTop,buttonEdge
	if (ort=="V") then
		buttonEdge=15+leftEdge
		buttonTop=5
	else
		buttonEdge=10+leftEdge
		buttonTop=bottomEdge-75
	end
	if (ort=="V") then
		zoomButton = ui.makeMenuButton(buttonEdge-12,buttonTop,buttonSize-15,buttonSize-15,"plus","",zoom.zoomIn)
		menuGroup:insert(zoomButton)
		buttonTop=buttonTop+buttonSize-30 
		zoomButton = ui.makeMenuButton(buttonEdge+27,buttonTop,buttonSize-15,buttonSize-15,"minus","",zoom.zoomOut)
		menuGroup:insert(zoomButton)
		buttonTop=buttonTop+buttonSize-15 
	end
	
	viewButton = ui.makeMenuButton(buttonEdge,buttonTop,buttonSize,buttonSize,"views","",showViewPanel)
	menuGroup:insert(viewButton)
	if (ort=="V") then buttonTop=buttonTop+buttonSize+5 end
	if (ort=="H") then buttonEdge=buttonEdge+buttonSize+2 end
	
	waypButton = ui.makeMenuButton(buttonEdge,buttonTop,buttonSize,buttonSize,"marks","",showMarkPanel)
	menuGroup:insert(waypButton)
	if (ort=="V") then buttonTop=buttonTop+buttonSize+5 end
	if (ort=="H") then buttonEdge=buttonEdge+buttonSize+2 end

	routeButton = ui.makeMenuButton(buttonEdge,buttonTop,buttonSize,buttonSize,"routes","",showRoutePanel)
	menuGroup:insert(routeButton)
	if (ort=="V") then buttonTop=buttonTop+buttonSize+5 end
	if (ort=="H") then buttonEdge=buttonEdge+buttonSize+2 end
	
	if (doTrack) then
		-- gotoButton = ui.makeMenuButton(buttonEdge,buttonTop,buttonSize,buttonSize,"goto","",showGotoPanel)
		-- menuGroup:insert(gotoButton)
		-- if (ort=="V") then buttonTop=buttonTop+buttonSize+5 end
		-- if (ort=="H") then buttonEdge=buttonEdge+buttonSize+2 end
	
		trackButton = ui.makeMenuButton(buttonEdge,buttonTop,buttonSize,buttonSize,"tracks","",showTrackPanel)
		menuGroup:insert(trackButton)
		if (ort=="V") then buttonTop=buttonTop+buttonSize+5 end
		if (ort=="H") then buttonEdge=buttonEdge+buttonSize+2 end
	end

	toolsButton = ui.makeMenuButton(buttonEdge,buttonTop,buttonSize,buttonSize,"tools","",showToolsPanel)
	menuGroup:insert(toolsButton)
	if (ort=="V") then buttonTop=buttonTop+buttonSize+5 end
	if (ort=="H") then buttonEdge=buttonEdge+buttonSize+2 end
	
	if (isPhone) then  
		buttonEdge=buttonEdge+20
		buttonTop=5
	end
	
	if (not isPhone) then
		if doCS then
			chartButton = ui.makeMenuButton(buttonEdge,buttonTop,buttonSize,buttonSize,"selchart","",selectChart)
			menuGroup:insert(chartButton)
			if (ort=="V") then buttonTop=buttonTop+buttonSize+5 end
			if (ort=="H") then buttonEdge=buttonEdge+buttonSize+2 end
		end
		
		infoButton = ui.makeMenuButton(buttonEdge,buttonTop,buttonSize,buttonSize,"info","",showInfoPanel)
		menuGroup:insert(infoButton)
		if (ort=="V") then buttonTop=buttonTop+buttonSize+5 end
		if (ort=="H") then buttonEdge=buttonEdge+buttonSize+2 end
		
		helpButton = ui.makeMenuButton(buttonEdge,buttonTop,buttonSize,buttonSize,"help","",showHelpPanel)
		menuGroup:insert(helpButton)
		if (ort=="V") then buttonTop=buttonTop+buttonSize+5 end
		if (ort=="H") then buttonEdge=buttonEdge+buttonSize+2 end
	end
	-- tideButton = ui.makeMenuButton(buttonEdge,buttonTop,buttonSize,buttonSize,"tidechart","",loadTidePorts)
	-- menuGroup:insert(tideButton)
	-- if (ort=="V") then buttonTop=buttonTop+buttonSize+5 end
	-- if (ort=="H") then buttonLeft=buttonLeft+buttonSize+5 end
	
	-- if (IO.checkFile(chartNum.."lights.txt")) then
		-- noteButton = ui.makeMenuButton(buttonEdge,buttonTop,buttonSize,buttonSize,"lights","",loadLights)
		-- menuGroup:insert(noteButton)
		-- buttonTop=buttonTop+buttonSize+5
	-- end
		
	-- mobButton = ui.makeMenuButton(buttonEdge,buttonTop,buttonSize,buttonSize,"mob","",makeMOBPanel)
	-- menuGroup:insert(mobButton)
	-- buttonTop=buttonTop+buttonSize+5
			
	menuClose=display.newGroup()
	menuClose1=display.newGroup()
	
	if (ort=="V") then
		if (isPhone) then
			menuCloseButton = ui.makeMenuButton(40,695,70,70,"arrowback","",menu.slideMenuIn)
			menuClose:insert(menuCloseButton)
			menuOpenButton = ui.makeMenuButton(40,695,70,70,"arrow","",menu.slideMenuOut)
			menuClose1:insert(menuOpenButton)
		else
			menuCloseButton = ui.makeMenuButton(10,695,70,70,"arrowback","",menu.slideMenuIn)
			menuClose:insert(menuCloseButton)		
			menuOpenButton = ui.makeMenuButton(10,695,70,70,"arrow","",menu.slideMenuOut)
			menuClose1:insert(menuOpenButton)
		end
	else
		menuCloseButton = ui.makeMenuButton(520,buttonTop+10,50,50,"arrowback","",menu.slideMenuIn)
		menuClose:insert(menuCloseButton)
		
		menuOpenButton = ui.makeMenuButton(520,buttonTop+10,50,50,"arrow","",menu.slideMenuOut)
		menuClose1:insert(menuOpenButton)
	end
	
	menuClose.x=menuClose.x+leftEdge
	menuClose1.x=menuClose1.x+leftEdge
	menuGroup:insert(menuClose)
	menuGroup:insert(menuClose1)
	
	if (ort=="V") then
		menuCover = display.newRect(menuGroup,leftEdge,menuTop,menuWidth,menuHeight)
	else
		menuCover = display.newRect(menuGroup,leftEdge,80,menuWidth,menuHeight)
	end
	menuCover:setFillColor(1,0,0,0.5)
	menuCover.anchorX = 0
	menuCover.anchorY = 0
	menuCover.alpha=0
	screenGroup:insert(menuGroup)
	if (ort=="V") then
		chartBackButton = ui.makeMenuButton(buttonEdge+100,10,80,80,"chartback","",chartBack)
	else
		chartBackButton = ui.makeMenuButton(10,10,80,80,"chartback","",chartBack)
	end
	menuGroup:insert(chartBackButton)
	--if (chartPointer==1) then chartBackButton.alpha=0 end
	chartBackButton.alpha=0
	
	-- if (daysSinceInstall<2) and (chartScale>50000) and (ort=="V") and (not isPhone) then
		-- buttonText = display.newImageRect(menuGroup, "images/buttontext.png", 160,680 )
		-- buttonText.x,buttonText.y=80,340
		-- MD.hTime=timer.performWithDelay(5000,function() display.remove(buttonText) end)
	-- end
end

function menu.slideMenuOut(self, touch)
	chartBackButton.alpha=0
	transition.to( menuClose, { time=500, x=menuClose.x+100 } )
	transition.to( menuGroup, { time=200, x=menuGroup.x-menuWidth } )
	return true
end

function menu.slideMenuIn(self, touch)
	if chartPointer~=1 then chartBackButton.alpha=1 end
	menuClose.x=menuClose.x-100
	transition.to( menuGroup, { time=500, x=menuGroup.x+menuWidth } )
	return true
end


return menu