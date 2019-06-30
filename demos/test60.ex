
-----------------------------------------------------------------------------
--# Drawing with Cairo
------------------------------------------------------------------------------
-- At first glance, this looks horribly complicated, but  
-- each of the 15 drawing shapes only require 10 to 20 lines
-- of code. Cut and paste the one(s) you need.
------------------------------------------------------------------------------

include GtkEngine.e
include GtkCairo.e
include std/math.e

constant 
    win = create(GtkWindow,"icon=applications-graphics,size=900x600,border=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl = create(GtkLabel,"markup=<b><u>Drawing with Cairo</u></b> \t\t" &
	"Original code for these objects was created by Øyvind Kolås, and put in the public domain."),
    hr = create(GtkSeparator),
    screen = create(GtkDrawingArea,"background=white,size request=900x500"),
    box = create(GtkBox,VERTICAL),
    sep = create(GtkSeparator,"margin bottom=5"),
    btnbox1 = create(GtkButtonBox,"layout=5"), -- 5 = GTK_BUTTONBOX_CENTER
    btnbox2 = create(GtkButtonBox,"layout=5"),
    btnbox3 = create(GtkButtonBox,"layout=5")

object btn = { -- an array of buttons to draw various shapes;
    create(GtkButton,"thumbnails/paint.png#Paint","Paint"),
    create(GtkButton,"thumbnails/arc.png#Arc","Arc"),
    create(GtkButton,"thumbnails/arcneg.png#Arc neg","ArcNeg"),
    create(GtkButton,"thumbnails/clip.png#Clip","Clip"),
    create(GtkButton,"thumbnails/image.png#Image","ClipImg"),
    create(GtkButton,"thumbnails/roundrect.png#Round Rect","RoundedRect"),
    create(GtkButton,"thumbnails/linecap.png#LineCap","LineCap"),
    create(GtkButton,"thumbnails/curveto.png#Curve to","CurveTo"),
    create(GtkButton,"thumbnails/pattern.png#Pattern","ImagePattern"),
    create(GtkButton,"thumbnails/fands.png#Fill and Stroke","FillandStroke"),
    create(GtkButton,"thumbnails/fillstyle.png#Fill Style","FillStyle"),
    create(GtkButton,"thumbnails/gradient.png#Gradient","Gradient"),
    create(GtkButton,"thumbnails/linejoin.png#Line Join","LineJoin"),
    create(GtkButton,"Hello","Hello"),
    create(GtkButton,"G'Day","GoodDay"),
    create(GtkButton,"gtk-save","Save"),
    create(GtkButton,"gtk-clear","Clear"),
    create(GtkButton,"gtk-quit","Quit")
    }

 set(btn[16],"tooltip text","Click to save the image in your home directory")
 
    add(btnbox1,btn[1..7])
    add(btnbox2,btn[8..13])
    add(btnbox3,btn[14..18])

    add(win,panel)
    add(box,screen)
    add(panel,{lbl,hr,box})
    pack(panel,{sep,-btnbox3,-btnbox2,-btnbox1})
    
show_all(win)
main()

------------------------------------------------------------------------
global function Clear()
------------------------------------------------------------------------
atom cr = create(GdkCairo_t,get(screen,"window"))
    set(cr,{
	{"source rgba",255,255,255,255},
	{"operator",CAIRO_OPERATOR_SOURCE},
	{"paint"}})
return 1
end function

-----------------------------------------------------------------------------------
global function Save() -- convert current drawing to image file
-----------------------------------------------------------------------------------
atom cr = create(GdkCairo_t,get(screen,"window"))
atom surf = get(cr,"target") 

ifdef WINDOWS then
	return Error(win,"Sorry",
		"Cannot write png files on Windows",
		"Don't know why.",GTK_BUTTONS_OK)
end ifdef

    get(surf,"write to png","image_from_test60.png")
    
return 1
end function

--------------------------------------------------------------------------
global function Paint(atom ctl, atom event, atom data)
--------------------------------------------------------------------------
atom cr = create(GdkCairo_t,get(screen,"window")) -- DRAWING CONTEXT

atom pat = create(CairoLinearGradient,100,200,200,100) -- FILL PATTERN
    set(pat,{
	{"add color stop rgba",0, 0,0,0,1},
	{"add color stop rgba",1, 1,0,0,1}})

