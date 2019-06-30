
--# Input form with enter key that works like Windows users expect;

include GtkEngine.e
include GtkEvents.e

constant
    win  = create(GtkWindow,"size=300x-1,border=10,$destroy=Quit"),
    pan  = create(GtkBox,"orientation=vertical,spacing=10"),
    inp1 = create(GtkEntry,"placeholder text=Name"),
    inp2 = create(GtkEntry,"placeholder text=Addr"),
    inp3 = create(GtkEntry,"placeholder text=City"),
    inp4 = create(GtkEntry,"placeholder text=Zip"),
    box  = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-about","About"),
    btn3 = create(GtkButton,"gtk-ok","ShowData")
    
    connect({inp1,inp2,inp3,inp4},"activate","trap_enter_key") --[1]

    add(win,pan)
    add(pan,{inp1,inp2,inp3,inp4})
    add(box,{btn1,btn2,btn3})
    pack(pan,-box)

show_all(win)
set(btn1,"can focus",FALSE)
set(btn3,"grab focus") 
-- move focus to btn to make first inp field placeholder visible;
main()
   
-----------------------------   
global function ShowData() --
-----------------------------
object 
    name = get(inp1,"text"),
    addr = get(inp2,"text"),
    city = get(inp3,"text"),
    zip  = get(inp4,"text")
    
if length(name) = 0 then 
    set(inp1,"grab focus") -- just go to first input box;
else
   Info(,,name,text:format("Addr: []\nCity: []\nZip: []",
    {addr,city,zip}))
   set(inp1,"grab focus") -- display and go to first inp box;
end if

return 1
end function

--------------------------
global function About() --[1]
--------------------------
return Info(win,"About","Input form",
`    
   This demos a way to make input forms
    where the <i>&lt;enter&gt;</i> key moves from
    field to field as expected by Windows users.
    
    Linux, by default, uses the TAB key for this.
    
    By connecting to the <i>trap_enter_key</i>
    function (in GtkEvents.e), you can make your
    program truly cross-platform.  
`)
end function
