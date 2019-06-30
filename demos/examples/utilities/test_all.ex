
----------------------------------------------------------------------------
--# Test all programs in ~/demos
----------------------------------------------------------------------------
-- Run this with an x-term so that you can see messages re: missing files;
-- It runs 10 tests at at time, starting with the number in the box.
-- After these are run, you can click the ok button to run the next 10.

-- You might be able to run as many as 40 or 50 programs at the same time,
-- depending upon memory and processor(s), but I can't recommend it,
-- since too many can 'freeze' the windows & mouse, leaving you no way
-- out but to hit the power switch!
----------------------------------------------------------------------------

include GtkEngine.e

chdir(canonical_path("~/demos"))

integer i = 0, ct = 0, step = 10
integer max = length(dir("test*.ex")) 
atom tick

constant docs = `<u><b>Testall</b></u> 

Runs several tests at a time, beginning with the number 
in the box below. Be sure to run this program from
an x-term, so you can see any error messages.

If you are using a slow computer with low memory,
you may change the 'step' variable from 10 to a lower
number.
`
constant 
    win = create(GtkWindow,"border=10,icon=thumbnails/mongoose.png,$destroy=Quit"),
    panel = create(GtkBox,VERTICAL),
    lbl1 = create(GtkLabel,{{"markup",docs}}),
    lbl2 = create(GtkLabel,"markup=   Start         Step"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkSpinButton,0,max,1),
    btn3 = create(GtkSpinButton,1,250,1),
    btn4 = create(GtkButton,"gtk-ok","Start")
    
    set(btn3,"value",10)
    set(btn2,"tooltip markup","<span color='yellow'><b><u>Start</u></b></span> Set the starting file number here")
    set(btn3,"tooltip markup","<span color='yellow'><b><u>Step</u></b></span> Number of programs to start at each pass")
    set(btn4,"tooltip markup","Click here to start the <span color='yellow'><b><u>next</u></b></span> set of tests")
    
    add(win,panel)
    add(panel,{lbl1,lbl2})
    add(box,{btn1,btn2,btn3,btn4})
    pack(panel,-box)
    
show_all(win)
main()

--------------------------
global function Start()
--------------------------
    i = get(btn2,"value as int")
    step = get(btn3,"value as int")
    tick = create(GTimeout,500,call_back(routine_id("Foo")))
    puts(1,"\n")
return 1
end function

--------------------------
global function Foo()
--------------------------
object fn

    fn = sprintf("test%d.ex",i)
    set(lbl2,"text",filename(fn))
    
    if not file_exists(fn) then
        printf(1,"%s not found!\n",{filename(fn)})
        set(lbl1,"text",get(lbl1,"text") & "\n" & filename(fn) & " missing!")
        set(win,"background","#F8E521")
    else
        system_exec(sprintf("eui %s &\n",{fn}))
        printf(1,"%s\n",{fn})
    end if
    
    i += 1
    if i >= max then
        Info(,,"That's all, Folks!",sprintf("%d demos",i))
        abort(0)
    end if

    set(btn2,"value",i)
    ct += 1
    
    if ct = step then
        ct = 0
        return 0
    else
        return 1
    end if
    
end function

    
