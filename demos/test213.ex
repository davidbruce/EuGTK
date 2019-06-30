
--# Syntax Color Chooser, GtkListBox, ini demo

namespace colors

include GtkEngine.e
include GtkSettings.e

constant 
    ini = canonical_path("~/demos/resources/test213.ini"),
    win = create(GtkWindow,"name=ColorChooser,title=GtkListBox,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbox = create(GtkListBox),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Bail")

add(win,pan)
pack_start(pan,lbox,1,1)
add(box,btn1)
pack_end(pan,box)

---------------------------------------------------------------------

object syntax_item = -- syntax names;
{
 "Normal",
 "Background",
 "Comment",
 "String",
 "Keyword",
 "Builtin",
 "Number",
 "Brace Highlight",
 "Line Number"
 }

object initial_color = -- if ini is not available;
{
 "black",
 "white",
 "red",
 "green",
 "magenta",
 "blue",
 "orange",
 "purple",
 "black"
}

export object cb = repeat(0,length(syntax_item))
export object bld = repeat(0,length(syntax_item))
export object ital = repeat(0,length(syntax_item))

object lbl = repeat(0,length(syntax_item))
object row = repeat(0,length(syntax_item))

for i = 1 to length(syntax_item) do

    row[i] = create(GtkBox)
    
    lbl[i] = create(GtkLabel,sprintf("%-15s",{syntax_item[i]}))
    set(lbl[i],"font","Ubuntu mono 12")
    set(lbl[i],"margin-left",4)
    set(lbl[i],"padding",10)
    set(lbl[i],"name",sprintf("%s label",{syntax_item[i]}))
    set(lbl[i],"color",initial_color[i])
    
    add(row[i],lbl[i])

-- Colors:
    cb[i] = create(GtkColorButton)
    set(cb[i],"tooltip text",sprintf("%s color",{syntax_item[i]}))
    set(cb[i],"rgba",initial_color[i])
    set(cb[i],"name",sprintf("%s button",{syntax_item[i]}))
    connect(cb[i],"color-set",_("UpdateColor"),i)

    pack(row[i],cb[i],1,0)
    
-- Bold:
    bld[i] = create(GtkCheckButton,"tooltip text=Bold")
    set(bld[i],"name",sprintf("%s bold",{syntax_item[i]}))
    connect(bld[i],"toggled",_("UpdateStyle"),i)
    pack_end(row[i],bld[i])
    
-- Italic:
    ital[i] = create(GtkCheckButton,"tooltip text=Italic")
    set(ital[i],"name",sprintf("%s italic",{syntax_item[i]}))
    connect(ital[i],"toggled",_("UpdateStyle"),i)
    pack_end(row[i],ital[i])
    
    set(lbox,"insert",row[i],-1)
    
end for

settings:Load(ini)
object bkcolor = settings:Get("ColorChooser","bkcolor") display(bkcolor)
for i = 1 to length(row) do
    set(row[i],"background",bkcolor)
    set(lbl[i],"color",get(cb[i],"rgba"))
end for
set(cb[2],"rgba",bkcolor)
set(lbl[2],"color",get(cb[1],"rgba"))
set(bld[2],"sensitive",FALSE)
set(ital[2],"sensitive",FALSE)

show_all(win)
main()

------------------------------------------------
function UpdateColor(atom ctl, atom x) --
------------------------------------------------
set(lbl[x],"color",get(cb[x],"rgba"))
if x = 2 then
    bkcolor = get(cb[2],"rgba")
    for i = 1 to length(row) do
      set(row[i],"background",bkcolor)  
    end for
end if
set(lbl[2],"color",get(cb[1],"rgba"))
return 1
end function

-----------------------------------------
function UpdateStyle(atom ctl, atom x) --
-----------------------------------------
object style = ""
if get(bld[x],"active") then style = "bold " end if
if get(ital[x],"active") then style &= "italic" end if
if length(style) = 0 then
    style = "normal"
end if
set(lbl[x],"font",style)
return 1
end function

-------------------------
global function Bail() --
-------------------------
settings:Save(ini,cb & bld & ital)
settings:Set(ini,"ColorChooser","bkcolor",bkcolor)
return Quit()
end function

