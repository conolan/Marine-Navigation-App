local composer = require( "composer" )
local scene = composer.newScene()
composer.removeHidden() 
local http = require("socket.http")
local ltn12 = require("ltn12")

local widget = require("widget")
composer.removeScene("loadchart")
composer.gotoScene( "splash")

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