
--# Passing Euphoria routines attached to buttons

include GtkEngine.e

constant docs = `<b><u>Passing Euphoria Routines</u></b>
Here, we send upper(), lower(), and proper()
Euphoria routine-ids to our user-written routine,
depending upon which button is pushed.`

constant txt = "nOw IS the tImE FOR all gOOd men to CoMe to the AiD of thE pArTy."

constant 
    win = create(GtkWindow,"size=300x100,position=1,border_width=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl1 = create(GtkLabel,{{"markup",docs}}),
    sep = create(GtkSeparator,"margin_top=10,margin_bottom=10"),
    lbl2 = create(GtkLabel,txt),
    btnbox = create(GtkButtonBox,"margin_top=10")

integer fn = _("Fn") -- convert local function Fn to a call-back;

constant btn1 = create(GtkButton,"Proper",fn,routine_id("proper"))
constant btn2 = create(GtkButton,"Lower",fn,routine_id("lower"))
constant btn3 = create(GtkButton,"Upper",fn,routine_id("upper"))
constant btn4 = create(GtkButton,"gtk-revert-to-saved",fn,0)
    
    add(win,panel)
    add(panel,{lbl1,sep,lbl2})
    add(btnbox,{btn1,btn2,btn3,btn4})
    pack(panel,-btnbox)

show_all(win)
main()

------------------------------------------------------------------------
function Fn(atom ctl, atom fn)
------------------------------------------------------------------------
if fn = 0 then
    set(lbl2,"markup",txt)
else
    set(lbl2,"markup",call_func(fn,{txt}))
end if
return 1
end function
