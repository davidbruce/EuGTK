
-------------------------
namespace fileselector -- Generic file selection dialog;
-------------------------

include std/wildcard.e

export constant version = "4.15.0"

/*
 * -- FUNCTIONS:
 *    fileselector:New()
 *    fileselector:Open()
 *    fileselector:Save()
 *    fileselector:SaveAs()
 *    fileselector:CreateFolder()
 *    fileselector:SelectFolder()
 *
*/
 
export boolean -- change these before calling the dialog if required;
	create_folders = TRUE,
	local_only = TRUE,
	select_multiple = FALSE,
	show_hidden = FALSE,
	do_overwrite_confirmation = TRUE,
	show_preview = FALSE,
	use_preview_label = FALSE
	
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

if not equal(version,gtk:version) then
	Error(,,"GtkFileSelector version mismatch","should be version " & gtk:version)
end if

export atom preview_size = 200  -- default size 
export object filters = {"euphoria","text"}	

--------------------------------------
function generate_filter(object name)
--------------------------------------
object filter = 0

	switch name do
	
	case "images" then filter = create(GtkFileFilter,{
		{"name","Images"},{"add mime type","image/*"}})
	
	case "png" then filter = create(GtkFileFilter,{
		{"name","png"},{"add mime type","image/png"}})
		
	case "jpg","jpeg" then filter = create(GtkFileFilter,{
		{"name","jpeg"},{"add mime type","image/jpeg"}})
	
	case "gif" then filter = create(GtkFileFilter,{
	    {"name","gif"},{"add mime type","image/gif"}})
	
	case "bmp" then filter = create(GtkFileFilter,{
	    {"name","bmp"},{"add mime type","image/bmp"}})
	        
	case "svg" then filter = create(GtkFileFilter,{
		{"name","svg"},{"add mime type","image/svg+xml"}})
	
	case "xpm" then filter = create(GtkFileFilter,{
	    {"name","xpm"},{"add mime type","image/x-xpixmap"}})
	    	
	case "euphoria",".eu" then filter = create(GtkFileFilter,{
		{"name","Euphoria files"},
		{"add pattern","*.e"}, 
		{"add pattern","*.ex"},
		{"add pattern","*.exw"},
		{"add pattern","*.cfg"}})
	
	case "text",".text",".txt" then filter = create(GtkFileFilter,{
		{"name","All text"},{"add mime type","text/plain"}})
		
	case "c",".c",".h" then filter = create(GtkFileFilter,{
		{"name","C source code"},{"add mime type","text/x-c"},
		{"add pattern","*.c"},{"add pattern","*.h"}})
		
	case "c++" then filter = create(GtkFileFilter,{
		{"name","C++ source code"},{"add pattern","*.c++"}})
		
	case "css",".css" then filter = create(GtkFileFilter,{
		{"name","css markup"},{"add mime type","text/css"},
		{"add pattern","*.css"}})
		
	case "python",".python",".py" then filter = create(GtkFileFilter,{
		{"name","Python"},{"add mime type","text/x-python"}})
		
	case "html",".htm",".html" then filter = create(GtkFileFilter,{
		{"name","html source"},{"add mime type","text/html"},
		{"add pattern","*.html"}})
		
	case "ini",".ini" then filter = create(GtkFileFilter,{ 
		{"name","ini"},{"add pattern","*.ini"}})
		
	case "data",".data" then filter = create(GtkFileFilter,{
		{"name","data"},{"add pattern","*.data"}})
		
	case "all" then filter = create(GtkFileFilter,{
		{"name","All files"},{"add pattern","*"}})
		
	case "dir" then filter = create(GtkFileFilter,{
		{"name","Directories"},{"add mime type","inode/directory"}}) 
		  
	end switch
	
return filter

end function
   
constant update_preview = call_back(routine_id("UpdatePreview"))

-- note: the junk param is added so that these functions can
-- be called in various ways other than a standard function call
-- don't let it concern you.

----------------------------------------------------------
export function New(object current=0, object junk=0)
----------------------------------------------------------
object result=0
atom dlg = create(GtkFileChooserDialog)

