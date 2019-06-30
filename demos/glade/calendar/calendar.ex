
-----------------------------------------------------------------------
--# Display a nice calendar using EuGTK and Glade
-----------------------------------------------------------------------
with define BUILDER -- shows objects if run from xterm

include GtkEngine.e

add(builder,locate_file("calendar.glade"))

-- PATCH: Gtk 3.14 forgets to add a close button to the about.dialog!
    if minor_version = 14 then 
        set("aboutdialog1","add button","gtk-close",0)
    end if
    
main()

---------------------------------------------------------------------
global function on_calendar1_day_selected_double_click()
---------------------------------------------------------------------
return Info("window1",,"Calendar Clicked",
        get("calendar1","date","%A, %b %d, %Y"),,
        "~/demos/thumbnails/cal.png","x-office-calendar")
end function

---------------------------------------------------------------------
global function on_OK_button_clicked() 
---------------------------------------------------------------------
return Info("window1",, -- see calendar date formats in HowItWorks.html
        get("calendar1","date","Today is %A"),
        get("calendar1","date","<b>%B %d</b>, which is\nday %j of the year %Y\n"),,
        "~/demos/thumbnails/cal.png","x-office-calendar")
end function

---------------------------------------------------------------------
global function on_About_button_clicked()
---------------------------------------------------------------------
return run("aboutdialog1")
end function

---------------------------------------------------------------------
global function check_link()
---------------------------------------------------------------------
 if networked() and inet_connected() then
    return 0 -- go ahead and try the link;
 else
    Warn(,,"Network Error",
    "No connection to Web!",,
    "~/demos/thumbnails/net0.png")
    return 1 -- don't try to connect the link;
end if
end function

---------------------------------------------------------------------
global function on_aboutdialog1_response() 
---------------------------------------------------------------------
  set("aboutdialog1","hide")
return 1
end function

