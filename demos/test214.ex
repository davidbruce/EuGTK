
--# Popover demo

include GtkEngine.e

requires("3.12","GtkPopover")

constant docs = "<b>GtkPopover</b>\n\tMove mouse over the OK button,\n\tthen choose an option!",
     win = create(GtkWindow,"size=300x250,border=10,$destroy=Quit"),
     pan = create(GtkBox,"orientation=vertical"),
     lbl = create(GtkLabel),
     box = create(GtkButtonBox),
     btn1 = create(GtkButton,"gtk-quit","Quit"),
     btn2 = create(GtkButton,"gtk-ok"),
     pop = create(GtkPopover,btn2),  
     popbox = create(GtkBox,"orientation=VERTICAL,border=10")
     
     add(popbox,create(GtkLabel,"Option"))

sequence rb = {0}
     rb &= add(popbox,create(GtkRadioButton,0,"Normal",_("SetColor"),"#D6D6D6"))
     rb &= add(popbox,create(GtkRadioButton,rb,"Red",_("SetColor"),"red"))
     rb &= add(popbox,create(GtkRadioButton,rb,"Green",_("SetColor"),"green"))
     rb &= add(popbox,create(GtkRadioButton,rb,"Blue",_("SetColor"),"blue"))
     rb &= add(popbox,create(GtkRadioButton,rb,"About",_("About")))
 
  add(win,pan)
  add(pop,popbox)
  add(btn2,pop)
  add(box,{btn1,btn2})
  add(pan,lbl)
  pack_end(pan,box)
  
  set(lbl,"markup",docs)
  set(pop,"transitions enabled",TRUE)
  connect(btn2,"enter",_("popup"))

show_all(win)
main()

-------------------
function popup() --
-------------------
 show_all(pop)
return 1
end function

--------------------------------------------
function SetColor(atom ctl, object color) --
--------------------------------------------
 set(win,"background",unpack(color))
return 1
end function

---------------------------
function About(atom ctl) --
---------------------------
if get(ctl,"active") then

 Info(win,"About",
 `<b>GtkPopover</b>`,
 `
 A bubble-like context window, 
 primarily meant to provide context-dependent information 
 or options. Popovers are attached to a widget, passed at 
 construction time on gtk_popover_new(), or updated afterwards 
 through gtk_popover_set_relative_to()...
 
 `,,"thumbnails/gtk-logo-rgb.gif")
 end if
 return 1
end function
