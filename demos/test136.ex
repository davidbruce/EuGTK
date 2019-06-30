
----------------------------------------------------------------------------
--# GtkFontChooserDialog 

-- Note: this is a pop-up dialog, not a widget to be added to a window. 

-- It is created in the main body of the code, so that it gets created 
-- only once, rather than in the choose function, where a new one would be 
-- created with each call to that function.
-- This way, it will retain its settings between activations.
----------------------------------------------------------------------------

include GtkEngine.e

constant note = `

-- <b>Please note:</b> this demo does NOT use a font filter, so it displays 
-- (or tries to) every font on your computer - this makes for a long list
-- with lots of 'odd' fonts such as clock faces, unreadable styles, etc.
-- You'll most likely want to use a font filter on any 'real-life' program...
-- see test36 or test59.
-- See also GtkFontChooser.e for a pre-made font chooser to include.

`
constant win = create(GtkWindow,"size=200x100,border=10,position=1,$destroy=Quit")

constant dlg = create(GtkFontChooserDialog,
	"title=Select a font,preview text=`EuGTK is easy to use as 1,2,3...`")
	set(dlg,"transient for",win)
	
constant panel = create(GtkBox,VERTICAL)
	add(win,panel)

constant lbl = create(GtkLabel,{
	{"font","8"},
	{"markup","<big><b><u>Font Chooser Dialog</u></b></big>\n" & note}})
	add(panel,lbl)

constant quitbtn = create(GtkButton,"gtk-quit","Quit")
constant fntbtn = create(GtkButton,"gtk-select-font","SelectFont")
constant btnbox = create(GtkButtonBox)
	add(btnbox,{quitbtn,fntbtn})
	pack(panel,-btnbox)

show_all(win)
main()

------------------------------------------------------------------------
global function SelectFont()
------------------------------------------------------------------------
if set(dlg,"run") = MB_OK then
	set(lbl,"font",get(dlg,"font"))
end if
set(dlg,"hide")
return 1
end function
