
-----------------------------------------------------------------------------
--# GtkSearchBar -- type a word which appears in the text;
-----------------------------------------------------------------------------

include GtkEngine.e
include GtkEvents.e

requires("3.10","GtkSearchBar")

ifdef WINDOWS then
	Error(,"Sorry","GtkSearchBar","Is not functional in Windows")
end ifdef

constant hdr = "<span font='bold 16'><u>GtkSearchBar</u></span>\n"

constant txt = 
"""
 A container made to have a search entry 
 (possibly with additional widgets, 
 such as drop-down menus, or buttons) 
 built-in. 
 
 The search bar would appear when a search 
 is started through typing on the keyboard, 
 or the application's search mode is toggled on.

For keyboard presses to start a search, 
events will need to be forwarded from the 
top-level window that contains the search bar. 
See gtk_search_bar_handle_event() for example code. 
Common shortcuts such as Ctrl+F should be handled 
as an application action, or through the menu items.

Type a word which appears in the text above to 
highlight all matching words. Hit esc key to hide
the search bar.

"""

constant 
     win = create(GtkWindow,"border=10,size=500x100,$key-press-event=onClick,$destroy=Quit"),
     pan = create(GtkBox,"orientation=vertical,spacing=10"),
     srch = create(GtkSearchEntry,"name=srch"),
     bar = create(GtkSearchBar,"show close button=TRUE"),
     cap = create(GtkLabel),
     lbl = create(GtkLabel),
     box = create(GtkButtonBox),
     btn1 = create(GtkButton,"gtk-quit","Quit")
     
     set(cap,"markup",hdr)
     set(lbl,"markup",txt)
     
     set(bar,"connect entry",srch)
     connect(srch,"search-changed","ShowText")

     add(win,pan)
     add(pan,{bar,cap,lbl})
     add(bar,srch)
     add(box,btn1)
     pack(pan,-box)

show_all(win)
main()

------------------------------------------------
global function onClick(atom ctl, atom event) -- detect keypresses in window;
------------------------------------------------
return get(bar,"handle event",event)
end function

-------------------------------------
global function ShowText(atom ctl) -- simple way to highlight found text;
-------------------------------------

object st = get(ctl,"text") -- search term;

object t = get(lbl,"text") -- current text;

if length(st) > 1 then
    t = split(t,st)
    set(lbl,"markup",flatten(t,sprintf("<b><span underline='double' color='blue'>%s</span></b>",{st}))) -- bold it;
else
    set(lbl,"markup",txt) -- restore original;
end if

return 1
end function
