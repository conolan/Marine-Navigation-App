local composer = require( "composer" )
local scene = composer.newScene()
composer.removeHidden() 

local widget = require("widget")
errtxt="Errors "
local DL=require("download_data")

function onCompleteTide(result)
	if result then	
		IO.saveOverFile("tideinstall.txt",theTime)		
		timer.performWithDelay(2000,function() composer.gotoScene(splashPage) end)
	else
		disText2.text=("ERROR - download/unzip of tides failed")
	end
end

function onComplete(result)
	if result then
		IO.saveOverFile("datainstall.txt",theTime)
	else

		disText2.text("ERROR - download of data failed")
	end
end

function scene:create( event )
	local screenGroup = self.view
		
	backRect = display.newRect(display.screenOriginX, display.screenOriginY, display.contentWidth-display.screenOriginX*2, display.contentHeight -display.screenOriginY*2)
	backRect:setFillColor(0.5,0.5,0.5)
	backRect.anchorX = 0
	backRect.anchorY = 0
	screenGroup:insert(backRect)
		
	backImg = display.newImageRect("photos/newgrimbsy.jpg",1024,768)
	backImg.anchorX = 0
	backImg.anchorY = 0
	screenGroup:insert(backImg)
	--backImg.touch = showLogin
	backImg.touch = jumplogin
	backImg:addEventListener( "touch", backImg )
	
	logoImg = display.newImageRect("images/realchartslogo.png",1000,179)
	logoImg.anchorX = 0.5
	logoImg.anchorY = 0
	logoImg.x=512
	logoImg.y=20
	screenGroup:insert(logoImg)
	
	local infoGroup=display.newGroup()
	
	local textOptions={parent=infoGroup, text="UKHO Charts designed by a sailor for sailors",x=512,y=210,width=1000,height=100,font=native.systemFont,fontSize=30,align="center"}
	disText1 = display.newText(textOptions)
	disText1:setFillColor(1,1,1)
	disText1.anchorY = 0
	
	local textOptions={parent=infoGroup, text="Updating data",x=512,y=500,width=700,height=60,font=native.systemFont,fontSize=20,align="center"}
	disText2 = display.newText(textOptions)
	disText2:setFillColor(0,0,0)
	disText2.anchorY = 0
	
	local textOptions={parent=infoGroup, text="",x=512,y=560,width=700,height=60,font=native.systemFont,fontSize=20,align="center"}
	errorText= display.newText(textOptions)
	errorText:setFillColor(0,0,0)
	errorText.anchorY = 0
	
	qImg = display.newImageRect("photos/quote1.png",1235/2,177/2)
	qImg.anchorX = 0.5
	qImg.anchorY = 0
	qImg.x=512
	qImg.y=600
	infoGroup:insert(qImg)		
	
	local textOptions={parent=infoGroup, text="Sir Walter Scott (Kenilworth)",x=500,y=700,width=400,height=100,font=native.systemFont,fontSize=20,align="center"}
	distText = display.newText(textOptions)
	distText:setFillColor(1,1,1)
	distText.anchorX = 0
	distText.anchorY = 0

	screenGroup:insert(infoGroup)
	DL.downloadData(onComplete)
	DL.downloadTideAndUnzipIt(onCompleteTide)
	
end


function jumplogin(self,touch)
	local phase = touch.phase
	if ( phase == "began" ) then self.alpha=0.5 end
	if ( phase == "ended" ) then
		composer.gotoScene( "loadchart")
	end
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