
----------------------------------------------------------------------------------------
--# Custom Dialogs

-- EuGTK Dialogs have several optional paramenters which allow you 
-- to modify the appearance.

-- You can modify parent, title, icon, primary label, secondary label, 
-- default buttons, titlebar icon, modal/nonmodal,
-- plus add on almost any other GtkWidget you wish, 
-- including GtkEntry, GtkTextView, etc.

-- You could, of course, create these completely 'by hand', starting
-- with a stock GtkDialog, but that would require writing dozens of 
-- lines of code, instead of just one or two.
-----------------------------------------------------------------------------------------

include GtkEngine.e
include std/io.e

constant docs = `<b><u>Custom Dialogs</u></b>

Without a lot of work!

You can use any of the pre-built EuGTK dialogs 
to display custom contents. Just send the contents
as the 8th parameter.

Click the LGPL button to see one.
`
constant license = read_file(canonical_path(locate_file("resources/license.txt")))

constant doc_icon = create(GdkPixbuf,"thumbnails/emblem-documents.png",60,60)

constant win = create(GtkWindow,"size=300x-1,position=1,border_width=10,$destroy=Quit")
 
constant panel = add(win,create(GtkBox,VERTICAL))
    add(panel,create(GtkLabel,{{"markup",docs}}))

constant box = pack_end(panel,create(GtkButtonBox,HORIZONTAL))
    add(box,{
	create(GtkButton,"gtk-quit","Quit"),
	create(GtkButton,"ascii#_LGPL","ShowCustomDialog")})
	
show_all(win)

main() 

-------------------------------------
global function ShowCustomDialog() -- create a dialog with lots of customization;
-------------------------------------

object txtview = create(GtkTextView, -- this will be the 'addon' widget
    "editable=FALSE,left_margin=10,right_margin=10,margin-top=10")

object buffer = get(txtview,"buffer") -- contents of the textview;
    set(buffer,"text",license)

object gtk_logo = create(GdkPixbuf,"thumbnails/BabyTux.bmp")

 return Custom(win,  -- [1] optional parent
    "Custom Dialog", -- [2] dialog title
    "\nLGPL",        -- [3] primary text
    -- [4] below, secondary text as a link:
    "See <a href='http://www.gnu.org/licenses/lgpl.html'>www.gnu.org</a>", 
    GTK_BUTTONS_CLOSE,	  -- [5] optional buttons
    doc_icon,             -- [6] optional dialog icon 
    "face-monkey",        -- [7] optional titlebar icon - visibility depends on theme 
    ,					  -- [8] bkgnd color (not changed)	
    GTK_DIALOG_MODAL,     -- [9] MODAL/NONMODAL - modal is default
    txtview)              -- [10] addon widget created earlier

end function


