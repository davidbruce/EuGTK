
---------------------------------------------------------------
--# Gray code/Decimal/Hex/Octal/Binary conversion program
-- I needed a Gray code generator, and it just kept growing!
-- Run with -d CODE to display Gray code table on console
----------------------------------------------------------------

include GtkEngine.e
include std/console.e
include std/convert.e
include std/sequence.e

-- change MAX_BIN_DIGITS to suit yourself; the bigger the number,
-- the longer it takes to generate a Gray code list;
constant MAX_BIN_DIGITS = 16

-- compute largest number possible given max_bin_digits:
constant MAX_NUM = power(2,MAX_BIN_DIGITS) -1 

constant -- define max # of digits allowed in inputs;
	DMAX = length(format("[]",MAX_NUM)), 
	BMAX = length(format("[B]",MAX_NUM)),
	HMAX = length(format("[X]",MAX_NUM)),
	OMAX = length(sprintf("%o",MAX_NUM)) 

constant -- allowable sets of chars (used to filter out unwanted key presses)
	BINNUM = {{'0','1'}}, 
	DECNUM = {{'0','9'}},
	OCTNUM = {{'0','7'}},
	HEXNUM = {{'0','9'},{'A','F'},{'a','f'}}

constant msg = "1. Enter a value in any box \n2. press enter"
constant docs = sprintf("<u><b>Converter</b></u>\n\nConverts numbers between 0 and %d",MAX_NUM)

enum BIN = 2, DEC = 10, HEX = #F, OCT = 8 

---------------------------------------------------------------
-- Generate Gray code table using the manual (pencil & paper)
-- method, 'cause it's easy to code and I flunked calculus ;)
---------------------------------------------------------------
object Gray = {"0","1"}

for i = 1 to MAX_BIN_DIGITS-1 do
	Gray = Gray & reverse(Gray) -- {"0","1","1","0"}
	for j = 1 to length(Gray) do
		if j <= length(Gray)/2 then 
			Gray[j] = "0" & Gray[j] -- prepend "0" to first half,
		else
			Gray[j] = "1" & Gray[j] -- prepend "1" to second half
		end if
	end for
end for

ifdef CODE then -- display code table on terminal;
	for i = 1 to length(Gray) do
		printf(1,"%d %s\n",{i-1,Gray[i]})
	end for
end ifdef

--------------------------------------------------------------------------------------
-- Build GUI
--------------------------------------------------------------------------------------
constant win = create(GtkWindow,
	"title=Code Converter,size=120x150,border=20,position=1,$destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL")
	add(win,panel)

constant lbl1 = create(GtkLabel)
	set(lbl1,"markup",docs)
	add(panel,lbl1)

constant 
	 inpGray = BuildInput("Gray",BIN,MAX_BIN_DIGITS),
	 inpDec = BuildInput("Decimal",DEC,DMAX),
	 inpHex = BuildInput("Hex",HEX,HMAX),
	 inpOct = BuildInput("Octal",OCT,OMAX),
	 inpBin = BuildInput("Binary",BIN,BMAX)

	 set(inpGray,"tooltip text","Accepts binary digits 1 or 0")
	 set(inpDec,"tooltip text","Accepts decimal digits 0-9, max 65,535")
	 set(inpHex,"tooltip text","Accepts hex digits 0-9,A-F, max FFFF")
	 set(inpOct,"tooltip text","Accepts octal digits 0-7, max 177777")
	 set(inpBin,"tooltip text","Accepts binary digits 1 or 0")

constant lbl2 = create(GtkLabel)
	add(panel,lbl2)
	set(lbl2,"markup",msg)

show_all(win)
main()

--------------------------------------------------------------
function BuildInput(sequence caption,integer base,integer max)
--------------------------------------------------------------
object lbl = create(GtkLabel,caption)
object inp = create(GtkEntry)
	set(inp,"font","Courier Bold 16")
	set(inp,"size request",100,40)
object buf = get(inp,"buffer")
	set(buf,"max length",max)
	connect(buf,"inserted-text",call_back(routine_id("FilterBase")),base)
	connect(inp,"activate",call_back(routine_id("UpdateDisplay")))
	add(panel,{lbl,inp})
return inp
end function

--------------------------------------------------
function UpdateDisplay(atom ctl)
--------------------------------------------------
object buf = get(ctl,"buffer")
object val = get(buf,"text") 
object dec = 0

	set(lbl2,"markup",msg)

	switch ctl do -- convert from ctl's base to decimal value;
		case inpDec then dec = to_number(val)
		case inpHex then dec = to_number(sprintf("#%s",{val}))
		case inpOct then dec = to_number(sprintf("@%s",{val}))
		case inpBin then dec = to_number(sprintf("!%s",{val}))
		case inpGray then 
			val = pad_head(val,MAX_BIN_DIGITS,'0') 
			dec = find(val,Gray)-1
	end switch

	if dec > MAX_NUM then 
		set(lbl2,"markup","<span color='red'>Warning - number too large!</span>")
		
	else -- update the number in all input fields, converting dec to base as needed;
		set(inpGray,"text",Gray[dec+1])
		set(inpDec,"text",format("[]",dec))
		set(inpHex,"text",format("[X]",dec))
		set(inpOct,"text",sprintf("%o",dec))
		set(inpBin,"text",format("[B]",dec))
	end if

return 1
end function

----------------------------------------------------------------------------------------
function FilterBase(atom buf, integer pos, object char, integer n, integer base)
----------------------------------------------------------------------------------------
object txt = get(buf,"text") 

	char = peek_string(char)

	switch base do -- if char entered isn't valid for base, delete it.
		case BIN then if not char_test(char,BINNUM) then set(buf,"delete text",pos,1) end if
		case OCT then if not char_test(char,OCTNUM) then set(buf,"delete text",pos,1) end if
		case DEC then if not char_test(char,DECNUM) then set(buf,"delete text",pos,1) end if
		case HEX then if not char_test(char,HEXNUM) then set(buf,"delete text",pos,1) end if
	end switch

return 1
end function



