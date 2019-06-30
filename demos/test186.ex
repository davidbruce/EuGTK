
----------------------------------------------------------------------------------------
--# GtkButtonBox - child_secondary property
----------------------------------------------------------------------------------------

include GtkEngine.e
include std/io.e

constant docs = `markup=
<u><b>ButtonBox</b></u>
By combining 'layout' and 'child secondary' 
commands you can separate the Help button from
the others.

Click Help to see the code.
`

constant 
    win = create(GtkWindow,"border=10,size=400x100,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,docs),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok"),
    btn3 = create(GtkButton,"gtk-help","Help")
    
    set(btn1,"tooltip text","Click to exit")
    set(btn2,"tooltip text=This button does nothing!")
    set(btn3,"tooltip text","Click to show layout code")

    add(box,{btn1,btn2,btn3})
    set(box,"layout",GTK_BUTTONBOX_START)
    set(box,"child secondary",btn3,TRUE)
    pack(panel,-box)

    add(win,panel)
    add(panel,lbl)
    pack(panel,-box)
    
show_all(win)
main()

global function Help()
object txt = read_lines(canonical_path("~/demos/test186.ex"))
   return Info(,,"Child Secondary",join(txt[30..34],"\n"))
end function


