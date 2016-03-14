------------------------------------------
-- Auxiliary Module
-- version: 0.0.1
-- Decription: This module has auxiliary functions to download/unzip files, decrypt images and show "encrypted images" on the fly
--
------------------------------------------

local aux = {}

---- Specify below your decryption settings
local cypher = "aes-128-cbc"
local passKey = "CA054921"

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
    
    baseDir = baseDir or system.DocumentsDirectory
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


local function showEncryptedImage(filename,width,height)
    
    -- decrypts the image
    local encrytedContent = readFromFile(filename .. ".aes")
    if encrytedContent == nil then
        return print("ERROR - Image encrypted not found ("..filename..".aes)")
    end
    local decrytedContent = decrypt(encrytedContent)
    
    -- temporarily saving the decrypted image
	baseDir= system.DocumentsDirectory,
    saveToFile(decrytedContent, filename)

    local image = display.newImageRect(filename,baseDir,width,height)

    --  deleting saving the decrypted image
    -- timer.performWithDelay(100,function()
        -- local results, reason = os.remove( system.pathForFile(filename,baseDir  ) )
        -- if results ~= true then print("Error trying to remove encryted image - reason =", reason) end
    -- end)    
   return image
end



-------------------------------------------------------
-- PUBLIC FUNCTIONS


aux.showEncryptedImage = showEncryptedImage


return aux
