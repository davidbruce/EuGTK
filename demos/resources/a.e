namespace a

include GtkEngine.e

export constant color = "red"

constant win = create(GtkWindow,{ -- this window is NOT exported
    {"name","a:window"}, -- note that this name must include the namespace!
    {"move",200,300},
    {"title","Window A"}})

show_all(win)

export function clear()
   set(win,"background",#dddddd)
return 1
end function
