
----------------------------------------------------------------------------
--# Inline CSS is not really recommended, but it's easy enough to use;
----------------------------------------------------------------------------

include GtkEngine.e

ifdef WINDOWS then
	Info(,,"Inline CSS Styling",
	"Is not recommended for Windows,\nresults are unpredictable.")
end ifdef

sequence img = locate_file("thumbnails/nature.jpg")

sequence docs = `

<u><b>CSS styling</b></u>
      from in-line data`

constant styling = text:format(`

#mainwin { 
    background-image: url("[]");
    border-radius: 200px;
    }
#first {color: red;}
    
GtkLabel#cowsay {
    color: white; 
    text-shadow: 4px 4px #140B91;
    }

GtkButton:hover {
    background-color: #08F320;
    }
    
GtkButton:active {
    background-color: #F30808;
    }
`,{img})

constant
    css = create(GtkCssProvider,styling),
    win = create(GtkWindow,"name=mainwin,size=420x420,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl1 = create(GtkLabel,"name=first,font=14"),
    lbl2 = create(GtkLabel,"name=cowsay"),
    cow = create(GtkImage,"~/demos/thumbnails/cowbell.png"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit")
	
    set(lbl1,"markup",docs)
	set(lbl2,"font","Comic Sans MS, Purisa 48")
    set(lbl2,"markup","""MOO<span size="x-small">(n)</span>?""")
    add(win,pan)
    pack(pan,{lbl1,lbl2,cow})
    add(box,btn1)
    pack(pan,-box)
    
show_all(win)
main()
