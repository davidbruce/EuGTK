
-------------------------------------------------------------------------
--# GtkRecentChooser
-------------------------------------------------------------------------

include GtkEngine.e
include std/net/url.e

constant 
    win = create(GtkWindow,"size=300x100,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,VERTICAL),
    lbl = create(GtkLabel,"markup='<b><u>RecentChooserDialog</u></b>\nClick OK to start',margin top=10"),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","Show")
    
    add(win,panel)
    add(panel,lbl)
    add(box,{btn1,btn2})
    pack(panel,-box)
    
show_all(win)
main()

---------------------------------------------------
global function Show()
---------------------------------------------------
object rc_dlg = create(GtkRecentChooserDialog,"Recent Files",win)
set(rc_dlg,{
    {"title","Recent files"},
    {"add button","gtk-cancel", MB_CANCEL},
    {"add button","gtk-open", MB_ACCEPT},
    {"default size",300,300},
    {"show not found",TRUE},   -- (don't know the conditions in which this works)
    {"limit",10}, 	           -- max number of items to display
    {"show tips",TRUE},        -- shows tooltip with full path to file
    {"local only",TRUE},       -- don't show networked files
    {"select multiple",FALSE}, -- if true, allow selecting more than one
    {"show icons",TRUE},       -- show file-type icons beside names
    {"sort type",GTK_RECENT_SORT_MRU}})

object filename
if get(rc_dlg,"run") = MB_ACCEPT then
    filename = get(rc_dlg,"current uri") 
		ifdef WINDOWS then 
			system(sprintf("explorer %s",{abbreviate_path(filename)}),0)
			set(rc_dlg,"destroy")
			return 1
		end ifdef
		show_uri(filename)
	end if
set(rc_dlg,"destroy")
return 1
end function
