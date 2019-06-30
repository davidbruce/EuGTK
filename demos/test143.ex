
--# GtkGrid demo

include GtkEngine.e

function PrintHello()
  puts(1,"Hello!\n")
return 1
end function
constant print_hello = call_back(routine_id("PrintHello"))

-- create a new window;
constant window = create(GtkWindow,"title=Grid Demo,border=10,position=1,$destroy=Quit")

-- a container to hold our buttons;
constant grid = create(GtkGrid)

-- Pack the container in the window;
  add(window,grid)

atom button = create(GtkButton,"Button 1",print_hello)

-- Place the first button in the grid cell (0, 0), and make it fill
-- just 1 cell horizontally and vertically (ie no spanning)

  set(grid,"attach",button, 0, 0, 1, 1)

  button = create(GtkButton,"Button 2",print_hello)

-- Place the second button in the grid cell (1, 0), and make it fill
-- just 1 cell horizontally and vertically (ie no spanning)

  set(grid,"attach",button, 1, 0, 1, 1)

  button = create(GtkButton,"gtk-quit","Quit")

-- Place the Quit button in the grid cell (0, 1), and make it
-- span 2 columns.

  set(grid,"attach", button, 0, 1, 2, 1)

-- Now that we are done packing our widgets, we show them all
-- in one go, by calling gtk_widget_show_all() on the window.
-- This call recursively calls gtk_widget_show() on all widgets
-- that are contained in the window, directly or indirectly.
 
  show_all (window)

-- All GTK applications must have a gtk_main(). Control ends here
-- and waits for an event to occur (like a key press or a mouse event),
-- until gtk_main_quit() is called.

 main ()


