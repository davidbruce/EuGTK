
---------------------
namespace settings -- functions to read and write config files (eg: *.ini);
---------------------

export constant version = "4.15.0"

/*
 * -- FUNCTIONS:
 *    settings:Save({list}) -- saves default values for items in {list}
 *    settings:Load(ini)    -- retrieves and restores values saved previously
 *    settings:Set() 	    -- add a non-default item name/value pair;
 *    settings:Get() 	    -- retrieve a non-default value for name.
 *    settings:Delete() 	-- remove an item from the ini
 *    
 * -- DEBUG COMMAND: 
 *    -d SETTINGS
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

include std/io.e
include GtkEngine.e

if not equal(version,gtk:version) then
    Error(,,"GtkSettings version mismatch","should be version " & gtk:version)
end if

constant fmt = """[].[]=[]""" -- format for the ini line;

------------------------------------------------------------------------
export function Save(sequence inifile, object ctl_list, integer debug=0)
------------------------------------------------------------------------
-- writes an 'ini' type file (file name and extension are up to you)
-- with an entry for each control on ctl_list. The controls MUST have 
-- been named, otherwise there's no way to save and retrieve the 
-- value/setting for that control.
------------------------------------------------------------------------
object comments = {}
object txt,line
atom fn = -1

inifile = locate_file(canonical_path(inifile))
ifdef SETTINGS then display("Saving to []",{inifile}) end ifdef

if file_exists(inifile) then
   fn = open(inifile,"r",0)
   
   ifdef SETTINGS then puts(1,"\n") end ifdef
     
   txt = read_lines(fn)
   for i = 1 to length(txt) do -- extract the comments;
	line = txt[i] 
	if match("--",line) = 1 -- comment - keep;
	or match("!",line) = 1 -- override setting (ignore changes)
	or match("+",line) = 1
	or equal("\n",line)
	or equal({},line) -- empty
	then -- removing everything but the comments;
		comments = append(comments,line)
	end if
   end for 
   close(fn)
   
   fn = open(inifile,"w",0)
   if write_lines(fn,comments) = -1 then
      Error(,,"GtkSettings Save",
	      sprintf("Failed to write to ini: <b>%s</b>",{inifile})) 
   end if
   flush(fn)
   close(fn)
    
end if -- file exists

object setting, tmp = 0, pos = {0,0}
object t1, name, prop
atom handle
integer class, width=0, height=0
integer fx,lc = length(comments)

fx = open(inifile,"a")
if fx = -1 then 
	Error(,,"SaveSettings Failed",sprintf("Cannot open %s",{inifile})) 
end if

if debug > 0 then display("\n* Saving []\n",{inifile}) 
	for i = 1 to lc do display("LINE: []:[]",{i,comments[i]}) end for
end if

for x = 1 to length(ctl_list) do 

	if string(ctl_list[x]) then 
		handle = pointer(ctl_list[x]) 
	else 
		handle = ctl_list[x] 
	end if
	
	name = get(handle,"name")
	class = class_id(handle)

	if class=GtkWindow then -- a window has 2 obvious 'saveable' properties;
	        {width,height} = get(handle,"size")
	        pos = get(handle,"position")
	        printf(fx,"%s.size={%d,%d}\n",{name,width,height})
	        printf(fx,"%s.position={%d,%d}\n",{name,pos[1],pos[2]})

	else
		setting = get_setting(handle) -- others have 1 obvious 'saveable' property
		if length(setting) > 0 then
		   ifdef SETTINGS then
		      display("settings:Save: []",{setting})
		   end ifdef   
		   printf(fx,"%s\n",{setting})
		end if
	end if
end for

flush(fx)
close(fx)

tmp = read_lines(inifile)
for i = 1 to length(tmp) do 
   if match("--!",tmp[i]) = 1 then --keep the override;
	t1 = split(tmp[i],"=")
	t1 = t1[1][2..$]
   end if
end for

write_lines(inifile,tmp)

object z
integer a1,b1
if debug > 0 then 
  display("\n* Verifying [] ",{inifile},0)
  z = read_lines(inifile) a1 = length(flatten(z))
  b1 = length(flatten(tmp)) 
  ifdef SETTINGS then display("[] []",{a1,b1}) end ifdef
  if a1 != b1 then Error(,,"GtkSettings Save",
     sprintf("File compare Failed when reading <b>%s</b>",{inifile}))
  end if
  ifdef SETTINGS then 
	for i = 1 to length(z) do
	display("  []:[]",{i,z[i]})
	end for
  end ifdef
end if

return 1
end function

------------------------------------------------------------------------
export function Load(sequence inifile, integer debug=0) -- 1 = debug;
------------------------------------------------------------------------
-- used to restore settings from the specified ini file.

object txt, line, obj, prop, val1=0, val2=0, val3=0, val4=0

inifile = canonical_path(locate_file(inifile))

if not(file_exists(inifile)) then -- create a new one;
	write_file(inifile,sprintf("--%s\n\n",{inifile}),TEXT_MODE)
	display("* Creating ini file: []",{inifile})
end if

if debug then
	display("* Reading []\n",{inifile}) 
end if

txt = read_lines(inifile)
if atom(txt) then -- read failed!
	Warn(,,"GtkSettings",sprintf("Failed to read %s",{inifile}))
	write_file(inifile,sprintf("--%s\n\n",{inifile}),TEXT_MODE)
	display("* Created ini file:  []",{inifile})
	return 0
end if

integer err=0
object a,b

for i = 1 to length(txt) do

	line = txt[i]
	
	if match("--",line) > 2 then -- strip trailing comments;
		line = line[1..match("--",line)-2]
	end if
	
	if match("--!",line) = 1 then
		line = line[4..$] -- keep it
		line = trim_head(line)
		ifdef SETTINGS then display("LINE1:[]",{line}) end ifdef
	end if
	
	if match("+",line) = 1 then -- non-default property or key/value;
		line = line[2..$] 
		line = split(line,'=')
		line[1] = split(line[1],'.')
		line[1][1] = trim(line[1][1])
		line[2] = trim(line[2])
		line[1][2] = trim(line[1][2]) 
		gtk:set(line[1][1],line[1][2],line[2])
		gtk:set(line[1][1],"data",line[1][2],line[2])
		continue
	end if
	
	if match("--",line)=1 then continue end if -- a comment;
    if not match("=",line) then continue end if -- line is blank;
    
	if length(line) > 0  then 
		line = split(line,'=') 
		a = trim(line[1]) b = trim(line[2])
		a = split(a,'.') 
		line = a & {b}
		ifdef SETTINGS then display("A:[] B:[]",{a,b}) end ifdef
		if vlookup(line[1],registry,4,1,-1) = -1 then
			err = i
			Error(,"Ini Load Error",
				sprintf("Invalid object name: %s",{line[1]}),
				sprintf("Line #%d of %s",{i,filename(inifile)}))
		else
			--display("SET:[].[]=[]",line)
			set(line[1],line[2],line[3])

		end if
	end if
end for

if debug = 1 then
 for i = 1 to length(txt) do
	if i = err then
		display("* ERROR:[:3]:[]",{i,txt[i]})
	else
		display("[:3]:[]",{i,txt[i]})
	end if
 end for
 puts(1,"\n")
end if

return 1
end function

----------------------------------------------
export function Get(object name, object data)
----------------------------------------------
object x = gtk:get(name,"data",data) 
if atom(x) and x > 0 then x = peek_string(x) end if
ifdef SETTINGS then display("settings:Get: [].[] => []",{name,data,x}) end ifdef
return x
end function

-------------------------------------------------------------------------------------------
export function Set(object ini,object ctl, sequence prop, object v1=0, object v2=0)
-------------------------------------------------------------------------------------------
if atom(ctl) then ctl = get(ctl,"name") end if
if not string(ctl) then return Error(,"settings:Set","Object must be named",prop) end if

ini = canonical_path(locate_file(ini))
Delete(ini,ctl,prop)

if equal("position",prop) or equal("size",prop) then
if string(v1) then v2 = v1[2] v1 = v1[1] end if
end if

if atom(v2) and v2=0 then
	writefln("+[].[]=[]",{ctl,prop,v1},{ini,"a"})
	ifdef SETTINGS then 
		display("settings:Set: [].[]=[]",
		 {ctl,prop,v1}) 
	end ifdef
else 
	writefln("+[].[]={[],[]}",
		{ctl,prop,v1,v2},{ini,"a"})
	ifdef SETTINGS then 
		display("settings:Set: +[].[]={[],[]}",
		 {ctl,prop,v1,v2}) 
	end ifdef
end if

return 1
end function	

--------------------------------------------------------------------
export function Delete(object ini,object ctl, sequence prop)
--------------------------------------------------------------------
if atom(ctl) then ctl = get(ctl,"name") end if
object tmp = read_lines(ini) 
object out = {}
atom f
object s1 = text:format("[].[]",{ctl,prop})

if sequence(tmp) then
for i = 1 to length(tmp) do
	if match(s1,tmp[i]) then -- skip
	else out &= {tmp[i]}
	end if
end for
end if

f = open(ini,"w")
for i = 1 to length(out)  do
   puts(f,out[i] & "\n")
end for
flush(f)
close(f)

return 1
end function

---------------------------------------------------------------------------------
function get_setting(object self, object property = 0) 
-- returns the 'important' value from a control
---------------------------------------------------------------------------------
object name = 0
object dt

if string(self) then 
	self = vlookup(self,registry,4,1) 
end if

object val = 0
object txt = {}
integer width, height, pos

integer x = find(self,vslice(registry,1))
	
	switch class_id(self) do 
	
	-- This decides which control property is important to save
	-- and stores the control's current value into the registry
	-- obviously, only the most important (and most likely to be changed by the user)
	-- are implemented. Others can be added in your program if needed.	
			
		case GtkEntry,GtkEntryBuffer,GtkTextBuffer then property = "text"

		case GtkCheckButton, GtkRadioButton, GtkToggleButton,
			GtkSwitch, GtkComboBox, GtkComboBoxText, 
			GtkMenu, GtkMenuButton, GtkCheckMenuItem, 
			GtkToggleToolButton, GtkSearchEntry
			then property = "active"

		case GtkPopover then property = "position"

		case GtkFontButton then property = "font name"

		case GtkAdjustment, GtkSpinButton, GtkScaleButton, 
			GtkVolumeButton,GtkModelButton, GtkScale 
			then property = "value"

		case GtkEntryCompletion then property = "model"

		case GtkLinkButton then property = "uri"

		case GtkMenuItem then property = "sensitive"
		
		case GtkExpander then property = "expanded"
		
		case GtkNotebook then property = "page"
			
		case GtkPaned then property = "position"
		
		case GtkStack then property = "visible-child-name"
		
		case GtkSearchBar then property = "search-mode"
		
		case GtkRevealer then property = "transition-type" 
		
		case GtkAspectFrame then property = "ratio"
		
		case GtkLabel then property = "text"
		
		case GtkSpinner then property = "active"
		
		case GtkProgressBar then property = "fraction"
		
		case GtkLevelBar then property = "value"
		
		case GtkTreeViewColumn then property = "fixed-width"
		
		case GtkFileChooser, GtkFileChooserButton, GtkFileChooserWidget, GtkFileChooserDialog
			then property = "filename"
			
		case GtkFontChooser, GtkFontChooserWidget, GtkFontChooserDialog then
			property = "font"
		
		-- special handling is required to format i/o for these controls:
		
		case GtkCalendar then 
			dt = get(self,"datetime",0)
			registry[x][5] = {"date",dt[1..3]}
			txt &= text:format(fmt,{registry[x][4],"date",dt[1..3]})
			return txt

		case GtkColorButton, GtkColorChooser, GtkColorChooserWidget, GtkColorChooserDialog then
			registry[x][5] = {"rgba",get(self,"rgba",1)}
			txt &= text:format(fmt,{registry[x][4],"rgba",get(self,"rgba",1)})
			return txt
		
	end switch
	
	if atom(property) then
	        return txt
	end if
	
	val = get(self,property) 
	registry[x][5] = {property,val}
	txt &= text:format(fmt,{registry[x][4],property,val})
	
	ifdef SETTINGS_SAVE then 
		display("settings:Save: [].[] => []",
		 {registry[x][4],property,val}) 
	end ifdef
	
return txt
end function

-------------------------------------
-- copyright 2005-2019 by Irv Mullins
-------------------------------------
