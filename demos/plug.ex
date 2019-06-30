
--------------------------------------------------------------------------------------
--# Plug and Socket Demo <span color='red'>Run sock.ex , not this file!!</span>
--------------------------------------------------------------------------------------
-- STOP!

-- Please run sock.ex
-- This will open a window and show a Socket ID.
-- sock.ex will then execute plug.ex, passing
-- the Socket ID to it. 
--
-- Plug will then open a small window containing a 
-- FileChooserButton. Use this to select images.
-- The selected image should be shown in the sock window.
----------------------------------------------------------

include GtkEngine.e

object cmd = command_line()

integer sock_id = 0
if length(cmd) > 2 then
	sock_id = to_number(cmd[3])
end if

constant win1 = create(GtkWindow,{
	{"border width",10},
	{"default size",200,50},	
	{"icon","~/demos/thumbnails/applications-development.svg"},
	{"position",GTK_WIN_POS_CENTER},
	{"connect","destroy","Quit"}})

constant pan = create(GtkBox,VERTICAL)
	add(win1,pan)

constant txt = create(GtkLabel,"Select an image:")
	add(pan,txt)
	
constant filter = create(GtkFileFilter,{
	{"name","Images"},
	{"add mime type","image/*"}})
	
constant btn = create(GtkFileChooserButton,"Open")
	pack_end(pan,btn)
	set(btn,"add filter",filter)
	connect(btn,"file-set","NewPix")
	
constant socket = create(GtkPlug,sock_id)

constant panel = create(GtkBox,VERTICAL)
	add(socket,panel)
	
constant img = create(GtkImage,"~/demos/thumbnails/mongoose.png")
	add(panel,img)
	
constant lbl = create(GtkLabel,"name=pluglabel")
	add(panel,lbl)
	
	show_all(socket)

show_all(win1)
main()

------------------------
global function NewPix()
------------------------
object fn = get(btn,"filename")
object pb = create(GdkPixbuf,fn,500,500,1)
if file_exists(fn) then
	set(lbl,"text",fn)
	set(img,"from pixbuf",pb)
end if
return 1
end function
