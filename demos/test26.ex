
--------------------------------------------------------------------
--# GtkInfoBar, used to show messages without a dialog. 

-- It is often temporarily shown at the top or bottom of a document. 
-- In contrast to GtkDialog, which has a action area at the bottom, 
-- GtkInfoBar has an action area at the side.

-------------------------------------------------------------------- 

include GtkEngine.e

constant docs = `<b><u>Info Bar</u></b> 

will appear when you click
either of the two buttons below.

Programmer can change the color of the info bar
to indication importance of the message.
`
enum BUG, GOOSE, CLOSE

sequence pix = {0,0}
    pix[BUG] = "thumbnails/bug-buddy.png"
    pix[GOOSE] = "thumbnails/mongoose.png"
	
constant fmt = `<span size='small' color='black'>The last button pressed was
the <b>%s</b> Button [#%d]</span>`

constant 
    win = create(GtkWindow,"position=CENTER,size=430x200,border=10,background=skyblue,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical"),
    btnbox = create(GtkButtonBox),
    btn1 = create(GtkButton,pix[BUG] & "# _Bug",_("PopupBar"),BUG),
    btn2 = create(GtkButton,pix[GOOSE] & "# _Mongoose",_("PopupBar"),GOOSE),
    lbl = create(GtkLabel,"margin top=20,markup=" & docs),
    ib = create(GtkInfoBar), 
    ca = get(ib,"content area"),
    img = create(GtkImage), -- add a container for the infobar image;
    iblabel = create(GtkLabel) -- text for infobar, with close button;
    
    add(ca,iblabel)
    set(ib,{
	{"message type",GTK_MESSAGE_QUESTION}, -- (*)
	{"add button","gtk-close",CLOSE},
	{"signal","response",_("PopupBar")}})
     add(panel,ib)

-- (*) For the theme I am using at the moment:
	-- GTK_MESSAGE_INFO = normal background color
	-- GTK_MESSAGE_WARNING = yellow
	-- GTK_MESSAGE_QUESTION = blue
	-- GTK_MESSAGE_ERROR = red
	-- GTK_MESSAGE_OTHER = borderless, use default window background color
	-- Possibly this may change depending upon the window theme in use.
	-- This only affects the background color of the infobar, not the button types, etc,
	-- as happens with the built-in dialogs.
    
    set(btn1,"tooltip text","This is button #1")

    add(win,panel)
    add(panel,lbl)
    add(ca,img)
    show_all(ca)
    add(btnbox,{btn1,btn2})
    pack_end(panel,btnbox)
	
show_all(win)
hide(ib)
main()

------------------------------------------------------------------------
function PopupBar(atom ctl, object z)
------------------------------------------------------------------------
object txt 
    if z = CLOSE then 
	set(ib,"hide")
	--set(win,"restore")
    else
	txt = remove_item('_',get(ctl,"label"))
	set(iblabel,"markup",sprintf(fmt,{txt,z}))
	set(iblabel,"show")
	set(img,"from file",locate_file(pix[z]))
	set(ib,"show_all")
    end if
return 1
end function
  


