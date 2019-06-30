
-------------------------------------------------------------------------
--# Drawing text with Cairo;
-- seldom worth the trouble, unless you need to add 
-- images under/over or intermixed with the text.
-------------------------------------------------------------------------

include GtkEngine.e
include GtkCairo.e
include std/math.e

constant fnt = create(PangoFontDescription,"Serif 10")

constant 
    win = create(GtkWindow,"title=`Drawing Text with Cairo`,position=1,border_width=10,$destroy=Quit"),
    panel = create(GtkBox),
    screen = create(GtkDrawingArea)

    add(win,panel)
    add(panel,screen)

show_all(win)
connect(panel,"draw","Paint")
main()

----------------------------------------------------------
global function Paint(atom ctl, atom event, atom data)
----------------------------------------------------------
atom dwin = get(screen,"window")
atom cr = create(GdkCairo_t,dwin)

    set(cr,{ -- draw a strange shape;
	{"source rgb",0,0,#ff},
	{"move to",2,2},
	{"arc",80,80,60,60, 2.0 * math:PI}, -- create shape
	{"source rgba",0.6, 0.0, 0.8, 0.2}, -- partially translucent color
	{"fill_preserve"}, -- fill shape with color, save shape
	{"color","blue"},
	{"line width",2}, -- outline
	{"stroke"}, -- draw outline around saved shape
	{"color","black"},  
	{"move to",5,5}, -- starting point for text
	$})

atom layout = create(PangoLayout,cr) 
    set(layout,{ -- draw text;
	{"font description",fnt},
	{"text",LGPL,-1},
	{"show layout",cr}})
	
object dim = get(layout,"pixel size") -- get width & height of text
 set(screen,"size request",dim[1],dim[2]) -- adjust to accomodate text
 
 set(cr,"destroy")   

return 1
end function





