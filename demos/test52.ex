
---------------------------------------------------------------------------------
--# GTimeout and GtkSwitch = a simple sports timer.
---------------------------------------------------------------------------------

include GtkEngine.e
include std/stats.e

-- Exercise for the programmer: 
-- Add a graph to show the increase/decrease in lap times
-- as the race progresses...

atom ct = 0, n = 1, last = 0
sequence fmt = "<span color='red'>%2.2f</span>"
sequence laps = {}

constant 
    win = create(GtkWindow,"title=Stopwatch,border=10,background=black,keep above=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    btn1 = create(GtkSwitch,"tip=click to start/pause,$activate=StartStop"),
    btn2 = create(GtkButton,"label=Lap,color=red,tip=click to log lap time,$clicked=RecordLapTime"),
    reset_img = create(GtkImage,"thumbnails/icon-reset.png"),
    btn3 = create(GtkButton,"image=./thumbnails/icon-reset.png,tip=click to reset,$clicked=Reset"),
    lbl = create(GtkLabel,"alignment=.5,font=36"),
    box = create(GtkButtonBox,"spacing=5"),
    tick = create(GTimeout,10,_("Count"))

    add(win,panel)
    add(panel,lbl)
    add(box,{btn1,btn2,btn3})
    pack(panel,-box)
    
show_all(win)

ifdef UNIX then
	Info(,,"Run from an x-term","if you want to see lap times")
end ifdef

main()

--------------------------------------
global function StartStop(atom ctl) -- toggle timer
--------------------------------------
return 0
end function

--------------------------------
global function RecordLapTime()
--------------------------------
laps = append(laps,{length(laps)+1,ct-last,0,ct})
last = ct
laps[$][3] = stats:average(vslice(laps,2)) -- average;

ifdef WINDOWS then
    system("cls")
elsedef
    system("clear")
end ifdef

for i = 1 to length(laps) do
    display("Lap: [:3>] Time: [.3] Avg: [.3>] Ttl: [.3]",laps[i])
end for

return 1
end function

--------------------------
global function Reset() -- zero time
--------------------------
    ct = 0
    laps = {} 
    last = 0
    set(lbl,"markup",sprintf(fmt,ct))
return 0 
end function 

-------------------
function Count() -- called by tick
-------------------
    if get(btn1,"active") then
        ct += .01
        set(lbl,"markup",sprintf(fmt,ct))
    end if
return 1
end function

