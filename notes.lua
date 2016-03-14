local notes = {}

function notes.makeNotes()
	clearPanel()
	local myNotes=IO.loadFile("chart"..chartNum.."_notes.txt")
	local theNotes=""
	if myNotes==nil then 
		theNotes=""
	else
		for i=1,#myNotes do
			theNotes=theNotes..myNotes[i].."\n"
		end
	end
	thePanel=ui.makeNotesPanel(110,10,900,370,true,theNotes,"bluebutton","Save",notes.saveNotes,"greybutton","cancel",clearPanel)
	screenGroup:insert(thePanel)
	return true
end


function notes.saveNotes()
	if "Win" == system.getInfo( "platformName" ) then
		inputName="blah blah blah"
	else
		inputName=inputNoteField.text
	end
	local fileName="chart"..chartNum.."_notes.txt"
	IO.saveOverFile(fileName,inputName)
	clearPanel()
end

function notes.readNotes()
	clearPanel()
	local myNotes=IO.loadFile("chart"..chartNum.."_notes.txt")
	local theNotes=""
	for i=1,#myNotes do
		theNotes=theNotes..myNotes[i].."\n"
	end
	thePanel=ui.makeReadNotesPanel(110,10,800,420,theNotes,"redbutton","Delete\nthis note",notes.deleteNote,"greybutton","Done",clearPanel)
	screenGroup:insert(thePanel)
	return true
end

function notes.showNotes(myNM)
	thePanel=ui.makeReadNotesPanel(110,10,800,420,myNM,"greybutton","Done",clearPanel)
	screenGroup:insert(thePanel)
	return true
end

function notes.deleteNote()
	local filename = "chart"..chartNum.."_notes.txt"
	local results, reason = os.remove( system.pathForFile( filename, system.DocumentsDirectory  ) )
	clearPanel()
	display.remove(noteButton)
	noteButton=nil
end

return notes