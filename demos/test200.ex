
------------------------------------------------------------------------
--# Demo of NON-MODAL dialogs
------------------------------------------------------------------------

include GtkEngine.e
include resources/mongoose.e

constant docs = `<b><u>Non-Modal Dialogs</u></b>

These should be used with caution, as they tend to clutter
up the screen, and there are usually better ways to
accomplish the same purpose.

Click the OK button below several times to pop up non-modal dialogs.
Then try changing various settings, and clicking Apply.

See also test288.ex
`
integer ct = 0

constant 
     apply_colors = _("ApplyColors"),
     clear_colors = _("ClearColors"),
     close_dialog = _("CloseDialog"),
     normal_background = #dbdbdb,

     win = create(GtkWindow,"size=300x-1,border=10,$enter-notify-event=ChangeFocus,$destroy=Quit"),
     panel = add(win,create(GtkBox,VERTICAL)),
     lbl = create(GtkLabel,{{"markup",docs}}),
     box = create(GtkButtonBox),
     btn1 = create(GtkButton,"gtk-quit","Quit"),
     btn2 = create(GtkButton,"gtk-ok","ShowNonModalDialog")
 
     add(win,panel)
     add(panel,lbl)
     add(box,{btn1,btn2})
     pack(panel,-box)
     
show_all(win)
main()

------------------------------------------
function ApplyColors(atom ctl, atom data)
------------------------------------------
     set(win,"background",get(data,"rgba",1))
 return 1
end function

-------------------------------------------
function ClearColors()
-------------------------------------------
	set(win,"background",normal_background)
 return 1
end function

-------------------------------------------
function CloseDialog(atom ctl, object id)
-------------------------------------------
 set(unpack(id),"destroy") 
 return 1
end function

-------------------------------------
global function ChangeFocus(atom ctl)
-------------------------------------
 set(ctl,"present")
 set(ctl,"grab focus")
 return 1
end function

---------------------------------------
global function ShowNonModalDialog() --
---------------------------------------
object -- these will be added to the dialog's main panel (above the buttons)
     colorbutton = create(GtkColorButton,{
          {"rgba",rand(#FFFFFF)},
          {"tooltip text","Choose a color for the main window\nclick Apply"}}),
     colorlbl = create(GtkLabel,"Choose a color"),
     colorbox = create(GtkButtonBox,HORIZONTAL) -- holder for label and colorbutton
     set(colorbox,"layout",GTK_BUTTONBOX_CENTER)
     add(colorbox,{colorlbl,colorbutton})
    
ct += 1
object dialog_name = sprintf("dialog %d",ct)

object testbtns = { -- these will be added along the bottom of the dialog in the usual button location
     {"gtk-cancel#_Clear",clear_colors},
     {"gtk-apply#_Apply",apply_colors,colorbutton},
     {"gtk-close#_Close",close_dialog,dialog_name}
     }  
    
    Custom(win,               			-- 1: parent
	  "test200",              			-- 2: titlebar caption
	  "Non modal dialog",     			-- 3: primary text
	  sprintf(`<span font="32">  %d</span>`,ct),	-- 4: secondary text 
	  testbtns,                         -- 5: array of buttons, add to the dialog's content area.
	  "thumbnails/user_icon.gif", 		-- 6: icon 
	  oeu_logo,                         -- 7: titlebar icon from mongoose.e include
	  "white",                          -- 8: background color
	  GTK_DIALOG_NON_MODAL, 			-- 9: mode
	  colorbox, 					    -- 10: add-on widget, 
	  rand(800), 					    -- 11: x location
	  rand(600),                        -- 12: y location
	  dialog_name)                      -- 13: unique name
return 1
end function