set(dlg,{
	{"name","FileNew"},
	{"title","Create a new file"},
	{"action",GTK_FILE_CHOOSER_ACTION_SAVE}, 
	{"add button","gtk-cancel",MB_CANCEL},
	{"add button","gtk-ok",MB_OK},
	{"create folders",create_folders},
	{"local only",local_only},
	{"select multiple",select_multiple},
	{"show hidden",show_hidden},
	{"do overwrite confirmation",do_overwrite_confirmation}})
		
	for i = 1 to length(filters) do
		set(dlg,"add filter",generate_filter(filters[i]))
	end for
	
	if show_preview = TRUE then
		atom preview = create(GtkImage)
		set(dlg,"preview widget",preview)
		connect(dlg,"update-preview",update_preview,preview) 
	end if
	
	if string(current) then 
		set(dlg,"current name",current)
	end if

	result = get(dlg,"run")
	if result = MB_OK then
		result = get(dlg,"filename")
	end if

destroy(dlg)

return result
end function
export constant new = call_back(routine_id("New"))

object custom_filter = 0
----------------------------------------
function FF(object info, object data) -- filters files to match a pattern;
----------------------------------------
if custom_filter = 0 then return 1 end if
object pattern = "*" & peek_string(data) & ".*"
info = peek8u({info,8})
info = peek_string(info[4])
return wildcard:is_match(pattern,info)
end function

----------------------------------------------------
export function Open(object data=0, object junk=0)
----------------------------------------------------
object result=0
object filter=0, filter_list = {}
custom_filter = 0 -- reset just in case;

if atom(data) and data > 0 then data = unpack(data) end if

atom dlg = create(GtkFileChooserDialog)

set(dlg,{
	{"name","FileOpen"},
	{"title","Open a file"},
	{"action",GTK_FILE_CHOOSER_ACTION_OPEN},
	{"add button","gtk-cancel",MB_CANCEL},
	{"add button","gtk-ok",MB_OK},
	{"create folders",create_folders},
	{"local only",local_only},
	{"select multiple",select_multiple},
	{"show hidden",show_hidden},
	{"use_preview_label",use_preview_label},
	{"do overwrite confirmation",do_overwrite_confirmation}})
		
	for i = 1 to length(filters) do
		filter = generate_filter(filters[i])
		set(dlg,"add filter",filter)
		filter_list = append(filter_list,filter)
	end for
		
	if show_preview = TRUE then
		atom preview = create(GtkImage)
		set(dlg,"preview widget",preview)
		connect(dlg,"update-preview",update_preview,preview) 
	end if

	if string(data) then -- was specified exactly;
		if file_exists(canonical_path(data)) then
			set(dlg,"filename",canonical_path(data))
		
		else
		    custom_filter = create(GtkFileFilter)
		    set(custom_filter,"name",data) 
		    set(custom_filter,"add pattern",data)
		    set(custom_filter,"add custom",0,call_back(routine_id("FF")),allocate_string(data))
			set(dlg,"add filter",custom_filter)
			set(dlg,"filter",custom_filter) -- select it;
		end if
	end if
	
	result = get(dlg,"run") -- ! 
	
	if result = MB_OK then
		if select_multiple then result = get(dlg,"filenames") 
		else result = get(dlg,"filename")
		end if
	end if
	
	for i = length(filter_list) to 1 by -1 do
		destroy(filter_list[i])
	end for

	destroy(dlg)

return result
end function
export constant open = call_back(routine_id("Open"))

----------------------------------------------------
export function Save(object data, object junk=0)
----------------------------------------------------
object result=0
atom dlg = create(GtkFileChooserDialog)
atom f

set(dlg,{
	{"name","FileSave"},
	{"title","Save this file"},
	{"action",GTK_FILE_CHOOSER_ACTION_SAVE},
	{"add button","gtk-cancel",MB_CANCEL},
	{"add button","gtk-ok",MB_OK},
	{"create folders",create_folders},
	{"local only",local_only},
	{"select multiple",select_multiple},
	{"show hidden",show_hidden},
	{"do overwrite confirmation",do_overwrite_confirmation}})
	
	for i = 1 to length(filters) do
		set(dlg,"add filter",generate_filter(filters[i]))
	end for

	if show_preview = TRUE then
		atom preview = create(GtkImage)
		set(dlg,"preview widget",preview)
		connect(dlg,"update-preview",update_preview,preview) 
	end if

	if atom(data) and data > 0 then
		set(dlg,"current name",unpack(data))
	end if

	if string(data) then
		set(dlg,"current name",data)
	end if

	result = get(dlg,"run")

	if result = MB_OK then
		result = get(dlg,"filename")
	end if

destroy(dlg)

return result
end function
export constant save = call_back(routine_id("Save"))

-----------------------------------------------------------
export function SaveAs(object data=0, object junk=0)
-----------------------------------------------------------
object result=0
atom dlg = create(GtkFileChooserDialog)

