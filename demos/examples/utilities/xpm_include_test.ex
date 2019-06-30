
----------------------------------------------------------------
--# This demo includes xpm images as regular Eu sequences.
----------------------------------------------------------------
-- If this program is bound, shrouded, or compiled, the images 
-- will be bound along with it, so neither the images nor the
-- include need to be available at run-time.
-----------------------------------------------------------------

include GtkEngine.e

include icon_P.e -- the converted xpm images;
include icon_I.e
include icon_E.e

constant win = create(GtkWindow,
    "title=XPM includes,icon=face-raspberry,size=100x100,position=1,border=30,$destroy=Quit")
    
constant panel = create(GtkBox,HORIZONTAL)
    add(win,panel)
    add(panel,{p:icon,i:icon,e:icon})

show_all(win)
main()
