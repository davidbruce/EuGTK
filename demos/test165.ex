
--# Print Operation demo

include GtkEngine.e
include GtkPrinter.e

constant docs = `<u><b>Print Operation</b></u>
Click button to pop up a dialog box.
<i>
 Note: be sure you have a printer set up 
 because each printer has different options,
 therefore different tabs will appear on the dialog.
 e.g. for a laserjet, you will see tabs for:
 General, Page Setup, Job scheduling,
 etc... 
 If no printer is set up, the dialog will be mostly 
 empty and useless.
 <span color='red'>
 Note! This does not PRINT anything, just demos the
 setup dialog!</span>
</i>
`
constant win = create(GtkWindow,"size=300x200,border=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
    add(win,panel)

constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(panel,lbl)

constant btn1 = create(GtkButton,"gtk-quit","Quit")
constant btn2 = create(GtkButton,"gtk-print","PageSetup")
constant box = create(GtkButtonBox)
    pack(panel,-box)
    add(box,{btn1,btn2})

show_all(win)
main()

-----------------------------------------
global function StartPrinting(atom op)
-----------------------------------------
    display("Status: []",{get(op,"status string")})
return 1
end function

-----------------------------------------------------------------
global function RenderPage(atom op, atom context, integer pg)
-----------------------------------------------------------------
    display("Status: []",{get(op,"status string")})
    display("Printing page #[]",pg)
return 1
end function

-----------------------------
global function PageSetup()
-----------------------------
object printop = create(GtkPrintOperation)
    set(printop,"job name","My Print Job #1")
    set(printop,"n pages",5)
    set(printop,"show progress",TRUE)
    set(printop,"track print status",TRUE)
    connect(printop,"begin-print","StartPrinting")
    connect(printop,"draw-page","RenderPage")
    set(printop,"run",GTK_PRINT_OPERATION_ACTION_PRINT_DIALOG,win)
return 1
end function
