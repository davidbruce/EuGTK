
--# Dialog modal and non-modal pop-up demo with call-back <span color='red'>New in EuGTK 4.14.6!</span>

include GtkEngine.e
include GtkSettings.e

constant docs = """markup=
 <b>Dialog addons</b>
 
 This demos the new named-parameter 
 function for EuGTK stock dialogs.
 
 Toggle the Calendar button 
 then click on a date. Click button
 again to close the calendar.
 """
constant
 win = create(GtkWindow,"size=300x-1,border=10,$destroy=Quit"),
 pan = create(GtkBox,"orientation=vertical,spacing=10"),
 lbl1 = create(GtkLabel,docs),
 lbl2 = create(GtkLabel),
 box = create(GtkButtonBox),
 btn1 = create(GtkButton,"gtk-quit","Quit"),
 btn2 = create(GtkButton,"gtk-about","Help"),
 btn3 = create(GtkButton,"thumbnails/cal.png#Calendar","PopupCalendar"),
 cal = create(GtkCalendar,"$day-selected=UpDate"),
 dlg = create(GtkDialog,"tip=Click on a date,$delete-event=hide,position=100x100")
 
 set(lbl2,"font","Purisa, Comic Sans MS 18")
 
 add(win,pan)
 add(pan,{lbl1,lbl2})
 add(box,{btn1,btn2,btn3})
 pack(pan,-box)
 
 add(get(dlg,"content area"),cal)
 show(cal)

show_all(win)
main()

---------------------------
global function UpDate() -- called whenever a calendar day is clicked;
---------------------------
set(lbl2,"markup",get(cal,"date","%A, %B %d, %Y"))
return 1 
end function

------------------------------------------
global function PopupCalendar(atom ctl) -- display a pop-up/dn box with a calendar;
------------------------------------------
if get(dlg,"visible") then hide(dlg) else show(dlg) end if
return 1
end function

-------------------------
global function Help() --
-------------------------
Info(`
pri=Pop-up Dialogs;
img=thumbnails/gtk-logo-rgb.gif;
sec=These dialogs can be modal or non-modal.

The calendar is non-modal, it can remain on screen
while other controls are activated.

This Info dialog is modal, it prevents other program
activity until it is dismissed.

A Pop-up dialog should have its close button 
disabled: set(dlg,"deletable",FALSE), or
have its delete-event signal trapped and sent to
the hide() function. Otherwise, the dialog will
be destroyed and will not be there if your program 
needs it again!

`)
return 1
end function
