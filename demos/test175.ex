
-------------------------------------------------------------------------------
--# GtkRadioToolButtons
-------------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>RadioToolButtons</b></u>
Choose 1 of several options. 
Click the buttons above.
`
constant 
    win = create(GtkWindow,"size=350x50,position=1,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical"),
    bar = create(GtkToolbar)
 
  add(win,pan)
  pack(pan,bar)
   
--note: 1st param to first radio button is null to start a new button group;
constant 
    tb1 = create(GtkRadioToolButton,0,"-","Show","Clown"), -- no caption;
    img1 = create(GdkPixbuf,"thumbnails/clown.png",25,25)
    set(tb1,"icon widget",create(GtkImage,img1))
    set(tb1,"label","Clown")

--note: 1st param to next radio button is the handle of the prev. button;
constant 
    tb2 = create(GtkRadioToolButton,tb1,"-","Show","Dragon"),
    img2 = create(GdkPixbuf,"thumbnails/dragon.png",25,25)
    set(tb2,"icon widget",create(GtkImage,img2))
    set(tb2,"label","Dragon")

constant 
    tb3 = create(GtkRadioToolButton,tb2,"-","Show","Fish"),
    img3 = create(GdkPixbuf,"thumbnails/fish.png",25,25)
    set(tb3,"icon widget",create(GtkImage,img3))
    set(tb3,"label","Fish")
    
constant tb4 = create(GtkToggleToolButton,"label=caps,$toggled=ToggleLabels")
    set(tb4,"tooltip text","Click to toggle button captions")
    
    add(bar,{tb1,tb2,tb3,tb4})

constant lbl1 = create(GtkLabel)
    set(lbl1,"markup",docs)
    add(pan,lbl1)

constant lbl2 = create(GtkLabel,"font=italic 32,color=red,text=Clown")
    add(pan,lbl2)
   
show_all(win) 
main()

----------------------------------------------
global function ToggleLabels(atom ctl)
----------------------------------------------
set(bar,"style",get(ctl,"active")*2)
return 1
end function

----------------------------------------------
global function Show(atom ctl, object name)
----------------------------------------------
    name = unpack(name)
    set(lbl2,"markup",name)
return 1
end function
