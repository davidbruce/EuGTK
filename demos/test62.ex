
------------------------------------------------------------------------
--# GtkAssistant
------------------------------------------------------------------------

include GtkEngine.e

constant docs = `
<b><u>GtkAssistant</u></b>

The GtkAssistant can be used to guide your program's users
through a process such as setting up a program, setting 
preferences, agreeing to your license terms, etc.

It returns signals indicating whether the process has been 
completed successfully or the user has decided to cancel.

Click the 'ok' button to see a demo.
`
------------------------------------------------------------------------
-- Main Window
------------------------------------------------------------------------
constant 
    win = create(GtkWindow,"position=1,border_width=10,$destroy=Quit"),
    panel = create(GtkBox,VERTICAL),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","ShowAssistant"),
    lbl = create(GtkLabel,{{"markup",docs}})

    set(btn2,"tooltip text","Click here for a demonstration")
    set(box,"margin top",10)
    
    add(win,panel)
    add(panel,lbl)
    add(box,{btn1,btn2})
    pack(panel,-box)
    
----------------------------------------------------------------
-- The Assistant:
----------------------------------------------------------------
constant assistant = create(GtkAssistant,
    "position=3,icon=./thumbnails/mongoose.png,$close=Closed,$cancel=Cancelled")

--------------------------------------------------------------------------------
-- A helper function to build assistant pages programmatically
--------------------------------------------------------------------------------
function CreateAssistantPage(integer pagetype, sequence title, integer complete)
object page = create(GtkBox,VERTICAL)
    get(assistant,"append page",page)
    set(assistant,{
	{"page type",page,pagetype},
	{"page title",page,title},
	{"page complete",page,complete}})
return page
end function

------------------------------------------------------------------------------------
-- Create 4 pages for the assistant
-- Use this code as a base for your own, or if you need something more elaborate,
-- read the GTK docs on the GtkAssistant!
-- You can add pages which, for example, offer to download an update, or to get 
-- permission to install some library, or register your program, or ?
------------------------------------------------------------------------------------
constant pg1 = CreateAssistantPage(GTK_ASSISTANT_PAGE_INTRO,"Page 1: Welcome!",TRUE)
    set(assistant,"title","Assistant")
    
    constant img1 = create(GtkImage,"./thumbnails/euphoria.gif")
	add(pg1,img1)
	
    constant lbl1 = create(GtkLabel,{
	{"justify",GTK_JUSTIFY_CENTER},
	{"markup",
	    sprintf("<b>EuGTK %s </b>\n\n<small>Release %s\n%s</small>",
		{version,release,copyright})}})
	add(pg1,lbl1)

constant pg2 = CreateAssistantPage(GTK_ASSISTANT_PAGE_CONTENT,"Page 2: License Terms",TRUE)
	
	constant gpl_label = create(GtkLabel,{
	    {"markup","<big><u>LGPL</u></big>\n\n" & LGPL},
	    {"font","8"}})
	add(pg2,gpl_label)

constant pg3 = CreateAssistantPage(GTK_ASSISTANT_PAGE_CONFIRM,"Page 3: Confirm",FALSE)
	
	constant lbl3 = create(GtkLabel)
	    set(lbl3,"markup",`_<big><u>Disclaimer</u></big>
		It ain't my fault!
		You break it, you keep it, 
		YMMV,
		etc...`)

	constant img3 = create(GtkImage,"./thumbnails/mongoose.png")
	add(pg3,{lbl3,img3})

constant agreebtn = create(GtkCheckButton,"Yes, I agree!",_("Agreed"),pg3)
	set(pg3,"border width",20)
	pack(pg3, -agreebtn)

constant pg4 = CreateAssistantPage(GTK_ASSISTANT_PAGE_SUMMARY,
	"Page 4: Summary",TRUE)
	add(pg4,
	    create(GtkLabel,"That's all folks!") &
	    create(GtkImage,"./thumbnails/tiphat1.gif") &
	    create(GtkImage,"./thumbnails/eugtk.png"))

show_all(win)
main()

----------------------------------------------
-- Display assistant when ok button is pressed
----------------------------------------------
global function ShowAssistant()
    show_all(assistant)
return 1
end function

------------------------------------------------------------------
-- Allow viewing page 4 only if 'I'm sure' checkbox is selected
------------------------------------------------------------------
function Agreed(atom ctl, atom page)
	set(assistant,"page complete",page,get(agreebtn,"active"))
return 1
end function

-------------------------------------------------
-- Here's where you put code to handle the 
-- cases where the assistant has been completed
-- or cancelled...
-------------------------------------------------
global function Closed()
	Info(win,,"Assistant closed!")
	set(assistant,"hide")
return 1
end function

global function Cancelled()
	Info(win,,"Assistant cancelled!")
	set(assistant,"hide")
return 1
end function