set(dlg,{
	{"name=FileSaveAs"},
	{"title","Save this file with a new name"},
	{"action",GTK_FILE_CHOOSER_ACTION_SAVE},
	{"add button","gtk-cancel",MB_CANCEL},
	{"add button","gtk-ok",MB_OK},
	{"create folders",create_folders},
	{"local only",local_only},
	{"select multiple",select_multiple},
	{"show hidden",show_hidden},
	{"do overwrite confirmation",do_overwrite_confirmation}})
	
	for i = 1 to length(filters) do
		set(dlg,"add filter",generate_filter(filters[i]))
	end for
	
	if show_preview = TRUE then
		atom preview = create(GtkImage)
		set(dlg,"preview widget",preview)
		connect(dlg,"update-preview",update_preview,preview) 
	end if

	if atom(data) and data > 0 then 
		set(dlg,"current name",unpack(data))
	elsif string(data) then
		set(dlg,"current name",data)
	end if

	result = get(dlg,"run")

	if result = MB_OK then
		result = get(dlg,"filename")
	end if

	destroy(dlg)

return result
end function
export constant save_as = call_back(routine_id("SaveAs"))

---------------------------------------------------------------
export function CreateFolder(object data=0, object junk=0)
---------------------------------------------------------------
object result=0
atom dlg = create(GtkFileChooserDialog)

set(dlg,{
	{"name=NewFolder"},
	{"title","Create a new folder"},
	{"action",GTK_FILE_CHOOSER_ACTION_CREATE_FOLDER},
	{"add button","gtk-cancel",MB_CANCEL},
	{"add button","gtk-ok",MB_OK},
	{"create folders",create_folders},
	{"local only",local_only},
	{"select multiple",select_multiple},
	{"show hidden",show_hidden},
	{"do overwrite confirmation",do_overwrite_confirmation}})
	
	for i = 1 to length(filters) do
		set(dlg,"add filter",generate_filter(filters[i]))
	end for
		
	if show_preview = TRUE then
		atom preview = create(GtkImage)
		set(dlg,"preview widget",preview)
		connect(dlg,"update-preview",update_preview,preview) 
	end if

	if string(data) then
		set(dlg,"current name",data)
	end if

	result = get(dlg,"run")

	if result = MB_OK then
		result = get(dlg,"filename")
	end if

destroy(dlg)

return result
end function
export constant create_folder = call_back(routine_id("CreateFolder"))

---------------------------------------------------------------
export function SelectFolder(object data=0, object junk=0)
---------------------------------------------------------------
object result=0
atom dlg = create(GtkFileChooserDialog)

set(dlg,{
	{"name","SelectFolder"},
	{"title","Select a folder"},
	{"action",GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER},
	{"add button","gtk-cancel",MB_CANCEL},
	{"add button","gtk-ok",MB_OK},
	{"create folders",create_folders},
	{"local only",local_only},
	{"select multiple",select_multiple},
	{"show hidden",show_hidden},
	{"do overwrite confirmation",do_overwrite_confirmation}})

	for i = 1 to length(filters) do
		set(dlg,"add filter",generate_filter(filters[i]))
	end for
	
	if show_preview = TRUE then
		atom preview = create(GtkImage)
		set(dlg,"preview widget",preview)
		connect(dlg,"update-preview",update_preview,preview) 
	end if

	if atom(data) and data > 0 then
		data = unpack(data)
		if string(data) then
			if file_exists(canonical_path(data)) then
				set(dlg,"filename",canonical_path(data))
			else
				set(dlg,"filename",data)
			end if
		end if
	end if

result = get(dlg,"run")

if result = MB_OK then
	result = get(dlg,"filename")
end if

destroy(dlg)

return result
end function
export constant select_folder = call_back(routine_id("SelectFolder"))

-----------------------------------------------------------------------
function UpdatePreview(atom dlg, atom preview) -- follow focus changes;
-----------------------------------------------------------------------
object pix 
atom ratio
object dimensions 
object fn = get(dlg,"filename")  

if string(fn) then -- avoid trying to preview a directory!
	pix = create(GdkPixbuf,fn)  
	if pix > 0 then
		dimensions = get(pix,"size")
		ratio = preview_size / dimensions[1]  
		dimensions *= {ratio,ratio}
		pix = get(pix,"scale simple",dimensions[1],dimensions[2],1)
		set(preview,"from pixbuf",pix)
	end if
end if

return 0
end function

-------------------------------------
-- copyright 2005-2019 by Irv Mullins
-------------------------------------
