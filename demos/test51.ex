
--------------------------------------------------------------------------
--# GTimeout and GIdle; tick tock...
--------------------------------------------------------------------------

include GtkEngine.e
include std/datetime.e -- requires you to namespace with gtk:

constant 
    win = create(GtkWindow,"border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    lbl1 = create(GtkLabel,"font=36,color=blue"),
    lbl2 = create(GtkLabel),
    box = create(GtkButtonBox),
    btn = create(GtkButton,"gtk-quit","Quit"),
    ticker = create(GTimeout,250,_("ticktock"))

    set(lbl2,"markup",docs()) 
    
    gtk:add(win,panel)
    gtk:add(panel,{lbl1,lbl2})
    gtk:add(box,btn)
    pack(panel,-box)

show_all(win)
main()

----------------------
function ticktock() -- updates the clock display;
----------------------
    set(lbl1,"text",datetime:format(now(),"%a %I:%M:%S %P"))
return 1 -- must return 1 to keep clock ticking!
end function

------------------
function docs() -- making this a func lets you move messy html code to bottom of program listing;
------------------
return
"""<b><u>Timeout / Idle</u></b>

Two kinds of timers are provided: the <b><i>timeout</i></b>, which calls a routine 
you supply once each x/thousands of a second, and the <b><i>idle</i></b>, which 
calls your routine as often as possible whenever GTK isn't attending 
to other things, like user clicks, window movements, etc.

This clock uses timeout, updating 4x per second to minimize 
visible 'jitter' in the time, but using less than 10% cpu time.
<span color='red'>
Changing the source to use idle instead will use 80-95% cpu!</span>
"""
end function


