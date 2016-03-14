

xmlapi = require( "xml" ).newParser()

local chartInfo = {}
local chartInfo = {_index = interface}

function chartInfo.getList()

	local chartxml = xmlapi:loadFile("source/ukirl/charts/0002-0_W.xml")


	print(chartxml.child[3],chartxml.child[4],chartxml.child[5][1],chartxml.child[5][2],chartxml.child[11][3],chartxml.child[11][4],chartxml.child[12][3],chartxml.child[12][4])


end
