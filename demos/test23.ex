
------------------------------------------------------------------------
--# A simple, but fairly complete, image viewer.
------------------------------------------------------------------------
-- Demonstrates Menus, FileChooser, FileFilters, Previews, etc.
-- Resizes images to fit the current window, shows statistics for 
-- selected image.
------------------------------------------------------------------------

include GtkEngine.e
include GtkEvents.e
include std/filesys.e
include std/datetime.e
  
atom preview_max = 150  -- default size 
object fn = 0 -- current filename
sequence name, path

constant win = create(GtkWindow,
    "name=Main,title=`Simple Image Viewer`,size=500x400,position=1," &
    "border=10,$configure-event=ResizeWindow,$destroy=Quit"),

    group = create(GtkAccelGroup), -- for CTL-O, CTL-C, CTL-Q menu options
    panel = create(GtkBox,"name=box,orientation=VERTICAL"),
    menubar = create(GtkMenuBar)
    
    pack(panel,menubar)

constant menu1 = create(GtkMenuItem,"_File"),
	filemenu = create(GtkMenu),
	    fileopen = create(GtkMenuItem,"gtk-open",_("FileOpen"),0,{group,"<Ctl>o"}),
	    fileclose = create(GtkMenuItem,"gtk-close",_("FileClose"),0,{group,"<Ctl>c"}),
	    sep1 = create(GtkSeparatorMenuItem),
	    fileexit = create(GtkMenuItem,"gtk-quit","Quit",0,{group,"<Ctl>q"})
	    set(fileclose,"sensitive",FALSE)
    
    gtk:add(filemenu,{fileopen,fileclose,sep1,fileexit})
    set(menu1,"submenu",filemenu)
    gtk:add(menubar,menu1)

constant menu2 = create(GtkMenuItem,"_Help"),
    helpmenu = create(GtkMenu),
	helpabout = create(GtkMenuItem,"gtk-about#About",_("ShowAbout"),0,{group,"F1"}),
	helpinfo = create(GtkMenuItem,"gtk-info#Photo _Info",_("PixInfo"),0,{group,"F2"})
    
    set(helpabout,"add accelerator",{group,"<ctl>a"})
    set(helpinfo,"add accelerator",{group,"<ctl>i"})
	
    set(helpinfo,"sensitive",FALSE)
    set(helpabout,"tooltip text","About this program...")
    set(helpinfo,"tooltip text","About current photo")
    gtk:add(helpmenu,{helpabout,helpinfo})
    set(menu2,"submenu",helpmenu)
    gtk:add(menubar,menu2)
    
constant 
    scrolwin = create(GtkScrolledWindow),
    scroller = create(GtkViewport,"border width=10"),
    img = create(GtkImage,"thumbnails/eugtk.png")

-----------------------------------------------------------------
-- filters determine which types of files will be shown in the
-- file chooser dialog. No filter = show all files.
-----------------------------------------------------------------

constant imagetypes = {"gif","jpg","png","ico"}

constant filter1 = create(GtkFileFilter,{{"name","All Images"}})
    ifdef UNIX then 
	set(filter1,"add mime type","image/*")
    elsedef -- windows doesn't know mime types?
	for i = 1 to length(imagetypes)  do
	    set(filter1,"add pattern",sprintf("*.%s",{imagetypes[i]}))
	end for
    end ifdef
    
constant 
    filter2 = create(GtkFileFilter,"name=`JPEG images`,add_pattern=*.jpg"),
    filter3 = create(GtkFileFilter,"name=`GIF images`,add_pattern=*.gif"),
    filter4 = create(GtkFileFilter,"name=`PNG images`,add_pattern=*.png"),
    filter5 = create(GtkFileFilter,"name=`All files`,add_pattern=*")

constant dlg = create(GtkFileChooserDialog,{
    {"title","Select an image"},
    {"transient for",win},
    {"action",GTK_FILE_CHOOSER_ACTION_OPEN},
    {"local only",FALSE},
    {"border width",10},
    {"select multiple",FALSE}})
	
gtk:add(dlg,{filter1,filter2,filter3,filter4,filter5})

constant action_area = get(dlg,"action area")
    set(dlg,"add button","gtk-cancel",MB_CANCEL)
    set(dlg,"add button","gtk-ok",MB_APPLY)

constant pvbox = create(GtkBox)
    set(dlg,"preview widget",pvbox)
    
