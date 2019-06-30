
---------------------------------------------------------------------------
--# Screen Capture program
-- Calls whichever linux screenshot program is available,
-- won't work on Windows without modification.
---------------------------------------------------------------------------

include GtkEngine.e

ifdef WINDOWS then
	Error(,,"No screenshot program known for Windows")
	abort(1)
end ifdef

object ss = {"mate-screenshot","gnome-screenshot"}

for i = 1 to length(ss) do -- look for valid screenshot program; 
  if string(uses(ss[i],0)) then ss = uses(ss[i],0) exit end if
end for

uses(ss)

constant 
    win = create(GtkWindow,"size=300x100,border_width=10,icon=camera,$destroy=Quit"),
    panel =  create(GtkBox,"orientation=vertical,spacing=10"),
    lbl1 = create(GtkLabel,"markup=<u><b>Screen Capture</b></u>\nClick the OK button to take a screen shot"),
    cam = create(GtkImage,"applets-screenshooter",GTK_ICON_SIZE_DIALOG),
    lbl2 = create(GtkLabel,sprintf("markup=<b>Using:</b> %s",{ss})),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"camera#_OK",_("ScreenShot")),
    box = create(GtkButtonBox)
    
    add(win,panel)
    add(panel,{lbl1,cam,lbl2})
    add(box,{btn1,btn2})
    pack(panel,-box)

show_all(win)
main()

-----------------------------
function ScreenShot()
-----------------------------
    system(sprintf("%s -i ",{ss}),0)
return 1
end function
