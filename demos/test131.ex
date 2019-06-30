
-----------------------------------------------------------------------------
--# GtkExpander
-----------------------------------------------------------------------------

include GtkEngine.e

constant 
    gpl = split(LGPL,"\n\n"),
    docs = "markup=<b>LGPL ~ GNU Lesser General Public License version 3.0</b>\n",
    sep = create(GtkSeparator,"margin=10"),
    win = create(GtkWindow,"size=460x400,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=VERTICAL"),
    lbl = create(GtkLabel,docs),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkToggleButton,"Expand All","Expand"),
    box = create(GtkButtonBox,"margin top=5"),
    css = create(GtkCssProvider,"GtkFrame {border-radius:6px; background-color:lightyellow;}")
    
    set(btn2,"tooltip text","Click to expand all paragraphs")

object exp = repeat(0,4)
object frm = repeat(0,4)
object lgpl = repeat(0,4)

for i = 1 to 4 do

    exp[i] = create(GtkExpander,{
        {"use markup",TRUE},
        {"label",sprintf("<span color='blue'><small>Paragraph %d</small></span>",i)},
        {"tooltip text",sprintf("Click to expand paragraph %d",i)}})
       
    frm[i] = create(GtkFrame)
    
    lgpl[i] = create(GtkLabel,{
        {"markup",gpl[i]},
        {"line wrap",FALSE},
        {"width chars",40},
        {"justify",GTK_JUSTIFY_LEFT},
        {"padding",1}})
        
    set(exp[i],"label fill",FALSE)
    add(exp[i],frm[i])
    add(frm[i],lgpl[i])
    set(exp[i],"halign",GTK_ALIGN_START)
    
end for

    add(win,pan)
    add(pan,{lbl,sep})
    pack(pan,exp)
    add(box,{btn1,btn2})
    pack(pan,-box)

show_all(win)
set(win,"restore")
main()

-----------------------------------
global function Expand(atom ctl)
-----------------------------------
integer x = 0
integer ct = 0
for i = 1 to 4 do
	x = get(ctl,"active") 
    set(exp[i],"expanded",x) 
end for
return 1
end function

 
