
---------------------------------------------------------------------------
--# Friendly aliens drop cows from a ufo.
---------------------------------------------------------------------------
-- Being friendly, the aliens provide cows with parachutes.
-- Cows do what cows do, once they reach the ground.
--
-- It's interesting to run this and a system monitor program 
-- on a multi-processor pc, and note how well the load is shared.

-- Ideally, this should be re-written to use tasks, one per cow.
---------------------------------------------------------------------------

include GtkEngine.e
include std/rand.e
include std/math.e

sequence cows = {}
atom cowspeed =  150
integer state = 0
enum X,Y
enum DirectionRight,DirectionLeft
enum Ptr, Position, Direction, Facing, Eating
constant Xrange = {2,310}, Yrange = {1,255}
constant 
	BORDER_LEFT = 2, BORDER_RIGHT = 300, 
	BORDER_TOP = 75, BORDER_BOTTOM = 220

constant win = create(GtkWindow,{
    {"resizable",FALSE},
    {"position",GTK_WIN_POS_CENTER_ALWAYS},
    {"connect","destroy",_("Bailout")}})

constant evbx = create(GtkEventBox,{
    {"background","#ffeeee"},
    {"connect","button-press-event",_("AddACow")}})
    add(win,evbx)

constant panel = create(GtkBox,VERTICAL)
    add(evbx,panel)

constant layout = create(GtkLayout,{
    {"tooltip markup","Click to add a cow"}})
    pack(panel,layout,TRUE,TRUE)

constant pix = create(GdkPixbuf,"thumbnails/nature.jpg",320,240)
constant img = create(GtkImage,pix)
    set(layout,"put",img,-2,-2)

sequence cow = repeat(0,10) -- fake animation, better to do it with gifs?
    cow[1] = create(GdkPixbuf,"thumbnails/cowbell.png",20,20)
    cow[2] = create(GdkPixbuf,"thumbnails/cowbell2.png",20,20)
    cow[3] = create(GdkPixbuf,"thumbnails/coweat.png",20,20)
    cow[4] = create(GdkPixbuf,"thumbnails/coweat2.png",20,20)
    cow[5] = create(GdkPixbuf,"thumbnails/coweat3.png",20,20)
    cow[6] = create(GdkPixbuf,"thumbnails/coweat4.png",20,20)
    cow[7] = create(GdkPixbuf,"thumbnails/coweat5.png",20,20)
    cow[8] = create(GdkPixbuf,"thumbnails/coweat6.png",20,20)
    cow[9] = create(GdkPixbuf,"thumbnails/coweat7.png",20,20)
    cow[10]= create(GdkPixbuf,"thumbnails/cowbell3.png",20,20)
    
atom timer = 0
atom flasher = create(GTimeout,250,_("flash"))

show_all(win)

set(win,"size request",320,240)

constant ufo1 = create(GdkPixbuf,"thumbnails/ufo1.png",40,0,1)
constant ufo2 = create(GdkPixbuf,"thumbnails/ufo2.png",40,0,1)
    set(win,"cursor",ufo1)

Info(win,,
    "Bovine Invaders \nfrom Outer Space",
    "Move the UFO around,\n click the left mouse button!")

main()

----------------------------
function flash()
----------------------------
state = not(state)
if state then
    set(win,"cursor",ufo1)    
else
    set(win,"cursor",ufo2)
end if
return 1
end function

----------------------------
function Bailout()
----------------------------
cows = {}
timer = 0
Quit()
return 1
end function

----------------------------
function AddACow()
----------------------------
object location = get(win,"pointer") 
location[X] = ensure_in_range(location[X],Xrange) 
location[Y] = ensure_in_range(location[Y],Yrange) +5

cows = append(cows,{Ptr,Position,Direction,Facing, Eating})
cows[$][Ptr] = create(GtkImage)
cows[$][Position]  = location
cows[$][Direction] = {rand_range(-1,+1),rand_range(-1,+1)}
cows[$][Facing] = rand(2)
cows[$][Eating] = rand(2)=1

integer x = ensure_in_range((cows[$][Direction][X]+1) + cows[$][Facing]+cows[$][Eating],{1,4})

set(cows[$][Ptr],"from pixbuf",cow[x])
set(layout,"put",cows[$][Ptr],location[X],location[Y])
show(cows[$][Ptr])
Beep()
set(win,"title",format("[] cows browsing",length(cows)))

timer = create(GTimeout,cowspeed,_("MoveACow"))

return 0
end function

------------------------------
function MoveACow()
------------------------------
integer n,r, eating, chance

if length(cows) = 0 then -- no cows? forgettaboutit!
    return 1
end if

n = rand(length(cows))
r = rand(20)

switch r do -- add some random actions;
    case 2 then cows[n][Direction][X] = 1
    case 3 then cows[n][Direction][Y] = 1
    case 4 then cows[n][Direction][X] = -1
    case 5 then cows[n][Direction][Y] = -1
    case 6,8,12 then cows[n][Eating] = 2
    case 9,10,11 then cows[n][Eating] = 0
end switch

if cows[n][Position][Y] > 70 then -- cow is on ground;
    set(cows[n][Ptr],"from pixbuf",cow[cows[n][Facing]+cows[n][Eating]])
    
elsif cows[n][Position][Y] > 40 then -- cow nearing ground - deploy chute
    set(cows[n][Ptr],"from pixbuf",cow[10])
    cows[n][Position][Y] += 2
    
else -- bailing out.
    set(cows[n][Ptr],"from pixbuf",cow[rand(3)+6])
    cows[n][Position][Y] += 4

end if

set(layout,"move",cows[n][Ptr],cows[n][Position][X],cows[n][Position][Y])

-- turn cow n when it reaches a border;

if cows[n][Position][X] < BORDER_LEFT then 
    cows[n][Direction][X] = +1
    cows[n][Facing] = DirectionLeft
    end if
    
if cows[n][Position][X] > BORDER_RIGHT then 
    cows[n][Direction][X] = -1 
    cows[n][Facing] = DirectionRight
    end if

if cows[n][Position][Y] < BORDER_TOP then
    cows[n][Direction][Y] = +1
    cows[n][Eating] = 2
    end if

if cows[n][Position][Y] > BORDER_BOTTOM then
    cows[n][Direction][Y] = -1
    cows[n][Eating] = 0
    end if

cows[n][Position] += cows[n][Direction] 

return 1
end function


