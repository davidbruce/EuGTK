
--------------------------------------------------------------------------
--# Demo of namespaces and Glade
--------------------------------------------------------------------------

with define BUILDER -- view namespacing on terminal - can comment this line out;

include GtkEngine.e

add(builder,locate_file("main.glade")) 
include about.e
include file.e
include prefs.e
 
main()

---------------------------------
global function random_color() --
---------------------------------
 set("main:window1","background",rand(#FFFFFF))
 return 1   
end function




