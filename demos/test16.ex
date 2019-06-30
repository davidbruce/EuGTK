
--------------------------------------------------------------------------------
--# GtkComboBoxEntry, with user-added items
--
-- Allows user to type or paste data into the box,  
-- in order to choose something that isn't in the supplied set.
--
-- It does not automatically add the item to the list for future use. 
-- To do that, you need to add it yourself. See function ShowChoice below.
--
-- Note also that the Combo entry normally 'traps' the enter key
-- when the cursor is in the input box.
-- Usually, you would like that to actually do something.
-- So we obtain the entry and connect the 'activate' signal 
-- to do something useful - see NOTE [1] below.
--------------------------------------------------------------------------------

include GtkEngine.e
include std/sort.e

constant docs = `<u><b>ComboBoxEntry</b></u> 
allows user to type in 
an item not on the list.
`
sequence fruit = sort({"Apple","Banana","cherry","Grape","Peach","pear","Orange"})

constant csort = routine_id("CSort") -- sort ignoring case;

constant 
	win = create(GtkWindow,"title=`Combo Box Entry`,size=250x80,border=10,position=1,$destroy=Quit"),
	panel = create(GtkBox,"orientation=VERTICAL"),
	lbl = create(GtkLabel,"markup=<u><b>ComboBoxEntry</b></u>\nChooose your favorite\n\n" &
		"(User can type in an item not on the list)"),
	box = create(GtkButtonBox),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-ok","ShowChoice"),
	combo = create(GtkComboBoxEntry,"margin_bottom=10")
	add(combo,custom_sort(csort,fruit))
	set(combo,"active",1)
	
--NOTE [1]
constant cb_entry = get(combo,"entry")       -- get the combo's GtkEntry
connect(cb_entry,"activate","ShowChoice")    -- display results on enter key
	
	set(btn2,"can default",TRUE)
	set(win,"default",btn2)

	add(win,panel)
	add(panel,{lbl,combo})
	pack_end(panel,box)
	add(box,{btn1,btn2})

show_all(win)
main()

-----------------------------------
function CSort(object a, object b) -- sort ignores case;
-----------------------------------
    return compare(lower(a),lower(b))
end function

------------------------------------------
global function ShowChoice(atom ctl, atom data)  
------------------------------------------ 
object favorite = get(combo,"active text") 
	
    if length(favorite) > 0 then
		
	if find(lower(favorite),lower(fruit)) > 0 then
	    return Info(win,,proper(favorite),"is your favorite fruit")
	end if
		
	if Question(win,,
	    text:format("Your favorite is:\n []",{proper(favorite)}),
			"\nWould you like to add this\nto the list of fruits?") 
			
	    = MB_YES then -- add it to the list and refresh the combo's list
		fruit = append(fruit,favorite)
		set(combo,"remove all")
		add(combo,custom_sort(csort,fruit))
	end if
	
    end if
	
return 1
end function



