
---------------------------------------
--# Application, Notification, etc...
---------------------------------------

include GtkEngine.e

constant docs = `<u><b>GNotification</b></u>
demos pop-up notifications, if your window
manager allows.
`
constant lbl = create(GtkLabel,{{"markup",docs}})

constant app = create(GtkApplication,"gnome.org") 
connect(app,"activate","AddMainWindow")

run(app)

-------------------------------
global function AddMainWindow()
-------------------------------
 atom win = create(GtkApplicationWindow,app)

 set(win,"size=300x150,icon=face-cool,border=10,show menubar=1")

 add(win,lbl)
 
 set(win,"application",app) 
  

 atom note = create(GNotification,"Notice:")
 set(note,"body","<b>test205</b> Started\nthis message will self-destruct in a few seconds.")
  
 set(app,"send notification","startup",note)
 
 show_all(win)

return 1
end function


