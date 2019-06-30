
--------------------------------------------------------------------------------
--# GtkClipboard paste text
-------------------------------------------------------------------------------- 

include GtkEngine.e	

constant docs = `<b><u>Clipboard</u></b>
Click the Paste button to add text 
to the clipboard, or copy some from 
an editor or web browser.
`
constant win = create(GtkWindow,"size=300x200,border_width=5,position=1,$destroy=Quit")

constant panel = create(GtkBox,GTK_ORIENTATION_VERTICAL)
    add(win,panel)

constant pix = create(GtkImage,"thumbnails/clipper.png")
    add(panel,pix)

constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(panel,lbl)

constant txt = "Now is the time for all good men\nto come to the aid of the party."

constant cb = create(GtkClipboard)

constant 
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-clear","Clear"),
    btn3 = create(GtkButton,"gtk-paste","Paste"),
    box = create(GtkButtonBox)
    pack(panel,-box)
    add(box,{btn1,btn2,btn3})

show_all(win)
main()

------------------------
global function Paste()
------------------------
    set(cb,"text",txt,length(txt))
return 1
end function

-----------------------
global function Clear()
-----------------------
    set(cb,"text","\n",1)
return 1
end function





