
-----------------------------------------------------------------------------
--# CSS import, fancy buttons, dialog background images, transparent dialog
-----------------------------------------------------------------------------

include GtkEngine.e

constant        
    css = create(GtkCssProvider,locate_file("test221.css")),
    win = create(GtkWindow,"name=Main,size=500x540,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,"CSS Tests"),
    box = create(GtkButtonBox,"spacing=10"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok#Plain","Plain"),
    btn3 = create(GtkButton,"gtk-ok#Fancy","Fancy"),
    btn4 = create(GtkButton,"gtk-ok#Transp","Transparent")
    
    add(win,pan)
    add(pan,lbl)
    add(box,{btn1,btn2,btn3,btn4})
    pack(pan,-box)
    
show_all(win)
main()

global function Plain()
return Info(,,"Test","Plain")
end function

global function Fancy()
return Info(,,"Fancy Dialog","with CSS Background",,,,,,,,,"FancyDialog") -- name it for css!
end function

global function Transparent()
return Info(,"Trans",
 "Transparent background","No icon\nMove me around!",,0,,,,,520,160,"TranspDialog")
end function

-- note: to make the transparent window frame invisible, set the Info dialog's
-- background color (8th parameter) to -1 .

