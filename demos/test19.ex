
-------------------------------------------------------------------------------------------------------
--# Test all buttons
-------------------------------------------------------------------------------------------------------

include GtkEngine.e

constant theme = create(GtkIconTheme) -- search for icon png's here;
  
constant win = create(GtkWindow,
    "title=`Test Buttons`,position=1,border=10,$destroy=Quit")

sequence b = { -- top row captions;
    create(GtkLabel,"markup=`<b>Button Styles</b>`"),
    create(GtkLabel,"Plain"),
    create(GtkLabel,"Stock"),
    create(GtkLabel,"Custom"),
    create(GtkLabel,"Themed"),
    create(GtkLabel,"Button"),
    
    create(GtkButton,"_OK"), -- first row of buttons;
    create(GtkButton,"gtk-ok"),
    create(GtkButton,"~/demos/thumbnails/pie.png#_Pie"),
    create(GtkButton,"face-smile-big#_Happy"),
    
    create(GtkLabel,"Toggle"), -- second row buttons;
    create(GtkToggleButton,"_OK"),
    create(GtkToggleButton,"media-record#_Record"),
    create(GtkToggleButton,"~/demos/thumbnails/cake.png#_Cake"),
    create(GtkToggleButton,"face-cool#_Cool"),
    $}
    
sequence cb = repeat(0,5) -- check buttons;
    cb[1] = create(GtkLabel,"Check")
    cb[2] = create(GtkCheckButton,"_OK")
    cb[3] = create(GtkCheckButton,"gtk-yes#_Yes")
    cb[4] = create(GtkCheckButton,"~/demos/thumbnails/fox.png#_Fox")
    cb[5] = create(GtkCheckButton,"face-surprise#_Oops!")

    b &= cb
    
sequence rb = repeat(0,10) -- radio buttons;
    rb[1] = create(GtkLabel,"Radio")
    rb[2] = create(GtkRadioButton,0,"_OK")
    rb[3] = create(GtkRadioButton,rb[2],"system-run#_Exec")
    rb[4] = create(GtkRadioButton,rb[3],"thumbnails/mouse.png#_Mouse")
    rb[5] = create(GtkRadioButton,rb[4],"face-laugh#_Laugh")
    
    b &= rb

constant grid = create(GtkGrid,{{"row spacing",5},{"column spacing",4}})

integer i = 1
for y = 1 to 6 do
    for x = 1 to 5 do
	    if b[i] > 0 then
		if b[i] > 0 then
		    set(grid,"attach",b[i],x,y,1,1)
		end if
	    end if
        i += 1
    end for
end for
 
constant lbl = create(GtkLabel,{{"markup","<b>Appearance</b>"}}),
	btn1 = create(GtkRadioButton,0,"Mode _0","SetMode",1),
	btn2 = create(GtkRadioButton,btn1,"Mode _1","SetMode",0),
	lbl2 = create(GtkLabel,"Appearance applies to Check buttons and Radio buttons only.")
	
	set(btn2,"tooltip text","Makes all look like buttons")
	set(btn1,"tooltip text","Selects normal appearance") 
	
	set(grid,{
	    {"attach",lbl,1,7,2,1},  -- mode 1
	    {"attach",btn2,3,7,1,1}, -- (Appearance)
	    {"attach",btn1,4,7,1,1},  -- mode  0
	    {"attach",lbl2,1,8,5,1}}) -- (appearance applies...)
	
	set(grid,{
	    {"insert row",2}, -- add decorations;
	    {"attach",create(GtkSeparator),1,2,5,1},
	    {"insert column",2},
	    {"attach",create(GtkSeparator,1),2,2,1,6},
	    {"insert row",6}, 
	    {"attach",create(GtkSeparator),1,8,6,1}
	    })
    
add(win,grid)
	
show_all(win)
main()

--------------------------------------------------
global function SetMode(atom ctl, integer mode) -- appearance mode;
--------------------------------------------------
    for i = 2 to 5 do
	set(cb[i],"mode",mode)
        set(rb[i],"mode",mode)
    end for
return 1
end function
