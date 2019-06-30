
------------------------------------------------------------------------
--# Fiddling with Frames;
-- This is just an experiment to see how many different types of frames
-- I can create.   One or two might prove useful.
------------------------------------------------------------------------

include GtkEngine.e

atom x = 0, y = 20
atom angle = 0

constant docs = `<b><u>Fiddling with Frames</u></b>
These frames have their appearance 
modified by mystyle4.css.`
    
constant css = create(GtkCssProvider,
	locate_file("resources/mystyle4.css"))

constant win = create(GtkWindow,
    "size=355x-1,border=10,position=1,background=lightgray,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL,spacing=10")
    add(win,panel)

constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(panel,lbl)

constant mongoose = create(GtkImage,create(GdkPixbuf,"thumbnails/mongoose.png",20,20,TRUE))
constant frame1 = create(GtkFrame,{
    {"name","frame1"},
    {"label widget",mongoose}})
    add(frame1,create(GtkLabel,
`
Frame with border-style: none;
background-color: skyblue;  
label widget(mongoose)

`))
    add(panel,frame1)

constant frame2 = create(GtkFrame,{
    {"label","Frame 2"},
    {"label align",1,0},
    {"name","frame2"}})
    add(frame2,create(GtkLabel,
`
Frame with border-style: inset; 
label align(1,0)

`))
    add(panel,frame2)
constant frame3 = create(GtkFrame,{
    {"label","Frame Number 3"},
    {"label align",0.5,0.5},
    {"name","frame3"}})
    add(frame3,create(GtkLabel,
`
Frame with border-style: outset;
label align(0.5,0.5)
`))
    add(panel,frame3)
    
constant tab4 = create(GtkLabel)
    ifdef WINDOWS then set(tab4,"font","Segoe Script Bold 14") end ifdef
    ifdef UNIX then set(tab4,"font","URW Chancery L 14") end ifdef
    set(tab4,"markup","<span color='magenta'><u><b>Fancy Title 4</b></u></span>")
    
constant frame4 = create(GtkFrame,"4")
    set(frame4,"name","frame4")
    set(frame4,"label widget",tab4)
    
constant lbl4 = create(GtkLabel)
    set(lbl4,"font","10")
    set(lbl4,"markup",
`Frame with border-radius: 20px;
 label font URW Chancery or Segoe Script`)
    add(frame4,lbl4) 
    add(panel,frame4)

constant frame5 = create(GtkFrame)
 set(frame5,"size request",-1,100)
 set(frame5,"name","frame5")
 set(frame5,"label align",1,1)

constant layout = create(GtkLayout)
constant lbl5 = create(GtkLabel,{
	{"name","label5"},
	{"markup","Inset frame with image and label"}})
    set(layout,"put",lbl5,25,10)
    
constant cow = create(GtkImage,"thumbnails/cowbell2a.gif")
    set(layout,"put",cow,x,y)
    add(frame5,layout)
    add(panel,frame5)
    
constant frame6 = create(GtkFrame,{
    {"name","frame6"},
    {"size request",-1,130}})
    add(panel,frame6)

constant eulbl = create(GtkLabel,{
    {"font","20"},
    {"margin top",10},
    {"color","rgba(255,0,0,0.5)"}, -- overlay semi-transparent
    {"markup","<small>\n</small><b>and EuGTK!</b>     "}})
    add(frame6,eulbl)
    
constant btn = create(GtkButton,"gtk-quit","Quit")
    pack(panel,-btn)
    set(btn,"tooltip markup",
	"<span color='black'><b>Click this button and hold!</b></span>")
  
constant tick = create(GTimeout,50,call_back(routine_id("TickTock")))
  
show_all(win)
main()

---------------------
function TickTock()
---------------------
x += 1 
y += (rand(3)-2) / 2
  
set(layout,"move",cow,x,y)
set(eulbl,"visible",not get(eulbl,"visible"))

if x > 350 then
    x = -120
end if

return 1
end function
