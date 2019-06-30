
--# Popup panel <span color='red'>New in EuGTK 4.14.4</span>

-- not like a tooltip, it doesn't show automatically.
-- not like a message box, it's not modal.

include GtkEngine.e

constant
    win = create(GtkWindow,"size=150x50,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    popwin = create(GtkWindow,GTK_WINDOW_POPUP),
    poppan = create(GtkBox,"orientation=horizontal,border=10"),
    popimg = create(GtkImage,"thumbnails/mongoose.png",30,30),
    poplbl = create(GtkLabel,"color=yellow,markup=Some <b>popup</b> information here"),
    box = create(GtkButtonBox,"spacing=10"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkToggleButton,"gtk-ok#Pop","PopupWin")

add(popwin,poppan)
add(poppan,{popimg,poplbl})
set(popwin,"background","blue")
set(popwin,"position",{400,300})
set(btn2,"tooltip text","Click to show pop up")
add(win,pan)
add(box,{btn1,btn2})
pack(pan,box)
show_all(win)
main()

-------------------------------------
global function PopupWin(atom ctl) --
-------------------------------------
if get(ctl,"active") then
    set(popwin,"position",get(win,"position")+{-160,-30}) -- follow window;
    show_all(popwin)
    set(btn2,"tooltip text","Click to hide popup")
else
    hide(popwin)
    set(btn2,"tooltip text","click to show popup")
end if
return 1
end function
