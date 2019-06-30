
--------------------------------------------------------------
--# UTF 8 demo
-- displays various ways to enter text;
--------------------------------------------------------------

include GtkEngine.e

object lbl = repeat(0,5)

-- the hard way:
lbl[1] = create(GtkLabel,"Gr\xC3\xBC\xC3\x9F Gott - esc. UTF-8: \xC2\xA9")

-- easier - pasted from text editor or web page:
lbl[2] = create(GtkLabel,"Fußbälle - direct UTF-8: ©")

-- using Eu's UTF string notation;
lbl[3] = create(GtkLabel,u"47 72 C3 BC C3 9F 20 47 6F 74 74 20 C2 A9")

-- more examples of direct paste from editor;
lbl[4] = create(GtkLabel,"Привет мир")

lbl[5] = create(GtkLabel,"こんにちは世界")

constant 
    win = create(GtkWindow,"size=300x100,position=1,border_width=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    box = create(GtkButtonBox,"margin-top=10"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkSpinButton,1,5,1,5),
    btn3 = create(GtkButton,"gtk-ok","Show"),
    inp = create(GtkEntry,{
    {"text",get(lbl[1],"text")},
    {"font","mono 14"}})
    
    connect(btn2,"value-changed","Update")
    
    add(win,panel)
    add(panel,lbl)
    add(panel,inp)
    add(box,{btn1,btn2,btn3})
    pack(panel,-box)

show_all(win)
main()

---------------------------
global function Update()
---------------------------
integer i = get(btn2,"value")
set(inp,"text",get(lbl[i],"text"))
return 1
end function

-------------------------
global function Show()
-------------------------
integer i = get(btn2,"value")
object txt = get(inp,"text")
object fmt = flatten(repeat("[:02X] ",length(txt))) 
Info(win,sprintf("Label %d",i),txt,format(fmt,txt))
return 1
end function

