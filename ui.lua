
local widget = require( "widget" )

local ui = {}

local pR,pG,pB,pA=1,.6,.2,.9
local nR,nG,nB,nA=.5,.6,1,.9
local mR,mG,mB,mA=.65,.79,0.93,1
-----------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
-----------------------------------------------------------------------------

function ui.makeButton(l,t,w,h,f,lb,fn,n)
	local lb1,lb2
	local offY=0
	local sFind=string.find(lb,"\n",1)
	txtcol={1,1,1}
	fSize=32
	
	if (sFind==nil) then
		lb1=lb
	else
		lb1=string.sub(lb,1,sFind-1)
		lb2=string.sub(lb,sFind)
		offY=-10
	end
	if string.len(lb1)>8 then fSize=fSize-6 end
	if string.len(lb1)>14 then fSize=fSize-5 end
	local buttonGroup=display.newGroup()
	newButton=widget.newButton{
	top=t,
	left = l,
	width=w,
	height=h,
	fontSize=fSize,
	font=native.systemFontBold,
	labelYOffset = offY,
	defaultFile = "images/"..f..".png",
	label=lb1,
	labelColor = { default=txtcol, over={ 0, 0, 0, 0.5 } },
	onRelease=function(event)
		if isFinger then fTimer=timer.performWithDelay(500,function() transition.to(finger,{time=200,alpha=0}) end) end
		transition.to(event.target,{time=50,alpha=1})
		fn(n)
		if finger~=nil then uiGroup:toFront() end
		return true
	end,
	onPress=function(event)
		if finger~=nil then 
			uiGroup:toFront()
			if (fTimer~=nil) then timer.cancel( fTimer ) end
			transition.to(finger,{time=50,alpha=1})
			transition.to(finger,{time=200,x=event.x,y=event.y})
		end
		transition.to(event.target,{time=50,alpha=0.5})
		display.remove(buttonText)
		if (messageBox~=nil) then clearMessage() end
		return true
	end
	}
	buttonGroup:insert(newButton)
	if (lb2~=nil) then
	--second line of text
		local lineSpace=22
		if isPhone then lineSpace =28 end
		local textOptions={parent=buttonGroup,text=lb2,x=l,y=t+lineSpace,width=180,height=38,font=native.systemFont,fontSize=14,align="center"}
		if (isPhone) then textOptions={parent=buttonGroup,text=lb2,x=l,y=t+lineSpace,width=180,height=42,font=native.systemFont,fontSize=18,align="center"} end
		bBox = display.newText(textOptions)
		if isPhone then 
			bBox:setTextColor(1,1,1)
		else
			bBox:setTextColor(0,0,0)
		end
		bBox.anchorX = 0
		bBox.anchorY = 0
	end
	return buttonGroup
end

function ui.makeMenuButton(l,t,w,h,f,lb,fn,n)
	local lb1,lb2
	local offY=0
	local sFind=string.find(lb,"\n",1)
	fSize=28
	if (isPhone) then 
		txtcol={0,0,0}
	else
		txtcol={1,1,1}
	end
	if string.len(lb)>10 then fSize=24 end
	if (sFind==nil) then
		lb1=lb
	else
		lb1=string.sub(lb,1,sFind-1)
		lb2=string.sub(lb,sFind)
		offY=-10
	end
	local buttonGroup=display.newGroup()
	newButton=widget.newButton{
	top=t,
	left = l,
	width=w,
	height=h,
	fontSize=fSize,
	labelYOffset = offY,
	defaultFile = "images/"..f..".png",
	label=lb1,
	labelColor = { default=txtcol, over={ 0, 0, 0, 0.5 } },
	onRelease=function(event)
		if isFinger then fTimer=timer.performWithDelay(500,function() transition.to(finger,{time=200,alpha=0}) end) end
		transition.to(event.target,{time=50,alpha=1})
		buttonX=l
		buttonY=t
		buttonH=h
		if isRoute then 
			alertRoute() 
		else
			fn(n)
		end
		if finger~=nil then uiGroup:toFront() end
		return true
	end,
	onPress=function(event)
		if finger~=nil then 
			uiGroup:toFront()
			if (fTimer~=nil) then timer.cancel( fTimer ) end
			transition.to(finger,{time=50,alpha=1})
			transition.to(finger,{time=200,x=event.x,y=event.y})
		end
		transition.to(event.target,{time=50,alpha=0.5})
		display.remove(buttonText)
		if (messageBox~=nil) then clearMessage() end
		return true
	end
	}
	buttonGroup:insert(newButton)
	if (lb2~=nil) then
	--second line of text
		local textOptions={parent=buttonGroup,text=lb2,x=l,y=t+18,width=180,height=38,font=native.systemFont,fontSize=14,align="center"}
		if (isPhone) then textOptions={parent=buttonGroup,text=lb2,x=l,y=t+28,width=180,height=42,font=native.systemFont,fontSize=18,align="center"} end
		bBox = display.newText(textOptions)
		bBox:setTextColor(0,0,0)
		bBox.anchorX = 0
		bBox.anchorY = 0
	end
	return buttonGroup
end

function ui.makeMiniButton(l,t,w,h,f,lb,fn,n)
	local buttonGroup=display.newGroup()
	newButton=widget.newButton{
	top=t,
	left = l,
	width=w,
	height=h,
	fontSize=16,
	defaultFile = "images/"..f..".png",
	label=lb,
	labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
	onRelease=function(event)
		if isFinger then fTimer=timer.performWithDelay(1000,function() transition.to(finger,{time=200,alpha=0}) end) end
		transition.to(event.target,{time=50,alpha=1})
		fn(n)
		return true
	end,
	onPress=function(event)
		if finger~=nil then 
			uiGroup:toFront()
			if (fTimer~=nil) then timer.cancel( fTimer ) end
			transition.to(finger,{time=50,alpha=1})
			transition.to(finger,{time=200,x=event.x,y=event.y})
		end
		transition.to(event.target,{time=50,alpha=0.5})
		return true
	end
	}
	buttonGroup:insert(newButton)
	return buttonGroup
end

function ui.checkXForPanel(x,width,offX)
	local pX
	if (x<360) then
		pX=110
	else
		pX=x-width-offX
	end
	return pX
end

