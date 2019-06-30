
------------------------------------------------------------------------
--# Demos use of ini or settings files, with optional data spaces;
------------------------------------------------------------------------
-- RUN THIS FROM AN X-TERM to see the ini contents

-- To use settings, you must give a unique name to each control you 
-- wish to monitor/set. This allows colors, fonts, etc. to be 
-- specified on startup, but unlike CSS, modified during the run, 
-- and more importantly, allows control *states* and *values*,
-- not just appearance, to be preserved from run to run. 

-- The ini code is plain text, and easier to edit than CSS.

include GtkEngine.e
include GtkSettings.e -- for saving and loading settings
include GtkFontSelector.e -- for font filter
include std/datetime.e  -- requires use of gtk: namespace

constant ini = canonical_path("~/demos/resources/test153.ini")

create(GtkWindow,"name=MainWindow,icon=face-cool,$delete-event=BailOut")

gtk:add("MainWindow",create(GtkBox,"name=panel,orientation=1,spacing=5"))

gtk:add("panel",{
    create(GtkEntry,"name=User,placeholder text=Enter your name here"),
    create(GtkCalendar,"name=MyCalendar"),
    create(GtkButtonBox,"name=Box1"),
    create(GtkButtonBox,"name=Box2")})

gtk:add("Box1",{
    create(GtkButton,"stock_calendar#_Today","SetToday"),
    create(GtkFontButton,{
	{"name","FontButton"},  
	{"filter func",fontselector:filter}, -- filter out unusable fonts
	{"signal","font-set","SetCalFont"}})})

gtk:add("Box2",{
    create(GtkButton,"gtk-quit","BailOut"),	
    create(GtkButton,"gtk-save","SaveState"),
    create(GtkButton,"gtk-help","Help"),
    create(GtkColorButton,"name=ColorChooserButton,$color-set=SetBkgnd")})

-- Below is the list of the active controls we want to save and load:	
   object list = {"MainWindow","User","ColorChooserButton","FontButton","MyCalendar"}

settings:Load(ini,0) -- get settings from prior run, 1 = display on terminal, optional;

show_all("MainWindow")

gtk:set("ColorChooserButton","grab focus")

main()

------------------------------
global function SaveState() -- save controls on list, don't exit;
------------------------------
 settings:Save(ini,list,1) -- 1 means display on terminal, optional;
return 1
end function

-------------------------------------
global function SetBkgnd(atom ctl) -- change and save window background color
-------------------------------------
object color = get(ctl,"rgba",1) -- 1 gets color as hex string 
    gtk:set("MainWindow","background",color)
    settings:Set(ini,"MainWindow","background",color) -- see note[1]
 return 1
end function

---------------------------------------
global function SetCalFont(atom ctl) -- change and save calendar font
---------------------------------------
object fnt = get(ctl,"font")
    gtk:set("MyCalendar","font",fnt)
    settings:Set(ini,"MyCalendar","font",fnt) -- see note[2]
return 1
end function

-----------------------------
global function SetToday() -- set calendar to current computer date, save to ini
-----------------------------
    gtk:set("MyCalendar","date",datetime:now())
    gtk:set("MyCalendar","mark day",gtk:get("MyCalendar","day"))
return 1
end function

-------------------------
global function Help() -- read and show saved 'data' settings
-------------------------
  Info(,"Greetings",gtk:get("User","text"),settings:Get("MainWindow","Message"))
  return 1
  end function
  
----------------------------
global function BailOut() -- save all settings for next run
---------------------------- 
-- save the default value for the active controls on the list,
-- this is the standard one-liner that is all that is needed for
-- most programs;
  settings:Save(ini,list)
return Quit()
end function

-- note [1] 
-- this is shown for demo purposes, an alternative would be to just set the 
-- window background by reading the ColorChooserButton's color property after 
-- loading the ini.

-- note [2]
-- this is also shown for demo purposes, normally it would do to set the calendar
-- font from the FontButton.font property. You might use this if you were setting
-- fonts in some other manner (text entry, perhaps?)


