
-----------------------------------------------------------------------------
--# Signal disconnect

-- Note: this shows the way to register and disconnect a signal from
-- a control. It is NOT the way to disable a control, since the  
-- appearance of the control is not altered to indicate that it is
-- disabled! For that, use set(ctl,"sensitive",FALSE).
-- The possible uses for this would be to activate a one-time use button, 
-- or to disconnect one signal and connect another, so a different function 
-- is called thereafter.
-----------------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"size=200x100,position=1,border_width=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical"),
    lbl = create(GtkLabel,"markup=<b><u>Signal Disconnect</u></b>\nClick the OK button ~ then try again!"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok")

constant sig2 = connect(btn2,"clicked",_("Foo"))

    add(win,pan)
    add(pan,lbl)
    add(box,{btn1,btn2})
    pack(pan,-box)
    
show_all(win)
main()

-------------------------
function Foo ()
-------------------------

    Info(win,"Sig Disconnect",
        sprintf("Signal id: %d",sig2),
        "this won't appear again!")

    disconnect(btn2,sig2)
    set(btn2,"tooltip markup",
        "<span color='red'><i>Sorry,</i>\n the signal has been disconnected!</span>")

return 1
end function
