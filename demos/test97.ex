
--# Passing data using multiple maps

include GtkEngine.e
include std/io.e
include std/map.e
include std/base64.e

constant docs = `
This creates a separate map for each person, and 
passes just that map to the called routine.

Each field must be named, and can be accessed later by
name rather than position.

Maps can be saved to disk, and loaded as necessary.
`
constant 
    jerrymap = load_map(locate_file("resources/Jerry.map")),
    justinmap = load_map(locate_file("resources/Justin.map")),

    win = create(GtkWindow,"border=10,size=300x100,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl1 = create(GtkLabel,"markup=<u><b>Passing Data</b></u> Using Maps"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"emblem-ok-symbolic#_Jerry","ShowInfo",jerrymap), -- link by map id;
    btn3 = create(GtkButton,"emblem-ok-symbolic#_Justin","ShowInfo",justinmap),
    btn4 = create(GtkButton,"gtk-save","Save"),
    box = create(GtkButtonBox),
    lbl2 = create(GtkLabel,
        {{"markup",
        """
        This creates a separate map for each person, and 
        passes just that map to the called routine.

        Each field must be named, and can be accessed later by
        name rather than position.

        Maps can be saved to disk, and loaded as necessary.
        """}})
    
    add(win,panel)
    add(panel,{lbl1,lbl2})
    add(box,{btn1,btn2,btn3,btn4})
    pack(panel,-box)

show_all(win)
main()

--------------------------------------------------------------
global function ShowInfo(atom ctl, object amap) -- map id passed
---------------------------------------------------------------
amap = pairs(amap) 
for i = 1 to length(amap) do
    amap[i] = text:format("[]=[]",amap[i])
end for

Info(,"Student",
    text:format("Name: [{name}]",amap), -- retrieve items by key;
    text:format(" age: [{age}]\n bal: $[{bal}]",amap),,
    locate_file(text:format("[{pix}]",amap)))
return 1
end function

-------------------------
global function Save()
-------------------------
-- here's how to save a couple of maps
-- either way works, use whichever is easier;

map a = map:new_from_kvpairs({
    {"name","Jerry Smith"},
    {"age",`16`}, -- note, numbers must be quoted somehow;
    {"bal",`49.95`},
    {"city","Buffalo NY"},
    {"phone","000-555-1212"},
    {"pix","thumbnails/Jerry.jpg"}})
    
map b = map:new_from_string("""
    name="Justin Jones",
    age='14',
    bal='12.99', 
    city="Reno, NV",
    phone=123-456-6789,
    pix=thumbnails/Justin.jpg""")

-- SM_RAW map is encoded, so not readable except to a programmer,
-- and the file is Binary mime type, so no apps to read it are usually available;
save_map(a,canonical_path("~/demos/resources/Jerry.map"),SM_RAW)
save_map(b,canonical_path("~/demos/resources/Justin.map"),SM_RAW)

dump(pairs(a),"resources/Jerry.enc")
return 1
end function
