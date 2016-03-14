picker={}
local pickerWheel
local widget = require "widget"

local function makeDate(date)
	if string.len(date)==1 then date="0"..date end
	return date
end
		
function picker.showPicker( tideData,event)

	local pickerGroup = display.newGroup()
	local rect = display.newRect(display.screenOriginX, display.screenOriginY, display.contentWidth-display.screenOriginX*2, display.contentHeight -display.screenOriginY*2)
	rect:setFillColor(1,1,1,0.8)
	rect.touch = menuListener
	rect:addEventListener( "touch", rect )
	rect.anchorX = 0
	rect.anchorY = 0
	pickerGroup:insert(rect)
	local pR,pG,pB,pA=1,.6,.2,.9
	local panelRect = display.newRoundedRect(512,340,400,460,5)
	panelRect:setFillColor(pR,pG,pB,pA)
	panelRect:setStrokeColor(pR-0.3,pG-0.3,pB-0.3)
	panelRect.strokeWidth = 2
	pickerGroup:insert(panelRect)
	
	local textOptions={parent=pickerGroup,text="Pick a date to view tides (2016)\nScroll the wheels up or down",x=512,y=120,width=500,height=100,font=native.systemFont,fontSize=24,align="center"}
	--disText = display.newText("Pick a date to view tides (2016)\nScroll the wheel up or down", 512, 156, 500,100, native.systemFont, 24)
	disText = display.newText(textOptions)
	disText:setTextColor(0,0,0)
	disText.anchorX = 0.5
	disText.anchorY = 0

	-- Create two tables to hold our days & years      
	local days = {}

	for i = 1, 31 do
		days[i] = i
	end

	local pMonth=tonumber(os.date( "%m" ))
	local pDay=tonumber(os.date( "%d" ))
	-- Set up the Picker Wheel's columns
	local columnData = 
	{ 
		{
			align = "center",
			width = 150,
			startIndex = pDay,
			labels = days,
			
		},
		{ 
			align = "left",
			width = 150,
			startIndex = pMonth ,
			labels = 
			{
				"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" 
			},
		},
	}

	local options = {
    frames = 
    {
        { x=0, y=0, width=320, height=222 },
        { x=320, y=0, width=320, height=222 },
        { x=640, y=0, width=8, height=222 }
    },
    sheetContentWidth = 648,
    sheetContentHeight = 222
	}
	local pickerWheelSheet = graphics.newImageSheet( "images/pickersheet.png", options )
	-- Create a new Picker Wheel
	pickerWheel = widget.newPickerWheel
	{
		top = 230,
		left=352,
		font = native.systemFontBold,
		columns = columnData,
		sheet = pickerWheelSheet,
		overlayFrame = 1,
		overlayFrameWidth = 320,
		overlayFrameHeight = 222,
		backgroundFrame = 2,
		backgroundFrameWidth = 320,
		backgroundFrameHeight = 222,
		separatorFrame = 3,
		separatorFrameWidth = 8,
		separatorFrameHeight = 222,
	}
	pickerGroup:insert(pickerWheel)	
	
	local myRectangle = display.newRect(514, 342, 300, 48)
	myRectangle:setFillColor(1, 0.5, 0.5)
	myRectangle.alpha=0
	pickerGroup:insert(myRectangle)
	screenGroup:insert(pickerGroup)

	local homeButton = widget.newButton{
		top=480,
		left = 422,
		width=180,
		height=60,
		labelColor = { default={1,1,1}	, over={ 0, 0, 0, 0.5 } },
		label="Back to Tide View",
		defaultFile = "images/bluebutton.png",
		
		onRelease=function(event)
			
			local selectedRows = pickerWheel:getValues()
			local isOK=true
			if selectedRows[2].index == 4 or selectedRows[2].index==6 or selectedRows[2].index==9 or selectedRows[2].index==11 then
				if selectedRows[1].index==31 then isOK=false end
			end
			if selectedRows[2].index == 2 then
				if selectedRows[1].index>29 then isOK=false end
			end
			
			if isOK==false then 
				myRectangle.alpha=0.75
				transition.to(myRectangle,{time=500,alpha=0})
				
			else
				pickedDate= (makeDate(selectedRows[1].index).."/"..makeDate(selectedRows[2].index).."/2016" )
				display.remove(pickerGroup)
				pickerGroup=nil
				clearPanel()
				thePanel=NT.startTide(tideData)
				thePanel.x=230
				thePanel.y=80
				screenGroup:insert(thePanel)				
			end
			transition.to(event.target,{time=50,alpha=1})
			return true
		end,
		onPress=function(event)
						
			transition.to(event.target,{time=50,alpha=0.5})
			return true
		end
	}
	pickerGroup:insert(homeButton)
	return true
end


return picker