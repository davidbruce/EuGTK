
------------------------------------------------------------------------------------
--# Using GtkPrinter.e
------------------------------------------------------------------------------------

include GtkEngine.e
include GtkPrinter.e

integer fn = open(canonical_path(locate_file("resources/license.txt")),"r")

constant docs = `Demo of how to print from a filename or file handle.
`
constant win = create(GtkWindow,{
    {"border width",10},
    {"default size",300,100},
    {"position",GTK_WIN_POS_CENTER},
    {"connect","destroy","Quit"}})

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)

constant icon = create(GtkImage,"~/demos/thumbnails/printer-icon.png")
    add(panel,icon)
    
constant lbl = create(GtkLabel,docs)
    add(panel,lbl)

constant 
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-print","PrintLGPL"), -- from a function;
    btn3 = create(GtkButton,"gtk-print",printer:print_file,fn), -- from  file handle;
    btn4 = create(GtkButton,"gtk-print",printer:print_file,locate_file("GtkEvents.e")), -- from file;
    box = create(GtkButtonBox)
    
    set(btn2,"tooltip text","Print using a user function")
    set(btn3,"tooltip text","Print from file handle attached to button")
    set(btn4,"tooltip text","Print from file path/name attached to button")
    
    add(box,{btn1,btn2,btn3,btn4})
    pack(panel,-box)

show_all(win)

main()

------------------------------------------------------------------------
global function PrintLGPL()
------------------------------------------------------------------------
    printer:use_line_numbers = FALSE
    printer:use_syntax_color = FALSE
    printer:PrintFile("Lesser General Public License\n",fn)
    printer:use_line_numbers = TRUE
    printer:use_syntax_color = TRUE
return 1
end function
