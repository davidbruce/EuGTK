
------------------------------------------------------------------------------------
--# Using GtkPrinter.e, print from in-line or generated text;
------------------------------------------------------------------------------------

include GtkEngine.e
include GtkPrinter.e

include std/primes.e

constant docs = `Demos how to print from generated or in-line text.
<small>
We are using some <u>markup</u> to change the <big>size</big>
and <i>style</i> of this <b>paragraph</b>.

You can print in <span color='red'>color</span> using this feature,
as well as different <span font='Purisa, Georgia bold italic 12'>font styles.</span>
</small>
`
sequence list = prime_list(100) 
for i = 1 to length(list) do
	list[i] = sprintf("<span color='red'><b>%2d</b></span> = <b>%d</b>\n",{i,list[i]})
end for
list = flatten(list)

ifdef WINDOWS then 
    printer:font = "16"
end ifdef

constant win = create(GtkWindow,{
    {"border width",10},
    {"default size",300,100},
    {"position",GTK_WIN_POS_CENTER},
    {"icon","printer"},
    {"signal","destroy","Quit"}})

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)

constant img = create(GtkImage,"thumbnails/document-print.png")
    add(panel,img)
    
constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(panel,lbl)

printer:confirm = TRUE
printer:use_line_numbers = FALSE
printer:sourcecode = FALSE -- markup
printer:use_syntax_color=FALSE
printer:settings_file = "MyPrintSettings"
printer:setup_file = "MyPrintSetup"
ifdef WINDOWS then printer:font = "Consolas Regular 14" end ifdef

constant
    btn0 = create(GtkButton,"gtk-quit","Quit"),
    btn1 = create(GtkButton,"Print _1","PrintPrimes"), -- via a program function call;
    btn2 = create(GtkButton,"Print _2",printer:print_text,"Hello World!\nThis is a test."), -- from sequence 
    btn3 = create(GtkButton,"Print _3",printer:print_text,LGPL), -- from variable
    btn4 = create(GtkButton,"gnome-mime-application-pdf# _PDF","Print2PDF") -- direct to pdf
    
    set(btn0,"tooltip markup","<span color='red'>Alt+Q\n</span>Click to quit")
    
    set(btn1,"tooltip markup",
    "<span color='red'>Alt+1\n</span>Print 25 prime numbers via a <b><i>function</i></b> call")
    
    set(btn2,"tooltip markup",
    "<span color='red'>Alt+2\n</span>Print from text stored in a <b><i>sequence</i></b>")
    
    set(btn3,"tooltip markup",
    "<span color='red'>Alt+3\n</span>Print from text stored in a <b><i>variable</i></b>")
    
    set(btn4,"tooltip markup",
    "<span color='red'>Alt+P\n</span>Print to a <b><i>PDF</i></b> file in your home directory")

constant
    btnbox = create(GtkButtonBox)
    set(btnbox,"spacing",5)
    pack(panel,-btnbox)
    add(btnbox,{btn0,btn1,btn2,btn3,btn4})

constant box2 = create(GtkButtonBox),
    btn5 = create(GtkCheckButton,"_Confirm Print Status/preview pdf")
    set(btn5,"active",TRUE)
    pack(panel,-box2)
    add(box2,btn5)
    
show_all(win)
main()

------------------------------------------------------------------------
global function PrintPrimes()
------------------------------------------------------------------------
    printer:use_markup=TRUE
    printer:plaintext = FALSE
    PrintText("First 25 Prime Numbers",list) -- title, text
    printer:reset()
return 1
end function

------------------------------------------------------------------------
global function Print2PDF() 
------------------------------------------------------------------------
    printer:reset()
    printer:sourcecode = FALSE -- don't use syntax colors, use markup;
    printer:confirm = get(btn5,"active")
    printer:use_line_numbers = FALSE
    printer:action = GTK_PRINT_OPERATION_ACTION_EXPORT
    printer:export_file = canonical_path("~/test191_out.pdf") 
    PrintText(text:format("Saved as PDF: []",{export_file}),docs & list) 
    printer:reset()
return 1
end function


