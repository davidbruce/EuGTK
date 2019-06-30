
--# Menus, Accellerator Keys

include GtkEngine.e
include menuwin.e
include gplwin.e
include helpwin.e
include aboutwin.e

constant -- create the main interface;

    win = create(GtkWindow,"title=Main Window;size=300x100;border=10,$destroy=Quit"),
        
    box = create(GtkBox,"orientation=vertical,spacing=10"),
    
    lbl = create(GtkLabel)
    
    -- set some properties that can't be easily set "inline";
    
    set(lbl,"markup",`
     Use the menus above, 
     or try &lt;alt&gt;L to see the LGPL,
     &lt;alt&gt;A to see the About Window,
     or F1 for the Help Window.
     
     &lt;ctl&gt;Q closes the main window (with ok dialog)
     &lt;alt&gt;F4 closes the focussed window.`)
            
    set(win,"add accel group",group) -- enable <ctl>keys to operate on window;

    -- "package" the items into the window;
    add(win,{group,box})
    pack(box,{menubar,lbl})
 
    -- instantiate and run;
 show_all(win)
 main()

-------------------------
global function onClose()
-------------------------
if Question(`title=Confirm Exit;
 sec=Do you really want to close this application?`) = MB_YES
then Quit()
end if
return 1 
end function

-- NOTE: there's a difference between windows and dialogs:
-- a window requires <alt>F4 or clicking on the [x] titlebar button to close,
-- a dialog can also be dismissed by hitting <esc>.

