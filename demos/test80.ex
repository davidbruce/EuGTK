
----------------------------------------------------------------
--# GtkMenus with styled text;

-- There are a number of different ways to create menus.
-- The easiest is with Glade (see examples in Glade folder),
-- but  the method shown below is probably the 'cleanest' 
-- and most-readable way to hand-code a menu.
-- You can add icons and/or accelerator keys
----------------------------------------------------------------

include GtkEngine.e

-- see also test54 for an alternate way to create the menu items

constant 
    win  = create(GtkWindow,"size=300x-1,border=10,position=MOUSE,$destroy=Quit"),
    group = create(GtkAccelGroup),
    panel = create(GtkBox,"orientation=vertical"),
    menubar = create(GtkMenuBar),
    filemenu = create(GtkMenuItem,"_File"),
    submenu1 = create(GtkMenu,"font=Purisa 16"),
    lbl = create(GtkLabel,"markup=<b><u>Menus</u></b>\n" &
	"This shows a way manually create and style menus.\n\n" &
	"Click on the _File menu item above.")
   
    set(win,"add accel group",group)

enum NEW,OPEN,CLOSE,SEP1,DIRTY,SEP2,RB1,RB2,RB3,BAIL

object item = repeat(0,BAIL)
    item[NEW] = create(GtkMenuItem,"gtk-new#_New","New")
    item[OPEN] = create(GtkMenuItem,"gtk-open#_Open","Open",0,{group,"<ctl>o"})
    item[CLOSE] = create(GtkMenuItem,"gtk-close#_Close","Close",0,{group,"<ctl>w"})
    item[SEP1] = create(GtkSeparatorMenuItem)
    item[DIRTY] = create(GtkCheckMenuItem,"_Dirty","Dirty",0,{group,"<ctl>d"})
    item[SEP2] = create(GtkSeparatorMenuItem)
    item[RB1] = create(GtkRadioMenuItem,0,"One","Baz",1)
    item[RB2] = create(GtkRadioMenuItem,item[RB1],"Two","Baz",2)
    item[RB3] = create(GtkRadioMenuItem,item[RB2],"Three","Baz",3)
    item[BAIL] = create(GtkMenuItem,"gtk-quit#_Quit","BailOut",0,{group,"<ctl>q"})

    set(item[CLOSE],"sensitive",FALSE)
    set(submenu1,"append",item)
    set(menubar,"append",filemenu)
    set(filemenu,"submenu",submenu1)
    
    add(win,{group,panel})
    pack(panel,menubar)
    add(panel,lbl)
    
show_all(win)
main()

----------------------
global function New()
----------------------
    puts(1,"New menu item clicked\n")
    set(item[CLOSE],"sensitive",TRUE)
    set(item[OPEN],"sensitive",FALSE)
return 1
end function

----------------------
global function Open()
----------------------
    puts(1,"Open menu item clicked\n")
    set(item[CLOSE],"sensitive",TRUE)
    set(item[OPEN],"sensitive",FALSE)
return 1
end function

-----------------------
global function Close()
-----------------------
    puts(1,"Close menu item clicked\n")
    set(item[CLOSE],"sensitive",FALSE)
    set(item[OPEN],"sensitive",TRUE)
return 1
end function

-------------------------------
global function Dirty(atom ctl)
-------------------------------
    printf(1,"Dirty = %d\n",get(ctl,"active"))
return 1
end function

----------------------------------------
global function Baz(atom ctl, atom data)
----------------------------------------
  if get(ctl,"active") then
	printf(1,"Radio %d active\n",data)
  end if
return 1
end function

-------------------------
global function BailOut()
-------------------------
if get(item[DIRTY],"active") then
	Warn(win,"Sorry","The file is dirty","clean it up first!")
else
	Quit()
end if
return 1
end function


