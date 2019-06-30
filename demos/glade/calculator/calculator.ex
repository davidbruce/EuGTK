
------------------------------------------------
--# Calculator - uses math_eval.e by Shian Lee
------------------------------------------------

include GtkEngine.e
include GtkEvents.e
include std/convert.e

include math_eval.e 

add(builder,canonical_path("~/demos/glade/calculator/calculator.glade"))

object accumulator = ""

boolean has_decimal = FALSE
integer parens = -0
 
set("label1","color=yellow,font=bold 16") 
set("eventbox1","background","black")
set("window1","icon","calc")

main()

-----------------------------------------------------------------------
global function on_button_clicked(Button btn) 
-----------------------------------------------------------------------
object key = get(btn,"name")
switch key do
    case "clr" then clear_display()
    case "=" then adjust_parens() do_calc()
    case else update_display(key)
end switch
return 0
end function

-----------------------------------------------------------------------
global function on_window1_key_press_event(Window w, atom event) 
-----------------------------------------------------------------------
object key = events:key(event) 
switch key do
    case 8 then do_backspace()
    case 13 then update_display(key) do_calc() -- enter key
    case 27 then clear_display() -- esc key clears accumulator
    case 174 then update_display(".") -- keypad '.' = 174
    case else if key > 0  then update_display(key) end if
end switch
	return 0
end function 

-------------------------------------
procedure do_backspace()
-------------------------------------
if length(accumulator) then 
    accumulator = accumulator[1..$-1]
    set("label1","text",accumulator)
end if
end procedure

-------------------------------------
procedure clear_display()
-------------------------------------
    accumulator = ""
    set("label1","text",accumulator)
    parens = 0
    has_decimal = FALSE
end procedure

-------------------------------------
procedure update_display(object key)
------------------------------------- 
    switch key do 
	case 40 then parens += 1
	case 41 then if parens > 0 then parens -= 1 end if
	case 13 then adjust_parens() return 
	case "|" then
	    adjust_parens()
	    set("label1","text",accumulator)
	    return 
	case "." then 
	    if has_decimal then return end if
	    has_decimal = TRUE 
    end switch
    accumulator &= key
    set("label1","text",accumulator)
end procedure

------------------------------------------------
procedure adjust_parens()
------------------------------------------------
    while parens > 0 do
	accumulator &= ')'
	parens -= 1
    end while
end procedure

------------------------------------------------
procedure do_calc() -- send text to math_eval()
------------------------------------------------
object txt = accumulator	
    if parens then txt &= ")" end if
object results = math_eval(txt)
	if atom(results) then -- valid result 
		results = sprintf("%g",results)
		set("label1","text",accumulator & " = " & results)
		accumulator = results
	else -- display the error message
		Warn(,,accumulator,results,,"calc",64) 
	end if
	
end procedure

-----------------------------------------
global function on_fn_clicked(Button b) 
-----------------------------------------
object name = get(b,"name") 
  if find('(',name) then parens += 1 end if
  accumulator &= name
  set("label1","text",accumulator)
return 1
end function

-----------------------------------------
global function Run(atom ctl, atom data)
-----------------------------------------
    run(data)
    hide(data)
return 1
end function



