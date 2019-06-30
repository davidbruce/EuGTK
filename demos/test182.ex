
-----------------------------------------------------------------
--# GtkFileChooserDialog
-- See also GtkFileSelector.e for a 'pre-built' dialog, 
-- which saves having to set up all the dialog params each time. 
-----------------------------------------------------------------

include GtkEngine.e

constant docs = `markup=
<u><b>FileChooserDialog</b></u>

the same dialog can be used to either open a file, save a file, 
or select a folder, by changing the action.

`
constant 
	win = create(GtkWindow,"border=10,size=300x-1,$destroy=Quit"),
	pan = create(GtkBox,"orientation=vertical,spacing=10"),
	lbl = create(GtkLabel,docs),
	box = create(GtkButtonBox)
	
    add(box,{ -- another way to code;
	create(GtkButton,"gtk-quit","Quit"),
	create(GtkButton,"folder-open#_Open",call_back(routine_id("Open"))),
	create(GtkButton,"gtk-save",call_back(routine_id("Save"))),
	create(GtkButton,"folder#_Folder",call_back(routine_id("ChooseFolder")))})

	add(win,pan)
	add(pan,lbl)
	pack(pan,-box)
	
show_all(win)
main()

-----------------------------------------------------------
function Open()
-----------------------------------------------------------

object dlg = create(GtkFileChooserDialog,{
	{"title","Open a file"},
	{"transient for",win},
	{"action",GTK_FILE_CHOOSER_ACTION_OPEN},
        {"select multiple",TRUE},
	{"add button","gtk-cancel",-1},
	{"add button","gtk-ok",1},
        {"add shortcut folder","../gtk3"}, -- I store GTK3 docs here;
        {"add shortcut folder","../docs/html"}}) -- and Eu docs here;

	if run(dlg) = 1 then 
		if Info(win,"Open","Open the file",
			get(dlg,"filename"),GTK_BUTTONS_YES_NO) = MB_YES then
			show_uri(get(dlg,"uri"))
		end if
	end if
	
        -- single select:
        -- get(dlg,"file") -- gets a GFile handle;
        -- get(dlg,"filename") -- gets /home/folder/file.ext format;
        -- get(dlg,"uri") -- gets file:///home/folder/file.ext format;

        -- multiple:
        -- get(dlg,"filenames") -- retuns sequence of all selected names;
        -- get(dlg,"files") -- returns a list of GFile handles;
        -- get(dlg,"uris") -- returns sequence of all selected uris;
        -- filename and uri return first file if multiple selected;
      
	destroy(dlg)

return 1
end function

------------------------------------------------------------
function Save()
------------------------------------------------------------
object dlg = create(GtkFileChooserDialog,{
	{"title","Save this file"},
	{"transient for",win},
	{"action",GTK_FILE_CHOOSER_ACTION_SAVE},
	{"add button","gtk-cancel",-1},
	{"add button","gtk-ok",1},
	{"current name","My Wonderful Program.ex"}})

	if run(dlg) = 1 then 
		Info(win,"Save","Save the file",
			"My Wonderful Program.ex\n(not really)",GTK_BUTTONS_CLOSE)
	end if 
	destroy(dlg)

return 1
end function

------------------------------------------------------------
function ChooseFolder()
------------------------------------------------------------
object dlg = create(GtkFileChooserDialog,{
	{"title","Choose a folder"},
	{"transient for",win},
	{"action",GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER},
	{"add button","gtk-cancel",-1},
	{"add button","gtk-ok",1}})

	ifdef WINDOWS then -- skip this
	elsedef
	    set(dlg,"filter", create(GtkFileFilter,{ -- Windows doesn't know mimes;
		{"name","Directories"},{"add mime type","inode/directory"}}))
	end ifdef

	if run(dlg) = 1 then 
		Info(win,"Folder","You chose folder:",
			get(dlg,"filename"),GTK_BUTTONS_CLOSE)
	end if 
	destroy(dlg)

return 1
end function



