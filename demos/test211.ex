
-------------------------------------------------------
--# Animated, swirling icons (one of the GTK CSS demos)
-- The animation is totally controlled by the css, 
-- therefore the Euphoria/GTK code is minimal:
-------------------------------------------------------

include GtkEngine.e

ifdef WINDOWS then 
	Info(,,"Sorry","Does not work in Windows!") 
end ifdef

constant css = create(GtkCssProvider,"~/demos/resources/css_pixbufs.css")
constant win = create(GtkWindow,"size=400x300,position=1,$destroy=Quit")

show_all(win)
main()
