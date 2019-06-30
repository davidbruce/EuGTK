
-------------------------
namespace fontselector -- Generic font selector dialog
-------------------------

export constant version = "4.15.0"

/*
 * --  FUNCTIONS:			        CALLBACKS:
 *     fontselector:Select()        fontselector:select 
 *     fontselector:FilterFonts()   fontselector:filter
 *   
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
include GtkCairo.e
include std/wildcard.e
include std/math.e
include std/hash.e

if not equal(version,gtk:version) then
    Error(,,"GtkFontSelector version mismatch","should be version " & gtk:version)
end if

/* 

	Optional parameter is the preferred (default) font, the one to be 
	returned if the font dialog ok button is clicked without choosing
	a different font. You can just specify a size here: "8" and that 
	will set only the dialog's size selector.

	You can specify a full font name and size: e.g. Purisa bold 16,
	and that font will be the one highlighted for selection.
	If you specify a font that doesn't exist: e.g. Bogus italic 18,
	and then use the returned font, GTK will do the best it can, 
	which will be to set the existing font to italic in 18pt.
	Fairly fail-safe, in other words.

	Setting this does not filter the list of fonts shown by the dialog.
	to do this, you need to set the pattern. See below.

	To exclude unwanted (and unreadable) fonts, such as symbols and
	dingbats, add them to the exclude sequence. See below.

	pattern can be set prior to the select() call
	pattern can be an array of font names, wildcards are ok
	e.g. {"Courier*","purisa"}
	if you use, for example, just {"Courier"}, without the wildcard,
	no fonts will be found. Watch out!

	{"sans"}, {"*sans"}, or {"*sans*"} will each return a different
	set of matching font names! trial and error may be required.

	if pattern is left unset, ALL fonts will be shown!

*/
  
export atom dlg = create(GtkFontChooserDialog,"name=FontSelector")

export object
	name = 0, -- font name
	title = "Choose a font", -- dialog title
	preview_text = "This is an EuGTK font selector",
	description = 0, -- a PangoFontDescription
	family = 0, -- font family
	style = 0, -- normal, oblique, italic
	variant = 0,
	weight = PANGO_WEIGHT_NORMAL,
	mono_filter = 0, -- flag to make it easy to show only mono fonts;
	font_list = {}
	
export atom size = 12*1024
export integer points = 12
export sequence pattern = {"*"} 

export sequence exclude = {"*symbol*","*dingbat*","*webdings","*wingdings*","*vemana*"} 
-- above list filters out unusable fonts;

------------------------------------------------------------------------
export function Select(object curr_fnt=0)
------------------------------------------------------------------------
	set(dlg,"title",title)	
	set(dlg,"preview text",preview_text)
	if string(curr_fnt) then 
		set(dlg,"font",curr_fnt) 
	end if
	pattern = lower(pattern)
	exclude = lower(exclude)

	set(dlg,"filter func",filter)
	
	if get(dlg,"run") then
		name = get(dlg,"font") 
		description = create(PangoFontDescription,name)
		family = get(description,"family")
		size = get(description,"size")
		points = math:round(size/PANGO_UNIT)
		variant = get(description,"variant")
		style = get(description,"style")
		weight = get(description,"weight")        
	end if
	
	hide(dlg) -- we keep it around, since it's likely to be used again :p 

return name
end function
export constant select = call_back(routine_id("Select"))

------------------------------------------------------------------------                 
export function FilterFonts(object family, object face, object data) 
------------------------------------------------------------------------
integer result = 0

if mono_filter then
        if gtk_func("pango_font_family_is_monospace",{P},{family})  = FALSE then
                return 0
        end if
end if

object name = lower(gtk_str_func("pango_font_family_get_name",{P},{family}))
	for i = 1 to length(pattern) do
		result = is_match(pattern[i],name) > 0 
		if result = 1 then
			for x = 1 to length(exclude) do
				if is_match(exclude[x],name) then
					return 0
				end if
			end for
		end if
		return result
	end for
return result
end function
export constant filter = call_back(routine_id("FilterFonts"))

/* -- for reference;
	weight_names = 
	"thin","ultralight","light","book","normal","medium",
	"semibold","bold","ultrabold","heavy","ultraheavy"

	PANGO_WEIGHT_THIN		= 100,
	PANGO_WEIGHT_ULTRALIGHT = 200,
	PANGO_WEIGHT_LIGHT		= 300,
	PANGO_WEIGHT_BOOK		= 380,
	PANGO_WEIGHT_NORMAL		= 400,
	PANGO_WEIGHT_MEDIUM		= 500,
	PANGO_WEIGHT_SEMIBOLD   = 600,
	PANGO_WEIGHT_BOLD		= 700,
	PANGO_WEIGHT_ULTRABOLD	= 800,
	PANGO_WEIGHT_HEAVY		= 900,
	PANGO_WEIGHT_ULTRAHEAVY = 1000,
	PANGO_UNIT				= 1024

	PANGO_STYLE_NORMAL	= 0,
	PANGO_STYLE_OBLIQUE	= 1,
	PANGO_STYLE_ITALIC	= 2
*/

-------------------------------------
-- copyright 2005-2019 by Irv Mullins
-------------------------------------
