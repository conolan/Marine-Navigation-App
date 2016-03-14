local composer = require( "composer" )
local scene = composer.newScene()
composer.removeHidden() 

local widget = require("widget")
errtxt="Errors "
local DL=require("download_data")

local function onCompleteTide(result)
	if result then	
		IO.saveOverFile("tideinstall.txt",theTime)		
	else
		disText2.text=("ERROR - download/unzip of tides failed")
		errorText.text=errtxt
	end
end

local function onCompleteChart(result)
	if result then
		display.remove(screengroup)
		IO.saveOverFile("appinstall.txt",theTime)
		composer.gotoScene( splashPage)
	else
		disText2.text("ERROR - download/unzip of charts failed")
		errorText.text=errtxt
	end
end

local function onComplete(result)
	if result then
		IO.saveOverFile("datainstall.txt",theTime)
	else
		disText2.text("ERROR - download of data failed")
		errorText.text=errtxt
	end
end

function scene:create( event )	
	screenGroup = self.view
		
	backRect = display.newRect(display.screenOriginX, display.screenOriginY, display.contentWidth-display.screenOriginX*2, display.contentHeight -display.screenOriginY*2)
	backRect:setFillColor(0.5,0.5,0.5)
	backRect.anchorX = 0
	backRect.anchorY = 0
	screenGroup:insert(backRect)
		
	backImg = display.newImageRect("photos/newgrimbsy.jpg",1024,768)
	backImg.anchorX = 0
	backImg.anchorY = 0
	screenGroup:insert(backImg)
	
	logoImg = display.newImageRect("images/realchartslogo.png",1000,179)
	logoImg.anchorX = 0.5
	logoImg.anchorY = 0
	logoImg.x=512
	logoImg.y=20
	screenGroup:insert(logoImg)
	
	local infoGroup=display.newGroup()
	
	local textOptions={parent=infoGroup, text="Raster Charts app designed by a sailor for sailors",x=512,y=210,width=1000,height=100,font=native.systemFont,fontSize=30,align="center"}
	disText1 = display.newText(textOptions)
	disText1:setFillColor(1,1,1)
	disText1.anchorY = 0
	
	local textOptions={parent=infoGroup, text="DOWNLOADING CHARTS AND DATA. PLEASE WAIT",x=512,y=580,width=1000,height=100,font=native.systemFont,fontSize=30,align="center"}
	local disText = display.newText(textOptions)
	disText:setFillColor(1,1,1)
	disText.anchorY = 0
	
	local textOptions={parent=infoGroup, text="Loading data on first install",x=512,y=610,width=700,height=60,font=native.systemFont,fontSize=20,align="center"}
	disText2= display.newText(textOptions)
	disText2:setFillColor(1,1,1)
	disText2.anchorY = 0
	
	local textOptions={parent=infoGroup, text="",x=512,y=560,width=700,height=60,font=native.systemFont,fontSize=20,align="center"}
	errorText= display.newText(textOptions)
	errorText:setFillColor(1,1,1)
	errorText.anchorY = 0
	
	local helpImg =display.newImageRect("images/chartselection.png",450,75)
	helpImg.x=512
	helpImg.y=535
	screenGroup:insert(helpImg)
	
	qImg = display.newImageRect("photos/quote1.png",1235/2,177/2)
	qImg.anchorX = 0.5
	qImg.anchorY = 0
	qImg.x=512
	qImg.y=630
	infoGroup:insert(qImg)		
	
	local textOptions={parent=infoGroup, text="Sir Walter Scott (Kenilworth)",x=500,y=720,width=400,height=100,font=native.systemFont,fontSize=20,align="center"}
	distText = display.newText(textOptions)
	distText:setFillColor(1,1,1)
	distText.anchorX = 0
	distText.anchorY = 0

	screenGroup:insert(infoGroup)
	DL.downloadTideAndUnzipIt(onCompleteTide)
	DL.downloadData(onComplete)
	DL.downloadChartData(onCompleteChart)
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