function ui.checkYForPanel(y,offY)
	local pX
	if  (y+offY<10) then offY=10 end
	if (y>450) then
		pY=y-250
	else
		pY=y+offY
	end
	return pY
end

function ui.makeNewPanel(name,x,y,w,h,isInput,b1Img,b1Text,b1Function,b2Img,b2Text,b2Function,b3Img,b3Text,b3Function,b4Img,b4Text,b4Function,b5Img,b5Text,b5Function)

	local pH=20--panel height and spacing for buttons
	if (MD.hTime~=nil) then timer.cancel( MD.hTime ) end
	local thePanel=display.newGroup()
	thePanel.name=name
	lastPanel=name

	-- local panelRect = display.newRoundedRect(buttonX+25,buttonY-y-5,150,buttonH+10,5)
	-- panelRect:setFillColor(pR,pG,pB,pA)
	-- panelRect.anchorX = 0
	-- panelRect.anchorY = 0
	-- panelRect.alpha=0.7
	-- thePanel:insert(panelRect)
	
	
	local panelRect = display.newRoundedRect(0,0,w,h,5)
	panelRect:setFillColor(pR,pG,pB,pA)
	panelRect:setStrokeColor(pR-0.3,pG-0.3,pB-0.3)
	panelRect.strokeWidth = 2
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	
	thePanel:insert(panelRect)

	local inputOffset=0
	local pIndent=10
	local textBoxH=60
	if platformName=="Android" then textBoxH=70 end
	if isInput then
		if isPhone then
			inputField = native.newTextField( 10, -110, 380, textBoxH )
			inputField.size = 16
			pH=pH+80
		else
			inputField = native.newTextField( 10, -110, 280, textBoxH )
			inputField.size = 60
			pH=pH+60
		end
		thePanel:insert(inputField)
		inputField.font = native.newFont( native.systemFont )
		inputField.userInput = fieldHandler
		inputField.anchorX = 0
		inputField.anchorY = 0
		inputField.text=MD.defaultText
		inputField.y=10
		inputOffset=40
		
		pIndent=60
	end
	buttonHeight=60
	if (isPhone) then buttonHeight=80 end
	local Button1 = ui.makeButton(pIndent,pH,180,buttonHeight,b1Img,b1Text,b1Function)
	thePanel:insert(Button1)
	pH=pH+buttonHeight+10
	if b2Img~=nil then
		local Button2 = ui.makeButton(pIndent,pH,180,buttonHeight,b2Img,b2Text,b2Function)
		thePanel:insert(Button2)
		pH=pH+buttonHeight+10
	end
	if b3Img~=nil then
		local Button3 = ui.makeButton(pIndent,pH,180,buttonHeight,b3Img,b3Text,b3Function)
		thePanel:insert(Button3)
		pH=pH+buttonHeight+10
	end
	if b4Img~=nil then
		local Button4 = ui.makeButton(pIndent,pH,180,buttonHeight,b4Img,b4Text,b4Function)
		thePanel:insert(Button4)
		pH=pH+buttonHeight+10
	end
	if b5Img~=nil then
		local Button5 = ui.makeButton(pIndent,pH,180,buttonHeight,b5Img,b5Text,b5Function)
		thePanel:insert(Button5)
		pH=pH+buttonHeight+10
	end
	
	thePanel.x=x
	thePanel.y=y
	panelRect.height=pH

	if finger~=nil then uiGroup:toFront() end
	return(thePanel)
end

function ui.makeNotesPanel(x,y,w,h,isInput,theText,b1Img,b1Text,b1Function,b2Img,b2Text,b2Function)

	local pH=20--panel height and spacing for buttons
	if (MD.hTime~=nil) then timer.cancel( MD.hTime ) end
	--display.remove(thePanel)
	local thePanel=display.newGroup()
	local panelRect = display.newRoundedRect(0,0,w,h,5)
	panelRect:setFillColor(pR,pG,pB,pA)
	panelRect.anchorX = 0
	panelRect.anchorY = 0

	thePanel:insert(panelRect)
	local inputOffset=0
	local pIndent=10
	if isInput then
		-- thePanel.x=thePanel.x-100
		-- panelRect.width=300
		inputNoteField = native.newTextBox( 10, -110, w-20, h-80 )
		thePanel:insert(inputNoteField)
		inputNoteField.isEditable = true
		inputNoteField.font = native.newFont( native.systemFont )
		inputNoteField.size = 20
		inputNoteField.userInput = fieldHandler
		inputNoteField.anchorX = 0
		inputNoteField.anchorY = 0
		if (theText~="") then
			inputNoteField.text=theText
		else
			inputNoteField.text="Notes :"..os.date( "%Y".."-".."%m".."-".."%d" )
		end
		inputNoteField.y=10
		inputOffset=40
		pH=pH+40
		pIndent=60
	end
	local Button1 = ui.makeButton(pIndent,h-65,180,60,b1Img,b1Text,b1Function)
	thePanel:insert(Button1)
	pH=pH+70
	if b2Img~=nil then
		local Button2 = ui.makeButton(pIndent+200,h-65,180,60,b2Img,b2Text,b2Function)
		thePanel:insert(Button2)
		pH=pH+70
	end
		
	thePanel.x=x
	thePanel.y=y
	pH=pH+10	
	return(thePanel)
end

function ui.makeMarkPanel(x,y,w,h,numMarks,markFunction,b1Img,b1Text,b1Function,b2Img,b2Text,b2Function,b3Img,b3Text,b3Function,b4Img,b4Text,b4Function)

	local pH=20--panel height and spacing for buttons
	local thePanel=display.newGroup()
	local panelRect = display.newRoundedRect(0,0,w,h,5)
	panelRect:setFillColor(pR,pG,pB,pA)
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	
	thePanel:insert(panelRect)
	local inputOffset=0
	local pIndent=10
	local pX=10
	for i=1,numMarks do
		local theMark = ui.makeButton(pX,pH,30,30,"marks/mark"..i,"",markFunction,i)
		theMark.num=i
		thePanel:insert(theMark)
		pX=pX+40
		if (i==4) then
			pX=10
			pH=pH+40
		end
	end
	pH=pH+40
	local Button1 = ui.makeButton(pIndent,pH,180,50,b1Img,b1Text,b1Function)
	thePanel:insert(Button1)
	pH=pH+60
	if b2Img~=nil then
		local Button2 = ui.makeButton(pIndent,pH,180,50,b2Img,b2Text,b2Function)
		thePanel:insert(Button2)
		pH=pH+60
	end

	thePanel.x=x
	thePanel.y=y
	panelRect.height=pH+10
	
	return(thePanel)
