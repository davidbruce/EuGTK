
----------------------------------------------------------------
--# GtkEntry used for password entry
----------------------------------------------------------------

include GtkEngine.e

constant pass = {254,8,121,106,124,124,128,120,123,109}

constant 
    win = create(GtkWindow,"size=300x100,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    img = create(GtkImage,"thumbnails/dialog-password.png"),
    lbl1 = create(GtkLabel,"Authorized Personnel Only\nEnter your password:"),
    input = create(GtkEntry,{
	{"max length",10},    -- 10 characters; 
	{"visibility",FALSE}, -- use as password entry;
	{"icon from stock",0,"gtk-caps-lock-warning"},
	{"tooltip markup",
	    format(`Hint: Password is <b><i>[1]</i></b>
	    <small>(shhh! don't tell!)</small>`,deserialize(pass))}})
	    
    connect(input,"changed",_("InputChanged"))
	
    add(win,panel)
    add(panel,{img,lbl1,input})
    
show_all(win)
main()

-------------------------------------------------------------------
function InputChanged()
-------------------------------------------------------------------
set(input,"progress fraction",get(input,"text length")* 0.10)
sequence pw = deserialize(pass) 
if equal(pw[1],get(input,"text")) then
    set(img,"from file","thumbnails/passgrn.png")
    set(input,{
	{"icon from stock",1,"gtk-media-play"},
	{"icon activatable",1,TRUE},
	{"connect","icon-press",_("PassOK")}})
end if
return 1
end function

------------------------------------------------------------------------
function PassOK()
------------------------------------------------------------------------
Info(0,"OK","Your password was correct!","You may now enter the inner sanctum")
return 1
end function
