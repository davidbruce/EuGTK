
-----------------------------------------------------------------------------
--# Attaching data to GtkButtons
-- Can pass integers or atoms which can be used directly.
-- Strings and more complex Euphoria objects are passed via pointer, 
-- which is created automatically, but must be 'unpacked' before use.
-----------------------------------------------------------------------------

include GtkEngine.e

sequence items = {
    {"Excesso Gasoline","gallon",3.599}, -- item #1
    {"Slippery Oil",    "quart", 2.49} -- item #2
}
enum NAME, UNIT, PRICE

constant 
    pix = create(GdkPixbuf,"thumbnails/gconf-editor.png"),
    win = create(GtkWindow,"size=200x150,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    img = create(GtkImage,pix),
    lbl1 = create(GtkLabel,"Carguy's Service Station"),
    lbl2 = create(GtkLabel,"font=8,text='Associating data with buttons"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"Gas",_("Foo"),1),
    btn2 = create(GtkButton,"Oil",_("Foo"),2) 
    
    add(win,panel)
    add(panel,{img,lbl1,lbl2})
    add(box,{btn1,btn2})
    pack(panel,-box)
    
show_all(win)
main()

------------------------------------------------
function Foo(atom ctl, integer n) -- n is item #
------------------------------------------------
    Info(win,"Lou's Gas & Oil",
        items[n][NAME],  
        sprintf("$%2.2f per %s",{items[n][PRICE],items[n][UNIT]}))
    return 1
end function