end

function ui.makeListPanel(name,x,y,w,h,numItems,listFunction,theList,b1Img,b1Text,b1Function)

	local myTable=table.copy(theList)
	if (table.maxn(myTable)<numItems) then numItems=table.maxn(myTable) end
	local pH=20--panel height and spacing for buttons
	local thePanel=display.newGroup()
	thePanel.name=name
	lastPanel=name
	local panelRect = display.newRoundedRect(0,0,w,h,5)
	panelRect:setFillColor(pR,pG,pB,pA)
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	
	thePanel:insert(panelRect)
	local inputOffset=0
	local pIndent=10
	local pX=10
	local theItem 
	for i=1,numItems do
		if myTable[i][2]~=nil then -- checking if has distance from waypoints
			theItem = ui.makeButton(pX,pH,240,60,"bluebutton",string.sub(string.gsub(myTable[i][2],".txt",""),1,20).."\n"..myTable[i][1].."kn",listFunction,myTable[i])
			theItem.data=myTable[i]
		else
			theItem = ui.makeButton(pX,pH,240,60,"bluebutton",string.sub(string.gsub(myTable[i],".txt",""),1,20),listFunction,myTable[i])
		end
		
		thePanel:insert(theItem)
		pH=pH+70
	end
	pIndent=((w-180)/2)
	local Button1 = ui.makeButton(pIndent,pH,180,50,b1Img,b1Text,b1Function)
	thePanel:insert(Button1)
	pH=pH+60
	
	thePanel.x=x
	thePanel.y=y
	panelRect.height=pH+10
	return(thePanel)
end

function ui.latLongPanel(name,x,y,w,h,inLat,inLong,plusFunctionLat,minusFunctionLat,plusFunctionLong,minusFunctionLong,b1Img,b1Text,b1Function,b2Img,b2Text,b2Function)

	local pH=40--panel height and spacing for buttons
	display.remove(thePanel)
	local thePanel=display.newGroup()
	local panelRect = display.newRoundedRect(0,0,w,h,5)
	panelRect:setFillColor(pR,pG,pB,pA)
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	panelRect.touch = menuListener
	panelRect:addEventListener( "touch", panelRect )
	local pIndent=30
	thePanel:insert(panelRect)
	local inputOffset=0
	local latPanel=display.newGroup()
	local longPanel=display.newGroup()
	local latNums=display.newGroup()
	local longNums=display.newGroup()
	local mod=1
	if (inLat<0) then mod=-1 end

	local textOptions={parent=latNums,text=math.floor(inLat*mod),x=20,y=40,width=50,height=40,font=native.systemFont,fontSize=36,align="center"}
	latTextA = display.newText(textOptions)
	latTextA:setTextColor(1,1,1)
	latTextA.anchorX = 0
	latTextA.anchorY = 0
	
	local plusRect1 = ui.makeButton(35,10,30,30,"plusbutton","",plusFunctionLat,1)
	latPanel:insert(plusRect1)
	local minusRect1 = ui.makeButton(35,80,30,30,"minusbutton","",minusFunctionLat,1)
	latPanel:insert(minusRect1)
	for i=1,4 do
		local plusRect = ui.makeButton(60+i*40,10,30,30,"plusbutton","",plusFunctionLat,i+1)
		latPanel:insert(plusRect)
		local minusRect = ui.makeButton(60+i*40,80,30,30,"minusbutton","",minusFunctionLat,i+1)
		latPanel:insert(minusRect)
		local pText=string.sub(inLat-math.floor(inLat),i+2,i+2)
		if (pText=="") then pText="0" end
		local textOptions={parent=latNums,text=pText,x=60+i*40,y=40,width=40,height=40,font=native.systemFont,fontSize=36,align="left"}
		latTextB = display.newText(textOptions)
		latTextB:setTextColor(1,1,1)
		latTextB.anchorX = 0
		latTextB.anchorY = 0
	end
	latPanel:insert(latNums)
	if (inLong<0) then mod=-1 end
	local textOptions={parent=longNums,text=math.floor(inLong*mod)*mod,x=0,y=180,width=80,height=40,font=native.systemFont,fontSize=36,align="center"}
	longTextA = display.newText(textOptions)
	longTextA:setTextColor(1,1,1)
	longTextA.anchorX = 0
	longTextA.anchorY = 0
	
	local plusRect1 = ui.makeButton(35,150,30,30,"plusbutton","",plusFunctionLong,1)
	longPanel:insert(plusRect1)
	local minusRect1 = ui.makeButton(35,220,30,30,"minusbutton","",minusFunctionLong,1)
	longPanel:insert(minusRect1)
	
	for i=1,4 do
		local plusRect = ui.makeButton(60+i*40,150,30,30,"plusbutton","",plusFunctionLong,i+1)
		longPanel:insert(plusRect)
		local minusRect = ui.makeButton(60+i*40,220,30,30,"minusbutton","",minusFunctionLong,i+1)
		longPanel:insert(minusRect)
		local pText=string.sub(inLong-math.floor(inLong*mod)*mod,i+3,i+3)
		if (pText=="") then pText="0" end
		local textOptions={parent=longNums,text=pText,x=60+i*40,y=180,width=40,height=40,font=native.systemFont,fontSize=36,align="left"}
		latTextB = display.newText(textOptions)
		latTextB:setTextColor(1,1,1)
		latTextB.anchorX = 0
		latTextB.anchorY = 0
	end
	longPanel:insert(longNums)
	
	pH=pH+240
	thePanel:insert(latPanel)
	thePanel:insert(longPanel)
	
	local Button1 = ui.makeButton(pIndent,pH,180,50,b1Img,b1Text,b1Function)
	thePanel:insert(Button1)
	pH=pH+60
	
	local Button2 = ui.makeButton(pIndent,pH,180,50,b2Img,b2Text,b2Function)
	thePanel:insert(Button2)
	
	thePanel.x=x
	thePanel.y=y
	pH=pH+60

	panelRect.height=pH
	if (isPhone) then
		thePanel.width=w*1.5
		thePanel.height=pH*1.5
		thePanel.x=x-w
	end
	if finger~=nil then uiGroup:toFront() end
	return(thePanel)
