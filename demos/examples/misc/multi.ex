
--# MULTI-LINGUAL <i>(uses ini files to translate captions)</i>

-- Run this program as follows: eui multi es (for spanish) 
-- or gr (greek), ge (german), fr (french), ru (russian)

include GtkEngine.e
include GtkSettings.e
include std/io.e

object cmdl = command_line() 
object ext = "en"
if length(cmdl) > 2 then ext = cmdl[3] end if

constant ini = locate_file(sprintf("~/demos/examples/misc/multi.%s",{ext}))

object bgcolor 
 
-- Note: we must connect to the main window's 'delete_event', rather than to the 
-- 'destroy' event here, so that the window still exists when the Exit routine
-- is called (and the window's properties can still be determined)
-- Once the window is destroyed, it's too late!

constant 
 win = create(GtkWindow,"name=MainWindow,$delete_event=Exit"),
 pan = create(GtkBox,"orientation=vertical,spacing=10"), 
 img = create(GtkImage,"name=Image1"),
 lbl = create(GtkLabel,"name=Label1,font=8"),
 box = create(GtkButtonBox),
 btn1 = create(GtkButton,"$clicked=Exit"),
 btn2 = create(GtkButton,"$clicked=Help"),
 btn3 = create(GtkButton,"$clicked=RandomBackgroundColor")

 set(btn1,"name","Button1")
 set(btn2,"name","Button2")
 set(btn3,"name","Button3")
 set({btn1,btn2,btn3},"always show image",TRUE)
 set({btn1,btn2,btn3},"use underline",TRUE)
  
 add(win,pan)
 add(pan,{img,lbl})
 add(box,{btn1,btn2,btn3})
 pack(pan,-box)

show_all(win)

 Startup() -- load saved settings;

main()

----------------------
procedure Startup() --
----------------------

--[1] Load all default properties for widgets on the Save list;
 settings:Load(ini) -- restores window size and position, background color, etc;

--[2] for demo purposes only, add ini text to window;
 set(lbl,"markup",read_file(canonical_path(ini)))

end procedure

------------------------------------------
global function RandomBackgroundColor() --
------------------------------------------
bgcolor = sprintf("#%06x",rand(#FFFFFF))
set(win,"background",bgcolor)
return 1
end function

-------------------------
global function Help() --
-------------------------
object capt = settings:Get("MainWindow","HelpCaption")
object title = settings:Get("MainWindow","HelpTitle")
object text = settings:Get("MainWindow","HelpText")
text = join(split(text,'|'),'\n')
return Info(,capt,title,text)
end function

-------------------------
global function Exit() --
-------------------------
-- save defaults;
 settings:Save(ini,{win,box,img,btn1,btn2})
 
 if object(bgcolor) then -- it has been changed;
  settings:Set(ini,"MainWindow","background",bgcolor)
 end if
 
return Quit()
end function
 
