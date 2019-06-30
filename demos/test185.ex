
--------------------------------------------------------------------------------
--# New style color chooser
--------------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>ColorChooserDialog</b></u> 
returns color as 'rgba(R,G,B,A)' string
`
if minor_version < 4 then
    Error(0,"Sorry","GtkColorChooserDialog",
	"Requires GTK version 3.4+",,"face-crying",6)
end if

constant win = create(GtkWindow,{
    {"position",GTK_WIN_POS_CENTER},
    {"border width",10},
    {"signal","destroy","Quit"}})
	
constant panel = create(GtkBox,VERTICAL)
    add(win,panel)

constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(panel,lbl)

constant 
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-select-color","Foo"),
    box = create(GtkButtonBox)
    add(box,{btn1,btn2})
    pack(panel,-box)

constant ccd = create(GtkColorChooserDialog,{
    {"transient for",win},
    {"title","Select a color"},
    {"use alpha",TRUE}})

show_all(win)
main()

-----------------------
global function Foo()
-----------------------
object color
if get(ccd,"run") = MB_OK then
    color = get(ccd,"rgba",6) 
    Info(win,"Color Chooser","You chose color",color)
    set(win,"background",color)
end if
set(ccd,"hide")
return 1
end function

