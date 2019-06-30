
------------------------------------------------------------------------
--# GtkTreeStore 
------------------------------------------------------------------------
-- Hard to understand, difficult to make it easy to use.
-- However, this does work for nested sequences 
-- up to a point, as long as the data is all strings.
------------------------------------------------------------------------ 

include GtkEngine.e


object store = create(GtkTreeStore,{gSTR,gSTR})

sequence os = {
    {"Windows","An Operating? System",
        {"Bill Gates"}},
    {"Linux","An Operating! System",
        {"Linus Torvalds"}},
    {"Mac","A Religion",
        {"Steve Jobs",
        "The Woz",
            {"Billy (the kid)",
                {"Bowser","Fido"},
             "Susan (the other kid)",
                {"Grumpy Cat"}
            }
        }
    }
}
set(store,"data",os)

constant 
    col1 = create(GtkColumn,"title=OS,type=text,markup=1,sort_column_id=1"),
    col2 = create(GtkColumn,"title=Notes,type=text,markup=2,sort_column_id=2")
    
constant tv  = create(GtkTreeView,{
    {"model",store},
    {"append columns",{col1,col2}},
    {"enable tree lines",TRUE},
    {"rules hint",TRUE}, 
    {"hover expand",TRUE},
--  {"expand all"},
    $})
    
constant selection = get(tv,"selection") 

constant 
    win = create(GtkWindow,"size=250x400,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,VERTICAL),
    btn2 = create(GtkToggleButton,"gtk-ok#Expand","Expand"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    box = create(GtkButtonBox)

    add(win,panel)
    pack(panel,tv,TRUE,TRUE,5)
    add(box,{btn1,btn2})
    pack(panel,-box)
    
show_all(win)
main()

------------------------
global function Expand()
------------------------
    if get(btn2,"active") then
        set(tv,"expand all")
    else
        set(tv,"collapse all")
    end if
return 1
end function
 



