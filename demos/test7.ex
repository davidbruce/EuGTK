
--------------------------------------------------------------------------------
--# GTK Entry, markup, dialogs, entry icons
--------------------------------------------------------------------------------

include GtkEngine.e

constant 
    win = create(GtkWindow,"title=GtkEntry,border=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL"),
    lbl = create(GtkLabel,"markup=Enter the name of the animal\nshown in the entry box above."),
    fox = create(GdkPixbuf,"thumbnails/fox.png",20,20),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok",_("ShowEntry")),
    btnbox = create(GtkButtonBox,"spacing=5"),
    edt = create(GtkEntry,{ 
        {"margin top",10},
        {"margin_bottom",10},
        {"icon from pixbuf",1,fox}, 
        {"icon activatable",1,TRUE}, 
        {"icon tooltip markup",1,"Click <i>me</i> to show the entered text"},
        {"placeholder text","Name this animal"}})
    
    connect(edt,"activate",_("ShowEntry")) -- on <enter>
    connect(edt,"icon-press",_("ShowEntry")) -- on icon clicked
    
    add(win,panel)
    add(panel,edt)
    add(panel,{lbl,fox})
    add(btnbox,{btn1,btn2})
    pack_end(panel,btnbox)

    set(btn1,"tooltip markup","Press to <b>quit</b>")
    set(btn2,"tooltip markup","Press to display the entered text")
    set(btn2,"grab focus") -- workaround for a bug in 'placeholder text' - see GtnEntry GTK docs

show_all(win)
main()

-----------------------------------------------------------
function ShowEntry()
-----------------------------------------------------------
object guess = get(edt,"text")

if length(guess) = 0 then guess = "nothing" end if

if equal(lower(guess),"fox") then 
    Info(win,"Answer","<u>Correct!</u>",
		sprintf("It <i>is</i> a <b>%s</b>",{guess}),,fox)
else
    if Question(win,"Sorry!",
        sprintf("<span underline='error' color='red'>%s</span> is not correct",{guess}),
        "Want to try again?") = MB_NO then Quit()
    end if
    set(edt,"text","")
end if

return 1
end function



