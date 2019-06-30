
------------------------------------------------------------------------------------
--# Using GtkPrinter.e, print from a disk file;
------------------------------------------------------------------------------------

include GtkEngine.e
include GtkPrinter.e

printer:font="Arial 12"

constant 
    docs = "Demo of how to print from a disk file",
    win = create(GtkWindow,"border=10,size=300x100,position=1,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,docs),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-print",_("SelectFile")),
    btn3 = create(GtkButton,"gtk-print",_("PrintCard"),"~/demos/resources/license.txt"),
    -- for use when printing the index card:
    custom_header = 
		"<span background='cyan' color='red' font='Purisa, Ubuntu Mono, Serif 10'>" &
		"<i><b> [1] </b></i>         </span>\n\n",
    custom_footer = 
		"<small><span color='blue'><i>Please leave this 3x5 card on [10]'s desk!</i>\n</span></small>"
   
    set(btn2,"tooltip markup","This prints on letter paper with the default header")
    set(btn3,"tooltip markup","This prints a 3x5 index card with custom header") 

	add(win,pan)
	add(pan,lbl)
	add(box,{btn1,btn2,btn3})
	pack(pan,-box)
	
show_all(win)
main()

------------------------------------------------------------------------
function SelectFile()
------------------------------------------------------------------------
object filename, extension
object dlg = create(GtkFileChooserDialog,{
    {"title","Open a file"},
    {"transient for",win},
    {"action",GTK_FILE_CHOOSER_ACTION_OPEN},
    {"add button","gtk-cancel",MB_CANCEL},
    {"add button","gtk-ok",MB_OK}})

    if run(dlg) = MB_OK then
        printer:reset() -- use defaults
        printer:paper_name = "na_letter"
        printer:show_progress=TRUE
        filename = get(dlg,"filename")
        extension = fileext(filename)
        if equal("e",extension) or equal("ex",extension) then
    		printer:use_syntax_color=TRUE
    		printer:use_line_numbers=TRUE
    	end if 

        printer:PrintFile(filename)
    end if
    destroy(dlg)
    
return 1
end function

------------------------------------------------------------------------
function PrintCard(atom ctl, object name)
------------------------------------------------------------------------
    printer:reset()
    printer:paper_name = "na_index-3x5"
    printer:orientation = 1
    printer:font = "Ubuntu 6"
    printer:top_margin = .1
    printer:use_line_numbers = FALSE
    printer:header = custom_header
    printer:footer = custom_footer
    
    name = canonical_path(unpack(name)) -- load the LGPL boilerplate:
    if file_exists(name) then
        PrintFile("LGPL",name)
    else
        Error(win,,"File not found",name)
    end if
    
return 1
end function

