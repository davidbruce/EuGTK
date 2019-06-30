
----------------------------------------------------------------------------------------------
--# Plug and Socket Demo <span color='green'>Run this one! It will call plug.ex.</span>
----------------------------------------------------------------------------------------------
-- Running this file will open a window and show a Socket ID.
-- sock.ex will then execute plug.ex, passing the Socket ID to it 
-- as the 3rd entry on the command line.
-- plug.ex will open a small window containing a 
-- FileChooserButton. Use this to select images.
-- The selected image should be shown in the sock window.
----------------------------------------------------------

chdir(canonical_path("~/demos"))

include GtkEngine.e

constant win2 = create(GtkWindow,{
	{"default size",520,520},
	{"border width",10}, 
	{"move",0,0},
	{"icon","~/demos/thumbnails/applications-development.svg"},
	{"connect","map-event","on_Map"},
	{"connect","destroy","Quit"}})

constant panel = create(GtkBox,VERTICAL)
	add(win2,panel)

constant lbl = create(GtkLabel)
	add(panel,lbl)
	
constant sock = create(GtkSocket)
	pack(panel,sock,1,1)

show_all(win2)
	
integer sock_id = get(sock,"id")

set(win2,"title",sprintf("Socket ID %d",sock_id))
display("Socket ID []",sock_id)

main()

---------------------------
global function on_Map() -- run plug.ex;
---------------------------
system(sprintf("eui plug.ex %d &",sock_id))
return 1
end function
