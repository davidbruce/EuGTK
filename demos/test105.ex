
-----------------------------------------------------------------------
--# Customizing built-in dialog boxes
-- Here we change the default behavior of the Info() box,
-- but the same options can be set to override the defaults
-- for the other built-in dialogs, such as Question or Error...
--
-- See also an easier way, using named parameters:
-- test227, test228
----------------------------------------------------------------------

include GtkEngine.e
   
Info(0,"Info Box1","Primary Text","<i>Secondary</i> Text")
--[1] parent window or null
--[2] dialog title or empty for default title
--[3] first line (automatically made bold if secondary text exists)
--[4] secondary text, can be marked up if desired

-- All parameters are optional, but dialogs won't make much sense without
-- at least parameter[3]

-- [5] is the button set to override default button(s);
Info(0,"Info Box3","Changing Buttons","use yes/no buttons",GTK_BUTTONS_YES_NO)
--------------------------------------------------------------^ button id, see GtkEnums

-- [6] is an image to use in place of the default dialog icon;
Info(0,"Info Box2","Dialog Icon","Change to Question icon",,"dialog-question")
----------------------------------------------------------^ icon name

-- [7] is an image to use in place of the default titlebar icon; 
constant img = create(GtkImage,"~/demos/thumbnails/BabyTux.png")
Info(0,"Info Box4","Titlebar Icon","Titlebar icon from a file",,,img)
-------------------------------------------------------^ custom icon image

-- Primary and Secondary text can use markup to set style and colors
-- Below we use markup to make a fancy Info dialog;

Info(0,"Info Box5",
	"<span font='URW Chancery L, Comic Sans MS 24'><b>Hello World</b></span>",
	"<span font='URW Chancery L 12'>We can be as fancy as we like here,\n" &
	"with multi-line text,\n<span color='red'>colors</span>, <u>underlined,</u> etc.</span>")


