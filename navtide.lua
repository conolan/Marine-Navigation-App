local widget = require "widget"

local navTide = {}

m_position={}
m_position.y=208
infograph="_m"
local xWidth=586
pickedDate=""
local graph = {}
local m_dates={}

local dayStrings={}
tideWeek={}
timeWeek={}
local tideText={}
local tideInfo={}
local sunInfo={}
local tideList={}
local tideNum={}
local sunSet={}
local sunRise={}
local moonPhase={}
graph.graphPoints = {}
graph.numGraphPoints = 0
local myImage, infotext, graphWidth, tideLine, tideGroup, currentTime, isToday, isSummer
local pR,pG,pB,pA=1,.6,.2,.9

local function makeDate(date)
	if string.len(date)==1 then date="0"..date end
	return date
end

local function new_Vector(xComp, yComp)
	local vector = {}
	vector.x = xComp
	vector.y = yComp	
	return vector
end

local cypher = "aes-128-cbc"
local passKey = "CA054921"

local function decrypt(data)    
    local openssl = require "plugin.openssl"
    local cipher = openssl.get_cipher ( cypher )    
    return cipher:decrypt ( data, passKey )    
end

local function readFromFile(filename, baseDir)     
    baseDir = baseDir or system.ResourceDirectory
    local path = system.pathForFile(filename, baseDir)
    local fh, reason = io.open(path, "rb")
    local content = nil
    if fh then
        
        -- read the content of the file
        content = fh:read("*a")  
        fh:close()        
    else
      print("Couldn't open file - reason: " .. reason)      
    end    
    return content
end

local function saveToFile(contents, filename, baseDir)
    
    baseDir = baseDir or system.DocumentsDirectory
    local path = system.pathForFile(filename, baseDir)
    local fh, reason = io.open(path, "wb")
    if fh then
        fh:write(contents)
        fh:close()  
    else
        print("Couldn't open file - reason: " .. reason)      
    end
end

local function showEncryptedTide(filename, baseDir)
    --print(filename .. ".aes")
    -- decrypts the image
    local encrytedContent = readFromFile(filename .. ".aes", baseDir)
    if encrytedContent == nil then
        return print("ERROR - Image encrypted not found ("..filename..".aes)")
    end
    local decrytedContent = decrypt(encrytedContent)
   
    -- temporarily saving the decrypted image
    saveToFile(decrytedContent, filename, baseDir)
	tideContent=IO.loadFile(filename, baseDir)
	-- loading using different function due to error parsing
   return tideContent   
end

local function showPlainTide(filename, baseDir)
    --print(filename .. ".aes")
	tideContent=IO.loadFile(filename, baseDir)
	-- loading using different function due to error parsing
   return tideContent   
end

---------------------------------------------------------------------------------------------------------------

graph.calculateSingleSection = function(tide1, tide2, pInterval, pPos, points)

	local numOfPoints = math.floor(pInterval/4);
	local point;
	local tempX = pPos.x;
	local tempY = pPos.y;

	for t = 1, numOfPoints do
		tempY = (( (tide1 + tide2)/2+(tide1-tide2)/2*math.cos((3.14/numOfPoints)*t) )*m_scale)

		point = new_Vector(tempX, pPos.y-tempY)
		points[graph.numGraphPoints] = point

		graph.numGraphPoints = graph.numGraphPoints+1
		tempX = tempX+pInterval/numOfPoints
	end
	return graph.numGraphPoints
end


graph.getHighest = function(tides)
	local highest = 0
	for i = 1, table.maxn(tides) do
		if tides[i].y > highest then
			highest = tides[i].y
		end
	end	
	return highest
end

graph.getLowest = function(tides)
	local lowest = 100
	for i = 1, table.maxn(tides) do
		if tides[i].y < lowest then
			lowest = tides[i].y
		end
	end	
	return lowest
end


