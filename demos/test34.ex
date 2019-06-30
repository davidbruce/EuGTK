
--------------------------------------------------------------------------------
--# GtkGrid - simple demo
--------------------------------------------------------------------------------

include GtkEngine.e

constant docs = `<u><b>GtkGrid</b></u>
The GtkGrid allows you to lay out items neatly.
There are several different ways to do this.
See tests 37, 39, and 143 for other ways.
`
constant 
    cow = create(GtkImage,"thumbnails/cowbell.png"),
    fox = create(GtkImage,"thumbnails/fox.png"),
    fish = create(GtkImage,"thumbnails/fish.png"),
    mouse = create(GtkImage,"thumbnails/mouse.png"),
    tux = create(GtkImage,"thumbnails/BabyTux.png"),

    win = create(GtkWindow,"size=300x300,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl1 = create(GtkLabel),
    grid = create(GtkGrid),
    lbl2 = create(GtkLabel)
    
    set(lbl1,"markup",docs)

    add(win,panel)
    add(panel,lbl1)
    add(panel,grid)
    add(grid,cow)
    set(grid,{
	{"attach above",cow,fox,1,1},
	{"attach beside",cow,fish,LEFT,1,1},
	{"attach beside",cow,mouse,RIGHT,1,1},
	$})

-- below is a formatted copy of the code above for display
set(lbl2,"font","10") 
set(lbl2,"markup",`<b><u>Source:</u></b>
<b>add</b>(grid,cow)
<b>set</b>(grid,{
    {"attach above",cow,fox,1,1},
    {"attach beside",cow,fish,LEFT,1,1},
    {"attach beside",cow,mouse,RIGHT,1,1}})`)
-- end of markup source code;

add(panel,lbl2)
show_all(win)
main()
