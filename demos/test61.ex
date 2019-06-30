
------------------------------------------------------------------------------
--# Simple Cairo graphics
------------------------------------------------------------------------------

include GtkEngine.e
include GtkCairo.e
include std/math.e
include std/mathcons.e

atom surf = create(CairoImageSurface,"./thumbnails/MorningRain.png")

constant 
    win = create(GtkWindow,"icon=applications-graphics,resizable=FALSE,position=1,$destroy=Quit"),
    box = create(GtkBox,HORIZONTAL),
    screen = create(GtkDrawingArea,"size request=400x300")

-- redraw whenever necessary. if you don't do this, other windows will destroy
-- contents of this window when they overlay it:
   connect(box,"draw","Paint") 

    add(box,screen)
    add(win,box)

show_all(win)
constant dwin = get(screen,"window") 
main()

---------------------------------------------------------
global function Paint(atom ctl, atom event)
---------------------------------------------------------
atom cr = create(GdkCairo_t,dwin) -- new cairo_t

---- background image;
  set(cr,{
    {"source surface",surf,1,1},
    {"paint"},

---- text;
    {"color","black"},
    {"move to",10,30},
    {"font size",30},
    {"show text","Drawing Primitives"},

---- text;
    {"color","red"},
    {"move to",200,200},
    {"font size",20},
    {"show text","Hello World!"},

---- triangle;
    {"color","yellow"},
    {"line width",2},
    {"move to",100,100},
    {"line to",200,200},
    {"line to",200,100},
    {"line to",100,100},
    {"stroke"},

---- rectangle blue;
    {"source rgba",0,0,#FF,0.4}, -- alternate way to set color and alpha;
    {"rectangle",80,80,40,50},
    {"fill preserve"},

---- add white outline;
    {"source rgb",#FF,#FF,#FF}, -- alternate way to set color;
    {"line width",2},
    {"stroke"}})

---- the arc or circle 0 or starting point is at 90 degrees or 3 o'clock;
---- I find it easier to think in terms of N,S,E,W, with north at 0/360
---- therefore this simple conversion code;

atom degree =  math:TWOPI/360
atom north = -degree*90
atom east = north + (degree*90)
atom south = east + (degree*90)
atom west = south + (degree*90)

  set(cr,{
    {"source rgba",0,#FF,0,0.4}, -- semi-transparent green circle;
    {"line width",2},
    {"arc",200,200,55,north,degree*360}, -- 'from due north to north + 360 degrees'
    {"fill"},

    {"destroy"}}) -- important!

return 1
end function



