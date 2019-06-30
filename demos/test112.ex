
--------------------------------------------------------------
--# Multiple text buffers
--------------------------------------------------------------

include GtkEngine.e

constant buff1 = create(GtkTextBuffer)
    
    set(buff1,"text",`
_____Here is text for buffer #1

    Now is the time for all good men to come
    to the aid of the party...

    You should copy/paste or type something 
    more here. You can copy/paste between 
    buffers, too.`)
    
--

constant buff2 = create(GtkTextBuffer)
	set(buff2,"text",`
____________And here is the text for buffer #2:
` & LGPL)

constant 
    win = create(GtkWindow,"size=480x300,position=1,border_width=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL,spacing=10"),
    scroller = create(GtkScrolledWindow),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"edit-paste#Buffer _1","Paste",buff1),
    btn2 = create(GtkButton,"edit-paste#Buffer _2","Paste",buff2),
    btn3 = create(GtkButton,"gtk-quit","Quit"),
    tv = create(GtkTextView,"editable=TRUE,left_margin=5,right_margin=5")
    
    set(btn1,"tooltip markup","Paste text from <b>Buffer #1</b>")
    set(btn2,"tooltip markup","Paste text from <b>Buffer #2</b>")
    
    add(win,panel)
    add(scroller,tv)
    pack(panel,scroller,TRUE,TRUE,10)
    add(box,{btn1,btn2,btn3})
    pack(panel,-box)

show_all(win)
main()

------------------------------------------------------------------------
global function Paste(atom ctl, atom whichbuffer)
------------------------------------------------------------------------
    set(tv,"buffer",whichbuffer)
return 1
end function