end

function ui.makeMiniPanel(x,y,w,h,b1Img,b1Text,b1Function,b2Img,b2Text,b2Function,b3Img,b3Text,b3Function,b4Img,b4Text,b4Function,b5Img,b5Text,b5Function,b6Img,b6Text,b6Function,b7Img,b7Text,b7Function,b8Img,b8Text,b8Function)
	local pH=10--panel height and spacing for buttons
	display.remove(thePanel)
	local thePanel=display.newGroup()
	local panelRect = display.newRoundedRect(0,0,w,h,10)
	panelRect:setFillColor(mR,mG,mB)
	panelRect:setStrokeColor(mR-0.3,mG-0.3,mB-0.3)
	panelRect.strokeWidth = 2
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	
	thePanel:insert(panelRect)
	local inputOffset=0
	local pIndent=10
	
	local Button1 = ui.makeMiniButton(pIndent,pH,60,60,b1Img,b1Text,b1Function,1)
	thePanel:insert(Button1)
	
	if b2Img~=nil then
		local Button2 = ui.makeMiniButton(pIndent+70,pH,60,60,b2Img,b2Text,b2Function,2)
		thePanel:insert(Button2)
	end
	pH=pH+70
	if b3Img~=nil then
		
		local Button3 = ui.makeMiniButton(pIndent,pH,60,60,b3Img,b3Text,b3Function,3)
		thePanel:insert(Button3)
		
			if b4Img~=nil then
			local Button4 = ui.makeMiniButton(pIndent+70,pH,60,60,b4Img,b4Text,b4Function,4)
			thePanel:insert(Button4)
		end
		pH=pH+70
	end
	
	if b5Img~=nil then
		
		local Button5 = ui.makeMiniButton(pIndent,pH,60,60,b5Img,b5Text,b5Function,5)
		thePanel:insert(Button5)
		
			if b6Img~=nil then
			local Button6 = ui.makeMiniButton(pIndent+70,pH,60,60,b6Img,b6Text,b6Function,6)
			thePanel:insert(Button6)
		end
		pH=pH+70
	end
	
	if b7Img~=nil then
		
		local Button7 = ui.makeMiniButton(pIndent,pH,60,60,b7Img,b7Text,b7Function,7)
		thePanel:insert(Button7)
		
			if b8Img~=nil then
			local Button8 = ui.makeMiniButton(pIndent+70,pH,60,60,b8Img,b8Text,b8Function,8)
			thePanel:insert(Button8)
		end
		pH=pH+70
	end
	
	thePanel.x=x
	thePanel.y=y
	panelRect.height=pH
	
	if finger~=nil then uiGroup:toFront() end
	return(thePanel)
end

function ui.makeReadNotesPanel(x,y,w,h,theText,b1Img,b1Text,b1Function,b2Img,b2Text,b2Function)

	local pH=10--panel height and spacing for buttons
	if (MD.hTime~=nil) then timer.cancel( MD.hTime ) end
	--display.remove(thePanel)
	local thePanel=display.newGroup()
	local panelRect = display.newRoundedRect(0,0,w,h,10)
	panelRect:setFillColor(nR,nG,nB,nA)
	panelRect:setStrokeColor(nR-0.3,nG-0.3,nB-0.3)
	panelRect.strokeWidth = 2
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	local textWidth=w-20
	local textheight=h-20
	thePanel:insert(panelRect)
	local pIndent=10
	local textOptions
	if (string.len(theText)>850) then
		textOptions={parent=thePanel, text=theText,x=pIndent,y=pH,width=textWidth,height=textHeight,font=native.systemFont,fontSize=22}
	else
		textOptions={parent=thePanel, text=theText,x=pIndent,y=pH,width=textWidth,height=textHeight,font=native.systemFont,fontSize=24}
	end
	local notesField = display.newText(textOptions)
	notesField.anchorX = 0
	notesField.anchorY = 0
	notesField.y=10
	notesField:setFillColor( 0, 0, 0 )
	pH=pH+h-30
	local Button1
	if (b1Img=="vmhlogo") then
		Button1 = ui.makeButton(50,pH-25,400,90,b1Img,b1Text,b1Function)
	else
		Button1 = ui.makeButton(w-400,pH,180,60,b1Img,b1Text,b1Function)
	end
	thePanel:insert(Button1)			
	
		
	if b2Img~=nil then
		local Button2 = ui.makeButton(w-200,pH,180,60,b2Img,b2Text,b2Function)
		thePanel:insert(Button2)
	end
	pH=pH+70
	thePanel.x=x
	thePanel.y=y
	panelRect.height=pH	
	if finger~=nil then uiGroup:toFront() end
	return(thePanel)
end

function ui.makeReadInfoPanel(x,y,w,h,offX,offY,theText,theImage,theFolder,b1Img,b1Text,b1Function,b2Img,b2Text,b2Function,b3Img,b3Text,b3Function,link)

	if (MD.hTime~=nil) then timer.cancel( MD.hTime ) end
	--display.remove(thePanel)
	local thePanel=display.newGroup()
	local panelRect = display.newRect(0,0,w,h)
	panelRect:setFillColor(nR,nG,nB,nA)

	panelRect.anchorX = 0
	panelRect.anchorY = 0
	local textWidth=w-160
	local textheight=h-40
	thePanel:insert(panelRect)
	local theFile=theFolder.."/"..theImage..".jpg"
	helpImage=display.newImageRect(theFile,system.ResourceDirectory,w,h)
	helpImage.x,helpImage.y=512,384
	thePanel:insert(helpImage)
	
	local textOptions={parent=thePanel, text=theText,x=offX,y=offY,width=textWidth,height=textHeight,font=native.systemFont,fontSize=36}
	local notesField = display.newText(textOptions)
	notesField.anchorX = 0
	notesField.anchorY = 0
	notesField:setFillColor( 1,1,1 )
	local Button1,Button2,Button3
	Button1 = ui.makeButton(w-200,h-70,180,60,b1Img,b1Text,b1Function)
	thePanel:insert(Button1)			
			
	if b2Img~=nil then
		Button2 = ui.makeButton(w-200,h-70,180,60,b2Img,b2Text,b2Function)
		thePanel:insert(Button2)
		Button1.x=Button1.x-200
	end
	if b3Img~=nil then
		Button3 = ui.makeButton(w-200,h-70,180,60,b3Img,b3Text,b3Function,link)
		thePanel:insert(Button3)
		Button1.x=Button1.x-200
		Button2.x=Button2.x-200
	end
	thePanel.x=x
	thePanel.y=y
	if finger~=nil then uiGroup:toFront() end
	return(thePanel)
