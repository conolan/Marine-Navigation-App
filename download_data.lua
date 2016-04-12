------------------------------------------
-- Auxiliary Module
-- version: 0.0.1
-- Decription: This module has auxiliary functions to download/unzip files, decrypt images and show "encrypted images" on the fly
--
------------------------------------------

local aux = {}

--tidePlace=IO.loadFile("downloadtide_"..region..".txt",system.ResourceDirectory)
chartPlace=IO.loadFile("downloadchart_"..region..".txt",system.ResourceDirectory)
if platformName=="Android" then chartPlace=IO.loadFile("downloadchart_"..region.."android.txt",system.ResourceDirectory) end
dataPlace=IO.loadFile("downloaddata_"..region..".txt",system.ResourceDirectory)
-- places=IO.loadFile("downloadplaces.txt",system.ResourceDirectory)
-- places=IO.loadFile("downloadplaces.txt",system.ResourceDirectory)
-- places=IO.loadFile("downloadplaces.txt",system.ResourceDirectory)

local tideFile = region.."_tides.zip"
local tideFilename = region.."/tides/"..region.."_tides.zip"
--local tideURL = tidePlace[1]

local dataFile = region.."_data.zip"
local dataFilename = region.."/data/"..region.."_data.zip"
local dataURL = dataPlace[1]

local chartFile = region.."_charts.zip"
if platformName=="Android" then chartFile = region.."_chartsandroid.zip" end
local chartFilename = region.."/"..region.."_charts.zip"
local chartURL = chartPlace[1]

---- Specify below your decryption settings
local cypher = "aes-128-cbc"
local passKey = "CF06B92D"

-------------------------------------------------------
-- PRIVATE FUNCTIONS

-- decrypt the data
local function decrypt(data)
    
    local openssl = require "plugin.openssl"
    local cipher = openssl.get_cipher ( cypher )    
    return cipher:decrypt ( data, passKey )    
end

-- saves the "contents" to a file called "filename"
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

-- reads the contents of a file called "filename" that is in the baseDir (baseDir can be = system.ResourcesDirectory, system.DocumentsDirectory, system.TemporaryDirectory)
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

-- unzips a file, set all extracted files to not sync with iCloud (Apple) and then deletes the zip file
local function unzip(filename, onComplete)
	local zip = require( "plugin.zip" )    
	local function zipListener( event )
        if ( event.isError ) then 
           
           return onComplete(false)
        else           
           if ( event.response and type(event.response) == "table" ) then               
              for i = 1, #event.response do                  
                  -- prints each file uncompressed
                  
                  -- disalbe iCloud backup for the file
                  local results, errStr = native.setSync( event.response[i], { iCloudBackup = false } )
              end              
              -- removes the zip file
              local results, reason = os.remove( system.pathForFile(filename, system.DocumentsDirectory  ) )
              if results ~= true then print("Error trying to remove zip file - reason =", reason) end
              
              return onComplete(true, event.response)
           end    
           onComplete(false)
        end
     end
    local options = {
            zipFile = filename,
            zipBaseDir = system.DocumentsDirectory,
            dstBaseDir = system.DocumentsDirectory,
            listener = zipListener,
         }
         zip.uncompress( options )
end


local function downloadTideAndUnzipIt(onComplete)
        
    local function networkListener( event )
                        
        if ( event.isError ) then
			errtxt=errtxt.. "Network err-tide failed "
            onComplete(false)
        
        elseif ( event.phase == "began" ) then
            -- print( "Phase: began" )
        
        elseif ( event.phase == "progress" ) then
            if ( event.bytesEstimated <= 0 ) then
                disText2.text= "Download progress: " .. math.floor(event.bytesTransferred/1000000) .."Mb"
            else
                disText2.text= "Download progress: " .. math.floor(event.bytesTransferred/1000000) .."Mb" .. " of estimated: " .. math.floor(event.bytesTransferred/1000000) .."Mb"
            end        
        elseif ( event.phase == "ended" ) then
            disText2.text=  "Phase: ended - Tide Download complete, total bytes transferred: " .. math.floor(event.bytesTransferred/1000000) .."Mb"          
            if event.status ~= 200 or type(event.response) ~= "table" then errtxt= errtxt.."Tide error "; return; end
            
           unzip(event.response.filename,onComplete)
		   -- print("event.response.filename=", "tide")
        end
    end

    local params = {}
    params.progress = true
    params.bodyType = "binary"
    network.download(tideURL,"GET",networkListener, params, tideFile, system.DocumentsDirectory )
