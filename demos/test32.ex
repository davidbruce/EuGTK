
-------------------------------------------------------------------------------------------
--# Info dialogs; Numerous options allow customization
-------------------------------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"size=200x100,border_width=10,position=1,$destroy=Quit"),
    tux = create(GdkPixbuf,"thumbnails/BabyTux.png"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl = create(GtkLabel,"markup=Click OK to open a <b><u>Custom Dialog</u></b>"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","Foo")
    
    set(win,"icon",tux)
    set(box,"layout",GTK_BUTTONBOX_EDGE)

    add(win,panel)
    add(panel,lbl)
    add(box,{btn1,btn2})
    pack_end(panel,box)

show_all(win)
main()

-----------------------------------------------------------------------------
global function Foo() -- use markup and custom image in Info dialog;
-----------------------------------------------------------------------------
Info(win,
    "About Penguins",
    "\n<big><i>Penguins</i></big>",
	`<small><span color='blue'>
	(1) They eat little-bitty fish
	(2) They live far, far away
	(3) They aren't as small as you might think!
	</span></small>`,,tux,tux)
return 1
end function



