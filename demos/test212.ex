
--# Css Styling (note paper)

include GtkEngine.e

constant -- (replace lined_paper with tartan or stripes for different backgrounds);
    win = create(GtkWindow,"name=lined_paper,title=Main Window,size=400x250,border=10"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl = create(GtkLabel),
    btnbox = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-about","About"),
    css = create(GtkCssProvider,"resources/css_multiplebgs.css")

    set(lbl,"markup","Now is the time\nfor all good men\nto come to the aid\nof the country.")
    ifdef UNIX then set(lbl,"font","Purisa 16") end ifdef
    ifdef WINDOWS then set(lbl,"font","Segoe Script 16") end ifdef
    add(win,panel)
    add(panel,lbl)
    
    pack_end(panel,btnbox)
    add(btnbox,{btn1,btn2})

show_all(win)
main()

------------------------
global function About()
------------------------
return Info(,,"<span color='white' font='12'>CSS Generated Backgrounds</span>",
    "<span color='yellow'><small>See resources/css_multiplebgs.css</small></span>")
end function
