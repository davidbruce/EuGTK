
-----------------------------------------------------------------
--# GtkOverlay -- demos overlayed button
-----------------------------------------------------------------

include GtkEngine.e
include GtkEvents.e

constant 
    win = create(GtkWindow,"size=300x-1,border_width=10,position=1,$destroy=Quit"),
    overlay = create(GtkOverlay),
    tv = create(GtkTextView,"left-margin=10,right-margin=10,top-margin=10,wrap mode=3"),
    buff = get(tv,"buffer")
    set(buff,"text",
    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, " &
    "sed diam nonumyeirmod tempor invidunt ut labore et dolore " &
    "magna aliquyam erat, sed diamvoluptua. At vero eos et accusam " &
    "et justo duo dolores et ea rebum. Stet clita kasd gubergren, " &
    "no sea takimata sanctus est Lorem ipsum dolor sit amet.Lorem i")

constant btn = create(GtkButton,{ -- pops up when mouse moves into window;
    {"label","Overlayed Quit Button"},
    {"image","gtk-quit"},
    {"valign",GTK_ALIGN_CENTER},
    {"halign",GTK_ALIGN_CENTER},
    {"connect","clicked","Quit"}})
    
    set(overlay,"add overlay",btn)
    connect(win,"event",_("Pop"))
    
    add(win,overlay)
    add(overlay,tv)
    
show({win,overlay,tv})
main()

----------------------------------
function Pop(atom ctl, atom event)
----------------------------------
switch events:name(event) do
    case "focus-in" then show(btn)
    case "focus-out" then hide(btn)
end switch
return 0
end function
