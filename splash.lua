local composer = require( "composer" )
local scene = composer.newScene()
composer.removeHidden() 
local http = require("socket.http")
local ltn12 = require("ltn12")

local widget = require("widget")
local myInstallDate=0
myInstallDate=IO.loadFile("appinstall.txt")
if myInstallDate~=nil then print(myInstallDate[1]) end
local myAppUpdateDate=IO.loadFile("appupdate.txt")
local myDataUpdateDate=IO.loadFile("datainstall.txt")
if myInstallDate==nil then composer.gotoScene( "loaddata") end
if myAppUpdateDate==nil then myAppUpdateDate=myInstallDate end
if myDataUpdateDate==nil then myDataUpdateDate={0} end

daysSinceInstall=(theTime-myInstallDate[1])/24/60/60

function scene:create( event )	
	screenGroup = self.view
		
	backRect = display.newRect(display.screenOriginX, display.screenOriginY, display.contentWidth-display.screenOriginX*2, display.contentHeight -display.screenOriginY*2)
	backRect:setFillColor(0.5,0.5,0.5)
	backRect.anchorX = 0
	backRect.anchorY = 0
	screenGroup:insert(backRect)
		
	backImg = display.newImageRect("photos/newtowncreek.jpg",display.contentWidth-display.screenOriginX*2,display.contentHeight -display.screenOriginY*2)
	backImg.anchorX = 0
	backImg.x=display.screenOriginX
	backImg.anchorY = 0
	screenGroup:insert(backImg)

	logoImg = display.newImageRect("images/realchartslogo.png",1000,179)

	logoImg.anchorX = 0.5
	logoImg.anchorY = 0
	logoImg.x=512
	logoImg.y=20
	screenGroup:insert(logoImg)
	
	infoGroup=display.newGroup()
	
	backRect = display.newRect(212, 195, 600, 40)
	backRect:setFillColor(0,0,0)
	backRect.anchorX = 0
	backRect.anchorY = 0
	infoGroup:insert(backRect)
	local theType
	local gpsInfo,demoInfo="",""
	if isDemo then
		theType="TIME LIMITED LITE VERSION"
		demoInfo="This version runs for 14 days under terms of UKHO agreement"
	elseif doTrack then
		theType="GPS VERSION"
	else
		theType="PLANNING VERSION"
	end
	if  isGPS==false then gpsInfo="This iPad needs an external GPS device for location and tracking" end
	local textOptions={parent=infoGroup, text=productDisplayName,x=512,y=202,width=600,height=30,font=native.systemFont,fontSize=24,align="center"}
	local titletext = display.newText(textOptions)
	titletext:setFillColor(1,1,1)
	titletext.anchorY = 0
	titletext.xScale=1.5

	local textOptions={parent=infoGroup, text=theType.."\n"..demoInfo.."\n"..gpsInfo,x=512,y=240,width=700,height=90,font=native.systemFont,fontSize=24,align="center"}
	local versionText = display.newText(textOptions)
	versionText:setFillColor(0,0,0)
	versionText.anchorY = 0
	
	local textOptions={parent=infoGroup, text="",x=512,y=350,width=700,height=70,font=native.systemFont,fontSize=20,align="center"}
	infoText1 = display.newText(textOptions)
	infoText1:setFillColor(.7,.7,.7)
	infoText1.anchorY = 0
	infoText2 = display.newText(textOptions)
	infoText2:setFillColor(.7,.7,.7)
	infoText2.anchorY = 0
	infoText2.y=infoText2.y+70
	if isDemo then 
		infoText1.text="To purchase full access to the 32 charts click the purchase button. This takes you to a new screen where you can confirm purchase"
		local ButtonPur = ui.makeButton(512-90,470,180,60,"bluebutton","Full Access\npurchase in appstore",function() composer.gotoScene( "splashpurchase") end)
		infoGroup:insert(ButtonPur)
	end
	local textOptions
	if doHarbour then
		textOptions={parent=infoGroup, text="NOT FOR NAVIGATION\nApptoonz and VisitMyHarbour accept no responsibility for use of this product\n\nNOTICE: The UK Hydrographic Office (UKHO) and its licensors make no warranties or representations, express or implied, with respect to this product. The UKHO and its licensors have not verified the information within this product or quality assured it.",x=512,y=500,width=800,height=140,font="Trebuchet MS Bold",fontSize=18,align="center"}
	else
		textOptions={parent=infoGroup, text="NOT FOR NAVIGATION\nApptoonz accept no responsibility for use of this product\n\nNOTICE: The UK Hydrographic Office (UKHO) and its licensors make no warranties or representations, express or implied, with respect to this product. The UKHO and its licensors have not verified the information within this product or quality assured it.",x=512,y=500,width=800,height=140,font="Trebuchet MS Bold",fontSize=18,align="center"}
	end
	noticeText = display.newText(textOptions)
	noticeText:setFillColor(0,0,0)
	noticeText.anchorY = 0
	noticeText2 = display.newText(textOptions)
	noticeText2:setFillColor(1,1,1)
	noticeText2.anchorY = 0
	noticeText2.x=noticeText2.x-2
	noticeText2.y=noticeText2.y-2
	
	local function noticeListener( event )
		if ( event.isError ) then
			infoText1.text="Network error! Your device is not connected to the internet for updating data. The app will still work"
		else
			if event.status == 200 then infoText1.text=event.response end
		end
	end

	local function updateListener( event )
		if ( event.isError ) then
			infoText2.text="Network error!"
		else
			--infoText2.text=tonumber(event.response)
			if (event.status == 200) and (tonumber(event.response)>tonumber(myDataUpdateDate[1])) then
				infoText2.text=tonumber(event.response).."\n".."update data tide"
				forUpdate="datatide"
				
				local Button1 = ui.makeButton(512-120,430,240,60,"bluebutton","Load new data",function() composer.gotoScene( "updatedata") end)
				infoGroup:insert(Button1)
			end
		end
	end

	--if not isDemo then 
		network.request( "http://www.realcharts.net/chartdata/"..region.."/notice/notice_plan2015.txt", "GET", noticeListener )
		network.request( "http://www.realcharts.net/chartdata/"..region.."/update_plan.txt", "GET", updateListener )
	--end

	local goText="I accept"
	if isDemo then goText="I accept\nproceed to charts" end
	timer.performWithDelay(2000, function()
		local Button1 = ui.makeButton(512-90,650,180,60,"greenbutton",goText,function() composer.gotoScene( "loadchart") end)
		infoGroup:insert(Button1)
	end)
	screenGroup:insert(infoGroup)
end


function scene:destroy( event )

    local sceneGroup = self.view
	display.remove(sceneGroup)
	
end

---------------------------------------------------------------------------------
-- END OF IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "create", scene )
scene:addEventListener( "destroy", scene )

return scene