graph.calculateSections = function(day)
	graph.graphPoints = {}
	graph.numGraphPoints = 0

	local pointInterval=graph.timeToPixels(timeWeek[day][2])-graph.timeToPixels(timeWeek[day][1])+xWidth

	graph.calculateSingleSection(tideWeek[day][1], tideWeek[day][2], pointInterval, new_Vector(m_position.x+graph.timeToPixels(timeWeek[day][1])-xWidth, m_position.y), graph.graphPoints);

	for z=3,#tideWeek[day] do
		if tideWeek[day][z]~=nil and tideWeek[day][z]~="*" and timeWeek[day][z]~=nil and timeWeek[day][z]~="*" then
			-- print("calculateSections",timeWeek[day][z],timeWeek[day][z-1])
			if timeWeek[day][z]<timeWeek[day][z-1] and (string.sub(timeWeek[day][z],1,2)~="24") then
				
				local pointInterval=graph.timeToPixels(timeWeek[day][z])-graph.timeToPixels(timeWeek[day][z-1])+xWidth
				graph.calculateSingleSection(tideWeek[day][z-1], tideWeek[day][z], pointInterval, new_Vector(m_position.x+graph.timeToPixels(timeWeek[day][z-1]), m_position.y), graph.graphPoints);
		
				break
			else
				local pointInterval=graph.timeToPixels(timeWeek[day][z])-graph.timeToPixels(timeWeek[day][z-1])
				graph.calculateSingleSection(tideWeek[day][z-1], tideWeek[day][z], pointInterval, new_Vector(m_position.x+graph.timeToPixels(timeWeek[day][z-1]), m_position.y), graph.graphPoints);
			end
			--end	
		end
	end
end

graph.timeToPixels = function(pTime) 
	if pTime~=nil then
		local minutes = tonumber(pTime:sub(4,5))
		local hours = pTime:sub(1,2)
		-- 12 pixels per hour, 5 minutes per pixel.
		return (hours*24) + (minutes/10); 
	end
end

graph.showText = function(day)
	local textGroup=display.newGroup()	
	local numTides=tideNum[day]
	local newLine=false
	local lineH,fSize,tleft=30,26,325
	if numTides>6 then lineH,fSize,tleft=28,24,325 end
	if numTides>7 then newLine=true end
	for i=1,#tideWeek[day] do
		if tideWeek[day]~="*" then
			if timeWeek[day][i+1]~=nil then
				if (string.sub(timeWeek[day][i+1],1,2)~="24") then
				
					local textOptions={parent=textGroup,text="", x=tleft,y= 12+i*lineH,width=200,height=40,font=native.systemFont,fontSize=fSize,align="left"}
				
					local disText = display.newText(textOptions)
					if i>6 then 
						disText.y=12+(i-6)*lineH
						disText.x=525						
					end
					if tideText[day][i]~=nil then 
					if tonumber(tideWeek[day][i+1])> midTide then 
						disText.text=disText.text.."H "
						disText:setTextColor(1,1,1)
					else
						disText.text=disText.text.."L "
						disText:setTextColor(0,0,0)
					end
					--disText.x=320
					-- if tideText[day][i]~=nil then 
						disText.text=disText.text..tideText[day][i]
						if string.len(tideText[day][i])==11 then disText.text=disText.text.."  " end
					end
				end
			end
		end
	end
	if newLine==false then
		local textOptions={parent=textGroup,text="Sun & Moon at\n"..string.upper(tideSun), x=520,y= 174,width=200,height=60,font=native.systemFont,fontSize=20,align="center"}
		local source = display.newText(textOptions)
		source:setTextColor(.7,.7,.9)
		
		local sunRise = display.newText("Sunrise "..sunRise[day], 520, 40, native.systemFont, 30)
		sunRise.anchorX = 0.5
		sunRise.anchorY = .5
		sunRise:setTextColor(1,1,1)
		textGroup:insert(sunRise)
		
		local sunSet = display.newText("Sunset "..sunSet[day], 520, 75, native.systemFont, 30)
		sunSet:setTextColor(1,1,1)
		sunSet.anchorX = 0.5
		sunSet.anchorY = .5
		textGroup:insert(sunSet)

		if moonPhase[day]~="*" then
			local moon = display.newImageRect("tideimages/"..moonPhase[day]..".png", 50,50)
			moon.x=520
			moon.y=120
			textGroup:insert(moon)
		end
	end
	return textGroup
end

