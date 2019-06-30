
-------------------------------------------------------------------
--# GtkClipboard (monitor program)
-------------------------------------------------------------------
-- Leave this program running, and either copy some text or an 
-- image from some other program, e.g. a web browser.
--
-- Or you may run test91 or test92, which paste,
-- respectively, some text or an image to the clipboard,
-- which will be intercepted by test100 and displayed.
-------------------------------------------------------------------

include GtkEngine.e

constant docs =  `<b><u>GtkClipboard Monitor program</u></b>
This program runs in a loop waiting for
either an image or some text to be copied
to the clipboard, then displays that data.

Run test91 and/or test92 while this program
waits, or copy an image or text from a webpage. 

`
constant cb = create(GtkClipboard) 

constant win = create(GtkWindow,
    "title=Clipboard Monitor,size=300x300,border_width=10,keep_above=TRUE,position=1,$destroy=Quit")

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)

constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(panel,lbl)

constant 
    frame1 = create(GtkFrame,"Text"),
    lbl1 = create(GtkLabel)
    add(frame1,lbl1)

constant 
    frame2 = create(GtkFrame,"Image"),
    pix2 = create(GtkImage)
    add(frame2,pix2)
 
    add(panel,{frame1,frame2})

constant 
    btnbox = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit")
    set(btnbox,"margin top",5)
    add(btnbox,btn1)
    pack(panel,-btnbox)

constant tick = create(GTimeout,500,_("WaitForCopy"))

show_all(win)
main()

-------------------------------------------
function WaitForCopy()
-------------------------------------------
atom img = get(cb,"wait for image")
if img > 0 then 
    set(pix2,"from pixbuf",img)
    return 1
end if

object txt = get(cb,"wait for text")
if string(txt) then
    set(lbl1,"text",wrap(txt,80))
    return 1
end if

return 1
end function

