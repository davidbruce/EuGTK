
------------------------------------------------------------------------
--# Print Unix dialog (don't use)

-- This demo is meant to show some of the low-level 
-- calls you could make if you were a glutton for punishment.

-- Forget you ever saw this, and use the GtkPrinter.e routines instead!
------------------------------------------------------------------------

include GtkEngine.e
include GtkPrinter.e

include std/math.e

constant docs = `<u><b>Print Unix Dialog</b></u>
Click button to pop up a dialog box.
<i>
 Note: be sure you have a printer set up 
 because each printer has different options,
 therefore different tabs will appear on the dialog.
 e.g. for a laserjet, you will see tabs for:
 General, Page Setup, Job scheduling, etc...
 
 If no printer is set up, the dialog will be mostly 
 empty and useless...
 <span color='red'>
 This doesn't actually print, just demos the setup.
 </span>
</i>
`
constant fmt = `
Printer: <b>[]</b>
Name: <b>[]</b>
Supports selection: <b>[]</b>
Paper size: <b>[]</b>
Display name: <b>[]</b>
PPD name: <b>[]</b>
Width: <b>[]</b>
Height: <b>[]</b>
Default: <b>[]</b>
Custom size? []
Top margin: []
Left margin: []
`
constant win = create(GtkWindow,{
	{"default size",300,200},
	{"border width",10},
	{"position",GTK_WIN_POS_CENTER},
	{"connect","destroy","Quit"}})
	
constant panel = create(GtkBox,VERTICAL)
	add(win,panel)

constant lbl = create(GtkLabel)
	set(lbl,"markup",docs)
	add(panel,lbl)

constant btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-print","PageSetup"),
	box = create(GtkButtonBox)
	pack(panel,-box)
	add(box,{btn1,btn2})

show_all(win)
main()

-----------------------------
global function PageSetup()
-----------------------------
-- Many of the settings below are not necessary for normal use,
-- they're shown just to illustrate some of the things you can 
-- modify or use if you wish. See GTK docs GtkPrintSettings for
-- full list of options;
	
object setup = create(GtkPageSetup,{
	{"orientation",GTK_PAGE_ORIENTATION_REVERSE_LANDSCAPE},
	{"left margin",0.25,GTK_UNIT_INCH},
	{"right margin",0.50,GTK_UNIT_INCH},
	{"top margin",1.0,GTK_UNIT_INCH},
	{"bottom margin",0.5,GTK_UNIT_INCH},
	{"paper size",create(GtkPaperSize,"na_legal")}})

object settings = create(GtkPrintSettings,{
	{"n copies",3},
	{"number up",4},
	{"printer lpi",300},
	{"scale",0.50},
	{"print pages",GTK_PRINT_PAGES_RANGES},
	{"collate",TRUE},
	{"reverse",TRUE}})

object dlg = create(GtkPrintUnixDialog,{
	{"embed page setup",TRUE},
	{"support selection",TRUE},
	{"has selection",TRUE},
	{"page setup",setup},
	{"transient for",win},
	{"print settings",settings}})

if get(dlg,"run") = MB_OK then

	object printer = get(dlg,"selected printer")
	object printer_name = get(printer,"name")
	object printer_location = get(printer,"location")
	object printer_job_count = get(printer,"job count")

	object paper = get(setup,"paper size")
	object paper_name = get(paper,"display name")

	atom paper_width = round(get(paper,"width",GTK_UNIT_INCH),10)
	atom paper_height = round(get(paper,"height",GTK_UNIT_INCH),10)
	atom margin_top = get(paper,"default top margin",GTK_UNIT_INCH)
	atom margin_left = get(paper,"default left margin",GTK_UNIT_INCH)

	Info(win,"Printer Info",printer_name,
		text:format("Location: []\nPaper: []\nSize: [] x []\nMargins: top: [] left: []\nJobs: []",
		{printer_location,paper_name,paper_width,paper_height,margin_top,margin_left,printer_job_count}))
		
end if
	
set(dlg,"hide")

return 1
end function
