local reg = {}


local fieldHandler1 = function( event )
	--called from input text on panels
	if "began" == event.phase then

	elseif "editing" == event.phase then
									
	elseif "ended" == event.phase then
		native.setKeyboardFocus( nil )
	elseif "submitted" == event.phase then
		native.setKeyboardFocus( nil )
	end
end

local fieldHandler2 = function( event )
	--called from input text on panels
	if "began" == event.phase then

	elseif "editing" == event.phase then
									
	elseif "ended" == event.phase then
		native.setKeyboardFocus( nil )
	elseif "submitted" == event.phase then
		native.setKeyboardFocus( nil )
	end
end

function reg.showRegister()
			
	loginGroup=display.newGroup()
	local rect = display.newRect(display.screenOriginX, display.screenOriginY, display.contentWidth-display.screenOriginX*2, display.contentHeight -display.screenOriginY*2)
	rect:setFillColor(0,0,0.5,1)
	rect.touch = menuListener
	rect:addEventListener( "touch", rect )
	rect.anchorX = 0
	rect.anchorY = 0
	loginGroup:insert(rect)
	local textOptions={parent=loginGroup, text="Please enter your name and email in the fields above\nYour details will only be used for important changes and updates",x=512,y=480,width=800,height=100,font=native.systemFont,fontSize=24,align="center"}
	disText = display.newText(textOptions)
	disText:setFillColor(1,1,1)
	disText.anchorX = 0.5
	disText.anchorY = 0
	screenGroup:insert(loginGroup)
	
	inputField1 = native.newTextField( 200, 190, 240, 60 )
	loginGroup:insert(inputField1)
	inputField1.font = native.newFont( native.systemFont )
	inputField1.userInput = fieldHandler1
	inputField1.placeholder="surname"
	inputField1.size = 24
	
	inputField2 = native.newTextField( 600, 190, 500, 60 )
	loginGroup:insert(inputField2)
	inputField2.font = native.newFont( native.systemFont )
	inputField2.inputType = "email"
	inputField2.userInput = fieldHandler2
	inputField2.placeholder="email"
	inputField2.size = 24
	
	subButton=ui.makeButton(312,300,180,60,"bluebutton","Register",reg.sendReg)
	loginGroup:insert(subButton)
	cancelButton=ui.makeButton(512,300,180,60,"greybutton","cancel",function() display.remove(loginGroup) end )
	loginGroup:insert(cancelButton)

	loginGroup:insert(disText)
	screenGroup:insert(loginGroup)

end


local function textListener( event )
	if ( event.isError ) then
			doMessage("Network error! Please check your connection or try again","",2)
	elseif ( event.phase == "began" ) then
        print( "Progress Phase: began" )
    elseif ( event.phase == "ended" ) then
		local theResponse=string.sub(event.response,1,5)

		if (theResponse~="error") then
			IO.saveOverFile("reg.txt",theTime)
			doMessage("Registration complete")
			isReg=true
		else
			doMessage("Error encountered. Please try another time")
		end
		display.remove(loginGroup)
		timer.performWithDelay(2000,nextInfo)
	end
end

function reg.sendReg()
	local inputEmail,inputName
	if "Win" == system.getInfo( "platformName" ) then
		inputName="Conor"
		inputEmail="conor@onolan.com"
	else
		inputName=inputField1.text
		inputEmail=inputField2.text
	end
	local http = require("socket.http")
	local ltn12 = require("ltn12")
	local urlOperations = require("socket.url")
	local urlEncode = urlOperations.escape
	doMessage("sending details","",2)
	inputName = urlEncode(inputName)
	inputEmail = urlEncode(inputEmail)
	network.request( "http://www.realcharts.net/dataops/reguser.php?name="..inputName.."&email="..inputEmail.."&product="..productName, "GET", textListener )
end


return reg