end

function ui.makePrefPanel(x,y,w,h,offX,offY,prefText,prefButtons,hText)

	if (MD.hTime~=nil) then timer.cancel( MD.hTime ) end

	local thePanel=display.newGroup()
	local panelRect = display.newRoundedRect(0,0,w,h,30)
	panelRect:setFillColor(nR,nG,nB,1)
	
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	local textWidth=w-240
	local textheight=60
	local headText=hText or "Preferences"
	thePanel:insert(panelRect)
	pH=30
	local textOptions={parent=thePanel, text=headText,x=offX,y=offY+pH,width=w-40,height=60,font=native.systemFont,fontSize=48,align="center"}
	local prefField = display.newText(textOptions)
	prefField.anchorX = 0
	prefField.anchorY = 0
	prefField:setFillColor( 1,1,1 )
	pH=pH+70	

	for i=1,#prefText do
		local textOptions={parent=thePanel, text=prefText[i],x=offX,y=offY+pH,width=textWidth,height=textHeight,font=native.systemFont,fontSize=24}
		local prefField = display.newText(textOptions)
		prefField.anchorX = 0
		prefField.anchorY = 0
		prefField:setFillColor( 1,1,1 )

		theButton = ui.makeButton(w-200,pH,180,60,prefButtons[i][1],prefButtons[i][2],prefButtons[i][3],prefButtons[i][4])
		thePanel:insert(theButton)	
		pH=pH+70		
	end
	
	theButton = ui.makeButton(w-400,pH,180,60,"greybutton","done",clearPanel)
	thePanel:insert(theButton)
	pH=pH+70
	thePanel.x=x
	thePanel.y=y
	panelRect.height=pH	
	if finger~=nil then uiGroup:toFront() end
	return(thePanel)
end

function ui.inputNumPanelDDD(x,y,w,h,numFunction,b1Img,b1Text,b1Function,b2Img,b2Text,b2Function)

	local pH=40--panel height and spacing for buttons
	display.remove(thePanel)
	local thePanel=display.newGroup()
	local panelRect = display.newRoundedRect(0,0,w,h,10)
	panelRect:setFillColor(pR,pG,pB,pA)
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	local pIndent=10
	thePanel:insert(panelRect)
	
	local inputOffset=0
	local numPanel=display.newGroup()
	local buttonPanel=display.newGroup()
	thePanel:insert(numPanel)
	thePanel:insert(buttonPanel)

	for i=1,7 do
		local textOptions={parent=numPanel,text="0",x=-25+i*30,y=20,width=40,height=40,font=native.systemFont,fontSize=36,align="left"}
		numText = display.newText(textOptions)
		numText:setTextColor(1,1,1)
		numText.anchorX = 0
		numText.anchorY = 0
	end
	pH=pH+50
	local numTable={"1","2","3","4","5","6","7","8","9","-","0","."}
	local mulX,mulY=0,0
	for i=1,12 do
		local plusRect = ui.makeButton(-50+i*65+mulX,pH+mulY,60,60,"numbutton",numTable[i],numFunction,i)
		buttonPanel:insert(plusRect)
		if (i==3) or (i==6) or (i==9) then
			mulY=mulY+70
			mulX=mulX-195
		end
	end

	pH=pH+290
	
	local Button1 = ui.makeButton(20,pH,180,50,b1Img,b1Text,b1Function)
	thePanel:insert(Button1)
	pH=pH+60
	
	local Button2 = ui.makeButton(20,pH,180,50,b2Img,b2Text,b2Function)
	thePanel:insert(Button2)
	pH=pH+60
	thePanel.x=x
	thePanel.y=y

	panelRect.height=pH	
	return(thePanel)
end

