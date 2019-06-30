
---------------
namespace prefs 
---------------

include GtkEngine.e

add(builder,locate_file("prefs.glade"))

constant self = "prefs:window1"
constant child = "prefs:label1" 

-----------------------------------------------------------------------
global function  show_prefs(atom ctl, atom data) 
-----------------------------------------------------------------------
    set(self,"visible",TRUE) 
return 1
end function

-----------------------------------------------------------------------
global function value_changed(atom scale, atom data) 
-----------------------------------------------------------------------
	set(self,"background",get(scale,"value")) 
return 1
end function

-----------------------------------------------------------------------
global function apply(atom ctl, atom data) 
-----------------------------------------------------------------------
-- apply settings here...then
	set(self,"visible",FALSE)
return 1
end function

-----------------------------------------------------------------------
global function cancel(atom ctl, atom data) 
-----------------------------------------------------------------------
-- abandon changes, then hide me;
	set(self,"visible",FALSE)
return 1
end function

------------------------------------------------------------------------
global function set_color(atom ctl, atom data) 
------------------------------------------------------------------------
if get(ctl,"active") then 
	set(child,"color",get(ctl,"label"))
end if
return 1
end function

