 
--# Custom Buttons with images, etc...
 
include GtkEngine.e
 
enum NAME, PRICE, PIX
 
sequence
 desserts = { -- an easily expanded list;
 {"Pumpkin Pie",  1.95, "thumbnails/pie.png"},
 {"Birthday Cake",2.25, "thumbnails/cake.png"},
 $}
 
constant
    win = create(GtkWindow,"border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lb1 = create(GtkLabel,"Flo's Bakery\nDessert Menu"),
    lb2 = create(GtkLabel,"font=8,label=Table Number"),
    tbl = create(GtkSpinButton,1,10,1)
    
    set(lb1,"font","cursive bold 16")
    add(win,pan)
    add(pan,{lb1,lb2,tbl})

    for i = 1 to length(desserts) do -- make as many buttons as needed;
       desserts[i][PIX] = create(GdkPixbuf,desserts[i][PIX],100,100)
       atom btn = create(GtkButton,,"Order",desserts[i])
       set(btn,{
        {"label",desserts[i][NAME]},
        {"image",desserts[i][PIX]},
        {"always show image",TRUE}}) 
       add(pan,btn)
    end for
    
 show_all(win)
 main()

 -----------------------------------------------
 global function Order(atom ctl, object data) -- must be object
 -----------------------------------------------
 data = unpack(data) & get(tbl,"value")
 Beep()
 return Info(win,"Order Up!",
        format("\n<big><b>[1]</b></big>\nfor table [4]",data),
        format("Price: <b>$[2.2]</b>",data),,data[PIX],,"red",,,2,2)
 end function
