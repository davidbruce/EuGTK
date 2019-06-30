
------------------------------------------------------------------------------
--# Formatting floats in GtkListView cells
------------------------------------------------------------------------------

include GtkEngine.e

include std/locale.e -- for 'money' format

-- Note: when you use locale.e, you will have to use the
-- namespaces for locale and eugtk calls, since locale.e and 
-- GtkEngine.e both have add(), set() and get() functions

locale:set("en_US.utf8") -- try different locales: en_IE.utf8, en_GB.utf8, etc.

constant docs = `<u><b>Floating-point numbers</b></u>

Numbers stored in list stores as floating-point
display with too many decimal places.

This shows how to display them correctly using a 
custom formatting function and locale:money()

`
constant 
    win = create(GtkWindow,"border=10,icon=thumbnails/mongoose.png,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    lbl = create(GtkLabel,{{"markup",docs}}),
    scroller = create(GtkScrolledWindow,"min content height=150,min contrent width=290"),
    col1 = create(GtkColumn,"title=Name,type=text,text=1,sort=1"),
    col2 = create(GtkColumn,"title=Age,type=text,text=2"),
    col3 = create(GtkColumn,"title=Raw Float,type=text,text=3,xalign=1,editable=TRUE"),
    col4 = create(GtkColumn,"title=Formatted,name=col4,type=text,text=3,xalign=1,editable=TRUE")
  
    gtk:set(col4,"cell data func",pointer("col4.renderer"),_("MyCellFmt")) -- use our own custom fmt func;

constant tv = create(GtkTreeView,{
    {"rules hint",TRUE},
    {"reorderable",TRUE},
    {"grid lines",GTK_TREE_VIEW_GRID_LINES_BOTH},
    {"append columns",{col1,col2,col3,col4}}})

constant selection = gtk:get(tv,"selection")
   
constant mdl = create(GtkListStore,{gSTR,gINT,gFLT})
    gtk:set(tv,"model",mdl)

constant list = 
{
    {"Sam Smith",45,19.95},
    {"Sue Jones",23,98.33},
    {"Frank Farkel",64,-4.00},
    {"Joe Schmoe",49,1056.50},
    $
}
gtk:set(mdl,"data",list)
add(win,panel)
add(panel,lbl)
add(scroller,tv)
pack(panel,scroller,TRUE,TRUE)

show_all(win)
ifdef WINDOWS then Info(,,"Sorry","Doesn't work in Windows") end ifdef
main()

---------------------------------------------------------------
function MyCellFmt(atom layout, atom rend, atom mdl, atom iter)
---------------------------------------------------------------
-- this function 'fixes' the display of floating-point numbers
-- in a list/tree view. Money is formatted per locale,
-- and debits are shown in red;

object val = gtk:get(mdl,"col data from iter",iter,3) 
  
   if string(val) then val = to_number(val) end if

    if val < 0 then 
        gtk:set(rend,"foreground","red")
    else
        gtk:set(rend,"foreground","black")
    end if
   
    gtk:set(rend,"property","markup",locale:money(val)) -- must specify "property";

return 1
end function

---------------------------------------------------------
function UpdateValue3(atom ctl, atom rend, object newval)
---------------------------------------------------------
atom row = gtk:get(selection,"selected row") 
    newval = to_number(peek_string(newval))
    gtk:set(mdl,"col data",row,3,newval)
return 1
end function

---------------------------------------------------------
function UpdateValue4(atom ctl, atom rend, object newval)
---------------------------------------------------------
atom row = gtk:get(selection,"selected row") 
    newval = to_number(peek_string(newval))  
    gtk:set(mdl,"col data",row,3,newval) 
return 1
end function
