
------------------------------------------------------------------------------------
--# GtkEntryCompletion
------------------------------------------------------------------------------------

include GtkEngine.e

sequence fruits = {
    "Apple",
    "Banana",
    "Blackberry",
    "Blueberry",
    "Durian",
    "Orange",
    "Peach",
    "Pear",
    "Pomegranite",
    "Prune",
    $}

constant 
    win = create(GtkWindow,"size=150x100,border=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl1 = create(GtkLabel,"markup=<b><u>GtkEntryCompletion</u></b>"),
    input1 = create(GtkEntry,"margin left=100,margin right=100"),
    lbl2 = create(GtkLabel,"justify=center,markup=Enter the name of a fruit that starts with <b>b</b> or <b>p</b>"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","ShowChoice"),
    btn3 = create(GtkButton,"gtk-help","Help")
    
constant ec_mdl = create(GtkListStore,{gSTR})
    
constant completion = create(GtkEntryCompletion,{
    {"model",ec_mdl},
    {"text column",1},
    {"popup set width",FALSE},
    {"insert action markup",5,"<i>Add to list</i>"},
    {"connect","action-activated",_("AddItem")}})

    set(input1,"completion",completion)
    set(ec_mdl,"data",fruits)

    add(win,panel)
    add(panel,{lbl1,input1,lbl2})	
    pack(panel,-box)
    add(box,{btn1,btn2,btn3})

show_all(win)
main()

----------------------------
global function ShowChoice()
----------------------------
    Info(win,"You chose",get(input1,"text"),"as your favorite")
    set(input1,"overwrite mode",FALSE)
    set(input1,"grab focus")
return 1
end function

------------------------------
function AddItem()
------------------------------
object newitem = get(input1,"text") 
    set(ec_mdl,"append row",newitem) -- add input item to list;
return 1
end function

--------------------------------
global function Help()
--------------------------------
Info(win,"Help","GtkEntryCompletion",
"""
A widget that automatically pops 
up a list of items which match 
the input typed 'thus far'.

You can add a new name to the list.
""")
return 1
end function




