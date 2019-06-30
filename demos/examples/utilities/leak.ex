
--------------------------------------------------------------------------------
--# Test for memory leaks in get and set routines;
-- Run System Monitor and watch memory usage while this runs for a long time.
-- Memory usage should not change, since no new widgets are created in the loop.
--------------------------------------------------------------------------------

include GtkEngine.e

if system_exec("which gnome-system-monitor",0) = 0 then
 if Question(,,"Use gnome-system-monitor") = MB_YES then
 system("gnome-system-monitor &",0)
 end if
elsif system_exec("which mate-system-monitor",0) = 0 then
 if Question(,,"Use mate-system-monitor") = MB_YES then
 system("mate-system-monitor &",0)
 end if
end if

constant docs = `<b><u>Leak Test</u></b>
This runs mate-system-monitor and then reads and
writes to a label, accessing it via widget name
(label2). Watch the memory usage, it should not
change even after running for a long time.
`
constant win = create(GtkWindow,"size=300x300,border=10,$destroy=Quit")
constant panel = create(GtkBox,"orientation=1,spacing=10")
constant img = create(GtkImage,"thumbnails/utilities-system-monitor.png")
constant lbl1 = create(GtkLabel) set(lbl1,"markup",docs)
constant lbl2 = create(GtkLabel,"text=`Hello World!`,name=Label2")
constant lbl3 = create(GtkLabel)

integer ct = 0

add(win,panel)
add(panel,{img,lbl1,lbl2,lbl3})

constant tick = create(GIdle,_("T1")) -- as fast as possible!
constant tock = create(GTimeout,1000,_("T2")) -- one second intervals

show_all(win)
set(win,"move",10,10)
main()

----------------
function T1() -- tests for leaks in set and get;
----------------
 ct += 1
 get("Label2","text") -- access count (discarded)
 set("Label2","text",sprintf("Hello World! %d",ct)) -- update count
 return 1
end function

---------------
function T2()-- show max count achieved in 1 sec.
---------------
 set(lbl3,"text",sprintf("%d lookups per second",ct)) 
 ct = 0 -- reset count
 return 1
end function
