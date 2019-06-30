
----------------------------------------------------------------------------------
--# More Graphics, demos translucency, resizing;
----------------------------------------------------------------------------------

include GtkEngine.e
include GtkCairo.e
include std/math.e

constant win = create(GtkWindow,{
    {"title","Resize Me!"},
    {"default size",300,300},
    {"position",GTK_WIN_POS_CENTER},
    {"border width",0},
    {"background",#DBDBDB},
    {"add events",GDK_BUTTON_PRESS_MASK},
    {"app paintable",TRUE},
    {"connect","destroy","Quit"}})
    
constant box = add(win,create(GtkBox,VERTICAL))

constant screen = create(GtkDrawingArea)
    pack(box,screen,TRUE,TRUE)

connect(box,"draw","Paint") -- re-do as needed;

show_all(win)
atom dwin = get(screen,"window") -- for use in Paint func;
main()

----------------------------------------------------------
global function Paint(atom ctl, atom event, atom data)
----------------------------------------------------------
atom cr = create(GdkCairo_t,dwin) 

object size = get(win,"size") - {0,40} -- allow for window header, etc
integer width = size[1]
integer height = size[2]
integer lesser = min(size)

-- coordinates for the center of the window;
  atom xc = width / 2
  atom yc = height / 2
  
-- clear previous drawing;  
 set(cr,{ 
  {"source rgb",0.86,0.86,0.86}, -- a neutral gray;
  {"paint"},

  {"source rgb",0,0,0}, -- outine the 3 shapes in black
  {"set_line_width",lesser * 0.02}, -- outline thickness increases with window size
  {"save"},

-- first draw a simple arc;
  {"arc",width / 3.0, height / 4.0, lesser / 4.0, -(PI / 5.0), PI},
  {"close_path"},   -- line back to start point
  {"source_rgb",0.0, 0.8, 0.0},
  {"fill_preserve"}, -- fill with color, save shape
  {"restore"},  -- back to opaque black
  {"stroke"},   -- outline shape

-- now draw a circle;
  {"save"},
  {"arc",xc, yc, lesser / 4.0, 0.0, 2.0 * PI}, -- full circle
  {"source rgba",0.6, 0.0, 0.8, 0.6},    -- partially translucent
  {"fill_preserve"},
  {"restore"},  -- back to opaque black
  {"stroke"},
  {"save"}})

-- and an ellipse;
  atom ex, ey, ew, eh
 -- center of ellipse
	ex = xc
	ey = 3 * height / 4
 -- ellipse dimensions
	ew = 3 * width / 4
	eh = height / 3
	
 set(cr,{
  {"translate",ex, ey},         
  {"scale",ew / 2.0, eh / 2.0},   

  {"arc",0, 0, 1, 0, 2 * PI},  -- centered at (0, 0)
  {"source rgba",0.8, 0, 0, 0.7},
  {"fill_preserve"}, -- fill with color, save shape
  {"restore"},  -- back to opaque black
  {"stroke"}, -- outline the shape
  {"destroy"}})
  
return 1
end function



