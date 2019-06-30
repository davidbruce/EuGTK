
-------------------------------------------------------------------------------------
--# GtkLevelBar -- see also test50.ex
-------------------------------------------------------------------------------------

include GtkEngine.e

requires("3.07","GtkLevelBar")

constant docs = `<u><b>LevelBar</b></u>

 The GtkLevelBar is a bar widget that can be used
 as a level indicator. Typical use cases are 
 displaying the strength of a password, or 
 showing the charge level of a battery.
 <small>
 Use gtk_level_bar_set_value() to set the 
 current value, and gtk_level_bar_add_offset_value() 
 to set the value offsets at which the bar will 
 be considered in a different state. GTK will add 
 a few offsets by default on the level bar: 
 GTK_LEVEL_BAR_OFFSET_LOW, GTK_LEVEL_BAR_OFFSET_HIGH 
 and GTK_LEVEL_BAR_OFFSET_FULL, with values 0.25, 
 0.75 and 1.0 respectively.</small>
`
constant win = create(GtkWindow,"border=10,size=300x200,position=1,$destroy=Quit")

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)

constant lbl1 = add(panel,create(GtkLabel,{
    {"font","12"},
    {"markup",docs}}))

constant bar = create(GtkLevelBar,{
    {"margin-bottom",10},
    {"size request",-1,15},
    {"value",0.5}})

 add(panel,bar)

constant fmt2 = "Above, level is %.02f in a range of 0=>1"
	
constant lbl2 = add(panel,create(GtkLabel,{
    {"font","12"},
    {"markup",sprintf(fmt2,0.1)}}))
	
constant spin = create(GtkSpinButton,0,1,.01)
    set(spin,{
	{"numeric",TRUE},
	{"digits",2},
	{"value",0.5},
	{"signal","value-changed","Update"}})
	
constant  
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	box = create(GtkButtonBox,"spacing=5,margin-top=5")
	pack(panel,-box)
	add(box,{btn1,spin})

show_all(win)
main()

--------------------------------
global function Update(atom ctl)
--------------------------------
	atom x = get(ctl,"value")
	set(bar,"value",x)
	set(lbl2,"markup",sprintf(fmt2,x))
return 1
end function 

 
