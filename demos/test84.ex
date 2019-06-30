
--------------------------------------------------------------------
--# Attaching data to buttons using Euphoria maps 
--------------------------------------------------------------------

include GtkEngine.e
include std/map.e

object jerry = map:new()
    map:put(jerry,"Name","Jerry")
    map:put(jerry,"School","Central High")
    map:put(jerry,"Age",17)
    map:put(jerry,"Pix",create(GdkPixbuf,"thumbnails/Jerry.jpg",100,100,1))

object justin = map:new()
    map:put(justin,"Name","Justin")
    map:put(justin,"School","Cleveland Middle School")
    map:put(justin,"Age",13)
    map:put(justin,"Pix",create(GdkPixbuf,"thumbnails/Justin.jpg",100,100,1))

constant 
    win = create(GtkWindow,"size=200x100,border_width=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    lbl = create(GtkLabel,"markup=<b><u>Passing Data</u></b> Using maps"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"Jerry","Foo",jerry),
    btn3 = create(GtkButton,"Justin","Foo",justin),
    btnbox = create(GtkButtonBox)
    
    add(win,panel)
    add(panel,lbl)
    add(btnbox,{btn1,btn2,btn3})
    pack(panel,-btnbox)

show_all(win)
main()

------------------------------------------------------------------------
global function Foo(atom ctl, integer data)
------------------------------------------------------------------------
Info(win,"Student",map:get(data,"Name"),
    sprintf(" <u>School:</u>\n   %s\n <u>Age:</u>\n   %d",
	{map:get(data,"School"),
	 map:get(data,"Age")}),,
	 map:get(data,"Pix"))
return 1
end function

