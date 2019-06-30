------------------------------------------------------------------------
--# Euphoria Multi-Tasking
------------------------------------------------------------------------
-- This shows how to use the GtkSpinner to indicate progress while loading
-- a large file, or while doing some other lengthy process...
-- If you do not multi-task, the spinner will stop while Euphoria 
-- is loading the file, which is exactly what you do NOT want to happen!
------------------------------------------------------------------------
-- Spinner seems to be broken in Gtk3.6.4, but works fine in Gtk3.4.1 and
-- Gtk3.8.4, and later versions.

include GtkEngine.e
include GtkEvents.e
include GtkFileSelector.e

include std/filesys.e

constant docs = `<u><b>Spinner &amp; Tasks</b></u>
This uses Euphoria's multi-tasking functions.
If you run this from an x-term, you will see the lines
as they are read. Click the OK button to begin.`

constant msg1 = "<span color='red'>Reading GtkEnums.e line: %d</span>"
constant msg2 = "<span color='blue'><i><b>Done! %d lines read.</b></i></span>"

integer lc = 0 -- count lines read;

atom t1
t1 = task_create(routine_id("task1"),{})
task_schedule(t1,{0.002,1})
boolean t1_running = TRUE

label "OPEN_FILE"
integer fn = open(locate_file("GtkEnums.e"),"r") -- file to read;
if fn = -1 then
    fn = fileselector:Open() 
    if fn < 3 then
        if Question(,,"Quit?") = MB_YES then Quit() else goto "OPEN_FILE" end if
    end if
end if

constant win = create(GtkWindow,"border_width=10,keep above=1,$destroy=Quit")

constant panel = create(GtkBox,1)
    add(win,panel)

constant lbl1 = create(GtkLabel)
    set(lbl1,"markup",docs)

constant lbl2 = create(GtkLabel)
constant lbl3 = create(GtkLabel)

constant spin = create(GtkSpinner)
    set(spin,"size request",30,30)
    
    add(panel,{lbl1,lbl2,spin,lbl3})
    
constant 
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","StartTask"),
    box = create(GtkButtonBox)
    add(box,{btn1,btn2})
    set(box,"margin top",15)
    pack(panel,-box)

show_all(win)
main()

--------------------------------------------------------
procedure task1() -- this reads and displays the file;
--------------------------------------------------------
object line = {}
while not atom(line) do
    lc += 1 -- increment line count
    line = gets(fn) -- read the line
        puts(1,line) -- display the line on terminal
        task_yield()
end while
t1_running = FALSE
end procedure

-----------------------------------------------------------------
global function StartTask() -- starts spin and yields to task1;
-----------------------------------------------------------------
    set(spin,"start")
    
    while t1_running do
        main_iteration_do(1) -- VITAL! (give GTK a chance to tick the clock)
        set(lbl2,"markup",sprintf(msg1,lc)) -- update # of lines read
        task_yield()
    end while
    
    set(spin,"stop")
    set(btn2,"sensitive",FALSE)
    set(lbl2,"markup",sprintf(msg2,lc)) -- done!
    
return 0
end function


