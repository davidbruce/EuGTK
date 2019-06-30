
---------------------------------------------------------------
--# GtkRecentFilter
---------------------------------------------------------------

include GtkEngine.e
include std/net/url.e

constant docs = `markup=
<b><u>Recent Filter</u></b>

This shows how to filter types of files
displayed by the RecentChooser.
I've limited it to the most recent 25.

Select a file, and click the <u>O</u>pen button.

`
constant 
    win = create(GtkWindow,"size=300x300,border=10,position=1,$destroy=Quit"),
    pan = create(GtkBox,"orientation=VERTICAL"),
    lbl = create(GtkLabel,docs),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-open","getFile")
   
constant rf1 = create(GtkRecentFilter, -- filter by extension
    "name=Euphoria,add pattern=*.ex,add pattern=*.e")

constant rf2 = create(GtkRecentFilter, -- filter by format
    "name=images,add pixbuf formats=TRUE")

constant rf3 = create(GtkRecentFilter, -- filter by mime type
    "name=html,add mime type=text/html")
    
constant rf4 = create(GtkRecentFilter, -- filter by app
    "name=pdf,add mime type=application/pdf")
    
constant rf5 = create(GtkRecentFilter, -- wildcard filter
    "name=all files,add pattern=*")

constant rc = create(GtkRecentChooserWidget,{
    {"show tips",TRUE}, -- display filepath in tooltips
    {"show not found",FALSE}, -- hid any deleted files 
    {"sort type",GTK_RECENT_SORT_MRU}, 
    {"add filter",rf1},
    {"add filter",rf2},
    {"add filter",rf3},
    {"add filter",rf4},
    {"add filter",rf5},
    {"limit",25}})
    
    add(win,pan)
    add(pan,lbl)
    pack(pan,rc,TRUE,TRUE,10)
    add(box,{btn1,btn2})
    pack(pan,-box)
    
show_all(win)
main()

---------------------------------
global function getFile()
---------------------------------
    object item = get(rc,"current item") 
    if item = 0 then return 1 end if
    object icon = get(item,"gicon") 
    object name = decode(get(item,"uri"))

    if Question(win,"Open","OK to open",name) = MB_YES then
        ifdef WINDOWS then 
			system(sprintf("explorer %s",{abbreviate_path(name)}),0)
			return 1
		end ifdef
        show_uri(name)
    end if
    
return 1
end function



