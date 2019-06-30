with define PP
------------------------------------------------------------------------------
--# GtkPrinter - progressbar, page headers, etc.
------------------------------------------------------------------------------

include GtkEngine.e
include GtkPrinter.e

constant docs = `markup=<b><u>Printing</u></b>
Print a long file with heading and page numbers.
In this case: GtkEngine.e.

Includes an optional progress-bar to show what's happening.
`
-- header for first page;
    printer:header = "<span font='Georgia bold 16'><b>[1]</b>"
	& "                                         "
	&"<span font='10'> Page [5] of [6]</span></span> \n\n"

-- header for subsequent pages;
    printer:subheader = "<span font='Georgia 14'><b>[1]</b>"
	& "                                                 "
	&"<span font='10'>Page [5]</span></span> \n\n"
	
ifdef WINDOWS then
-- header for first page;
    printer:header = "<span font='Georgia bold 16'><b>[1]</b>"
	& "                                         "
	&"<span font='10'> Page [5] of [6]</span></span> \n\n"

-- header for subsequent pages;
    printer:subheader = "<span font='Georgia 14'><b>[1]</b>"
	& "                                                 "
	&"<span font='8'>Page [5]</span></span> \n\n"
	
	printer:font = "8"
	
	Info(,"Caution","Windows Users","Windows 10 fake printers don't work, get CutePDF or something similar")
end ifdef

constant 
	win = create(GtkWindow,"border=10,position=1,$destroy=Quit"),
	panel = create(GtkBox,VERTICAL,5),
	lbl = create(GtkLabel,docs),
	img = create(GtkImage,"thumbnails/document-print.png"),
	box = create(GtkButtonBox),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-print",print_file,canonical_path(locate_file("GtkEngine.e")))
	
	
    add(win,panel)
    add(panel,{lbl,img})
    add(box,{btn1,btn2})
    pack(panel,-box)
    
    pack(panel,printer:progress)
    set(printer:progress,"show text",TRUE)

    printer:use_line_numbers = TRUE
    printer:sourcecode = TRUE
    printer:parent = win

 
show_all(win)
set(printer:progress,"hide") -- hide it until printing is started.
main()








