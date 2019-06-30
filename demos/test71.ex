
--------------------------------------------------------------------------------------
--# Icon Themes

-- GTK comes with a large number of named icons. 
-- Run ~/demos/examples/utilities/icons.ex to see them, organized by category.
--------------------------------------------------------------------------------------

include GtkEngine.e

-- we can provide a list of possible icons, first valid name is returned:
object selected_icon = valid_icon_name({"face-coolz","face-glasses","face-laugh","gtk-ok"})

constant 
    win = create(GtkWindow,"position=1,border_width=10,$destroy=Quit"),
    panel = create(GtkBox,VERTICAL),
    img = create(GtkImage,selected_icon),
    lbl = create(GtkLabel,"markup=<b><u>Themed Icons</u></b>\nEnter an icon name"),
    inp = create(GtkEntry,{{"text",selected_icon}}),
    box = create(GtkButtonBox,"margin top=5"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-apply","Foo")	

    connect(inp,"activate","Foo")
		
    add(win,panel)
    add(panel,{img,lbl,inp})
    add(box,{btn1,btn2})
    pack(panel,-box)
    
show_all(win)
main()

--------------------------------------------------
global function Foo()
--------------------------------------------------
    set(img,"from icon name",get(inp,"text"),GTK_ICON_SIZE_DIALOG)
return 1
end function

