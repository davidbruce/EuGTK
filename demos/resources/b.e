namespace b

include GtkEngine.e

export constant color = "green"

constant win = create(GtkWindow,{ -- note this window is NOT exported.
    {"name","b:window"}, -- you must include the namespace as part of name
    {"move",400,700},
    {"title","Window B"}})
 
show_all(win)

export function clear()
   set(win,"background",#dddddd)
return 1
end function
