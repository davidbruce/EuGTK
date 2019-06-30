
--# Unit conversion by <b>Jim Roberts</b>

include GtkEngine.e 
include _convert.e 
include std/math.e
   
-- [1] additional routines added by Kenneth Rhodes, Irv Mullins: 

global constant index = {"Length", "Time", "Velocity", "Angles",  "Angular Velocity","Area", "Volume",  "Weight", "Pressure", "Energy"} 
 
global function SelectUnit(integer i) 
object cs = {}
   for a = 1  to length(Unit[i]) by 2 do 
      cs = append(cs, Unit[i][a])  
   end for 
return cs 
end function

-- [2] GUI by Irv;

constant  
    win = create(GtkWindow,"border_width=10,position=1,$destroy=Quit"), 
    pan = create(GtkBox,"orientation=HORIZONTAL,spacing=10"), 
    lbl = create(GtkLabel,"Unit Category"), 
    cb1 = create(GtkComboBoxText),  
    V1 = create(GtkEntry,"placeholder text=Value to convert,$changed=Convert"),  
    cb2 = create(GtkComboBoxText,"$changed=Convert"),  
    cb3 = create(GtkComboBoxText,"$changed=Convert"),   
    V2 = create(GtkEntry,"placeholder text=Results,width chars=40"), 
     
    btnbox = create(GtkButtonBox,"spacing=5"), 
    btn = create(GtkButton,"gtk-quit","Quit") 
     
     set(win,"title","Conversion routines by Jim Roberts")
    add(win,pan) 
    add(pan,{lbl,cb1,V1,cb2,cb3,V2})  
    add(pan, V2) 
    pack_end(pan,btnbox) 
    add(btnbox,btn) 
    
    for i = 1 to length(index) do
        set(cb1,"append text",index[i])
    end for
    connect(cb1,"changed","Update")
    
show_all(win) 
main() 
 
---------------------------
global function Update() --
---------------------------
integer u = get(cb1,"active")
object units = SelectUnit(u)

 set(cb2,"remove all") 
 set(cb3,"remove all")
 for j = 1 to length(units) do
    set(cb2,"append text",units[j])
    set(cb3,"append text",units[j])
 end for
 set(cb2,"active",1)
 set(cb3,"active",1)
 
return 1 
end function 

----------------------------
global function Convert() --
----------------------------
atom val = to_number(get(V1,"text"))  
object from_units = get(cb2,"active text")
object to_units = get(cb3,"active text")

if val = 0 or atom(from_units) or atom(to_units) then return 1 end if

object results = convert_unit(val,from_units, to_units)
 results[1] = from_units
 results[2] = to_units 
 set(V2,"tooltip markup",text:format("[4] [1] = [3] [2]",results))
 
 results[3] = sprintf("%.4g",results[3]) 
 results = append(results,val)
 set(V2,"text",text:format("[4] [1] = [3] [2]",results))      

return 1
end function 
