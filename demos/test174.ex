
-----------------------------------------------------------------------------------------
--# GtkEntry with icons
-----------------------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>Entry with Icons</b></u>
enter some text in the box, then click on 
either of the icons at left or right.
Left clears the entry, right converts to upper case.

You can use one, both, or none.
`
constant win = create(GtkWindow,"size=300x100,border=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)

constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(panel,lbl)

constant inp = create(GtkEntry,{
    {"icon from icon name",0,"edit-delete"},
    {"icon tooltip text",0,"Clear"},
    {"icon from stock",1,"gtk-go-up"},
    {"icon tooltip text",1,"To Upper Case"},
    {"margin bottom",5},
    {"connect","icon-press","Bar"}})
    add(panel,inp)

constant 
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","Foo")
    add(box,{btn1,btn2})
    pack(panel,-box)

show_all(win)
main()

------------------------------------------------
global function Foo()
------------------------------------------------
    object txt = get(inp,"text") 
	Info(win,,"You entered:",txt)
return 1
end function

------------------------------------------------
global function Bar(atom ctl, integer icon_pos)
------------------------------------------------
    if icon_pos = 0 then
	set(ctl,"text","")
    else
	set(ctl,"text",upper(get(ctl,"text"))) 
    end if
return 1
end function
