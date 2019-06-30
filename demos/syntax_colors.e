
--------------------------
namespace syntax_colors --
--------------------------

export constant version = "4.15.0"
export sequence inifile = "~/demos/resources/syntax_colors.ini"

/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 */
	
include GtkEngine.e
include GtkSettings.e

if not equal(version,gtk:version) then
    Error(,,"GtkSyntaxColors version mismatch","should be version " & gtk:version)
end if

export constant
    dialog = create(GtkDialog,"name=ColorChooser,$delete event=Bail,title=Syntax Colors")

constant 
    ini = canonical_path(inifile),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbox = create(GtkListBox)

object aa = get(dialog,"action area")
add(aa,pan)
pack_start(pan,lbox,1,1)

---------------------------------------------------------------------

export object item = -- syntax names;
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

object initial_color = -- use if ini is not available;
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

export object button = repeat(0,length(item))
export object bold = repeat(0,length(item))
export object italic = repeat(0,length(item))

object lbl = repeat(0,length(item))
object row = repeat(0,length(item))

for i = 1 to length(item) do

    row[i] = create(GtkBox)
    
    lbl[i] = create(GtkLabel,sprintf("%-15s",{item[i]}))
    set(lbl[i],"font","Courier New, Ubuntu mono 12")
    set(lbl[i],"margin-left",4)
    set(lbl[i],"padding",10)
    set(lbl[i],"name",sprintf("%s label",{item[i]}))
    set(lbl[i],"color",initial_color[i])
    
    add(row[i],lbl[i])

-- Colors:
    button[i] = create(GtkColorButton)
    set(button[i],"tooltip text",sprintf("%s color",{item[i]}))
    set(button[i],"rgba",initial_color[i])
    set(button[i],"name",sprintf("%s button",{item[i]}))
    connect(button[i],"color-set",_("UpdateColor"),i)

    pack(row[i],button[i],1,0)
    
-- Italic:
    italic[i] = create(GtkCheckButton,"tooltip text=Italic")
    set(italic[i],"name",sprintf("%s italic",{item[i]}))
    connect(italic[i],"toggled",_("UpdateStyle"),i)
    pack_end(row[i],italic[i])
    
-- Bold:
    bold[i] = create(GtkCheckButton,"tooltip text=Bold")
    set(bold[i],"name",sprintf("%s bold",{item[i]}))
    connect(bold[i],"toggled",_("UpdateStyle"),i)
    pack_end(row[i],bold[i])
    
    set(lbox,"insert",row[i],-1)
    
end for

show_all(aa)

settings:Load(ini)
export object background = settings:Get("ColorChooser","background") 
for i = 1 to length(row) do
    set(row[i],"background",background)
    set(lbl[i],"color",get(button[i],"rgba"))
end for

set(button[2],"rgba",background)
set(lbl[2],"color",get(button[1],"rgba")) -- use normal text color
--set(bold[2],"sensitive",FALSE) -- n/a for background colors
set(italic[2],"sensitive",FALSE) 
set(bold[2],"tooltip text","N/A for backgrounds")
set(italic[2],"tooltip text","N/A for backgrounds")

------------------------------------------------
function UpdateColor(atom ctl, atom x) --
------------------------------------------------
set(lbl[x],"color",get(button[x],"rgba"))
if x = 2 then
    background = get(button[2],"rgba")
    for i = 1 to length(row) do
      set(row[i],"background",background)  
    end for
end if
set(lbl[2],"color",get(button[1],"rgba"))
return 1
end function

-----------------------------------------
function UpdateStyle(atom ctl, atom x) --
-----------------------------------------
object style = ""
if get(bold[x],"active") then style = "bold " end if
if get(italic[x],"active") then style &= "italic" end if
if length(style) = 0 then
    style = "normal"
end if
set(lbl[x],"font",style)
return 1
end function

-------------------------
global function Bail() --
-------------------------
settings:Save(ini,button & bold & italic)
settings:Set(ini,"ColorChooser","background",background)
hide(dialog)
return 1
end function

-------------------------------------
-- copyright 2005-2019 by Irv Mullins
-------------------------------------

	
