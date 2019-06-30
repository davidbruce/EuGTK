
------------------------------------------------------
--# Custom monetary formatting for GtkCellRenderers
------------------------------------------------------

include GtkEngine.e
include std/locale.e -- requires you to use gtk: namespace;

--locale:set("en_GB.utf8") -- try this;

constant 
 win = create(GtkWindow,"size=280x180,border=10,$destroy=Quit"),
 panel = create(GtkBox,"orientation=vertical,spacing=10"),
 scrol = create(GtkScrolledWindow),
 store = create(GtkListStore,{gSTR,gINT,gFLT}),
 box = create(GtkButtonBox),
 btn1 = create(GtkButton,"gtk-quit","Quit")
 	       
sequence students = { -- name, age, amt due
    {"Sam Smith",     15, 1009.954}, -- will round down
    {"Sue Jones",     14,   -12.99},
    {"Freddie Farkel",16,  20.0054}, -- will round up
    $}
gtk:set(store,"data",students)

constant 
    tv = create(GtkTreeView,"grid lines=3"),
    col1 = create(GtkColumn,"title=Name,type=text,text=1"),
    col2 = create(GtkColumn,"title=Age,type=text,text=2"),
    col3 = create(GtkColumn,"title=Amt Due, name=col3,type=text,text=3,xalign=1")
    gtk:set(col3,"cell data func",pointer("col3.renderer"),_("monetary_format")) -- see note;
    gtk:set(tv,"model",store)
    -- important note: col3 MUST have a name, doesn't matter what,
    -- in order for the format func call to work!
 add(win,panel)
 add(tv,{col1,col2,col3})
 add(box,btn1)
 add(scrol,tv)
 pack(panel,scrol,1,1)
 pack(panel,-box)
 
show_all(win)
main()

----------------------------------------------------------------------------
-- Generic monetary formatting function, should use different $ symbols for
-- different locales. Currently broken in Windows, my computer thinks I am
-- in Belize. I'm not, darn it!
----------------------------------------------------------------------------
function monetary_format(atom layout, atom rend, atom mdl, atom iter)
----------------------------------------------------------------------------
atom val = gtk:get(mdl,"col data from iter",iter,3) 
 gtk:set(rend,"property","markup",locale:money(val)) -- must use "property" here!
return 1
end function