function ui.inputNumPanelDMM(x,y,w,h,latFunction,longFunction,numFunction,tabFunction,b1Img,b1Text,b1Function,b3Img,b3Text,b3Function,b4Img,b4Text,b4Function)

	local pH=40--panel height and spacing for buttons
	display.remove(thePanel)
	local thePanel=display.newGroup()
	local panelRect = display.newRoundedRect(0,0,w,h,10)
	panelRect:setFillColor(pR,pG,pB,pA)
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	local pIndent=10
	thePanel:insert(panelRect)
	
	local inputOffset=0
	local numPanel1=display.newGroup()
	local numPanel2=display.newGroup()
	local numPanel3=display.newGroup()
	local numPanel4=display.newGroup()
	local buttonPanel=display.newGroup()
	thePanel:insert(numPanel1)
	numPanel1.num=1
	numPanel1.touch = tabFunction
	numPanel1:addEventListener( "touch", numPanel1 )
	thePanel:insert(numPanel2)
	thePanel:insert(numPanel3)
	thePanel:insert(numPanel4)
	thePanel:insert(buttonPanel)

	for i=1,3 do
		local textOptions={parent=numPanel1,text="0",x=-20+i*30,y=20,width=40,height=40,font=native.systemFont,fontSize=36,align="left"}
		numText = display.newText(textOptions)
		numText:setTextColor(1,1,1)
		numText.anchorX = 0
		numText.anchorY = 0
		
		local textOptions={parent=numPanel3,text="0",x=-20+i*30,y=70,width=40,height=40,font=native.systemFont,fontSize=36,align="left"}
		numText = display.newText(textOptions)
		numText:setTextColor(1,1,1)
		numText.anchorX = 0
		numText.anchorY = 0
	end
	
	for i=1,4 do
		local textOptions={parent=numPanel2,text="0",x=78+i*30,y=20,width=40,height=40,font=native.systemFont,fontSize=36,align="left"}
		numText = display.newText(textOptions)
		numText:setTextColor(1,1,1)
		numText.anchorX = 0
		numText.anchorY = 0
		
		local textOptions={parent=numPanel4,text="0",x=78+i*30,y=70,width=40,height=40,font=native.systemFont,fontSize=36,align="left"}
		numText = display.newText(textOptions)
		numText:setTextColor(1,1,1)
		numText.anchorX = 0
		numText.anchorY = 0
	end
	local dotRect = display.newRect(163,50,8,8)
	dotRect:setFillColor(0,0,0)
	thePanel:insert(dotRect)
	local dotRect = display.newRect(163,100,8,8)
	dotRect:setFillColor(0,0,0)
	thePanel:insert(dotRect)
	local latButton = ui.makeMiniButton(230,20,30,40,"numbutton","S",latFunction)
	buttonPanel:insert(latButton)
	local latButton = ui.makeMiniButton(230,20,30,40,"numbutton","N",latFunction)
	buttonPanel:insert(latButton)
	local longButton = ui.makeMiniButton(230,70,30,40,"numbutton","W",longFunction)
	buttonPanel:insert(longButton)
	local longButton = ui.makeMiniButton(230,70,30,40,"numbutton","E",longFunction)
	buttonPanel:insert(longButton)
	numPanel2.alpha=0.5
	numPanel2.num=2
	numPanel2.touch = tabFunction
	numPanel2:addEventListener( "touch", numPanel2 )
	numPanel3.alpha=0.5
	numPanel3.num=3
	numPanel3.touch = tabFunction
	numPanel3:addEventListener( "touch", numPanel3 )
	numPanel4.alpha=0.5
	numPanel4.num=4
	numPanel4.touch = tabFunction
	numPanel4:addEventListener( "touch", numPanel4 )
	pH=pH+80
	
	local numTable={"1","2","3","4","5","6","7","8","9","","0"}
	local mulX,mulY=0,0
	for i=1,11 do
		--if (numTable[i]~="") then
			local numButton = ui.makeButton(-20+i*65+mulX,pH+mulY,60,60,"numbutton",numTable[i],numFunction,i)
			buttonPanel:insert(numButton)
			if (i==3) or (i==6) or (i==9) then
				mulY=mulY+70
				mulX=mulX-195
			end
		--end
	end
	local Button1 = ui.makeMiniButton(175,pH+mulY,60,60,b1Img,b1Text,b1Function)
	thePanel:insert(Button1)

	pH=pH+290
		
	local Button3 = ui.makeButton(50,pH,180,50,b3Img,b3Text,b3Function)
	thePanel:insert(Button3)
	pH=pH+60
	thePanel.x=x
	thePanel.y=y
	
	local Button4 = ui.makeButton(50,pH,180,50,b4Img,b4Text,b4Function)
	thePanel:insert(Button4)
	pH=pH+60
	thePanel.x=x
	thePanel.y=y

	panelRect.height=pH	
	return(thePanel)
end

function ui.keyPanel(x,y,w,h,textFunction,b1Img,b1Text,b1Function,b2Img,b2Text,b2Function)

	local pH=10--panel height and spacing for buttons
	display.remove(thePanel)
	local thePanel=display.newGroup()
	local panelRect = display.newRoundedRect(0,0,w,h,10)
	panelRect:setFillColor(pR,pG,pB,pA)
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	local pIndent=10
	thePanel:insert(panelRect)
	
	local inputOffset=0
	local textPanel=display.newGroup()
	local buttonPanel=display.newGroup()
	thePanel:insert(textPanel)
	thePanel:insert(buttonPanel)
	
	local numTable={"1","2","3","4","5","6","7","8","9","0","-"}
	local textTable1={"Q","W","E","R","T","Y","U","I","O","P"}
	local textTable2={"A","S","D","F","G","H","J","K","L","@"}
	local textTable3={"Z","X","C","V","B","N","M",".","_","'"}
	local allTables={numTable,textTable1,textTable2,textTable3}
	local mulX,mulY=0,0
	for i=1,4 do
		for j=1,table.maxn(allTables[i]) do
			local textRect = ui.makeButton(-50+j*65+mulX,pH+mulY,60,60,"numbutton",allTables[i][j],textFunction,allTables[i][j])
			buttonPanel:insert(textRect)
		end
		mulY=mulY+70
		if (i<3) then mulX=mulX+30 end
	end
	local lastkey=table.maxn(allTables[1])+table.maxn(allTables[2])+table.maxn(allTables[3])+table.maxn(allTables[4])+1
	pH=pH+280
	local Button1 = ui.makeButton(80,pH,500,50,b1Img,b1Text,b1Function,lastKey)
	buttonPanel:insert(Button1)
	pH=pH+10
	local Button2 = ui.makeButton(600,pH,180,50,b2Img,b2Text,b2Function)
	thePanel:insert(Button2)
	pH=pH+60

	thePanel.x=x
	thePanel.y=y

	panelRect.height=pH	
	return(thePanel)
end

