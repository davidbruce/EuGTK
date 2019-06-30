
--# Page Setup Unix dialog demo (how to retrieve settings)

include GtkEngine.e
include GtkPrinter.e
include std/math.e

constant docs = `<u><b>Page Setup Unix Dialog</b></u>
Click OK button to pop up a dialog box.
<span color='red'>
This doesn't really print anything, just shows a 
simple printer select dialog and how 
to set and retrieve print settings.
</span>
`
-- format for listing settings;
constant fmt = `
Name: <b>[]</b>
Display: <b>[]</b>
PPD name: <b>[]</b>
Paper width: <b>[.2]</b> 
Paper height: <b>[.2]</b> 
Page width: <b>[.2]</b> 
Page height: <b>[.2]</b> 
Left margin: <b>[.2]</b> 
Right margin: <b>[.2]</b>
Top margin: <b>[.2]</b>
Bot margin: <b>[.2]</b>
Orientation: <b>[]</b>

`
constant orientation = {"Portrait","Landscape","Reverse Portrait","Reverse Landscape"} 

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

constant box = pack_end(panel,create(GtkButtonBox))
	add(box,{
		create(GtkButton,"gtk-quit","Quit"),
		create(GtkButton,"gtk-ok","ShowPageSetup")})

show_all(win)
main()

-------------------------------
global function ShowPageSetup()
-------------------------------
object dlg = create(GtkPageSetupUnixDialog)
	set(dlg,"transient for",win)
	
if get(dlg,"run") = MB_OK then
	object setup = get(dlg,"page setup")
	object papersize = get(setup,"paper size")
	set(lbl,"markup",format(fmt,
		{get(papersize,"name"),
		 get(papersize,"display name"),
		 get(papersize,"ppd name"),
		 round(get(setup,"paper width",GTK_UNIT_INCH),10),
		 round(get(setup,"paper height",GTK_UNIT_INCH),10),
		 round(get(setup,"page width",GTK_UNIT_INCH),10),
		 round(get(setup,"page height",GTK_UNIT_INCH),10),
		 round(get(setup,"left margin",GTK_UNIT_INCH),10),
		 round(get(setup,"right margin",GTK_UNIT_INCH),10),
		 round(get(setup,"top margin",GTK_UNIT_INCH),10),
		 round(get(setup,"bottom margin",GTK_UNIT_INCH),10),
		 orientation[get(setup,"orientation")+1]
		 }))
end if
set(dlg,"destroy")
return 1
end function
