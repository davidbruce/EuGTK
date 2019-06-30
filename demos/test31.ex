
------------------------------------------------------------------------
--# Calendar with locale
------------------------------------------------------------------------

include GtkEngine.e

-- Translates calendar text if you have the language installed.

include std/locale.e 
object lang = "es_ES.iso885915@euro"

if locale:set(lang) = 0 then
    Warn(0,,"Sorry, unable to load",lang) 
end if

constant 
    win = create(GtkWindow,"position=center,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    cal = create(GtkCalendar),
    box = create(GtkButtonBox,"border=10"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","ShowDate")

    gtk:set(cal,"mark day",gtk:get(cal,"day")) -- highlight today
    
    add(win,panel)
    add(panel,cal)
    add(box,{btn1,btn2})
    pack_end(panel,box)
    
show_all(win)
main()

------------------------------------------------------------------------
global function ShowDate()
------------------------------------------------------------------------
object selected_date = gtk:get(cal,"date","%A, %b %d, %Y") 
    Info(win,"Calendar Results","Selected date",selected_date)
    return 1
end function

