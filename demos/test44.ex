
----------------------------------------------------------------------------
--# GtkFixed: <span color='red'>deprecated</span> 
----------------------------------------------------------------------------

include GtkEngine.e

constant note = `This looks bad - on purpose!
You should only use fixed layouts for special cases,
<b><i>not</i></b> for designing normal windows.
It's unfriendly to users who may want to resize windows, 
or who need a different font size, etc...`

constant 
    win = create(GtkWindow,"background=skyblue,border_width=10,size=300x300,position=1,$destroy=Quit"),
    panel = create(GtkLayout,"size=300x300"),
    lbl1 = create(GtkImage,"thumbnails/jeff.jpg"),
    btn1 = create(GtkButton,"gtk-help",_("Foo")),
    btn2 = create(GtkButton,"gtk-quit","Quit")

constant sizer = create(GtkSizeGroup,{
    {"mode",GTK_SIZE_GROUP_BOTH},
    {"add widget",btn1},
    {"add widget",btn2}})

    add(win,panel)
    set(panel,"put",lbl1,10,10)
    set(panel,"put",btn1,25,5)
    set(panel,"put",btn2,32,30)
    
show_all(win)
main()

--------------------------------------------------
function Foo()
--------------------------------------------------
    Info(win,"OK","<u>GtkLayout</u>\n",note)
return 1
end function