constant preview = create(GtkImage)
    pack_start(pvbox,preview,TRUE,TRUE)
    show(preview)
    
    gtk:add(win,group)
    gtk:add(win,panel)
    pack(panel,scrolwin,1,1)
    gtk:add(scrolwin,scroller)
    gtk:add(scroller,img)

-- call UpdatePreview whenever selection, filter, or folder changes.
   connect(dlg,"update-preview",_("UpdatePreview")) 

show_all(win)

-- try to find user's pictures folder via a call to a glib func:
ifdef WINDOWS then
	path = canonical_path("~\\Pictures")
end ifdef

ifdef OSX then
	-- FIXME OSX
end ifdef

ifdef LINUX then -- this function doesn't exist on Windows;
    path = gtk_str_func("g_get_user_special_dir",{S},
	{G_USER_DIRECTORY_PICTURES})
end ifdef

main()

------------------------------------------------------------------------
function FileOpen()
------------------------------------------------------------------------
object tmp
integer result 

    set(dlg,"current folder",path)
    result = run(dlg) 
    switch result do
    
        case GTK_RESPONSE_APPLY then
	    tmp = get(dlg,"filename")
	    path = dirname(tmp)
        
	    -- note: important to check to see that an actual file is selected, 
	    if not atom(tmp) then -- if atom, no file was selected 
		fn = locate_file(tmp)
		if file_type(fn) = 1 then
		    set(win,"title",filename(fn))
		    set(fileclose,"sensitive",TRUE)
		    ResizeWindow()
		end if
	    end if
	    hide(dlg)
        
	case GTK_RESPONSE_CANCEL then path = current_dir() hide(dlg)
    
    end switch
   
    set(helpinfo,"sensitive",TRUE)
    
return 1
end function 

------------------------------------------------------------------------
function FileClose() -- remove image from view;
------------------------------------------------------------------------
    fn = 0
    set(img,"clear")
    set(win,"title","Image Viewer")
    set(fileopen,"sensitive",TRUE)
    set(fileclose,"sensitive",FALSE)
    set(helpinfo,"sensitive",FALSE)
return 1
end function

----------------------------------------------------------------------------
global function UpdatePreview(atom ctl=0, atom event=0) -- as focus changes;
----------------------------------------------------------------------------
object pix 
atom ratio
object dimensions 

object fn = get(dlg,"filename")  

if string(fn) then -- avoid trying to preview a directory!
	pix = create(GdkPixbuf,fn) 
	if pix > 0 then
	    dimensions = get(pix,"size") 
	    ratio = preview_max / dimensions[1]  
	    dimensions *= {ratio,ratio}
	    pix = set(pix,"scale simple",dimensions[1],dimensions[2],1)
	    set(preview,"from pixbuf",pix)
	    set(dlg,"preview widget active",TRUE)
	else
	    set(dlg,"preview widget active",FALSE)
	end if
end if

return 0
end function

-------------------------------------------------------------------------
global function ResizeWindow() -- tries to fit the image into the window!
-------------------------------------------------------------------------
object pix
object ratio 
sequence size
size = get(win,"size") - {30,50} -- allow for window border & header
if file_exists(fn) then
    pix = create(GdkPixbuf,fn,size[1],size[2],1) 
    set(img,"from pixbuf",pix)
end if
return 0
end function

------------------------------------------------------------------------
function ShowAbout()
------------------------------------------------------------------------
return Info(win," About ","Simple Image Viewer",
"Resize the main window\nthe image is expanded to fit.",,"emblem-photos")
end function

------------------------------------------------------------------------
function PixInfo()
------------------------------------------------------------------------
atom w = allocate(8), h = allocate(8)

-- obtain size of the current image;
integer flen = file_length(fn)

-- obtain time & date file saved;
object tstamp = file_timestamp(fn)

-- get more info by obtaining a a file_info structure from the filename;
object info = gtk_func("gdk_pixbuf_get_file_info",{P,I,I},{allocate_string(fn,1),w,h}) 
    w = peek4u(w) h = peek4u(h)

-- get image format (jpg, gif, etc...) from the info structure;
object fmt = peek_string(peek4u(info))

-- create an icon for the Info box using the current image;
Pixbuf pix = create(GdkPixbuf,fn,90,0,1)

Info(win,"File Info", -- show as much info about the selected image as possible;
    text:format("File: []\n",{filename(fn)}),
    text:format("Folder: []\nFormat: []\nWidth: []px, Height: []px\nSize: [,,] bytes",
        {path,fmt,w,h,flen}) &
    datetime:format(tstamp,"\nDate: %a, %d %b %Y"),,pix,128)
    
return 1
end function

