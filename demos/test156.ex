
------------------------------------------------------------------------
--# GtkStack offers a variety of 'transition' effects when pages change.
------------------------------------------------------------------------

include GtkEngine.e

requires("3.10.8","for GtkStack")

constant img = {
    create(GtkImage,"thumbnails/fox.png"),
    create(GtkImage,"thumbnails/fish.png"),
    create(GtkImage,"thumbnails/mouse.png")
    }
    
sequence captions = {
    "None",
    "Crossfade",
    "Slide Right",
    "Slide Left",
    "Slide Up",
    "Slide Down",
    "Left Right",
    "Up Down"
    }
 
 if minor_version > 10 then
    captions &= {
        "Over Up","Over Down","Over Left","Over Right",
        "Under Up","Under Down","Under Left","Under Right","Over Up Down"}
 end if
 
 if minor_version > 12 then
    captions &= {"Over Down Up","Over Left Right","Over Right Left"}
 end if

constant icons = { -- icons for radio buttons;
    0,
    "media-playlist-shuffle",
    "go-next",
    "go-previous",
    "go-up",
    "go-down",
    "thumbnails/rightleft.png",
    "thumbnails/updown.png",
    $}

constant tips = { -- for radio buttons;
    "None\n<i>change is instantaneous</i>",
    "Crossfade",
    "Slide right",
    "Slide left",
    "Slide up",
    "Slide down",
    "Slide left-right\n<small>bi-directional\naccording to button order</small>",
    "Slide up-down\n<small>bi-directional\naccording to button order</small>",
    "Over up\n<small>cover the old page by sliding up</small>",
    "Over down\n<small>cover the old page by sliding down</small>",
    "Over left\n<small>cover the old page by sliding left</small>",
    "Over right\n<small>cover the old page by sliding right</small>",
    "Under up\n<small>uncover the new page by sliding up</small>",
    "Under down\n<small>uncover the new page by sliding down</small>",
    "Under left\n<small>uncover the new page by sliding to the left</small>",
    "Under right\n<small>uncover the new page by sliding to the right</small>",
    "Over up down\n<small>according to button order</small>",
    "Over down up\n<small>according to button order</small>",
    "Over left right\n<small>according to button order</small>",
    "Over right left\n<small>according to button order</small>",
    $}
    
constant window = create(GtkWindow,{
    {"border width",10},
    {"position",GTK_WIN_POS_CENTER},
    {"connect","destroy","Quit"}})

constant grid = add(window,create(GtkGrid))

constant stack = create(GtkStack,{
    {"hexpand",TRUE},
    {"vexpand",TRUE},
    {"transition duration",500},
    {"transition type",GTK_STACK_TRANSITION_TYPE_NONE}})

set(grid,"attach",stack,0,0,1,1)

constant stackswitcher = create(GtkStackSwitcher,{
    {"border width",10},
    {"spacing",10},
    {"stack",stack}})

set(grid,"attach",stackswitcher,0,2,1,1)

sequence page = repeat(0,3)
for i = 1 to 3 do 
    page[i] = newPage(i)
    set(stack,"add titled",page[i],
        sprintf("label %d",i),sprintf("Page %d",i))
end for 

set(grid,"attach",newOptions(),0,1,1,1)

constant speed = create(GtkScale,{
    {"orientation",HORIZONTAL},
    {"range",0,2}, -- min, max
    {"increments",.01,.1}, -- step, page
    {"digits",2},
    {"value",1.00},
    {"tooltip markup","Transition Speed"},
    {"connect","value-changed","SetTransitionSpeed"}})
    set(grid,"attach",speed,0,3,1,1)

constant lbl2 = create(GtkLabel,{
    {"markup","Transition speed (seconds)"},
    {"font","8"}})
    set(grid,"attach",lbl2,0,4,1,1)

show_all(window)

main()

-------------------------------
function newPage(integer page) -- build page content;
-------------------------------
atom box = create(GtkBox,VERTICAL)
atom lbl = create(GtkLabel,sprintf("Page %d",page))
atom frm = create(GtkFrame,sprintf("Page %d",page))
    set(lbl,"font","Purisa, Georgia bold 36")
    add(frm,box)
    add(box,{img[page],lbl})
return frm
end function

---------------------
function newOptions() -- build option buttons;
---------------------
atom frame = create(GtkFrame,"Transition Types") 
atom grid = create(GtkGrid)
add(frame,grid)

atom x = 0 
object btns = repeat(0,20)
for i = 1 to length(captions) do 
    x = create(GtkRadioButton,x,captions[i],"setTransition",i-1)
    if i = 2 then set(x,"active",TRUE) end if
    if i <= length(icons) then
        set(x,"image",create(GtkImage,icons[i],GTK_ICON_SIZE_SMALL_TOOLBAR))
    end if
    if i <= length(tips) then set(x,"tooltip markup",tips[i]) end if
    set(x,"font","8")
    btns[i] = x
end for

btns = breakup(btns,4) -- 'columnize'
for i = 1 to 4 do
 for j = 1 to 4 do
    if btns[i][j] > 0 then
        set(grid,"attach",btns[i][j],j,i,1,1)
    end if
 end for
end for

return frame
end function

--------------------------------------------------
global function setTransition(atom ctl, integer x)
--------------------------------------------------
    set(stack,"transition type",x)
return 1
end function

--------------------------------------------------
global function SetTransitionSpeed(atom ctl)
--------------------------------------------------
    set(stack,"transition duration",get(ctl,"value")*1000)
return 1
end function


