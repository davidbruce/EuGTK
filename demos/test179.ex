
--# Passing data using a single k/v map, accessed by key;
--  See also test181 for a different way, without using map;

include GtkEngine.e
include std/map.e

constant docs = `<u><b>Passing data using a Map</b></u>
Another way to attach data to controls, 
and retrieve data by field-name. 

This stores all data in a single map.
Fields can be entered in random order, but 
each field must be named. 
`
object x = map:new() -- uses named keys, so data can be entered in random order;

map:put(x,"jerry","name=Jerry Smith,bal=39.99,age=15,pix=thumbnails/Jerry.jpg")
map:put(x,"justin","name=Justin Jones,pix=thumbnails/Justin.jpg,age=14,bal=12.99")

constant 
    win = create(GtkWindow,"border=10,size=300x100,position=1,$destroy=Quit"),
    pan = create(GtkBox,"orientation=VERTICAL"),
    lbl = create(GtkLabel),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok#Jerry","ShowInfo","jerry"),-- linked by names;
    btn3 = create(GtkButton,"gtk-ok#Justin","ShowInfo","justin"),
    box = create(GtkButtonBox)

    set(lbl,"markup",docs)
    
    add(win,pan)
    add(pan,lbl)
    pack(pan,-box)
    add(box,{btn1,btn2,btn3})

show_all(win)
main()

------------------------------------------------
global function ShowInfo(atom ctl, object key)
------------------------------------------------
key = unpack(key)   -- retrieve passed name (e.g. jerry)
object data = keyvalues(map:get(x,key),,,,"\t\n\r") 
--display(data)
for i = 1 to length(data) do -- convert back to key=val format;
    data[i] = text:format("[]=[]",data[i])
end for
--display(data)
Info(,,
    format("[{name}]",data), -- retrieve items by fieldname;
    format(" age: [{age}]\n bal: $[{bal}]",data),,
    format("[{pix}]",data)) 
return 1
end function

