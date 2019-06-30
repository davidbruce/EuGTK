
with define BUILDER

include GtkEngine.e

add(builder,locate_file("widgetname.glade"))

main()

-----------------------------------------------------------------------
global function setcolor(atom ctl) 
-----------------------------------------------------------------------
set("window1","background",get(ctl,"name"))
return 1
end function
