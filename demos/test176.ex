
--------------------------------------------------------------------------
--# GtkToggleToolButtons
--------------------------------------------------------------------------

include GtkEngine.e

constant docs = `markup=
<u><b>ToggleToolButtons</b></u>
Click the buttons above.
`
constant 
    names = {"Clown","Dragon","Fish"},
    win = create(GtkWindow,"border=10,size=300x-1,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    bar = create(GtkToolbar),
    lbl1 = create(GtkLabel,docs),
    lbl2 = create(GtkLabel,"font=18,color=red")

object tb = repeat(0,4)

constant img1 = create(GdkPixbuf,"thumbnails/clown.png",25,25)
    tb[1]= create(GtkToggleToolButton,"1","Show",1)
    set(tb[1],"icon widget",create(GtkImage,img1))
    set(tb[1],"label","Clown")

constant img2 = create(GdkPixbuf,"thumbnails/dragon.png",25,25)
    tb[2] = create(GtkToggleToolButton,"2","Show",2)
    set(tb[2],"icon widget",create(GtkImage,img2))
    set(tb[2],"label","Dragon")

constant img3 = create(GdkPixbuf,"thumbnails/fish.png",25,25)
  tb[3] = create(GtkToggleToolButton,"3","Show",3)
  set(tb[3],"icon widget",create(GtkImage,img3))
  set(tb[3],"label","Fish")

  tb[4] = create(GtkToggleToolButton,"4","ToggleCaptions")
  set(tb[4],"label","Caps")
  
    add(win,pan)
    pack(pan,bar)
    add(bar,tb)
    add(pan,{lbl1,lbl2})
    
show_all(win)
main()

--------------------------------------------
global function ToggleCaptions(atom ctl)
--------------------------------------------
set(bar,"style",get(ctl,"active")*2)
return 1
end function

--------------------------------------------
global function Show(atom ctl, atom data)
--------------------------------------------
object txt = "", char = " "
for i = 1 to 3 do
    if get(tb[i],"active") then char = "✔" else char = " " end if
    txt &= sprintf("%s %s\n",{names[i],char})
end for
set(lbl2,"markup",txt)
return 1
end function
