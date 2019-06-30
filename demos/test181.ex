
--# Passing key/value pairs, accessed by key;
--  See test179 for a different way, using a map;

include GtkEngine.e

constant docs =
`
<u><b>Passing Key/Value pairs</b></u>

Another way to attach data to controls, 
and retrieve data by<i><b> field name</b></i>,
rather than by position.
Therefore, field order can be random.

`
constant sam = {"name=Sam Smith","bal=6.45","city=Buffalo","phone=000-555-1212"}
constant joe = {"bal=44.22", "name=Joe Jones","phone=123-456-7890","city=Reno"}

constant 
    win = create(GtkWindow,"size=300x100,border=10,$destroy=Quit"), 
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok#_Sam","Foo",sam),
    btn3 = create(GtkButton,"gtk-ok#_Joe","Foo",joe),
    box = create(GtkButtonBox)
    
    set(lbl,"markup",docs)
    
    add(box,{btn1,btn2,btn3})
    add(pan,lbl)
    pack(pan,-box)
    add(win,pan)
    
show_all(win)
main()

------------------------------------------
global function Foo(atom ctl, object data)
------------------------------------------
data = unpack(data) -- convert back to named k/v sequence
    Info(win,"Data",
        format("[{name}]",data),
        format("[{phone}]    <b>$[{bal}]</b>",data))
return 1
end function