graph.drawTideGraph = function(day)
	tideGroup=display.newGroup()
	myImage = display.newImageRect("tideimages/graph"..infograph..".png", graphWidth,282)
	--myImage:setReferencePoint(display.TopLeftReferencePoint);
	myImage.anchorX = 0
	myImage.anchorY = 0
	myImage.x = 0
	myImage.y =0
	tideGroup:insert(myImage)
	local thisDay=dayStrings[day]
	local textOptions={parent=tideGroup,text=thisDay, x=10,y= -22,width=400,height=40,font=native.systemFont,fontSize=20,align="center"}
	local myName = display.newText(textOptions)
	
	myName:setTextColor(1,1,1)
	myName.anchorX = 0
	myName.anchorY = 0
	myName.x=-(myName.width-640)/2
	
	display.setDefault("lineColor",0,0,0)
	
	local rect = display.newRoundedRect(m_position.x-2 ,13, graph.timeToPixels(sunRise[day])+m_position.x/2, 226,10)
	rect:setFillColor(0,0,0,0.3)
	rect.anchorX = 0
	rect.anchorY = 0
	tideGroup:insert(rect)
	
	local rect = display.newRoundedRect(m_position.x+graph.timeToPixels(sunSet[day]),13, graphWidth-graph.timeToPixels(sunSet[day])-m_position.x*2, 226,10)	
	tideGroup:insert(rect)
	rect:setFillColor(0,0,0,0.3)
	rect.anchorX,rect.anchorY = 0,0

	local highest = graph.getHighest(graph.graphPoints)
	local lowest = graph.getLowest(graph.graphPoints)
	
	if day==1 and isToday==true then
		local nowLineX=graph.timeToPixels(currentTime)+m_position.x
		local line = display.newLine(nowLineX,20,nowLineX,225)
		line:setStrokeColor(0,1,0,1)
		line.strokeWidth=4
		tideGroup:insert(line)
	end
	
	display.setDefault("lineColor",0.5,0.5,1)
	tideLine=display.newGroup()
	
	for i = 1, #graph.graphPoints-1 do

		if graph.graphPoints[i].x >= m_position.x-10 and graph.graphPoints[i+1].x <= (m_position.x)+xWidth then
--first graphpoint greater than left edge and second point less than right edge
			if graph.graphPoints[i-1].x < m_position.x-10 and graph.graphPoints[i].x > m_position.x-10 then

			elseif graph.graphPoints[i+1].x > (m_position.x)+(xWidth) and graph.graphPoints[i].x < (m_position.x)+(xWidth) then


			else
				local line = display.newLine(graph.graphPoints[i].x, graph.graphPoints[i].y, graph.graphPoints[i+1].x, graph.graphPoints[i+1].y)
				line.strokeWidth=2
				line:setStrokeColor(45/256,119/256,219/256,1)
				tideLine:insert(line)
				
				pPoints={graph.graphPoints[i].x,220, graph.graphPoints[i].x, graph.graphPoints[i].y, graph.graphPoints[i+1].x, graph.graphPoints[i+1].y,graph.graphPoints[i+1].x,220}
				local poly=display.newPolygon( graph.graphPoints[i].x, 220,pPoints )
				--poly.fill = {45/256,119/256,219/256,0.5}
				poly:setFillColor( 45/256,119/256,219/256,0.5 )
				poly.anchorX = 0
				poly.anchorY = 1
				tideLine:insert(poly)
			end
		end
		
	end
	tideLine.y=20
	tideGroup:insert(tideLine)
	
	for i=1,tideNum[day] do
		local offSet = 43
		if math.fmod(i, 2)~=0 then offSet=58 end
		if tideText[day][i]~="*" then
			local timeDisplay=timeWeek[day][i+1]
			if timeDisplay~=nil then
				if string.sub(timeDisplay,1,2)=="24" then timeDisplay="00"..string.sub(timeDisplay,3) end
				if (graph.timeToPixels(timeWeek[day][i+1])-graph.timeToPixels(timeWeek[day][i]))>30 or i==1 then
					local tide1a = display.newText(timeDisplay, graph.timeToPixels(timeWeek[day][i+1]), -20, native.systemFont, 18)
					tide1a:setTextColor(1,1,1)

					tide1a.anchorX = 0
					tide1a.anchorY = 0.5
					if tide1a.x<15 then tide1a.x=15 end
					if tide1a.x>560 then tide1a.x=560 end
					tide1a.y=210+offSet
					tideGroup:insert(tide1a)
					local tide1b = display.newText(tideWeek[day][i+1], graph.timeToPixels(timeWeek[day][i+1]), -20, native.systemFont, 18)
					tide1b:setTextColor(0,0,0)

					tide1b.anchorX = 0
					tide1b.anchorY = 0.5
					if tide1b.x<15 then tide1b.x=15 end
					if tide1b.x>560 then tide1b.x=560 end
					tide1b.y=lowest+90-offSet
					tideGroup:insert(tide1b)
				end
			end
		end
	end
	return tideGroup
	
end

