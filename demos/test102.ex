
--# Custom animated buttons

include GtkEngine.e

constant 
    ani_large = "thumbnails/dino_slo.gif",
    ani_small = "thumbnails/dino_mite.gif",

    win = create(GtkWindow,"border_width=10,position=1,icon=ani_small,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl1 = create(GtkLabel,"markup=<b><u>Custom Buttons</u></b>\n\t You can create your own!"),
    box = create(GtkButtonBox),
    btn = create(GtkButton,{
        {"label","Click Me!"},
        {"image",create(GtkImage,ani_small)},
        {"always show image",TRUE},
        {"connect","clicked","Foo"}
        })
    
    add(win,panel)
    add(panel,lbl1)
    add(box,btn)
    pack(panel,-box)

show_all(win)
main()

----------------------------------------------------------------
global function Foo()
----------------------------------------------------------------
    Info(win,"OK","Thank you",
        "<small>please click again sometime</small>",,ani_large,ani_small)
return 1
end function
