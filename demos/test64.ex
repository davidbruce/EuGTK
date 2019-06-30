
----------------------------------------------------------------------------------------------
--# Custom Tooltips - routine to build fancier tooltips with images, etc...
----------------------------------------------------------------------------------------------

include GtkEngine.e

constant txt = {
    "Click to <b><i>exit</i></b>",
    "Click button to see <b><u>help</u></b>"
    }

constant img = {
    create(GdkPixbuf,"thumbnails/clown.png",80,80,1),
    create(GdkPixbuf,"thumbnails/gtk-logo-rgb.gif",80,80,1)
    }
    
constant 
    win = create(GtkWindow,"title=Custom Tooltips,border_width=10,$destroy=Quit"),
    panel = create(GtkBox,VERTICAL),
    photo = create(GtkImage,"thumbnails/jeff.jpg"),
    lbl1 = create(GtkLabel,"Hover over the buttons..."),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-help","Help")
    
    set(btn1,"has tooltip",TRUE)
    connect(btn1,"query-tooltip","MakeCustomTooltip") -- call custom tip builder func;
    
    set(btn2,"has tooltip",TRUE)
    connect(btn2,"query-tooltip","MakeCustomTooltip") -- call custom tip builder func;

    add(win,panel)
    add(panel,{photo,lbl1})
    add(box,{btn1,btn2})
    pack(panel,-box)
    
show_all(win)
main()

-- must write a function to build a custom tooltip on 'query-tooltip' signal;
-------------------------------------------------------------------------------------------------------------------
global function MakeCustomTooltip(atom b, integer x, integer y, atom mode, Tooltip tip) 
-------------------------------------------------------------------------------------------------------------------
integer n = 0
    switch b do
	case btn1 then n = 1
	case btn2 then n = 2
    end switch
    set(tip,"icon",img[n])
    set(tip,"markup",txt[n])
return 1
end function

------------------------------------------------------------------------
global function Help()
------------------------------------------------------------------------
return Info(win,"Help","Some help",
	"could appear here,\nif I weren't too lazy to type some...",,,img[2])
end function
