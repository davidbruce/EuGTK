
-----------------------------------------------------------------
--# GtkFlowBox - new
-----------------------------------------------------------------

include GtkEngine.e

requires("3.12","GtkFlowBox")

constant 
     win = create(GtkWindow,"title=FlowBox - RESIZE ME!,border=10,position=center,$destroy=Quit"),
     fb = create(GtkFlowBox,"orientation=horizontal,homogeneous=FALSE")
     
     add(win,fb)
     
sequence obj = repeat(0,4)
    obj[1] = create(GtkImage,"thumbnails/clown.png")
    obj[2] = create(GtkImage,create(GdkPixbuf,"thumbnails/eugtk.png",100,0,1))
    obj[3] = create(GtkSpinButton,0,10,1)
    obj[4] = create(GtkButtonBox)
add(fb,obj)

add(obj[4],create(GtkButton,"gtk-quit","Quit"))
add(obj[4],create(GtkButton,"gtk-about","ShowDocs"))
     
show_all(win)
main()

--------------------------
global function ShowDocs()
--------------------------
Info(,"FlowBox",    
"A GtkFlowBox",
`positions child widgets in sequence 
 according to its orientation.

 For instance, with the horizontal orientation, 
 the widgets will be arranged from left to right, 
 starting a new row under the previous row when 
 necessary. Reducing the width in this case will 
 require more rows, so a larger height will be 
 requested.

 Likewise, with the vertical orientation, 
 the widgets will be arranged from top to bottom, 
 starting a new column to the right when necessary. 
 Reducing the height will require more columns, 
 so a larger width will be requested.

 The children of a GtkFlowBox can be dynamically 
 sorted and filtered.`,,"thumbnails/gtk-logo-rgb.gif")

return 1
end function
