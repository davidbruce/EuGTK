
----------------------------------------------------------------------
--# Menus, accelerators
----------------------------------------------------------------------

include GtkEngine.e

constant 
    win  = create(GtkWindow,"size=300x100,$destroy=Quit"),
    group = create(GtkAccelGroup),
    panel = create(GtkBox,"orientation=VERTICAL,spacing=10"),
    lbl = create(GtkLabel,"markup=<u><b>Menus</b></u>\n" &
        "Please run this from an x-term so you can see\n"&
        "the results when selecting a menu item."),
    menubar = create(GtkMenuBar),
    filemenu = create(GtkMenuItem,"_File"),
    submenu1 = create(GtkMenu),
    hr = create(GtkSeparator)

    add(win,group) -- must add group to parent window before assigning accel keys like <ctl>Q;
    
enum OPEN,CLOSE,S1,DIRTY,S2,ONE,TWO,THREE,S3,BAIL

sequence f  = repeat(0,BAIL)
    f[OPEN] = create(GtkMenuItem,"_Open","fOpen")
    f[CLOSE] = create(GtkMenuItem,"_Close","fClose")
    f[S1] = create(GtkSeparatorMenuItem)
    f[DIRTY] = create(GtkCheckMenuItem,"_Dirty","fDirty")
    f[S2] = create(GtkSeparatorMenuItem)
    f[ONE] = create(GtkRadioMenuItem,NULL,"One","ShowButtonID",1)
    f[TWO] = create(GtkRadioMenuItem,f[6],"Two","ShowButtonID",2)
    f[THREE] = create(GtkRadioMenuItem,f[7],"Three","ShowButtonID",3)
    f[S3] = create(GtkSeparatorMenuItem)
    f[BAIL] = create(GtkMenuItem,"_Quit","Bail",0,{group,"<Ctl>q"})
        
    set(f[CLOSE],"sensitive",FALSE)
    set(submenu1,"append",f)

    set(f[OPEN],"tooltip text","Open a file (Radio Menu Item)")
    set(f[CLOSE],"tooltip text","Close file (Radio Menu Item)")
    set(f[DIRTY],"tooltip text","Dirty flag (Check Menu Item)")
    set(f[ONE],"tooltip text","Radio button 1")
    set(f[TWO],"tooltip text","Radio button 2")
    set(f[THREE],"tooltip text","Radio button 3")
    set(f[BAIL],"tooltip text","Menu Item with Accel")
    set(lbl,"margin",10)
    
    add(win,panel)
    pack(panel,menubar) -- pack, not add!
    pack(panel,hr)
    set(menubar,"append",filemenu)
    set(filemenu,"submenu",submenu1)
    add(panel,lbl)
    
show_all(win)
main()

-----------------------
global function fOpen()
-----------------------
    puts(1,"Open menu item clicked\n")
    set(f[CLOSE],"sensitive",TRUE)
    set(f[OPEN],"sensitive",FALSE)
return 1
end function

------------------------
global function fClose()
------------------------
    puts(1,"Close menu item clicked\n")
    set(f[CLOSE],"sensitive",FALSE)
    set(f[OPEN],"sensitive",TRUE)
return 1
end function

--------------------------------
global function fDirty(atom ctl)
--------------------------------
    printf(1,"Dirty = %d\n",get(ctl,"active"))
return 1
end function

------------------------------------------
global function ShowButtonID(atom ctl, atom id)
------------------------------------------
    if get(ctl,"active") then
        printf(1,"Radio %d active\n",id)
    end if
return 1
end function

----------------------
global function Bail()
----------------------
    if get(f[DIRTY],"active") then
        Warn(win,"Sorry","The file is dirty","clean it up first!")
    else
        Quit()
    end if
return 1
end function
