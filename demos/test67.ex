
-------------------------------------------------------------------
--# Multiple RadioButton groups
-------------------------------------------------------------------

constant docs = `<u><b>Radio button groups</b></u>
All buttons call the same function, 
but each group does its own thing.
`
include GtkEngine.e

constant 
    win = create(GtkWindow,"size=300x100,border_width=10,position=1,$destroy=Quit"),
    panel = create(GtkBox,"orientation=VERTICAL,spacing=5"),
    lbl1 = create(GtkLabel,{{"markup",docs}}),
    sep = create(GtkSeparator,"color=red"),
    lbl2 = create(GtkLabel,"font='purisa bold 48',color=red,text=One")

object set1 = {}
 set1 &= create(GtkRadioButton,NULL,"One","Foo",1) -- NULL as first param indicates new group
 set1 &= create(GtkRadioButton,set1[$],"Two","Foo",2) -- $ says 'use handle of previous button as group
 set1 &= create(GtkRadioButton,set1[$],"Three","Foo",3)
 
object set2 = {}
 set2 &= create(GtkRadioButton,NULL,"Red","Foo",#ff0000) -- NULL as first param indicates new group
 set2 &= create(GtkRadioButton,set2[$],"Green","Foo",#00ff00) -- last param is color to use
 set2 &= create(GtkRadioButton,set2[$],"Blue","Foo",#0000ff)

add(win,panel) 
add(panel,lbl1)
add(panel,set1)
add(panel,sep)
add(panel,set2)
add(panel,lbl2) 

constant names = {"One","Two","Three"} -- for lbl2

show_all(win)
main()

----------------------------------------------
global function Foo(atom ctl, object data)
----------------------------------------------
if get(ctl,"active") then -- only process selected, not de-selected;
    
    if find(ctl,set1) then -- handle is in first set (buttons 1..3)
	set(lbl2,"text",names[data]) -- convert 1,2,3 to name
	
    else -- handle is in second set (buttons 4..6)
	set(lbl2,"color",data)
    end if
    
end if
return 1
end function
