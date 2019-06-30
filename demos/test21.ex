
----------------------------------------------------------------
--# GtkCombo with model, cell renderers and bitmaps
----------------------------------------------------------------

include GtkEngine.e

sequence desserts = {
    {"thumbnails/cake.png",   " Strawberry Cake"},
    {"thumbnails/pie.png",    " Pecan Pie"},
    {"thumbnails/BabyTux.png"," Pickled Herring"}
    }

for i = 1 to length(desserts)  do -- convert filename to a pointer to the pixbuf;
    desserts[i][1] = create(GdkPixbuf,desserts[i][1],30,30,1)
end for

constant 
    win = create(GtkWindow,"size=160x100,border=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    lbl = create(GtkLabel,"markup=<b><u>Choose a dessert</u></b>\n\tfrom the drop-down list below:"),
    combo = create(GtkComboBox,"margin-top=10"),
    mdl = create(GtkListStore,{gPIX,gSTR})
    
    add(win,panel)
    add(panel,{lbl,combo})
    set(mdl,"data",desserts)
    set(combo,"model",mdl)

-- the following code inserts an image and some text in each cell of the drop-down combo;
constant pixrend = create(GtkCellRendererPixbuf)
constant txtrend = create(GtkCellRendererText)  

CellArea cell_area = get(combo,"property","cell-area")
    set(cell_area,{ 
	{"add",pixrend},
	{"add",txtrend},
	{"attribute connect",pixrend,"pixbuf",1},
	{"attribute connect",txtrend,"text",2}})

show_all(win) 
main()