function navTide.startTide(tideData)
	local tideName=tideData[1]
	local tideSite=tideData[2]
	tideSun=tideData[3]
	m_scale=tideData[4]
	midTide=tideData[5]

	local tideGroup = display.newGroup()
	local rect = display.newRect(leftEdge-230,topEdge-80,screenWidth,screenHeight)
	rect:setFillColor(0,0,0,0.7)
	rect.touch = menuListener
	rect:addEventListener( "touch", rect )
	rect.anchorX = 0
	rect.anchorY = 0
	tideGroup:insert(rect)
	local panelRect = display.newRoundedRect(-10,-10,660,600,5)
	panelRect:setFillColor(pR,pG,pB,pA)
	panelRect:setStrokeColor(pR-0.3,pG-0.3,pB-0.3)
	panelRect.strokeWidth = 2
	panelRect.anchorX = 0
	panelRect.anchorY = 0
	tideGroup:insert(panelRect)
	local currentYear = tonumber(os.date( "%Y" ) )
	local currentMonth = tonumber(os.date( "%m" ) )
	local currentDay = tonumber(os.date( "%d" ) )
	local myDate
	if pickedDate~="" then
		myDate=pickedDate
		isToday=false
		pickedDate=""
	else
		myDate=( makeDate(currentDay).."/"..makeDate(currentMonth).."/"..currentYear )
		isToday=true
		if currentYear~=2016 then 
			myDate="25/12/2016" 
			isToday=false
		end
	end
	local myImage

	if (tonumber(string.sub(myDate,4,5))>10) or ((tonumber(string.sub(myDate,4,5))==10) and (tonumber(string.sub(myDate,1,2))>30)) then
		myImage = display.newImageRect("tideimages/header.png", 640,96)
		isSummer=false
	elseif (tonumber(string.sub(myDate,4,5))<3) or ((tonumber(string.sub(myDate,4,5))==3) and (tonumber(string.sub(myDate,1,2))<27)) then
		myImage = display.newImageRect("tideimages/header.png", 640,96)
		isSummer=false
	else
		myImage = display.newImageRect("tideimages/header_summer.png", 640,96)
		isSummer=true
	end

	myImage.anchorX = 0
	myImage.anchorY = 0
	myImage.x = 0
	myImage.y =display.screenOriginY/2
	tideGroup:insert(myImage)	
	local nameText
	if (string.len(tideName)<15) then
		nameText = display.newText(tideGroup,tideName,320, 40, native.systemFont,48)
	elseif (string.len(tideName)>25) then
		nameText = display.newText(tideGroup,tideName,320, 40, native.systemFont,30)
	else
		nameText = display.newText(tideGroup,tideName,320, 40, native.systemFont,36)
	end
	nameText:setFillColor(pR-0.3,pG-0.3,pB-0.3)
	
	m_position.x=34
	graphWidth=640
	graph.graphPoints = {}
	graph.numGraphPoints = 0
	-- tideInfo = showEncryptedTide("tides/"..tideSite..".txt",system.DocumentsDirectory )
	print(tideSite)
	tideInfo = showPlainTide("tides/"..tideSite..".txt",system.ResourceDirectory )
	sunInfo = showPlainTide("tides/"..tideSun.."sunmoon.txt",system.ResourceDirectory )

	currentTime = os.date( "%H:%M" ) 

	local endDate=7
	for i=1,#tideInfo do
		tideTable = string.gsub(tideInfo[i],"  "," "):split(" ")
		-- print("dates",tideTable[4],tideTable[3],tideTable[2])
		local tideDate=(makeDate(tideTable[4]).."/"..makeDate(tideTable[3]).."/"..tideTable[2])
		
		if tideDate==myDate then
			
			local tideTableP = string.gsub(tideInfo[i-1],"  "," "):split(" ")
			local tideTableN = string.gsub(tideInfo[i+1],"  "," "):split(" ")
			-- This checks for the last day of year. need change if required to roll into a new year
			if tonumber(string.sub(tideDate,1,2))>24 and tonumber(string.sub(tideDate,4,5))==12 and tonumber(string.sub(tideDate,9,10))==15 then
				endDate=31-tonumber(string.sub(tideDate,1,2))

			end
			
			for z=1,endDate do
				numTides=2
				sunTable = string.gsub(sunInfo[i-1+z],"  "," "):split(",")
				tideTable = string.gsub(string.gsub(tideInfo[i-1+z],"  "," "),"  "," "):split(" ")
				local tideTableP = string.gsub(string.gsub(tideInfo[i-2+z],"  "," "),"  "," "):split(" ")
				local tideTableN = string.gsub(string.gsub(tideInfo[i+z],"  "," "),"  "," "):split(" ")
				local m_times={}
				local m_tides={}
				local m_text={}
				numTides=1
				for i=5,27, 2 do
					local pTime,pTide					
					if tideTableP[i]~="*" then 
					
						m_times[1]=convertToTime(tideTableP[i])
						m_tides[1]=tideTableP[i+1]
						--table.insert(m_text,"*")
					end					
				end

				for i=5,27, 2 do
					if tideTable[i]~="*" then 
						table.insert( m_times, convertToTime(tideTable[i]) )
						table.insert( m_tides, tideTable[i+1] )
						table.insert(m_text,convertToTime(tideTable[i]).." : "..tideTable[i+1])
						numTides=numTides+1
					else
						table.insert( m_times, convertToTime(tideTableN[5]) )
						table.insert( m_tides, tideTableN[6] )
						--table.insert(m_text,"*")
						break
					end
				end
				
				if tideTable[27]~="*" then
					table.insert( m_times, convertToTime(tideTableN[5]) )
					table.insert( m_tides, tideTableN[6] )
				end
				
				local theDate=makeDate(tideTable[4]).."/"..makeDate(tideTable[3]).."/"..tideTable[2]
				local theDay=os.date( "*t", os.time{year=tideTable[2], month=makeDate(tideTable[3]), day=makeDate(tideTable[4]) } )
				local days={"Sunday", "Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"}

				dayStrings[z]=days[theDay.wday].." "..theDate
				
				tideWeek[z]=m_tides
				timeWeek[z]=m_times
				tideText[z]=m_text
				tideNum[z]=numTides
				sunRise[z]=sunTable[2]
				sunSet[z]=sunTable[3]
				moonPhase[z]=sunTable[4]

			end
		end		
	end

	if currentYear==2016 then
	
		local function scrollViewListener( event )
		
			local s = event.target    -- reference to scrollView object
			local phase = event.phase

			if "ended"==phase then

				local sPosX,sPosY=s:getContentPosition()
				if sPosX>0 then s:scrollToPosition{x=0, y=sPosY,} end
				if sPosX<-graphWidth*6 then s:scrollToPosition{x=-graphWidth*6, y=sPosY,} end
				s:scrollToPosition{	x=(math.round(sPosX/graphWidth)*graphWidth),y= 0, time=200}
			end
		end
	
		tideScroll = widget.newScrollView
		{
			top = 100-display.screenOriginY/2,
			left = 0,
			width = graphWidth,
			height = 480,
			scrollWidth = graphWidth,
			scrollHeight = 0,
			listener = scrollViewListener,
			verticalScrollDisabled=true,
			backgroundColor = { pR-0.15,pG-0.15,pB-0.15 }
		}			

		for i=1,endDate do
			graph.calculateSections(i)
			tideTable[i]=graph.drawTideGraph(i)
			tideList[i]=graph.showText(i)
			tideTable[i].y=20
			tideList[i].y=280
			tideTable[i].x=-graphWidth+i*graphWidth
			tideList[i].x=-graphWidth+i*graphWidth
			tideScroll:insert(tideList[i])

			tideScroll:insert(tideTable[i])			
		end

		tideGroup:insert(tideScroll)
		
		local button1=ui.makeButton(30,510,180,60,"greybutton","Exit",hideTide)
		tideGroup:insert(button1)

		local button2=ui.makeButton(30,430,180,60,"bluebutton","Pick a date",picker.showPicker,tideData)
		tideGroup:insert(button2)
	else
		local button1=ui.makeButton(50,510,180,60,"greybutton","Exit",hideTide)
		tideGroup:insert(button1)
		nameText.text="Tide data no longer available"
	end
	return tideGroup	
end

function convertToTime(rawTime)

	local formedTime
	if rawTime=="*" or rawTime=="9999" or rawTime=="99.9" then
		formedTime="*"
	else
		if isSummer then rawTime=rawTime+100 end
		
		if string.len(rawTime)==4 then
			formedTime=string.sub(rawTime,1,2)..":"..string.sub(rawTime,3,4)
		elseif string.len(rawTime)==3 then
			formedTime="0"..string.sub(rawTime,1,1)..":"..string.sub(rawTime,2,3)
		elseif string.len(rawTime)==2 then
			formedTime="00:"..rawTime
		else
			formedTime="00:0"..rawTime
		end
	end
	return formedTime
end

return navTide