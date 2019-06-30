------------------------------------------------------------------------
--# Euphoria MultiTasking;
------------------------------------------------------------------------
-- Shows how to use the GtkSpinner to indicate progress while loading
-- a large file, or some other lengthy process...
-- If you do not multi-task, the spinner will stop while Euphoria 
-- is working, which is exactly what you do NOT want to happen!
------------------------------------------------------------------------
-- Spinner seems to be broken in Gtk3.6.4, but works fine in Gtk3.4.1 and
-- Gtk3.8.4, and later versions.

include GtkEngine.e
include GtkEvents.e
include std/filesys.e

atom t1
t1 = task_create(routine_id("task1"),{})
task_schedule(t1,{0.002,1})
boolean t1_running = TRUE

integer lc = 0 -- count lines read;
integer fn = open(locate_file("GtkEnums.e"),"r") -- file to read;

constant docs = `markup=
<b>Spinner and Tasks</b>

This uses Euphorias multi-tasking functions.
If you run this from an x-term you will see the lines
as they are read. Click the OK button to begin.`

constant 
    msg1 = "<span color='red'>Reading GtkEnums.e line: %d</span>",
    msg2 = "<span color='blue'><i><b>Done</b></i></span>",

    win = create(GtkWindow,"border_width=10,keep above=1,$destroy=Quit"),
    panel = create(GtkBox,1),
    lbl1 = create(GtkLabel,docs),
    lbl2 = create(GtkLabel),
    spin = create(GtkSpinner),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","StartTask"),
    box = create(GtkButtonBox)
    
    add(box,{btn1,btn2})
    set(box,"margin top",15)
    pack(panel,-box)
    set(spin,"size request",30,30)
    add(panel,{lbl1,lbl2,spin})
    add(win,panel)
    
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
t1_running = FALSE -- EOF, kill task
end procedure

-----------------------------------------------------------------
global function StartTask() -- starts spin and yields to task1;
-----------------------------------------------------------------
    set(spin,"start")
    
    while t1_running do
        main_iteration_do(1) -- vital! (give GTK a chance to tick the clock)
        set(lbl2,"markup",sprintf(msg1,lc)) -- update # of lines read
        task_yield()
    end while
    
    set(spin,"stop")
    set(btn2,"sensitive",FALSE)
    set(lbl2,"markup",msg2) -- done!
    
return 0
end function


