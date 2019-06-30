
---------------
namespace about 
---------------

include GtkEngine.e

add(builder,locate_file("about.glade"))

-- help:window1 is designed completely in Glade, all we need to do 
-- here is to show and hide it when needed;

------------------------------
global function about_run() --
------------------------------
object self = "about:dialog"
integer result = get(self,"run")
hide(self)
return result
end function


