
-------------------------------------------------------------------------------------
--# Saving Settings:

-- Note: Objects to have their status saved MUST be named with a unique name.
-- The reason for having to name the controls is because otherwise
-- they will have a default name: GtkButton, for example, for EVERY button created.
-- That would leave no way to indicate which button you are referencing.

-- Controls (vs. widgets) are things like spin buttons, font buttons, color buttons,
-- scales, volumn controls, calendars, etc. which have ONE particular setting 
-- that may be useful to preserve between runs. These are named in a list which 
-- is passed to the settings:Save() function. Entries are made to the ini file
-- for the items on this list automatically.

-- Widgets (vs. controls) are things like Windows, which have no single specific
-- property that you would always want to save, so those items along with the 
-- property you are interested in saving and restoring must be added to
-- the ini file, either by editing the ini manually, or by your program code,
-- using the settings:Update() function. These begin with --@

-- Permanently-fixed properties can be specified by using ! in the ini file.
-- These persist from run to run, and cannot be changed by your program.

--------------------------------------------------------------------------------------

include GtkEngine.e
include GtkSettings.e
include GtkFontSelector.e

constant ini = canonical_path(locate_file("resources/test173.ini"))

constant msg = `<b><u>Settings</u></b>

This demos how to obtain and save settings
of various controls that might need to be 
stored in an 'ini' type file.

Move or resize the window, select a 
font and color, then click the [X] close
button on the titlebar.

Then run this program again. If you 
run it from an x-term you can see the 
ini being loaded/saved.

`
constant win = create(GtkWindow,
    "name=Main Window,border=10,background=skyblue,position=1,font=8,$delete-event=BailOut")

constant panel = create(GtkBox,"orientation=VERTICAL,spacing=10")
    add(win,panel)

constant lbl = create(GtkLabel,"name=My Label")    
    add(panel,lbl)

constant cal = create(GtkCalendar,"name=My Calendar")
    add(panel,cal)

constant ck = create(GtkCheckButton,"gtk-edit#_Editable")
    set(ck,"name=MyCheckButton,tooltip text=Doesn't do anything")

constant fbtn1 = create(GtkFontButton,{
    {"name","TextFontBtn"},
    {"use font",TRUE},
    {"filter func",fontselector:filter}, -- add a filter so only usable fonts show
    {"connect","font-set","ChangeFont",lbl}})
    
constant fbtn2 = create(GtkFontButton,{
    {"name","CalendarFontBtn"},
    {"use font",TRUE},
    {"filter func",fontselector:filter}, -- add a filter so only usable fonts show
    {"connect","font-set","ChangeFont",cal}})
		
constant cbtn = create(GtkColorButton,{
    {"name","ColorButton"},
    {"tooltip text","Select window background color"},
    {"connect","color-set","ChangeBkgnd",win}})

constant btn = create(GtkButton,"gtk-quit",_("BailOut"))
    set(btn,"font","12")
    
constant box1 = create(GtkButtonBox,HORIZONTAL,5)
    add(box1,{fbtn1,fbtn2})
    pack(panel,box1)
    
constant box2 = create(GtkButtonBox,HORIZONTAL,5)
    add(box2,{cbtn,ck,btn})
    pack(panel,-box2)
    
-- these are the control handles we want to load/save:
constant control_list = {win,lbl,cal,cbtn,ck,fbtn1,fbtn2} 

settings:Load(ini) -- on startup, restore some settings;
show_all(win)

main()

--------------------------------------------------
global function ChangeBkgnd(atom ctl, atom target) 
--------------------------------------------------
    set(target,"background",get(ctl,"rgba"))
return 1
end function

-------------------------------------------------
global function ChangeFont(atom ctl, atom target)
-------------------------------------------------
    set(target,"font",get(ctl,"font name"))
    set("Main Window","resize",1,1) -- resize to smallest that will fit.
return 1
end function

-------------------------
global function BailOut() 
-------------------------
 -- save state for controls in {list};
    settings:Save(ini,control_list)

 -- save non-default properties for these controls;
    settings:Set(ini,"My Label","font",get("TextFontBtn","font"))
    settings:Set(ini,"My Calendar","font",get("CalendarFontBtn","font"))
    settings:Set(ini,"Main Window","background",get("ColorButton","rgba"))
    settings:Set(ini,"Main Window","size", get("Main Window","size"))
    settings:Set(ini,"Main Window","position", get("Main Window","position"))
    
return Quit()
end function
