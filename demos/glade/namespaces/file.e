
--------------
namespace file
--------------

include GtkEngine.e

add(builder,locate_file("file.glade"))
	
object working_file = canonical_path("~/demos/test0.ex")

constant self = "file:dialog"

-----------------------------------------------------------------------
global function file_new(atom ctl, atom data) 
-----------------------------------------------------------------------
	set(self,{
	    {"action",GTK_FILE_CHOOSER_ACTION_SAVE},
	    {"title","New File"},	
	    {"current name","MyNewFile"},
	    {"run"},
	    {"visible",FALSE}})
return 0
end function

-----------------------------------------------------------------------
global function file_open(atom ctl, atom data) 
-----------------------------------------------------------------------
	set(self,{
	    {"action",GTK_FILE_CHOOSER_ACTION_OPEN},
	    {"title","Open File"},
	    {"filename",working_file},
	    {"run"},
	    {"visible",FALSE}})
return 0
end function

-----------------------------------------------------------------------
global function file_save(atom ctl, atom data) 
-----------------------------------------------------------------------
	set(self,{
	    {"action",GTK_FILE_CHOOSER_ACTION_SAVE},
	    {"title","Save"},
	    {"filename","testxxx.ex"},
	    {"run"},
	    {"visible",FALSE}})
return 1
end function

-----------------------------------------------------------------------
global function file_save_as(atom ctl, atom data) 
-----------------------------------------------------------------------
	set(self,{
	    {"action",GTK_FILE_CHOOSER_ACTION_SAVE},
	    {"title","Save As"},
	    {"current name",""},
	    {"run"},
	    {"visible",FALSE}})
return 1
end function

-- following routines handle file-chooser dialog buttons;
-----------------------------------------------------------------------
global function file_cancel(atom ctl, atom data) 
-----------------------------------------------------------------------
	set(self,"visible",FALSE)
return 1
end function

-----------------------------------------------------------------------
global function file_accept(atom ctl, atom data) 
-----------------------------------------------------------------------
object filename = get(self,"filename") 
	display(filename)
	if atom(filename) then
	return 0 -- no filename entered
	end if
	
integer action = get(self,"action")
	switch action do
		case GTK_FILE_CHOOSER_ACTION_SAVE then
		-- add your save code here;
		case GTK_FILE_CHOOSER_ACTION_OPEN then
		-- open the file and do whatever...
		show_uri(filename) -- for example;
	end switch
	set(self,"visible",FALSE)	
	
return 1
end function
