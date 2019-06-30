
-------------------------------------------------------------------------
--# GtkLevelBar 
-------------------------------------------------------------------------

include GtkEngine.e

requires("3.6","GtkLevelBar")

constant docs = `
The GtkLevelBar is a bar widget that can be used 
as a level indicator. Typical use cases are 
displaying the strength of a password, 
or showing the charge level of a battery.
Colors and steps are adjustable.
`
constant 
     win = create(GtkWindow,"size=380x200,border=10,$destroy=Quit"),
     panel = create(GtkBox,"orientation=VERTICAL,spacing=10"),
     hdr = create(GtkLabel,"markup=<u><b>GtkLevelBar</b></u>"),
     lbl = create(GtkLabel,"Move the slider!"),
     box = create(GtkButtonBox),
     btn1 = create(GtkButton,"gtk-quit","Quit"),
     btn2 = create(GtkCheckButton,"Discrete","ChangeMode"),
     btn3 = create(GtkButton,"gtk-help","Help")
     
constant lbar = create(GtkLevelBar)
	 set(lbar,{
	       {"name","Levelbar"},
		{"size request",-1,20},
		{"min value",0},
		{"max value",10},
		{"value",5},
		{"add offset value","low",3.0},
		{"add offset value","my-offset",5.00},
		{"add offset value","high",7.00}})
	
constant scale = create(GtkScale,HORIZONTAL,0,10,0.001)
	 set(scale,"digits",2)
	 set(scale,"value",5)
	 connect(scale,"value changed","Update")

     add(win,panel)
     add(panel,{hdr,lbar,scale,lbl})
     add(box,{btn1,btn2,btn3})
     pack(panel,-box)
     
show_all(win)
main()

-------------------------
global function Update()
-------------------------
     set(lbar,"value",get(scale,"value"))
return 1
end function

-------------------------------------
global function ChangeMode(atom ctl)
-------------------------------------
     set(lbar,"mode",get(ctl,"active"))
return 1
end function

------------------------
global function Help()
------------------------
  Info(win,"Help","GtkLevelBar\n",
     `
      This widget can be used as a level indicator. 
      Typical use cases are displaying the strength 
      of a password, or showing the charge level of 
      a battery.
     
      Colors and steps are adjustable.
`,,"thumbnails/gtk-logo-rgb.gif")
return 1
end function
