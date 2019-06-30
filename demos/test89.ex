
--# Warning dialog

include GtkEngine.e

-- Setting the dialog icon and the dialog titlebar icon from a pixbuf;
-- titlebar icon may or may not be visible, depending upon the theme in use;

atom clown1 = create(GdkPixbuf,"thumbnails/clown.png",80,80,1)

Warn(0,,"You are confused"," (but this is your normal state)",,clown1,clown1)

