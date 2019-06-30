
-----------------------------------------------------------------------
--# Progress bar
-----------------------------------------------------------------------
-- Normally the progress percentage would be set by some code
-- during a long process, such as reading a file, processing data, etc.
-- perhaps being called as a separate 'watchdog' task using Eu tasks.

-- For demo purposes we take the easy way out and provide up and down 
-- buttons, just so you can see how it works.
------------------------------------------------------------------------

include GtkEngine.e
include std/math.e -- for ensure_in_range

enum STEP=0, PULSE 
boolean mode = STEP

constant 
	win = create(GtkWindow,"title=`Progress Bar`,border=10,position=1,$destroy=Quit"),
	panel = create(GtkBox,"orientation=VERTICAL,spacing=10"),
	pb = create(GtkProgressBar,"show_text=TRUE"),
	box = create(GtkBox,"orientation=HORIZONTAL,spacing=10"),
	leftbtnbox = create(GtkButtonBox,"orientation=VERTICAL,spacing=10,layout=3"),
	rightbtnbox = create(GtkButtonBox,"orientation=VERTICAL"),
	dnbtn = create(GtkButton,"back#_Back",_("Update")),
	upbtn = create(GtkButton,"forward#_Forward",_("Update")),
	perbtn = create(GtkRadioButton,0,"_Percentage\nMode",_("SelectMode"),0),
	actbtn = create(GtkRadioButton,perbtn,"_Activity\nMode",_("SelectMode"),1),
	quitbtn = create(GtkButton,"gtk-quit","Quit"),
	showtxt = create(GtkCheckButton,"Show _Txt",_("ShowText"))

	add(win,panel)
	add(panel,pb)
	add(panel,box)
	add(leftbtnbox,{dnbtn,upbtn,quitbtn})
	add(rightbtnbox,{actbtn,perbtn,showtxt})
	pack(box,{leftbtnbox,rightbtnbox})

	set(dnbtn,"tooltip text= Click to subtract 10%,sensitive=FALSE")
	set(upbtn,"tooltip text=Click to add 10%,sensitive=TRUE")
	set(perbtn,"tooltip text=Select this button to show % of progress")
	set(actbtn,"tooltip text=Select this button to show activity mode")
	set(showtxt,"tooltip text=Select whether to show status as text")
	set(showtxt,"active",TRUE)

-- Important: you must always call timeout with a call_back address
constant tick = create(GTimeout,100,_("Pulse"))

show_all(win)
main()

-------------------------------------------------------------
function Update(atom ctl)
-------------------------------------------------------------
-- get current setting;
atom percentage = get(pb,"fraction") 

switch ctl do -- respond to buttons by adjusting percentage
	case upbtn then percentage += .1
	case dnbtn then percentage -= .1
end switch

-- limit percentage to range of 0..100%;
    percentage = ensure_in_range(percentage,{0,1})

-- enable/disable buttons as needed;
if percentage < .01 then -- can't go down any lower, so
	set(dnbtn,"sensitive",FALSE)  -- disable down button
	set(upbtn,"sensitive",TRUE)   -- enable up button
	
elsif percentage > .99 then -- can't go up any higher
	set(upbtn,"sensitive",FALSE)
	set(dnbtn,"sensitive",TRUE)
	
else -- somewhere in middle of range, can go either way
	set(upbtn,"sensitive",TRUE)
	set(dnbtn,"sensitive",TRUE)
	
end if

-- update displayed values. progress text can be anything, not just %
 set(pb,"text",sprintf("%2.0f%%",percentage*100))
 set(pb,"fraction",percentage)
 
return 1
end function

--------------------------------------------------
function SelectMode(atom ctl, boolean x)
--------------------------------------------------
if get(ctl,"active") then
	mode = x
	if mode = PULSE then
		set(upbtn,"sensitive",FALSE)
		set(dnbtn,"sensitive",FALSE)
	end if
end if
return 1
end function

-------------------------
function Pulse() 
-------------------------
if mode = 1 then 
	set(pb,"pulse")
	set(pb,"text","Working...")
else
	Update(pb)
end if
return 1
end function

------------------------------------
function ShowText(atom ctl)
------------------------------------
set(pb,"show text",get(ctl,"active"))
return 1
end function