end

local function downloadData(onComplete)    
    local function networkListener( event )       
     if ( event.isError ) then
			errtxt=errtxt.. "Network err-data failed "
            onComplete(false)
        
        elseif ( event.phase == "began" ) then
            disText2.text="Phase: began"
        
        elseif ( event.phase == "progress" ) then
            if ( event.bytesEstimated <= 0 ) then
                disText2.text= "Download progress: " .. math.floor(event.bytesTransferred/1000000) .."Mb" 
            else
                disText2.text= "Download progress: " .. math.floor(event.bytesTransferred/1000000) .."Mb" .. " of estimated: " .. event.bytesEstimated
            end        
        elseif ( event.phase == "ended" ) then
            disText2.text=  "Phase: ended - Data Download complete, total bytes transferred: " .. math.floor(event.bytesTransferred/1000000) .."Mb"          
            if event.status ~= 200 or type(event.response) ~= "table" then disText2.text= "Error - connected to the server but download failed"; return; end
            
            
           unzip(event.response.filename,onComplete)
		   print("event.response.filename=", "data")
        end
    end
	disText2.text="Starting - "..dataURL
    local params = {}
    params.progress = true
    params.bodyType = "binary"

    network.download(dataURL,"GET",networkListener, params, dataFile, system.DocumentsDirectory )
end

local function downloadChartData(onComplete)    
    local function networkListener( event )
                        
        if ( event.isError ) then
            errtxt=errtxt.. "Network err-Chart failed "
            onComplete(false)
        
        elseif ( event.phase == "began" ) then
            print( "Phase: began" )
        
        elseif ( event.phase == "progress" ) then
            if ( event.bytesEstimated <= 0 ) then
                disText2.text= "Download progress: " .. math.floor(event.bytesTransferred/1000000) .."Mb" 
            else
                disText2.text= "Download progress: " .. math.floor(event.bytesTransferred/1000000) .."Mb" .. " of estimated: " .. math.floor(event.bytesEstimated/1000000) .."Mb"
            end
			if ( event.bytesTransferred < event.bytesEstimated*.2 ) then 
				if doHarbour then 
					disText1.text="Notes on harbours, marinas and Yacht Clubs"
				else
					disText1.text="Tides covering the full year - choose any date"
				end
			elseif ( event.bytesTransferred < event.bytesEstimated*.6 ) then 
				disText1.text="Screen capture charts with routes and waypoints and email for printing" 
			elseif ( event.bytesTransferred < event.bytesEstimated*.8 ) then 
				disText1.text="Updated charts for 2016" 
			elseif ( event.bytesTransferred < event.bytesEstimated ) then 
				if doLights then 
					disText1.text="Updated Lights and Marks data plus tides covering the full year" 
				else
					disText1.text="Tides covering the full year - choose any date" 
				end
			end
        elseif ( event.phase == "ended" ) then
            disText2.text=  "Phase: ended - Download complete, total bytes transferred: " .. math.floor(event.bytesTransferred/1000000) .."Mb"          
            if event.status ~= 200 or type(event.response) ~= "table" then disText2.text= chartURL; return; end
            
           print("event.response.filename=", event.response.filename)
           unzip(event.response.filename,onComplete)
           IO.saveOverFile("chartupdate.txt",theTime)
        end
    end

    local params = {}
    params.progress = true
    params.bodyType = "binary"

    network.download(chartURL,"GET",networkListener, params, chartFile, system.DocumentsDirectory )
	
end

-------------------------------------------------------
-- PUBLIC FUNCTIONS

aux.downloadTideAndUnzipIt = downloadTideAndUnzipIt
aux.downloadData = downloadData
aux.downloadChartData = downloadChartData

return aux
