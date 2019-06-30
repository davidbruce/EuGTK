
-----------------------------------------------------------------------
--# Custom Tooltips (with images, fancy fonts, etc...)
-----------------------------------------------------------------------

include GtkEngine.e

-----------------------------------------------------
-- create a custom tooltip window;
-----------------------------------------------------

constant mytip = create(GtkWindow,GTK_WINDOW_POPUP)

constant tipanel = create(GtkGrid)
    add(mytip,tipanel)
    show(tipanel)

constant tiptxt1 = `<span><u><b>Custom Tooltip</b></u>

I made this myself! 

</span>
`
constant tiptxt2 = `<span><u><b>Custom Tooltip</b></u>

I made this myself! 

Heat Level: %d (Bwa Ha Hah!)

</span>
`
constant tip = create(GtkLabel,{
    {"markup",tiptxt1},
    {"color","white"}})
    set(tipanel,"attach",tip,1,2,1,1)
    show(tip)

constant img = create(GtkImage,"face-devilish",64)
    set(tipanel,"attach",img,1,1,1,1)
    show(img)
    
constant bkgnd = create(GtkImage,"thumbnails/fire.png")
    set(tipanel,"attach",bkgnd,1,1,2,2)
    show(bkgnd)
    
-----------------------------------------------------
-- create main window;
-----------------------------------------------------
constant 
    win = create(GtkWindow,"size=300x100,border=10,$destroy=Quit"),
    pan = create(GtkBox,VERTICAL),
    scale = create(GtkScale,HORIZONTAL,0,100,1),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit")
------------------------------------------------------------
-- add scale values
------------------------------------------------------------
    constant fmt = "<span size='x-small' color='red'>%d</span>"
    constant min = 0, max = 100, step = 1
    for i = min to max by 10 do
            set(scale,"add mark",i,GTK_POS_TOP,sprintf(fmt,i))
    end for

    add(win,pan)
    add(box,btn1)
    pack(pan,-box)

    connect(scale,"value-changed",_("UpdateCustomToolTip"))
    set(scale,"value pos",GTK_POS_BOTTOM)
    set(scale,"tooltip text","-")
    set(scale,"tooltip window",mytip)
    pack(pan,scale,TRUE,TRUE)

show_all(win)
main()

------------------------------
function UpdateCustomToolTip()
------------------------------
integer heat = get(scale,"value")
set(tip,"markup",sprintf(tiptxt2,heat))
return 1
end function