atom surf = get(cr,"target") 
    set(cr,{
    -- TEXT
	{"translate",160,-80},
	{"source rgb",#FF,0,0},
	{"move to",200,200},
	{"show text","Hello World!"},
    -- SHAPE
	{"move to",100,200},
	{"curve to",100,100,100,100,200,100},
	{"curve to",200,200,200,200,100,200},
	{"close path"},
	{"save"}})
    
    -- FILL SHAPE WITH PATTERN
    set(cr,{
	{"source",pat},
	{"fill preserve"}})

    -- DRAW BORDER AROUND PATTERN
    set(cr,{
	{"source rgb",0,0,0},
	{"line width",3},
	{"stroke"}})

    -- CLEAN UP
    set(cr,"destroy") 
    set(pat,"destroy")
 
return -1
end function

------------------------------------------------------------------------
global function Arc()
------------------------------------------------------------------------
atom xc = 128.0
atom yc = 128.0
atom radius = 100.0

-- angles are specified in radians
atom angle1 = 45.0 * DEGREES_TO_RADIANS
atom angle2 = 180.0 * DEGREES_TO_RADIANS

atom cr = create(GdkCairo_t,get(screen,"window")) 
 
 set(cr,{
    {"line width",10.0},
    {"translate",20,40},
    {"arc", xc, yc, radius, angle1, angle2},
    {"stroke"},

-- draw helping lines 
    {"source rgba", 1, 0.2, 0.2, 0.6},
    {"line_width",6.0},

    {"arc",xc, yc, 10.0, 0, math:TWOPI},
    {"fill"},

    {"arc",xc, yc, radius, angle1, angle1},
    {"line to", xc, yc},
    {"arc", xc, yc, radius, angle2, angle2},
    {"line to", xc, yc},
    {"stroke"}})

 set(cr,"destroy")
 
return 1
end function

------------------------------------------------------------------------
global function ArcNeg(atom ctl)
------------------------------------------------------------------------
atom xc = 128.0
atom yc = 128.0
atom radius = 80.0

-- angles are specified in radians
atom angle1 = 45.0 * DEGREES_TO_RADIANS
atom angle2 = 180.0 * DEGREES_TO_RADIANS

atom cr = create(GdkCairo_t,get(screen,"window")) 

 set(cr,{
    {"translate",1,-30},
    {"line width",10.0},
    {"arc negative", xc, yc, radius, angle1, angle2},
    {"stroke"},

-- draw helping lines 
    {"source rgba", 1, 0.2, 0.2, 0.6},
    {"line_width",6.0},

    {"arc",xc, yc, 10.0, 0, math:TWOPI},
    {"fill"},

    {"arc",xc, yc, radius, angle1, angle1},
    {"line to", xc, yc},
    {"arc", xc, yc, radius, angle2, angle2},
    {"line to", xc, yc},
    {"stroke"}})
 
 set(cr,"destroy")
 
return 1
end function

------------------------------------------------------------------------
global function Clip()
------------------------------------------------------------------------
atom cr = create(GdkCairo_t,get(screen,"window"))

 set(cr,{
    {"translate",180,100},
    {"arc", 128.0, 128.0, 76.8, 0, math:TWOPI}, -- full circle
    {"clip"},

    {"new path"},  -- current path is not consumed by cairo_clip() 
    {"rectangle", 0, 0, 256, 256},
    {"fill"},
    {"color",#00FF00}, -- bright green
    {"move to", 0, 0},
    {"line to", 256, 256},
    {"move to", 256, 0},
    {"line to", 0, 256},
    {"line width", 10.0},
    {"stroke"}})
 set(cr,"destroy")

return 1
end function

------------------------------------------------------------------------
global function ClipImg()
------------------------------------------------------------------------
atom cr = create(GdkCairo_t,get(screen,"window"))
atom surf = get(cr,"target") 
atom image = create(CairoImageSurface,"thumbnails/MorningRain.png")
integer w = get(image,"width"), h = get(image,"height")

-- clip image to a circle;
 set(cr,{
    {"translate",350,100},
    {"arc", 128.0, 128.0, 76.8, 0, math:TWOPI},
    {"clip"},
    {"new path"}, -- path not consumed by clip()

    {"scale", 256/w, 256/h},
    {"source surface", image, 0, 0},
    {"paint"},
    {"paint"}, -- ? don't know why
    {"destroy"}})

return 1
end function

------------------------------------------------------------------------
global function RoundedRect()
------------------------------------------------------------------------
atom x          =  25.6,    -- rectangle 
     y          =  25.6,
     width      = 204.8,
     height     = 204.8,
     aspect     =   1.0,    -- aspect ratio 
     corner_radius = height / 5.0  -- corner curvature radius 

atom radius = corner_radius / aspect
atom degrees = math:PI / 180.0
atom cr = create(GdkCairo_t,get(screen,"window"))
        
  set(cr,{
    {"translate",420,-10},
    {"new sub path"},
    {"arc", x+width-radius, y+radius, radius, -90*degrees, 0*degrees},
    {"arc", x+width-radius, y+height-radius, radius, 0*degrees, 90*degrees},
    {"arc", x+radius, y+height-radius, radius, 90*degrees, 180*degrees},
    {"arc", x+radius, y+radius, radius, 180*degrees, 270*degrees},
    {"close path"},

    {"source rgb", 0.5, 0.5, 1},
    {"fill preserve"},
    {"source rgba",0.5, 0, 0, 0.5},
    {"line width", 10.0},
    {"stroke"}})
  
  set(cr,"destroy")
  
return 1
end function

------------------------------------------------------------------------
global function LineCap()
------------------------------------------------------------------------
atom cr = create(GdkCairo_t,get(screen,"window"))

 set(cr,{
    {"translate",410,-10},
    {"line width",30.0},
    {"line cap", CAIRO_LINE_CAP_BUTT}, 
    {"move to", 64.0, 50.0},
    {"line to", 64.0, 200.0},
    {"stroke"},
    {"line cap", CAIRO_LINE_CAP_ROUND},
    {"move to", 128.0, 50.0},
    {"line to", 128.0, 200.0},
    {"stroke"},
    {"line cap", CAIRO_LINE_CAP_SQUARE},
    {"move to", 192.0, 50.0},
    {"line to", 192.0, 200.0},
    {"stroke"},

-- draw helping lines 
    {"source rgb", 1, 0.2, 0.2},
    {"line width", 2.56},
    {"move to", 64.0, 50.0},
    {"line to", 64.0, 200.0},
    {"move to", 128.0, 50.0},
    {"line to", 128.0, 200.0},
    {"move to", 192.0, 50.0},
    {"line to", 192.0, 200.0},

    {"stroke"},
    {"destroy"}})

--NOTES:    
--CAIRO_LINE_CAP_BUTT
--start(stop) the line exactly at the start(end) point

--CAIRO_LINE_CAP_ROUND
--use a round ending, the center of the circle is the end point

--CAIRO_LINE_CAP_SQUARE
--use squared ending, the center of the square is the end point 

return 1
end function

------------------------------------------------------------------------
global function CurveTo()
------------------------------------------------------------------------
atom x = 25.6, y = 128.0,
    x1 = 102.4, y1 = 230.4,
    x2 = 153.6, y2 = 25.6,
    x3 = 230.4, y3 = 128.0

atom cr = create(GdkCairo_t,get(screen,"window"))

 set(cr,{
    {"translate",20,260},
    {"move to",x,y},
    {"curve to",x1,y1,x2,y2,x3,y3},
    {"line width",10.0},
    {"stroke"},

    {"source rgba",1,0.2,0.2,0.6},
    {"line width",6.0},
    {"move to",x,y},
    {"line to",x1,y1},
    {"move to",x2,y2},
    {"line to",x3,y3},
    {"stroke"}})
 
 set(cr,"destroy")
 
return 1
end function

------------------------------------------------------------------------
global function FillandStroke()
------------------------------------------------------------------------
atom cr = create(GdkCairo_t,get(screen,"window"))

-- create path for odd shape;
 set(cr,{
    {"translate",250,240},
    {"move to",128,25.6},
    {"line to",230.4,230.4},
    {"rel line to",-102.4,0},
    {"curve to",51.2,230.4,51.2,128,128,128},
    {"close path"},

-- create path for rectangle;
    {"move to",64,25.6},
    {"rel line to",51.2,51.2},
    {"rel line to",-51.2,51.2},
    {"rel line to",-51.2,-51.2},
    {"close path"},

-- fill color; 
    {"color","yellow"},
    {"fill preserve"}, --save paths for next step;
    
-- draw outlines with broad brush;
    {"line width",10},
    {"color","blue"},
    {"stroke"}})
    
 set(cr,"destroy")

return 1
end function

------------------------------------------------------------------------
global function FillStyle()
------------------------------------------------------------------------
atom cr = create(GdkCairo_t,get(screen,"window"))

-- draw a little 'cart' with wheels;
 set(cr,{
    {"translate",500,260},
    {"line width",6},
    {"rectangle",12,12,232,70},
    {"new sub path"},
    {"arc",64,64,40,0,math:TWOPI},
    {"new sub path"},
    {"arc negative",192,64,40,0,-math:TWOPI},

-- fill areas;
    {"fill rule",CAIRO_FILL_RULE_EVEN_ODD},
    {"color","green"},
    {"fill preserve"},
    {"source rgb",0,0,0},
    {"stroke"},

-- draw another 'cart';
    {"translate",0,128},
    {"rectangle",12,12,232,70},
    {"new sub path"},
    {"arc",64,64,40,0,2*math:PI},
    {"new sub path"},
    {"arc negative",192,64,40,0,-math:TWOPI},

-- fill with a different algorithm;
    {"fill rule",CAIRO_FILL_RULE_WINDING},
    {"color","blue"},
    {"fill preserve"},
    {"source rgb",0,0,0},
    {"stroke"}})

  set(cr,"destroy")
  
--CAIRO_FILL_RULE_WINDING
--If the path crosses the ray from left-to-right, counts +1. 
--If the path crosses the ray from right to left, counts -1. 
--(Left and right are determined from the perspective of looking 
--along the ray from the starting point.) 
--If the total count is non-zero, the point will be filled.

--CAIRO_FILL_RULE_EVEN_ODD
--Counts the total number of intersections, without regard to the 
--orientation of the contour. If the total number of intersections 
--is odd, the point will be filled. 

return 1
end function

------------------------------------------------------------------------
global function Gradient()
------------------------------------------------------------------------
atom cr = create(GdkCairo_t,get(screen,"window"))
    set(cr,"translate",650,-25)

-- background;
object bg = create(CairoLinearGradient,0,0,0,256)
    set(bg,{ -- vertical shade light to dark green;
	{"add color stop rgba",1,0,2,0,1},
	{"add color stop rgba",0,1,1,1,1}})

    set(cr,{ -- rectangle used as bkgnd;
	{"rectangle",0,0,256,256},
    	{"source",bg},
	{"fill"}})
	
    set(bg,"destroy")

-- foreground;
object fg = create(CairoRadialGradient,115,102,25,102,102,128)
    set(fg,{ -- 'ball' effect, circle with radial gradient 'highlight';
	{"add color stop rgba",0,1,1,1,1},
	{"add color stop rgba",1,0,0,0,1}})

    set(cr,{
	{"source",fg},
	{"arc",128,128,76.8,0,math:TWOPI}, -- 2PI = full circle;
	{"fill"}})
	
    set(fg,"destroy")
	set(cr,"destroy")
	
return 1
end function

------------------------------------------------------------------------
global function ImagePattern() -- use an image as a repeating pattern
------------------------------------------------------------------------
atom cr = create(GdkCairo_t,get(screen,"window"))

atom img = create(CairoImageSurface,"thumbnails/clown.png")
integer w = get(img,"width")
integer h = get(img,"height")

atom patt = create(CairoPattern,img)
    set(patt,"extend",CAIRO_EXTEND_REPEAT)

    set(cr,{
	{"translate",170,240},
	{"rotate",math:QUARTPI}, -- 45 degrees clockwise;
	{"scale",1 / math:SQRT2, 1 / math:SQRT2},
	{"translate",-128,-128},

	{"source",patt},
	{"rectangle",0,0,256,256},
	{"fill"}})

 set(cr,"destroy")
 set(patt,"destroy")
 
return 1
end function

--------------------------------------------------------------------------------
global function LineJoin() -- corner appearance when two lines join at an angle
--------------------------------------------------------------------------------
atom cr = create(GdkCairo_t,get(screen,"window"))

 set(cr,{
    {"translate",690,250},
    {"line width",20.96},
    {"move to",76.8,84.40},
    {"rel line to",51.2,-51.2},
    {"rel line to",51.2,51.2},
    {"line join",CAIRO_LINE_JOIN_MITER},
    {"color","red"},
    {"stroke"},

    {"move to",76.8,161.28},
    {"rel line to",51.2,-51.2},
    {"rel line to",51.2,51.2},
    {"line join",CAIRO_LINE_JOIN_BEVEL},
    {"color","green"},
    {"stroke"},

    {"move to",76.8,238.08},
    {"rel line to",51.2,-51.2},
    {"rel line to",51.2,51.2},
    {"line join",CAIRO_LINE_JOIN_ROUND},
    {"color","blue"},
    {"stroke"}})
  
  set(cr,"destroy")
  
return 1
end function

------------------------------------------------------------------------
global function Hello()
------------------------------------------------------------------------
 atom cr = create(GdkCairo_t,get(screen,"window"))
 
  set(cr,{
    {"select font face", "serif", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_BOLD},
    {"font size",rand(36+8)},
    {"source rgb", rand(100)/100, rand(100)/100, rand(100)/100},
    {"move to",rand(600), rand(500)},
    {"show text","Hello, world"},
    {"destroy"}})
return 1
end function

------------------------------------------------------------------------
global function GoodDay()
------------------------------------------------------------------------
atom cr = create(GdkCairo_t,get(screen,"window"))
 set(cr,{
    {"select font face","Purisa",CAIRO_FONT_SLANT_NORMAL,CAIRO_FONT_WEIGHT_BOLD},
    {"font size",rand(36+8)},
    {"source rgb",rand(100)/100, rand(100)/100, rand(100)/100},
    {"move to",rand(600),rand(500)},
    {"show text","G'Day, Mate!"},
    {"destroy"}})
return 1
end function