function ui.pickerPanelDMM(x,y,w,h,b1Img,b1Text,b1Function,b2Img,b2Text,b2Function)
	display.remove(thePanel)
	local thePanel=display.newGroup()
	local panelRect = display.newRoundedRect(0,0,w,h,10)
	panelRect:setFillColor(pR,pG,pB,1)
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	thePanel:insert(panelRect)
	local maxLat,minLat,maxLong,minLong=math.ceil(MD.topLat),math.floor(MD.bottomLat),math.ceil(MD.bottomLong),math.floor(MD.topLong)
	local maxLatF,minLatF,maxLongF,minLongF=math.floor(MD.topLat),math.floor(MD.bottomLat),math.floor(MD.bottomLong),math.floor(MD.topLong)
	
	local maxLatM,minLatM,maxLongM,minLongM=math.floor(navMaths.ddd2dmm(MD.topLat)[2]),math.floor(navMaths.ddd2dmm(MD.bottomLat)[2]),math.floor(navMaths.ddd2dmm(MD.topLong)[2]),math.floor(navMaths.ddd2dmm(MD.bottomLong)[2])
	
	local textOptions={parent=thePanel,text="Waypoints can only be entered within the current chart\nFormat is Degrees Minutes Decimal (DDD MM.MM)",x=20,y=10,width=w-40,height=60,font=native.systemFont,fontSize=24,align="left"}
	local wpInfo = display.newText(textOptions)
	wpInfo:setTextColor(.2,.2,.2,1)
	wpInfo.anchorX = 0
	wpInfo.anchorY = 0

	local latListD={50}

		--for i = 49,51 do
		-- for i = 51,55 do
			--table.insert(latListD,i)
		--end

	local longListD={0,-1}

		-- for i = -7,2 do
		-- for i = -11,-4 do
			-- table.insert(longListD,i)
		-- end
	
	local latListM={}
	for i = 0,59 do
		table.insert(latListM,i)
	end
	
	local longListM={}
	for i = 0,59 do
		table.insert(longListM,i)
	end
	
	local listMM={}
	for i = 0,99 do
		table.insert(listMM,i)
	end
	
	local columnDataLat = 
	{ 	{ 	align = "center",
			-- startIndex = math.floor(#latListD/2),
			startIndex = 1,
			labels = latListD,
		},
		{ 	align = "center",
			startIndex = math.floor(#latListM/2),
			labels = latListM,
		},
		{ 	align = "center",
			startIndex = math.floor(#listMM/2) ,
			labels = listMM,
		},}
		
	local columnDataLong = 
	{ 	{ 	align = "center",
			startIndex = math.floor(#longListD/2),
			labels = longListD,
		},
		{ 	align = "center",
			startIndex = math.floor(#longListM/2),
			labels = longListM,
		},
		{ 	align = "center",
			startIndex = math.floor(#listMM/2) ,
			labels = listMM,
		},}
	
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
	pickerWheelLat = widget.newPickerWheel
	{
		top=80,
		left=10,
		font = native.systemFontBold,
		fontSize=20,
		columns = columnDataLat,
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
		columnColor = { 0, 0, 0, 0 },
		fontColor = { .5,.5,.5, 1 },
		fontColorSelected = { 0,0,0}
	}
	thePanel:insert(pickerWheelLat)
	
	pickerWheelLong = widget.newPickerWheel	{
		top=80,
		left=360,
		font = native.systemFontBold,
		fontSize=20,
		columns = columnDataLong,
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
		columnColor = { 0, 0, 0, 0 },
		fontColor = { .5,.5,.5, 1 },
		fontColorSelected = { 0,0,0}
	}
	thePanel:insert(pickerWheelLong)
	
	pH=320
	local Button1 = ui.makeButton(260,pH,180,50,b1Img,b1Text,b1Function)
	thePanel:insert(Button1)
	
	local Button2 = ui.makeButton(460,pH,180,50,b2Img,b2Text,b2Function)
	thePanel:insert(Button2)	
	thePanel.x=x
	thePanel.y=y
	return(thePanel)
end

function ui.makeMOBPanel(x,y,w,h,textWidth,textHeight,fSize,b1Img,b1Text,b1Function,b2Img,b2Text,b2Function,b3Img,b3Text,b3Function,b4Img,b4Text,b4Function)

	local pH=10--panel height and spacing for buttons
	if (MD.hTime~=nil) then timer.cancel( MD.hTime ) end
	--display.remove(thePanel)
	local thePanel=display.newGroup()
	local panelRect = display.newRoundedRect(0,0,w,h,10)
	panelRect:setFillColor(pR,pG,pB,pA)
	panelRect:setStrokeColor(pR-0.3,pG-0.3,pB-0.3)
	panelRect.strokeWidth = 2
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	
	thePanel:insert(panelRect)
	local inputOffset=0
	local pIndent=10
	
	local textOptions={parent=thePanel, text="MAN OVERBOARD ALERT",x=pIndent,y=pH,width=w-20,height=textHeight,font=native.systemFont,align="center",fontSize=fSize}
	local notesField = display.newText(textOptions)
	notesField.anchorX = 0
	notesField.anchorY = 0

	notesField:setFillColor( 1, 0, 0 )
	pH=pH+40
	local textOptions={parent=thePanel, text="Click this box to minimise",x=pIndent,y=pH,width=w-20,height=30,font=native.systemFont,align="center",fontSize=24}
	local notesField2 = display.newText(textOptions)
	notesField2.anchorX = 0
	notesField2.anchorY = 0
	notesField2:setFillColor( 0, 0, 0 )
	
	pH=pH+30
	local textOptions={parent=thePanel, text="52DEG 43.56M",x=pIndent,y=pH,width=textWidth,height=textHeight,font=native.systemFont,align="center",fontSize=fSize+4}
	local notesField = display.newText(textOptions)
	notesField.anchorX = 0
	notesField.anchorY = 0
	notesField:setFillColor( 1, 0, 0 )
	
	local textOptions={parent=thePanel, text="-7DEG 13.06M",x=pIndent,y=pH,width=textWidth,height=textHeight,font=native.systemFont,align="center",fontSize=fSize+4}
	local notesField = display.newText(textOptions)
	notesField.anchorX = 0
	notesField.anchorY = 0
	notesField.x=w/2+10	
	notesField:setFillColor( 1, 0, 0 )
	pH=pH+60
	
	local textOptions={parent=thePanel, text="52DEG 43.46M",x=pIndent,y=pH,width=textWidth,height=textHeight,font=native.systemFont,align="center",fontSize=fSize}
	local notesField = display.newText(textOptions)
	notesField.anchorX = 0
	notesField.anchorY = 0
	notesField.x=10
	notesField:setFillColor( 0, 0, 0 )
	
	local textOptions={parent=thePanel, text="-7DEG 13.12M",x=pIndent,y=pH,width=textWidth,height=textHeight,font=native.systemFont,align="center",fontSize=fSize}
	local notesField = display.newText(textOptions)
	notesField.anchorX = 0
	notesField.anchorY = 0
	notesField.x=w/2+10
	notesField:setFillColor( 0, 0, 0 )
	pH=pH+50
	
	local textOptions={parent=thePanel, text="DISTANCE",x=pIndent,y=pH,width=textWidth,height=textHeight,font=native.systemFont,align="center",fontSize=fSize}
	local notesField = display.newText(textOptions)
	notesField.anchorX = 0
	notesField.anchorY = 0
	notesField.x=10
	notesField:setFillColor( 0, 0, 0 )
	
	local textOptions={parent=thePanel, text="0.23NM",x=pIndent,y=pH,width=textWidth,height=textHeight,font=native.systemFont,align="center",fontSize=fSize}
	local notesField = display.newText(textOptions)
	notesField.anchorX = 0
	notesField.anchorY = 0
	notesField.x=w/2+10
	notesField:setFillColor( 0, 0, 0 )
	pH=pH+40
	
	
	-- local Button1 = ui.makeButton(pIndent,pH,180,60,b1Img,b1Text,b1Function)
	-- thePanel:insert(Button1)
	pIndent=pIndent+190
	if b2Img~=nil then
		local Button2 = ui.makeButton(pIndent,pH,180,60,b2Img,b2Text,b2Function)
		thePanel:insert(Button2)
	end
	pIndent=pIndent+190
	-- if b3Img~=nil then
		-- local Button3 = ui.makeButton(pIndent,pH,180,60,b3Img,b3Text,b3Function)
		-- thePanel:insert(Button3)
		-- pIndent=pIndent+190
	-- end
	pH=pH+70
	
	thePanel.x=x
	thePanel.y=y
	panelRect.height=pH
			
	return(thePanel)
end

function ui.getInfoGroup(leftEdge)
-- runs along bottom, shows crosshairs info, opens and closes
	mainInfoGroup=display.newGroup()
	local behindRect
	if ort=="V" then --orientation of menu
		behindRect = display.newRoundedRect(mainInfoGroup,190,bottomEdge-80,924-leftEdge,80,30)
	else
		behindRect = display.newRoundedRect(mainInfoGroup,585,bottomEdge-80,924-leftEdge,80,30)
	end
	behindRect:setFillColor(1,1,0.8,0.8)
	behindRect.anchorX = 0
	behindRect.anchorY = 0
	
	infoClose=display.newGroup()
	infoClose1=display.newGroup()
	if ort=="V" then
		menuCloseButton = ui.makeButton(195,695,70,70,"arrow","",slideInfo)	
		menuOpenButton = ui.makeButton(195,695,70,70,"arrowback","",slideInfo)
	else
		menuCloseButton = ui.makeButton(590,700,50,50,"arrow","",slideInfo)	
		menuOpenButton = ui.makeButton(590,700,50,50,"arrowback","",slideInfo)
	end
	infoClose:insert(menuCloseButton)
	infoClose1:insert(menuOpenButton)	
	mainInfoGroup:insert(infoClose)
	mainInfoGroup:insert(infoClose1)

	lldGroup=display.newGroup()
	local textOptions1,textOptions2,textOptions3
	local xShift=0
	
		textOptions1={parent=lldGroup, text="",x=640,y=735,font=native.systemFont,fontSize=24}
		textOptions2={parent=lldGroup, text="",x=760,y=735,font=native.systemFont,fontSize=24}
		textOptions3={parent=lldGroup, text="",x=885,y=735,font=native.systemFont,fontSize=24}
		latLongD1 = display.newText(textOptions1)
		latLongD1:setTextColor(0,0,0)
		latLongD1.anchorX = 0
		latLongD1.anchorY = 0
		latLongD2 = display.newText(textOptions2)
		latLongD2:setTextColor(0,0,0)
		latLongD2.anchorX = 0
		latLongD2.anchorY = 0
		latLongZoom = display.newText(textOptions3)
		latLongZoom:setTextColor(0,0,0)
		latLongZoom.anchorX = 0
		latLongZoom.anchorY = 0
		mainInfoGroup:insert(lldGroup)
	if ort=="H" then 
		xShift=360 
		lldGroup.alpha=0
	else
		lldGroup.alpha=1
	end
	llmGroup=display.newGroup()
	local textOptions={parent=llmGroup, text="",x=290+xShift,y=735,width=50,height=30,font=native.systemFont,fontSize=24,align="right"}
	latLongM1 = display.newText(textOptions)
	latLongM1:setTextColor(1,0,0)
	latLongM1.anchorX = 0
	latLongM1.anchorY = 0
	mainInfoGroup:insert(llmGroup)
	
	local textOptions={parent=llmGroup, text="",x=355+xShift,y=735,width=100,height=30,font=native.systemFont,fontSize=24,align="left"}
	latLongM2 = display.newText(textOptions)
	latLongM2:setTextColor(1,0,0)
	latLongM2.anchorX = 0
	latLongM2.anchorY = 0
	
	local textOptions={parent=llmGroup, text="",x=450+xShift,y=735,width=50,height=30,font=native.systemFont,fontSize=24,align="right"}
	latLongM3 = display.newText(textOptions)
	latLongM3:setTextColor(1,0,0)
	latLongM3.anchorX = 0
	latLongM3.anchorY = 0
	
	local textOptions={parent=llmGroup, text="",x=515+xShift,y=735,width=100,height=30,font=native.systemFont,fontSize=24,align="left"}
	latLongM4 = display.newText(textOptions)
	latLongM4:setTextColor(1,0,0)
	latLongM4.anchorX = 0
	latLongM4.anchorY = 0
	
	local textOptions={parent=llmGroup, text="O",x=350+xShift,y=745,font=native.systemFont,fontSize=12}
	latLongDeg = display.newText(textOptions)
	latLongDeg:setTextColor(0,0,0)
	local textOptions={parent=llmGroup, text="O",x=510+xShift,y=745,font=native.systemFont,fontSize=12}
	latLongDeg2 = display.newText(textOptions)
	latLongDeg2:setTextColor(0,0,0)
	--if isPhone then llmGroup.alpha=0 end

	local textOptions
	if ort=="V" then
		textOptions={parent=mainInfoGroup, text="",x=280,y=700,font=native.systemFont,fontSize=20}
	else
		textOptions={parent=mainInfoGroup, text="",x=655,y=695,width=500,height=60,font=native.systemFont,fontSize=18}
	end
	MD.cName = display.newText(textOptions)
	MD.cName:setFillColor(0,0,1)
	MD.cName.anchorX = 0
	MD.cName.anchorY = 0
	return mainInfoGroup
end

-----------------------------------------------------------------------------

function ui.destroyInterface()

end

return ui