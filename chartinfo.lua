
xmlapi = require( "xml" ).newParser()

local chartInfo = {}
local chartInfo = {_index = interface}

function chartInfo.getList()
	local chartxml
	print(xmlFile)
	chartxml = xmlapi:loadFile("data/"..xmlFile..".xml",system.DocumentsDirectory )

	local myChartList={}
	
	for i=1, #chartxml.child do
		local myChart={}
		table.insert(myChartList,myChart)
		for j=1,15 do
			table.insert(myChartList[i],chartxml.child[i].child[j].value)
		end
	end
	return myChartList
end

function chartInfo.readNM()
	local myNMList={}
	local nmxml = xmlapi:loadFile("nm.xml")
	for i=1, #nmxml.child do
		local myNM={}
		table.insert(myNMList,myNM)
		for j=1,5 do
			table.insert(myNMList[i],nmxml.child[i].child[j].value)
		end
	end
	return myNMList
end

function chartInfo.loadNMdata()
	--called from tools panel 
	clearPanel()
	CI.getNM()
	myNM=CI.readNM()
	timer.performWithDelay(2000,function () readNMData() end)
end

function chartInfo.readNMData()
	nmTable={}
	local wpLoaded=0
	for i=1,#myNM do
		if (myNM[i]~="") then 
			local nmName=myNM[i][1]
			local nmData=myNM[i][2].."\n"..myNM[i][3]
			local markLat=(tonumber(myNM[i][4]))
			local markLong=(tonumber(myNM[i][5]))
			showNM(nmName,nmData,markLat,markLong)
		end
	end
end

function chartInfo.showNM(nmName,nmData,markLat,markLong)
	newNM=display.newImageRect("images/nm.png",40,40)
	newNM.name=lightName
	newNM.touch=nmListener
	newNM:addEventListener( "touch", newNM )
	newNM.info=nmData.."\n"..markLat.."\n"..markLong
	local theLat=navMaths.getPixelsFromLat(markLat)-MD.mapH/2
	local theLong=navMaths.getPixelsFromLong(markLong)-MD.mapW/2
	newNM.x,newNM.y=theLong,theLat
	nmGroup:insert(newNM)
end

function chartInfo.nmListener(self,touch)
	local phase = touch.phase
	if (phase=="ended") then
		notes.showNotes(self.info)
	end
	return true
end


return chartInfo