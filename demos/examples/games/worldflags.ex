
----------------------------------------------------------------------------
--# Worldflags - match the flags and name the country (and test your memory)
----------------------------------------------------------------------------

include GtkEngine.e
include std/filesys.e
include std/sequence.e

integer prev = 0, guesses = 0, correct = 0, misses = 0
atom score =  0
constant flagdir = canonical_path("~/demos/resources/flags/")

----------------------------
-- get list of flag names 
----------------------------
object flaglist = dir(flagdir & "flags-*.png")

    if atom(flaglist) then
        Error(0,"Worldflags Error","Cannot find flags",flagdir,,GTK_BUTTONS_CLOSE)
        abort(1)
    end if
     
    flaglist = vslice(flaglist,D_NAME)
     
--------------------------------
-- select 8 at random, no dupes 
--------------------------------
object flagarray = {}
while length(flagarray) < 8 do
    flagarray = add_item(flaglist[rand(length(flaglist))],flagarray)
end while

---------------------------------------------
-- shuffle the 8 and add them to list again 
-- so every flag has a twin somewhere       
---------------------------------------------
flagarray &= shuffle(flagarray)

enum HANDLE, FLAG, TUX, NAME, CAPTION, SIGID, HASH, MATCHED

-------------------------------------------
-- create buttons from the selected flags 
-------------------------------------------
object btn = {HANDLE,FLAG,TUX,NAME,CAPTION,SIGID,HASH,MATCHED}
object btns = repeat(btn,16)
object ctl, name, flag, tux, box, lbl, sigid, id
for i = 1 to 16 do 
     
     -- get rid of the file extension, and change country name to nice format;
        name = proper(join(split(flagarray[i][7..$-4],'_'),' '))
    
    -- match flag with its twin by means of a hash on the file name;
        id = hash(name,0) 
    
     -- make a button to hold the flag;
        ctl = create(GtkToolButton)
        flag = create(GtkImage,flagdir & flagarray[i])
        tux = create(GtkImage,"~/demos/thumbnails/BabyTux.png")
        sigid = connect(ctl,"clicked",call_back(routine_id("onClick")),i)
            box = create(GtkBox,1)
            lbl = create(GtkLabel,{
				{"text",name},
                {"font","8"},
                {"max width chars",10},
                {"ellipsize",PANGO_ELLIPSIZE_END}})
                add(box,{tux,flag,lbl})
            set(ctl,{
				{"label widget",box},
				{"size request",80,80}})
            show({ctl,box,flag,lbl})
        btns[i] = {ctl,flag,tux,name,lbl,sigid,id,FALSE}
     
        ifdef CHEAT then
            set(ctl,"tooltip text",name)
        end ifdef
end for
 
----------------------
-- make a main window 
----------------------
constant win = create(GtkWindow,{
    {"border width",10},
    {"default size",120,120},
    {"position",GTK_WIN_POS_CENTER},
    {"icon","thumbnails/preferences-desktop-locale.svg"}})
    connect(win,"destroy","Quit")
    show(win)

constant panel = create(GtkBox,1)
    add(win,panel)
    show(panel)

---------------------
-- make a grid 
---------------------
constant grid = create(GtkGrid,{
    {"row homogeneous",TRUE},
    {"column homogeneous",TRUE}})
    add(panel,grid)
    show(grid)

-------------------------------
-- attach flag buttons to grid
-------------------------------
integer i = 1
for x = 1 to 4 do
    for y = 1 to 4 do
        set(grid,"attach",btns[i][HANDLE],x,y,1,1)
        i += 1
    end for
end for

constant helptxt = create(GtkLabel,{
	{"markup","Perfect score is 100"},
    {"font","8"},
    {"foreground","red"}})
    add(panel,helptxt)
    show(helptxt)

------------------------------------------
-- show flags for 5 seconds, then hide 'em
------------------------------------------ 
constant delay = create(GTimeout,5000,call_back(routine_id("hide_flags")))

main()

------------------------------------------------------------------------
function hide_flags() -- called once at start of pgm. after a delay
------------------------------------------------------------------------
    for x = 1 to 16 do
        set(btns[x][FLAG],"hide")
        set(btns[x][CAPTION],"hide")
        set(btns[x][TUX],"show")
        btns[x][MATCHED] = FALSE
    end for
return 0 -- 0 kills the timer, otherwise it would fire again every 5 sec.
end function

---------------------------------------------------------------
function onClick(atom ctl, integer this)
---------------------------------------------------------------
    set(btns[this][TUX],"hide")
    set(btns[this][FLAG],"show")

    if btns[this][MATCHED] then return 1 end if

    if prev > 0 then
       
        if this = prev then return 1 end if -- same one clicked again, forgettaboutit!
      
       if btns[this][HASH] != btns[prev][HASH] then -- not a match
            set(btns[prev][FLAG],"hide")
            set(btns[prev][CAPTION],"hide")
            set(btns[prev][TUX],"show")
            misses += 1
            prev = this
            guesses += 1
            score -= 1
        else -- matched!
            btns[prev][MATCHED] = TRUE
            btns[this][MATCHED] = TRUE
            guesses += 1
            correct += 1
            prev = 0
            popup_extra_credit(this)
        end if
    else
        prev = this
    end if

    set(win,"title", -- update score;
        sprintf("Score: %2.1f",score))
        
    return 1
end function

-------------------------------------------------------------
function popup_extra_credit(integer x)
-------------------------------------------------------------
object dlg = create(GtkDialog,{
    {"default size",200,200},
    {"border width",10},
    {"add button","gtk-ok",1}})

object ca = get(dlg,"content area") 

object img = create(GtkImage,sprintf("~/demos/resources/flags/%s",{flagarray[x]}))
object lbl = create(GtkLabel,{
    {"font","8"},
    {"markup",
        "You get <b>5 points</b> for correctly matching the flags.\n" &
        "For <i>more</i> points, please identify the country that\nflies this flag."}})
        
object sep = create(GtkSeparator)
    add(ca,{img,lbl,sep})

object choices = {btns[x][NAME]}
    while length(choices) < 3 do
        choices = add_item(btns[rand(16)][NAME],choices)
    end while
    choices = shuffle(choices)

object btn = repeat(0,3)
    btn[1] = create(GtkRadioButton,0,choices[1])
    btn[2] = create(GtkRadioButton,btn[1],choices[2])
    btn[3] = create(GtkRadioButton,btn[2],choices[3])
    add(ca,btn)
    show_all(ca)

object choice
integer i = get(dlg,"run")

    for j = 1 to 3 do
        if get(btn[j],"active") then choice = choices[j] end if 
    end for

    if equal(choice,btns[x][NAME]) then
        score += 100/8
        show_matched_captions(0)
        Beep()
    else
        score += 5
        show_matched_captions(x)
        set(helptxt,"text","Incorrect guesses are shown in red")
    end if

    set(dlg,"destroy")
    show_matched_captions(0)

return 1
end function

------------------------------------------------------------------------
procedure show_matched_captions(integer x)
------------------------------------------------------------------------
for i = 1 to 16 do
    if btns[i][MATCHED] then show(btns[i][CAPTION]) end if
    if x > 0 then -- set miss-identified captions to red
        if equal(btns[i][NAME],btns[x][NAME]) then 
            set(btns[i][CAPTION],"color","red")
        end if
    end if
end for
end procedure


