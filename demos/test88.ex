
-----------------------------------------------
--# Error dialog, icon, titlebar icon
-- shows how to set the dialog icon and the 
-- dialog's titlebar icon from a file;
-- titlebar icon may or may not be visible, 
-- depending upon the theme in use;
-----------------------------------------------

include GtkEngine.e

object fname = "thumbnails/mongoose.png"

Error(0,,"OMG!","This is an Error dialog",,fname,fname)
