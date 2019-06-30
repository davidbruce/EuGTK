
--# Misc. buttons

include GtkEngine.e

constant 
    win = create(GtkWindow,"size=150x-1,position=1,border_width=10,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    box = create(GtkButtonBox,"margin-top=10"),
    quit_btn = create(GtkButton,"gtk-quit","Quit"),
    
    custom_button = create(GtkButton,,"Hasta_la_Vista"), -- a 'blank' button;
        btn_face = create(GtkBox), -- container for button contents;
        btn_img = create(GtkImage,"thumbnails/tiphat1.gif"), 
        btn_lbl = create(GtkLabel,"markup with mnemonic=<i>_Away We Go!</i>"),
    
    controls = {
        create(GtkLabel,"from stock ~ alt-o"),create(GtkButton,"gtk-ok"),
        create(GtkLabel,"\nwith hot-key ~ alt-c"),create(GtkButton,"_Click Me"),
        create(GtkLabel,"\ntoggle button ~ alt-t"),create(GtkToggleButton,"_Toggle Me"),
        create(GtkLabel,"\ncheck button ~ alt-m"),create(GtkCheckButton,"Check _Me!"),
        create(GtkLabel,"\ncustom button ~ alt-a"),custom_button 
        }

    add(custom_button,btn_face)
    add(btn_face,{btn_img,btn_lbl})
    add(win,panel)
    add(panel,controls)
    add(box,quit_btn)
    pack(panel,-box)

show_all(win)
main()

---------------------------------
global function Hasta_la_Vista()
---------------------------------
Info(win,"Adios","Bye","gotta go!")
Quit()
return 1
end function
