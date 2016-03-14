
local widget = require( "widget" )

local navMaths = {}


function navMaths.getLatFromPixels(latP)
	local thelat=navMaths.getLatitude(MD.worldWidth,MD.chartTop-latP)
	return thelat
end

function navMaths.getLongFromPixels(longP)
	local thelong=MD.topLong+(longP/MD.longUnit)
	return thelong
end

function navMaths.getPixelsFromLat(lat)
	thePer=((MD.topLat-MD.bottomLat)/2*30)

	fromTopPer=(MD.topLat-lat)/(MD.topLat-MD.bottomLat)
	theMod=math.abs(math.abs(fromTopPer-0.5)-0.5)*thePer	
	local thePixels=((MD.topLat-lat)*MD.latUnit)+theMod

	return thePixels
end

function navMaths.getPixelsFromLong(long)
	local thePixels=(-(MD.topLong-long)*MD.longUnit)
	return thePixels
end

function navMaths.getLatitude ( pxWidth, pixelShift )
    pi = math.pi  
    a = 1 / ( pxWidth / (2 * pi ) )  
    b = math.exp( ( pixelShift * 2) * a ) 
    lat = (math.asin( ( b - 1 ) / (b + 1) ) ) * (180 /pi )
    return lat
end

function navMaths.getTopPixelShift ( pxWidth, map_latitude )
	local pi = math.pi 
    pixelShift = (pxWidth / ( 2 * pi) ) * math.log( math.tan( pi / 4 + (map_latitude/2) * pi / 180 ) )
    return pixelShift
end

function navMaths.getDistance(lat1,long1,lat2,long2,dNum)

	--called from checkmark, result in nautical miles
	if dNum==nil then dNum=2 end
	--print(lat1,long1,lat2,long2,dNum)
	local dlon = math.rad(long2) -math.rad(long1)
	local dlat = math.rad(lat2)- math.rad(lat1)
	local a = math.pow((math.sin(dlat/2)),2) + math.cos(math.rad(lat1)) * math.cos(math.rad(lat2)) * math.pow((math.sin(dlon/2)),2)
	local c = 2 * math.atan2( math.sqrt(a), math.sqrt(1-a) ) 
	local d = navMaths.makeNumD((3440.065* c),dNum)
	return d
end

function navMaths.getBearing(lat1,long1,lat2,long2)
	local dlon = math.rad(long2) -math.rad(long1)
	local dlat = math.rad(lat2)- math.rad(lat1)
	
	local y=math.sin(dlon)*math.cos(math.rad(lat2))
	local x=math.cos(math.rad(lat1))*math.sin(math.rad(lat2))-(math.sin(math.rad(lat1))*math.cos(math.rad(lat2))*math.cos(dlon))
	local bearing=(math.deg(math.atan2(y,x))%360)
	return bearing

end

function navMaths.makeNumD(num,points,force)
	--called from checkMark
	local modifier=math.pow(10,points)
	local newNum=math.round(num*modifier)/modifier
	
	local zeros=""
	if force then	
		if (string.find(newNum,".",1,true)==nil) then newNum=newNum.."." end
		for i=1,string.len(math.round(num))+1+points-string.len(newNum) do
			zeros=zeros.."0"
		end
		return newNum..zeros
	else
		return newNum
	end
end

function navMaths.ddd2dmm(d)
	local mod=1
	if (d<0) then mod=-1 end
	local a=math.floor(d*mod)
	local b=(d*mod-a)*60
	return({a*mod,b})
end

function navMaths.dmmString(lat,long)
	local theLong="  E "
	if (long<0) then theLong="  W " end
	theLong = theLong..navMaths.makeNumD(navMaths.ddd2dmm(math.abs(long))[1],2).."  "..navMaths.makeNumD(navMaths.ddd2dmm(long)[2],2)
	return "N "..navMaths.makeNumD(navMaths.ddd2dmm(lat)[1],2).."  "..navMaths.makeNumD(navMaths.ddd2dmm(lat)[2],2)..theLong
end

function navMaths.dmmStringBreak(lat,long)-- not used
	local theLong="  E "
	if (long<0) then theLong="W " end
	theLong = theLong..navMaths.makeNumD(navMaths.ddd2dmm(math.abs(long))[1],2).."  "..navMaths.makeNumD(navMaths.ddd2dmm(long)[2],2)
	return "N "..navMaths.makeNumD(navMaths.ddd2dmm(lat)[1],2).."  "..navMaths.makeNumD(navMaths.ddd2dmm(lat)[2],2).."\n"..theLong
end

function navMaths.dmm2ddd(d,m)
--CANNOT PASS MINUS TO THIS, MINUS ADDED AFTER
	local b=(m)/60
	local outPut=navMaths.makeNumD(tonumber(d+b),4)
	return(outPut)
end

return navMaths