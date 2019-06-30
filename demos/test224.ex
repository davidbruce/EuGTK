
--# Cairo Clock <span color='blue'>requires SPD-SAY</span>

-- Help a child (or some recent college graduates) learn to read a clock!
-- Displays the current computer time in analog and digital form,
-- speaks the time when the button is clicked or every quarter hour.

include GtkEngine.e
include GtkCairo.e
include std/math.e

integer radius = 110
integer n_words = 12
atom angle = 0
integer prevsec = 0
integer prevangle = 0
object speak

constant
    win = create(GtkWindow,"icon=thumbnails/clock.png,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    screen = create(GtkDrawingArea,"size request=300x300,$draw=DrawFace"),
    lbl = create(GtkLabel,"font=Mono 16,color=blue"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"thumbnails/clock.png#Say Time"),
    tick = create(GIdle,call_back(routine_id("Tock"))) -- check when doing nothing else;

    connect(btn2,"clicked","Update")
    connect(btn2,"clicked","SayTime")
    
object fg1 = create(CairoRadialGradient,115,102,25,102,102,128)
    set(fg1,{ -- 'dome' effect, a circle with a radial gradient 'highlight';
	{"add color stop rgba",0,.9,.9,.9,1},
	{"add color stop rgba",1,.4,.5,.6,1}})
    
object fg2 = create(CairoRadialGradient,10,10,20,20,20,20)
    set(fg2,{ 
	{"add color stop rgba",0,1,1,1,1},
	{"add color stop rgba",1,0,0,0,1}})

    add(win,pan)
    pack(pan,screen,1,1)
    pack(pan,lbl)
    pack(box,{btn1,btn2})
    pack(pan,-box)
    
show_all(win)

 if atom(uses("spd-say")) then
	set(btn2,"sensitive",FALSE)
 end if

main()

-----------------------------
global function DrawFace() -- draw clock face w/o hands;
-----------------------------
atom cr = create(GdkCairo_t,get(screen,"window")) 

set(cr,{ -- circle
    {"color","black"},
    {"line width",20},
    {"arc",150,150,100,0,360*DEGREES_TO_RADIANS},
    {"stroke"}})

object color  
set(cr,"line width",1)

for i = 0 to 359 by 6 do
    if remainder(i,5) then color = "black" 
    else color = "red"
    end if
    set(cr,{
        {"color",color},
        {"arc",150,150,90,0,i*DEGREES_TO_RADIANS,i*DEGREES_TO_RADIANS},
        {"stroke preserve"},
        {"line to",150,150},
        {"stroke"}})
end for

set(cr,{
    {"source",fg1},
    {"arc",150,150,75,0,math:TWOPI}, -- 2PI = full circle;
    {"fill"}})
 	
object layout = create(PangoCairoLayout,cr)
object font = create(PangoFontDescription,"Bold 12")
set(layout,"font description",font)

set(cr,"color","white")
set(cr,"translate",150,150)
for i = 1 to n_words do -- draw hours
    set(layout,"text",sprintf("%2d",i))
    angle = (360 * i) / n_words
    set(cr,"save")
    set(cr,"rotate",(angle * PI / 180)-.1)
    gtk_func("pango_cairo_update_layout",{P,P},{cr,layout})
    set(cr,"move to",0,-radius)
    gtk_func("pango_cairo_show_layout",{P,P},{cr,layout})
    set(cr,"restore")
end for
set(cr,"destroy")
return 1 
end function

-------------------------
global function Tock() -- draw the clock hands;
-------------------------   
atom cr = create(GdkCairo_t,get(screen,"window")) 
object now = date() 
integer hour = now[4]
integer min = now[5]
integer sec = now[6]

if sec = prevsec then return 1 end if -- only draw when needed;

set(cr,{
    {"source",fg1},
    {"arc",150,150,75,0,math:TWOPI}, -- 2PI = full circle;
    {"fill"}})
 	
set(cr,"translate",150,150)

angle = (360/12)*hour -- hours hand
angle += ((360/12)/60)*min -- add minutes
angle = (angle-90)*DEGREES_TO_RADIANS

set(cr,{
    {"color","black"},
    {"line width",6},
    {"line cap", CAIRO_LINE_CAP_ROUND},
    {"arc",0,0,radius-60,angle,angle},
    {"stroke preserve"},
    {"line to",0,0},
    {"stroke"}})

angle = (360/60)*min -- minutes hand
angle = (angle-90)*DEGREES_TO_RADIANS

set(cr,{
    {"line width",4},
    {"line cap",CAIRO_LINE_CAP_ROUND},
    {"arc",0,0,radius-40,angle,angle},
    {"stroke preserve"},
    {"line to",0,0},
    {"stroke"}})

angle = (360/60)*sec -- seconds hand
angle = (angle-90)*DEGREES_TO_RADIANS

set(cr,{
    {"color","red"},
    {"line width",1},
    {"arc",0,0,radius-35,angle,angle},
    {"stroke preserve"},
    {"line to",0,0},
    {"stroke"},

    {"source",fg2}, -- hub
    {"arc",0,0,10,0,360*DEGREES_TO_RADIANS},
    {"fill"},
    {"destroy"}})
     
prevsec = sec
Update()
return 1
end function

---------------------------
global function Update() -- update the text;
---------------------------
object now = date() 
integer hour = now[4]
integer min = now[5]
integer sec = now[6]

object tm = "A.M."
if hour > 11 and min > 0 then
    hour -= 12
    tm = "P.M."
end if
if hour = 0 then
    hour = 12
end if

set(lbl,"text",sprintf("%d:%02d:%02d %s",{hour,min,sec,tm}))

speak = sprintf("%d %d %s",{hour,min,tm})

if min = 0 then
    speak = sprintf("%d %s",{hour,tm})
elsif min < 10 then
    speak = sprintf("%d oh %d %s",{hour,min,tm})
end if

if sec = 0 then
if remainder(min,5) = 0 then
    SayTime()
end if
end if

return 1
end function

----------------------------
global function SayTime() --
----------------------------
    system(sprintf("spd-say -p10 -r-50 -tchild_female -i-10 -w -mnone ' The time is %s' &",{speak}))
return 1
end function



