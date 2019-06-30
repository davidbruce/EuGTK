
------------------------------------------------------------------------
--# GtkFontFilter - show only usable or desirable fonts
 
-- This demonstrates the use of a font filter routine to limit the 
-- styles of font displayed by the font chooser. 
------------------------------------------------------------------------

include GtkEngine.e

constant docs = """markup=
<b>Font Selection</b>

This shows how to allow only specific fonts to be
selectable in a font-selection dialog.


"""
-- below, list the font families you want to see in the font chooser;

constant 
    fontlist = {"URW Chancery L","Sans","Arial","Courier","Ubuntu","Impact","Balmoral D"},
    
    win = create(GtkWindow,"size=300x100,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical,padding=10"),
    lbl = create(GtkLabel,docs),
    box = create(GtkButtonBox,"spacing=10,margin top=10"),
    okbtn = create(GtkButton,"gtk-quit","Quit"),
    fntbtn = create(GtkFontButton,"font name=URW Chancery L italic medium 14,use font=TRUE," &
	"title=`Choose a nice font, now, OK?`,$font-set=ChangeFont")

    add(win,panel)
    add(panel,lbl)
    pack(panel,-box)
    add(box,{okbtn,fntbtn})
    
	set(fntbtn,"filter func",_("FontFilter")) 
	
show_all(win)
main()

-----------------------------------------------------------------
function FontFilter(atom family, atom face, atom data)
-----------------------------------------------------------------
object name = gtk_str_func("pango_font_family_get_name",{P},{family})
return find(name,fontlist)
end function

------------------------------------------------------------------
global function ChangeFont()
------------------------------------------------------------------
set(lbl,"font",get(fntbtn,"font name"))
return 1
end function

