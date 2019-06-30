
--# Widget opacity, blinking icons, timers

include GtkEngine.e
include std/math.e

requires("3.10","Widget Opacity")

constant docs = `
Slide the slider bar to change the 
opacity of the left button and blink
speed of the right button image.
`
constant 
	win = create(GtkWindow,"title=Widget Opacity,border=10,$destroy=Quit"),
	panel = create(GtkBox,"orientation=vertical"),
	box = create(GtkButtonBox),
	btn1 = create(GtkButton,"~/demos/thumbnails/clown.png#Clown"),
	btn2 = create(GtkButton,"~/demos/thumbnails/clown.png#Clown"),
	btn2img = get(btn2,"image"),
	slider = create(GtkScale,0,0,1,.01),
	lbl = create(GtkLabel,{{"markup",docs}})
	
	set(btn1,"opacity",0.5)
	set(slider,"value",0.5)
	set(slider,"draw value",FALSE)

	add(win,panel)
	add(box,{btn1,btn2})
	pack(panel,box)
	add(panel,{slider,lbl})
	
atom tick = create(GTimeout,100,_("blink"))
atom x = 1

connect(slider,"value-changed","Update")

show_all(win)

if get(win,"is composited") = 0 then
	Warn(win,"Sorry",
	"This program requires",
	"a compositing window manager")
end if

main()

-------------------------
global function Update()
-------------------------
atom v = get(slider,"value")
set(btn1,"opacity",v) 
if tick > 0 then 
	v = ensure_in_range(v,{.01,.99}) -- avoid lockup with tick out of range;
	set(tick,"remove") -- kill previous timer;
	tick = create(GTimeout,100 - (v*100),_("blink"))
end if
return 1
end function

-------------------
function blink() -- strictly for fun  :)
-------------------
set(btn2img,"opacity",x)
x -= .1
if x < 0 then x = 1 end if
return 1
end function
