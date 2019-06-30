
----------------
namespace gtk -- main gtk engine;
----------------

with define GTK3

constant linux_library_path = "libgtk-3.so.0"
constant windows_library_path = "C:/Program Files/GTK3-Runtime Win64/bin/"
constant osx_library_path = "/opt/local/lib/libgtk-3.dylib"

export constant 
	version = "4.15.0", 
	release = "Apr 1, 2019",
	copyright = " © 2005-2019 by Irv Mullins"

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

object libpath  =  windows_library_path -- libpath used only by Windows;

object gtklibs 

ifdef OSX then 
	gtklibs = osx_library_path 
end ifdef

ifdef UNIX then 
	gtklibs = linux_library_path
end ifdef

setenv("NO_AT_BRIDGE","1") -- needed for some distros (e.g. Raspbian);

-- Following button, font, and menu overrides provided so that you have more
-- control over the appearance than GTK wants to give you. To override,     
-- set these from your program *after* including GtkEngine.e. 
              
-- these settings affect ALL buttons in your program!:
   public integer BTN_ICON_SIZE = 20 -- pixels;
   public object  BTN_TEXT_FONT = 0 -- e.g. "Courier New" 0 = users pref, from desktop
   public integer BTN_TEXT_SIZE = 0 -- points, 0 = users pref from desktop settings
   public integer BTN_SHOW_IMGS = 1 
	-- 0 respects user's Preferences/Desktop Settings,
	-- 1 disregards GTK prefs, shows image regardless.
	 
   public integer multi_tasking = 0 -- 1 if needed to load large list-view data sets
   
-- for menus:
   public object  ACCEL_FONT = "italic 10" -- affects accels in menus;
   public integer MENU_SHOW_IMG = 0 -- 0 respects user's Preferences/Desktop Settings, 1 disregards; 

public include GtkEnums.e 

-- GtkEnums includes most of Eu std libraries as public,
-- making them available to your eu programs without    
-- having to specifically include them.                 

if not equal(version,enums:version) then -- these 2 must be in sync!
	crash("Version mismatch: GtkEnums should be version %s",{version})
end if

-- std/math, std/datetime, etc. aren't made public,
-- because that would cause too many conflicts,                
-- requiring you to use namespaces everywhere,                 
-- but GtkEngine.e requires them locally;                                

include std/os.e
include std/io.e
include std/types.e
include std/datetime.e 
include std/math.e	
include std/net/dns.e 
include std/net/http.e

public constant -- 'shorthand' identifiers to save space in method prototypes;
	P = C_POINTER,  -- any valid pointer 
	B = C_BYTE,     -- 8 bits (boolean)
	I = C_INT,      -- 32 (integer)
	S = E_ATOM,     -- 64 (string) 
	D = C_DOUBLE,   -- 64 (double)
	F = C_FLOAT,    -- 32 (float)
	A = E_INTEGER,  -- 32/64 (glist ptr)
	X = E_OBJECT,   -- 32/64 (array of pointers)
	V = E_SEQUENCE  -- 32/64 (pointer to array of strings)

-- hopefully, the above are compatible with both 32 and 64-bit architectures

global object LIBS -- a single lib in OSX,UNIX, a sequence of dll's for Windows;

ifdef OSX then -- thanks to Pete Eberlein for testing with OSX!
	LIBS =  {open_dll(gtklibs)}
	if equal({0},LIBS) then 
	crash("""
	******************************
	** No libgtk-3.dylib found! **
	******************************""")
	end if
	
elsifdef UNIX then -- Linux, BSD, etc.
	LIBS = {open_dll(gtklibs)}
	if equal({0},LIBS) then 
	crash("""
	*****************************
	** No libgtk-3.so.0 found! **
	*****************************""")
	end if
	
elsifdef WINDOWS then -- everything is harder with Windows;

	LIBS = dir(libpath & "*.dll") -- get a list of all .dll's in that folder;

	if atom(LIBS) and LIBS = -1 then -- none found;
	crash("""
	****************************************
	** Cannot find GTK runtime libraries! **
	****************************************""")
	end if

	LIBS = vslice(LIBS,1) -- retain only the filenames;
	
	atom x

	for i = 1 to length(LIBS) do -- load each;
		x = open_dll(LIBS[i]) 
		if x = 0 then
		  ifdef DEBUG then
			display("Error loading []",{LIBS[i]})
		  end ifdef
		else
			LIBS[i] = x -- append this lib to list of libs;
		end if
	end for

end ifdef -- PLATFORMS;

if not object(LIBS) then -- no point in continuing;
	crash("""
	***********************************
	** Required libraries not found! **
	***********************************""")
end if

export constant cmd = pad_tail(command_line(),5,"") -- arbitrary limit;

object params = {0,0}

ifdef GTK4 then params = {} end ifdef -- none required

atom success = gtk_func("gtk_init_check",{P,P},params) -- initialize GTK;

if success then
	gtk_proc("g_set_prgname",{S}," " & filename(cmd[2])) -- set default pgm name;
	gtk_proc("g_type_init",{}) -- initialize normal GTK types;
else
	crash("""
	**************************************
	** Could not initialize GTK engine! **
	**************************************""")
end if

public constant -- two special types must be initialized at run-time, don't know why!   
	gPIX = gtk_func("gdk_pixbuf_get_type"),
	gCOMBO = gtk_func("gtk_combo_box_get_type")

	storage_types = append(storage_types,{gPIX,"gPIX"})
	storage_types = append(storage_types,{gCOMBO,"gCOMBO"})
	
------------------------------------------------
-- Obtain a lot of sometimes useful system info;
------------------------------------------------
include euphoria/info.e

constant os_info = os:uname()

export object 
	major_version = gtk_func("gtk_get_major_version"),
	minor_version = gtk_func("gtk_get_minor_version"),
	micro_version = gtk_func("gtk_get_micro_version"),
	lib_version = sprintf("%d.%d.%d",{major_version,minor_version,micro_version}),
	user_name = gtk_str_func("g_get_user_name"),
	real_name = gtk_str_func("g_get_real_name"),
	init_dir = init_curdir(),
	curr_dir = gtk_str_func("g_get_current_dir"),
	home_dir = gtk_str_func("g_get_home_dir"),
	prog_dir = pathname(cmd[2]),
	temp_dir = gtk_str_func("g_get_tmp_dir"),
	data_dir = gtk_str_func("g_get_user_data_dir"),
	conf_dir = gtk_str_func("g_get_user_config_dir"),
	runt_dir = gtk_str_func("g_get_user_runtime_dir"),
	app_name = gtk_str_func("g_get_application_name"),
	prg_name = gtk_str_func("g_get_prgname"),
	def_lang = gtk_func("gtk_get_default_language"),
	usr_lang = gtk_str_func("pango_language_to_string",{P},{def_lang}),
	os_pid = os:get_pid(),   -- process id: e.g:1234
	os_name = os_info[1],	 -- e.g: Linux
	os_distro = os_info[2],  -- e.g: Mint17
	os_version = os_info[3], -- e.g: 3.13.0-24-generic
	os_compiled = os_info[4],-- date, etc...
	os_arch = os_info[5],	 -- e.g: AMD64
	os_path = getenv("PATH"),
	os_shell = getenv("SHELL"),
	os_term = getenv("TERM"),
	eu_version = version_string_short(),
	eu_inc = getenv("EUINC"),
	eu_dir = getenv("EUDIR"), 
	eu_platform = platform_name(),
	host_name = gtk_str_func("g_get_host_name"),	
	host_addr = "unknown",
	inet_addr = "none",
    locale = gtk_str_func("setlocale",{P,P},{0,0}),
	codeset = gtk_str_func("g_get_codeset"),
	desktop_dir = gtk_str_func("g_get_user_special_dir",{I},{0}),
	documents_dir = gtk_str_func("g_get_user_special_dir",{I},{1}),
	download_dir = gtk_str_func("g_get_user_special_dir",{I},{2}),
	music_dir = gtk_str_func("g_get_user_special_dir",{I},{3}),
	pictures_dir = gtk_str_func("g_get_user_special_dir",{I},{4}),
	public_share_dir = gtk_str_func("g_get_user_special_dir",{I},{5}),
	templates_dir = gtk_str_func("g_get_user_special_dir",{I},{6}),
	videos_dir = gtk_str_func("g_get_user_special_dir",{I},{7})

if atom(eu_inc) and eu_inc = -1 then eu_inc = "Unset" end if
if atom(eu_dir) and eu_dir = -1 then eu_dir = "Unset" end if

ifdef BITS64 then
	constant eu_arch_bits = "64"	
elsedef 
	constant eu_arch_bits = "32"
end ifdef

if atom(os_term) then os_term = "none" end if

ifdef WINDOWS then 	
	locale = gtk_str_func("g_win32_getlocale"),
	user_name = getenv("USERNAME")
	real_name = getenv("USERNAME")
	home_dir = getenv("HOMEPATH")
	temp_dir = getenv("TEMP")
	os_name = getenv("OS")
	os_term = getenv("SESSIONNAME")
	os_compiled = getenv("PROCESSOR_IDENTIFIER")
end ifdef

-- following added because Windows misbehaves in the ifdef above :(

if atom(os_term) then os_term = getenv("SESSIONNAME") end if
if atom(os_shell) then os_shell = getenv("ComSpec") end if
if atom(os_arch) then os_arch = getenv("PROCESSOR_ARCHITECTURE") end if

export object info = { -- above system info in key=value form, sometimes useful;
	"version="     & version,
	"release="     & release,
	"copyright="   & copyright,
	"major="       & sprintf("%d",major_version),
	"minor="       & sprintf("%d",minor_version),
	"micro="       & sprintf("%d",micro_version),
	"user_name="   & user_name,
	"real_name="   & real_name,
	"host_name="   & host_name,
	"host_addr="   & host_addr,
	"inet_addr="   & inet_addr,
	"home_dir="    & home_dir,
	"prog_dir="    & prog_dir,
	"temp_dir="    & temp_dir,
	"init_dir="	   & init_dir,
	"curr_dir="    & curr_dir,
	"data_dir="    & data_dir,
	"conf_dir="    & conf_dir,
	"runt_dir="    & runt_dir,
	"app_name="    & app_name,
	"prg_name="    & prg_name,
	"os_pid="      & to_string(os:get_pid()),
	"os_name="     & os_info[1],
	"os_distro="   & os_info[2],
	"os_vers="     & os_info[3],
	"os_comp="     & os_compiled,
	"os_arch="     & os_arch,
	"os_term="     & os_term,
	"os_shell="    & os_shell,
	"os_path="     & os_path,
	"lib_version=" & lib_version, -- gtk library version
	"eu_date="     & version_date(),
	"eu_version="  & version_string_short(),
	"eu_revision=" & to_string(version_revision()),
	"eu_platform=" & eu_platform,
	"eu_arch_bits="& eu_arch_bits,
	"eu_inc="      & eu_inc,  -- EUINC
	"eu_dir="      & eu_dir,  -- EUDIR	
	"usr_lang="    & usr_lang,
	"codeset="	   & codeset,
	"locale="      & locale,
	"desktop="	   & desktop_dir,
	"documents="   & documents_dir,
	"download="    & download_dir,
	"music="       & music_dir,
	"pictures="    & pictures_dir,
	"public_share="& public_share_dir,
	"templates="   & templates_dir,
	"videos="      & videos_dir,
	"CMD1="        & cmd[1], -- break up the command line options;
	"CMD2="        & cmd[2],
	"CMD3="        & cmd[3],
	"CMD4="        & cmd[4],
	"CMD5="        & cmd[5],
	$} 
	
public constant LGPL = read_file(locate_file("resources/license.txt"))

ifdef UNIX then
     host_addr = get_network_address()
     info[10] = "host_addr=" & host_addr
end ifdef

boolean traceme = TRUE

-------------------------
export function Beep() -- FIXME!
-------------------------
object dm = gtk_func("gdk_display_manager_get")
object dd = gtk_func("gdk_display_manager_get_default_display",{P},{dm})
gtk_proc("gdk_display_beep",{P},{dd})
return 1
end function

------------------------------
export function networked() -- LAN available?
------------------------------
ifdef WINDOWS then 
	return not equal(get_network_address(),"127.0.0.1")
end ifdef
atom m = gtk_func("g_network_monitor_get_default") 
return gtk_func("g_network_monitor_get_network_available",{P},{m})
end function

------------------------------------
export function get_network_address() -- e.g. 127.0.0.1 or 192.168.1.x
------------------------------------
object ipfile = canonical_path("~/my.ip") 

host_addr = "127.0.0.1"
integer x1 = 0, x2 = 0
object results = {"127.0.0.1"}

ifdef UNIX then
	if file_exists(ipfile) then delete_file(ipfile) end if
	system(sprintf("ifconfig > %s",{ipfile}))
	sleep(.25)
	object lines =  read_lines(ipfile)
	delete_file(ipfile)
	if not atom(lines) then
	for i = 1 to length(lines) do
	   if match("inet addr:",lines[i]) then
		x1 = match(":",lines[i])
		x2 = match(" ",lines[i][x1..$])
		x2 += x1
		if x1<x2 then
			results = add_item(trim(lines[i][x1+1..x2]),results,ADD_SORT_UP)
		end if
	   end if
	end for
       end if
	
	if length(results) > 1 then
		results = remove_all("127.0.0.1",results)
	end if

end ifdef

ifdef WINDOWS then -- FIXME!
	host_addr = "127.0.0.1"
end ifdef

return results[1]
end function

-----------------------------------------
export function get_external_address() -- "as seen on the www!"
-----------------------------------------
if not inet_connected() then return "no inet" end if
object results = http_get("http://icanhazip.com")
if atom(results) then 
	return "unknown"
else
	inet_addr = results[2]
	return inet_addr
end if
end function

-----------------------------------
export function inet_connected() -- FIXME!
-----------------------------------
atom err = allocate(8) err = 0 
if not networked() then return 0 end if
atom x = gtk_func("g_network_address_parse_uri",{P,I,P},
	{allocate_string("http://google.com"),80,err})
return x
end function

-------------------------------------------------------------
public procedure requires(sequence gtk_vers, object msg=0) -- ensure GTK widget is available;
-------------------------------------------------------------
object s = split(gtk_vers,'.') -- e.g. convert "3.20.0" to major, minor, micro
	if length(s) < 3 then s = append(s,"0") end if 
	s[1] = to_integer(s[1]) 
	s[2] = to_integer(s[2]) 
	s[3] = to_integer(s[3])

object msg2 = gtk_str_func("gtk_check_version",{I,I,I},{s[1],s[2],s[3]})
	if string(msg2) then
		if string(msg) then msg2 = msg & "\n" & msg2 end if
		Error(,"Fatal Error",msg2,
		text:format("Requires Gtk version []\nInstalled is Gtk [].[].[]",
		{gtk_vers,major_version,minor_version,micro_version}),GTK_BUTTONS_CLOSE,
		"dialog-info","dialog-error")
	abort(1)
	end if
end procedure

--------------------------------------------------------
public function uses(sequence helper, integer bail=1) -- ensure helper program is available;
--------------------------------------------------------
object loc = gtk_str_func("g_find_program_in_path",{P},{allocate_string(helper)})
if atom(loc) then
	if bail then -- show error message if 0 for second param is not supplied;
	   Warn("sec=Helper program not found!;btn=1;pri="&helper)
	end if
	return FALSE
end if
return loc -- returns the path to the helper program in case needed;
end function

boolean ERRHANDLER = 0

-------------------------------------
-- MAIN EuGTK FUNCTIONS BEGIN HERE --
-------------------------------------

enum NAME,PARAMS,RETVAL,VECTOR,CLASS

--------------------------------------------------------------------------------
public function create(integer class, -- class is one of the GtkWidget enums;
	object p1=0, object p2=0, object p3=0, object p4=0, -- p1 .. p8 are 
	object p5=0, object p6=0, object p7=0, object p8=0) -- optional params;
--------------------------------------------------------------------------------
-- This function does the following:
-- 1. initializes the class if not already initialized,
-- 2. creates a new instance of the class (returning a handle to that instance)
-- 3. optionally sets one or more properties 
-- 4. optionally connects one or more signals
---------------------------------------------------------------------------------

	if class = GtkStockList then -- GtkStock is not a real widget, but we fake it.
		return newStockList()    -- Also, stock items are deprecated as of 3.10+
	end if						 -- so don't get in the habit of using them too much :)

	if class = GtkColumn then return newColumn(p1) end if -- call a 'shorthand' method
	
	if not initialized[class] then -- create a routine_id for each 'method' in class
		init(class) -- but only do it if this is the first call to that class
	end if

	ifdef CREATE then
		display(widget[class])
	end ifdef
	
	object method = lookup("new",vslice(widget[class],1),widget[class],0)
	if method[VECTOR] = -1 then -- a 'new' method name was not found;
		Error(,,widget[class][$],"not implemented in this GTK version!")
		abort(class)
	end if

	object props = 0, dataitem = 0
	if sequence(p1) and sequence(p1[1]) then -- a {list} of properties was provided.
		props = p1 			 				 -- save until widget is created, 
		p1 = 0								 -- then set them in one 'swell foop'

	elsif string(p1) and match("=",p1) then  -- properties were provided in string form,
		props = keyvalues(p1,,,,"\r")    	 -- break them up into key/value pairs, 
		p1 = 0				 				 -- save for later;
		dataitem = vlookup("data",props,1,2)
	end if

	atom handle = 0
	object params = method[PARAMS]
	object args = {p1,p2,p3,p4,p5,p6,p7,p8} 

	args = args[1..length(params)] -- discard un-needed args;
	
	ifdef PARAMS then display(params) end ifdef -- debug;

	for i = 1 to length(params) do -- ensure values match formal params;

		switch params[i] do

			case S then -- convert string to pointer to cstring;
				if string(args[i]) then 
					args[i] = allocate_string(args[i]) 
				end if
			case B then -- convert "1", "TRUE", or "YES" to 1,
			if string(args[i]) then 
				if args[i] = "1" 
				or upper(args[i]) = "TRUE" 
				or upper(args[i]) = "YES" then 
					args[i] = 1
				else
					args[i] = 0 --  anything else is 0;
				end if
			end if
		end switch
	end for

	ifdef CREATE then -- debug;
		display(decode_method("CREATE",class,method)) 
		puts(1,"\tArgs: ") display(args,{2,5,10,78,"%d","%.2g",32,127,1,0})
		ifdef METHOD then display(method) end ifdef 
	end ifdef

	if method[RETVAL] > 0 then -- it's a GTK function (routine_id is positive);
		handle = c_func(method[VECTOR],args) -- call the func;
	end if

	if method[RETVAL] < -1 then -- it's a Eu func (a negated routine_id)
		handle = call_func(-method[VECTOR],args) -- convert to positive rid and call;
	end if

	if handle = 0 then -- failure :(
		ifdef CREATE then
			display("Create failed for class []",{widget[class][$]})
		end ifdef
		return handle
	end if

	object sig = 0, arg1 = 0 ,arg2 = 0

	switch class do -- connect a default signal for some common controls;
		case GtkButton then sig ="clicked" arg1 = p2 arg2 = p3
		case GtkToolButton then sig ="clicked" arg1 = p3 arg2 = p4
		case GtkRadioButton then sig ="toggled" arg1 = p3 arg2 = p4
		case GtkRadioToolButton then sig = "toggled" arg1 = p3 arg2 = p4
		case GtkRadioMenuItem then sig ="toggled" arg1 = p3 arg2 = p4
		case GtkMenuItem then sig ="activate" arg1 = p2 arg2 = p3
		case GtkCheckMenuItem then sig = "toggled" arg1 = p2 arg2 = p3
		case GtkCellRendererToggle then sig = "toggled" arg1 = p1 arg2 = p2
		case GtkFontButton then sig = "font-set" arg1 = p2 arg2 = p3
		case GtkStatusIcon then sig = "activate" arg1 = p1 arg2 = p2
		case GtkSwitch then sig = "notify::active" arg1 = p1 arg2 = p2
		case GtkColorButton then sig = "color-set" arg1 = p2 arg2 = p3
		case GtkCalendar then sig = "day-selected-double-click" arg1 = p2 arg2 = p3
		case GtkComboBoxText, GtkComboBoxEntry then sig ="changed" arg1 = p1 arg2 = p2
		case GtkCheckButton then sig ="toggled" arg1 = p2 arg2 = p3	
		case GtkToggleButton then sig ="toggled" arg1 = p2 arg2 = p3	
		case GtkToggleToolButton then sig ="toggled" arg1 = p2 arg2 = p3	
	end switch

	if atom(arg2) and arg2 = 0 then arg2 = dataitem end if
	connect(handle,sig,arg1,arg2) -- connect per above switch;

	ifdef CREATE then  -- debug;
		display("\t[] => []\n",{widget[class][$],handle}) 
	end ifdef

	register(handle,class)

	if class = GtkWindow then  -- if not otherwise specified, use OpenEu logo;
	atom err= allocate(8,1)	   -- as the default icon
		gtk_func("gtk_window_set_default_icon_from_file",{P,P},
			{allocate_string(locate_file("./thumbnails/mongoose.png"),1),err})
	end if

	-----------------------------------------------
	-- set properties using the new key/val style;
	-----------------------------------------------
	object p = 0, signal, name, v1, v2, v3, v4

	if not atom(props) then 

		if handle > 0 then

			for i = 1 to length(props) do
				props[i] = pad_tail(props[i],5,0)

				for n = 1 to 5 do
					props[i][n] = numeric_test(props[i][n])
				end for
			end for

			for i =  1 to length(props) do
			
				name = props[i][1] 
				v1 = props[i][2]
				v2 = props[i][3]
				v3 = props[i][4]
				v4 = props[i][5]

				if match("$",name) = 1 then
					signal = name[2..$]
					connect(handle,signal,v1,dataitem)
				elsif match("#",name) = 1 then
					set(handle,"data",name[2..$],v1)
				elsif equal("tip",name) = 1 then
					set(handle,"tooltip text",v1)
				else
					set(handle,name,v1,v2,v3,v4)
				end if
			end for
		end if
	end if
	
	return handle -- a pointer to the newly created instance

end function 

------------------------------------------------------------------------
public function set(object handle, object property, 
	object p1=0, object p2=0, object p3=0, object p4=0,
	object p5=0, object p6=0, object p7=0, object p8=0)
------------------------------------------------------------------------
-- This routine sets a property for the given widget handle.
-- Handle is normally an atom, but a widget name in string form
-- may be used provided the widget was named.
-- Property is always a string, p1...p8 are optional parameters.
-- Any parameter expected but not supplied is set to null,
-- excess parameters are discarded.
------------------------------------------------------------------------
integer class=-1
object name = "unknown"
object result = 0
object allocated = {}

	name = handle -- save for later use;
		
	if string(handle) then handle = pointer(handle) end if

	if sequence(handle) then
	    for i = 1 to length(handle) do
	          set(handle[i],property,p1,p2,p3,p4,p5,p6,p7,p8)  
	    end for
	    return 1
	end if
	
	if handle = 0 then 
		traceme = FALSE
		Error(,"Critical Error","Object unnamed or NULL",
			text:format("Invalid name/handle: [] ",{name}))
		crash("\nCritical Error\tObject unnamed or NULL! *%s* [%d]\n**************",
			{name,handle})
	end if

	object prop = 0

	if string(property) and match("=",property) > 0 then -- convert props
		property = keyvalues(property,,,,"\t\n")   -- to key/val form;
	end if

	if sequence(property) -- new create format (key=value pairs); 
	and not string(property) then
		for i = 1 to length(property) do
		   while length(property[i]) < 5 do
			   property[i] &= 0
		   end while
		   for n = 1 to 5 do
			property[i][n] = numeric_test(property[i][n])
		   end for
		end for
	
		for i = 1 to length(property) do
			prop = property[i] if prop[1][1]='$' then continue end if
			while length(prop) < 8 do prop &= 0 end while
			set(handle,prop[1],prop[2],prop[3],prop[4],prop[5],prop[6],prop[7],prop[8])
		end for
	return 0
	end if

	class = vlookup(handle,registry,1,2,-1) -- get widget's class;

	if class = -1 then -- fail;
		display("Set invalid handle [] []",{handle,prop})
	end if

	property = "set_" & lower(join(split(property,' '),'_')) -- conform;

	object method = lookup_method(class,property)
	ifdef METHOD then display(method) end ifdef

	if atom(method) then 
		if not set_property(handle,property[5..$],numeric_test(p1)) then
			Error(,,"Cannot set property",class_name(handle) & property)
		end if
		return 0
	end if

	if method[VECTOR] = -1 then
		Warn(,,"Method not found",
		sprintf("%s->%s",{class_name(handle),property})) 
		return 0 
	end if

	-- method was found;

		object params = method[PARAMS]

		switch method[1] do -- make life easier for a common operation;
			case "set_from_file" then p1 = canonical_path(p1)
		end switch

		object args = {handle,p1,p2,p3,p4,p5,p6,p7,p8}
		
		ifdef PARAMS then 
			puts(1,"Params: ") display(params)
			puts(1,"Args: ") display(args)
		end ifdef

		args = args[1..length(params)] -- match args to formal parameters;
		for i = 2 to length(args) do
			switch params[i] do

			case A then -- array of strings;
			if not atom(args[i]) then
				args[i] = allocate_string_pointer_array(args[i])
				allocated &= args[i]
			end if

			case S then -- string;
			if atom(args[i]) then
				args[i] = sprintf("%g",args[i])
			end if
			if string(args[i]) then 
				args[i] = allocate_string(args[i],0) 
				allocated &= args[i]
			end if

			case B then 
			if string(args[i]) then
				if equal("TRUE",upper(args[i]))
				or equal("YES",upper(args[i]))
				or equal("1",args[i]) then
					args[i] = 1
				end if
				if equal("FALSE",upper(args[i]))
				or equal("NO",upper(args[i]))
				or equal("0",args[i]) then
					args[i] = 0
				end if
			end if

			case I,D then 
			if string(args[i]) then
				args[i] = to_number(args[i])
			end if

		 -- apply patches for zero-based indexes;
			     switch method[1] do
				case "add_attribute",
				     "set_active",
				     "set_text_column",
				     "set_pixbuf_column",
				     "set_tooltip_column",
				     "set_search_column",
				     "attribute_connect",
				     "reorder_child",
				     "page",
				     "remove_page",
				     "set_current_page",
				     "set_sort_column_id" then args[i]-=1
			     end switch
			end switch
		end for

		ifdef SET then -- debug;
			if traceme then
			display(decode_method("SET",class,method))  
			puts(1,"\tArgs: ") 
			display(decode_args(method,args),
				{2,2,11,78,"%d","%2.22f",32,127,1,0})
			puts(1,"\n")
			end if
		end ifdef

	if equal("set_name",property) then
		p8 = find(handle,vslice(registry,1)) 
		registry[p8][4] = p1
	end if

	if method[RETVAL] = 0 then -- it's a GTK proc;
		c_proc(method[VECTOR],args)
	end if

	if method[RETVAL] > 0 then -- it's a GTK func;
		result = c_func(method[VECTOR],args)
	end if

	if method[RETVAL] <-1 then -- it's a Eu func;
		result = call_func(-method[VECTOR],args)
	end if

	if method[VECTOR] = -1 then -- GTK doesn't know about this method!
		printf(1,
		"Warning: %s->%s call is invalid," &
		"******** perhaps you need a later GTK version",
			{widget[class][$],property})
	end if

	if not equal("set_data",property) then
		for i = 1 to length(allocated) do
		free(allocated[i])
		end for
	end if

	return result

end function 

---------------------------------------------------------------------------
export function get(object handle, sequence property,
     object p1=MINF, object p2=MINF, object p3=MINF, 
	 object p4=MINF, object p5=MINF, object p6=MINF)
---------------------------------------------------------------------------
-- This routine gets one or more values for a given property name.
-- Property name is always a string, handle is usually an atom,
-- but may be a string if the widget was named. 
---------------------------------------------------------------------------
integer class
object name = "unknown"

	if string(handle) then 
		name = handle 
		handle = pointer(handle) 
	end if

	class = vlookup(handle,registry,1,2,-1) -- get widget's class;

	if class = -1 then
		return 0
	end if

	property = "get_" & lower(join(split(property,' '),'_'))

	object method = lookup_method(class,property)

	if atom(method) then -- not found, try fallback to Object;
		return get_property(handle,property[5..$])
	end if

 -- else, method found;

	object params = method[PARAMS]

	if method[VECTOR] = -1 then
		crash("\nERROR:\n****** Invalid call: %s->%s",{widget[class][$],method[1]})
	end if
	object result = {}

	if string(p1) then p1 = allocate_string(p1,1) end if
	if string(p2) then p2 = allocate_string(p2,1) end if
	if string(p3) then p3 = allocate_string(p3,1) end if
	if string(p4) then p4 = allocate_string(p4,1) end if
	if string(p5) then p5 = allocate_string(p5,1) end if

	object args = {handle,
		allocate(8,1),allocate(8,1),allocate(8,1),
		allocate(8,1),allocate(8,1),allocate(8,1)}

	if p1 > MINF then args[2]=p1 end if
	if p2 > MINF then args[3]=p2 end if
	if p3 > MINF then args[4]=p3 end if
	if p4 > MINF then args[5]=p4 end if
	if p5 > MINF then args[6]=p5 end if
	if p6 > MINF then args[7]=p6 end if

	args = args[1..length(params)]

	ifdef GET then -- debug
		display(decode_method("GET",class,method),0) 
		puts(1,"\tArgs: ") 
		display(decode_args(method,args),
			{2,2,11,78,"%d","%2.22f",32,127,4,-1})
	end ifdef

----------------------------------------------------------------------------------------
	if method[RETVAL] <-1 then -- it's a Eu func (negated routine_id);
		result = call_func(-method[VECTOR],args) 
		goto "fini"
	end if

----------------------------------------------------------------------------------------
	if method[RETVAL] = 0 then -- it's a GTK proc, may have multiple return values;
		c_proc(method[VECTOR],args)
		result = repeat(0,length(args)) 
		for i = 1 to length(args) do 
			switch params[i] do -- convert arg pointer to value;
				case D then result[i] = float64_to_atom(peek({args[i],8})) 
				case F then result[i] = float32_to_atom(peek({args[i],4})) 
				case I then result[i] = peek4s(args[i]) 
				case B then result[i] = peek(args[i])
				case A then result[i] = unpack_gs_str_list(args[i])
				case X then result[i] = unpack_gs_atom_list(args[i])
				case V then result[i] = deallocate_string_pointer_array(args[i])
				case S then if args[i] > 0 then result[i] = peek_string(args[i]) end if
				case else result[i] = args[i]
			end switch
		end for
		result = result[2..$] -- don't return handle, just results;
		goto "fini"
	end if 

-------------------------------------------------------------------------------------	
	if method[RETVAL] > 0 then -- it's a GTK func;
		result = c_func(method[VECTOR],args) 
		switch method[RETVAL] do -- convert function result to value;
			case A then result = unpack_gs_str_list(result)
			case X then result = unpack_gs_atom_list(result)
			case V then result = deallocate_string_pointer_array(result)
			case S then if result > 0 then 
					result = peek_string(result)  
				else 
					result = 0 
				end if
			case I then 
				switch method[1] do -- patch for zero-based indexing;
					case 
						"get_active",
						"get_text_column",
						"get_pixbuf_column",
						"get_column",
						"get_tooltip_column",
						"get_search_column",
						"get_current_page",
						"get_index",
						"get_item_index",
						"page_num",
						"get_sort_column_id" then result += 1
				end switch
		end switch
	goto "fini"
	end if

-------------------------------------------------------------------------------------

label "fini"

	if method[CLASS] != GSList then -- for widgets created 'internally' by GTK
		if method[CLASS] != 0 then  -- as a result of creating a parent widget;
			if not initialized[method[CLASS]] then init(method[CLASS]) end if
			if atom(result) then register(result,method[CLASS])
			else for z = 1 to length(result) do
				register(result[z],method[CLASS]) -- must be registered!;
				end for
			end if 
		end if
	end if

ifdef GET then display("\tReturns: []\n",{result}) end ifdef

return result  
end function 

---------------------------------------------------
public function add(object parent, object child) -- add widgets to container;
---------------------------------------------------

     if atom(child) and child = 0 then -- no can do!
	  display("Null pointer passed to add()\n")
	  return 0
     end if

     if class_id(child) = GdkPixbuf then -- issue a warning;
	  return Warn(,,"Cannot add a pixbuf to a container",
	       "Create an image from it first,\nthen add the image.",,child)
     end if

     if class_id(parent) = GtkBuilder then 
	  load_builder(parent,child) 
	  return 1
     end if

     if string(parent) then -- convert to handle;
	  parent = pointer(parent)
     end if

     if string(child) then -- convert to handle;
	  child = pointer(child)
     end if

     -- Switches below implement an easier-to-remember 'add' syntax 
     -- as an alias for the various 'set' calls shown. 
     -- The GTK original is still available, if you wish to use it.
	 
     switch class_id(child) do
	  case GtkAccelGroup then set(parent,"add accel group",child)
	  case GtkMenu then set(parent,"submenu",child)
	  return child
     end switch

     switch class_id(parent) do 
	
	  case GtkBox then foreach(child,"pack start",parent)

	  case GtkComboBoxText, GtkComboBoxEntry then
	       foreach(child,"append text",parent)

	  case GtkToolbar then foreach(child,"insert",parent,-1)

	  case GtkFileChooserDialog then
	       if class_id(child) = GtkFileFilter then
		    foreach(child,"add filter",parent)
	       end if

	  case GtkSizeGroup then foreach(child,"add widgets",parent)

	  case GtkTreeView then foreach(child,"append column",parent)

	  case GtkMenu, GtkMenuBar then foreach(child,"append",parent)
	  	  
	  case else foreach(child,"add",parent)
		
     end switch
	
return child
end function 

---------------------------------------------------------------------
function foreach(object child, sequence fn, atom parent, atom data=0)
---------------------------------------------------------------------
if atom(child) then set(parent,fn,child,data)
else 
     for i = 1 to length(child) do
	  set(parent,fn,child[i],data)
     end for
end if
return 1
end function

------------------------------------------------------------------------
public function pack(object parent, object child,
	integer expand=0, integer fill=0, integer padding=0)
------------------------------------------------------------------------
-- pack a child widget or {list} of widgets into parent container;
-- prepending a negative sign to a child pointer means
--'pack end'. this is an alias which is sometimes useful.
------------------------------------------------------------------------

	if string(child) then child = pointer(child) end if

	if atom(child) then
		if child > 0 then
			pack_start(parent,child,expand,fill,padding)
		else
		child = -child
			pack_end(parent,child,expand,fill,padding)
		end if
	else 
		for i = 1 to length(child) do
			pack(parent,child[i],expand,fill,padding)
		end for
	end if

	return abs(child)
end function

-------------------------------------------------------------
public function pack_start(object parent, object child, 
	boolean expand=0, boolean fill=0, integer padding=0)
-------------------------------------------------------------
     if atom(child) then
	  set(parent,"pack start",child,expand,fill,padding)
     else
	  for i = 1 to length(child) do
	       pack_start(parent,child[i],expand,fill,padding)
	  end for
     end if
return child
end function 

-------------------------------------------------------------
public function pack_end(object parent, object child, 
	boolean expand=0, boolean fill=0, integer padding=0)
-------------------------------------------------------------
     if atom(child) then
	  set(parent,"pack end",child,expand,fill,padding)
     else
	  for i = 1 to length(child) do
	       pack_end(parent,child[i],expand,fill,padding)
	  end for
     end if
return child
end function

----------------------------------
public procedure show(object x) -- show widget  or a {list} of widgets;
----------------------------------
	if string(x) then x = pointer(x) end if
     if atom(x) then
	  set(x,"show")
     else 
	  for i = 1 to length(x) do 
	       show(x[i]) 
	  end for
     end if
end procedure

--------------------------------------
public procedure show_all(object x) -- show container x and all children;
--------------------------------------
     if string(x) then set(x,"show_all") return end if
     if atom(x) then
	  set(x,"show all")
     else
	  for i = 1 to length(x) do
	       set(x[i],"show all")
	  end for
     end if
end procedure

----------------------------------
public function hide(object x) -- hide a widget or a {list} of widgets;
----------------------------------
     if string(x) then set(x,"hide") return 1 end if
     if atom(x) then 
	  set(x,"hide")
     else
	  for i = 1 to length(x) do
	       hide(x[i])
	  end for
     end if
return 1
end function

--------------------------------------
public function hide_all(object x) -- hide container x and any children it contains;
--------------------------------------
    if string(x) then x = pointer(x) end if
    if atom(X) then
		set(x,"hide all")
	else
		for i = 1 to length(x) do
			hide(x[i])
		end for
	end if
return 1
end function

---------------------------------------
export function destroy(object ctl) -- destroy a widget or {list} of widgets;
---------------------------------------
     if sequence(ctl) then
	  for i = 1 to length(ctl) do
		destroy(ctl[i])
	  end for
     else
	  if ctl > 0 then 
		set(ctl,"destroy")
		deregister(ctl)
	  end if
     end if
return 1
end function

--------------------------
export procedure main() -- start the GTK engine;
--------------------------
	gtk_proc("gtk_main")
end procedure

without warning {not_reached} 

-----------------------------------------------------
export function Quit(atom ctl=0, object errcode=0) -- kill the GTK engine;
-----------------------------------------------------
     abort(errcode)
return 1
end function
export constant gtk_main_quit = call_back(routine_id("Quit"))
	
with warning {not_reached} 

----------------------------------
function numeric_test(object x) -- convert numbers passed in key=value format;
----------------------------------
 atom z
 
 if atom(x) then 
	return x 
 end if
 
 if string(x) then -- convert some common words to boolean;
   switch upper(x) do
	case "TRUE","YES","VERTICAL" then return TRUE 
	case "FALSE","NO","HORIZONTAL" then return FALSE
	case "MOUSE" then return GTK_WIN_POS_MOUSE
	case "CENTER" then return GTK_WIN_POS_CENTER
	case "PARENT" then return GTK_WIN_POS_CENTER_ON_PARENT
	case "CENTER_ALWAYS" then return GTK_WIN_POS_CENTER_ALWAYS
	case else -- do nothing;
   end switch
 end if

 z = to_number(x)
 
 if z != 0 then 
	return z
 else
	return x
 end if
	
end function

------------------------------------------------------------------------
-- Following functions register and initialize class methods 
------------------------------------------------------------------------
-- A class is initialized the first time a widget of that class is created.
-- This means the widget's method vectors are filled in with Eu routine_ids, 
-- either direct or generated by define_c_func or define_c_proc.

-- When a subsequent call is made to a widget method, that vector is 
-- used by calling c_func, c_proc, or call_func as appropriate.

-- If the call is to a method not implemented by the widget, but is 
-- instead a method inherited from one of the widget's ancestors, 
-- then that ancestor is also initialized if necessary.

-- This scheme means that program startup isn't delayed as it would be 
-- if all 300+ widgets and nearly 4000 methods were to be initialized, 
-- most of which would likely never be used in any given program.

------------------------------------------------------------------------
global procedure init(integer class)
------------------------------------------------------------------------
object name, params, retval

 	for method = 3 to length(widget[class])-1 do

		name = sprintf("+%s_%s",{widget[class][NAME],widget[class][method][NAME]})

		widget[class][method] = pad_tail(widget[class][method],5,0)
		params = widget[class][method][PARAMS]
		retval = widget[class][method][RETVAL]

		if class = GtkSpinButton then 
			switch widget[class][method][NAME] do
				case "get_increments","get_range" then 
					params[2] = P params[3] = P
				case else -- do nothing;
			end switch
		end if

		if widget[class][method][RETVAL] = 0 then -- it's a GTK proc
			widget[class][method][VECTOR] = define_proc(name,params)
			goto "init"
		end if

		if widget[class][method][RETVAL] > 0 then -- it's a GTK func
			widget[class][method][VECTOR] = define_func(name,params,retval)
			goto "init"
		end if

		if widget[class][method][RETVAL] < -1 then -- it's a Eu func
			widget[class][method][VECTOR] = widget[class][method][RETVAL]
		end if

   label "init"

	initialized[class] = TRUE

	ifdef INIT_ERR then
		if widget[class][method][VECTOR] = -1 then -- function is invalid!
			display("\tINIT ERROR: [].[] ERR:[]",
			{widget[class][$],widget[class][method][NAME],
				widget[class][method][VECTOR]}) 
		end if
	end ifdef
		
	end for
	    
	ifdef INIT then
		display("Init class:[] []",{class,widget[class][$]}) 
		for i = 3 to length(widget[class]) -1 do
		     if length(widget[class][i]) > 3 then
				display("\t[] [] []",
				{i-2,widget[class][i][1],widget[class][i][4]})
			else
				display("\t[] [] []",
				{i-2,widget[class][i][1],widget[class][i][2]})
			end if
		end for
		display("\n")
	end ifdef
	
end procedure 

------------------------------------------------------------------------
-- The registry associates a control's handle with its class,
-- so that future calls to set or get that control's properties
-- can go directly to the correct set of functions stored in the
-- large widget{} structure.
------------------------------------------------------------------------
export object registry = {}

----------------------------------------------------------------------------------------
global function register(atom handle, integer class, 
	object name="-nil-", object v=math:MINF)
----------------------------------------------------------------------------------------
ifdef REG then display("Handle [] Class [] Name []",{handle,class,name}) end ifdef

integer x = find(handle,vslice(registry,1))

	if x > 0 then -- handle already exists in the registry,
	ifdef REG_DUP then -- debug
	    if not equal(handle,registry[x][1]) then
		display("Note: [] handle [] already registered to [] [] []",
		{widget[class][$],handle,registry[x][3],registry[x][1],name})
	    end if	
	end ifdef
	
	-- update it in case handle has been recycled.
	     registry[x] = {handle,class,widget[class][$],name,v}
	     return 1
	end if 

	-- else, add the widget to the registry;
		registry = append(registry,{handle,class,widget[class][$],name,v})

	-- initialize class if this is the first use of that class;
	if not initialized[class] then init(class) end if

	ifdef REG then -- debug
	     display("[:4]",length(registry),0)
		display(" Registry + [3:16]\thandle: [1:10>]",registry[$]) 
	end ifdef
return 1
end function 
  
--------------------------------------
procedure deregister(object handle) -- remove object when no longer used;
--------------------------------------
if string(handle) then
        handle = pointer(handle)
end if
integer x = find(handle,vslice(registry,1))
if x > 0 then
	ifdef DEREG then
	     display("[:4]",length(registry),0)
		display(" Registry - [3:16]\thandle:[1:11>]\t[4]",registry[x])
	end ifdef
	registry = remove(registry,x) 
end if
end procedure

------------------------------------------
global function class_id(object handle) -- returns an integer widget class = Gtk* enums
------------------------------------------
	if string(handle) then handle = pointer(handle) end if
	return vlookup(handle,registry,1,2,-1)
end function

---------------------------------------
global function class_name(object x) -- returns class_name for a given handle/name;
---------------------------------------
object handle = x
	if string(x) then handle = pointer(x) x = "gSTR" end if
	return vlookup(handle,registry,1,3,x)
end function

--------------------------------------
global function widget_name(atom x) -- returns gtk name from the widget sequence;
--------------------------------------
return widget[x][$]
end function

-------------------------------------------
public function object_name(atom handle) -- returns name of object or -nil-
------------------------------------------- 
	return vlookup(handle,registry,1,4,"?") 
end function

---------------------------------------
public function pointer(object name) -- returns handle to object or null;
---------------------------------------
	return vlookup(name,registry,4,1,0)
end function

------------------------------------------------------------------------
function lookup_method(integer class, sequence prop)
------------------------------------------------------------------------
-- Finds the method to set or get a property for a given class,
-- if not found, ancestors of that class are checked until the method
-- is located. 
  
  if class = -1 then return 0 end if

	ifdef LOOKUP then display("\nLOOKUP: []->[]",{widget[class][$],prop},0) end ifdef

	object method = lookup(prop,vslice(widget[class],NAME),widget[class],0)

	if atom(method) then -- try sans the set_ or get_ prefix;
		method = lookup(prop[5..$],vslice(widget[class],NAME),widget[class],0)
	end if

	if sequence(method) then -- method was found in this class, we're done!
		ifdef LOOKUP then display("\n\tFOUND: '[]' in []",{method[1],widget[class][$]}) end ifdef
		return method 
	end if

	object ancestor -- if not found, need to look for method in ancestors;
	
		for i = 1 to length(widget[class][PARAMS]) do
			ancestor = widget[class][PARAMS][i] 
			if ancestor = 0 then return 0 end if

			if not initialized[ancestor] then 
				init(ancestor) 
			end if
			
			ifdef LOOKUP then
				display("\n\tTRY [] ancestor []",{widget[class][$],widget[ancestor][$]},0)
			end ifdef
			
			method = lookup(prop,vslice(widget[ancestor],NAME),widget[ancestor],0)
			if atom(method) then
				method = lookup(prop[5..$],vslice(widget[ancestor],NAME),widget[ancestor],0)
			end if

			if sequence(method) then -- found it!
			   ifdef LOOKUP then 
				display("\n\tFOUND: '[]' property for []",{method[1],widget[ancestor][$]}) 
			   end ifdef
			   return method
			end if

		end for
    
      -- FAIL:
	ifdef LOOKUP then 
		display("\n** METHOD NOT FOUND:[] []",{widget[class][$],prop}) 
	end ifdef
	return -1 -- method not found (not implemented)
	
end function 

-----------------------------------------------------------------------------
public function connect(object ctl, object sig, object fn=0, object data=0, 
	atom closure=0, integer flags=0)
-----------------------------------------------------------------------------
-- tells control ctl to call your Eu function fn, sending data along for the ride,
-- whenever that control gets the specified signal 

integer result = -1
atom rid = 0

	if atom(fn) and fn = 0 then -- no point in registering null functions!
		 return 0
	end if

	if string(ctl) then  -- convert name to pointer;
		ctl = pointer(ctl)
	end if 

	ifdef CONNECT then
		display("CONNECT: [] $[] -> [] data: []\n",{get(ctl,"name"),sig,fn,data})
	end ifdef
	
	if sequence(ctl) then 
		for i = 1 to length(ctl) do
			connect(ctl[i],sig,fn,data,closure,flags)
		end for
		return 1
	end if

	if string(fn) then -- we can call functions by name if in scope;
	
		ifdef COMPILE then -- do compile test if requested;
			ifdef CONNECT then 
				display("Connecting [] [] [] $[]=[] Data:[]",
					{class_name(ctl),get(ctl,"name"),ctl,sig,fn,data})
			end ifdef
			if routine_id(fn) = -1 then
				printf(1,"\n\tCaution: function %s will not link when compiled!\n" &
					   "\t********\n",{fn})
				Error(,"Compile Test",sprintf("Caution:%s",{get(ctl,"name")}),
				  text:format("<b>function []</b> will not link when compiled!",{fn}))	   
			end if
		end ifdef

		rid = routine_id(fn) -- convert string function name to routine_id;
		
		if rid > -1 then 	-- named function is in scope;
			fn = call_back(rid) -- so obtain a callback;
			
		else -- callback invalid, function is not in scope;
			printf(1,"\n\tError: function %s is not in scope\n" &
				"\t****** (make it global or link via _(\"%s\")\n\n",{fn,fn})
			Warn(,,sprintf("function %s </b> is not in scope<b>",{fn}),
			       sprintf("make it global or link via _(\"%s\")",{fn}) )
		end if
	end if

	sig = lower(join(split(sig,' '),'-')) -- normalize signal names;
	sig = allocate_string(sig) -- convert to pointer;

	if integer(data) then -- data can be attached directly;
		result = gtk_func("g_signal_connect_data",
			{P,S,P,P,P,I},{ctl,sig,fn,data,closure,flags})
		free(sig)
	return result
	end if

	if atom(data) then -- data must be serialized and unpacked later;
		data = prepend({data},"ATOM") -- tag it;
		data = allocate_wstring(serialize(data)+1)
		result = gtk_func("g_signal_connect_data",
			{P,S,P,P,P,I},{ctl,sig,fn,data,closure,flags})
		free(sig)
	return result
	end if

	if string(data) then -- data must be serialized and unpacked later;
		data = prepend({data},"STR") -- tag it;
		data = allocate_wstring(serialize(data)+1) 
		result = gtk_func("g_signal_connect_data",
			{P,S,P,P,P,I},{ctl,sig,fn,data,closure,flags})
		free(sig)
		return result
	end if

	if sequence(data) then -- data must be serialized and unpacked later;
		data = prepend(data,"SEQ") -- tag it;
		data = allocate_wstring(serialize(data)+1)
		result = gtk_func("g_signal_connect_data",
			{P,S,P,P,I,I},{ctl,sig,fn,data,closure,flags})
		free(sig)
		return result
	end if

end function 

-------------------------------------------------------
export procedure disconnect(atom ctl, integer sigid) -- disconnect a signal from ctl;
-------------------------------------------------------
	gtk_proc("g_signal_handler_disconnect",{P,I},{ctl,sigid})
end procedure

--------------------------------------
export function unpack(object data) -- retrieves data passed in a control's data space; 
--------------------------------------
if atom(data) and data = 0 then return 0 end if
object result = deserialize(peek_wstring(data)-1)
	switch result[1][1] do -- get the tag;
		case "ATOM","STR","INT" then return result[1][2]
		case "SEQ" then return result[1][2..$]
		case else return result
	end switch
end function

-------------------------------------------------------
export function deallocate_string_pointer_array(atom x)
-------------------------------------------------------
integer i = 0
object result = {}
  while peek4u(x+i) > 0 do
		result = append(result,peek_string(peek4u(x+i)))
		ifdef BITS64 then
			i += 8
		elsedef
			i += 4
		end ifdef
  end while
 return result
end function

------------------------------------------------------------------
export function environment() -- returns name=val list of env vars
------------------------------------------------------------------
return deallocate_string_pointer_array(gtk_func("g_get_environ"))
end function

--------------------------------------------------------------------------
-- the following 3 'decode_x' functions make debug displays more readable;
--------------------------------------------------------------------------

function decode_args(object method, object args)
------------------------------------------------------------------------
 for i = 1 to length(method[PARAMS]) do
	switch method[PARAMS][i] do
		case S then 
			if atom(args[i]) and args[i] > 0 then 
				args[i] = peek_string(args[i]) 
				if length(args[i]) > 40 then
					args[i] = args[i][1..40] & "..."
				end if
				args[i] = args[i]
			end if
	case else -- do not convert
	end switch
 end for
 return args
end function 

constant ptype = {0,P,I,D,F,S,B,A}
constant pname = {{},"None","Ptr ","Int ","Dbl ","Flt ","Str ","Bool ","Array "}

---------------------------------------
function decode_params(object params)
---------------------------------------
 return transmute(params,ptype,pname)
end function

----------------------------------------------------------------------
function decode_method(sequence title, integer class, object method)
----------------------------------------------------------------------
object z = {}
integer n
	z = prepend(method,widget[class][$]) 
	z = prepend(z,title) 
	z[4] = decode_params(method[PARAMS]) 
	while length(z) < 5 do
		z = append(z,0)
	end while
	if length(method) >= RETVAL then
		n = find(method[RETVAL],ptype) 
		z[5] = pname[n+1]
	end if
 return text:format("[]\n\tCall: []->[]\n\tParams: []\n\tReturn type: []\n\tVector: []",z)
end function

---------------------------------------------------------
export function to_sequence(atom glist, integer fmt=0) -- mostly internal use;
---------------------------------------------------------
-- convert glist pointer back to a Euphoria sequence;
-- results are returned in a choice of formats;
  integer len = gtk_func("g_list_length",{P},{glist}) 
  object s = {}
  atom data
	for i = 0 to len-1 do
		data = gtk_func("g_slist_nth_data",{P,I},{glist,i})
		switch fmt do
			case 0 then s = append(s,peek_string(data))
			case 1 then s = append(s,data)
			case 2 then s = append(s,gtk_str_func("gtk_tree_path_to_string",{P},{data}))
			case 3 then s = append(s,to_number(gtk_str_func("gtk_tree_path_to_string",
										{P},{data})))
			case else Warn(,,"Converting glist to_sequence",
				"invalid format supplied,\nvalues are 0 to 3")
		end switch
	end for
 return s
end function

-------------------------------------------------------------------------
-- METHOD DECLARATIONS: 
-------------------------------------------------------------------------

sequence initialized = repeat(0,512)

-- This is a set of flags which are set to 1 when a given class has 
-- been initialized. This prevents having to initialize the class
-- methods repeatedly. Size is larger than GtkFinal to allow 'plugin'
-- widgets to be added at runtime.

export sequence widget = repeat(0,GtkFinal)

-- This structure holds prototypes for each GTK method call,
-- organized by class. When each class is initialized,
-- vectors are added pointing to the routine_ids needed
-- to call the GTK functions that implement each method.

-- The widgets below need not be in any specific order.
-- New widget class names must also be added to the list in GtkEnums  

sequence stock_list = create(GtkStockList) -- a fake object;

widget[GObject] = {"g_object", -- this is the lowest-level;
{0}, 
	{"new",{I,S,S,I},P}, 
	{"set",{P,S,P,P}},   
	{"set_property",{P,S,P},-routine_id("set_property")}, 
	{"get_property",{P,S},-routine_id("get_property")},
	{"get_data",{P,P},S},
	{"set_data",{P,S,S}},
	{"set_data_full",{P,S,S,P}},
	{"steal_data",{P,S},P},
	{"signal",{P,P,P,P,P,P},-routine_id("connect")}, 
	{"connect",{P,P,P,P,P,P},-routine_id("connect")},
"GObject"} 

     constant 
	  fn1 = define_proc("g_object_get",{P,P,P,P}),
	  doubles = {"angle","climb-rate","fraction","max-value","min-value",
	       "scale","value","pulse-step","scale","size-points","text-xalign",
	       "text-yalign","xalign","yalign"}
	       
    --------------------------------------------------------------
    function set_property(object handle, object a, object b)
    --------------------------------------------------------------
	object params = {P,P,P,P}
		ifdef SETP then
			display("    >> Obj Set Property [] [] []",
				{class_name(handle),peek_string(a),b})
		end ifdef
		if find(a,doubles) then params = {P,P,D,P} end if
		if string(a) then a = allocate_string(a,1) end if
		if string(b) then b = allocate_string(b,1) end if
		gtk_proc("g_object_set",params,{handle,a,b,0}) 
	 return 1
	end function

    --------------------------------------------------
    function get_property(atom handle, object p)
    --------------------------------------------------
	atom x = allocate(8,1) 
		ifdef GETP then
			display("    >> Obj Get Property [] [] []",
				{class_name(handle),handle,peek_string(p)})
		end ifdef
		if string(p) then p = allocate_string(p,1) end if
		c_proc(fn1,{handle,p,x,0}) 
		object result = peek4u(x)
	 return result
	end function

widget[GtkAdjustment] = {"gtk_adjustment",
{GObject},
	{"new",{D,D,D,D,D,D},P},
	{"set_value",{P,D}},
	{"get_value",{P},D},
	{"clamp_page",{P,D,D}},
	{"value_changed",{P}},
	{"configure",{P,D,D,D,D,D,D}},
	{"get_lower",{P},D},
	{"get_page_increment",{P},D},
	{"get_step_increment",{P},D},
	{"get_minimum_increment",{P},D},
	{"set_upper",{P,D}},
	{"get_upper",{P},D},
	{"set_page_increment",{P,D}},
	{"set_page_size",{P,D}},
	{"set_step_increment",{P,D}},
	{"set_upper",{P,D}},
"GtkAdjustment"}

widget[GtkWidgetPath] = {"gtk_widget_path",
{GObject},
	{"new",{},P},
	{"append_type",{P,I},I},
	{"append_with_siblings",{P,P,I},I},
	{"append_for_widget",{P,P},I},
	{"copy",{P},P,0,GtkWidgetPath}, -- automatically type-cast to proper object;
	{"get_object_type",{P},I},
	{"has_parent",{P,I},B},
	{"is_type",{P,I},B},
	{"iter_add_class",{P,I,S}},
	{"iter_add_region",{P,I,S,I}}, -- deprecated 3.;14
	{"iter_clear_classes",{P,I}},
	{"iter_clear_regions",{P,I}}, -- deprecated 3.14
	{"iter_get_name",{P,I},S},
	{"iter_get_object_type",{P,I},I},
	{"iter_get_siblings",{P,I},P,0,GtkWidgetPath},
	{"iter_get_sibling_index",{P,I},I},
	{"iter_has_class",{P,I,S},B},
	{"iter_has_name",{P,I,S},B},
	{"iter_has_qclass",{P,I,P},B},
	{"iter_has_qname",{P,I,P},B},
	{"iter_has_qregion",{P,I,P,I},B}, -- deprecated 3.14
	{"iter_has_region",{P,I,S,I},B}, -- deprecated 3.14
	{"iter_list_classes",{P,I},A,0,GSList}, -- return type is a gSlist;
	{"iter_list_regions",{P,I},A,0,GSList}, -- deprecated 3.14
	{"iter_remove_class",{P,I,S}},
	{"iter_remove_region",{P,I,S}}, -- deprecated 3.14
	{"iter_set_name",{P,I,S}},
	{"iter_set_object_type",{P,I,I}},
	{"iter_set_object_name",{P,I,S}}, -- 3.20
	{"iter_get_object_name",{P,I},S}, -- 3.20
	{"iter_get_state",{P,I},I}, -- 3.14
	{"iter_set_state",{P,I,I}}, -- 3.14
	{"length",{P},I},
	{"prepend_type",{P,I}},
	{"to_string",{P},S},
	{"get_object_name",{P,I},S}, -- 3.20
	{"set_object_name",{P,I,S}}, -- 3.20
"GtkWidgetPath"}

widget[GtkWidgetClass] = {"gtk_widget_class",
{GtkWidget,GtkBuildable,GObject},
	{"set_template",{P,P}}, -- 3.10
	{"set_template_from_resource",{P,S}}, -- 3.10
	{"get_template_child",{P,I,S},P,0,GObject}, 
	{"bind_template_child_full",{P,S,B,I}},
	{"bind_template_callback_full",{P,S,P}},
	{"set_connect_func",{P,P,P,P}},
	{"set_css_name",{P,S}}, -- 3.20
	{"get_css_name",{P},S}, -- 3.20
"GtkWidgetClass"}

widget[GtkWidget] = {"gtk_widget",
{GtkBuildable,GObject},
	{"new",{I},P},
	{"destroy",{P}},
	{"in_destruction",{P},B},
	{"destroyed",{P},B},
	{"unparent",{P}},
	{"show",{P}},
	{"show_now",{P}},
	{"hide",{P}},
	{"show_all",{P}},
	{"map",{P}},
	{"unmap",{P}},
	{"realize",{P}},
	{"unrealize",{P}},
	{"draw",{P}},
	{"queue_draw",{P}},
	{"queue_resize",{P}},
	{"queue_resize_no_redraw",{P}},
	{"get_frame_clock",{P},P,0,GdkFrameClock},
	{"add_tick_callback",{P,P,P,P},I},
	{"remove_tick_callback",{P,I}}, -- GTK 3.8+
	{"set_size_request",{P,P,P},-routine_id("widget_set_size_request")},
	{"size_allocate",{P,P}},
	{"size_allocate_with_baseline",{P,P,I}},
	{"add_accelerator",{P,S,P,I,I}},
	{"remove_accelerator",{P,P,I,I},B},
	{"set_accel_path",{P,S,P}},
	{"can_activate_accel",{P,I},B},
	{"event",{P,P},B},
	{"activate",{P},B},
	{"reparent",{P,P}}, -- deprecated 3.14
	{"intersect",{P,P,P},B},
	{"is_focus",{P},B},
	{"grab_focus",{P},B},
	{"grab_default",{P}},
	{"set_name",{P,S},-routine_id("widget_set_name")},
	{"get_name",{P},S},
	{"set_sensitive",{P,B}},
	{"get_sensitive",{P},B},
	{"set_parent",{P,P}},
	{"get_parent",{P},P},
	{"set_parent_window",{P,P}},
	{"get_parent_window",{P},P},
	{"set_events",{P,I}},
	{"get_events",{P},I},
	{"add_events",{P,I}},
	{"set_device_events",{P,P,I}},
	{"get_device_events",{P,P},I},
	{"add_device_events",{P,P,I}},
	{"set_device_enabled",{P,P,B}},
	{"get_device_enabled",{P,P},B},
	{"get_toplevel",{P},P},
	{"get_ancestor",{P,I},P},
	{"is_ancestor",{P,P},B},
	{"set_visual",{P,P}},
	{"get_visual",{P},P,0,GdkVisual},
	{"get_pointer",{P,I,I}}, -- deprecated 3.4
	{"translate_coordinates",{P,P,I,I,I,I},B},
	{"hide_on_delete",{P},B},
	{"set_direction",{P,I}},
	{"get_direction",{P},I},
	{"set_default_direction",{I}},
	{"get_default_direction",{},I},
	{"shape_combine_region",{P,P}},
	{"create_pango_context",{P},P},
	{"get_pango_context",{P},P,0,PangoContext},
	{"create_pango_layout",{P,S},P},
	{"queue_draw_area",{P,I,I,I,I}},
	{"queue_draw_region",{P,P}},
	{"set_app_paintable",{P,B}},
	{"set_double_buffered",{P,B}}, -- deprecated 3.14
	{"set_redraw_on_allocate",{P,B}},
	{"mnemonic_activate",{P,B},B},
	{"send_expose",{P,P},I},
	{"send_focus_change",{P,P},B},
	{"get_accessible",{P},P},
	{"child_focus",{P,I},B},
	{"child_notify",{P,S}},
	{"freeze_child_notify",{P}},
	{"get_child_visible",{P},B},
	{"get_parent",{P},P},
	{"get_path",{P},P,0,GtkWidgetPath},
	{"get_settings",{P},P,0,GtkSettings},
	{"get_clipboard",{P,I},P,0,GtkClipboard},
	{"get_display",{P},P,0,GdkDisplay},
	{"get_root_window",{P},P,0,GdkWindow}, -- deprecated 3.12
	{"get_screen",{P},P,0,GdkScreen},
	{"has_screen",{P},B},
	{"get_size_request",{P,I,I}},
	{"set_child_visible",{P,B}},
	{"thaw_child_notify",{P}},
	{"set_no_show_all",{P,B}},
	{"get_no_show_all",{P},B},
	{"add_mnemonic_label",{P,P}},
	{"remove_mnemonic_label",{P,P}},
	{"is_composited",{P},B},
	{"set_tooltip_markup",{P,S}},
	{"get_tooltip_markup",{P},S},
	{"set_tooltip_text",{P,S}},
	{"get_tooltip_text",{P},S},
	{"set_tooltip_window",{P,P}},
	{"get_tooltip_window",{P},P,0,GtkWindow},
	{"set_has_tooltip",{P,B}},
	{"get_has_tooltip",{P},B},
	{"trigger_tooltip_query",{P}},
	{"get_window",{P},P,0,GdkWindow},
	{"register_window",{P,P}}, -- GTK 3.8+
	{"unregister_window",{P,P}}, -- GTK 3.8+
	{"get_allocated_width",{P},I},
	{"get_allocated_height",{P},I},
	{"get_allocation",{P},-routine_id("widget_get_allocation")},
	{"set_allocation",{P,P}},
	{"get_allocated_baseline",{P},I},
	{"get_app_paintable",{P},B},
	{"set_can_default",{P,B}},
	{"get_can_default",{P},B},
	{"get_can_focus",{P},B},
	{"get_double_buffered",{P},B}, -- deprecated 3.14
	{"get_has_window",{P},B},
	{"get_sensitive",{P},B},
	{"get_visible",{P},B},
	{"is_visible",{P},B}, -- GTK 3.8+
	{"set_visible",{P,B}},
	{"set_state_flags",{P,I,B}},
	{"unset_state_flags",{P,I}},
	{"get_state_flags",{P},I},
	{"has_default",{P},B},
	{"has_focus",{P},B},
	{"has_visible_focus",{P},B},
	{"has_grab",{P},B},
	{"is_drawable",{P},B},
	{"is_toplevel",{P},B},
	{"set_window",{P,P}},
	{"set_receives_default",{P,B}},
	{"get_receives_default",{P},B},
	{"set_support_multidevice",{P,B}},
	{"get_support_multidevice",{P},B},
	{"set_realized",{P,B}},
	{"get_realized",{P},B},
	{"set_mapped",{P,B}},
	{"get_mapped",{P},B},
	{"device_is_shadowed",{P,P},B},
	{"get_modifier_mask",{P,I},I},
	{"insert_action_group",{P,S,P}},
	{"get_opacity",{P},D},  -- GTK 3.8+
	{"set_opacity",{P,D}}, -- GTK 3.8+
	{"get_path",{P},P,0,GtkWidgetPath},
	{"get_style",{P},P,0,GtkStyle},
	{"get_style_context",{P},P,0,GtkStyleContext},
	{"reset_style",{P}},
	
	{"measure",{P,I,I,I,I,I,I}},	-- New in GTK4:

	{"get_preferred_height",{P,I,I}}, 		-- deprecated in GTK4;
	{"get_preferred_width",{P,I,I}}, 		-- deprecated in GTK4;
	{"get_preferred_height_for_width",{P,I,I,I}}, 	-- deprecated in GTK4;
	{"get_preferred_width_for_height",{P,I,I,I}}, 	-- deprecated in GTK4;
	{"get_preferred_height_and_baseline_for_width",{P,I,I,I,I,I}}, -- deprecated in GTK4;

	{"get_request_mode",{P},I},
	{"get_preferred_size",{P,P,P}},
	{"get_preferred_size_and_baseline",{P,P,I,I}},
	{"get_halign",{P},I},
	{"set_halign",{P,I}},
	{"get_valign",{P},I},
	{"set_valign",{P,I}},
	
	{"set_margin_left",{P,I}}, -- deprecated 3.12 use start or end instead;
	{"get_margin_left",{P},I}, -- deprecated 3.12
	{"set_margin_right",{P,I}}, -- deprecated 3.12
	{"get_margin_right",{P},I}, -- deprecated 3.12
	
	{"get_margin_end",{P},I}, -- new 3.12
	{"set_margin_end",{P,I}}, -- new 3.12
	{"get_margin_start",{P},I}, -- new 3.12
	{"set_margin_start",{P,I}}, -- new 3.12
	
	{"set_margin_top",{P,I}},
	{"get_margin_top",{P},I},
	{"set_margin_bottom",{P,I}},
	{"get_margin_bottom",{P},I},
	{"get_hexpand",{P},B},
	{"set_hexpand",{P,B}},
	{"get_hexpand_set",{P},B},
	{"set_hexpand_set",{P,B}},
	{"get_vexpand",{P},B},
	{"set_vexpand",{P,B}},
	{"get_vexpand_set",{P},B},
	{"set_vexpand_set",{P,B}},
	{"queue_compute_expand",{P}},
	{"compute_expand",{P,I},B},
	{"init_template",{P}},
	{"get_automated_child",{P,I,S},P,0,GObject},
	{"get_clip",{P,P}}, -- 3.14
	{"set_clip",{P},P}, -- 3.14
	{"get_action_group",{P,S},P,0,GActionGroup}, -- 3.16
	{"list_action_prefixes",{P},A}, -- 3.16
	{"get_font_map",{P},P,0,PangoFontMap}, -- 3.18
	{"set_font_map",{P,P}}, -- 3.18
	{"get_font_options",{P},P}, -- 3.18
	{"set_font_options",{P,P}}, -- 3.18
	{"signal",{P,P,P,P,P,P},-routine_id("connect")},
	{"list_accel_closures",{P},X,0,GList},
	{"get_font",{P},-routine_id("widget_get_font")},
	{"get_allocated_size",{P,P,I}}, -- 3.20
	{"get_focus_on_click",{P},B}, -- 3.20
	{"set_focus_on_click",{P,B}}, -- 3.20
	
-- Aliases to fix awkward overrides; ordinarily you will use one of these 4,
	{"set_font",{P,S},-routine_id("widget_set_font")},
	{"set_color",{P,P},-routine_id("widget_set_foreground")}, 
	{"set_foreground",{P,P},-routine_id("widget_set_foreground")},
	{"set_background",{P,P},-routine_id("widget_set_background")},
	{"modify_base",{P,I,P},-routine_id("widget_modify_base")},
	
-- Only use override versions below when you need to change the color
-- of a control in a state other than normal. Rarely used since themes
-- often disallow the use of stateful colors;
	{"override_background_color",{P,I,P},
	-routine_id("widget_override_background_color")},
	{"override_color",{P,I,P},
	-routine_id("widget_override_color")},
	
-- following new functions added in GTK4:
	{"get_width",{P},I},
	{"get_height",{P},I},
	{"measure",{P,I,I,I,I,I,I}}, 
	{"contains",{P,D,D},B},
	{"pick",{P,D,D},P},
	{"get_first_child",{P,P},P},
	{"get_last_child",{P,P},P},
	{"get_next_sibling",{P,P},P},
	{"get_prev_sibling",{P,P},P},
	{"get_template_child",{P,I,S},P},
	{"snapshot_child",{P,P,P}},
	{"insert_before",{P,P,P}},
	{"insert_after",{P,P,P}},
	{"get_cursor",{P},P,0,GdkCursor},
	{"set_cursor",{P,P}},
	{"set_cursor_from_name",{P,S}},
	{"get_clipboard",{P},P,0,GdkClipboard},
	{"get_primary_clipboard",{P},P,0,GdkClipboard},
"GtkWidget"}

	function widget_set_size_request(atom ctl, object x=0, object y=0)
	if string(x) then -- format was string form, e.g."200x100"
		x = split(x,'x') 
		y = to_number(x[2])
		x = to_number(x[1])
	end if
	gtk_func("gtk_widget_set_size_request",{P,I,I},{ctl,x,y})
	return 1
	end function
	
	function widget_get_font(atom x)
	 object layout = get(x,"layout")
	 object context = gtk_func("pango_layout_get_context",{P},{layout})
	 object descr = gtk_func("pango_context_get_font_description",{P},{context})
	 return gtk_str_func("pango_font_description_to_string",{P},{descr})
	end function

	function widget_get_allocation(atom obj)
	 atom al = allocate(32,1)
		gtk_func("gtk_widget_get_allocation",{P,P},{obj,al})
	 return peek4u({al,4})
	end function
	
	function widget_set_name(atom ctl, object name)
	 gtk_proc("gtk_widget_set_name",{P,P},{ctl,name})
	 integer x = find(ctl,vslice(registry,1))
	 if x > 0 then
		registry[x][4] = peek_string(name)
	 end if
	 return 1
	end function
	
	-- This allows specifying a font name, e.g. "Courier bold 12" as a string,
	-- instead of a pointer to a pango font description object;
	
	function widget_set_font(atom x, object fnt)
	  fnt = gtk_func("pango_font_description_from_string",{P},{fnt})
	  gtk_proc("gtk_widget_override_font",{P,P},{x,fnt})
	 return 1
	end function

	-- The functions below handle color conversion to/from rgba,
	-- as well as supplying easier-to-use method names for setting background
	-- and foreground. These methods are only used to set the colors of a widget
	-- in the NORMAL state, whereas if you want to set the colors in 
	-- some other state, such as mouse-over, etc, you use the original syntax:
	-- set(widget,"override background",STATE,"color")

	function widget_set_foreground(atom x, object c) -- alias 'color'
	 return widget_override_color(x,0,c)
	end function

	function widget_set_background(atom x, object c) -- alias 'background'
	  return widget_override_background_color(x,0,c)
	end function

	function widget_override_color(atom x, integer state=0, object c)
	 if atom(c) then
		c = text:format("#[:06X]",c)
	 end if
	 gtk_proc("gtk_widget_override_color",{P,I,P},{x,state,to_rgba(c)})
	return 1
	end function

	function widget_override_background_color(atom x, integer state=0, object c)
	 if atom(c) then
		c = text:format("#[:06X]",c)
	 end if
	 gtk_proc("gtk_widget_override_background_color",{P,I,P},{x,state,to_rgba(c)})
	 return 1
	end function

	function widget_modify_base(atom x, integer state, object c)
	if atom(c) then
		c = text:format("#[:06X]",c)
	end if
	gtk_proc("gtk_widget_modify_base",{P,I,P},{x,state,to_rgba(c)})
	return 1
	end function
	
widget[GtkContainer] =  {"gtk_container",
{GtkWidget,GtkBuildable,GObject},
	{"add",{P,P}},
	{"remove",{P,P}},
	{"check_resize",{P}},
	{"foreach",{P,P,P}},
	{"get_children",{P},X},
	{"get_path_for_child",{P,P},S},
	{"set_focus_child",{P,P}},
	{"get_focus_child",{P},P},
	{"set_focus_vadjustment",{P,P}},
	{"get_focus_vadjustment",{P},P,0,GtkAdjustment},
	{"set_focus_hadjustment",{P,P}},
	{"get_focus_hadjustment",{P},P,0,GtkAdjustment},
	{"child_type",{P},I},
	{"forall",{P,P,P}}, 
	{"set_border",{P,I},-routine_id("set_border")},
	{"set_border_width",{P,I}}, -- deprecated in GTK4;
	{"get_border_width",{P},I}, -- deprecated in GTK4;
	{"propagate_draw",{P,P,P}},
	{"child_notify",{P,P,S}},
	{"child_notify_by_pspec",{P,P,P}}, -- 3.18
	{"class_install_child_properties",{P,I,P}}, -- 3.18
"GtkContainer"}

ifdef GTK4 then -- border width property is deprecated;
elsedef
	function set_border(atom ctl, integer w)
	ifdef GTK4 then
		Warn(,,"Border width","Deprecated in GTK4")
	elsedef
		gtk_proc("gtk_container_set_border_width",{P,I},{ctl,w})
	 end ifdef
	 return 1
	end function
end ifdef
	
widget[GdkKeymap] = {"gdk_keymap",
{GObject},
	{"new",{},-routine_id("new_keymap")},
	{"get_default",{},-routine_id("new_keymap")},
	{"get_for_display",{P},P,0,GdkKeymap},
	{"get_capslock_state",{P},B},
	{"get_numlock_state",{P},B},
	{"get_modifier_state",{P},I},
	{"get_direction",{P},I},
	{"have_bidi_layouts",{P},B},
	{"lookup_key",{P,P},I},
	{"get_scroll_lock_state",{P,B}},
"GdkKeymap"}

	function new_keymap(atom disp=0) 
	 if disp=0 then
		return gtk_func("gdk_keymap_get_default")
	 else
		return gtk_func("gdk_keymap_get_for_display",{P},P)
	 end if
	end function

widget[GtkBin] = {"gtk_bin", 
{GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"get_child",{P},P},
"GtkBin"}

widget[GtkBox] = {"gtk_box",
{GtkContainer,GtkWidget,GtkOrientable,GtkBuildable,GObject},
	{"new",{I,I},P}, 
	{"pack_start",{P,P,B,B,I}}, 
	{"pack_end",{P,P,B,B,I}},
	{"set_homogeneous",{P,B}},
	{"get_homogeneous",{P},B},
	{"set_spacing",{P,I}},
	{"get_spacing",{P},I},
	{"reorder_child",{P,P,I}}, 
	{"query_child_packing",{P,P,B,B,I,I}},
	{"set_child_packing",{P,P,B,B,I,I}}, 
	{"set_baseline_position",{P,I}},
	{"get_baseline_position",{P},I},
	{"get_center_widget",{P},P,0,GtkWidget}, -- 3.12
	{"set_center_widget",{P,P}}, -- 3.12
"GtkBox"}

widget[GtkButtonBox] = {"gtk_button_box",
{GtkBox,GtkContainer,GtkWidget,GtkBuilder,GtkOrientable,GObject},
	{"new",{I},P},
	{"set_layout",{P,I}},
	{"get_layout",{P},I},
	{"set_child_secondary",{P,P,B}},
	{"get_child_secondary",{P,P},B},
	{"set_child_non_homogeneous",{P,P,B}},
	{"get_child_non_homogeneous",{P,P},P},
"GtkButtonBox"}

widget[GtkWindowGroup] = {"gtk_window_group",
{GObject},
	{"new",{},P},
	{"add_window",{P,P}},
	{"remove_window",{P,P}},
	{"list_windows",{P},X,0,GList},
	{"get_current_grab",{P},P,0,GtkWidget},
	{"get_current_grab_device",{P,P},P,0,GtkWidget},
"GtkWindowGroup"}

widget[GtkWindow] = {"gtk_window",
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{I},P},
	{"set_title",{P,S}},
	{"get_title",{P},S},
	{"set_resizable",{P,B}},
	{"get_resizable",{P},B},
	{"get_size",{P,I,I}},
	{"set_size",{P,P},-routine_id("win_set_size")}, 
	{"set_position",{P,P},-routine_id("win_set_pos")}, 
	{"set_default",{P,P}},
	{"set_default_size",{P,I,I}},
	{"get_default_size",{P,I,I}},
	{"get_position",{P,I,I}},
	{"add_accel_group",{P,P}},
	{"remove_accel_group",{P,P}},
	{"activate_focus",{P},B},
	{"activate_default",{P},B},
	{"set_modal",{P,B}},
	{"get_modal",{P},B},
	{"set_gravity",{P,I}},
	{"get_gravity",{P},I},
	{"set_transient_for",{P,P}},
	{"get_transient_for",{P},P,0,GtkWindow},
	{"set_attached_to",{P,P}},
	{"get_attached_to",{P},P,0,GtkWidget},
	{"set_destroy_with_parent",{P,B}},
	{"get_destroy_with_parent",{P},B},
	{"set_hide_titlebar_when_maximized",{P,B}},
	{"get_hide_titlebar_when_maximized",{P},B},
	{"set_screen",{P,P}},
	{"get_screen",{P},P,0,GdkScreen},
	{"is_active",{P},B},
	{"list_toplevels",{P},X,0,GSList},
	{"has_toplevel_focus",{P},B},
	{"add_mnemonic",{P,I,P}},
	{"remove_mnemonic",{P,I,P}},
	{"set_mnemonics_visible",{P,B}},
	{"get_mnemonics_visible",{P},B},
	{"mnemonic_activate",{P,I,I},B},
	{"activate_key",{P,P},B},
	{"propagate_key_event",{P,P},B},
	{"get_focus",{P},P,0,GtkWidget},
	{"set_focus",{P,P}},
	{"set_focus_visible",{P,B}},
	{"get_focus_visible",{P},B},
	{"get_default_widget",{P},P,0,GtkWidget},
	{"set_default",{P,P}},
	{"present",{P}},
	{"present_with_time",{P,P}},
	{"iconify",{P}},
	{"deiconify",{P}},
	{"stick",{P}},
	{"unstick",{P}},
	{"maximize",{P}},
	{"unmaximize",{P}},
	{"fullscreen",{P}},
	{"unfullscreen",{P}},
	{"set_keep_above",{P,B}},
	{"set_keep_below",{P,B}},
	{"begin_resize_drag",{P,I,I,I,I,I}},
	{"begin_move_drag",{P,I,I,I,I}},
	{"set_decorated",{P,B}},
	{"get_decorated",{P},B},
	{"set_deletable",{P,B}},
	{"get_deletable",{P},B},
	{"set_mnemonic_modifier",{P,I}},
	{"get_mnemonic_modifier",{P},I},
	{"set_type_hint",{P,I}},
	{"get_type_hint",{P},I},
	{"set_skip_taskbar_hint",{P,B}},
	{"get_skip_taskbar_hint",{P},B},
	{"set_skip_pager_hint",{P,B}},
	{"get_skip_pager_hint",{P},B},
	{"set_urgency_hint",{P,B}},
	{"get_urgency_hint",{P},B},
	{"set_accept_focus",{P,B}},
	{"get_accept_focus",{P},B},
	{"set_focus_on_map",{P,B}},
	{"get_focus_on_map",{P},B},
	{"set_startup_id",{P,S}},
	{"set_role",{P,S}},
	{"get_role",{P},S},
	{"get_icon",{P},P,0,GdkPixbuf},
	{"get_icon_name",{P},S},
	{"get_icon_list",{P},P,0,GList},
	{"get_default_icon_list",{P},X,0,GList},
	{"get_group",{P},P,0,GtkWindowGroup},
	{"has_group",{P},B},
	{"get_window_type",{P},I},
	{"move",{P,I,I}},
	{"resize",{P,I,I}},
	{"resize_to_geometry",{P,I,I}},
	{"set_has_resize_grip",{P,B}},
	{"get_has_resize_grip",{P},B},
	{"resize_grip_is_visible",{P},B}, -- deprecated 3.14
	{"get_resize_grip_area",{P,P},B}, -- deprecated 3.14
	{"set_titlebar",{P,P}}, -- 3.10
	{"get_titlebar",{P},P,0,GtkWidget}, -- 3.16
	{"set_icon",{P,P},-routine_id("win_set_icon")},
	{"restore",{P},-routine_id("win_restore")}, -- see below;
	{"close",{P}}, -- 3.10
	{"is_maximized",{P},B}, -- 3.12
	{"set_interactive_debugging",{B}}, -- 3.14
	{"set_auto_startup_notification",{P,B}},
	{"fullscreen_on_monitor",{P,P,I}}, -- 3.18
	{"set_application",{P,P}},
	{"get_application",{P},P,0,GtkApplication},
	{"set_cursor",{P,P},-routine_id("win_set_cursor")},
	
	-- following are GTK4:
	{"get_cursor",{P},P,0,GdkCursor},
	{"set_cursor",{P,P}},
	{"set_cursor_from_name",{P,S}},
	{"get_clipboard",{P},P,0,GdkClipboard},
	{"get_primary_clipboard",{P},P,0,GdkClipboard},
	{"get_width",{P},I},
	{"get_height",{P},I},
	{"get_clip",{P,P}},
	{"contains",{P,D,D},B},
	{"pick",{P,D,D},P},
	{"set_display",{P,P}},	
	
"GtkWindow"}

	function win_set_size(atom win, object size) 
	-- allow for "WxH" format as well as {w,h} format;
	  if match("x",size) then size = split(size,'x') end if
	  if match("{",size) = 1 and match("}",size) = length(size) then
		size = size[2..$-1]
		size = split(size,',')
	 end if
	  set(win,"default_size",size[1],size[2])
	 return 1
	end function
	
	function win_set_pos(atom win, object pos) -- e.g. GTK_WIN_POS_* enums
	    if integer(pos) then -- only one integer passed;
		gtk_proc("gtk_window_set_position",{P,I},{win,pos}) -- use original call;
		return 1
	    end if 
	    -- else position is WxH format, so call move instead;
	    if match("x",pos) then pos = split(pos,'x') end if
	    if match("{",pos) = 1 and match("}",pos) = length(pos) then
		pos = pos[2..$-1]
		pos = split(pos,',')
	    end if
	  set(win,"move",pos[1],pos[2])
	  return 1
	end function
	
	function win_set_cursor(atom win, object cursor)
	  atom gdkwin = get(win,"window")
	  cursor = create(GdkCursor,cursor)
	  set(gdkwin,"cursor",cursor)
	 return cursor
	end function
	
 -- this replaces a handy but deprecated GTK function which 
 -- restores a window to its original size after being resized 
 -- to fit larger contents;
   
	function win_restore(atom win)
	  set(win,"hide")
	  set(win,"unrealize")
	  gtk_proc("gtk_window_set_position",{P,I},{win,1})
	  set(win,"show")
	 return 1
	end function
	
 -- manages the creation of window icon from a variety of source formats.
 -- this makes life much easier for the programmer.
 
	function win_set_icon(object win, object icon)
	 object path 
	
	 if string(icon) then
		path = locate_file(icon)--display(path)
		if file_type(path) = 1 then
			gtk_proc("gtk_window_set_icon_from_file",{P,P},
				{win,allocate_string(path,1)})
			return 1
	   else
			gtk_proc("gtk_window_set_icon_name",{P,P},
				{win,allocate_string(icon,1)})
			return 1
		end if
	 end if
	
	 if sequence(icon) then
	gtk_proc("gtk_window_set_icon",{P,P},{win,xpm_to_pixbuf(icon)})
	 end if
	
	 if atom(icon) then
		if class_id(icon) = GtkImage then 
			icon = get(icon,"pixbuf") 
		end if
		if class_id(icon) = GdkPixbuf then
			gtk_proc("gtk_window_set_icon",{P,P},{win,icon})
		end if
		return 1
	 end if
	
	 return 0
	end function

widget[GtkMisc] = {"gtk_misc", -- deprecated 3.14
{GtkWidget,GtkBuildable,GObject},
	{"set_alignment",{P,F,F}},
	{"get_alignment",{P,F,F}},
	{"set_padding",{P,I,I}},
	{"get_padding",{P,I,I}},
"GtkMisc"}

widget[GtkLabel] = {"gtk_label",
{GtkMisc,GtkWidget,GtkBuildable,GObject},
	{"new",{S},P},
	{"new_with_mnemonic",{S},P,0,GtkLabel},
	{"set_text",{P,S}},
	{"set_value",{P,D,S},-routine_id("lbl_set_value")},
	{"get_value",{P,S},-routine_id("lbl_get_value")},
	{"get_text",{P},S},
	{"set_markup",{P,S}},
	{"set_text_with_mnemonic",{P,S}},
	{"set_markup_with_mnemonic",{P,S}},
	{"set_pattern",{P,S}},
	{"set_justify",{P,I}},
	{"get_justify",{P},I},
	{"get_attributes",{P},P,0,PangoAttrList},
	{"set_ellipsize",{P,I}},
	{"get_ellipsize",{P},I},
	{"set_width_chars",{P,I}},
	{"get_width_chars",{P},I},
	{"set_max_width_chars",{P,I}},
	{"get_max_width_chars",{P},I},
	{"set_line_wrap",{P,B}},
	{"get_line_wrap",{P},B},
	{"set_line_wrap_mode",{P,I}},
	{"get_layout_offsets",{P,I,I}},
	{"get_mnemonic_keyval",{P},I},
	{"set_selectable",{P,B}},
	{"get_selectable",{P},B},
	{"select_region",{P,I,I}},
	{"get_selection_bounds",{P,I,I},B},
	{"set_mnemonic_widget",{P,P}},
	{"get_mnemonic_widget",{P},P,0,GtkWidget},
	{"get_label",{P},S},
	{"get_layout",{P},P,0,PangoLayout},
	{"get_line_wrap_mode",{P},I},
	{"set_use_markup",{P,B}},
	{"get_use_markup",{P},B},
	{"set_use_underline",{P,B}},
	{"get_use_underline",{P},B},
	{"set_single_line_mode",{P,B}},
	{"get_single_line_mode",{P},B},
	{"set_angle",{P,D}},
	{"get_current_uri",{P},S},
	{"set_track_visited_links",{P,B}},
	{"get_track_visited_links",{P},B},
	{"set_lines",{P,I}}, -- 3.10
	{"get_lines",{P},I}, -- 3.10
	{"get_xalign",{P},F}, -- 3.16
	{"get_yalign",{P},F}, -- 3.16
	{"set_xalign",{P,F}}, -- 3.16
	{"set_yalign",{P,F}}, -- 3.16
"GtkLabel"}

	function lbl_set_value(atom lbl, atom val, object fmt) 
	  if fmt > 0 then fmt = peek_string(fmt) end if
	  if equal({48},fmt) then fmt = "[:6.2]" end if
	  set(lbl,"text",text:format(fmt,val)) -- convert atom to string for label;
	 return 1
	end function

	function lbl_get_value(atom lbl, object fmt="[,,.2.2]")
	 if atom(fmt) and fmt > 0 then fmt = peek_string(fmt) end if
	 return text:format(fmt,to_number(get(lbl,"text")))
	end function
	
widget[GtkImage] = {"gtk_image",
{GtkMisc,GtkWidget,GtkBuildable,GObject},
	{"new",{P,I,I,I},-routine_id("newImage")},
	{"set_image",{P,P,P},-routine_id("setImage")}, -- not a gtk func, a EuGTK convenience
	{"set_from_file",{P,S}},
	{"set_from_pixbuf",{P,P}},
	{"set_from_icon_name",{P,S,I}}, -- GTK_ICON_SIZE_* (GTK4 will ignore size arg)
	{"set_from_animation",{P,P}},
	{"set_from_gicon",{P,P,I}},
	{"set_from_resource",{P,S}},
	{"set_from_surface",{P,P}}, -- 3.10
	{"clear",{P}},
	{"set_pixel_size",{P,I}},
	{"get_pixel_size",{P},I},
	{"get_pixbuf",{P},P,0,GdkPixbuf}, 
	{"get_animation",{P},P,0,GdkPixbufAnimation},
	{"get_storage_type",{P},I},
	{"get_icon_name",{P},-routine_id("img_get_icon_name")},
	
     -- following are GTK4:
	{"set_icon_size",{P,P}},
	{"get_icon_size",{P},P,0,GtkIconSize},
	{"get_surface",{P},P}, -- cairo_surface_t *
	{"get_texture",{P},P,0,GdkTexture},
	{"set_from_texture",{P,P}},
	
"GtkImage"}

-----------------------------------------------------
 -- create an image from a variety of source formats
 ----------------------------------------------------
	function newImage(object icon=0, integer size=6, integer w=0, integer h=0)

	 if atom(icon) then
	   if icon = 0  then
		return gtk_func("gtk_image_new") -- just a blank image requested;
	   else
	   switch class_id(icon) do
		case GdkPixbuf then
			icon = gtk_func("gtk_image_new_from_pixbuf",{P},{icon})
		case GIcon then
			icon = gtk_func("gtk_image_new_from_gicon",{P,I},{icon,size})
		case CairoSurface_t then
			icon = gtk_func("gtk_image_new_from_surface",{P},{icon})
		case else -- do nothing
	   end switch
	   end if
	   return icon
	 end if
	 
	 object theme, icon_info
	 
	 if string(icon) then 
	 
		if begins("gtk-",icon) then -- from stock (deprecated)
			if size = 0 then size = 6 end if
			return gtk_func("gtk_image_new_from_icon_name",{P,I},
				{allocate_string(icon,1),size}) -- size is a GTK_ICON_SIZE_ enum;
		end if
		
		if file_exists(canonical_path(icon)) then -- from file
			icon = canonical_path(icon)
			if h = 0 and w = 0 then -- return at natural size;
				return gtk_func("gtk_image_new_from_file",{P},
					{allocate_string(icon,1)})
			else
				icon = newPixbuf(icon,w,h,size) -- resize it;
				return gtk_func("gtk_image_new_from_pixbuf",{P},{icon})
			end if
		end if
	
		if file_exists(locate_file(icon)) then -- from file
			icon = locate_file(icon)
			if h = 0 and w = 0 then -- return at natural size;
				return gtk_func("gtk_image_new_from_file",{P},
					{allocate_string(icon,1)})
			else
				icon = newPixbuf(icon,w,h,size) -- resize it;
				return gtk_func("gtk_image_new_from_pixbuf",{P},{icon})
			end if
		end if
		
		if size < 7 then 
			icon = gtk_func("gtk_image_new_from_icon_name",{P,I},{icon,size})
		else 	
			theme = create(GtkIconTheme) -- get current theme;
			icon_info = get(theme,"lookup icon",icon,size) -- get icon details;
			icon = get(icon_info,"load icon") -- load selected icon;
			return create(GtkImage,icon)
		end if
			
	 end if

	 return icon
	end function

	-----------------------------------------------------------------------------------
	function setImage(atom img, object icon, integer size=0)
	-----------------------------------------------------------------------------------

	 if size = 0 then 
		size = get(img,"pixel size") 
	 end if
	
	 if class_id(img) =  GdkPixbuf then
		set(img,"from pixbuf",icon,size)
	    return img 
	 end if
	 
	 if string(icon) then 

		if file_exists(canonical_path(icon)) then -- from file
			set(img,"from file",icon)
			set(img,"pixel size",size)
			return img
		end if
		
		if begins("gtk-",icon) then -- from stock (deprecated)
			set(img,"from stock",icon)
			return img
		end if
		
		set(img,"from icon name",icon)
		return img
		
	 end if
	 return img
	end function	
	
	function img_get_icon_name(atom img)
	 atom name = allocate(8), size = allocate(8)
	 atom fn = define_proc("gtk_image_get_icon_name",{P,P,P})
	 c_proc(fn,{img,name,size})
	 if name > 0 then
	   return {peek_string(peek4u(name)),peek4u(size)}
	 else return -1
	 end if
	end function
	
widget[GdkCursor] = {"gdk_cursor",
{GObject},
	{"new",{P,P,P},-routine_id("newCursor")},
	{"get_display",{P},P,0,GdkDisplay},
	{"get_image",{P},P,0,GdkPixbuf},
	{"get_surface",{P,D,D},P,0,CairoSurface_t},
	{"get_cursor_type",{P},I},
"GdkCursor"}

 -- manages cursor creation from a variety of sources
	function newCursor(object a, object b=0, integer c=0)
	 atom disp = gtk_func("gdk_display_get_default") 
	
	 if string(a) then
		return gtk_func("gdk_cursor_new_from_name",{P,P},{disp,allocate_string(a,1)})
	 end if
	
	 if class_id(a) = GdkPixbuf then
		return gtk_func("gdk_cursor_new_from_pixbuf",{P,P,I,I},{disp,a,b,c})
	 end if
	
	 if class_id(a) = CairoSurface_t then
		return gtk_func("gdk_cursor_new_from_surface",{P,P,D,D},{disp,a,b,c})
	 end if
	
	 if integer(a) then
		ifdef GTK4 then Error(,,"Cursor","needs fixing") 
		elsedef
		return gtk_func("gdk_cursor_new_for_display",{P,I},{disp,a})
		end ifdef
	 end if
	
	end function

widget[GdkWindow] = {"gdk_window",
{GObject},
	{"new",{P,P,I},P},
	{"set_title",{P,S}},
	{"destroy",{P}},
	{"get_width",{P},I},
	{"get_height",{P},I},
	{"get_position",{P,I,I}},
	{"get_device_position",{P,P,P,P,P},P,0,GdkWindow},
	{"get_device_position_double",{P,P,P,P,P},P,0,GdkWindow},
	{"get_origin",{P,I,I}},
	{"get_parent",{P},P,0,GdkWindow},
	{"get_toplevel",{P},P,0,GdkWindow},
	{"get_children",{P},A,0,GList},
	{"get_children_with_user_data",{P,P},A,0,GList},
	{"peek_children",{P},P,0,GList},
	{"get_events",{P},I},
	{"set_events",{P,I}},
	{"set_icon_name",{P,S}},
	{"set_transient_for",{P,P}},
	{"get_root_origin",{P,I,I}},
	{"get_root_coords",{P,I,I,P,P}},
	{"get_frame_extents",{P,P}},
	{"set_modal_hint",{P,B}},
	{"get_modal_hint",{P},B},
	{"set_type_hint",{P,I}},
	{"get_type_hint",{P},I},
	{"get_window_type",{P},I},
	{"get_display",{P},P,0,GdkDisplay},
	{"get_screen",{P},P,0,GdkScreen},
	{"get_visual",{P},P,0,GdkVisual},
	{"show",{P}},
	{"show_unraised",{P}},
	{"hide",{P}},
	{"is_destroyed",{P},B},
	{"is_visible",{P},B},
	{"is_viewable",{P},B},
	{"is_input_only",{P},B},
	{"is_shaped",{P},B},
	{"set_composited",{P,B}}, -- deprecated 3.16
	{"get_composited",{P},B}, -- deprecated 3.16
	{"set_opacity",{P,D}},
	{"set_cursor",{P,P}},
	{"get_cursor",{P},P},
	{"get_state",{P},I},
	{"withdraw",{P}},
	{"iconify",{P}},
	{"deiconify",{P}},
	{"stick",{P}},
	{"unstick",{P}},
	{"maximize",{P}},
	{"unmaximize",{P}},
	{"fullscreen",{P}},
	{"unfullscreen",{P}},
	{"set_fullscreen_mode",{P,I}},
	{"get_fullscreen_mode",{P},I},
	{"set_opacity",{P,D}},
	{"scroll",{P,I,I}},
	{"move_region",{P,P,I,I}},
	{"shape_combine_region",{P,P,I,I}},
	{"set_child_shapes",{P}},
	{"merge_child_shapes",{P}},
	{"input_shape_combine_region",{P,P,I,I}},
	{"set_child_input_shapes",{P}},
	{"merge_child_input_shapes",{P}},
	{"get_geometry",{P,I,I,I,I}},
	{"set_background_rgba",{P,P}},
	{"set_fullscreen_mode",{P,I}},
	{"get_fullscreen_mode",{P},I},
	{"get_scale_factor",{P},I},
	{"set_opaque_region",{P,P}},
	{"get_effective_parent",{P},P,0,GdkWindow},
	{"get_effective_toplevel",{P},P,0,GdkWindow},
	{"beep",{}},
	{"focus",{P,I}},
	{"restack",{P,P,B}},
	{"raise",{P}},
	{"lower",{P}},
	{"set_keep_above",{P,B}},
	{"set_keep_below",{P,B}},
	{"reparent",{P,P,I,I}},
	{"ensure_native",{P},B},
	{"has_native",{P},B},
	{"register_dnd",{P}},
	{"move",{P,I,I}},
	{"scroll",{P,I,I}},
	{"resize",{P,I,I}},
	{"move_resize",{P,I,I,I,I}},
	{"move_region",{P,P,I,I}},
	{"begin_resize_drag",{P,I,I,I,I,I}},
	{"begin_resize_drag_for_device",{P,I,P,I,I,I,I}},
	{"begin_move_drag",{P,I,I,I,I}},
	{"begin_move_drag_for_device",{P,P,I,I,I,I}},
	{"show_window_menu",{P,P},B},
	{"create_gl_context",{P,P},P,0,GdkGLContext}, -- 3.16
	{"mark_paint_from_clip",{P,P}}, -- 3.16
	{"get_clip_region",{P},P,0,CairoRegion_t},
	{"begin_paint_rect",{P,P}},
	{"begin_paint_region",{P,P}},
	{"end_paint",{P}},
	{"set_opaque_region",{P,P}},
	{"get_visible_region",{P},P,0,CairoRegion_t},
	{"set_invalidate_handler",{P,P}},
	{"invalidate_rect",{P,P,B}},
	{"invalidate_region",{P,P,B}},
	{"invalidate_maybe_recurse",{P,P,P,P}},
	{"get_update_area",{P},P,0,CairoRegion_t},
	{"freeze_updates",{P}},
	{"thaw_updates",{P}},
	{"process_all_updates",{P}},
	{"process_updates",{P,B}},
	{"get_frame_clock",{P},P,0,GdkFrameClock},
	{"set_user_data",{P,P}},
	{"get_user_data",{P,P}},
	{"set_override_redirect",{P,B}},
	{"set_accept_focus",{P,B}},
	{"get_accept_focus",{P},B},
	{"set_focus_on_map",{P,B}},
	{"get_focus_on_map",{P},B},
	{"add_filter",{P,P,P}},
	{"remove_filter",{P,P,P}},
	{"set_background_pattern",{P,P}},
	{"get_background_pattern",{P},P,0,CairoPattern_t},
	{"set_geometry_hints",{P,P,I}},
	{"set_functions",{P,I}},
	{"get_pass_through",{P},B},
	{"set_pass_through",{P,B}},
	{"create_gl_context",{P,P},P,0,GdkGLContext},
	{"mark_paint_from_clip",{P,P}},
	{"new_toplevel",{P,I,I},P}, -- GDK4
	{"new_popup",{P,P},P}, -- GDK4
	{"new_temp",{P},P}, -- GDK4
	{"new_child",{P,P},P}, -- GDK4
	{"create_vulcan_context",{P,P},P,0,GdkVulkanContext}, -- GDK4
"GdkWindow"}

widget[GdkVulkanContext] = {"gdk_vulkan_context",
{GObject},
	{"new",{},P},
"GdkVulkanContext"}

widget[GdkPixbuf] = {"gdk_pixbuf",
{GObject},
	{"new",{P,I,I,I},-routine_id("newPixbuf")},
	{"get_from_window",{P,I,I,I,I},P,0,GdkPixbuf},
	{"get_from_surface",{P,I,I,I,I},P,0,GdkPixbuf},
	{"flip",{P,I},P,0,GdkPixbuf},
	{"rotate_simple",{P,I},P,0,GdkPixbuf},
	{"scale_simple",{P,I,I,I},P,0,GdkPixbuf},
	{"add_alpha",{P,B,I,I,I},P,0,GdkPixbuf},
	{"copy",{P},P,0,GdkPixbuf},
	{"copy_area",{P,I,I,I,I,P,I,I}},
	{"apply_embedded_orientation",{P},P,0,GdkPixbuf},
	{"fill",{P,P}},
	{"add_alpha",{P,B,I,I,I},P,0,GdkPixbuf},
	{"get_n_channels",{P},I},
	{"get_has_alpha",{P},B},
	{"get_colorspace",{P},I},
	{"get_bits_per_sample",{P},I},
	{"get_pixels",{P},P},
	{"get_pixels_with_length",{P,I},P},
	{"get_width",{P},I},
	{"get_height",{P},I},
	{"get_size",{P},-routine_id("getPixbufSize")},
	{"get_rowstride",{P},I},
	{"get_byte_length",{P},I},
	{"get_option",{P,S},S},
	{"set_option",{P,S,S},B},
	{"remove_option",{P,S},B},
	{"copy_options",{P,P},B},
	{"saturate_and_pixelate",{P,P,F,B},0,GdkPixbuf},
	{"composite_color_simple",{}},-- Cannot implement, use gtk_func if required.
	{"save",{P,P,P,P},-routine_id("pb_save")},
	{"get_file_info",{P,S},-routine_id("pb_get_file_info")},
	{"get_format",{P,S},-routine_id("pb_get_format")},
"GdkPixbuf"}

 -----------------------------------------------
 -- create a pixbuf from a variety of sources --
 -----------------------------------------------
 
	function newPixbuf(object name, integer w=0, integer h=0, atom ratio=0)
	-----------------------------------------------------------------------
	atom err = allocate(32,1) err = 0
	object path=allocate_string("gtk-missing-image",1)
	object pix = 0

	if string(name) then
	
		path = canonical_path(locate_file(name)) 

		if file_exists(path) then -- it's a file;
			path = allocate_string(path,1)
			goto "build"
		end if
		
		if has_icon(name) then -- it's a theme icon;
			path = icon_info(name) 
			if string(path[3]) then 
				path = allocate_string(path[3],1)
			else
				path = "!"
			end if
			goto "build"
		else return 0
		end if 
		
	end if -- string name;

	label "build"
		
	if h = 0 and w = 0 then -- return at original size;
		pix = gtk_func("gdk_pixbuf_new_from_file",{P,P},{path,err})
		ifdef PIXBUF then 
			display("PIXBUF: [] (using at original size)",{peek_string (path)}) 
		end ifdef
	
	else -- if one or other dimension given, scale it, otherwise size it;
		if w > 0 and h = 0 then h = -1 end if
		if w = 0 and h > 0 then w = -1 end if
		ifdef PIXBUF then display("PIXBUF: [] SCALED []x[] ratio: []",
			{peek_string(path),w,h,ratio}) 
		end ifdef
		pix = gtk_func("gdk_pixbuf_new_from_file_at_scale",
			{P,I,I,B,P},{path,w,h,ratio,err})
	end if

	return pix
	end function

 -------------------------------------------------------------------------------
 -- save a pixbuf in various formats based on file extension(.png, .jpg, etc) --
 -------------------------------------------------------------------------------
	function pb_save(atom handle, object fn, object ft, object params = 0)
		if string(fn) then fn = allocate_string(fn,1) end if
		if string(ft) then ft = allocate_string(ft,1) end if
		if string(params) then
			params = split(params,'=')
			for i = 1 to length(params) do
				params[i] = allocate_string(params[i],1)
			end for
		end if

	atom err = allocate(8,1) err = 0
	if atom(params) then 
		return gtk_func("gdk_pixbuf_save",{P,P,P,P,P},{handle,fn,ft,err,0})
	else
		return gtk_func("gdk_pixbuf_save",{P,P,P,P,P,P,P},
			{handle,fn,ft,err,params[1],params[2],0})
	end if
	end function
 
 -- pixbuf utilities;
 
	function getPixbufSize(object pb)
	return {get(pb,"width"),get(pb,"height")}
	end function
	
	function pb_get_file_info(atom pb, object name)
		atom w = allocate(8,1), h = allocate(8,1)
		object fmt = gtk_func("gdk_pixbuf_get_file_info",{P,P,P},
		{name,w,h})
	return {fmt,peek4u(w),peek4u(h)}
	end function
	
	function pb_get_format(atom pb, object name)   
	object fmt = pb_get_file_info(pb,name)
	return fmt
	end function
		
widget[GdkPixbufFormat] = {"gdk_pixbuf_format",
{GObject},
	{"get_name",{P},S},
	{"get_description",{P},S},
	{"get_mime_types",{P},A},
	-- {"extensions",{P},P}, -- error ?
	{"is_writable",{P},B},
	{"is_scalable",{P},B},
	{"is_disabled",{P},B},
	{"set_disabled",{P,B}},
	{"get_license",{P},S},
"GdkPixbufFormat"}

widget[GtkDialog] = {"gtk_dialog",
{GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"run",{P},I},
	{"get_action_area",{P},P,0,GtkBox}, -- deprecated 3.12
	{"get_content_area",{P},P,0,GtkBox},
	{"response",{P,I}},
	{"add_button",{P,S,I},P,0,GtkButton},
	{"add_action_widget",{P,P,I}},
	{"set_default_response",{P,I}},
	{"set_response_sensitive",{P,I,B}},
	{"get_response_for_widget",{P,P},I},
	{"get_widget_for_response",{P,I},P,0,GtkWidget},
	{"get_header_bar",{P},P,0,GtkContainer},-- GTK 3.12
"GtkDialog"}
   
widget[GtkMessageDialog] = {"gtk_message_dialog",
{GtkDialog,GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P,I,I,I,S,S},P},
	{"new_with_markup",{P,I,I,I,S,S},P},
	{"set_markup",{P,S}},
	{"set_image",{P,P}}, -- deprecated 3.12
	{"get_image",{P},P,0,GtkImage}, -- deprecated 3.12
	{"format_secondary_text",{P,S,S}},
	{"format_secondary_markup",{P,S,S}},
	{"get_message_area",{P},P,0,GtkContainer},
"GtkMessageDialog"}

widget[GtkSeparator] = {"gtk_separator",
{GtkWidget,GObject,GtkBuildable,GtkOrientable},
	{"new",{I},P},
"GtkSeparator"}

widget[GtkEditable] = {"gtk_editable",
{0},
	{"select_region",{P,I,I}},
	{"get_selection_bounds",{P,I,I}},
	{"insert_text",{P,S,I,I}},
	{"delete_text",{P,I,I}},
	{"get_chars",{P,I,I},S},
	{"cut_clipboard",{P}},
	{"copy_clipboard",{P}},
	{"paste_clipboard",{P}},
	{"delete_selection",{P}},
	{"set_position",{P,I}},
	{"get_position",{P},I},
	{"set_editable",{P,B}},
	{"get_editable",{P},B},
"GtkEditable"}

widget[GtkTextIter] = {"gtk_text_iter",
{GObject},
	{"get_buffer",{P},P,0,GtkTextBuffer},
	{"copy",{P},P,0,GtkTextIter},
	{"free",{P}},
	{"get_offset",{P},I},
	{"get_line",{P},I},
	{"get_line_offset",{P},I},
	{"get_line_index",{P},I},
	{"get_visible_line_index",{P},I},
	{"get_visible_line_offset",{P},I},
	{"get_char",{P},I},
	{"get_slice",{P,P},S},
	{"get_text",{P,P},S},
	{"get_visible_slice",{P,P},S},
	{"get_visible_text",{P,P},S},
	{"get_pixbuf",{P},P,0,GdkPixbuf},
	{"get_marks",{P},X,0,GSList},
	{"get_toggled_tags",{P,B},X,0,GSList},
	{"get_child_anchor",{P},P,0,GtkTextChildAnchor},
	{"begins_tag",{P,P},B},
	{"ends_tag",{P,P},B},
	{"toggles_tag",{P,P},B},
	{"has_tag",{P,P},B},
	{"get_tags",{P},X,0,GSList},
	{"editable",{P,B},B},
	{"can_insert",{P,B},B},
	{"starts_word",{P},B},
	{"ends_word",{P},B},
	{"inside_word",{P},B},
	{"starts_line",{P},B},
	{"ends_line",{P},B},
	{"starts_sentence",{P},B},
	{"ends_sentence",{P},B},
	{"inside_sentence",{P},B},
	{"is_cursor_position",{P},B},
	{"get_chars_in_line",{P},I},
	{"get_bytes_in_line",{P},I},
	{"get_attributes",{P,P},B},
	{"get_language",{P},P,0,PangoLanguage},
	{"is_end",{P},B},
	{"is_start",{P},B},
	{"forward_char",{P},B},
	{"backward_char",{P},B},
	{"forward_chars",{P,I},-routine_id("iterFwdChrs")},
	{"backward_chars",{P,I},B},
	{"forward_line",{P},B},
	{"backward_line",{P},B},
	{"forward_lines",{P,I},B},
	{"backward_lines",{P,I},B},
	{"forward_word_ends",{P,I},B},
	{"backward_word_starts",{P,I},B},
	{"forward_word_ends",{P},B},
	{"backward_word_start",{P},B},
	{"forward_cursor_position",{P},B},
	{"backward_cursor_position",{P},B},
	{"forward_cursor_positions",{P,I},B},
	{"backward_cursor_positions",{P,I},B},
	{"backward_sentence_start",{P},B},
	{"backward_sentence_starts",{P,I},B},
	{"forward_sentence_end",{P},B},
	{"forward_sentence_ends",{P,I},B},
	{"forward_visible_word_ends",{P,I},B},
	{"backward_visible_word_starts",{P,I},B},
	{"forward_visible_word_end",{P},B},
	{"backward_visible_word_start",{P},B},
	{"forward_visible_cursor_position",{P},B},
	{"backward_visible_cursor_position",{P},B},
	{"forward_visible_cursor_positions",{P,I},B},
	{"backward_visible_cursor_positions",{P,I},B},
	{"forward_visible_line",{P},B},
	{"backward_visible_line",{P},B},
	{"forward_visible_lines",{P,I},B},
	{"backward_visible_lines",{P,I},B},
	{"set_offset",{P,I}},
	{"set_line",{P,I}},
	{"set_line_offset",{P,I}},
	{"set_line_index",{P,I}},
	{"set_visible_line_index",{P,I}},
	{"set_visible_line_offset",{P,I}},
	{"forward_to_end",{P}},
	{"forward_to_line_end",{P},B},
	{"forward_to_tag_toggle",{P,P},B},
	{"backward_to_tag_toggle",{P,P},B},
	{"forward_find_char",{P,P,P,P},B},
	{"backward_find_char",{P,P,P,P},B},
	{"forward_search",{P,S,I,P,P,P},B},
	{"backward_search",{P,S,I,P,P,P},B},
	{"equal",{P,P},B},
	{"compare",{P,P},I},
	{"in_range",{P,P,P},B},
	{"order",{P,P}},
	{"starts_tag",{P,P},B}, -- 3.20
"GtkTextIter"}

	constant fwd_chrs = define_func("gtk_text_iter_forward_chars",{P,I})
	
	function iterFwdChars(atom iter, integer ct)
	if c_func(fwd_chrs,{iter,ct}) then
	   return iter
	else return -1
	end if
	end function
	
widget[GtkEntry] = {"gtk_entry",
{GtkWidget,GtkEditable,GtkCellEditable,GtkBuildable,GObject},
	{"new",{},P},
	{"get_buffer",{P},P,0,GtkEntryBuffer},
	{"set_buffer",{P,P}},
	{"set_text",{P,S}},
	{"set_value",{P,D},-routine_id("entry_set_value")}, -- not GTK, a convenience func;
	{"get_text",{P},S},
	{"get_value",{P},-routine_id("entry_get_value")}, -- not GTK, a convenience func;
	{"get_text_length",{P},I},
	{"get_text_area",{P,P}},
	{"set_visibility",{P,B}},
	{"get_visibility",{P},B},
	{"set_invisible_char",{P,I}},
	{"get_invisible_char",{P},I},
	{"unset_invisible_char",{P}},
	{"set_max_length",{P,I}},
	{"get_max_length",{P},I},
	{"set_activates_default",{P,B}},
	{"get_activates_default",{P},B},
	{"set_has_frame",{P,B}},
	{"get_has_frame",{P},B},
	{"set_width_chars",{P,I}},
	{"get_width_chars",{P},I},
	{"set_alignment",{P,F}},
	{"get_alignment",{P},F},
	{"set_placeholder_text",{P,S}}, -- GTK 3.2+
	{"get_placeholder_text",{P},S}, -- GTK 3.2+
	{"set_overwrite_mode",{P,B}},
	{"get_overwrite_mode",{P},B},
	{"get_layout",{P},P,0,PangoLayout},
	{"get_layout_offsets",{P,I,I}},
	{"set_completion",{P,P}},
	{"get_completion",{P},P,0,GtkEntryCompletion},
	{"set_progress_fraction",{P,D}},
	{"set_progress_pulse_step",{P,D}},
	{"progress_pulse",{P}},
	{"set_icon_from_stock",{P,I,S}}, -- deprecated 3.10
	{"set_icon_from_pixbuf",{P,I,P}},
	{"set_icon_from_icon_name",{P,I,S}},
	{"set_icon_from_gicon",{P,I,P}},
	{"get_icon_storage_type",{P,I},I},
	{"get_icon_pixbuf",{P,I},P,0,GdkPixbuf},
	{"get_icon_name",{P,I},S},
	{"get_icon_area",{P,I,I}},
	{"get_icon_gicon",{P,I},P,0,GIcon},
	{"set_icon_activatable",{P,I,B}},
	{"set_icon_sensitive",{P,I,B}},
	{"get_icon_at_pos",{P,I,I},I},
	{"set_icon_tooltip_text",{P,I,S}},
	{"get_icon_tooltip_text",{P,I},S},
	{"set_icon_tooltip_markup",{P,I,S}},
	{"get_icon_tooltip_markup",{P,I},S},
	{"set_tabs",{P,P}}, -- 3.10
	{"get_tabs",{P},P,0,PangoTabArray}, -- 3.10
	{"get_max_width_chars",{P},I}, -- 3.12
	{"set_max_width_chars",{P,I}}, -- 3.12
	{"im_context_filter_keypress",{P,I},B},
	{"grab_focus_without_selecting",{P}}, --3.16
	
	{"set_icon_from_texture",{P,I,P}}, -- GTK4
	{"get_icon_texture",{P,I},P,0,GdkTexture}, -- GTK4
	
"GtkEntry"}

	function entry_get_value(atom x) -- retrieve input text as a number;
	object txt = get(x,"text") 
	return to_number(txt)
	end function

	function entry_set_value(atom x, atom v) -- convert number to text equivalent;
	if integer(v) then
		set(x,"text",sprintf("%d",v))
	else
	set(x,"text",sprintf("%2.2f",v)) 
	end if
	return 1
	end function

widget[GtkSpinButton] = {"gtk_spin_button",
{GtkEntry,GtkWidget,GtkEditable,GtkCellEditable,GtkOrientable,GtkBuildable,GObject},
	{"set_adjustment",{P,P}},
	{"get_adjustment",{P},P,0,GtkAdjustment},
	{"set_digits",{P,I}},
	{"get_digits",{P},I},
	{"set_range",{P,D,D}},
	{"get_range",{P,D,D}},
	{"set_value",{P,D}},
	{"get_value",{P},-routine_id("getSpinVal")},
	{"get_value_as_int",{P},I},
	{"set_update_policy",{P,I}},
	{"set_numeric",{P,B}},
	{"get_numeric",{P},B},
	{"set_wrap",{P,B}},
	{"get_wrap",{P},B},
	{"spin",{P,I,D}},
	{"update",{P}},
	{"get_increments",{P,D,D}},
	{"set_snap_to_ticks",{P,B}},
	{"get_snap_to_ticks",{P},B},
	{"configure",{P,P,D,I}},
	{"new",{D,D,D},-routine_id("newSpinButton")},
	
	{"set_text",{P,S}}, -- GTK4
	{"get_text",{P},S}, -- GTK4
	{"set_width_chars",{P,I}}, -- GTK4
	{"get_width_chars",{P},I}, -- GTK4
	{"set_max_width_chars",{P,I}}, -- GTK4
	{"get_max_width_chars",{P},I}, -- GTK4
	
"GtkSpinButton"}

 -- create a spin button from an ajustment object or from a range of values
 
	function newSpinButton(atom a=0, atom b=0, atom c=0)
	----------------------------------------------------
	atom sb = 0
	if a+b+c = 0 then a = create(GtkAdjustment,0,0,100,1) end if
	if class_id(a) = GtkAdjustment then
		sb = gtk_func("gtk_spin_button_new",{P,D,I},{a,b,c})
	else
		sb = gtk_func("gtk_spin_button_new_with_range",{D,D,D},{a,b,c})
	end if
	return sb
	end function

	function getSpinVal(atom spin)
	------------------------------
	object range = get(spin,"range") 
	atom fn = define_func("gtk_spin_button_get_value",{P},D)
	atom val = c_func(fn,{spin})
	val = math:ensure_in_range(val,range) 
	if val < 0.0001 then val = 0 end if
	return val
	end function
	
widget[GtkOrientable] = {"gtk_orientable",
{GObject},
	{"set_orientation",{P,I}},
	{"get_orientation",{P},I},
"GtkOrientable"}

widget[GtkRange] = {"gtk_range",
{GtkWidget,GtkOrientable,GtkBuildable,GObject},
	{"set_fill_level",{P,D}},
	{"get_fill_level",{P},D},
	{"set_restrict_to_fill_level",{P,B}},
	{"get_restrict_to_fill_level",{P},B},
	{"set_show_fill_level",{P,B}},
	{"get_show_fill_level",{P},B},
	{"set_adjustment",{P,P}},
	{"get_adjustment",{P},P},
	{"set_inverted",{P,B}},
	{"get_inverted",{P},B},
	{"set_value",{P,D}},
	{"get_value",{P},D},
	{"set_increments",{P,D,D}},
	{"set_range",{P,D,D}},
	{"set_round_digits",{P,I}},
	{"get_round_digits",{P},I},
	{"set_lower_stepper_sensitivity",{P,I}},
	{"get_lower_stepper_sensitivity",{P},I},
	{"set_upper_stepper_sensitivity",{P,I}},
	{"get_upper_stepper_sensitivity",{P},I},
	{"set_flippable",{P,B}},
	{"get_flippable",{P},B},
	{"set_min_slider_size",{P,I}},
	{"get_min_slider_size",{P},I},
	{"get_slider_range",{P,I,I}},
	{"set_slider_size_fixed",{P,B}},
	{"get_slider_size_fixed",{P},B},
"GtkRange"}

widget[GtkScale] = {"gtk_scale",
{GtkRange,GtkWidget,GtkOrientable,GtkBuildable,GObject},
	{"set_digits",{P,I}},
	{"get_digits",{P},I},
	{"set_draw_value",{P,B}},
	{"get_draw_value",{P},B},
	{"set_has_origin",{P,B}},
	{"get_has_origin",{P},B},
	{"set_value_pos",{P,I}},
	{"get_value_pos",{P},I},
	{"get_layout",{P},P,0,PangoLayout},
	{"get_layout_offsets",{P,I,I}},
	{"add_mark",{P,D,I,S}},
	{"clear_marks",{P}},
	{"new",{P,P,P,P},-routine_id("newScale")},
"GtkScale"}

 -------------------------------------------
 -- create scale from range or adjustment --
 -------------------------------------------
	function newScale(integer orient, atom min=0, atom max=0, atom step=0)
	if min+max+step = 0 then
		return gtk_func("gtk_scale_new",{I,P},{orient,0})
	end if
	if class_id(min) = GtkAdjustment then
		return gtk_func("gtk_scale_new",{I,P},{orient,min})
	else
		return gtk_func("gtk_scale_new_with_range",{I,D,D,D},{orient,min,max,step})
	end if
	end function 

widget[GTimeout] = {"g_timeout",
{0},
	{"new",{I,P,P},-routine_id("newTimeout")},
	{"add",{I,P,P},-routine_id("newTimeout")},
	{"add_full",{I,I,P,P,P}},
	{"remove",{I},-routine_id("remTimeout")},
"GTimeout"}

	function newTimeout(atom ms, atom fn, atom data)
	return gtk_func("g_timeout_add",{I,P,P},{ms,fn,data})
	end function

	function remTimeout(atom t)
	return gtk_func("g_source_remove",{P},{t})        
	end function
		
widget[GIdle] = {"g_idle",
{0},
	{"new",{P,P},-routine_id("newIdle")},
	{"add",{P,P},-routine_id("newIdle")},
	{"add_full",{I,P,P,P}},
	{"remove_by_data",{P},-routine_id("remIdle2")},
"GIdle"}

	function newIdle(atom fn, atom data)
	return gtk_func("g_idle_add",{P,P},{fn,data})
	end function
	
	function remIdle2(atom data)
	return gtk_func("g_idle_remove_by_data",{P},{data})
	end function

widget[GNotification] = {"g_notification",
{0},
	{"new",{S},P},
	{"set_title",{P,S}},
	{"set_body",{P,S}},
	{"set_icon",{P,P}}, -- expects a GIcon;
	{"set_priority",{P,I}},  -- error?
	{"set_default_action",{P,S}},
	{"add_button",{P,S,S}},
	{"add_button_with_target_value",{P,S,S,I}},
	{"set_default_action_and_target_value",{P,S,I}},
"GNotification"}

widget[GCancellable] = {"g_cancellable",
{0},
	{"new",{},P},
"GCancellable"}

widget[GApplication] = {"g_application",
{0},
	{"new",{S,I},P},
	{"get_application_id",{P},S},
	{"set_application_id",{P,S}},
	{"id_is_valid",{P,S},B},
	{"get_inactivity_timeout",{P},I},
	{"set_inactivity_timeout",{P,I}},
	{"get_flags",{P},I},
	{"set_flags",{P,I}},
	{"get_resource_base_path",{P},S},
	{"set_resource_base_path",{P,S}},
	{"get_dbus_connection",{P},P},
	{"get_dbus_object_path",{P},S},
	{"get_is_registered",{P},B},
	{"get_is_remote",{P},B},
	{"register",{P,P,P},B},
	{"hold",{P}},
	{"release",{P}},
	{"quit",{P}},
	{"activate",{P}},
	{"open",{P,P,I,I}},
	{"send_notification",{P,S,P}},
	{"withdraw_notification",{P,S}},
	{"run",{P,I,P},I},
	{"add_main_option_entries",{P,P}},
	{"add_option_group",{P,P}},
	{"add_main_option",{P,S,S,I,I,S,S}},
	{"set_default",{P}},
	{"mark_busy",{P}},
	{"unmark_busy",{P}},
	{"get_is_busy",{P},B},
	{"bind_busy_property",{P,P,S}},
	{"unbind_busy_property",{P,P,S}},
"GApplication"}
	
widget[GAppInfo] = {"g_app_info",
{0},
	{"get_name",{P},S},
	{"get_display_name",{P},S},
	{"get_description",{P},S},
	{"get_executable",{P},S},
	{"get_commandline",{P},S},
	{"get_icon",{P},P,0,GIcon},
	{"launch",{P,P,P,P},B},
	{"supports_files",{P},B},
	{"supports_uris",{P},B},
	{"launch_uris",{P,P,P,P},B},
	{"should_show",{P},B},
	{"can_delete",{P},B},
	{"delete",{P},B},
	{"set_as_default_for_type",{P,S,P},B},
	{"set_as_default_for_extension",{P,S,P},B},
	{"add_supports_type",{P,S,P},B},
	{"can_remove_supports_type",{P},B},
	{"remove_supports_type",{P,S,P},B},
	{"get_all",{},P,0,GList},
"GAppInfo"}

widget[GFile] = {"g_file",
{GObject},
	{"new",{P},-routine_id("newGFile")},
	{"get_parse_name",{P},S},
	{"parse_name",{S},P},
	{"equal",{P,P},B},
	{"get_basename",{P},S},
	{"get_path",{P},S},
	{"get_uri",{P},S},
	{"get_parse_name",{P},S},
	{"get_parent",{P},P,0,GFile},
	{"has_parent",{P,P},B},
	{"get_child",{P,S},P,0,GFile},
	{"get_child_for_display_name",{P,S,P},P,0,GFile},
	{"has_prefix",{P,P},B},
	{"get_relative_path",{P,P},S},
	{"resolve_relative_path",{P,S},P,0,GFile},
	{"is_native",{P},B},
	{"has_uri_scheme",{P,S},B},
	{"get_uri_scheme",{P},S},
	{"read",{P,P,P},P,0,GFileInputStream},
"GFile"}

 ---------------------------------------
 -- create a GFile from a path or uri --
 ---------------------------------------
	function newGFile(object s)
	  if file_exists(canonical_path(locate_file(s))) then
		return gtk_func("g_file_new_for_path",{P},
		{allocate_string(canonical_path(locate_file(s)),1)})
	  else
		return gtk_func("g_file_new_for_uri",{P},
			{allocate_string(s,1)})
	  end if
	 return 0
	end function

widget[GIcon] = {"g_icon",
{GObject},
	{"hash",{P},I},
	{"equal",{P,P},B},
	{"to_string",{P},S},
	{"new_for_string",{S,P},P},
	{"new",{S},-routine_id("newGIcon")},
	{"serialize",{P},P},
	{"deserialize",{P},P,0,GIcon},
"GIcon"}

	function newGIcon(object s)
	if string(s) then s = allocate_string(s,1) end if
	return gtk_func("g_icon_new_for_string",{P,P},{s,0})
	end function

widget[GFileIcon] = {"g_file_icon",
{GIcon,GObject},
	{"new",{P},S},
	{"get_file",{P},S},
"GFileIcon"}

widget[GFileInfo] = {"g_file_info",
{GObject},
	{"new",{},P},
	{"get_name",{P},S},
	{"get_display_name",{P},S},
	{"get_edit_name",{P},S},
	{"get_icon",{P},P,0,GIcon},
	{"get_symbolic_icon",{P},P,0,GIcon},
	{"get_content_type",{P},S},
	{"get_size",{P},I},
	{"get_modification_time",{P,P}},
	{"get_symlink_target",{P},S},
	{"get_etag",{P},S},
	{"get_sort_order",{P},I},
	{"get_deletion_date",{P},P,0,GDateTime},
	{"set_is_hidden",{P,B}},
	{"set_is_symlink",{P,B}},
	{"set_name",{P,S}},
	{"set_display_name",{P,S}},
	{"set_edit_name",{P,S}},
	{"set_icon",{P,P}},
	{"set_symbolic_icon",{P,P}},
	{"set_content_type",{P,S}},
	{"set_size",{P,I}},
"GFileInfo"}

widget[GList] = {"g_list",
{GObject},
	{"new",{},-routine_id("newGList")},
	{"append",{P,P},P},
	{"length",{P},I},
	{"nth_data",{P,I},P},
"GList"}

	function newGList()
	  atom x = allocate(64) x = 0 -- keep;
	 return x
	end function

widget[GSList] = {"g_slist",
{GObject},
	{"length",{P},I},
"GSList"}

object temp_list 

  export function unpack_gs_str_list(atom gs)
	 if gs = 0 then return 1 end if
	 atom fn = call_back(routine_id("gs_str_each"))
	  temp_list = {}
	  gtk_proc("g_slist_foreach",{P,P,P},{gs,fn,0})
	 return temp_list
  end function

	export function gs_str_each(object x)
		  if x > 0 then
			temp_list = append(temp_list,peek_string(x))
		  end if
		return 1
	end function

	export function unpack_gs_atom_list(object gs)
		temp_list = {}
		atom fn = call_back(routine_id("gs_atom_each"))
		gtk_proc("g_slist_foreach",{P,P,P},{gs,fn,0})
	return temp_list
	end function

	function gs_atom_each(object x)
	temp_list = append(temp_list,x)
	return 1
	end function

widget[GdkDisplay] = {"gdk_display",
{GObject},
	{"new",{},-routine_id("newGdkDisplay")}, -- alias for get_default;
	{"open",{S},P,0,GdkDisplay},
	{"get_name",{P},S},
	{"get_n_screens",{P},I}, -- deprecated 3.10
	{"get_screen",{P,I},P,0,GdkScreen}, -- deprecated 3.20
	{"get_default_screen",{P},P,0,GdkScreen},
	{"get_device_manager",{P},P,0,GdkDeviceManager}, -- deprecated 3.20
	{"device_is_grabbed",{P,P},B},
	{"beep",{P}},
	{"sync",{P}},
	{"flush",{P}},
	{"close",{P}},
	{"is_closed",{P},B},
	{"get_event",{P},P,0,GdkEvent},
	{"peek_event",{P},P,0,GdkEvent},
	{"put_event",{P,P}},
	{"has_pending",{P},B},
	{"set_double_click_time",{P,I}},
	{"set_double_click_distance",{P,I}},
	{"supports_cursor_color",{P},B},
	{"supports_cursor_alpha",{P},B},
	{"get_default_cursor_size",{P},I},
	{"get_maximal_cursor_size",{P,I,I}},
	{"get_default_group",{P},P,0,GdkWindow},
	{"supports_selection_notification",{P},B},
	{"request_selection_notification",{P,P},B},
	{"supports_clipboard_persistence",{P},B},
	{"store_clipboard",{P,P,I,P,I}},
	{"supports_shapes",{P},B},
	{"supports_input_shapes",{P},B},
	{"supports_composite",{P},B}, -- deprecated 3.16
	{"get_app_launch_context",{P},P,0,GtkAppLaunchContext},
	{"notify_startup_complete",{P,S}},
	{"get_default_seat",{P},P,0,GdkSeat}, -- 3.20
	{"list_seats",{P},A}, -- 3.20
	{"get_monitor",{P,I},P,0,GdkMonitor}, -- 3.22
	{"get_n_monitors",{P},I}, -- 3.22
	{"get_primary_monitor",{P},P,0,GdkMonitor}, -- 3.22
	{"get_monitor_at_point",{P,I,I},P,0,GdkMonitor}, -- 3.22
	{"get_monitor_at_window",{P,P},P,0,GdkMonitor}, -- 3.22
"GdkDisplay"}

	function newGdkDisplay() -- alias;
	return gtk_func("gdk_display_get_default",{})
	end function
	
widget[GdkDevice] = {"gdk_device",
{GObject},
	{"get_name",{P},S}, -- 3.20
	{"get_vendor_id",{P},S}, -- 3.16
	{"get_product_id",{P},S}, -- 3.16
	{"get_source",{P},P,0,GdkInputSource}, 
	{"get_device_type",{P},I},
	{"get_display",{P},P,0,GdkDisplay},
	{"get_has_cursor",{P},B},
	{"get_n_axes",{P},I},
	{"get_n_keys",{P},I},
	{"warp",{P,P,I,I}},
	{"grab",{P,P,I,B,I,P,P},I},
	{"ungrab",{P,P}},
	{"get_state",{P,P,D,P}},
	{"get_position",{P,P,I,I}},
	{"get_position_double",{P,P,D,D}},
	{"get_window_at_position",{P,I,I},P,0,GdkWindow},
	{"get_window_at_position_double",{P,D,D},P,0,GdkWindow},
	{"get_history",{P,P,P,P,P,I},B},
	{"free_history",{P,I}},
	{"set_mode",{P,I},B},
	{"get_mode",{P},I},
	{"set_key",{P,I,I,I}},
	{"get_key",{P,I,I,I},B},
	{"get_axis",{P,D,I,D},B},
	{"list_axes",{P},A,0,GList},
	{"get_axis_value",{P,D,P,D},B},
	{"get_last_event_window",{P},P,0,GdkWindow},
	{"set_axis_use",{P,I,I}},
	{"get_axis_use",{P,I},I},
	{"get_associated_device",{P},P,0,GdkDevice},
	{"list_slave_devices",{P},A,0,GList},
	{"get_position",{P,P,I,I}},
"GdkDevice"}

ifdef GTK3 then
widget[GdkScreen] = {"gdk_screen", -- DEPRECATED in GTK4
{GdkDevice,GObject},
	{"new",{},-routine_id("newGdkScreen")}, -- alias for get_default;
	{"get_system_visual",{P},P,0,GdkVisual},
	{"get_rgba_visual",{P},P,0,GdkVisual},
	{"is_composited",{P},B},
	{"get_root_window",{P},P,0,GdkWindow},
	{"get_display",{P},P,0,GdkDisplay},
	{"get_number",{P},I},
	{"get_width",{P},I}, 
	{"get_height",{P},I},
	{"get_width_mm",{P},I},
	{"get_height_mm",{P},I},
	{"list_visuals",{P},P,0,GList},
	{"get_toplevel_windows",{P},P,0,GList},
	{"make_display_name",{P},S},
	{"get_n_monitors",{P},I},
	{"get_primary_monitor",{P},I},
	{"get_monitor_geometry",{P,I,P}},
	{"get_monitor_workarea",{P,I,P}},
	{"get_monitor_at_point",{P,I,I},I},
	{"get_monitor_at_window",{P,P},I},
	{"get_monitor_height_mm",{P,I},I},
	{"get_monitor_width_mm",{P,I},I},
	{"get_monitor_plug_name",{P,I},S},
	{"get_setting",{P,S,P},B},
	{"get_font_options",{P},P,0,CairoFontOptions},
	{"get_resolution",{P},D},
	{"set_resolution",{P,D}},
	{"get_active_window",{P},P,0,GdkWindow},
	{"get_window_stack",{P},P,0,GList},
"GdkScreen"}

	function newGdkScreen() -- alias;
	return gtk_func("gdk_screen_get_default",{})
	end function
	
end ifdef -- deprecated GTK4

widget[GdkVisual] = {"gdk_visual",
{GObject},
"GdkVisual"}

widget[GThemedIcon] =  {"g_themed_icon",
{GIcon,GObject},
	{"new",{S},P},
	{"new_with_default_fallbacks",{S},P},
	{"get_names",{P},P},
"GThemedIcon"}

widget[GtkThemedIcon] = {"gtk_themed_icon",
{GObject},
"GtkThemedIcon"}

widget[GEmblem] = {"g_emblem",
{GObject},
	{"new",{P},P},
	{"get_icon",{P},P,0,GIcon},
"GEmblem"}

widget[GEmblemedIcon] = {"g_emblemed_icon",
{GIcon,GObject},
	{"new",{P,P},P},
"GEmblemedIcon"}

widget[GdkSeat] = {"gdk_seat",
{GObject},
	{"get_display",{P},P,0,GdkDisplay},
	{"grab",{P,P,I,B,P,P,P,P},I}, -- 3.20
	{"ungrab",{P}}, -- 3.20
	{"get_capabilities",{P},P}, -- 3.20
	{"get_pointer",{P},P,0,GdkDevice}, -- 3.20
	{"get_keyboard",{P},P,0,GdkDevice}, -- 3.20
	{"get_slaves",{P,I},A}, -- 3.20
"GdkSeat"}

widget[GdkDeviceManager] = {"gdk_device_manager",
{GObject},
	{"new",{P},-routine_id("newDeviceManager")},
	{"get_display",{P},P,0,GdkDisplay},
	{"list_devices",{P,I},X,0,GList},
	{"get_client_pointer",{P},P,0,GdkDevice},
"GdkDeviceManager"}

	function newDeviceManager(atom disp=0)
	if disp = 0 then disp = gtk_func("gdk_display_get_default") end if
	return gtk_func("gdk_display_get_device_manager",{P},{disp})
	end function

widget[GtkAppChooser] = {"gtk_app_chooser",
{GtkWidget},
	{"get_app_info",{P},P,0,GAppInfo},
	{"get_content_type",{P},S},
	{"refresh",{P}},
"GtkAppChooser"}

widget[GtkAppChooserButton] = {"gtk_app_chooser_button",
{GtkComboBox,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GtkCellLayout,
 GtkCellEditable,GObject},
	{"new",{S},P},
	{"append_custom_item",{P,S,S,P}},
	{"append_separator",{P}},
	{"set_active_custom_item",{P,S}},
	{"set_show_default_item",{P,B}},
	{"get_show_default_item",{P},B},
	{"set_show_dialog_item",{P,B}},
	{"get_show_dialog_item",{P},B},
	{"set_heading",{P,S}},
	{"get_heading",{P},S},
"GtkAppChooserButton"}

widget[GMenu] = {"g_menu",
{GObject},
	{"new",{},P},
	{"append",{P,S,S}},
"GMenu"}

widget[GSettings] = {"g_settings",
{GObject},
	{"new",{S},P},
	{"set_value",{P,S,P},B},
	{"get_value",{P},P},
	{"get_user_value",{P,S},P},
"GSettings"}

widget[GtkApplication] = {"gtk_application",
{GApplication,GObject},
	{"new",{S,I},-routine_id("newApplication")},
	{"add_window",{P,P}},
	{"remove_window",{P,P}},
	{"get_windows",{P},A,0,GList},
	{"get_window_by_id",{P,I},P,0,GtkWindow},
	{"get_active_window",{P},P,0,GtkWindow},
	{"inhibit",{P,P,I,S},I},
	{"uninhibit",{P,I}},
	{"is_inhibited",{P,I},B},
	{"get_app_menu",{P},P,0,GMenuModel},
	{"set_app_menu",{P,P}},
	{"get_menubar",{P},P,0,GMenuModel},
	{"set_menubar",{P,P}},
	{"add_accelerator",{P,S,S,P}},
	{"remove_accelerator",{P,S,P}},
	{"run",{P},-routine_id("app_run")},
	{"activate",{P},-routine_id("app_activate")},
	{"get_accels_for_action",{P,S},V}, -- 3.12
	{"set_accels_for_action",{P,S,S}}, -- 3.12
	{"list_action_descriptions",{P},V},
	{"get_actions_for_accel",{P,S},V}, -- 3.14
	{"get_menu_by_id",{P,S},P,0,GMenu}, -- 3.14
	{"prefers_app_menu",{},B}, -- 3.14
"GtkApplication"}

	function app_activate(object x)
	  gtk_proc("g_application_activate",{P},{x})
	 return 1
	end function

	function app_run(object x)
	  gtk_proc("g_application_run",{P,I,P},{x,0,0})
	 return 1
	end function

	function newApplication(object id, object flags)
	  if string(id) then id = allocate_string(id,1) end if
	  if gtk_func("g_application_id_is_valid",{P},{id}) then
		return gtk_func("gtk_application_new",{P,I},{id,flags})
	  else
		crash("Error: invalid application id!")
	  end if
	 return 0
	end function
	
widget[GtkApplicationWindow] = {"gtk_application_window",
{GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P},P},
	{"set_show_menubar",{P,B}},
	{"get_show_menubar",{P},B},
	{"set_help_overlay",{P,P}}, -- 3.20
	{"get_help_overlay",{P},P,0,GtkShortcutsWindow}, -- 3.20
	{"get_id",{P},I},
"GtkApplicationWindow"}

-- Soon to be deprecated, but still used by Glade;
widget[GtkAlignment] = {"gtk_alignment",
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{F,F,F,F},P},
	{"set",{P,F,F,F,F}},
	{"get_padding",{P,I,I,I,I}},
	{"set_padding",{P,I,I,I,I}},
"GtkAlignment"}

widget[GtkAppLaunchContext] = {"gdk_app_launch_context",
{GdkAppLaunchContext,GObject},
	{"set_screen",{P,P}},
	{"set_desktop",{P,I}},
	{"set_timestamp",{P,I}},
	{"set_icon",{P,P}},
	{"set_icon_name",{P,S}},
"GtkAppLaunchContext"}

widget[GtkAspectFrame] = {"gtk_aspect_frame",
{GtkFrame,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{S,F,F,F,B},P},
	{"set",{P,F,F,F,B}},
"GtkAspectFrame"}

widget[GtkAssistant] = {"gtk_assistant",
{GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"set_current_page",{P,I}},
	{"get_current_page",{P},I},
	{"get_n_pages",{P},I},
	{"get_nth_page",{P,I},P,0,GtkWidget},
	{"prepend_page",{P,P},I},
	{"append_page",{P,P},I},
	{"insert_page",{P,P,I},I},
	{"remove_page",{P,I}},
	{"set_forward_page_func",{P,P,P,P}},
	{"set_page_type",{P,P,P}},
	{"get_page_type",{P,P},I},
	{"set_page_title",{P,P,S}},
	{"get_page_title",{P,P},S},
	{"set_page_complete",{P,P,B}},
	{"get_page_complete",{P,P},B},
	{"add_action_widget",{P,P}},
	{"remove_action_widget",{P,P}},
	{"update_buttons_state",{P}},
	{"commit",{P}},
	{"next_page",{P}},
	{"previous_page",{P}},
	{"get_page_has_padding",{P,P},B}, -- 3.18
	{"set_page_has_padding",{P,P,B}}, -- 3.18
"GtkAssistant"}

widget[GtkDrag] = {"gtk_drag",
{0},
	{"get_data",{P,P,P,P}},
	{"get_source_widget",{P},P,0,GtkWidget},
	{"highlight",{P}},
	{"unhighlight",{P}},
	{"begin_with_coordinates",{P,P,P,I,P,I,I},P},
	{"finish",{P,B,B,P}},
	{"set_icon_widget",{P,P,I,I}},
	{"set_icon_pixbuf",{P,P,I,I}},
	{"set_icon_surface",{P,P}},
	{"set_icon_name",{P,P,I,I}},
	{"set_icon_gicon",{P,P,I,I}},
	{"set_icon_default",{P}},
	{"check_threshold",{P,I,I,I,I},B},
	{"cancel",{P}}, -- 3.16
"GtkDrag"}

widget[GtkDragSource] = {"gtk_drag_source",
{GtkDrag},
	{"set",{P,I,P,I,I}},
	{"set_icon_pixbuf",{P,P}},
	{"set_icon_name",{P,S}},
	{"set_icon_gicon",{P,P}},
	{"unset",{P}},
	{"set_target_list",{P,P}},
	{"get_target_list",{P},P,0,GtkTargetList},
	{"add_text_targets",{P}},
	{"add_image_targets",{P}},
	{"add_uri_targets",{P}},
"GtkDragSource"}

widget[GtkDragDest] = {"gtk_drag_dest",
{GtkDrag},
	{"set",{P,I,P,I,I}},
	{"set_proxy",{P,P,I,B}},
	{"unset",{P}},
	{"find_target",{P,P,P},P},
	{"get_target_list",{P},P,0,GtkTargetList},
	{"set_target_list",{P,P}},
	{"add_text_targets",{P}},
	{"add_image_targets",{P}},
	{"add_uri_targets",{P}},
	{"set_track_motion",{P,B}},
	{"get_track_motion",{P},B},
"GtkDragDest"}

widget[GtkCssProvider] = {"gtk_css_provider",
{GObject},
	{"new",{P},-routine_id("new_css_provider")}, -- just gets default.
	{"get_default",{},P,0,GtkCssProvider},
	{"get_named",{S,S},P,0,GtkCssProvider},
	{"load_from_data",{P,S,I,P},B},
	{"load_from_file",{P,S,P},B},
	{"load_from_path",{P,S,P},B},
	{"load_from_resource",{P,S}}, -- 3.16
	{"to_string",{P},S},
"GtkCssProvider"}

 --------------------------------------------------
 -- initialize and load css provider in one call --
 --------------------------------------------------
	function new_css_provider(object name=0)
	 atom provider = gtk_func("gtk_css_provider_get_default")
	 atom style = create(GtkStyleContext)
	 atom screen = get(style,"screen")
	 register(provider,GtkCssProvider)

ifdef GTK4 then

	 if atom(name) then -- no params provided, just create a provider;
		set(style,"add provider for screen",screen,provider,800)
		return provider
	 end if
	
	if file_exists(canonical_path(locate_file(name))) then -- load from file;
		if gtk_func("gtk_css_provider_load_from_path",{P,P},
		{provider,allocate_string(canonical_path(locate_file(name)),1)}) then
		set(style,"add provider for screen",screen,provider,800) 
		return provider		  
		else 
			printf(1,"Error finding or parsing css from path: %s \n",
			{canonical_path(locate_file(name))})
		end if
	end if

	if string(name) then -- load from string;
		integer len = length(name)
		name = allocate_string(name,1)
		if gtk_func("gtk_css_provider_load_from_data",{P,P,I},
			{provider,name,len}) then
		set(style,"add provider for screen",screen,provider,800)
		end if
	end if
	
elsedef
	 atom err = allocate(64,1) err = 0

	 if atom(name) then -- no params provided, just create a provider;
		set(style,"add provider for screen",screen,provider,800)
		return provider
	 end if
	
	if file_exists(canonical_path(locate_file(name))) then -- load from file;
	   if gtk_func("gtk_css_provider_load_from_path",{P,P,P},
		{provider,allocate_string(canonical_path(locate_file(name)),1),err}) then
	      set(style,"add provider for screen",screen,provider,800) 
	      return provider		  
	  else 
	      printf(1,"Error finding or parsing css from path: %s \n",
		     {canonical_path(locate_file(name))})
	  end if
	end if

	if string(name) then -- load from string;
	   integer len = length(name)
	   name = allocate_string(name,1)
	   if gtk_func("gtk_css_provider_load_from_data",{P,P,I,P},
			{provider,name,len,err}) then
	      set(style,"add provider for screen",screen,provider,800)
	   end if
	end if
	
end ifdef
	
	 return provider
	end function
	
widget[GtkCssSection] = {"gtk_css_section",
{GObject},
	{"get_end_line",{P},I},
	{"get_end_position",{P},I},
	{"get_file",{P},P,0,GFile},
	{"get_parent",{P},P,0,GtkCssSection},
	{"get_section_type",{P},I},
	{"get_start_line",{P},I},
	{"get_start_position",{P},I},
	{"ref",{P},P},
	{"unref",{P}},
"GtkCssSection"}

widget[GtkStatusIcon] = {"gtk_status_icon", -- deprecated 3.14
{GObject},
	{"new",{},P,0,GObject},
	{"new_from_pixbuf",{P},P},
	{"new_from_file",{S},P},
	{"new_from_icon_name",{S},P},
	{"new_from_gicon",{P},P},
	{"set_from_pixbuf",{P,P}},
	{"set_from_file",{P,S}},
	{"set_from_icon_name",{P,S}},
	{"set_from_gicon",{P,P}},
	{"get_storage_type",{P},I},
	{"get_pixbuf",{P},P,0,GdkPixbuf},
	{"get_icon_name",{P},S},
	{"get_gicon",{P},P},
	{"get_size",{P},I},
	{"set_screen",{P,P}},
	{"get_screen",{P},P,0,GdkScreen},
	{"set_tooltip_text",{P,S}},
	{"get_tooltip_text",{P},S},
	{"set_tooltip_markup",{P,S}},
	{"get_tooltip_markup",{P},S},
	{"set_has_tooltip",{P,B}},
	{"get_has_tooltip",{P},P},
	{"set_title",{P,S}},
	{"get_title",{P},S},
	{"set_name",{P,S}},
	{"set_visible",{P,B}},
	{"get_visible",{P},B},
	{"is_embedded",{P},B},
	{"get_geometry",{P,P,P,I},B},
	{"get_x11_window_id",{P},I},
	{"position_menu",{P,P,I,I,B},-routine_id("si_position_menu")},
"GtkStatusIcon"}

	function si_position_menu(atom stat, atom menu, integer x, integer y, integer p)
	  atom fn = define_proc("gtk_status_icon_position_menu",{P,I,I,I,P})
	  c_proc(fn,{menu,x,y,p,stat}) -- menu and status_icon params are swapped;
	 return 1
	end function 
	 
widget[GtkOffscreenWindow] = {"gtk_offscreen_window",
{GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"get_surface",{P},P,0,CairoSurface_t},
	{"get_pixbuf",{P},P,0,GdkPixbuf},
"GtkOffscreenWindow"}

widget[GtkComboBox] = {"gtk_combo_box",
{GtkBin,GtkContainer,GtkWidget,GtkCellLayout,GtkCellEditable,GtkBuildable,GObject},
	{"new",{P},-routine_id("newComboBox")},
	{"set_wrap_width",{P,I}},
	{"get_wrap_width",{P},I},
	{"set_row_span_column",{P,I}},
	{"get_row_span_column",{P},I},
	{"set_column_span_column",{P,I}},
	{"get_column_span_column",{P},I},
	{"set_active",{P,I}},
	{"get_active",{P},I},
	{"set_id_column",{P,I}},
	{"get_id_column",{P},I},
	{"set_active_id",{P,S},B},
	{"get_active_id",{P},S},
	{"set_model",{P,P}},
	{"get_model",{P},P,0,GtkTreeModel},
	{"popup_for_device",{P,P}},
	{"popup",{P}},
	{"popdown",{P}},
	{"set_row_separator_func",{P,P,P,P}},
	{"get_row_separator_func",{P},P},
	{"set_add_tearoffs",{P,B}}, -- deprecated 3.10
	{"get_add_tearoffs",{P},B}, -- deprecated 3.10
	{"set_title",{P,S}}, -- deprecated 3.10
	{"get_title",{P},S}, -- deprecated 3.10
	{"set_focus_on_click",{P,B}},
	{"get_focus_on_click",{P},B},
	{"set_button_sensitivity",{P,I}},
	{"get_button_sensitivity",{P},I},
	{"get_has_entry",{P},B},
	{"set_entry_text_column",{P,I}},
	{"get_entry_text_column",{P},I},
	{"set_popup_fixed_width",{P,B}},
	{"get_popup_fixed_width",{P},B},
	{"set_activates_default",{P,B},-routine_id("combo_set_activates_default")},
	{"get_entry",{P},-routine_id("combo_get_entry")},
"GtkComboBox"}

 -----------------------------------------------------
 -- create a combo box either empty or from a model --
 -----------------------------------------------------
	function newComboBox(object x=0)
	 if x = 0 then
		return gtk_func("gtk_combo_box_new",{},{})
	 end if
	 if class_id(x) = GtkListStore then
		return gtk_func("gtk_combo_box_new_with_model",{P},{x})
	 end if
	end function
	
	function combo_get_entry(atom box)
	  atom x = get(box,"child")
	  register(x,GtkEntry) 
	 return x
	end function
	
	function combo_set_activates_default(atom box, boolean z)
	  atom x = get(box,"child")
	  register(x,GtkEntry) 
	  set(x,"property","activates-default",z)
	 return 1
	end function

widget[GtkComboBoxText] = {"gtk_combo_box_text",
{GtkCellLayout,GtkCellEditable,GtkComboBox,GtkBin,GtkContainer,
 GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"new_with_entry",{},P},
	{"append",{P,S,S}},
	{"prepend",{P,S,S}},
	{"insert",{P,I,S,S}},
	{"append_text",{P,S}},
	{"prepend_text",{P,S}},
	{"insert_text",{P,I,S}},
	{"remove",{P,I}},
	{"remove_all",{P}},
	{"get_active_text",{P},S},
"GtkComboBoxText"}

widget[GtkComboBoxEntry] = {"gtk_combo_box_text",
{GtkComboBoxText,GtkComboBox,GtkBin,GtkContainer,GtkWidget,GObject},
	{"new",{},-routine_id("new_combo_box_entry")},
"GtkComboBoxEntry"}

	function new_combo_box_entry() -- alias;
	 return gtk_func("gtk_combo_box_text_new_with_entry",{},{})
	end function

widget[GtkFrame] = {"gtk_frame",
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{S},P},
	{"set_label",{P,S}},
	{"get_label",{P},S},
	{"set_label_align",{P,F,F}},
	{"get_label_align",{P,F,F}},
	{"set_label_widget",{P,P}},
	{"get_label_widget",{P},P,0,GtkWidget},
	{"set_shadow_type",{P,I}},
	{"get_shadow_type",{P},I},
"GtkFrame"}

widget[GtkModelButton] = {"gtk_model_button", -- new in 3.16
{GtkButton,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
"GtkModelButton"}

widget[GtkButton] = {"gtk_button",
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P},-routine_id("newButton")},
	{"set_relief",{P,I}},
	{"get_relief",{P},I},
	{"set_label",{P,S}},
	{"get_label",{P},S},
	{"set_use_underline",{P,B}},
	{"get_use_underline",{P},B},
	{"set_focus_on_click",{P,B}},
	{"get_focus_on_click",{P},B},
	{"set_alignment",{P,F,F}}, -- deprecated 3.14
	{"get_alignment",{P,F,F}}, -- deprecated 3.15
	{"set_image",{P,P},-routine_id("setBtnImage")},
	{"get_image",{P},P,0,GtkImage},
	{"set_image_position",{P,I}},
	{"get_image_position",{P},I},
	{"set_always_show_image",{P,B}}, -- GTK 3.6+
	{"get_always_show_image",{P},B}, -- GTK 3.6+
	{"get_event_window",{P},P,0,GdkWindow},
	{"set_icon_name",{P,S}}, -- GTK4
	{"get_icon_name",{P},S}, -- GTK4

"GtkButton"}

 ----------------------------------------------------------------------------------
 -- handles creation of buttons with icons from various sources;
 -- this function modified greatly from earlier versions, in order  
 -- to circumvent the misguided idea that buttons, menus, etc. should not have
 -- icons (even though window managers have settings to show or hide these
 -- icons as the USER prefers)
 ----------------------------------------------------------------------------------

	function setBtnImage(atom btn, object img)
	------------------------------------------
	if class_id(img) = GdkPixbuf then
	   img = create(GtkImage,img)
	end if
	if string(img) then 
	   if file_exists(canonical_path(img)) then
	        img = canonical_path(img)
	   elsif file_exists(canonical_path("~" & img)) then
	        img = canonical_path("~" & img)   
	   end if
	   img = create(GdkPixbuf,img,20,20,1)  
	   img = create(GtkImage,img)
	end if
	if atom(img) then
	   gtk_proc("gtk_button_set_image",{P,P},{btn,img})     
	end if
	return 1
	end function

	function newButton(object cap = 0)
	----------------------------------
	atom btn = 0
	integer show_img  = 0
	object tmp, t1, box, lbl = 0, icon = 0
	
	 if BTN_SHOW_IMGS = 0 then 
		show_img = get(settings,"property","gtk-button-images")
	 else 
		show_img = BTN_SHOW_IMGS 
	end if
	
	if atom(cap) then
		if cap = 0 then -- blank button requested;
			btn = gtk_func("gtk_button_new",{})
			register(btn,GtkButton) 
			return btn
		else  
			btn = gtk_func("gtk_button_new",{})
			register(btn,GtkButton)
			set(btn,"use underline",TRUE)

		if show_img then
			if class_id(cap) = GdkPixbuf then -- convert to image;
				cap = create(GtkImage,cap)
			end if
			if class_id(cap) = GtkImage then 
				set(btn,"image",cap) -- add image to btn
				set(btn,"always show image",BTN_SHOW_IMGS)
			end if
		if string(BTN_TEXT_FONT) then 
			set(btn,"font",BTN_TEXT_FONT) 
		end if
		if BTN_TEXT_SIZE > 0 then
			set(btn,"font",sprintf("%d",BTN_TEXT_SIZE))
		end if
		return btn
		end if
	  end if
	end if

	if string(cap) then 
		if match("#",cap) = 0 then 
			btn = gtk_func("gtk_button_new_from_stock",{P},{allocate_string(cap)})
			register(btn,GtkButton) 
			set(btn,"always show image",BTN_SHOW_IMGS)
			set(btn,"use underline",TRUE)
			if string(BTN_TEXT_FONT) then
				set(btn,"font",BTN_TEXT_FONT)
			end if
			if BTN_TEXT_SIZE > 0 then
				set(btn,"font",sprintf("%d",BTN_TEXT_SIZE))
			end if
			return btn
		end if
		tmp = split(cap,'#') 
		btn = gtk_func("gtk_button_new_with_mnemonic",{P},{allocate_string(tmp[2],1)})
		register(btn,GtkButton)
		set(btn,"use underline",TRUE)

		t1 = canonical_path(locate_file(tmp[1]))
		
		if match("gtk-",cap) = 1 then -- build a button;
			btn = gtk_func("gtk_button_new") 
			register(btn,GtkButton)
			box = create(GtkBox,0,5)
			add(btn,box)
			icon = create(GtkImage,tmp[1],ceil(BTN_ICON_SIZE/10))
			if icon > 0 and show_img  then add(box,icon) end if
			if length(tmp[2]) > 0 then 
				lbl = gtk_func("gtk_label_new_with_mnemonic",
					{P},{allocate_string(tmp[2])})
				register(lbl,GtkLabel)
				if string(BTN_TEXT_FONT) then
					set(lbl,"font",BTN_TEXT_FONT)
				end if
				if BTN_TEXT_SIZE > 0 then
					set(lbl,"font",sprintf("%d",BTN_TEXT_SIZE))
				end if
				add(box,lbl)
			end if
			set(btn,"always show image",BTN_SHOW_IMGS)
			set(btn,"use underline",TRUE)
			return btn
		
		elsif file_exists(t1) then -- make icon from file;
			icon = create(GdkPixbuf,t1,BTN_ICON_SIZE,0,1)
			
		else 
			icon = create(GtkImage,tmp[1],BTN_ICON_SIZE,0,1)
		end if
		set(btn,"image",icon)
		set(btn,"always show image",BTN_SHOW_IMGS)
		set(btn,"use underline",TRUE)
		if string(BTN_TEXT_FONT) then
			set(btn,"font",BTN_TEXT_FONT)
		end if
		if BTN_TEXT_SIZE > 0 then
			set(btn,"font",sprintf("%d",BTN_TEXT_SIZE))
		end if
		return btn
	end if
			
	btn = gtk_func("gtk_button_new",{})
	register(btn,GtkButton)
	
	return btn
	end function

widget[GtkToggleButton] = {"gtk_toggle_button",
{GtkButton,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P},-routine_id("newToggleButton")},
	{"new_with_label",{S},P},
	{"new_with_mnemonic",{S},P},
	{"set_mode",{P,B}},
	{"get_mode",{P},B},
	{"toggled",{P}},
	{"set_active",{P,B}},
	{"get_active",{P},B},
	{"set_inconsistent",{P,B}},
	{"get_inconsistent",{P},B},
"GtkToggleButton"}

	function newToggleButton(object cap = 0)
	atom btn = 0
	object tmp, t1, icon = 0

	if atom(cap) then
		if cap = 0 then -- blank button;
			btn = gtk_func("gtk_toggle_button_new",{})
			register(btn,GtkToggleButton)
			return btn
		else
			btn = gtk_func("gtk_toggle_button_new",{})
			register(btn,GtkToggleButton)
			if class_id(cap) = GdkPixbuf then -- convert to image;
				cap = create(GtkImage,cap)
			end if
			if class_id(cap) = GtkImage then 
				set(btn,"image",cap) -- add image to btn
				set(btn,"always show image",BTN_SHOW_IMGS)
			end if
		return btn
		end if
	end if

	if string(cap) then 
		if match("#",cap) = 0 then 
			btn = gtk_func("gtk_toggle_button_new_with_mnemonic",
				{P},{allocate_string(cap)})
			register(btn,GtkToggleButton)
			if string(BTN_TEXT_FONT) then
				set(btn,"font",BTN_TEXT_FONT)
			end if
			if BTN_TEXT_SIZE > 0 then
				set(btn,"font",sprintf("%d",BTN_TEXT_SIZE))
			end if
			return btn
		end if
		tmp = split(cap,'#') 
		btn = gtk_func("gtk_toggle_button_new_with_mnemonic",
			{P},{allocate_string(tmp[2],1)})
		register(btn,GtkToggleButton)
		
		t1 = canonical_path(locate_file(tmp[1]))
		
		if match("gtk-",cap) = 1 then 
			icon = create(GtkImage,tmp[1],ceil(BTN_ICON_SIZE/5)) 
		
		elsif file_exists(t1) then
			icon = create(GdkPixbuf,t1,BTN_ICON_SIZE,0,1)
			
		else 
			icon = create(GtkImage,tmp[1],BTN_ICON_SIZE,0,1)
		end if
		set(btn,"image",icon)
		if string(BTN_TEXT_FONT) then
			set(btn,"font",BTN_TEXT_FONT)
		end if
		if BTN_TEXT_SIZE > 0 then 
			set(btn,"font",sprintf("%d",BTN_TEXT_SIZE))
		end if
		set(btn,"always show image",BTN_SHOW_IMGS)
		return btn
	end if

	btn = gtk_func("gtk_toggle_button_new",{})
	register(btn,GtkToggleButton)
	
	return btn
	 
	end function
	
widget[GtkCheckButton] = {"gtk_check_button",
{GtkToggleButton,GtkButton,GtkBin,GtkContainer,GtkWidget,
 GtkBuildable,GObject},
	{"new",{P},-routine_id("newCheckButton")},
	{"new_with_label",{S},P,0,GtkCheckButton},
	{"new_with_mnemonic",{S},P,0,GtkCheckButton},
"GtkCheckButton"}

	function newCheckButton(object cap = 0)
	atom btn = 0
	object tmp, t1, icon = 0

	if atom(cap) then
		if cap = 0 then -- blank button;
			btn = gtk_func("gtk_check_button_new",{})
			register(btn,GtkCheckButton)
			return btn
		else
			btn = gtk_func("gtk_check_button_new",{})
			register(btn,GtkCheckButton)
			if class_id(cap) = GdkPixbuf then -- convert to image;
				cap = create(GtkImage,cap)
			end if
			if class_id(cap) = GtkImage then 
				set(btn,"image",cap) -- add image to btn
				set(btn,"always show image",BTN_SHOW_IMGS)
			end if
		return btn
		end if
	end if

	if string(cap) then 
		if match("#",cap) = 0 then
			btn = gtk_func("gtk_check_button_new_with_mnemonic",
				{P},{allocate_string(cap)})
			register(btn,GtkCheckButton)
			if string(BTN_TEXT_FONT) then
				set(btn,"font",BTN_TEXT_FONT)
			end if
			if BTN_TEXT_SIZE > 0 then
				set(btn,"font",sprintf("%d",BTN_TEXT_SIZE))
			end if
			return btn
		end if
		tmp = split(cap,'#') 
		btn = gtk_func("gtk_check_button_new_with_mnemonic",
			{P},{allocate_string(tmp[2],1)})
		register(btn,GtkCheckButton)
		
		t1 = canonical_path(locate_file(tmp[1]))
		
		if match("gtk-",cap) = 1 then
			icon = create(GtkImage,tmp[1],ceil(BTN_ICON_SIZE/5))
		
		elsif file_exists(t1) then
			icon = create(GdkPixbuf,t1,BTN_ICON_SIZE,0,1)
			
		else 
			icon = create(GtkImage,tmp[1],BTN_ICON_SIZE,0,1)
		end if
		set(btn,"image",icon)
		if string(BTN_TEXT_FONT) then
			set(btn,"font",BTN_TEXT_FONT)
		end if
		if BTN_TEXT_SIZE > 0 then
			set(btn,"font",sprintf("%d",BTN_TEXT_SIZE))
		end if
		set(btn,"always show image",BTN_SHOW_IMGS)
		return btn
	end if

	btn = gtk_func("gtk_check_button_new",{})
	register(btn,GtkCheckButton)
	
	return btn  
	end function
	
widget[GtkRadioButton] = {"gtk_radio_button",
{GtkCheckButton,GtkToggleButton,GtkButton,GtkBin,GtkContainer,
 GtkWidget,GtkBuildable,GObject},
	{"new",{P,P},-routine_id("newRadioButton")},
	{"set_group",{P,P}},
	{"get_group",{P},P},
	{"join_group",{P,P}},
"GtkRadioButton"}

function newRadioButton(object group={}, object cap = 0)
atom btn = 0
object tmp, t1, icon = 0

if length(group) > 1 then
if sequence(group) then 
  while group[$] = 0 do
	group = group[1..$-1]
  end while
  group = group[$]
end if
end if

	if atom(cap) then
		if cap = 0 then -- blank button;
			btn = gtk_func("gtk_radio_button_new",{P},{group})
			register(btn,GtkRadioButton)
			return btn
		else
			btn = gtk_func("gtk_radio_button_new",{P},{group})
			register(btn,GtkRadioButton)
			if class_id(cap) = GdkPixbuf then -- convert to image;
				cap = create(GtkImage,cap)
			end if
			if class_id(cap) = GtkImage then 
				set(btn,"image",cap) -- add image to btn
				set(btn,"always show image",BTN_SHOW_IMGS)
			end if
		return btn
		end if
	end if
	
	if string(cap) then 
		if match("#",cap) = 0 then 
			btn = gtk_func("gtk_radio_button_new_with_mnemonic_from_widget",
				{P,P},{group,cap})
			register(btn,GtkRadioButton)
			if string(BTN_TEXT_FONT) then
				set(btn,"font",BTN_TEXT_FONT)
			end if
			if BTN_TEXT_SIZE > 0 then
				set(btn,"font",sprintf("%d",BTN_TEXT_SIZE))
			end if
			return btn
		end if
		tmp = split(cap,'#') 
		btn = gtk_func("gtk_radio_button_new_with_mnemonic_from_widget",{P,P},{group,allocate_string(tmp[2],1)})
		register(btn,GtkRadioButton)
		
		t1 = canonical_path(locate_file(tmp[1]))
		
		if match("gtk-",cap) = 1 then
			icon = create(GtkImage,tmp[1],ceil(BTN_ICON_SIZE/5))
		
		elsif file_exists(t1) then
			icon = create(GdkPixbuf,t1,BTN_ICON_SIZE,0,1)
			
		else 
			icon = create(GtkImage,tmp[1],BTN_ICON_SIZE,0,1)
		end if
		set(btn,"image",icon)
		if string(BTN_TEXT_FONT) then
			set(btn,"font",BTN_TEXT_FONT)
		end if
		if BTN_TEXT_SIZE > 0 then
			set(btn,"font",sprintf("%d",BTN_TEXT_SIZE))
		end if
		set(btn,"always show image",BTN_SHOW_IMGS)
		return btn
	end if
		
	btn = gtk_func("gtk_radio_button_new",{P},{group})
	register(btn,GtkRadioButton)
	if string(BTN_TEXT_FONT) then
		set(btn,"font",BTN_TEXT_FONT)
	end if
	if BTN_TEXT_SIZE > 0 then
		set(btn,"font",sprintf("%d",BTN_TEXT_SIZE))
	end if
	return btn  
	end function
	
widget[GtkColorButton] = {"gtk_color_button",
{GtkColorChooser,GtkButton,GtkBin,GtkContainer,GtkWidget,
 GtkBuildable,GObject},
	{"new",{P},-routine_id("newColorButton")},
	{"set_title",{P,S}},
	{"get_title",{P},S},
	{"show_editor",{P,B}}, -- 3.20
"GtkColorButton"}

	function newColorButton(object c=0)
	  if string(c) then c = to_rgba(c) end if
	  if c=0 then return gtk_func("gtk_color_button_new")
	  else return gtk_func("gtk_color_button_new_with_rgba",{P},{c})
	  end if
	end function

widget[GtkFontButton] = {"gtk_font_button",
{GtkFontChooser,GtkButton,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P,P,P},-routine_id("newFontButton")},
	{"set_font_name",{P,S}},
	{"get_font_name",{P},S},
	{"set_show_style",{P,B}},
	{"get_show_style",{P},B},
	{"set_show_size",{P,B}},
	{"get_show_size",{P},B},
	{"set_use_font",{P,B}},
	{"get_use_font",{P},B},
	{"set_use_size",{P,B}},
	{"get_use_size",{P},B},
	{"set_title",{P,S}},
	{"get_title",{P},S},
"GtkFontButton"}

	function newFontButton(object f=0, object fn=0, object data=0)
	  if string(f) then f = allocate_string(f,1) end if
	  atom fnt
	  if f = 0 then
		fnt = gtk_func("gtk_font_button_new")
	  else 
		fnt = gtk_func("gtk_font_button_new_with_font",{P},{f})
	  end if
	  if string(fn) or fn > 0 then 
		connect(fnt,"font-set",fn,data) 
	  end if
	 return fnt
	end function
	
widget[GtkLinkButton] = {"gtk_link_button",
{GtkButton,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{S,S},-routine_id("newLinkButton")},
	{"set_uri",{P,S}},
	{"get_uri",{P},S},
	{"set_visited",{P,B}},
	{"get_visited",{P},B},
"GtkLinkButton"}

	function newLinkButton(object link, object lbl=0)
	 if lbl = 0 then return gtk_func("gtk_link_button_new",{S},{link}) 
	 else return gtk_func("gtk_link_button_new_with_label",{S,S},{link,lbl})
	 end if
	end function

widget[GtkLockButton] = {"gtk_lock_button", -- unable to make this work!
{GtkButton,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P},P},
	{"set_permission",{P,P}},
	{"get_permission",{P},P,0,GPermission},
"GtkLockButton"}

widget[GPermission] = {"g_permission",
{GObject},
	{"get_allowed",{P},B},
	{"get_can_acquire",{P},B},
	{"get_can_release",{P},B},
	{"acquire",{P,P,P},B},
	{"acquire_async",{P,P,P,P}},
	{"acquire_finish",{P,P,P},B},
	{"release",{P,P,P},B},
	{"release_async",{P,P,P,P}},
	{"finish",{P,P,P},B},
	{"impl_update",{P,B,B,B}},
"GPermission"}

widget[GSimplePermission] = {"g_simple_permission",
{GPermission},
	{"new",{B},P},
"GSimplePermission"}

widget[GtkScaleButton] = {"gtk_scale_button",
{GtkButton,GtkBin,GtkContainer,GtkWidget,GtkBuildable,
 GtkOrientable,GObject},
	{"new",{I,D,D,D,P},P},
	{"set_adjustment",{P,P}},
	{"get_adjustment",{P},P,0,GtkAdjustment},
	{"set_value",{P,D}},
	{"get_value",{P},D},
	{"get_popup",{P},P,0,GtkWidget},
	{"get_plus_button",{P},P,0,GtkButton},
	{"get_minus_button",{P},P,0,GtkButton},
	{"set_icons",{P,A}},
"GtkScaleButton"}

widget[GtkMenu] = {"gtk_menu",
{GtkMenuShell,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P},-routine_id("newMenu")},
	{"attach",{P,P,I,I,I,I}},
	{"attach_to_widget",{P,P,P}},
	{"get_attach_widget",{P},P,0,GtkWidget},
	{"get_for_attach_widget",{P},P,0,GList},
	{"detach",{P}},
	{"popup",{P,P,P,P,P,I,I}},
	{"popdown",{P}},
	{"reposition",{P}},
	{"set_active",{P,I}},
	{"get_active",{P},P,0,GtkMenuItem},
	{"popup_for_device",{P,P,P,P,P,P,P,I,I}},
	{"set_accel_group",{P,P}},
	{"get_accel_group",{P},P,0,GtkAccelGroup},
	{"set_accel_path",{P,S}},
	{"get_accel_path",{P},S},
	{"set_title",{P,S}}, -- deprecated 3.10
	{"get_title",{P},S}, -- deprecated 3.10
	{"set_monitor",{P,I}},
	{"get_monitor",{P},I},
	{"set_tearoff_state",{P,B}}, -- deprecated 3.10
	{"get_tearoff_state",{P},B}, -- deprecated 3.10
	{"set_reserve_toggle_size",{P,B}},
	{"get_reserve_toggle_size",{P},B},
	{"set_screen",{P,P}},
	{"popup_at_pointer",{P,P}}, -- 3.22
	{"popup_at_rect",{P,P,P,I,I,P}}, -- 3.22
	{"popup_at_widget",{P,P,I,I,P}}, -- 3.22
	
	{"set_display",{P,P}}, -- GTK4
	
"GtkMenu"}

   function newMenu(object x=0)
	if class_id(x) =  GMenuModel then
	return gtk_func("gtk_menu_new_from_model",{P},{x})
	else
	return gtk_func("gtk_menu_new")
	end if
   end function
   
widget[GtkMenuBar] = {"gtk_menu_bar",
{GtkMenuShell,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P},-routine_id("newMenuBar")},
	{"set_pack_direction",{P,I}},
	{"get_pack_direction",{P},I},
	{"set_child_pack_direction",{P,I}},
	{"get_child_pack_direction",{P},I},
"GtkMenuBar"}

	function newMenuBar(atom x=0)
	  if class_id(x) = GMenuModel then
		return gtk_func("gtk_menu_bar_new_from_model",{P},{x})
	  else
		return gtk_func("gtk_menu_bar_new")
	  end if
	end function

widget[GMenu] = {"g_menu",
{GMenuModel,GObject},
	{"new",{},P},
	{"freeze",{P}},
	{"insert",{P,I,S,S}},
	{"prepend",{P,S,S}},
	{"append",{P,S,S}},
	{"insert_item",{P,I,P}},
	{"append_item",{P,P}},
	{"prepend_item",{P,P}},
	{"insert_section",{P,I,S,P}},
	{"prepend_section",{P,S,P}},
	{"append_section",{P,S,P}},
	{"append_submenu",{P,S,P}},
	{"insert_submenu",{P,I,S,P}},
	{"prepend_submenu",{P,S,P}},
	{"remove",{P,I}},
"GMenu"}

widget[GMenuModel] = {"g_menu_model",
{GObject},
	{"is_mutable",{P},B},
	{"get_n_items",{P},I},
	{"get_item_attribute",{P,I,S,S,P},B},
	{"get_item_link",{P,I,S},P,0,GMenuModel},
	{"items_changed",{P,I,I,I}},
"GMenuModel"}

widget[GMenuItem] = {"g_menu_item",
{GObject},
	{"new",{S,S},P},
	{"new_section",{S,P},P,0,GMenuItem},
	{"new_submenu",{S,P},P,0,GMenuItem},
	{"set_label",{P,S}},
	{"set_action_and_target_value",{P,S,P}},
	{"set_detailed_action",{P,S}},
	{"set_section",{P,P}},
	{"set_submenu",{P,P}},
	{"set_attribute_value",{P,P,P}},
	{"set_link",{P,S,P}},
"GMenuItem"}

widget[GtkMenuButton] = {"gtk_menu_button", --3.6
{GtkToggleButton,GtkButton,GtkBin,GtkContainer,GtkWidget,
 GtkBuildable,GObject},
	{"new",{},P},
	{"set_popup",{P,P}},
	{"get_popup",{P},P,0,GtkMenu},
	{"set_menu_model",{P,P}},
	{"get_menu_model",{P},P,0,GMenuModel},
	{"set_direction",{P,I}},
	{"get_direction",{P},I},
	{"set_align_widget",{P,P}},
	{"get_align_widget",{P},P,0,GtkWidget},
	{"set_popover",{P,P}}, -- 3.12
	{"get_popover",{P},P,0,GtkPopover}, -- 3.12
	{"set_use_popover",{P,B}}, -- 3.12
	{"get_use_popover",{P},B}, -- 3.12
"GtkMenuButton"}
   
widget[GtkMenuItem] = {"gtk_menu_item",
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P,P,P,P},-routine_id("newMenuItem")},
	{"set_label",{P,S},-routine_id("mi_set_label")},
	{"get_label",{P},-routine_id("mi_get_label")},
	{"set_image",{P,P},-routine_id("mi_set_image")},
	{"get_image",{P},-routine_id("mi_get_image")},
	{"set_use_underline",{P,B}},
	{"get_use_underline",{P},B},
	{"set_submenu",{P,P}},
	{"get_submenu",{P},P,0,GtkWidget},
	{"select",{P}},
	{"deselect",{P}},
	{"activate",{P}},
	{"toggle_size_allocate",{P,I}},
	{"set_reserve_indicator",{P,B}},
	{"get_reserve_indicator",{P},B},
	{"add_accelerator",{P,P,P},-routine_id("mi_add_accelerator")},
"GtkMenuItem"}

-------------------------------------------------------------
-- all this just to allow images and accels on menu items! --
-------------------------------------------------------------
   
constant activate = allocate_string("activate")
  
	function newMenuItem(object stk=0, object fn=0, object data=0, object accels=0)
	 object item, img = 0

	if sequence(stk) and match("#",stk) then
		stk = split(stk,'#')
		img = stk[1]
		stk = stk[2]
		goto "next"
	end if	

	if sequence(stk) and match("#",stk) = 0 then
		if match("gtk-",stk) then 
			img = stk
			stk = "_" & proper(stk[5..$])
		end if
	end if

   label "next"

	if atom(stk) then
		item = gtk_func("gtk_menu_item_new")
	else 
		item = gtk_func("gtk_menu_item_new_with_mnemonic",{P},{allocate_string(stk,1)})
	end if
	
	 register(item,GtkMenuItem)

   label "accels "
	
	if atom(img) and img = 0 then
		item = mi_add_accelerator(item,accels)
	 else
		item = mi_add_accelerator(item,accels,img)
	 end if
	
	 return item
	end function

   function mi_add_accelerator(atom item, object accels, object img = 0)
	 atom x = allocate(8,1)
	 integer key, mods, show_img = 0

	 object child = get(item,"child") 
		
	 if MENU_SHOW_IMG = 0 then 
		show_img = get(settings,"property","gtk-menu-images")
	 else 
		show_img = MENU_SHOW_IMG 
	end if
		
	 if atom(img) and img = 0 then -- do nothing
	 else 
		if show_img then
		img = get_icon_image(img,3)
		end if
	 end if

	 if  sequence(accels) then
	   gtk_proc("gtk_accelerator_parse", {P,P,P}, 
		{allocate_string(accels[2],1),x,x+4})

	   key = peek4u(x) mods = peek4u(x+4)

	   gtk_proc("gtk_widget_add_accelerator",{P,P,P,I,I,I},
		{item,activate,accels[1],key,mods,GTK_ACCEL_VISIBLE})

	   if class_id(child) = -1 then
		gtk_proc("gtk_accel_label_set_accel_widget",{P,P},{child,item})
		gtk_proc("gtk_accel_label_set_accel",{P,I,I},{child,key,mods})
	   end if
	 end if

	 gtk_proc("g_object_ref",{P},{child})
	 gtk_proc("gtk_container_remove",{P,P},{item,child})

	 atom box = create(GtkButtonBox)
	 set(box,"margin left",0)
	 set(box,"layout",GTK_BUTTONBOX_START)

	 if atom(img) and img > 0 and show_img=1 then
		add(box,img) 
		register(img,GtkImage) 
		set(box,"halign",0)
		set(img,"margin left",0)
		set(img,"margin right",0)
		set(box,"child non_homogeneous",img,TRUE)
	 end if

	 register(child,GtkAccelLabel)
		pack_start(box,child,1,1) -- put the label back
	
	 set(box,"child non_homogeneous",child,TRUE)
	 set(child,"halign",0)
	 set(child,"margin left",0)
	 
	if sequence(accels) then
		object txt = gtk_str_func("gtk_accelerator_get_label",{I,I},{key,mods})
		if string(txt) then
			atom acc = create(GtkLabel)
			set(acc,"padding",0,0)
			set(acc,"markup",txt)
			if sequence(ACCEL_FONT) then
				set(acc,"font",ACCEL_FONT)
			end if
		add(box,acc) 
		set(box,"child secondary",acc,TRUE)
		set(box,"child non_homogeneous",acc,TRUE)
		end if
	end if

	 add(item,box)
	 
	 return item
	end function
	
	function mi_set_label(atom item, object lbl) 
	  if string(lbl) then lbl = allocate_string(lbl,1) end if
	  atom b = get(item,"child")
	  object list = get(b,"children")
	  if atom(list) then 
		list &= 0
	  end if

	  for i = 1 to length(list) do
	     if class_id(list[i]) = GtkAccelLabel then
		gtk_proc("gtk_label_set_text",{P,P},{list[i],lbl})
		return 1
	     end if
	  end for

	 return 1
	end function

        function mi_get_label(atom item)
	 atom b = get(item,"child")
	 object list = get(b,"children") 
	 for i = 1 to length(list) do 
	   if class_id(list[i]) = GtkAccelLabel then
		return gtk_str_func("gtk_label_get_text",{P},{list[i]})
	   end if
	 end for
	return 0
	end function
	
	function mi_set_image(atom item, object img)
	  if string(img) then img = get_icon_image(img,GTK_ICON_SIZE_MENU) end if
	  img = get(img,"pixbuf")
	  atom b = get(item,"child")
	  object l = get(b,"children")
	  for i = 1 to length(l) do
	   if class_id(l[i]) = GtkImage then
		gtk_proc("gtk_image_set_from_pixbuf",{P,P},{l[i],img})
		return 1
	   end if
	 end for
	 return 1
	end function

	function gmi_get_image(atom item)
	  atom b = get(item,"child") 
	  object l = get(b,"children")
	  for i = 1 to length(l) do
	   if class_id(l[i]) = GtkImage then
		return l[i]
	   end if
	  end for
	return 1
	end function

	function mi_set_use_underline(atom item, boolean use)
	  atom b = get(item,"child")
	  object l = get(b,"children")
	  for i = 1 to length(l) do
	    if class_id(l[i]) = GtkAccelLabel then
		gtk_proc("gtk_label_set_use_underline",{P,B},{l[i],use})
		return 1
	    end if
	  end for
	 return 1
	end function

	function mi_get_use_underline(atom item)
	  atom b = get(item,"child") 
	  object l = get(b,"children")
	  l = to_sequence(l,1)
	  for i = 1 to length(l) do
	    if class_id(l[i]) = GtkAccelLabel then
		return gtk_func("gtk_label_get_use_underline",{P},{l[i]})
	    end if
	  end for
	 return 1
	end function

widget[GtkImageMenuItem] = {"gtk_image_menu_item",
{GtkMenuItem,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P,P,P,P},-routine_id("newMenuItem")},
"GtkImageMenuItem"}
  
widget[GtkRadioMenuItem] = {"gtk_radio_menu_item",
{GtkCheckMenuItem,GtkMenuItem,GtkBin,GtkContainer,GtkWidget,
 GtkBuildable,GObject},
	{"new",{P,P,P,P,P},-routine_id("newRadioMenuItem")},
	{"set_group",{P,P}},
	{"get_group",{P},P},
	{"join_group",{P,P}}, -- 3.18
"GtkRadioMenuItem"}

function newRadioMenuItem(atom group, object stk, object fn, object data, object accels=0)
	  object item, img = 0

	  if match("#",stk) then
		stk = split(stk,'#')
		img = stk[1]
		stk = stk[2]
		goto "next"
	  end if	

	  if not match("#",stk) then
		if match("gtk-",stk) then
			img = stk
		end if
	  end if

	label "next"
	
	  if group = 0 then
		item = gtk_func("gtk_radio_menu_item_new_with_mnemonic",{P,P},
		{group,allocate_string(stk,1)})
	  else
		item = gtk_func("gtk_radio_menu_item_new_with_mnemonic_from_widget",
		{P,P},{group,allocate_string(stk,1)})
	  end if
	  register(item,GtkMenuItem)

	  if atom(img) and img = 0 then
		item = mi_add_accelerator(item,accels)
	  else
		item = mi_add_accelerator(item,accels,img)
	  end if

	 return item
	end function

widget[GtkCheckMenuItem] = {"gtk_check_menu_item",
{GtkMenuItem,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P,P,P,P},-routine_id("newCheckMenuItem")},
	{"set_active",{P,B}},
	{"get_active",{P},B},
	{"toggled",{P}},
	{"set_inconsistent",{P,B}},
	{"get_inconsistent",{P},B},
	{"set_draw_as_radio",{P,B}},
	{"get_draw_as_radio",{P},B},
"GtkCheckMenuItem"}

	function newCheckMenuItem(object stk,object fn, object data, object accels=0)
	  object item, img = 0

	  if match("#",stk) then
		stk = split(stk,'#')
		img = stk[1]
		stk = stk[2]
		goto "next"
	  end if	

	  if not match("#",stk) then
		if match("gtk-",stk) then
			img = stk
		end if
	  end if

	label "next"

	  item = gtk_func("gtk_check_menu_item_new_with_mnemonic",
		{P},{allocate_string(stk,1)})
	  register(item,GtkCheckMenuItem)

	  if atom(img) and img = 0 then
		item = mi_add_accelerator(item,accels)
	  else
		item = mi_add_accelerator(item,accels,img)
	  end if

	 return item
	end function
	
widget[GtkNumerableIcon] = {"gtk_numerable_icon", -- deprecated 3.14
{GEmblemedIcon,GObject},
	{"new",{P},P,0,GIcon},
	{"new_with_style_context",{P,P},P,0,GIcon},
	{"get_background_gicon",{P},P,0,GIcon},
	{"set_background_gicon",{P,P}},
	{"get_background_icon_name",{P},S},
	{"set_background_icon_name",{P,S}},
	{"get_count",{P},I},
	{"set_count",{P,I}},
	{"get_label",{P},S},
	{"set_label",{P,S}},
	{"get_style_context",{P},P,0,GtkStyleContext},
	{"set_style_context",{P,P}},
"GtkNumerableIcon"}

widget[GtkEventBox] = {"gtk_event_box",
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"set_above_child",{P,B}},
	{"get_above_child",{P},B},
	{"set_visible_window",{P,B}},
	{"get_visible_window",{P},B},
"GtkEventBox"}

widget[GtkExpander] = {"gtk_expander",
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P},-routine_id("newExpander")},
	{"set_spacing",{P,I}},
	{"get_spacing",{P},I},
	{"set_expanded",{P,B}},
	{"get_expanded",{P},B},
	{"set_label",{P,S}},
	{"get_label",{P},S},
	{"set_label_widget",{P,P}},
	{"get_label_widget",{P},P},
	{"set_label_fill",{P,B}},
	{"get_label_fill",{P},B},
	{"set_use_underline",{P,B}},
	{"get_use_underline",{P},B},
	{"set_use_markup",{P,B}},
	{"get_use_markup",{P},B},
	{"set_resize_toplevel",{P,B}},
	{"get_resize_toplevel",{P},B},
"GtkExpander"}

	function newExpander(object caption="")
	  if string(caption) and match("_",caption) then
		return gtk_func("gtk_expander_new_with_mnemonic",{P},{caption})
	  else
		return gtk_func("gtk_expander_new",{P},{caption})
	  end if
	end function
	
widget[GtkToolItem] = {"gtk_tool_item",
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"set_homogeneous",{P,B}},
	{"get_homogeneous",{P},B},
	{"set_expand",{P,B}},
	{"get_expand",{P},B},
	{"set_tooltip_text",{P,S}},
	{"set_tooltip_markup",{P,S}},
	{"set_use_drag_window",{P,B}},
	{"get_use_drag_window",{P},B},
	{"set_visible_horizontal",{P,B}},
	{"get_visible_horizontal",{P},B},
	{"set_visible_vertical",{P,B}},
	{"get_visible_vertical",{P},B},
	{"set_is_important",{P,B}},
	{"get_is_important",{P},B},
	{"get_ellipsize_mode",{P},I},
	{"get_icon_size",{P},I},
	{"get_orientation",{P},I},
	{"get_toolbar_style",{P},I},
	{"get_relief_style",{P},I},
	{"get_text_alignment",{P},F},
	{"get_text_orientation",{P},I},
	{"retrieve_proxy_menu_item",{P},P,0,GtkMenuItem},
	{"set_proxy_menu_item",{P,S,P}},
	{"get_proxy_menu_item",{P,S},P,0,GtkMenuItem},
	{"rebuild_menu",{P}},
	{"toolbar_reconfigured",{P}},
	{"get_text_size_group",{P},P,0,GtkSizeGroup},
"GtkToolItem"}

widget[GtkToolButton] = {"gtk_tool_button",
{GtkToolItem,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P,P},-routine_id("newToolButton")},
	{"set_label",{P,S}},
	{"get_label",{P},S},
	{"set_use_underline",{P,B}},
	{"get_use_underline",{P},B},
	{"set_stock_id",{P,S}}, -- deprecated 3.10
	{"get_stock_id",{P},S}, -- deprecated 3.10
	{"set_icon_name",{P,S}},
	{"get_icon_name",{P},S},
	{"set_icon_widget",{P,P}},
	{"get_icon_widget",{P},P,0,GtkWidget},
	{"set_label_widget",{P,P}},
	{"get_label_widget",{P},P,0,GtkWidget},
"GtkToolButton"}

	function newToolButton(object icn=0, object lbl=0)
	--------------------------------------------------
	if string(icn) then 
		icn = create(GtkImage,icn)
	end if
	
	if string(lbl) then 
		lbl = allocate_string(lbl)
	end if
	
	atom btn = gtk_func("gtk_tool_button_new",{P,P},{icn,lbl})

	return btn
	end function

widget[GtkMenuToolButton] = {"gtk_menu_tool_button",
{GtkToolButton,GtkToolItem,GtkBin,GtkContainer,GtkWidget,
 GtkBuildable,GObject},
	{"new",{P,P},-routine_id("newMenuToolButton")},
	{"set_menu",{P,P}},
	{"get_menu",{P},P,0,GtkMenu},
	{"set_arrow_tooltip_text",{P,S}},
	{"set_arrow_tooltip_markup",{P,S}},
"GtkMenuToolButton"}

	function newMenuToolButton(object icn=0, object lbl=0)
	  if string(icn) then
		icn = create(GtkImage,icn,1)
	  end if
	  if string(lbl) then
		lbl = allocate_string(lbl,1)
	  end if
	  atom btn = gtk_func("gtk_menu_tool_button_new",{P,P},{icn,lbl})
	 return btn
	end function
	
widget[GtkToggleToolButton] = {"gtk_toggle_tool_button",
{GtkToolButton,GtkToolItem,GtkBin,GtkContainer,GtkWidget,
 GtkBuildable,GObject},
	{"new",{S},-routine_id("newToggleToolButton")},
	{"set_active",{P,B}},
	{"get_active",{P},B},
"GtkToggleToolButton"}

	function newToggleToolButton(object x)
	atom btn
	 if string(x) then
		btn = gtk_func("gtk_toggle_tool_button_new_from_stock",{S},{x})
	 elsif atom(x) then
		btn = gtk_func("gtk_toggle_tool_button_new")
		if class_id(btn) = GdkPixbuf then
			set(btn,"image",create(GtkImage,btn))   
		end if
	 end if
	 return btn
	end function

widget[GtkRadioToolButton] = {"gtk_radio_tool_button",
{GtkToggleToolButton,GtkToolButton,GtkToolItem,GtkBin,GtkContainer,
 GtkWidget,GtkBuildable,GObject},
	{"new",{P},-routine_id("newRadioToolButton")},
	{"set_group",{P,P}},
	{"get_group",{P},P},
"GtkRadioToolButton"}

	function newRadioToolButton(atom id)
	  if class_id(id) = GtkRadioToolButton then
		return gtk_func("gtk_radio_tool_button_new_from_widget",{P},{id})
	  else
		return gtk_func("gtk_radio_tool_button_new",{P},{id})
	  end if
	end function

widget[GtkSeparatorToolItem] = {"gtk_separator_tool_item",
{GtkToolItem,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"set_draw",{P,B}},
	{"get_draw",{P},B},
"GtkSeparatorToolItem"}

widget[GtkOverlay] = {"gtk_overlay",
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"add_overlay",{P,P}},
	{"reorder_overlay",{P,P,I}}, -- 3.18
	{"get_overlay_pass_through",{P,P},B}, -- 3.18
	{"set_overlay_pass_through",{P,P,B}}, -- 3.18
"GtkOverlay"}

widget[GtkScrollable] = {"gtk_scrollable",
{GObject},
	{"set_hadjustment",{P,P}},
	{"get_hadjustment",{P},P,0,GtkAdjustment},
	{"set_vadjustment",{P,P}},
	{"get_vadjustment",{P},P,0,GtkAdjustment},
	{"set_hscroll_policy",{P,I}},
	{"get_hscroll_policy",{P},I},
	{"set_vscroll_policy",{P,I}},
	{"get_vscroll_policy",{P},I},
	{"get_border",{P,P},B}, -- 3.16
"GtkScrollable"}

widget[GtkScrolledWindow] = {"gtk_scrolled_window",
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P,P},P},
	{"set_hadjustment",{P,P}},
	{"get_hadjustment",{P},P,0,GtkAdjustment},
	{"set_vadjustment",{P,P}},
	{"get_vadjustment",{P},P,0,GtkAdjustment},
	{"get_hscrollbar",{P},P,0,GtkWidget},
	{"get_vscrollbar",{P},P,0,GtkWidget},
	{"set_policy",{P,I,I}},
	{"get_policy",{P,I,I}},
	{"get_placement",{P},I},
	{"set_placement",{P,I}},
	{"unset_placement",{P}},
	{"set_shadow_type",{P,I}},
	{"get_shadow_type",{P},I},
	{"set_min_content_width",{P,I}},
	{"get_min_content_width",{P},I},
	{"get_max_content_width",{P},I}, -- 3.22
	{"set_max_content_width",{P,I}}, -- 3.22
	{"set_min_content_height",{P,I}},
	{"get_min_content_height",{P},I},
	{"get_max_content_height",{P},I}, -- 3.22
	{"set_max_content_height",{P,I}}, -- 3.22
	{"get_propagate_natural_width",{P},B}, -- 3.22
	{"set_propagate_natural_width",{P,B}}, -- 3.22
	{"get_propagate_natural_height",{P},B}, -- 3.22
	{"set_propagate_natural_height",{P,B}}, -- 3.22
	{"set_kinetic_scrolling",{P,B}},
	{"get_kinetic_scrolling",{P},B},
	{"set_capture_button_press",{P,B}},
	{"get_capture_button_press",{P},B},
	{"set_headers",{P,P}},
	{"add_with_viewport",{P,P}}, -- deprecated 3.8
	{"get_overlay_scrolling",{P},B}, -- 3.16
	{"set_overlay_scrolling",{P,B}}, -- 3.16
"GtkScrolledWindow"}

widget[GtkSidebar] = {"gtk_sidebar", -- 3.16
{GtkBin,GtkContainer,GtkWidget,GObject},
	{"new",{},P},
	{"set_stack",{P,P}},
	{"get_stack",{P},P,0,GtkStack},
"GtkSidebar"}

widget[GtkTextBuffer] = {"gtk_text_buffer",
{GObject},
	{"new",{P},P},
	{"get_line_count",{P},I},
	{"get_char_count",{P},I},
	{"get_tag_table",{P},P,0,GtkTextTagTable},
	{"insert",{P,P,S,I}},
	{"insert_at_cursor",{P,S,I}},
	{"insert_interactive",{P,P,S,I,B},B},
	{"insert_interactive_at_cursor",{P,S,I,B},B},
	{"insert_range",{P,P,P,P}},
	{"insert_range_interactive",{P,P,P,P,B},B},
	{"insert_with_tags",{P,P,S,I,P,P}},
	{"insert_with_tags_by_name",{P,P,S,I,S}},
	{"insert_markup",{P,P,S,I}}, -- 3.16
	{"delete",{P,P,P}},
	{"delete_interactive",{P,P,P,B},B},
	{"backspace",{P,P,B,B},B},
	{"set_text",{P,P},-routine_id("setBufferText")},
	{"get_text",{P},-routine_id("getBufferText")},
	{"get_slice",{P,P,P,B},S},
	{"insert_pixbuf",{P,P,P}},
	{"insert_child_anchor",{P,P,P}},
	{"create_child_anchor",{P,P},P,0,GtkTextChildAnchor},
	{"create_mark",{P,S,P,B},P,0,GtkTextMark},
	{"move_mark",{P,P,P}},
	{"move_mark_by_name",{P,S,P}},
	{"add_mark",{P,P,P}},
	{"delete_mark",{P,P}},
	{"delete_mark_by_name",{P,S}},
	{"get_mark",{P,S},P,0,GtkTextMark},
	{"get_insert",{P},P,0,GtkTextMark},
	{"get_selection_bound",{P},P,0,GtkTextMark},
	{"get_selection_bounds",{P},-routine_id("getSelectionBounds")},
	{"get_has_selection",{P},B},
	{"place_cursor",{P,P}},
	{"select_range",{P,P,P}},
	{"apply_tag",{P,P,P,P}},
	{"remove_tag",{P,P,P,P}},
	{"apply_tag_by_name",{P,S,P,P}},
	{"remove_tag_by_name",{P,S,P,P}},
	{"remove_all_tags",{P,P,P}},
	{"create_tag",{P,S,S,S},P,0,GtkTextTag},
	{"get_iter_at_line_offset",{P,P,I,I}},
	{"get_iter_at_offset",{P,P,I}},
	{"get_iter_at_line",{P,I},-routine_id("getIterAtLine")},
	{"get_iter_at_line_index",{P,I,I},-routine_id("getIterAtLineIndex")},
	{"get_iter_at_mark",{P,P},-routine_id("getIterAtMark")},
	{"get_iter_at_child_anchor",{P,P,P}},
	{"get_start_iter",{P,P}},
	{"get_end_iter",{P,P}},
	{"get_bounds",{P,P,P}},
	{"set_modified",{P,B}},
	{"get_modified",{P},B},
	{"delete_selection",{P,B,B},B},
	{"paste_clipboard",{P,P,P,B}},
	{"copy_clipboard",{P,P}},
	{"cut_clipboard",{P,P,B}},
	{"get_selection_bounds",{P,P,P},B},
	{"begin_user_action",{P}},
	{"end_user_action",{P}},
	{"add_selection_clipboard",{P,P}},
	{"remove_selection_clipboard",{P,P}},
	{"deserialize",{P,P,I,P,I,I,P},B},
	{"deserialize_set_can_create_tags",{P,I,B}},
	{"deserialize_get_can_create_tags",{P,I},B},
	{"get_copy_target_list",{P},P,0,GtkTargetList},
	{"get_deserialize_formats",{P,I},P},
	{"get_paste_target_list",{P},P,0,GtkTargetList},
	{"get_serialize_formats",{P,I},P},
	{"register_deserialize_format",{P,S,P,P,P},P},
	{"register_deserialize_tagset",{P,S},P},
	{"register_serialize_format",{P,S,P,P,P},P},
	{"register_serialize_tagset",{P,S},P},
	{"serialize",{P,P,P,P,P,I},I},
	{"unregister_deserialize_format",{P,P}},
	{"unregister_serialize_format",{P,P}},
	{"insert_markup",{P,P,S,I}}, -- 3.16
"GtkTextBuffer"}

	export constant 
	fnBufStart = define_proc("gtk_text_buffer_get_start_iter",{P,P}),
	fnBufEnd = define_proc("gtk_text_buffer_get_end_iter",{P,P}),
	fnBufGet = define_func("gtk_text_buffer_get_text",{P,P,P,B},S),
	fnBufSet = define_proc("gtk_text_buffer_set_text",{P,S,I}),
	fnBufIns = define_func("gtk_text_buffer_get_insert",{P},P),
	fnBufIterLine = define_proc("gtk_text_buffer_get_iter_at_line",{P,P,I}),
	fnBufIterLineIndex = define_proc("gtk_text_buffer_get_iter_at_line_index",{P,P,I,I}),
	fnBufIterMark = define_proc("gtk_text_buffer_get_iter_at_mark",{P,P,P}),
	fnBufBounds = define_func("gtk_text_buffer_get_selection_bounds",{P,P,P},B)

	function getBufferText(object buf)
	  atom start = allocate(64) c_proc(fnBufStart,{buf,start})
	  atom fini = allocate(64) c_proc(fnBufEnd,{buf,fini})
	  object result = c_func(fnBufGet,{buf,start,fini,1})
	 return peek_string(result)
	end function

	function getSelectionBounds(object buf)
	  atom start = allocate(100)
	  atom fini = allocate(100)
	  atom iter = allocate(100)
	  if c_func(fnBufBounds,{buf,start,fini}) then
		return {start,fini}
	  else
		start = c_func(fnBufIns,{buf})
		c_proc(fnBufIterMark,{buf,iter,start})
	  return {iter,iter}
	  end if
	end function

	function setBufferText(object buf, object txt)
	  object len
	  if atom(txt) then 
		len = peek_string(txt)
		len = length(len)
	  else
		len = length(txt)
		txt = allocate_string(txt)
	  end if
	  c_proc(fnBufSet,{buf,txt,len})
	 return 1
	end function

	function getIterAtLine(object buf, integer ln)
	atom iter = allocate(100)
	c_proc(fnBufIterLine,{buf,iter,ln-1})
	return iter       
	end function
	
	function getIterAtLineIndex(object buf, integer line, integer index)
	atom iter = allocate(100)
	c_proc(fnBufIterLineIndex,{buf,iter,line-1,index-1})
	return iter        
	end function
	
	function getIterAtMark(object buf, atom mark)
	atom iter = allocate(100)
	c_proc(fnBufIterMark,{buf,iter,mark})
	return iter        
	end function
	
widget[GtkClipboard] = {"gtk_clipboard",
{GObject},
	{"new",{I},-routine_id("newClipboard")},
	{"get_default",{P},P,0,GtkClipboard},-- 3.16
	{"get_for_display",{P,I},P,0,GtkClipboard},
	{"get_display",{P},P,0,GdkDisplay},
	{"set_with_data",{P,P,I,P,P,P},B},
	{"set_with_owner",{P,P,I,P,P,P},B},
	{"get_owner",{P},P,0,GObject},
	{"clear",{P}},
	{"set_text",{P,S,I}},
	{"set_image",{P,P}},
	{"request_contents",{P,I,P,P}},
	{"request_text",{P,P,P}},
	{"request_image",{P,P,P}},
	{"request_targets",{P,P,P}},
	{"request_rich_text",{P,P,P,P}},
	{"request_uris",{P,P,P}},
	{"wait_for_contents",{P,I},P,0,GtkSelectionData},
	{"wait_for_text",{P},S},
	{"wait_for_image",{P},P,0,GdkPixbuf},
	{"wait_for_rich_text",{P,P,I,I},I},
	{"wait_for_uris",{P},A},
	{"wait_is_text_available",{P},B},
	{"wait_is_image_available",{P},B},
	{"wait_is_rich_text_available",{P,P},B},
	{"wait_is_uris_available",{P},B},
	{"wait_for_targets",{P,P,I},B},
	{"wait_is_target_available",{P,I},B},
	{"set_can_store",{P,P,I}},
	{"store",{P}},
	{"get_selection",{P},P}, -- 3.22
"GtkClipboard"}

	function newClipboard(integer i=0) -- just use default clipboard;
	 return gtk_func("gtk_clipboard_get",{I},{i})
	end function

widget[GtkSelectionData] = {"gtk_selection_data",
{0},
	{"set",{P,I,I,S,I}},
	{"set_text",{P,S,I},B},
	{"get_text",{P},S},
	{"set_pixbuf",{P,P},B},
	{"get_pixbuf",{P},P,0,GdkPixbuf},
	{"set_uris",{P,S},B},
	{"get_uris",{P},A},
	{"get_targets",{P,P,I},B},
	{"targets_include_image",{P,B},B},
	{"targets_include_text",{P},B},
	{"targets_include_uri",{P},B},
	{"targets_include_rich_text",{P,P},B},
	{"get_selection",{P},P},
	{"get_data",{P},S},
	{"get_length",{P},I},
	{"get_data_with_length",{P,I},S},
	{"get_data_type",{P},I},
	{"get_display",{P},P,0,GdkDisplay},
	{"get_format",{P},I},
	{"get_target",{P},I},
	{"set_surface",{P,P},B}, -- GTK4
	{"get_surface",{P},0,P}, -- cairo_surface_t * GTK4
	{"set_texture",{P,P},B}, -- GTK4
	{"get_texture",{P},P,0,GdkTexture}, -- GTK4	
"GtkSelectionData"}

widget[GtkCellArea] = {"gtk_cell_area",
{GtkCellLayout,GtkBuildable,GObject},
	{"add",{P,P}},
	{"remove",{P,P}},
	{"set_property",{P,P,S,P}},
	{"get_property",{P,P,S,P}},
	{"has_renderer",{P,P},B},
	{"foreach",{P,P}},
	{"foreach_alloc",{P,P,P,P,P,P,P}},
	{"event",{P,P,P,P,P,I},I},
	{"render",{P,P,P,P,P,P,I,B}},
	{"get_cell_allocation",{P,P,P,P,P,P}},
	{"get_cell_at_position",{P,P,P,P,I,I,P},P,0,GtkCellRenderer},
	{"create_context",{P},P,0,GtkCellAreaContext},
	{"copy_context",{P,P},P,0,GtkCellAreaContext},
	{"get_request_mode",{P},I},
	{"get_preferred_width",{P,P,P,I,I}},
	{"get_preferred_height_for_width",{P,P,P,I,I,I}},
	{"get_preferred_height",{P,P,P,I,I}},
	{"get_preferred_width_for_height",{P,P,P,I,I,I}},
	{"get_current_path",{P},S},
	{"apply_attributes",{P,P,P,B,B}},
	{"attribute_connect",{P,P,S,I}},
	{"attribute_disconnect",{P,P,S}},
	{"attribute_get_column",{P,P,S},I}, -- 3.14
	{"is_activatable",{P},B},
	{"activate",{P,P,P,P,I,B},B},
	{"activate_cell",{P,P,P,P,P,I},B},
	{"focus",{P,I},B},
	{"set_focus_cell",{P,P}},
	{"get_focus_cell",{P},P,0,GtkCellRenderer},
	{"add_focus_sibling",{P,P,P}},
	{"remove_focus_sibling",{P,P,P}},
	{"is_focus_sibling",{P,P,P},B},
	{"get_focus_siblings",{P,P},X,0,GList},
	{"get_focus_from_sibling",{P,P},P,0,GtkCellRenderer},
	{"get_edited_cell",{P},P,0,GtkCellRenderer},
	{"get_edit_widget",{P},P,0,GtkCellEditable},
	{"stop_editing",{P,B}},
	{"inner_cell_area",{P,P,P,P}},
	{"request_renderer",{P,P,P,P,I,I,I}},
	{"class_install_property",{P,I,P}},
	{"class_find_cell_property",{P,S},P},
	{"class_list_cell_properties",{P,I},P},	
	{"snapshot",{P,P,P,P,P,P,I,B}}, -- GTK4	
"GtkCellArea"}

widget[GtkCellAreaCell] = {"gtk_cell_area_cell",
{GtkCellArea},
	{"set_property",{P,P,S,P}},
	{"get_property",{P,P,S,P}},
"GtkCellAreaCell"}

widget[GtkCellAreaBox] = {"gtk_cell_area_box",
{GtkCellLayout,GtkCellArea,GtkBuildable,GtkOrientable,GObject},
	{"new",{},P},
	{"pack_start",{P,P,B,B,B}},
	{"pack_end",{P,P,B,B,B}},
	{"set_spacing",{P,I}},
	{"get_spacing",{P},I},
"GtkCellAreaBox"}

widget[GtkCellAreaContext] = {"gtk_cell_area_context",
{GObject},
	{"get_area",{P},P,0,GtkCellArea},
	{"allocate",{P,I,I}},
	{"reset",{P}},
	{"get_preferred_width",{P,I,I}},
	{"get_preferred_height",{P,I,I}},
	{"get_preferred_height_for_width",{P,I,I,I}},
	{"get_preferred_width_for_height",{P,I,I,I}},
	{"get_allocation",{P,I,I}},
	{"push_preferred_width",{P,I,I}},
	{"push_preferred_height",{P,I,I}},
"GtkCellAreaContext"}

widget[GtkCellEditable] = {"gtk_cell_editable",
{GtkWidget},
	{"start_editing",{P,P}},
	{"editing_done",{P}},
	{"remove_widget",{P}},
"GtkCellEditable"}

widget[GtkCellLayout] = {"gtk_cell_layout",
{GObject},
	{"pack_start",{P,P,B}},
	{"pack_end",{P,P,B}},
	{"get_area",{P},P,0,GtkCellArea},
	{"get_cells",{P},X,0,GList},
	{"reorder",{P,P,I}},
	{"clear",{P}},
	{"add_attribute",{P,P,S,I}},
	{"set_cell_data_func",{P,P,P,P,P}},
	{"clear_attributes",{P,P}},
"GtkCellLayout"}

widget[GtkCellRenderer] = {"gtk_cell_renderer",
{GtkCellEditable,GObject},
	{"set_fixed_size",{P,I,I}},
	{"get_fixed_size",{P,I,I}},
	{"set_visible",{P,B}},
	{"get_visible",{P},B},
	{"set_sensitive",{P,B}},
	{"get_sensitive",{P},B},
	{"set_alignment",{P,F,F}},
	{"get_alignment",{P,F,F}},
	{"set_padding",{P,I,I}},
	{"get_padding",{P,I,I}},
	{"get_state",{P,P,I},I},
	{"is_activatable",{P},B},
	{"get_aligned_area",{P,P,I,P,P}},
	{"render",{P,P,P,P,P,I}},
	{"activate",{P,P,P,P,P,P,I},B},
	{"start_editing",{P,P,P,P,P,P,I},P,0,GtkCellEditable},
	{"stop_editing",{P,B}},
	{"get_preferred_height",{P,P,I,I}},
	{"get_preferred_width",{P,P,I,I}},
	{"get_preferred_height_for_width",{P,P,I,I,I}},
	{"get_preferred_width_for_height",{P,P,I,I,I}},
	{"get_preferred_size",{P,P,P,P}},
	{"get_request_mode",{P},I},
	
	{"snapshot",{P,P,P,P,P,I}}, -- GTK4
	
"GtkCellRenderer"}

-- Many properties exist for cell renderers, see GTK docs!

widget[GtkCellRendererAccel] = {"gtk_cell_renderer_accel",
{GtkCellRendererText,GtkCellRenderer,GObject},
	{"new",{},P},
"GtkCellRendererAccel"}

widget[GtkCellRendererCombo] = {"gtk_cell_renderer_combo",
{GtkCellRendererText,GtkCellRenderer,GObject},
	{"new",{},P},
	{"set_text_column",{P,I},-routine_id("setTextCol")},
"GtkCellRendererCombo"}

	function setTextCol(atom r, integer n)
	  set(r,"text-column",n)
	  return 1
	end function
	
widget[GtkAccessible] = {"gtk_accessible",
{GObject},
	{"get_widget",{P},P},
	{"set_widget",{P,P}},
"GtkAccessible"}

widget[GtkCellRendererText] = {"gtk_cell_renderer_text",
{GtkCellRenderer,GObject},
	{"new",{},P},
	{"set_fixed_height_from_font",{P,I}},
"GtkCellRendererText"}

widget[GtkCellRendererPixbuf] = {"gtk_cell_renderer_pixbuf",
{GtkCellRenderer,GObject},
	{"new",{},P},
"GtkCellRendererPixbuf"}

widget[GtkCellRendererProgress] = {"gtk_cell_renderer_progress",
{GtkOrientable,GtkCellRenderer,GObject},
	{"new",{},P},
"GtkCellRendererProgress"}

widget[GtkCellRendererSpin] = {"gtk_cell_renderer_spin",
{GtkCellRendererText,GtkCellRenderer,GObject},
	{"new",{},P},
"GtkCellRendererSpin"}

widget[GtkCellRendererSpinner] = {"gtk_cell_renderer_spinner",
{GtkCellRenderer,GObject},
	{"new",{},P},
"GtkCellRendererSpinner"}

widget[GtkCellRendererToggle] = {"gtk_cell_renderer_toggle",
{GtkCellRenderer,GObject},
	{"new",{},P},
	{"set_radio",{P,B}},
	{"get_radio",{P},B},
	{"set_active",{P,B}},
	{"get_active",{P},B},
	{"set_activatable",{P,B}},
	{"get_activatable",{P},B},
"GtkCellRendererToggle"}

widget[GtkTreeModelFilter] = {"gtk_tree_model_filter",
{GtkTreeModel,GtkTreeDragSource,GObject},
	{"new",{P,P},P},
	{"set_visible_func",{P,P,P,P}},
	{"set_modify_func",{P,I,P,P,P,P}},
	{"set_visible_column",{P,I}},
	{"get_model",{P},P,0,GtkTreeModel},
	{"convert_child_iter_to_iter",{P,P,P},B},
	{"convert_iter_to_child_iter",{P,P,P},B},
	{"convert_child_path_to_path",{P,P},P,0,GtkTreePath},
	{"convert_path_to_child_path",{P,P},P,0,GtkTreePath},
	{"refilter",{P}},
	{"clear_cache",{P}},
"GtkTreeModelFilter"}

widget[GtkTreeModelSort] = {"gtk_tree_model_sort",
{GtkTreeSortable,GtkTreeModel,GtkTreeDragSource,GObject},
	{"new",{P},-routine_id("newTMS")},
	{"new_with_model",{P},P},
	{"get_model",{P},P,0,GtkTreeModel},
	{"convert_child_path_to_path",{P,P},P,0,GtkTreePath},
	{"convert_child_iter_to_iter",{P,P,P},B},
	{"convert_path_to_child_path",{P,P},P,0,GtkTreePath},
	{"convert_iter_to_child_iter",{P,P,P}},
	{"reset_default_sort_func",{P}},
	{"clear_cache",{P}},
"GtkTreeModelSort"}

	function newTMS(atom filter)
	return gtk_func("gtk_tree_model_sort_new_with_model",{P},{filter})
	end function
	
widget[GtkListStore] = {"gtk_list_store", 
{GtkTreeModel,GtkTreeSortable,GtkTreeDragSource,GtkTreeDragDest,GtkBuildable,GObject},
	{"new",{P},-routine_id("newListStore")},
	{"clear",{P}},
	{"set_data",{P,P},-routine_id("ls_set_data")},
	{"get_data",{P},-routine_id("ls_get_data")},
	{"get_n_rows",{P},-routine_id("ls_get_n_rows")},
	{"get_n_cols",{P},-routine_id("ls_get_n_cols")},
	{"set_row_data",{P,I,P},-routine_id("ls_set_row_data")},
	{"get_row_data",{P,I},-routine_id("ls_get_row_data")},
	{"set_col_data",{P,I,I,P},-routine_id("ls_set_col_data")},
	{"get_col_data",{P,I,I},-routine_id("ls_get_col_data")},
	{"get_col_data_from_iter",{P,P,P},-routine_id("ls_get_col_data_from_iter")},
	{"remove_row",{P,I},-routine_id("ls_remove_row")},
	{"replace_row",{P,I,P},-routine_id("ls_replace_row")},
	{"insert_row",{P,I,P},-routine_id("ls_insert_row")},
	{"prepend_row",{P,P},-routine_id("ls_prepend_row")},
	{"append_row",{P,P},-routine_id("ls_append_row")},
	{"set_swap_rows",{P,I,I},-routine_id("ls_set_swap_rows")},
	{"set_move_before",{P,I,I},-routine_id("ls_set_move_before")},
	{"set_move_after",{P,I,I},-routine_id("ls_set_move_after")},
"GtkListStore"}

--------------------------------------------------------------------------
-- almost all calls to GtkListStore are overridden with Euphoria calls,
-- because the GTK versions are just too complex and tedious to set up,
-- making them impractical to use.
---------------------------------------------------------------------------

constant 
	TM1 = define_func("gtk_tree_model_get_iter_first",{P,P},I),
	TM2 = define_func("gtk_tree_model_iter_next",{P,P},I),
	TM3 = define_func("gtk_tree_model_get_iter_from_string",{P,P,P},P),
	TM4 = define_proc("gtk_tree_model_get",{P,P,I,P,I}),
	TM5 = define_func("gtk_tree_model_get_column_type",{P,I},I),
	LS0 = define_proc("gtk_list_store_clear",{P}),
	LS1 = define_proc("gtk_list_store_insert",{P,P,I}),
	LS2 = define_proc("gtk_list_store_append",{P,P}),
	LS3 = define_proc("gtk_list_store_swap",{P,P,P}),
	LS4 = define_proc("gtk_list_store_move_before",{P,P,P}),
	LS5 = define_proc("gtk_list_store_move_after",{P,P,P}),
	LS6 = define_func("gtk_list_store_iter_is_valid",{P,P},B)

	function newListStore(object params)
	  object proto = I & repeat(P,length(params))
	  params = length(params) & params -- must build func params 'on the fly'
	  atom fn = define_func("gtk_list_store_new",proto,P)
	 return c_func(fn,params)
	end function

	function ls_get_n_rows(object store)
	 return gtk_func("gtk_tree_model_iter_n_children",{P,P},{store,0})
	end function 
	
	function ls_get_n_cols(object store)
	 return gtk_func("gtk_tree_model_get_n_columns",{P},{store}) 
	end function
	
	function ls_set_data(object store, object data)   
	  atom iter = allocate(32,1)
	  integer n = length(data)
	  for row = 1 to n do
	        if multi_tasking then 
			gtk_proc("gtk_main_iteration_do",{P},{1}) 
			set("progress","fraction",row/n)
		end if
		c_proc(LS1,{store,iter,length(data)}) -- new row
		if string(data[row]) then
			ls_set_row_data(store,row,{data[row]})
		else
			ls_set_row_data(store,row,data[row])
		end if
	  end for
	 return 1
	end function 
	
	function ls_set_row_data(atom store, integer row, object data)
	  integer max_col = ls_get_n_cols(store)
	  for col = 1 to math:min({length(data),max_col}) do 
		ls_set_col_data(store,row,col,data[col])
	  end for
	 return 1
	end function

	function ls_set_col_data(object store, object row, integer col, object data)
	 integer max_col = ls_get_n_cols(store)

	 if col < 1 or col > max_col then 
		crash("Invalid column #%d",col) 
	 end if
	
	 atom s = allocate_string(sprintf("%d",row-1))
	 atom iter = allocate(32,1)
	 if not c_func(TM3,{store,iter,s}) then
		return -1
	 end if

	object prototype  = {P,P,I,P,I}

	integer col_type = c_func(TM5,{store,col-1})

	switch col_type do
		case gSTR then prototype = {P,P,I,S,I}
		  if integer(data) then -- print w/o decimals;
		     data = sprintf("%d",data)
		  end if
		  if atom(data) then -- convert to 2 dp fmt (for convenience);
		     data = sprintf("%2.2f",data) 
		  end if
		case gDBL,gFLT then prototype = {P,P,I,D,I}
		case gINT,gBOOL then prototype = {P,P,I,I,I}
		case gPIX,gCOMBO then prototype = {P,P,I,P,I}
		case else crash(sprintf("\nError: invalid column type in col %d !\n******",col))
	end switch

	if string(data) then
		data = allocate_string(data) -- don't free these strings!
	end if
	
	atom fn = define_proc("gtk_list_store_set",prototype)
	object params = {store,iter,col-1,data,-1}
	c_proc(fn,params)

	return 1
	end function

	function ls_get_data(object store) 
	  object data = {}
	  for row = 1 to ls_get_n_rows(store) do
		data = append(data,ls_get_row_data(store,row))
	  end for
	 return data
	end function

	function ls_get_row_data(object store, integer row)
	  object data = {}
	  
	  integer max_row = ls_get_n_rows(store)
	  if row > max_row then return -1 end if
	
	  integer max_col = ls_get_n_cols(store) 
	  for i = 1 to max_col do
		data = append(data,ls_get_col_data(store,row,i))
	  end for
	  if max_col = 1 then 
	return data[1] else return data
	  end if
	end function 
	
	function ls_get_col_data(atom store, integer row, integer col)
	atom x  = allocate(32,1)
	object result 
	
	ifdef LISTSTORE then
		display("Get Col Data ~ row [] col []",{row,col},0)
	end ifdef
	
	integer col_type = c_func(TM5,{store,col-1})
	ifdef BITS64 then 
		poke8(x,col_type) 
	elsedef
		poke4(x,col_type) 
	end ifdef

	atom iter = allocate(64,1)
	
	c_func(TM3,{store,iter,allocate_string(sprintf("%d",row-1),1)})
		if gtk_func("gtk_list_store_iter_is_valid",{P,P},{store,iter}) = 0 then
		display("Error in ls_get_col_data 2 ") abort(0) end if
		
	c_proc(TM4,{store,iter,col-1,x,-1})
	if gtk_func("gtk_list_store_iter_is_valid",{P,P},{store,iter}) = 0 then
		display("Error in ls_get_col_data 3") abort(0) end if
		
	switch col_type do
		case gSTR then 
			ifdef BITS64 then -- thanks pete eberlein
						result = peek8u(x)
				elsedef 
						result = peek4u(x)
				end ifdef
				if result > 0 then
						result = peek_string(result)
				end if
		case gINT then result = peek4u(x)
		case gBOOL then result = peek(x)
		case gDBL then result = float64_to_atom(peek({x,8}))
		case gFLT then result = float32_to_atom(peek({x,4}))
		case gPIX then result = peek4u(x)
		case else display("Error in ls_get_col_data 4") abort(0) 
	end switch
	ifdef LISTSTORE then
		display(" = []",{result})
	end ifdef
	return result
	end function
		
	function ls_get_col_data_from_iter(atom store, atom iter, integer col)
	atom x  = allocate(128,1)
	object result
	
	ifdef LISTSTORE then
		display("Get Col Data from Iter ~ store [] iter [] col [] ",
		{store,iter,col},0)
	end ifdef
	
	integer col_type = c_func(TM5,{store,col-1})
	ifdef BITS64 then 
		poke8(x,col_type) 
	elsedef
		poke4(x,col_type) 
	end ifdef
	
	if gtk_func("gtk_list_store_iter_is_valid",{P,P},{store,iter}) = 0 then
		display("Error in ls_get_col_data_from_iter (invalid iter) ") 
		abort(0) 
	end if
		
	c_proc(TM4,{store,iter,col-1,x,-1})
	  
	   	if gtk_func("gtk_list_store_iter_is_valid",{P,P},{store,iter}) = 0 then
		display("Error in 6117 ls_get_col_data_from_iter 2 ") abort(0) end if
		
	switch col_type do
		case gSTR then 
			ifdef BITS64 then -- thanks Pete Eberlein;
				result = peek8u(x)
			elsedef 
				result = peek4u(x)
			end ifdef
			if result > 0 then
				result = peek_string(result)
			end if
		case gINT then result = peek4u(x)
		case gBOOL then result = peek(x)
		case gDBL then result = float64_to_atom(peek({x,8}))
		case gFLT then result = float32_to_atom(peek({x,4}))
		case gPIX then result = peek4u(x)
		case else display("Error in ls_get_col_data_from_iter 3") abort(0) 
	end switch
	ifdef LISTSTORE then
		display(" = []",{result})
	end ifdef
	return result
	end function
		   
	function ls_insert_row(object store, object data, integer pos)
	  object tmp = ls_get_data(store) 
	  tmp = insert(tmp,data,pos)
	  set(store,"clear")
	  ls_set_data(store,tmp)
	 return tmp
	end function
		
	function ls_append_row(atom store, object data)
	  object tmp = ls_get_data(store)
	  tmp = append(tmp,data)
	  set(store,"clear")
	  set(store,"data",tmp)
	 return tmp
	end function 
	
	function ls_prepend_row(atom store, object data)
	  object tmp = ls_get_data(store)
	  tmp = prepend(tmp,data)
	  set(store,"clear")
	  set(store,"data",tmp)
	 return tmp
	end function 
	
	function ls_remove_row(atom store, integer row)
	  object tmp = ls_get_data(store)
	  tmp = remove(tmp,row)
	  set(store,"clear")
	  ls_set_data(store,tmp)
	 return tmp
	end function 
	
	function ls_replace_row(atom store, object data, integer row)
	  object tmp = ls_get_data(store)
	  set(store,"clear") 
	  tmp = replace(tmp,{data},row)
	  ls_set_data(store,tmp)
	 return tmp
	end function 

	function ls_set_swap_rows(atom store, integer row_a, integer row_b)
	  if get(store,"is sorted") then
		Warn(,,"Can't move items in a sorted list!")
		return -1
	  end if
	  atom iter_a = allocate(32,1), iter_b = allocate(32,1)
	  c_func(TM3,{store,iter_a,allocate_string(sprintf("%d",row_a-1),1)})
	  c_func(TM3,{store,iter_b,allocate_string(sprintf("%d",row_b-1),1)})
	  c_proc(LS3,{store,iter_a,iter_b})
	 return get(store,"data")
	end function
	
	function ls_set_move_before(atom store, integer row_a, integer row_b)
	  if get(store,"is sorted") then
		Error(0,,"Can't move items in a sorted list!")
		return -1
	  end if
	  atom iter_a = allocate(32,1), iter_b = allocate(32,1)
	  c_func(TM3,{store,iter_a,allocate_string(sprintf("%d",row_a-1),1)})
	  c_func(TM3,{store,iter_b,allocate_string(sprintf("%d",row_b-1),1)})
	  c_proc(LS4,{store,iter_b,iter_a})
	 return get(store,"data")
	end function
	
	function ls_set_move_after(atom store, integer row_a, integer row_b)
	  if get(store,"is sorted") then
		Error(0,,"Can't move items in a sorted list!")
		return -1
	  end if
	  atom iter_a = allocate(32,1), iter_b = allocate(32,1)
	  c_func(TM3,{store,iter_a,allocate_string(sprintf("%d",row_a-1),1)})
	  c_func(TM3,{store,iter_b,allocate_string(sprintf("%d",row_b-1),1)})
	  c_proc(LS5,{store,iter_b,iter_a})
	 return get(store,"data")
	end function
	
widget[GtkTreeStore] = {"gtk_tree_store",
{GtkTreeModel,GtkTreeDragSource,GtkTreeDragDest,GtkTreeSortable,GtkBuildable,GObject},
	{"new",{P},-routine_id("newTreeStore")},
	{"get_n_rows",{P},-routine_id("ts_get_n_rows")},
	{"get_n_cols",{P},-routine_id("ts_get_n_cols")},
	{"get_data",{P},-routine_id("ts_get_data")},
	{"set_data",{P,P},-routine_id("ts_set_data")},
	{"set_row_data",{P,P,P},-routine_id("ts_set_row_data")},
	{"remove_row",{P,I},-routine_id("ts_remove_row")},
	{"insert_row",{P,P,P,I}},
	{"insert_before",{P,P,P,P}},
	{"insert_after",{P,P,P,P}},
	{"prepend",{P,P,P}},
	{"append",{P,P,P}},
	{"is_ancestor",{P,P,P},B},
	{"iter_depth",{P,P},I},
	{"clear",{P}},
	{"swap",{P,P,P}},
	{"move_before",{P,P,P}},
	{"move_after",{P,P,P}},
"GtkTreeStore"}

	function newTreeStore(object params)
	  object proto = I & repeat(P,length(params))
	  params = length(params) & params -- must build func params 'on the fly'
	  atom fn = define_func("gtk_tree_store_new",proto,P)
	 return c_func(fn,params)
	end function
	
	function ts_get_n_rows(object store)
	 return gtk_func("gtk_tree_model_iter_n_children",{P,P},{store,0})
	end function 
	
	function ts_get_n_cols(object store)
	 return gtk_func("gtk_tree_model_get_n_columns",{P},{store})
	end function
	
	function ts_set_data(object store, object data)
	  atom iter = allocate(32,1)
	  for row = 1 to length(data) do
		gtk_proc("gtk_tree_store_append",{P,P,P},{store,iter,0}) 
		ts_set_row_data(store,data[row],iter)	
	  end for
	 return 1
	end function 
	
	constant TSA = define_proc("gtk_tree_store_append",{P,P,P})
	
	-- the following should really be recursive, but that's too complicated 
	-- for me to figure out! Anyway, four deep should be enough.
	
	function ts_set_row_data(atom store, object data, object parent = 0)
	atom iter1 = allocate(32,1) 
	atom iter2 = allocate(32,1)
	atom iter3 = allocate(32,1)
	atom iter4 = allocate(32,1)
	for i = 1 to length(data) do
		if string(data[i]) then
			ts_set_row_col_data(store,parent,i,data[i])
		else
			for j = 1 to length(data[i]) do
				if string(data[i][j]) then
					c_proc(TSA,{store,iter1,parent})
					ts_set_row_col_data(store,iter1,1,data[i][j])
				else
					for k = 1 to length(data[i][j]) do
						if string(data[i][j][k]) then
							c_proc(TSA,{store,iter2,iter1})
							ts_set_row_col_data(store,iter2,1,data[i][j][k])
						else
							for l = 1 to length(data[i][j][k]) do
								if string(data[i][j][k][l]) then
									c_proc(TSA,{store,iter3,iter2})
									ts_set_row_col_data(store,iter3,1,data[i][j][k][l])
								else
									for m = 1 to length(data[i][j][k][l]) do
										c_proc(TSA,{store,iter4,iter3})
										ts_set_row_col_data(store,iter4,1,data[i][j][k][l][m])
									end for
								end if
							end for
						end if
					end for
				end if
			end for
		end if
	end for
	return 1
	end function

	function ts_set_row_col_data(object store, object iter, integer col, object item)
	  integer max_col = ts_get_n_cols(store)
	  if col < 1 or col > max_col then 
		crash("Invalid column #%d",col) 
	  end if
	
	  object prototype  = {P,P,I,P,I}
	
	  integer col_type

	  col_type = c_func(TM5,{store,col-1})
	  switch col_type do
		case gDBL then prototype = {P,P,I,D,I}
		case gFLT then prototype = {P,P,I,F,I}
		case gSTR, gPIX then prototype = {P,P,I,P,I} 
		case gBOOL,gINT then prototype = {P,P,I,I,I}
			if atom(item) then item = sprintf("%g",item) end if
		case else Warn(,,"Unknown column type",
			"Expecting gSTR, gBOOL, gINT, gDBL, gFLT, or gPIX") 
	  end switch

	  if string(item[1]) then item = item[1] end if
	  if string(item) then item = allocate_string(item,1) end if

	  atom fn = define_proc("gtk_tree_store_set",prototype)
	  object params = {store,iter,col-1,item,-1}
	  c_proc(fn,params)
		
	 return iter
	end function
	
	function ts_get_data(atom store)
	  object rowdata = {}
	  object column = {}
	  for row = 1 to ts_get_n_rows(store) do
		for col = 1 to ts_get_n_cols(store) do
			column = append(column,get(store,"col data",col))
		end for
		rowdata = append(rowdata,column)
		column = {}
	 end for
	 return rowdata
	end function
	
	function ts_remove_row(atom store, integer row)
	  object tmp = get(store,"data")
	  tmp = remove(tmp,row)
	  set(store,"data",tmp)
	 return tmp
	end function
	
widget[GtkTreeDragSource] = {"gtk_tree_drag_source",
{0},
"GtkTreeDragSource"}

widget[GtkTreeDragDest] = {"gtk_tree_drag_dest",
{0},
"GtkTreeDragDest"}

widget[GtkTreePath] = {"gtk_tree_path",
{GObject},
	{"new",{P},-routine_id("newTreePath")},
	{"to_string",{P},S},
	{"to_integer",{P},-routine_id("tp_to_integer")},
	{"new_first",{},P,0,GtkTreePath},
	{"append_index",{P,I}},
	{"prepend_index",{P,I}},
	{"get_depth",{P},I},
	{"get_indices",{P},A},
	{"get_indices_with_depth",{P,I},A},
	{"free",{P}},
	{"copy",{P},P,0,GtkTreePath},
	{"compare",{P,P},I},
	{"next",{P}},
	{"prev",{P},B},
	{"up",{P},B},
	{"down",{P}},
	{"is_ancestor",{P,P},B},
	{"is_descendant",{P,P},B},
"GtkTreePath"}

	function newTreePath(object x=0)
	  if atom(x) and x > 0 then
		x = sprintf("%d",x-1)
	  end if
	  if string(x) then
		x = allocate_string(x,1)
	  end if
	  if x > 0 then
		return gtk_func("gtk_tree_path_new_from_string",{P},{x})
	   else 
		return gtk_func("gtk_tree_path_new",{},{})
	  end if
	end function 
	
	function tp_to_integer(object x)
	  integer n = to_number(gtk_str_func("gtk_tree_path_to_string",{P},{x}))
	 return n+1
	end function 
	
widget[GtkTreeRowReference] = {"gtk_tree_row_reference",
{GObject},
	{"new",{P,P},P,0,GtkTreeRowReference},
	{"get_model",{P},P,0,GtkTreeModel},
	{"get_path",{P},P,0,GtkTreePath},
	{"valid",{P},B},
	{"free",{P}},
	{"copy",{P},P,0,GtkTreeRowReference},
	{"inserted",{P,P}},
	{"deleted",{P,P}},
	{"reordered",{P,P,P,A}},
"GtkTreeRowReference"}

widget[GtkTreeIter] = {"gtk_tree_iter",
{GObject},
	{"new",{},-routine_id("newTreeIter")},
	{"copy",{P},P,0,GtkTreeIter},
	{"free",{P}},
"GtkTreeIter"}

	function newTreeIter()
	return allocate(64) -- keep;
	end function

widget[GtkTreeModel] = {"gtk_tree_model",
{GObject},
	{"get_flags",{P},I},
	{"get_n_columns",{P},I},
	{"get_column_type",{P,I},I},
	{"get_iter",{P,P,P},B},
	{"get_iter_first",{P,P},B},
	{"get_path",{P,P},P,0,GtkTreePath},
	{"get_value",{P,P,I},-routine_id("tm_get_value")},
	{"set_value",{P,I,I,P},-routine_id("tm_set_value")},
	{"iter_next",{P,P},B},
	{"iter_previous",{P,P},B},
	{"iter_children",{P,P,P},B},
	{"iter_has_child",{P,P},B},
	{"iter_n_children",{P,P},I},
	{"iter_nth_child",{P,P,P,I},B},
	{"iter_parent",{P,P,P},B},
	{"get_string_from_iter",{P,P},-routine_id("tm_get_string_from_iter")},
	{"ref_node",{P,P}},
	{"unref_node",{P,P}},
	{"foreach",{P,P,P}},
	{"n_rows",{P},-routine_id("tm_get_n_rows")},
	{"row_changed",{P,P,P}},
	{"row_inserted",{P,P,P}},
	{"row_has_child_toggled",{P,P,P}},
	{"row_deleted",{P,P}},
	{"rows_reordered",{P,P,P,P}},
	{"get_iter_n",{P,I},-routine_id("tm_get_iter_n")},
	{"get_iter_from_string",{P,P},-routine_id("tm_get_iter_from_string")},
	{"get_iter_from_path",{P,P},-routine_id("tm_get_iter_from_path")},
	{"get_col_value",{P,P,I},-routine_id("tm_get_col_value")},
	{"get_row_values",{P,P},-routine_id("tm_get_row_values")},
	{"get_col_data",{P,P,P},-routine_id("tm_get_col_data")},
	{"get_row_data",{P,I},-routine_id("tm_get_row_values")},
"GtkTreeModel"}

	constant 
		fntmget = define_proc("gtk_tree_model_get_value",{P,P,I,P}),
		fncoltype = define_func("gtk_tree_model_get_column_type",{P,I},I),
		gtvfn = define_proc("gtk_tree_model_get",{P,P,I,P,I}),
		tmncol = define_func("gtk_tree_model_get_n_columns",{P},I)

	function tm_get_n_rows(atom model)
	  atom fn = define_func("gtk_tree_model_iter_n_children",{P,P},I)
	 return c_func(fn,{model,0})
	end function

	function tm_get_string_from_iter(atom model, atom iter)
	  atom fn = define_func("gtk_tree_model_get_string_from_iter",{P,P},P)
	 return peek_string(c_func(fn,{model,iter}))
	end function
	
	function tm_get_iter_from_string(atom model, object str)
	  atom iter = allocate(64) 
	  atom fn = define_func("gtk_tree_model_get_iter_from_string",{P,P,P},P)
	  if string(str) then str = allocate_string(str,1) end if
	  if c_func(fn,{model,iter,str}) then
		return iter
	  end if
	 return 0
	end function

	function tm_get_iter_n(atom model, integer path)
	 return tm_get_iter_from_string(model,sprintf("%d",path-1))
	end function

	function tm_get_iter_from_path(atom model, object path)
	 return tm_get_iter_from_string(model,peek_string(path))
	end function

	function tm_get_value(atom mdl, atom iter, integer col)
	  atom x  = allocate(64,1)
	  integer ct = c_func(fncoltype,{mdl,col-1})
	  object result
	
	  ifdef BITS64 then 
		poke8(x,ct) 
	  elsedef
		poke4(x,ct) 
	  end ifdef
	
	  c_proc(gtvfn,{mdl,iter,col-1,x,-1}) 
	  switch ct do
		 case gSTR then 
			ifdef BITS64 then -- thanks Pete Eberlein;
				result = peek8u(x)
			elsedef 
				result = peek4u(x)
			end ifdef
			if result > 0 then
				return peek_string(result)
			else
				return sprintf("%d",result)
			end if
		case gBOOL,gINT then return peek4u(x)
		case gFLT then return float32_to_atom(peek({x,4}))
		case gPIX then return peek4u(x)
		case else return sprintf("%d",x)
	  end switch
	 return sprintf("Oops %d",ct)
	end function

	function tm_get_row_values(atom mdl, atom iter)
	  integer ncols = c_func(tmncol,{mdl}) 
	  object results = repeat(0,ncols)
	  for n = 1 to ncols do
		results[n] = tm_get_value(mdl,iter,n)
	  end for
	 return results
	end function

	function tm_get_col_value(atom mdl, integer row, integer col)
	  atom iter = allocate(32,1)
	  object data = tm_get_row_values(mdl,iter)
	 return data[col]
	end function

	function tm_set_col_value(atom mdl, integer row, integer col, object data)
	  atom iter = tm_get_iter_n(mdl,row) 
	  atom fn = define_proc("gtk_list_store_set",{P,P,I,P,I})
	  if string(data) then data = allocate_string(data,1) end if
	  c_proc(fn,{mdl,iter,col-1,data,-1})
	 return 1
	end function
	
	function tm_get_col_data(atom mdl, integer row, integer col)
	  atom iter = tm_get_iter_n(mdl,row) 
	  object data = tm_get_row_values(mdl,iter)
	 return data[col]
	end function

widget[GtkTreeSortable] = {"gtk_tree_sortable",
{GtkTreeModel,GObject},
	{"sort_column_changed",{P}},
	{"set_sort_column_id",{P,I,I}},
	{"get_sort_column_id",{P},-routine_id("ts_get_sort_col_id")},
	{"is_sorted",{P},-routine_id("ts_is_sorted")},
	{"get_sort_order",{P},-routine_id("ts_get_sort_order")},
	{"set_sort_func",{P,I,P,P,P}},
	{"set_default_sort_func",{P,P,P,P}},
	{"has_default_sort_func",{P},B},
"GtkTreeSortable"}

	function ts_is_sorted(atom mdl)
	atom col = allocate(64), ord = allocate(64)
	return gtk_func("gtk_tree_sortable_get_sort_column_id",{P,P,P},{mdl,col,ord})
	end function
	
	function ts_get_sort_order(atom mdl)
	atom col = allocate(64),ord = allocate(64)
	object result = gtk_func("gtk_tree_sortable_get_sort_column_id",{P,P,P},{mdl,col,ord})
	if result=TRUE then return peek4u(ord) else return -1 end if
	end function
		
	function ts_get_sort_col_id(atom mdl)
	  atom col = allocate(64), ord = allocate(64)
	  object result = gtk_func("gtk_tree_sortable_get_sort_column_id",{P,P,P},{mdl,col,ord}) 
	  if result=TRUE then return peek4u(col)+1 else return -1 end if
	end function
	
widget[GtkViewport] = {"gtk_viewport",
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GtkScrollable,GObject},
	{"new",{P,P},P},
	{"set_shadow_type",{P,I}},
	{"get_shadow_type",{P},I},
"GtkViewport"}

widget[GtkAppChooserWidget] = {"gtk_app_chooser_widget",
{GtkBox,GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GtkAppChooser,GObject},
	{"new",{S},P},
	{"set_show_default",{P,B}},
	{"get_show_default",{P},B},
	{"set_show_recommended",{P,B}},
	{"get_show_recommended",{P},B},
	{"set_show_fallback",{P,B}},
	{"get_show_fallback",{P},B},
	{"set_show_other",{P,B}},
	{"get_show_other",{P},B},
	{"set_show_all",{P,B}},
	{"get_show_all",{P},B},
	{"set_default_text",{P,S}},
	{"get_default_text",{P},S},
"GtkAppChooserWidget"}

widget[GtkVolumeButton] = {"gtk_volume_button",
{GtkScaleButton,GtkButton,GtkBin,GtkContainer,GtkWidget,GtkBuildable,
GtkOrientable,GObject},
	{"new",{},P},
"GtkVolumeButton"}

widget[GtkColorChooserWidget] = {"gtk_color_chooser_widget",
{GtkColorChooser,GtkBox,GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{},P},
"GtkColorChooserWidget"}

widget[GtkColorChooser] = {"gtk_color_chooser",
{GObject},
	{"set_rgba",{P,P},-routine_id("cc_set_rgba")},
	{"get_rgba",{P,I},-routine_id("cc_get_rgba")},
	{"set_use_alpha",{P,B},-routine_id("cc_set_alpha")},
	{"get_use_alpha",{P},-routine_id("cc_get_alpha")},
	{"add_palette",{P,I,I,I,A}},
"GtkColorChooser"}

-- color chooser utilities;

	function cc_set_rgba(atom x, object c)
	  if string(c) then
		  c = to_rgba(c)
	  else
		  c = to_rgba(text:format("#[X]",c))
	  end if
	  gtk_proc("gtk_color_chooser_set_rgba",{P,P},{x,c})
	 return 1
	end function

	function cc_get_rgba(atom x, integer fmt)
	  atom fn = define_proc("gtk_color_chooser_get_rgba",{P,P})
	  atom rgba = allocate(32,1)
	  c_proc(fn,{x,rgba})
	  object c = gtk_func("gdk_rgba_to_string",{P},{rgba})
	 return fmt_color(c,fmt)
	end function

	function cc_set_alpha(atom x, integer b)
	  gtk_proc("gtk_color_chooser_set_use_alpha",{P,B},{x,b})
	 return 1
	end function

	function cc_get_alpha(atom x)
	  atom fn = define_func("gtk_color_chooser_get_use_alpha",{P},B)
	 return c_func(fn,{x})
	end function

------------------------------------------------------------------------
-- following color functions make using RGB colors much easier, 
-- converting automatically between various color notations;
------------------------------------------------------------------------

	function cs_set_current_rgba(atom x, object c)
	  c =peek_string(c)
	  gtk_proc("gtk_color_selection_set_current_rgba",{P,P},{x,to_rgba(c)})
	 return 1
	end function

	function cs_set_previous_rgba(atom x, object c)
	  c = peek_string(c)
	  gtk_proc("gtk_color_selection_set_previous_rgba",{P,P},{x,to_rgba(c)})
	 return 1
	end function

	function cs_get_current_rgba(atom x, integer fmt=0)
	  atom rgba = allocate(32,1) 
	  atom fn = define_proc("gtk_color_selection_get_current_rgba",{P,P})
	  c_proc(fn,{x,rgba}) 
	  object c = gtk_func("gdk_rgba_to_string",{P},{rgba})
	 return fmt_color(c,fmt)
	end function

	function cs_get_previous_rgba(atom x, integer fmt=0)
	  atom rgba = allocate(32,1)
	  atom fn = define_proc("gtk_color_selection_get_previous_rgba",{P,P})
	  c_proc(fn,{x,rgba})
	  object c = gtk_func("gdk_rgba_to_string",{rgba})
	 return fmt_color(c,fmt)
	end function

widget[GtkNativeDialog] = {"gtk_native_dialog",
{GtkBuilder,GObject},
	{"show",{P}},
	{"hide",{P}},
	{"destroy",{P}},
	{"get_visible",{P},B},
	{"set_modal",{P,B}},
	{"get_modal",{P},B},
	{"set_title",{P,S}},
	{"get_title",{P},S},
	{"set_transient_for",{P,P}},
	{"get_transient_for",{P},P},
	{"run",{P}},
"GtkNativeDialog"}
	
widget[GtkFileChooserNative] = {"gtk_file_chooser_native",
{GtkFileChooser,GtkNativeDialog,GtkBuilder,GObject},
	{"new",{S,P,I,S,S},P},
	{"get_accept_label",{P},S},
	{"set_accept_label",{P,S}},
	{"get_cancel_label",{P},S},
	{"set_cancel_label",{P,S}},
"GtkFileChooserNative"}

widget[GtkFileChooser] = {"gtk_file_chooser",
{GtkWidget},
	{"set_action",{P,I}},
	{"get_action",{P},I},
	{"set_local_only",{P,B}},
	{"get_local_only",{P},B},
	{"set_select_multiple",{P,B}},
	{"get_select_multiple",{P},B},
	{"set_show_hidden",{P,B}},
	{"get_show_hidden",{P},B},
	{"set_do_overwrite_confirmation",{P,B}},
	{"get_do_overwrite_confirmation",{P},B},
	{"set_create_folders",{P,B}},
	{"get_create_folders",{P},B},
	{"get_current_name",{P},S}, --GTK3.10
	{"set_current_name",{P,S}},
	{"set_filename",{P,S}},
	{"get_filename",{P},S},
	{"get_filenames",{P},A,0,GSList},
	{"select_filename",{P,S}},
	{"unselect_filename",{P},S},
	{"select_all",{P}},
	{"unselect_all",{P}},
	{"set_current_folder",{P,S}},
	{"get_current_folder",{P},S},
	{"set_uri",{P,S}},
	{"get_uri",{P},S},
	{"select_uri",{P,S}},
	{"unselect_uri",{P,S}},
	{"get_uris",{P},A,0,GSList},
	{"set_current_folder_uri",{P,S}},
	{"get_current_folder_uri",{P},S},
	{"set_preview_widget",{P,P}},
	{"get_preview_widget",{P},P,0,GtkWidget},
	{"set_preview_widget_active",{P,B}},
	{"get_preview_widget_active",{P},B},
	{"set_use_preview_label",{P,B}},
	{"get_use_preview_label",{P},B},
	{"get_preview_filename",{P},S},
	{"get_preview_uri",{P},S},
	{"set_extra_widget",{P,P}},
	{"get_extra_widget",{P},P,0,GtkWidget},
	{"add_filter",{P,P}},
	{"remove_filter",{P,P}},
	{"list_filters",{P},X,0,GSList},
	{"set_filter",{P,P}},
	{"get_filter",{P},P,0,GtkFileFilter},
	{"add_shortcut_folder",{P,S,P},B},
	{"remove_shortcut_folder",{P,S,P},B},
	{"list_shortcut_folders",{P},A,0,GSList},
	{"add_shortcut_folder_uri",{P,S,P},B},
	{"remove_shortcut_folder_uri",{P,S,P},B},
	{"list_shortcut_folder_uris",{P},A,0,GSList},
	{"get_current_folder_file",{P},P,0,GFile},
	{"get_file",{P},P,0,GFile},
	{"get_files",{P},X,0,GFile},
	{"get_preview_file",{P},P,0,GFile},
	{"select_file",{P,P,P},B},
	{"set_current_folder_file",{P,P,P},B},
	{"set_file",{P,P,P},B},
	{"unselect_file",{P,P}},
"GtkFileChooser"}

widget[GtkFileChooserButton] = {"gtk_file_chooser_button",
{GtkFileChooser,GtkBox,GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{S,I},P},
	{"new_with_dialog",{P},P},
	{"set_title",{P,S}},
	{"get_title",{P},S},
	{"set_width_chars",{P,I}},
	{"get_width_chars",{P},I},
	{"set_focus_on_click",{P,B}},
	{"get_focus_on_click",{P},B},
"GtkFileChooserButton"}

widget[GtkFileChooserWidget] = {"gtk_file_chooser_widget",
{GtkFileChooser,GtkBox,GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{I},P},
"GtkFileChooserWidget"}

widget[GtkFileFilter] = {"gtk_file_filter",
{GtkBuildable,GObject},
	{"new",{},P},
	{"set_name",{P,S}},
	{"get_name",{P},S},
	{"add_mime_type",{P,S}},
	{"add_pattern",{P,S}},
	{"add_pixbuf_formats",{P}},
	{"add_custom",{P,I,P,P,P}},
	{"get_needed",{P},I},
	{"filter",{P,P},B},
"GtkFileFilter"}

widget[GtkFontChooser] = {"gtk_font_chooser",
{GObject},
	{"get_font_family",{P},P,0,PangoFontFamily},
	{"get_font_face",{P},P,0,PangoFontFace},
	{"get_font_size",{P},I},
	{"set_font",{P,S}},
	{"get_font",{P},S},
	{"set_font_desc",{P,P}},
	{"get_font_desc",{P},P,0,PangoFontDescription},
	{"set_preview_text",{P,S}},
	{"get_preview_text",{P},S},
	{"set_show_preview_entry",{P,B}},
	{"get_show_preview_entry",{P},B},
	{"set_filter_func",{P,P,P,P}},
	{"get_font_map",{P},P,0,PangoFontMap}, -- 3.18
	{"set_font_map",{P,P}}, -- 3.18	
	{"get_font_features",{P},S}, -- GTK4
	{"get_level",{P},I}, -- GTK4
	{"set_level",{P,I}}, -- GTK4	
"GtkFontChooser"}

widget[GtkFontChooserWidget] = {"gtk_font_chooser_widget",
{GtkFontChooser,GtkBox,GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{},P},
"GtkFontChooserWidget"}

widget[GtkInfoBar] = {"gtk_info_bar",
{GtkBox,GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{},P},
	{"add_action_widget",{P,P,I}},
	{"add_button",{P,S,I},P,0,GtkButton},
	{"set_response_sensitive",{P,I,B}},
	{"set_default_response",{P,I}},
	{"response",{P,I}},
	{"set_message_type",{P,I}},
	{"get_message_type",{P},I},
	{"get_action_area",{P},P,0,GtkBox},
	{"get_content_area",{P},P,0,GtkBox},
	{"set_show_close_button",{P,B}}, -- 3.10
	{"get_show_close_button",{P},B}, -- 3.10	
	{"set_revealed",{P,B}}, -- 3.22.29
	{"get_revealed",{P},B}, -- 3.22.29	
"GtkInfoBar"}

widget[GtkRecentChooser] = {"gtk_recent_chooser",
{GObject},
	{"set_show_private",{P,B}},
	{"get_show_private",{P},B},
	{"set_show_not_found",{P,B}},
	{"get_show_not_found",{P},B},
	{"set_show_icons",{P,B}},
	{"get_show_icons",{P},B},
	{"set_select_multiple",{P,B}},
	{"get_select_multiple",{P},B},
	{"set_local_only",{P,B}},
	{"get_local_only",{P},B},
	{"set_limit",{P,I}},
	{"get_limit",{P},I},
	{"set_show_tips",{P,B}},
	{"get_show_tips",{P},B},
	{"set_sort_type",{P,I}},
	{"get_sort_type",{P},I},
	{"set_sort_func",{P,P,P,P}},
	{"set_current_uri",{P,S,P},B},
	{"get_current_uri",{P},S},
	{"get_current_item",{P},P,0,GtkRecentInfo},
	{"select_uri",{P,S,P},B},
	{"unselect_uri",{P,S}},
	{"select_all",{P}},
	{"unselect_all",{P}},
	{"get_items",{P},A,0,GSList},
	{"get_uris",{P},A},
	{"add_filter",{P,P}},
	{"remove_filter",{P,P}},
	{"list_filters",{P},X,0,GSList},
	{"set_filter",{P,P}},
	{"get_filter",{P},P,0,GtkRecentFilter},
"GtkRecentChooser"}

widget[GtkRecentChooserWidget] = {"gtk_recent_chooser_widget",
{GtkBox,GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GtkRecentChooser,GObject},
	{"new",{P},-routine_id("newRecentChooserWidget")},
"GtkRecentChooserWidget"}

	function newRecentChooserWidget(atom x=0)
	  if class_id(x) = GtkRecentManager then
		return gtk_func("gtk_recent_chooser_widget_new_for_manager",{P},{x})
	  else
		return gtk_func("gtk_recent_chooser_widget_new")
	  end if
	end function
	
widget[GtkStatusbar] = {"gtk_statusbar",
{GtkBox,GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{},P},
	{"get_context_id",{P,P},I},
	{"push",{P,I,S},I},
	{"pop",{P,I}},
	{"remove",{P,I,I}},
	{"remove_all",{P,I}},
	{"get_message_area",{P},P},
"GtkStatusBar"}

widget[GtkFixed] = {"gtk_fixed",
{GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"put",{P,P,I,I}},
	{"move",{P,P,I,I}},
"GtkFixed"}

widget[GtkGrid] = {"gtk_grid",
{GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{},P},
	{"attach",{P,P,I,I,I,I}},
	{"attach_next_to",{P,P,P,I,I,I}},
	{"attach_beside",{P,P,P,I,I,I},-routine_id("AttachBeside")}, -- alias;
	{"attach_above",{P,P,P,I,I},-routine_id("AttachAbove")}, -- alias;
	{"attach_below",{P,P,P,I,I},-routine_id("AttachBelow")}, -- alias;
	{"get_child_at",{P,I,I},P,0,GtkWidget},
	{"insert_row",{P,I}},
	{"remove_row",{P,I}}, --3.10
	{"insert_column",{P,I}},
	{"remove_column",{P,I}}, --3.10
	{"insert_next_to",{P,P,I}},
	{"set_row_homogeneous",{P,B}},
	{"get_row_homogeneous",{P},B},
	{"set_column_homogeneous",{P,B}},
	{"get_column_homogeneous",{P},B},
	{"set_row_spacing",{P,I}},
	{"get_row_spacing",{P},I},
	{"set_column_spacing",{P,I}},
	{"get_column_spacing",{P},I},
	{"set_baseline_row",{P,I}}, --3.10
	{"get_baseline_row",{P},I}, --3.10
	{"set_row_baseline_position",{P,I,I}}, --3.10
	{"get_row_baseline_position",{P,I},I}, --3.10
"GtkGrid"}

	function AttachBeside(atom grid, atom a, atom b, integer side, integer w, integer h)
	return set(grid,"attach_next_to",b,a,side,w,h)
	end function
	
	function AttachAbove(atom grid, atom a, atom b, integer w, integer h)
	return set(grid,"attach_next_to",b,a,2,w,h)
	end function
	
	function AttachBelow(atom grid, atom a, atom b, integer w, integer h)
	return set(grid,"attach_next_to",b,a,3,w,h)
	end function
	
widget[GtkPaned] = {"gtk_paned",
{GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{I},P},
	{"add1",{P,P}},
	{"add2",{P,P}},
	{"pack1",{P,P,B,B}},
	{"pack2",{P,P,B,B}},
	{"get_child1",{P},P,0,GtkWidget},
	{"get_child2",{P},P,0,GtkWidget},
	{"set_position",{P,I}},
	{"get_position",{P},P},
	{"get_handle_window",{P},P,0,GdkWindow},
	{"get_wide_handle",{P},B}, -- 3.16
	{"set_wide_handle",{P,B}}, -- 3.16
"GtkPaned"}

widget[GtkIconInfo] = {"gtk_icon_info",
{GObject},
	{"new",{P,P},-routine_id("newIconInfo")},
	{"get_base_size",{P},I},
	{"get_base_scale",{P},I}, --3.10
	{"get_filename",{P},S},
	{"get_display_name",{P},S}, -- deprecated 3.14
	{"get_builtin_pixbuf",{P},P,0,GdkPixbuf}, -- deprecated 3.14
	{"load_icon",{P},-routine_id("icon_info_load_icon")},
	{"load_surface",{P,P,P},P,0,CairoSurface_t},
	{"load_icon_async",{P,P,P,P}},
	{"load_icon_finish",{P,P,P},P,0,GdkPixbuf},
	{"load_symbolic",{P,P,P,P,P,B,P},P,0,GdkPixbuf},
	{"load_symbolic_async",{P,P,P,P,P,P,P,P}},
	{"load_symbolic_finish",{P,P,P,P},P,0,GdkPixbuf},
	{"load_symbolic_for_context",{P,P,P,P},P,0,GdkPixbuf},
	{"load_symbolic_for_context_async",{P,P,P,P,P}},
	{"load_symbolic_for_context_finish",{P,P,P,P},P,0,GdkPixbuf},
	{"set_raw_coordinates",{P,B}}, -- deprecated 3.14
	{"get_embedded_rect",{P,P},B}, -- deprecated 3.14
	{"get_attach_points",{P,A,P},B}, -- deprecated 3.14
	{"is_symbolic",{P},B}, -- 3.12
"GtkIconInfo"}
	
	function newIconInfo(atom theme, atom pix) -- reorder params;
	 return gtk_func("gtk_icon_info_new_for_pixbuf",{P,P},{theme,pix})
	end function
	
	function icon_info_load_icon(atom info) -- allow for err, register object;
	  atom err = allocate(8,1) err = 0
	  atom icn = gtk_func("gtk_icon_info_load_icon",{P,P},{info,err})
	  register(icn,GdkPixbuf)
	 return icn
	end function

widget[GtkIconTheme] = {"gtk_icon_theme",
{GObject},
	{"new",{P},-routine_id("newIconTheme")}, -- gets default if no screen given;
	{"set_screen",{P,P}},
	{"set_search_path",{P,S,I}},
	{"get_search_path",{P,P,I}},
	{"append_search_path",{P,S}},
	{"prepend_search_path",{P,S}},
	{"set_custom_theme",{P,S}},
	{"has_icon",{P,S},B},
	{"lookup_icon",{P,P,I,I},P,0,GtkIconInfo},
	{"lookup_icon_for_scale",{P,P,I,I,I},P,0,GtkIconInfo},
	{"choose_icon",{P,A,I,I},P,0,GtkIconInfo},
	{"choose_icon_for_scale",{P,A,I,I,I},P,0,GtkIconInfo},
	{"lookup_by_gicon",{P,P,I,I},P,0,GtkIconInfo},
	{"load_icon",{P,S,I,I},-routine_id("icon_theme_load_icon")},
	{"load_icon_for_scale",{P,S,I,I,I,P},P,0,GdkPixbuf},
	{"load_surface",{P,S,I,I,P,I,P},P,0,CairoSurface_t},
	{"list_contexts",{P},-routine_id("icon_theme_list_contexts")},
	{"list_icons",{P,S},-routine_id("icon_theme_list_icons")},
	{"get_icon_sizes",{P,S},A},
	{"rescan_if_needed",{P},B},
	{"get_example_icon_name",{P},S},
	{"add_builtin_icon",{S,I,P}}, -- deprecated 3.14
	{"add_resource_path",{P,S}}, -- 3.14
"GtkIconTheme"}

	function newIconTheme(atom x=0)
	  if class_id(x) = GdkScreen then
		return gtk_func("gtk_icon_theme_get_for_screen",{P},{x})
	  else
		return gtk_func("gtk_icon_theme_get_default")
	  end if
	end function
	
	function icon_theme_load_icon(atom theme, object name, integer size, integer flags)
	  atom err = allocate(8,1) err = 0
	 return gtk_func("gtk_icon_theme_load_icon",{P,P,I,I,P},{theme,name,size,flags,err})
	end function
	
	function icon_theme_list_contexts(atom theme)
	  object list = gtk_func("gtk_icon_theme_list_contexts",{P},{theme})
	 return to_sequence(list)
	end function

	function icon_theme_list_icons(atom theme, object context)
	  object list = gtk_func("gtk_icon_theme_list_icons",{P,P},{theme,context})
	 return to_sequence(list)
	end function

widget[GtkIconView] = {"gtk_icon_view",
{GtkCellLayout,GtkScrollable,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"new_with_area",{P},P},
	{"new_with_model",{P},P},
	{"set_model",{P,P}},
	{"get_model",{P},P,0,GtkTreeModel},
	{"set_text_column",{P,I}},
	{"get_text_column",{P},I},
	{"set_markup_column",{P,I}},
	{"get_markup_column",{P},I},
	{"set_pixbuf_column",{P,I}},
	{"get_pixbuf_column",{P},I},
	{"get_visible_range",{P,I,I},B},
	{"get_path_at_pos",{P,I,I},P,0,GtkTreePath},
	{"get_item_at_pos",{P,I,I,I,I},B},
	{"convert_widget_to_bin_window_coords",{P,I,I,I,I}},
	{"set_cursor",{P,P,P,B}},
	{"get_cursor",{P},-routine_id("getIVcursor")},
	{"selected_foreach",{P,P,P}},
	{"set_selection_mode",{P,I}},
	{"get_selection_mode",{P},I},
	{"set_columns",{P,I}},
	{"get_columns",{P},I},
	{"set_spacing",{P,I}},
	{"get_spacing",{P},I},
	{"set_row_spacing",{P,I}},
	{"get_row_spacing",{P},I},
	{"set_column_spacing",{P,I}},
	{"get_column_spacing",{P},I},
	{"set_margin",{P,I}},
	{"get_margin",{P},I},
	{"set_item_padding",{P,I}},
	{"get_item_padding",{P},I},
	{"set_activate_on_single_click",{P,B}}, --3.8
	{"get_activate_on_single_click",{P},B}, --3.8
	{"get_cell_rect",{P,P,P,P},B}, --3.6
	{"select_path",{P,P}},
	{"unselect_path",{P,P}},
	{"path_is_selected",{P,P},B},
	{"get_selected_items",{P},X,0,GList},
	{"select_all",{P}},
	{"unselect_all",{P}},
	{"item_activated",{P,P}},
	{"scroll_to_path",{P,P,B,F,F}},
	{"get_visible_range",{P,I,I},B},
	{"set_tooltip_item",{P,P,P}},
	{"set_tooltip_cell",{P,P,P,P}},
	{"get_tooltip_context",{P,I,I,B,P,P,P},B},
	{"set_tooltip_column",{P,I}},
	{"get_tooltip_column",{P},I},
	{"get_item_row",{P,P},I},
	{"get_item_column",{P,P},I},
	{"enable_model_drag_source",{P,I,P,I,I}},
	{"enable_model_drag_dest",{P,P,I,I}},
	{"unset_model_drag_source",{P}},
	{"unset_model_drag_dest",{P}},
	{"set_reorderable",{P,B}},
	{"get_reorderable",{P},B},
	{"set_drag_dest_item",{P,I,I}},
	{"get_drag_dest_item",{P,I,I}},
	{"get_dest_item_at_pos",{P,I,I,I,I},B},
	{"create_drag_icon",{P,P},P,0,CairoSurface_t},
"GtkIconView"}

  function getIVcursor(atom iv)
  atom fn = define_func("gtk_icon_view_get_cursor",{P,P,P},B)
  atom path = allocate(8), cell = allocate(8)
  if c_func(fn,{iv,path,cell}) = 1 then 
  return to_number(gtk_str_func("gtk_tree_path_to_string",{P},{peek4u(path)}))+1
  else return -1
  end if
  end function
  
widget[GtkLayout] = {"gtk_layout",
{GtkContainer,GtkWidget,GtkBuildable,GtkScrollable,GObject},
	{"new",{P,P},P},
	{"put",{P,P,I,I}},
	{"move",{P,P,I,I}},
	{"set_size",{P,I,I}},
	{"get_size",{P,I,I}},
	{"get_bin_window",{P},P,0,GdkWindow},
"GtkLayout"}

widget[GtkSeparatorMenuItem] = {"gtk_separator_menu_item",
{GtkMenuItem,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
"GtkSeparatorMenuItem"}

widget[GtkRecentChooserMenu] = {"gtk_recent_chooser_menu",
{GtkMenu,GtkMenuShell,GtkContainer,GtkWidget,GtkBuildable,GtkRecentChooser,GObject},
	{"new",{},P},
	{"new_for_manager",{P},P},
	{"set_show_numbers",{P,B}},
	{"get_show_numbers",{P},B},
"GtkRecentChooserMenu"}

widget[GtkRecentFilter] = {"gtk_recent_filter",
{GtkBuildable,GObject},
	{"new",{},P},
	{"set_name",{P,S}},
	{"get_name",{P},S},
	{"add_mime_type",{P,S}},
	{"add_pattern",{P,S}},
	{"add_pixbuf_formats",{P}},
	{"add_group",{P,S}},
	{"add_age",{P,I}},
	{"add_application",{P,S}},
	{"add_custom",{P,I,P,P,P}},
	{"get_needed",{P},I},
	{"filter",{P,P},B},
"GtkRecentFilter"}

widget[GtkRecentInfo] = {"gtk_recent_info",
{GObject},
	{"get_uri",{P},S},
	{"get_display_name",{P},S},
	{"get_description",{P},S},
	{"get_mime_type",{P},S},
	{"get_added",{P},I},
	{"get_modified",{P},I},
	{"get_visited",{P},I},
	{"get_private_hint",{P},B},
	{"get_application_info",{P,S,S,I,I},B},
	{"get_applications",{P,I},V},
	{"last_application",{P},S},
	{"has_application",{P,S},B},
	{"create_app_info",{P,S,P},P,0,GAppInfo},
	{"get_groups",{P,I},A},
	{"has_group",{P,S},B},
	{"get_icon",{P,I},P,0,GdkPixbuf},
	{"get_gicon",{P},P,0,GIcon},
	{"get_short_name",{P},S},
	{"get_uri_display",{P},S},
	{"get_age",{P},I},
	{"is_local",{P},B},
	{"exists",{P},B},
	{"match",{P,P},B},
"GtkRecentInfo"}

widget[GtkSettings] = {"gtk_settings",
{GtkStyleProvider,GObject},
	{"new",{P},-routine_id("newSettings")},
	{"reset_property",{P,S}}, -- 3.20
"GtkSettings"}

	function newSettings(atom x=0)
	  switch class_id(x) do
		case GdkScreen then
			return gtk_func("gtk_settings_get_for_screen",{P},{x})
		case GdkDisplay then -- GTK4
			return gtk_func("gtk_settings_get_for_display",{P},{x})
		case else
			return gtk_func("gtk_settings_get_default")
	  end switch
	end function 
	
widget[GtkSizeGroup] = {"gtk_size_group",
{GtkBuildable,GObject},
	{"new",{I},P},
	{"set_mode",{P,I}},
	{"get_mode",{P},I},
	{"set_ignore_hidden",{P,B}},
	{"get_ignore_hidden",{P},B},
	{"add_widget",{P,P}},
	{"add_widgets",{P,P},-routine_id("sg_add_widgets")},
	{"remove_widget",{P,P}},
	{"get_widgets",{P},X,0,GSList},
"GtkSizeGroup"}

	function sg_add_widgets(atom group, object widgets) -- allow {list} of widgets;
	  if atom(widgets) then
		set(group,"add widget",widgets)
	  else
		for i = 1 to length(widgets) do
			set(group,"add widget",widgets[i])
		end for
	  end if
	 return 1
	end function
	
widget[GtkTargetEntry] = {"gtk_target_entry",
{GObject},
	{"new",{S,I,I},P},
	{"copy",{P},P,0,GtkTargetEntry},
	{"free",{P}},
"GtkTargetEntry"}

widget[GtkTargetList] = {"gtk_target_list",
{GObject},
	{"new",{P,I},P},
	{"add",{P,P,I,I}},
	{"add_table",{P,P,I}},
	{"add_text_targets",{P,I}},
	{"add_image_targets",{P,I,B}},
	{"add_uri_targets",{P,I}},
	{"add_rich_text_targets",{P,I,B,P}},
	{"remove",{P,P}},
	{"find",{P,P,P},B},
"GtkTargetList"}

widget[GtkTextChildAnchor] = {"gtk_text_child_anchor",
{GObject},
	{"new",{},P},
	{"get_deleted",{P},B},
	{"get_widgets",{P},X,0,GList},
"GtkTextChildAnchor"}

widget[GtkTextMark] = {"gtk_text_mark",
{GObject},
	{"new",{S,B},P},
	{"set_visible",{P,B}},
	{"get_visible",{P},B},
	{"get_deleted",{P},B},
	{"get_name",{P},S},
	{"get_buffer",{P},P,0,GtkTextBuffer},
	{"get_left_gravity",{P},B},
"GtkTextMark"}

widget[GtkTextTag] = {"gtk_text_tag",
{GObject},
	{"new",{S},P},
	{"set_priority",{P,I}},
	{"get_priority",{P},I},
	{"event",{P,P,P,P},B},
	{"changed",{P,B}}, -- 3.20
"GtkTextTag"}

widget[GtkTextAttributes] = {"gtk_text_attributes",
{GObject},
	{"new",{},P},
	{"copy",{P},P,0,GtkTextAttributes},
	{"copy_values",{P,P}},
"GtkTextAttributes"}

widget[GtkTextTagTable] = {"gtk_text_tag_table",
{GtkBuildable,GObject},
	{"new",{},P},
	{"add",{P,P}},
	{"remove",{P,P}},
	{"lookup",{P,S},P,0,GtkTextTag},
	{"foreach",{P,P,P}},
	{"get_size",{P},I},
"GtkTextTagTable"}

widget[GtkMenuShell] = {"gtk_menu_shell",
{GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"append",{P,P},-routine_id("ms_append")},
	{"prepend",{P,P}},
	{"insert",{P,P,I}},
	{"deactivate",{P}},
	{"select_item",{P,P}},
	{"select_first",{P,B}},
	{"deselect",{P}},
	{"activate_item",{P,P,B}},
	{"cancel",{P}},
	{"set_take_focus",{P,B}},
	{"get_take_focus",{P},B},
	{"get_selected_item",{P},P,0,GtkWidget},
	{"get_parent_shell",{P},P,0,GtkWidget},
	{"bind_model",{P,P,S,B}}, --3.6
"GtkMenuShell"}

	function ms_append(atom menu, object items) -- allow {list} of items;
	  if atom(items) then
		gtk_proc("gtk_menu_shell_append",{P,P},{menu,items})
	  else
		for i = 1 to length(items) do
			ms_append(menu,items[i])
		end for
	  end if
	 return 1
	end function
	
widget[GtkNotebook] = {"gtk_notebook",
{GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"append_page",{P,P,P},I},
	{"append_page_menu",{P,P,P,P},I},
	{"prepend_page",{P,P,P},I},
	{"prepend_page_menu",{P,P,P,P},I},
	{"insert_page",{P,P,P,I},I},
	{"insert_page_menu",{P,P,P,P,I},I},
	{"remove_page",{P,I}},
	{"page_num",{P,I},I},
	{"next_page",{P}},
	{"prev_page",{P}},
	{"reorder_child",{P,P,I}},
	{"set_tab_pos",{P,I}},
	{"get_tab_pos",{P},I},
	{"set_show_tabs",{P,B}},
	{"get_show_tabs",{P},B},
	{"set_show_border",{P,B}},
	{"get_show_border",{P},B},
	{"set_scrollable",{P,B}},
	{"get_scrollable",{P},B},
	{"popup_enable",{P}},
	{"popup_disable",{P}},
	{"get_current_page",{P},I},
	{"set_menu_label",{P,P},0,GtkWidget},
	{"get_menu_label",{P,P},P},
	{"get_menu_label_text",{P,P},S},
	{"get_n_pages",{P},I},
	{"get_nth_page",{P,I},P,0,GtkWidget},
	{"set_tab_label",{P,P}},
	{"get_tab_label",{P,P},P,0,GtkWidget},
	{"set_tab_label_text",{P,P,S}},
	{"get_tab_label_text",{P,P},S},
	{"set_tab_detachable",{P,P,B}},
	{"get_tab_detachable",{P,P},B},
	{"set_current_page",{P,I}},
	{"set_group_name",{P,S}},
	{"get_group_name",{P},S},
	{"set_action_widget",{P,P,I}},
	{"get_action_widget",{P,I},P,0,GtkWidget},
	{"detach_tab",{P,P}}, -- 3.16
"GtkNotebook"}

widget[GtkSocket] = {"gtk_socket",
{GtkContainer,GtkWidget,GObject},
	{"new",{},P},
	{"add_id",{P,P}},
	{"get_id",{P},P},
	{"get_plug_window",{P},P,0,GdkWindow},
"GtkSocket"}

widget[GtkPlug] = {"gtk_plug",
{GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{I},P},
	{"get_id",{P},I},
	{"get_embedded",{P},B},
	{"get_socket_window",{P},P,0,GdkWindow},
"GtkPlug"}

widget[GtkToolPalette] = {"gtk_tool_palette",
{GtkScrollable,GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{},P},
	{"set_exclusive",{P,P,B}},
	{"get_exclusive",{P,P},B},
	{"set_expand",{P,P,B}},
	{"get_expand",{P,P},B},
	{"set_group_position",{P,P,I}},
	{"get_group_position",{P,P},I},
	{"set_icon_size",{P,I}},
	{"get_icon_size",{P},I},
	{"unset_icon_size",{P}},
	{"set_style",{P,I}},
	{"get_style",{P},I},
	{"unset_style",{P}},
	{"add_drag_dest",{P,P,I,I,I}},
	{"get_drag_item",{P,P},P,0,GtkWidget},
	{"get_drop_group",{P,I,I},P,0,GtkToolItemGroup},
	{"set_drag_source",{P,I}},
"GtkToolPalette"}

widget[GtkTextView] = {"gtk_text_view",
{GtkScrollable,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"new_with_buffer",{P},P},
	{"set_buffer",{P,P}},
	{"get_buffer",{P},P,0,GtkTextBuffer},
	{"scroll_to_mark",{P,P,D,B,D,D}},
	{"scroll_to_iter",{P,P,D,B,D,D},B},
	{"scroll_mark_onscreen",{P,P}},
	{"place_cursor_onscreen",{P},B},
	{"get_visible_rect",{P,P}},
	{"get_iter_location",{P,P,P}},
	{"get_cursor_locations",{P,P,P,P}},
	{"get_line_at_y",{P,P,I,I}},
	{"get_line_yrange",{P,P,I,I}},
	{"get_iter_at_location",{P,P,I,I}},
	{"get_iter_at_position",{P,P,I,I,I}},
	{"buffer_to_window_coords",{P,P,I,I,I,I}},
	{"window_to_buffer_coords",{P,P,I,I,I,I}},
	{"get_window",{P,I},P,0,GdkWindow},
	{"set_border_window_size",{P,I,I}},
	{"get_border_window_size",{P,P},I},
	{"forward_display_line",{P,P},B},
	{"backward_display_line",{P,P},B},
	{"forward_display_line_end",{P,P},B},
	{"backward_display_line_start",{P,P},B},
	{"starts_display_line",{P,P},B},
	{"move_visually",{P,P,I},B},
	{"add_child_at_anchor",{P,P,P}},
	{"add_child_in_window",{P,P,P,I,I}},
	{"move_child",{P,P,I,I}},
	{"set_wrap_mode",{P,I}},
	{"get_wrap_mode",{P},I},
	{"set_editable",{P,B}},
	{"get_editable",{P},B},
	{"set_cursor_visible",{P,B}},
	{"get_cursor_visible",{P},B},
	{"set_overwrite",{P,B}},
	{"get_overwrite",{P},B},
	{"set_pixels_above_lines",{P,I}},
	{"get_pixels_above_lines",{P},I},
	{"set_pixels_below_lines",{P,I}},
	{"get_pixels_below_lines",{P},I},
	{"set_pixels_inside_wrap",{P,I}},
	{"get_pixels_inside_wrap",{P},I},
	{"set_justification",{P,I}},
	{"get_justification",{P},I},
	{"set_left_margin",{P,I}},
	{"get_left_margin",{P},I},
	{"set_right_margin",{P,I}},
	{"get_right_margin",{P},I},
	{"set_indent",{P,I}},
	{"get_indent",{P},I},
	{"set_tabs",{P,A}},
	{"get_tabs",{P},A,0,PangoTabArray},
	{"set_accepts_tab",{P,B}},
	{"get_accepts_tab",{P},B},
	{"im_context_filter_keypress",{P,P},B},
	{"get_default_attributes",{P},P,0,GtkTextAttributes},
	{"reset_im_context",{P}},
	{"set_input_purpose",{P,I}}, -- 3.6+
	{"get_input_purpose",{P},I}, -- 3.6+
	{"set_input_hints",{P,I}}, -- 3.6+
	{"get_input_hints",{P},I}, -- 3.6+
	{"get_monospace",{P},B}, -- 3.16
	{"set_monospace",{P,B}}, -- 3.16
	{"get_bottom_margin",{P},I}, -- 3.18
	{"set_bottom_margin",{P,I}}, -- 3.18
	{"get_top_margin",{P},I}, -- 3.18
	{"set_top_margin",{P,I}}, -- 3.18
	{"reset_cursor_blink",{P}}, -- 3.20
"GtkTextView"}

widget[GtkToolShell] = {"gtk_tool_shell",
{GtkWidget},
	{"get_ellipsize_mode",{P},I},
	{"get_icon_size",{P},I},
	{"get_orientation",{P},I},
	{"get_relief_style",{P},I},
	{"get_style",{P},I},
	{"get_text_alignment",{P},F},
	{"get_text_orientation",{P},I},
	{"get_text_size_group",{P},P,0,GtkSizeGroup},
	{"rebuild_menu",{P}},
"GtkToolShell"}

widget[GtkToolbar] = {"gtk_toolbar",
{GtkToolShell,GtkContainer,GtkWidget,GtkOrientable,GtkBuildable,GObject},
	{"new",{},P},
	{"insert",{P,P,I}},
	{"get_item_index",{P,P},I},
	{"get_n_items",{P},I},
	{"get_nth_item",{P},P},
	{"get_drop_index",{P,I,I},I},
	{"set_drop_highlight_item",{P,P,I}},
	{"set_show_arrow",{P,B}},
	{"get_show_arrow",{P},B},
	{"set_icon_size",{P,I}},
	{"get_icon_size",{P},I},
	{"unset_icon_size",{P}},
	{"set_style",{P,I}},
	{"get_style",{P},I},
	{"unset_style",{P}},
"GtkToolbar"}

widget[GtkToolItemGroup] = {"gtk_tool_item_group",
{GtkToolShell,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{S},P},
	{"set_collapsed",{P,B}},
	{"get_collapsed",{P},B},
	{"set_ellipsize",{P,I}},
	{"get_ellipsize",{P},I},
	{"get_drop_item",{P,I,I},P,0,GtkToolItem},
	{"get_n_items",{P},I},
	{"get_nth_item",{P,I},P,0,GtkToolItem},
	{"set_label",{P,S}},
	{"get_label",{P},S},
	{"set_label_widget",{P,P}},
	{"get_label_widget",{P},P,0,GtkWidget},
	{"set_header_relief",{P,I}},
	{"get_header_relief",{P},I},
	{"insert",{P,P,I}},
	{"set_item_position",{P,P,I}},
"GtkToolItemGroup"}

widget[GtkTooltip] = {"gtk_tooltip",
{GObject},
	{"set_text",{P,S}},
	{"set_markup",{P,S}},
	{"set_icon",{P,P}},
	{"set_icon_from_stock",{P,P}}, -- deprecated 3.10;
	{"set_icon_from_icon_name",{P,S,I}},
	{"set_icon_from_gicon",{P,P,I}},
	{"set_custom",{P,P}}, -- put your own container here;
	{"trigger_tooltip_query",{P}},
	{"set_tip_area",{P,P}},	
"GtkTooltip"}

widget[GdkRectangle] = {"gdk_rectangle",
{GObject},
	{"new",{I,I,I,I},-routine_id("newRect")},
"GdkRectangle"}

	function newRect(integer x, integer y, integer w, integer h)
	atom r = allocate(32)
	poke4(r,x)
	poke4(r+4,y)
	poke4(r+8,w)
	poke4(r+12,h)
	register(r,GdkRectangle)
	return r
	end function

export function is_in_rectangle(object c, integer x, integer y)
  if x >= c[1] and x <= c[3] and y >= c[2] and y <= c[4] then
  return 1 else return 0 end if
end function

-- Following functions are for listview cells. See diet.ex for examples
-- You can also copy and modify this for use in your own program;
-- You DO NOT! call these directly, they only obtain their data from 
-- the listview row/column "on the fly".

----------------------------------------------------------------
export function cell_fmt(atom l, atom r, atom m, atom i, atom c) 
----------------------------------------------------------------
object val = gtk:get(m,"col data from iter",i,c) 
val = round(val,1000000) -- should eliminate floating point problem w/o too much loss;
object fmt = get(l,"data","fmt") 
if equal({},val) then -- for simplicity, this uses ONLY text:format()
  gtk:set(r,"property","markup","") 
else 
  gtk:set(r,"property","markup",text:format(fmt,{val}))   
end if
return 1
end function

constant VALID_PARAMS = { -- these can be set when create(GtkColumn,...) is called;
"name","type","title","text","markup","pixbuf","progress","spin",
"toggle","combo","widget","reorderable","resizable","clickable",
"foreground","background","color","bkgnd","sort","xalign","expand",
"min-width","max-width","fixed-width","alignment","sizing","visible",
"spacing","sort_column_id","sort-order","margin-start","margin-end",
"editable","tip","tooltip text","value","font"}

------------------------------------
function newColumn(object params) -- a convenience for easy, one-line creation;
------------------------------------    

params = keyvalues(params,,,,"\t\n\r") -- get param string;

atom c = create(GtkTreeViewColumn) -- create a new column;
atom r = -1 -- renderer;
integer q = 0
object n = "?" -- column name;
object x = 0, p = 0, z = 0

object t = vlookup("type",params,1,2) -- got to know this first!

switch t do -- create the requested type of cell renderer;
    case "text","markup" then r = create(GtkCellRendererText)
    case "pixbuf" then r = create(GtkCellRendererPixbuf)
    case "progress" then r = create(GtkCellRendererProgress) 
    case "spin" then r = create(GtkCellRendererSpin)
    case "toggle" then r = create(GtkCellRendererToggle)
    case "combo" then r = create(GtkCellRendererCombo)
    case else display("Error specifying cell renderer type")
end switch
   
if r = -1 then -- wrong or no type= line added;
    Warn(,,"Create new column",
	"Must specify a renderer type (i.e. type=text)")
    return 0
end if

set(c,"pack start",r) -- add the renderer to the column;
set(r,"name",get(c,"name") & ".renderer")

n = vlookup("title",params,1,2,"?")

ifdef NEW_COL then display("ListView Column settings:\n") end ifdef

for i = 1 to length(params) do 

    p = params[i][1]
    z = params[i][2]
    x = to_number(z)
    
ifdef NEW_COL then display("[] [] [] []",{i,p,z,x}) end ifdef
     
if is_in_list(p,VALID_PARAMS) = 0 then 
	Warn(,,"New Column",
	   sprintf("Invalid parameter: <b>%s</b>\nin col: <b>%s</b>",{p,n}))
end if

    if x = 0 then
	switch p do
		case "title","clickable","reorderable",
		     "resizable","expand","visible" then set(c,p,z)
		case "color" then set(r,"foreground",z)
		case "bkgnd" then set(r,"background",z)
		case "widget" then set(c,p,pointer(z))
		case "name" then n=p 
		        set(c,p,z)
			q = find(r,vslice(registry,1))
			registry[q][4] = z &  ".renderer"

		case else -- go on to next step;
	end switch
    else
	switch p do
		case "text","markup","foreground","background",
		     "pixbuf","value" then
			 set(c,"add attribute",r,p,x) --> col #
		case "color" then set(r,"foreground",x) -- alias;
		case "bkgnd" then set(r,"background",x) -- alias;
		case "sort" then set(c,"sort column id",x) -- alias;
		case "xalign" then set(r,p,x)
		case "tip" then set(r,"tooltip-markup",z)		    
		case "editable" then set(r,"editable",x)
		case "min-width","max-width","fixed-width",
		     "alignment","sizing","spacing",
		     "sort_column_id","sort-order" then 
			set(c,p,x)
		case else -- nothing needed!
	end switch

    end if

end for

return c
end function

widget[GtkTreeView] = {"gtk_tree_view",
{GtkContainer,GtkWidget,GtkBuildable,GtkScrollable,GObject},
	{"new",{P},-routine_id("newTreeView")},
	{"set_model",{P,P}},
	{"get_model",{P},P,0,GtkTreeModel},
	{"get_selection",{P},P,0,GtkTreeSelection},
	{"set_headers_visible",{P,B}},
	{"get_headers_visible",{P},B},
	{"set_headers_clickable",{P,B}},
	{"get_headers_clickable",{P},B},
	{"set_show_expanders",{P,B}},
	{"get_show_expanders",{P},B},
	{"set_expander_column",{P,P}},
	{"get_expander_column",{P},P,0,GtkTreeViewColumn},
	{"set_level_indentation",{P,I}},
	{"get_level_indentation",{P},I},
	{"columns_autosize",{P}},
	{"set_rules_hint",{P,B}}, -- deprecated 3.14
	{"get_rules_hint",{P},B}, -- deprecated 3.14
	{"set_activate_on_single_click",{P,B}}, -- GTK 3.8+
	{"get_activate_on_single_click",{P},B}, -- GTK 3.8+
	{"append_column",{P,P},I},
	{"append_columns",{P,P},-routine_id("tv_append_columns")},
	{"remove_column",{P,P,I}},
	{"insert_column",{P,P,I}},
	{"insert_column_with_attributes",{P,I,S,S,I,I}},
	{"insert_column_with_data_func",{P,I,S,P,P,P,P}},
	{"get_n_columns",{P},I},
	{"get_column",{P,I},P,0,GtkTreeViewColumn},
	{"get_columns",{P},X,0,GList},
	{"move_column_after",{P,P,P}},
	{"set_column_drag_function",{P,P,P,P}},
	{"scroll_to_point",{P,I,I}},
	{"scroll_to_cell",{P,P,P,P,F,F},-routine_id("tv_scroll_to_cell")},
	{"set_cursor",{P,P,P,B}},
	{"set_cursor_on_cell",{P,P,P,P,B}},
	{"get_cursor",{P,P,P}},
	{"row_activated",{P,P,P}},
	{"expand_row",{P,P,B},B},
	{"expand_all",{P}},
	{"expand_to_path",{P,P}},
	{"collapse_all",{P}},
	{"map_expanded_rows",{P,P,P}},
	{"row_expanded",{P,P},B},
	{"set_reorderable",{P,B}},
	{"get_reorderable",{P,B}},
	{"get_path_at_pos",{P,I,I,P,P,I,I},B},
	{"is_blank_at_pos",{P,I,I,P,P,I,I},B},
	{"get_cell_area",{P,P,P,P}},
	{"get_background_area",{P,P,P,P}},
	{"get_visible_rect",{P,P}},
	{"get_visible_range",{P,P,P},B},
	{"convert_bin_window_to_tree_coords",{P,I,I,I,I}},
	{"convert_bin_window_to_widget_coords",{P,I,I,I,I}},
	{"convert_tree_to_bin_window_coords",{P,I,I,I,I}},
	{"convert_tree_to_widget_coords",{P,I,I,I,I}},
	{"convert_widget_to_bin_window_coords",{P,I,I,I,I}},
	{"convert_widget_to_tree_coords",{P,I,I,I,I}},
	{"enable_model_drag_dest",{P,P,I,I}},
	{"enable_model_drag_source",{P,I,P,I,I}},
	{"unset_rows_drag_source",{P}},
	{"unset_rows_drag_dest",{P}},
	{"set_drag_dest_row",{P,P,I}},
	{"get_drag_dest_row",{P,P,P}},
	{"get_drag_dest_row_at_pos",{P,I,I,P,P},B},
	{"create_row_drag_icon",{P,P},P,0,CairoSurface_t},
	{"set_enable_search",{P,B}},
	{"get_enable_search",{P},B},
	{"set_search_column",{P,I}},
	{"get_search_column",{P},I},
	{"set_search_equal_func",{P,P,P,P}},
	{"get_search_equal_func",{P},P},
	{"set_search_entry",{P,P}},
	{"get_search_entry",{P},P,0,GtkEntry},
	{"set_search_position_func",{P,P,P,P}},
	{"get_search_position_func",{P},P},
	{"set_fixed_height_mode",{P,B}},
	{"get_fixed_height_mode",{P},B},
	{"set_hover_selection",{P,B}},
	{"get_hover_selection",{P},B},
	{"set_hover_expand",{P,B}},
	{"get_hover_expand",{P},B},
	{"set_destroy_count_func",{P,P,P,P}},
	{"set_row_separator_func",{P,P,P,P}},
	{"get_row_separator_func",{P},P},
	{"set_rubber_banding",{P,B}},
	{"get_rubber_banding",{P},B},
	{"set_enable_tree_lines",{P,B}},
	{"get_enable_tree_lines",{P},B},
	{"set_grid_lines",{P,B}},
	{"get_grid_lines",{P},B},
	{"set_tooltip_row",{P,P,P}},
	{"set_tooltip_cell",{P,P,P,P,P}},
	{"set_tooltip_column",{P,I}},
	{"get_tooltip_column",{P},I},
	{"get_tooltip_context",{P,I,I,B,P,P,P},B},
	{"select_row",{P,P,D,D},-routine_id("tv_select_row")},
	{"get_selected_row_data",{P,P},-routine_id("tv_get_selected_row_data")},
	{"get_selected_col_data",{P,P,I},-routine_id("tv_get_selected_col_data")},
"GtkTreeView"}

	function newTreeView(atom x=0)
		if class_id(x) = GtkTreeModel then
			return gtk_func("gtk_tree_view_new_with_model",{P},{x})
	else
		return gtk_func("gtk_tree_view_new")
		end if
	end function
	
	constant sfn1 = define_func("gtk_tree_view_get_model",{P},P)
	constant sfn2 = define_func("gtk_tree_model_get_n_columns",{P},I)
	constant sfn3 = define_func("gtk_tree_model_get_iter",{P,P,P},B)
	constant sfn4 = define_func("gtk_tree_model_get_column_type",{P,I},I)
	constant sp1 = define_proc("gtk_tree_model_get",{P,P,I,P,I})

	function tv_get_selected_col_data(atom view, atom path, integer col)
	object data = tv_get_selected_row_data(view,path)
	return data[col]
	end function

	function tv_get_selected_row_data(atom view, atom path)
	atom mdl = c_func(sfn1,{view})
	integer ncols = c_func(sfn2,{mdl})
	object data = repeat(0,ncols)
	object types = repeat(0,ncols)
	atom iter = allocate(32,1)
	object result
	
	if c_func(sfn3,{mdl,iter,path}) then
	for i = 1 to length(data) do
		data[i] =  allocate(32,1)
		types[i] = c_func(sfn4,{mdl,i-1}) 
		c_proc(sp1,{mdl,iter,i-1,data[i],-1})
	end for
	end if
	
	for i = 1 to length(data) do
	switch types[i] do
		case gSTR then 
		ifdef BITS64 then -- thanks pete eberlein
			result = peek8u(data[i])
		elsedef 
			result = peek4u(data[i])
		end ifdef
		if result > 0 then
			result = peek_string(result)
		end if
		data[i] = result

		case else data[i] = peek4u(data[i])
	end switch
	end for
	
	return data
	end function

	function tv_scroll_to_cell(atom v, atom p, atom c=0, integer align=0, atom row=0, atom col=0)
	gtk_proc("gtk_tree_view_scroll_to_cell",{P,P,P,I,F,F},{v,p,c,align,row,col})
	return 1
	end function
	
	function tv_append_columns(atom store, object cols)
	  if atom(cols) then
		gtk_func("gtk_tree_view_append_column",{P,P},{store,cols})
	  else
		for i = 1 to length(cols) do
		  tv_append_columns(store,cols[i])
		end for
	  end if
	 return 1
	end function

	function tv_select_row(atom tv, object path, atom rowalign=0,  atom colalign=0)
		path = create(GtkTreePath,path)
		gtk_func("gtk_tree_view_scroll_to_cell",
			{P,P,I,I,F,F},{tv,path,0,1,rowalign,colalign})
	 return 1
	end function
	
widget[GtkTreeViewColumn] = {"gtk_tree_view_column",
{GtkCellLayout,GtkBuildable,GObject},
	{"new",{},P},
	{"set_title",{P,S}},
	{"get_title",{P},S},
	{"pack_start",{P,P,B}},
	{"pack_end",{P,P,B}},
	{"clear",{P}},
	{"clicked",{P}},
	{"add_attribute",{P,P,S,I}},
	{"set_spacing",{P,I}},
	{"get_spacing",{P},I},
	{"set_visible",{P,B}},
	{"get_visible",{P},B},
	{"set_resizable",{P,B}},
	{"get_resizable",{P},B},
	{"set_sizing",{P,I}},
	{"get_sizing",{P},I},
	{"set_fixed_width",{P,I}},
	{"get_fixed_width",{P},I},
	{"set_min_width",{P,I}},
	{"get_min_width",{P},I},
	{"set_max_width",{P,I}},
	{"get_max_width",{P},I},
	{"set_expand",{P,B}},
	{"get_expand",{P},B},
	{"set_clickable",{P,B}},
	{"get_clickable",{P},B},
	{"set_widget",{P,P}},
	{"get_widget",{P},P},
	{"get_button",{P},P,0,GtkWidget},
	{"set_alignment",{P,F}},
	{"get_alignment",{P},F},
	{"set_reorderable",{P,B}},
	{"get_reorderable",{P},B},
	{"set_sort_column_id",{P,I}},
	{"get_sort_column_id",{P},I},
	{"set_sort_indicator",{P,B}},
	{"get_sort_indicator",{P},B},
	{"set_sort_order",{P,I}},
	{"get_sort_order",{P},I},
	{"cell_set_cell_data",{P,P,P,B,B}},
	{"cell_get_size",{P,P,I,I,I,I}},
	{"cell_get_position",{P,P,I,I},B},
	{"cell_is_visible",{P},B},
	{"focus_cell",{P,P}},
	{"queue_resize",{P}},
	{"get_tree_view",{P},P,0,GtkTreeView},
	{"get_x_offset",{P},I},
	{"get_renderer",{P},-routine_id("getTVColumnRenderer")},
	{"set_format_func",{P,P,I,P},-routine_id("setTVColumnFormat")},
"GtkTreeViewColumn"}

function setTVColumnFormat(atom ctl, object funk, integer col=0, object fmt)

if col < 1 then 
	Warn(,,"Error in format func","column # required") 
return 0
end if

set(ctl,"data","fmt",fmt) -- store the format for later access;
if _(funk) < 1 then Warn(,,"Error in format func",
  text:format("Invalid function: []",{funk})) 
return 0
end if

object renderer = get(ctl,"name") & ".renderer"
set(ctl,"cell data func",pointer(renderer),_(funk),col) -- install format function;

return 1
end function

function getTVColumnRenderer(atom col)
atom rend = 0
object name = get(col,"name") 
for i = 1 to length(registry) do
  if equal(name,registry[i][4]) then
      if registry[i][2] = GtkTreeViewColumn then
       -- display(registry[i])
       rend = registry[i][1]
       exit
     end if
  end if
end for
return rend
end function

widget[GtkTreeSelection] = {"gtk_tree_selection",
{GObject},
	{"set_mode",{P,I}},
	{"get_mode",{P},I},
	{"set_select_function",{P,P,P,P}},
	{"get_select_function",{P},P},
	{"get_user_data",{P},P},
	{"get_tree_view",{P},P},
	{"selected_foreach",{P,P,P}},
	{"count_selected_rows",{P},I},
	{"select_path",{P,P}},
	{"unselect_path",{P,P}},
	{"path_is_selected",{P,P},B},
	{"select_iter",{P,P}},
	{"unselect_iter",{P,P}},
	{"iter_is_selected",{P,P},B},
	{"select_all",{P}},
	{"unselect_all",{P}},
	{"select_range",{P,P,P}},
	{"unselect_range",{P,P,P}},
	{"get_selected_row",{P,P},-routine_id("ts_get_selected_row")},
	{"get_selected_rows",{P,P},-routine_id("ts_get_selected_rows")},
	{"get_selected_row_data",{P},-routine_id("ts_get_selected_row_data")},
"GtkTreeSelection"}

	function ts_get_selected_rows(atom selection, atom model)
	  object list = gtk_func("gtk_tree_selection_get_selected_rows",
		{P,P},{selection,model})
	  list = to_sequence(list,3)
	 return list +1
	end function
	
	function ts_get_selected_row(atom selection, atom model)
	  object result = ts_get_selected_rows(selection,model) 
	  if equal({},result) then return 0
	  else return result[1]
	  end if
	end function
	
	function ts_get_selected_row_data(atom selection)
	  atom mdl = allocate(32), iter = allocate(32)
	  integer n
	  object x,t, val, result
	  if gtk_func("gtk_tree_selection_get_selected",{P,P,P},{selection,mdl,iter}) then
		mdl = peek4u(mdl) 
		n = gtk_func("gtk_tree_model_get_n_columns",{P},{mdl})
		x = repeat(0,n) t = x

		for i = 1 to n do
			val = allocate(32,1)
			gtk_proc("gtk_tree_model_get",{P,P,I,P,I},{mdl,iter,i-1,val,-1})
			t[i] = gtk_func("gtk_tree_model_get_column_type",{P,I},{mdl,i-1})
			x[i] = val
		end for

		for i = 1 to length(x) do
			switch t[i] do
				case gSTR then 
					ifdef BITS64 then -- thanks Pete Eberlein;
						result = peek8u(x[i])
					elsedef 
						result = peek4u(x[i])
					end ifdef
					if result > 0 then
						x[i] = peek_string(result)
					end if
				case gFLT then x[i] = float32_to_atom(peek({x[i],4}))
				case gDBL then x[i] = float64_to_atom(peek({x[i],8}))
				case else x[i] = peek4u(x[i])
			end switch
		end for
		return x
	end if

	 return -1
	end function

widget[GtkActionBar] = {"gtk_action_bar", -- GTK 3.12
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject}, 
	{"new",{},P},
	{"pack_start",{P,P}},
	{"pack_end",{P,P}},
	{"get_center_widget",{P},P},
	{"set_center_widget",{P,P}},
	{"get_revealed",{P},B}, -- GTK4
	{"set_revealed",{P,B}}, -- GTK4
"GtkActionBar"}

widget[GtkAccelLabel] = {"gtk_accel_label",
{GtkLabel,GtkMisc,GtkWidget,GtkBuildable,GObject},
	{"new",{S},P},
	{"get_accel",{P,I,I}}, -- 3.14
	{"set_accel",{P,I,I}},
	{"set_accel_closure",{P,P}},
	{"set_accel_widget",{P,P}},
	{"get_accel_widget",{P},P,0,GtkWidget},
	{"get_accel_width",{P},I},
	{"refetch",{P},B},
"GtkAccelLabel"}

widget[GtkAccelGroup] = {"gtk_accel_group",
{GObject},
	{"new",{},P},
	{"connect",{P,I,I,I,P}},
	{"connect_by_path",{P,S,P}},
	{"disconnect",{P,P},B},
	{"disconnect_key",{P,I,I},B},
	{"activate",{P,I,P,I,I},B},
	{"lock",{P}},
	{"unlock",{P}},
	{"get_is_locked",{P},B},
	{"from_accel_closure",{P},P,0,GtkAccelGroup},
	{"get_modifier_mask",{P},I},
	{"find",{P,P,P},P},
"GtkAccelGroup"}

widget[GtkArrow] = {"gtk_arrow", -- deprecated 3.14
{GtkMisc,GtkWidget,GtkBuildable,GObject},
	{"new",{I,I},P},
	{"set",{P,I,I}},
"GtkArrow"}

widget[GtkCalendar] = {"gtk_calendar",
{GtkWidget,GtkBuildable,GObject},
	{"clear_marks",{P}},
	{"get_date",{P,I},-routine_id("cal_get_date")},
	{"get_ymd",{P,I},-routine_id("cal_get_ymd")},
	{"get_eu_date",{P},-routine_id("cal_get_eu_date")},
	{"get_day",{P},-routine_id("cal_get_day")},
	{"get_month",{P},-routine_id("cal_get_month")},
	{"get_year",{P},-routine_id("cal_get_year")},
	{"get_datetime",{P,I},-routine_id("cal_get_datetime")},
	{"get_day_is_marked",{P,I},B},
	{"get_display_options",{P},I},
	{"mark_day",{P,I},B},
	{"new",{P},-routine_id("newCalendar")},
	{"select_day",{P,I}},
	{"select_month",{P,I,I},-routine_id("cal_select_month")},
	{"set_display_options",{P,I}},
	{"unmark_day",{P,I},B},
	{"set_show_details",{P,B},-routine_id("setShowDetails")},
	{"set_detail_width_chars",{P,I}},
	{"get_detail_width_chars",{P},I},
	{"get_detail_height_rows",{P},I},
	{"set_detail_height_rows",{P,I}},
	{"set_date",{P,P},-routine_id("cal_set_date")},
	{"set_eu_date",{P,P},-routine_id("cal_set_eu_date")},
	{"set_day",{P,I},-routine_id("cal_set_day")},
	{"set_month",{P,I},-routine_id("cal_set_month")},
	{"set_year",{P,I},-routine_id("cal_set_year")},
"GtkCalendar"}

	function newCalendar(object d = 0) -- create calendar, set optional date;
	  object cal = gtk_func("gtk_calendar_new")
	  if atom(d) and d = 0 then return cal
		else gtk_proc("gtk_calendar_select_month",{P,I,I},{cal,d[2]-1,d[1]})
		gtk_proc("gtk_calendar_select_day",{P,I},{cal,d[3]})
		return cal
	  end if
	end function
	
	function setShowDetails(atom cal, integer show)
	  set(cal,"property","show-details",show)
	return 1
	end function
	
------------------------------------------------------------------------
-- Calendar convenience functions
------------------------------------------------------------------------
-- Handle odd month numbering scheme:

-- Q: If the first day of the month is 1, then why is the first month 
-- of the year zero?
-- A: Blame a C programmer!

-- Here we fix that, plus change the set_date routine from two steps
-- to one; also, provide for standard formatting to be used when 
-- getting the date. See std/datetime.e for the formats available.
------------------------------------------------------------------------

    constant get_date = define_proc("gtk_calendar_get_date",{P,I,I,I})

	function cal_select_month(atom handle, integer mo, integer yr=0)
	  while mo < 1 do yr -= 1 mo += 12 end while
	  while mo > 12 do yr += 1 mo -= 12 end while
	  gtk_proc("gtk_calendar_select_month",{P,I,I},{handle,mo-1,yr})
	 return 1
	end function

	function cal_set_day(atom cal, integer day)
	  object curr = get(cal,"eu_date") 
	  curr[1] += 1900
	  curr[3] = day
	  object test = repeat(0,6)
	  test[1] = curr[1]
	  test[2] = curr[2]
	  test[3] = 1
	  if day < 1 or day > days_in_month(test) then
	     return Error(,,"Invalid date",
	       text:format("[2]/[3]/[1]",curr))
	  end if
	  set(cal,"date",text:format("[]/[]/[]",curr))
	 return 1
	end function
	
	function cal_set_month(atom cal, integer month)
	  if month < 1 or month > 12 then
	     return Error(,,"Invalid date","month is incorrect")
	  end if
	  object curr = get(cal,"eu_date") 
	  curr[1] += 1900
	  curr[2] = month
	  set(cal,"date",text:format("[]/[]/[]",curr))	 return 1
	end function
	
	function cal_set_year(atom cal, integer year)
	  if year < 0 then 
	     return Error(,,"Invalid date","year is less than zero")
	  end if
	  integer mo = get(cal,"month")
	  gtk_proc("gtk_calendar_select_month",{P,I,I},{cal,mo-1,year})
	 return 1
	end function
	
	function dt_parse(object cdate)
	object dt = datetime:parse(cdate,"%Y/%m/%d")
	if atom(dt) then
		dt = datetime:parse(cdate,"%Y,%m,%d")
	end if
	if atom(dt) then
		dt = datetime:parse(cdate,"%m/%d/%y") 
	end if
	if atom(dt) then
		dt = datetime:parse(cdate,"%m/%d/%Y")
	end if
	if atom(dt) then
		dt = datetime:parse(cdate,"%y/%m/%d")
	end if
	return dt
	end function
	
	function cal_set_date(atom cal, object cdate)
	integer yr, mo, da
	object dt = 0
	
	if not datetime(cdate) then 
		dt = dt_parse(cdate) 
	else dt = cdate 
	end if
	
	if atom(dt) then 
	
		if cdate[1] > 31 then -- Y/M/D
			yr = cdate[1] 
			mo = cdate[2]
			da = cdate[3]
		end if
		
		if cdate[3] > 31 then -- M/D/Y
			mo = cdate[1]
			da = cdate[2]
			yr = cdate[3]
		end if
		
	else
		yr = dt[1]
		mo = dt[2]
		da = dt[3]
	end if
	
	if sequence(dt) then
	 gtk_proc("gtk_calendar_select_month",{P,I,I},{cal,mo-1,yr})
	 gtk_proc("gtk_calendar_select_day",{P,I},{cal,da})
	 return 1
	end if
	
	return -1
	end function

	function cal_set_eu_date(atom handle, object edt)
	  edt[1] += 1900 
	  set(handle,"date",text:format("[]/[]/[]",edt))
	 return 1
	end function
	
	function cal_get_date(atom handle, object fmt=0)
	  atom y = allocate(8,1), m = allocate(8,1), d = allocate(8,1)
	  object clock
	  if atom(fmt) and fmt = 0 then
		fmt = "%A, %b %d, %Y"
	  else
		fmt = peek_string(fmt)
	  end if
	  object result
	  c_proc(get_date,{handle,y,m,d})
	  result = datetime:new(peek4u(y),peek4u(m)+1,peek4u(d))
	  clock = datetime:now()
	  result = result[1..3] & clock[4..6]
	  result = datetime:format(result,fmt)
	 return result
	end function

	function cal_get_datetime(atom cal, object fmt=1)
	  atom y = allocate(8,1), m = allocate(8,1), d = allocate(8,1)
	  object result
	  c_proc(get_date,{cal,y,m,d})
	  result = datetime:now() -- for current hr,min,sec
	  result[1] = peek4u(y)
	  result[2] = peek4u(m)+1
	  result[3] = peek4u(d)
	  if fmt = 0 then -- set hr,min,sec to zero;
		result[4] = 0
		result[5] = 0
		result[6] = 0
	  end if
	 return result
	end function
	
	function cal_get_eu_date(atom cal) --returns {y,m,d} in Eu fmt.
	  atom y = allocate(8,1), m = allocate(8,1), d = allocate(8,1)
	  c_proc(get_date,{cal,y,m,d})
	  sequence result = {peek4u(y)-1900,peek4u(m)+1,peek4u(d)}
	 return result
	end function

	function cal_get_ymd(atom cal, integer full=0)
	object clock
	switch full do
		case 0 then return cal_get_eu_date(cal) + {1900,0,0}
		case 1 then return cal_get_eu_date(cal) + {1900,0,0} & {0,0,0}
		case 2 then clock = datetime:now() 
		       return cal_get_eu_date(cal) + {1900,0,0} & clock[4..6]
		case else return cal_get_eu_date(cal) + {1900,0,0}
	end switch
	end function

	function cal_get_day(atom cal)
	  atom y = allocate(8,1), m = allocate(8,1), d = allocate(8,1)
	  c_proc(get_date,{cal,y,m,d})
	  integer result = peek4u(d)
	 return result
	end function

	function cal_get_month(atom cal)
	  atom y = allocate(8,1), m = allocate(8,1), d = allocate(8,1)
	  c_proc(get_date,{cal,y,m,d})
	  integer result = peek4u(m)
	 return result+1
	end function

	function cal_get_year(atom cal)
	  atom y = allocate(8,1), m = allocate(8,1), d = allocate(8,1)
	  c_proc(get_date,{cal,y,m,d})
	  integer result = peek4u(y)
	 return result
	end function

widget[GtkCellView] = {"gtk_cell_view",
{GtkCellLayout,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{P,P},-routine_id("newCellView")},
	{"set_model",{P,P}},
	{"get_model",{P},P},
	{"set_displayed_row",{P,P}},
	{"get_displayed_row",{P},P,0,GtkTreePath},
	{"set_draw_sensitive",{P,B}},
	{"get_draw_sensitive",{P},B},
	{"set_fit_model",{P,B}},
	{"get_fit_model",{P},B},
	{"new_with_texture",{P},P},
"GtkCellView"}

	function newCellView(atom x=0, atom y=0)
	  if class_id(x) = GtkCellArea
		and class_id(y) = GtkCellAreaContext then
			return gtk_func("gtk_cell_view_new_with_context",{P,P},{x,y})
	  elsif atom(x) and x > 0 then
		if class_id(x) = GdkPixbuf then
			return gtk_func("gtk_cell_view_new_with_pixbuf",{P},{x})
		end if
	  elsif string(x) then
		return gtk_func("gtk_cell_view_new_with_markup",{P},{allocate_string(x)})
	  end if
	end function
	
widget[GtkDrawingArea] = {"gtk_drawing_area",
{GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"get_content_width",{P},I}, -- GTK4
	{"set_content_width",{P,I}}, -- GTK4
	{"get_content_height",{P},I}, -- GTK4
	{"set_content_height",{P,I}}, -- GTK4
"GtkDrawingArea"}

widget[GtkSearchEntry] = {"gtk_search_entry", --3.6
{GtkEntry,GtkWidget,GtkBuildable,GtkEditable,GtkCellEditable,GObject},
	{"new",{},P},
	{"handle_event",{P,P},B},
"GtkSearchEntry"}

widget[GtkEntryBuffer] = {"gtk_entry_buffer",
{GObject},
	{"new",{S,I},P},
	{"get_text",{P},S},
	{"set_text",{P,S,I}},
	{"get_bytes",{P},I},
	{"get_length",{P},I},
	{"set_max_length",{P,I}},
	{"get_max_length",{P},I},
	{"insert_text",{P,I,S,I},I},
	{"delete_text",{P,I,I},I},
	{"emit_deleted_text",{P,I,I}},
	{"emit_inserted_text",{P,I,S,I}},
"GtkEntryBuffer"}

widget[GtkEntryCompletion] = {"gtk_entry_completion",
{GtkCellLayout,GtkBuildable,GObject},
	{"new",{P},-routine_id("newEntryCompletion")},
	{"get_entry",{P},P,0,GtkEntry},
	{"set_model",{P,P}},
	{"get_model",{P},P,0,GtkTreeModel},
	{"set_match_func",{P,P,P,P}},
	{"set_minimum_key_length",{P,I}},
	{"get_minimum_key_length",{P},I},
	{"compute_prefix",{P,S},S},
	{"get_completion_prefix",{P},S},
	{"insert_prefix",{P}},
	{"insert_action_text",{P,I,S}},
	{"insert_action_markup",{P,I,S}},
	{"delete_action",{P,I}},
	{"set_text_column",{P,I}},
	{"get_text_column",{P},I},
	{"set_inline_completion",{P,B}},
	{"get_inline_completion",{P},B},
	{"set_inline_selection",{P,B}},
	{"get_inline_selection",{P},B},
	{"set_popup_completion",{P,B}},
	{"get_popup_completion",{P},B},
	{"set_popup_set_width",{P,B}},
	{"get_popup_set_width",{P},B},
	{"set_popup_single_match",{P,B}},
	{"get_popup_single_match",{P},B},
	{"complete",{P}},
"GtkEntryCompletion"}

	function newEntryCompletion(atom x=0)
	  if class_id(x) = GtkCellArea then
		return gtk_func("gtk_entry_completion_new_with_area",{P},{x})
	  else
		return gtk_func("gtk_entry_completion_new")
	  end if
	end function
	
widget[GtkRevealer] = {"gtk_revealer", -- new in GTK 3.10
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"set_reveal_child",{P,B}},
	{"get_reveal_child",{P},B},
	{"get_child_revealed",{P},B},
	{"set_transition_duration",{P,I}},
	{"get_transition_duration",{P},I},
	{"set_transition_type",{P,I}},
	{"get_transition_type",{P},I},
"GtkRevealer"}

widget[GtkSearchBar] = {"gtk_search_bar", -- new in GTK 3.10
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"connect_entry",{P,P}},
	{"set_search_mode",{P,B}},
	{"get_search_mode",{P},B},
	{"set_show_close_button",{P,B}},
	{"get_show_close_button",{P},B},
	{"handle_event",{P,P},B},
"GtkSearchBar"}

widget[GtkStack] = {"gtk_stack", -- new in GTK 3.10
{GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"add_named",{P,P,S}},
	{"add_titled",{P,P,S,S}},
	{"set_visible_child",{P,P}},
	{"get_visible_child",{P},P,0,GtkWidget},
	{"set_visible_child_name",{P,S}},
	{"get_visible_child_name",{P},S},
	{"set_visible_child_full",{P,S,I}},
	{"set_homogeneous",{P,B}},
	{"get_homogeneous",{P},B},
	{"set_transition_duration",{P,I}},
	{"get_transition_duration",{P},I},
	{"set_transition_type",{P,I}},
	{"get_transition_type",{P},I},
	{"get_child_by_name",{P,S},P,0,GtkWidget}, -- 3.12
	{"get_transition_running",{P},B}, -- 3.12
	{"get_hhomogeneous",{P},B}, -- 3.16
	{"set_hhomogeneous",{P,B}}, -- 3.16
	{"get_vhomogeneous",{P},B}, -- 3.16
	{"set_vhomogeneous",{P,B}}, -- 3.16
	{"get_interpolate_size",{P},B}, -- 3.18
	{"set_interpolate_size",{P,B}}, -- 3.18
"GtkStack"}
  
widget[GtkStackSidebar] = {"gtk_stack_sidebar", -- 3.16
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"set_stack",{P,P}},
	{"get_stack",{P},P,0,GtkStack},
"GtkStackSidebar"}

widget[GtkStackSwitcher] = {"gtk_stack_switcher",
{GtkBox,GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{},P},
	{"set_stack",{P,P}},
	{"get_stack",{P},P,0,GtkStack},
"GtkStackSwitcher"}

widget[GtkScrollbar] = {"gtk_scrollbar",
{GtkRange,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{I,P},P},
"GtkScrollbar"}

widget[GtkInvisible] = {"gtk_invisible",
{GtkWidget,GtkBuildable,GObject},
	{"new",{P},-routine_id("newInvisible")}, 
	{"set_screen",{P,P}},
	{"get_screen",{P},P,0,GdkScreen},
"GtkInvisible"}
	
	function newInvisible(atom x=0) -- x may be handle to screen;
	  if class_id(x) = GdkScreen then
		return gtk_func("gtk_invisible_new_for_screen",{P},{x})
	  else
		return gtk_func("gtk_invisible_new")
	  end if
	end function
	
widget[GtkProgressBar] = {"gtk_progress_bar",
{GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{},P},
	{"pulse",{P}},
	{"set_fraction",{P,D}},
	{"get_fraction",{P},D},
	{"set_inverted",{P,B}},
	{"get_inverted",{P},B},
	{"set_show_text",{P,B}},
	{"get_show_text",{P},B},
	{"set_text",{P,S}},
	{"get_text",{P},S},
	{"set_ellipsize",{P,B}},
	{"get_ellipsize",{P},B},
	{"set_pulse_step",{P,D}},
	{"get_pulse_step",{P},D},
"GtkProgressBar"}

widget[GtkSpinner] = {"gtk_spinner",
{GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"start",{P}},
	{"stop",{P}},
"GtkSpinner"}

widget[GtkSwitch] = {"gtk_switch",
{GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"set_active",{P,B}},
	{"get_active",{P},B},
	{"get_state",{P},B}, -- GTK3.14
	{"set_state",{P,B}}, -- GTK3.14
"GtkSwitch"}

widget[GtkBorder] = {"gtk_border",
{GObject},
	{"new",{},P},
	{"copy",{P},P},
	{"free",{P}},
"GtkBorder"}

widget[GtkLevelBar] = {"gtk_level_bar",-- GTK3.6+
{GtkWidget,GtkBuildable,GtkBuildable,GtkOrientable,GObject},
	{"new",{D,D},-routine_id("newLevelBar")},
	{"new_for_interval",{D,D},P},
	{"set_mode",{P,I}},
	{"get_mode",{P},I},
	{"set_value",{P,D}},
	{"get_value",{P},D},
	{"set_min_value",{P,D}},
	{"get_min_value",{P},D},
	{"set_max_value",{P,D}},
	{"get_max_value",{P},D},
	{"add_offset_value",{P,S,D}},
	{"remove_offset_value",{P,S}},
	{"get_offset_value",{P,S},D},
	{"get_inverted",{P},B}, --GTK3.8+
	{"set_inverted",{P,B}}, --GTK3.8+
"GtkLevelBar"} 

	function newLevelBar(atom x=0, atom y=0)
	  if x+y > 0 then
		return gtk_func("gtk_level_bar_new_for_interval",{D,D},{x,y})
	  else
		return gtk_func("gtk_level_bar_new")
	  end if
	end function
	
widget[GtkAboutDialog] = {"gtk_about_dialog",
{GtkDialog,GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"set_program_name",{P,S}},
	{"get_program_name",{P},S},
	{"set_version",{P,S}},
	{"get_version",{P},S},
	{"set_copyright",{P,S}},
	{"get_copyright",{P},S},
	{"set_comments",{P,S}},
	{"get_comments",{P},S},
	{"set_license",{P,S}},
	{"get_license",{P},S},
	{"set_wrap_license",{P,B}},
	{"get_wrap_license",{P},B},
	{"set_license_type",{P,I}},
	{"get_license_type",{P},I},
	{"set_website",{P,S}},
	{"get_website",{P},S},
	{"set_website_label",{P,S}},
	{"get_website_label",{P},S},
	{"set_authors",{P,A}},
	{"get_authors",{P},V},
	{"set_artists",{P,A}},
	{"get_artists",{P},V},
	{"set_documenters",{P,A}},
	{"get_documenters",{P},V},
	{"set_translator_credits",{P,S}},
	{"get_translator_credits",{P},S},
	{"set_logo",{P,P},-routine_id("setAboutLogo")},
	{"get_logo",{P},P,0,GdkPixbuf},
	{"set_logo_icon_name",{P,S}},
	{"get_logo_icon_name",{P},S},
	{"add_credit_section",{P,S,A}},
"GtkAboutDialog"} -- see also system-information property - GTK4;

	function setAboutLogo(atom dlg, object logo)
	  if string(logo) then
		logo = locate_file(logo)
		if file_type(logo) = 0 then return 0 end if
	  end if
	  if atom(logo) and class_id(logo) = GdkPixbuf then 
		return 0
	  else
		logo = create(GdkPixbuf,logo)
	  end if
	  gtk_proc("gtk_about_dialog_set_logo",{P,P},{dlg,logo})
	 return 1
	end function
	
widget[GtkAppChooserDialog] = {"gtk_app_chooser_dialog",
{GtkAppChooser,GtkDialog,GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P,I,P},-routine_id("newAppChooserDialog")},
	{"get_widget",{P},P,0,GtkAppChooserWidget},
	{"set_heading",{P,S}},
	{"get_heading",{P},S},
"GtkAppChooserDialog"}

	function newAppChooserDialog(atom parent, integer flags, object x)
	   if string(x) and file_exists(canonical_path(x)) then
		x = allocate_string(canonical_path(x),1)
		x = gtk_func("g_file_new_for_path",{P},{x})
		return gtk_func("gtk_app_chooser_dialog_new",{P,I,P},{parent,flags,x})
	  else
		if string(x)  then x = allocate_string(x,1) end if
		return gtk_func("gtk_app_chooser_dialog_new_for_content_type",
			{P,I,P},{parent,flags,x})
	  end if
	end function

widget[GtkColorChooserDialog] = {"gtk_color_chooser_dialog",
{GtkColorChooser,GtkDialog,GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{S,P},P},
"GtkColorChooserDialog"}

widget[GtkFileChooserDialog] = {"gtk_file_chooser_dialog",
{GtkFileChooser,GtkDialog,GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{S,P,I,S},P},
"GtkFileChooserDialog"}

widget[GtkFontChooserDialog] = {"gtk_font_chooser_dialog",
{GtkFontChooser,GtkDialog,GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{S,P},P},
"GtkFontChooserDialog"}

widget[GtkStyleProvider] = {"gtk_style_provider",
{0},
	{"get_style_property",{P,P,I,P,P},B},
"GtkStyleProvider"}

widget[GtkStyleContext] = {"gtk_style_context",
{GObject},
	{"new",{},P},
	{"add_provider",{P,P,I}},
	{"add_provider_for_screen",{P,P,P,I},-routine_id("sc_add_provider_for_screen")},
	{"get",{P,I,S,P,I}},
	{"get_junction_sides",{P},I},
	{"get_parent",{P},P,0,GtkStyleContext},
	{"get_path",{P},P,0,GtkWidgetPath},
	{"get_property",{P,S,I,P}},
	{"get_screen",{P},P,0,GdkScreen},
	{"get_frame_clock",{P},P,0,GdkFrameClock},
	{"get_state",{P},I},
	{"get_style",{P,S,P,I}},
	{"get_style_property",{P,S,P}},
	{"get_section",{P,S},P,0,GtkCssSection},
	{"get_color",{P,I,P}},
	{"get_background_color",{P,I},-routine_id("GetBkColor")}, -- deprecated 3.16
	{"get_border_color",{P,I,P}}, -- deprecated 3.16
	{"get_border",{P,I,P}},
	{"get_padding",{P,I,P}},
	{"get_margin",{P,I,P}},
	{"invalidate",{P}}, -- deprecated 3.12
	{"lookup_color",{P,S,P},B},
	{"remove_provider",{P,P}},
	{"remove_provider_for_screen",{P,P}},
	{"reset_widgets",{P}},
	{"set_background",{P,P}}, -- deprecated 3.18
	{"restore",{P}},
	{"save",{P}},
	{"set_junction_sides",{P,I}},
	{"set_parent",{P,P}},
	{"set_path",{P,P}},
	{"add_class",{P,S}},
	{"remove_class",{P,S}},
	{"has_class",{P,S},B},
	{"list_classes",{P},P,0,GList},
	{"add_region",{P,S,I}}, -- deprecated 3.14
	{"remove_region",{P,S}}, -- deprecated 3.14
	{"has_region",{P,S,I},B}, -- deprecated 3.14
	{"list_regions",{P},P,0,GList}, -- deprecated 3.14
	{"set_screen",{P,P}},
	{"set_frame_clock",{P,P}},
	{"set_state",{P,I}},
	{"set_scale",{P,I}}, -- 3.10
	{"get_scale",{P},I}, -- 3.10
	{"to_string",{P,I},S}, -- 3.20
	{"set_display",{P,P}}, -- GTK4
	{"get_display",{P},P,0,GdkDisplay}, -- GTK4
	{"remove_provider_for_display",{P,P}}, -- GTK4
	{"add_provider_for_display",{P,P,I}}, -- GTK4
"GtkStyleContext"}
	
	function sc_add_provider_for_screen(atom context, atom scrn, atom pro, integer pri)
	  gtk_proc("gtk_style_context_add_provider_for_screen",{P,P,I},{scrn,pro,pri})
	 return 1
	end function
	
	function GetBkColor(atom context, integer state=0)
         atom fn = define_proc("gtk_style_context_get_background_color",{P,P,P})
         atom c = allocate(32)
         c_proc(fn,{context,state,c})
	return peek4u(c)
	end function
	
widget[GtkRecentChooserDialog] = {"gtk_recent_chooser_dialog",
{GtkRecentChooser,GtkDialog,GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{S,P,P},P},
	{"new_for_manager",{S,P,P,P},P},
"GtkRecentChooserDialog"}

widget[GtkListBox] = {"gtk_list_box", -- new in GTK 3.10
{GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"prepend",{P,P}},
	{"insert",{P,P,I}},
	{"select_row",{P,P}},
	{"select_all",{P}}, -- 3.14
	{"unselect_all",{P}}, -- 3.14
	{"unselect_row",{P,P}}, -- 3.14
	{"get_selected_row",{P},P,0,GtkListBoxRow},
	{"get_selected_rows",{P},X,0,GList},-- 3.14
	{"row_is_selected",{P},B}, -- 3.14
	{"selected_foreach",{P,P,P}}, -- 3.14
	{"set_selection_mode",{P,I}},
	{"get_selection_mode",{P},I},
	{"set_activate_on_single_click",{P,B}}, 
	{"get_activate_on_single_click",{P},B}, 
	{"set_adjustment",{P,P}},
	{"get_adjustment",{P},P,0,GtkAdjustment},
	{"set_placeholder",{P,P}},
	{"get_row_at_index",{P,I},P,0,GtkListBoxRow},
	{"get_row_at_y",{P,I},P,0,GtkListBoxRow},
	{"invalidate_filter",{P}},
	{"invalidate_headers",{P}},
	{"invalidate_sort",{P}},
	{"set_filter_func",{P,P,P,P}},
	{"set_header_func",{P,P,P,P}},
	{"set_sort_func",{P,P,P,P}},
	{"drag_highlight_row",{P,P}}, 
	{"drag_unhighlight_row",{P}}, 
	{"bind_model",{P,P,P,P,P}}, -- 3.16
"GtkListBox"}

widget[GtkListBoxRow] = {"gtk_list_box_row",
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"changed",{P}},
	{"get_header",{P},P,0,GtkWidget},
	{"get_type",{},I},
	{"set_header",{P,P}},
	{"get_index",{P},I},
	{"set_activatable",{P,B}},
	{"set_selectable",{P,B}},
	{"get_selectable",{P},B},
"GtkListBoxRow"}

widget[GtkPopover] = {"gtk_popover", -- new in GTK 3.12
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{P,P},-routine_id("newPopover")},
	{"bind_model",{P,P,S}},
	{"set_relative_to",{P,P}},
	{"get_relative_to",{P},P,0,GtkWidget},
	{"set_pointing_to",{P,P}},
	{"get_pointing_to",{P,P},B},
	{"set_position",{P,I}},
	{"get_position",{P},I},
	{"set_modal",{P,B}},
	{"get_modal",{P},B},
	{"get_transitions_enabled",{P},B},
	{"set_transitions_enabled",{P,B}},
	{"get_default_widget",{P},P,0,GtkWidget}, -- 3.18
	{"set_default_widget",{P,P}}, -- 3.18
	{"get_constrain_to",{P},P}, -- 3.20
	{"set_constrain_to",{P,P}}, -- 3.20
	{"popup",{P}}, -- 3.22
	{"popdown",{P}}, -- 3.22
"GtkPopover"}

	function newPopover(atom a=0, atom b=0)
	  if class_id(b) = GMenuModel then
		return gtk_func("gtk_popover_new_from_model",{P,P},{a,b})
	  else
		return gtk_func("gtk_popover_new",{P},{a})
	  end if
	end function
	
widget[GtkPopoverMenu] = {"gtk_popover_menu", -- 3.16
{GtkPopover,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"open_submenu",{P,S}},
"GtkPopoverMenu"}

widget[GtkPlacesSidebar] = {"gtk_places_sidebar", -- new 3.10
{GtkScrolledWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"set_open_flags",{P,I}},
	{"get_open_flags",{P},I},
	{"set_location",{P,P}},
	{"get_location",{P},P,0,GFile},
	{"set_show_desktop",{P,B}},
	{"get_show_desktop",{P},B},
	{"add_shortcut",{P,P}},
	{"remove_shortcut",{P,P}},
	{"list_shortcuts",{P},A,0,GSList},
	{"get_nth_bookmark",{P,I},P,0,GFile},
	{"get_show_connect_to_server",{P},B}, -- deprecated 3.18
	{"set_show_connect_to_server",{P,B}}, -- deprecated 3.18
	{"set_local_only",{P,B}}, -- 3.12
	{"get_local_only",{P},B}, -- 3.12
	{"get_show_enter_location",{P},B}, --3.14
	{"set_show_enter_location",{P,B}}, --3.14
	{"get_show_other_locations",{P},B}, -- 3.18
	{"set_show_other_locations",{P,B}}, -- 3.18
	{"get_show_recent",{P},B}, -- 3.18
	{"set_show_recent",{P,B}}, -- 3.18
	{"get_show_trash",{P},B}, -- 3.18
	{"set_show_trash",{P,B}}, -- 3.18
	{"set_drop_targets_visible",{P,B,P}}, -- 3.18
"GtkPlacesSidebar"}

widget[GtkHeaderBar] = {"gtk_header_bar", -- new in GTK 3.10
{GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"set_title",{P,S}},
	{"get_title",{P},S},
	{"set_subtitle",{P,S}},
	{"get_subtitle",{P},S},
	{"set_has_subtitle",{P,B}}, -- 3.12
	{"get_has_subtitle",{P},B}, -- 3.12
	{"set_custom_title",{P,P}},
	{"get_custom_title",{P},P,0,GtkWidget},
	{"pack_start",{P,P}},
	{"pack_end",{P,P}},
	{"set_show_close_button",{P,B}}, -- GTK3
	{"get_show_close_button",{P},B},
	{"set_decoration_layout",{P,S}}, -- 3.12
	{"get_decoration_layout",{P},S}, -- 3.12
	{"set_show_title_buttons",{P,B}}, -- GTK4
	{"get_show_title_buttons",{P},B}, -- GTK4
"GtkHeaderBar"}

widget[GtkFlowBox] = {"gtk_flow_box", -- GTK 3.12
{GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{},P},
	{"insert",{P,P,I}},
	{"get_child_at_index",{P,I},P,0,GtkFlowBoxChild},
	{"get_child_at_pos",{P,I,I},P,0,GtkFlowBoxChild}, -- 3.22.6
	{"set_hadjustment",{P,P}},
	{"set_vadjustment",{P,P}},
	{"set_homogeneous",{P,B}},
	{"get_homogeneous",{P},B},
	{"set_row_spacing",{P,I}},
	{"get_row_spacing",{P},I},
	{"set_column_spacing",{P,I}},
	{"get_column_spacing",{P},I},
	{"set_min_children_per_line",{P,I}},
	{"get_min_children_per_line",{P},I},
	{"set_max_children_per_line",{P,I}},
	{"get_max_children_per_line",{P},I},
	{"set_activate_on_single_click",{P,B}},
	{"get_activate_on_single_click",{P},B},
	{"selected_foreach",{P,P,P}},
	{"get_selected_children",{P},X,0,GList},
	{"select_child",{P,P}},
	{"unselect_child",{P,P}},
	{"select_all",{P}},
	{"unselect_all",{P}},
	{"set_selection_mode",{P,I}},
	{"get_selection_mode",{P},I},
	{"set_filter_func",{P,P,P,P}},
	{"invalidate_filter",{P}},
	{"set_sort_func",{P,P,P,P}},
	{"invalidate_sort",{P}},
	{"bind_model",{P,P,P,P,P}}, -- 3.18
"GtkFlowBox"}

widget[GtkFlowBoxChild] = {"gtk_flow_box_child", -- GTK 3.12
{GtkBin,GtkContainer,GtkWidget,GtkBuildable,GtkOrientable,GObject},
	{"new",{},P},
	{"get_index",{P},I},
	{"is_selected",{P},B},
	{"changed",{P}},
"GtkFlowBoxChild"}

widget[GtkMountOperation]  = {"gtk_mount_operation",
{GObject},
	{"new",{P},P},
	{"is_showing",{P},B},
	{"set_parent",{P,P}},
	{"get_parent",{P},P,0,GtkWindow},
	{"set_screen",{P,P}},
	{"get_screen",{P},P,0,GdkScreen},
"GtkMountOperation"}

----------------------------------------------------------------------
-- stocklist is not a real GTK widget, we just fake it for convenience
----------------------------------------------------------------------
widget[GtkStockList] = {"gtk_stocklist", -- deprecated in GTK 3.12+
{0}, 
"GtkStockList"}

	function newStockList()
	object list = gtk_func("gtk_stock_list_ids")
	return to_sequence(list)
	end function

---------------------------------------------------------------------
-- Support for Gestures; mostly untested, since this requires a 
-- touch-screen display. Anyone who wants can buy me one!
---------------------------------------------------------------------

widget[GtkEventController] = {"gtk_event_controller",
{GObject},
	{"get_propagation_phase",{P},I},
	{"set_propagation_phase",{P,I}},
	{"handle_event",{P,P},B},
	{"get_widget",{P},P,0,GtkWidget},
	{"reset",{P}},
	{"scroll_new",{P,I},P}, -- GTK4
	{"scroll_set_flags",{P,I}}, -- GTK4
	{"scroll_get_flags",{P},I}, -- GTK4
	{"motion_new",{P},P}, -- GTK4	
"GtkEventController"}
	
widget[GdkFrameClock] = {"gdk_frame_clock",
{GObject},
	{"get_frame_time",{P},I},
	{"request_phase",{P,P}},
	{"begin_updating",{P}},
	{"end_updating",{P}},
	{"get_frame_counter",{P},I},
	{"get_history_start",{P},I},
	{"get_timings",{P,I},P},
	{"get_current_timings",{P},P,0,GdkFrameTimings},
	{"get_refresh_info",{P,I,I,I}},
"GdkFrameClock"}

widget[GdkFrameTimings] = {"gdk_frame_timings",
{GObject},
	{"get_frame_counter",{P},I},
	{"get_complete",{P},B},
	{"get_frame_time",{P},I},
	{"get_presentation_time",{P},I},
	{"get_refresh_interval",{P},I},
	{"get_predicted_presentation_time",{P},I},
"GdkFrameTimings"}

widget[GdkEvent] = {"gdk_event",
{GObject},
	{"new",{},P},
	{"peek",{},P,0,GdkEvent},
	{"get",{},P,0,GdkEvent},
	{"put",{P}},
	{"copy",{P},P,0,GdkEvent},
	{"get_axis",{P,I,D},B},
	{"get_button",{P,P},B},
	{"get_keycode",{P,P},B},
	{"get_keyval",{P,P},B},
	{"get_root_coords",{P,D,D},B},
	{"get_scroll_direction",{P,P},B},
	{"get_scroll_deltas",{P,D,D},B},
	{"get_state",{P,P},B},
	{"get_time",{P},I},
	{"get_window",{P},P,0,GdkWindow},
	{"get_event_type",{P},I},
	{"get_event_sequence",{P},P,0,GdkEventSequence},
	{"request_motions",{P}},
	{"get_click_count",{P,P},B},
	{"get_coords",{P,D,D},B},
	{"triggers_context_menu",{P},B},
	{"handler_set",{P,P,P}},
	{"set_screen",{P,P}},
	{"get_screen",{P},P,0,GdkScreen},
	{"set_device",{P,P}},
	{"get_device",{P},P,0,GdkDevice},
	{"set_source_device",{P,P}},
	{"get_source_device",{P},P,0,GdkDevice},
"GdkEvent"}

widget[GdkEventSequence] = {"gdk_event_sequence",
{GdkEvent},
"GdkEventSequence"}

widget[GtkGesture] = {"gtk_gesture", --GTK3.14
{GtkEventController,GObject},
	{"get_device",{P},P},
	{"get_window",{P},P},
	{"set_window",{P,P}},
	{"is_active",{P},B},
	{"is_recognized",{P},B},
	{"get_sequence_state",{P,P},I},
	{"set_sequence_state",{P,P,I},B},
	{"set_state",{P,I},B},
	{"get_sequences",{P},A},
	{"handles_sequence",{P,P},B},
	{"get_last_updated_sequence",{P},P},
	{"get_last_event",{P,P},P},
	{"get_point",{P,P,D,D},B},
	{"get_bounding_box",{P,P},B},
	{"get_bounding_box_center",{P,D,D},B},
	{"group",{P,P}},
	{"ungroup",{P}},
	{"get_group",{P},A},
	{"is_grouped_with",{P,P},B},
"GtkGesture"}

widget[GtkGestureSingle] = {"gtk_gesture_single",
{GtkGesture,GtkEventController,GObject},
	{"get_exclusive",{P},B},
	{"set_exclusive",{P,B}},
	{"get_touch_only",{P},B},
	{"set_touch_only",{P,B}},
	{"get_button",{P},I},
	{"set_button",{P,I}},
	{"get_current_button",{P},I},
	{"get_current_sequence",{P},P},
"GtkGestureSingle"}

widget[GtkGestureRotate] = {"gtk_gesture_rotate",
{GtkGesture,GtkEventController,GObject},
	{"new",{P},P},
	{"get_angle_delta",{P},D},
"GtkGestureRotate"}

widget[GtkGestureZoom] = {"gtk_gesture_zoom",
{GtkGesture,GtkEventController,GObject},
	{"new",{P},P},
	{"get_scale_delta",{P},D},
"GtkGestureZoom"}

widget[GtkGestureDrag] = {"gtk_gesture_drag", -- 3.14
{GtkGestureSingle,GtkGesture,GtkEventController,GObject},
	{"new",{P},P},
	{"get_start_point",{P,D,D},B},
	{"get_offset",{P,D,D},B}, 
"GtkGestureDrag"}

widget[GtkGesturePan] = {"gtk_gesture_pan",
{GtkGestureDrag,GtkGestureSingle,GtkGesture,GtkEventController,GObject},
	{"new",{P,I},P},
	{"get_orientation",{P},I},
	{"set_orientation",{P,I}},
"GtkGesturePan"}

widget[GtkGestureSwipe] = {"gtk_gesture_swipe",
{GtkGestureSingle,GtkGesture,GtkEventController,GObject},
	{"new",{P},P},
	{"get_velocity",{P,D,D},B},
"GtkGestureSwipe"}

widget[GtkGestureLongPress] = {"gtk_gesture_long_press",
{GtkGestureSingle,GtkGesture,GtkEventController,GObject},
	{"new",{P},P},
"GtkGestureLongPress"}

widget[GtkGestureMultiPress] = {"gtk_gesture_multi_press",
{GtkGestureSingle,GtkGesture,GtkEventController,GObject},
	{"new",{P},P},
	{"get_area",{P,P},B},
	{"set_area",{P,P}},
"GtkGestureMultiPress"}

widget[GtkPadController] = {"gtk_pad_controller", -- 3.22
{GtkEventController,GObject},	
	{"new",{P,P,P},P}, -- window, group, pad;
	{"set_action_entries",{P,P,I}}, 
	{"set_action",{P,I,I,I,S,S}}, -- [ctl] type, index, mode, label, action name;
"GtkPadController"}

widget[GtkMountOperation] = {"gtk_mount_operation",
{GMountOperation,GObject},
	{"new",{P},P},
	{"is_showing",{P},B},
	{"set_parent",{P,P}},
	{"get_parent",{P},P,0,GtkWindow},
	{"set_display",{P,P}}, -- GTK4
	{"get_display",{P},P,0,GdkDisplay}, -- GTK4

"GtkMountOperation"}

--------------------------------------------------------------------
-- Support for openGL;
-- Untested - I don't know anything about OpenGL!
--------------------------------------------------------------------

widget[GdkGLProfile] = {"gdk_gl_profile",
 {},
"GdkGLProfile"}

widget[GdkGLContext] = {"gdk_gl_context",
{GObject},
	{"new",{},-routine_id("newGLContext")},
	{"get_current",{},P},
	{"clear_current",{}},
	{"make_current",{P}},
	{"get_version",{P,I,I}},
	{"get_shared_context",{P},P,0,GdkGLContext},
	{"get_window",{P},P,0,GdkWindow},
	{"get_visual",{P},P,0,GdkVisual},
	{"get_display",{P},P,0,GdkDisplay},
	{"set_forward_compatible",{P,B}},
	{"get_forward_compatible",{P},B},
	{"set_debug_enabled",{P,B}},
	{"get_debug_enabled",{P},B},
	{"set_required_version",{P,I,I}},
	{"get_required_version",{P,I,I}},
	{"set_use_es",{P,B}}, -- GTK 3.22
	{"get_use_es",{P},B}, -- GTK 3.22
	{"is_legacy",{P},B}, -- GTK 3.20
	{"realize",{P}}, -- GTK 3.16
"GdkGLContext"}

	function newGLContext() -- alias for new;
	return c_func("gdk_gl_context_get_current")
	end function

widget[GtkGLArea] = {"gtk_gl_area", -- GTK 3.16
{GtkWidget,GtkBuildable,GObject},
	{"new",{},P},
	{"get_context",{P},P},
	{"set_has_alpha",{P,B}},
	{"get_has_alpha",{P},B},
	{"set_has_depth_buffer",{P,B}},
	{"get_has_depth_buffer",{P},B},
	{"make_current",{P}},
	{"get_auto_render",{P},B},
	{"set_auto_render",{P,B}},
	{"get_error",{P},P},
	{"set_error",{P,P}},
	{"queue_render",{P}},
	{"set_profile",{P,P}},
	{"get_profile",{P},P,0,GdkGLProfile},
	{"get_has_stencil_buffer",{P},B},
	{"set_has_stencil_buffer",{P,B}},
	{"attach_buffers",{P}},
	{"get_required_version",{P,I,I}},
	{"set_required_version",{P,I,I}},
	{"get_use_es",{P},B}, -- 3.22
	{"set_use_es",{P,B}}, -- 3.22
"GtkGLArea"}

widget[GdkPixbufAnimation] = {"gdk_pixbuf_animation",
{GdkPixbuf,GObject},
	{"new",{P},-routine_id("newPixbufAnimation")},
	{"get_width",{P},I},
	{"get_height",{P},I},
	{"get_delay_time",{P},I},
	{"is_static_image",{P},B},
	{"get_static_image",{P},P,0,GdkPixbuf},
	{"get_iter",{P,P},P,0,GdkPixbufAnimationIter},
"GdkPixbufAnimation"}

	function newPixbufAnimation(object name) -- alias for 'new';
	  atom err = allocate(8,1) err = 0
	  if string(name) and file_exists(canonical_path(name)) then
		name = allocate_string(canonical_path(name),1)
	  end if
	 return gtk_func("gdk_pixbuf_animation_new_from_file",{P,P},{name,err})
	end function

widget[GdkPixbufAnimationIter] = {"gdk_pixbuf_animation_iter",
{GObject},
	{"get_pixbuf",{P},P,0,GdkPixbuf},
	{"advance",{P,P},B},
	{"get_delay_time",{P},I},
	{"on_currently_loading_frame",{P},B},
"GdkPixbufAnimationIter"}

widget[GtkRecentManager] = {"gtk_recent_manager",
{GObject},
	{"new",{},-routine_id("recent_manager_get_default")},
	{"get_default",{},P,0,GtkRecentManager},
	{"add_item",{P,S},B},
	{"add_full",{P,S,P},B},
	{"remove_item",{P,S,P},B},
	{"lookup_item",{P,S,P},P,0,GtkRecentInfo},
	{"has_item",{P,S},B},
	{"move_item",{P,S,S,P},B},
	{"get_items",{P},X,0,GtkRecentInfo},
	{"purge_items",{P,P},I},
"GtkRecentManager"}

   function recent_manager_get_default() -- alias for 'new';
	return gtk_func("gtk_recent_manager_get_default")
   end function
   
--------------------------------------------------------------------------------
-- shortcuts are new in 3.20, inadequate documentation means no way to test yet;
--------------------------------------------------------------------------------
-- Supposedly, all these can be set via set(x,"property","title","FooBar")
-- where x is the handle or name of the shortcut...
-- Except there seems no way to actually create a shortcuts window!

widget[GtkShortcutsWindow] = {"gtk_shortcuts_window",
{GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
-- properties:
-- section-name
-- view-name
"GtkShortcutsWindow"}

widget[GtkShortcutsSection] = {"gtk_shortcuts_section",
{GtkBox,GtkContainer,GtkWidget,GObject},
-- properties;
-- max-height
-- section-name
-- title
-- view-name
"GtkShortcutsSection"}

widget[GtkShortcutsGroup] = {"gtk_shortcuts_group",
{GtkBox,GtkContainer,GtkWidget,GObject},
-- properties;
-- accel-size-group
-- height
-- title
-- title-size-group
-- view
"GtkShortcutsGroup"}

widget[GtkShortcutsShortcut] = {"gtk_shortcuts_shortcut",
{GtkBox,GtkContainer,GtkWidget,GObject},
-- properties;
-- accel-size-group
-- accelerator
-- title
-- title-size-group
-- subtitle
-- subtitle-set
-- direction
-- icon
-- icon-set
-- shortcut-type
"GtkShortcutsShortcut"}

widget[GtkShortcutsGesture] = {"gtk_shortcuts_gesture",
{GtkBox,GtkContainer,GtkWidget,GObject},
-- properties;
-- icon
-- icon-size-group
-- subtitle
-- title
-- title-size-group
"GtkShortcutsGesture"}

widget[GtkBuildable] = {"gtk_buildable",
{GObject},
	{"set_name",{P,S}},
	{"get_name",{P},S},
	{"add_child",{P,P,P,S}},
	{"set_buildable_property",{P,P,S,P}},
	{"construct_child",{P,P,S},P,0,GObject},
	{"custom_tag_start",{P,P,P,S,P,P},B},
	{"custom_tag_end",{P,P,P,S,P}},
	{"custom_finished",{P,P,P,S,P}},
	{"parser_finished",{P,P}},
	{"get_internal_child",{P,P,S},P,0,GObject},
"GtkBuildable"}

widget[GtkBuilder] = {"gtk_builder",
{GObject},
	{"new",{},P},
	{"add_callback_symbol",{P,S,P}}, -- 3.10
	{"lookup_callback_symbol",{P,S},P}, -- 3.10
	{"set_application",{P,P}}, -- 3.10
	{"get_application",{P},P,0,GtkApplication}, -- 3.10
	{"add_from_file",{P,S},-routine_id("addBuilderObjects")},
	{"add_from_string",{P,P},-routine_id("addBuilderObjects")},
	{"get_object",{P,P},P},
	{"get_objects",{P},A,0,GSList},
	{"connect",{P},-routine_id("builder_connect")},
	{"set_translation_domain",{P,S}},
	{"get_translation_domain",{P},S},
	{"get_type_from_name",{P,S},I},
"GtkBuilder"}

export constant builder = create(GtkBuilder)
object current_builder_file = ""

export function ID(atom ctl) -- retrieve the Glade ID property;
	return vlookup(ctl,registry,1,4,"?")
end function

export sequence class_name_index = repeat(0,length(widget))
	for i = 1 to length(widget) do
		if sequence(widget[i]) then
		   class_name_index[i] = widget[i][$]
		end if
	end for

	constant bad_from_file = define_func("gtk_builder_add_from_file",{P,P,P},I)
	constant bad_from_str = define_func("gtk_builder_add_from_string",{P,P,I,P},I)

	function addBuilderObjects(atom bld, object str) 
	  atom err = allocate(8,1) err = 0
	  object fname = 0, result = -1
	  integer len = 0
	  
	  if string(str) and file_exists(locate_file(str)) then
	     fname = allocate_string(locate_file(str))
	     result = c_func(bad_from_file,{bld,fname,err})
	  end if
	          
	  if atom(str) and str > 0 then
	          fname = locate_file(peek_string(str))
		  if string(fname) then
			fname = allocate_string(fname)
			result = c_func(bad_from_file,{bld,fname,err})
		  end if
	  end if
	  
	  if string(str) and not file_exists(locate_file(str)) then
		len = length(str)
		str = allocate_string(str)
		result = c_func(bad_from_str,{bld,str,len,err})
	  end if
	  
	  return result
	end function
	
 -- link signals defined in Glade, this starts a 'for' loop, 
 -- running the builder_connect_function for each control;
	function builder_connect(atom bld)
	gtk_func("gtk_builder_connect_signals_full",{P,P,P},{bld,builder_connect_func,0})
	return 1
	end function

	constant builder_connect_func = call_back(routine_id("builder_connect_function"))

 -- links Glade controls to user-written or Eu functions 
 
	----------------------------------------------------------------------------- 
	function builder_connect_function(atom bld, atom obj, object sig, object hdlr, atom cxo)
	-----------------------------------------------------------------------------
	hdlr = peek_string(hdlr)
	sig = peek_string(sig)
	
	if atom(current_builder_file) and (current_builder_file > 0) then
		current_builder_file = peek_string(current_builder_file)
	end if

	atom rid = routine_id(hdlr) 
		if rid = -1 then
			printf(1,"-----------------------------------------------------------------------\n")
			printf(1,"-- Undeclared function in %s\n",{current_builder_file})
			printf(1,"-----------------------------------------------------------------------\n")
			show_template(hdlr)
			abort(1)
		else
			rid = call_back(rid) 
			connect(obj,sig,rid,cxo)
		end if

	 return 1
	end function

	--------------------------------------------------------------------
	procedure load_builder(object parent, object child, object prefix=0)
	--------------------------------------------------------------------
	object id, name, class, path
	object x, tree
	integer c,n
	atom err = allocate(8,1) 

	current_builder_file = canonical_path(child)
	if file_exists(current_builder_file) then
		set(parent,"add from file",current_builder_file,err)
		set(parent,"connect")
		prefix = filebase(child)
		if match(prefix,filebase(prg_name)) then
			prefix = 0 -- do not prefix main file objects
		end if
		x = read_lines(canonical_path(child))

	elsif string(child) then
		set(parent,"add from string",child,err)
		set(parent,"connect")
		x = split(child,'\n')
	end if

	ifdef BUILDER then
		display(repeat('-',80))
		display("OBJECT               GLADE ID                  WIDGET NAME       HANDLE") 
		display(repeat('-',80))
	end ifdef
	
	for i = 1 to length(x) do
		if string(x[i]) and match("<object class",x[i]) then
			c = match("class=",x[i]) + 7
			n = match("id=",x[i]) + 4

			class = x[i][c..$]
			class = split(class," ")
			class = class[1]
			if class[$] = '"' then class = class[1..$-1] end if

			id = x[i][n..$]
			n = find('"',id)
			id = id[1..n-1]

			n = get(builder,"object",id)

			if string(prefix) then
				id = sprintf("%s:%s",{prefix,id})
			end if
			
			class = find(class,class_name_index)
			if class < 1 then
				display("Error finding class for []",{id})
			else if not initialized[class] then
					init(class)
			end if						
			
			tree = widget[class][2]
			for z = 1 to length(tree) do
				init(tree[z])
			end for
			
			register(n,class,id)
		
			ifdef BUILDER then 
				if equal(class_name(n),get(n,"name")) then
				display("[:20] [:25] [:15] [:10>]",{class_name(n),id,"-",n}) 
				else
				display("[:20] [:25] [:15] [:10>]",{class_name(n),id,get(n,"name"),n}) 
				end if
			end ifdef

		end if
	end if
end for

end procedure

-------------------------------------------------------------------------------
procedure show_template(object handlr) -- prompt for missing functions w/Glade;
-------------------------------------------------------------------------------
-- following is a template, not code. do not edit!
	printf(1,"""
________

		-----------------------------------------------------------------------
		global function %s() 
		-----------------------------------------------------------------------
  
		return 1
		end function

""",{handlr})
-- end template;
end procedure

----------------------------------------------------------------------------
-- Internet conveniences 
----------------------------------------------------------------------------
---------------------------------------
public function show_uri(object uri) -- may be deprecated soon
---------------------------------------

if atom(uri) then
	return 0
end if

ifdef WINDOWS then
	system("explorer " & uri,0)
	return 1
end ifdef
	
integer x = find('#',uri) -- in case link is to an html section;
object tmp

if x > 0 then
	tmp = canonical_path(uri[1..x-1]) -- look for file (sans section link);
	if file_exists(tmp) then
		uri = tmp & uri[x..$] -- replace the section link;
	end if
else
	tmp = canonical_path(uri) 
	if file_exists(tmp) then
		uri = tmp
	end if
end if

atom err = allocate(8,1) err=0

object result = gtk_func("gtk_show_uri",{P,P,P,P},
		{0,allocate_string(uri,1),0,err})
		
 return result
 
end function

--------------------------------------------------------------------------
public function show_uri_on_window(atom win,object uri)
--------------------------------------------------------------------------
atom err  = allocate(8,1) err=0
object result = gtk_func("gtk_show_uri_on_window",
  {P,P,P,P},{win,allocate_string(uri,1),0,err})
return result        
end function

---------------------------------------------------------------------------
-- ICON FUNCTIONS 
---------------------------------------------------------------------------

-----------------------------
export function list_icons()
-----------------------------
atom theme = gtk_func("gtk_icon_theme_get_default")
  object list = gtk_func("gtk_icon_theme_list_icons",{P,P},{theme,0})
 return to_sequence(list)
end function

--------------------------------------
export function has_icon(object name)
--------------------------------------
atom theme = gtk_func("gtk_icon_theme_get_default")
  name = allocate_string(name,1)
 return gtk_func("gtk_icon_theme_has_icon",{P,P},{theme,name})
end function

----------------------------------------
export function valid_icon(object list)
----------------------------------------
-- check a list of possible icon names 

  object result = 0
  if atom(list[1]) then
	list = {list}
  end if
  for i = 1 to length(list) do
	result = get_icon_image(list[i]) 
	if string(result) then return 1 end if
  end for
 return result
end function

---------------------------------------------
export function valid_icon_name(object list)
---------------------------------------------
-- check a list of possible icon names, return name of first valid one found;

  for i = 1 to length(list) do
	if valid_icon({list[i]}) > 0 then
		return list[i]
	end if
	if file_exists(locate_file(list[i])) then
		return list[i]
	end if
  end for
 return "gtk-missing-image"
end function

------------------------------------------------------------------------------------
   function get_icon_image(object icon, object x=0, object y=0, object z=1)
-------------------------------------------------------------------------------------
-- get image from a variety of sources;

atom img = 0, ani = 0, default_theme, handle
handle = to_number(icon)

	if class_id(handle) = GdkPixbuf then 
		img = create(GtkImage,handle)
		return img
	end if

	if class_id(handle) = GtkImage then
		return handle
	end if

	if find(icon,stock_list) then
		img = gtk_func("gtk_image_new_from_stock",{P,I},
			{allocate_string(icon,1),x})
		return img
	end if

	default_theme = gtk_func("gtk_icon_theme_get_default",{})
	if gtk_func("gtk_icon_theme_has_icon",{P,P},
		{default_theme,allocate_string(icon,1)}) then
		img = create(GdkPixbuf,icon,18,18,z)
		img = create(GtkImage,img)
		register(img,GtkImage)
		return img
	end if

	icon = locate_file(icon) 

	if file_type(icon) = 1 then -- image from file
		ani = create(GdkPixbufAnimation,icon,x,y) 
		if gtk_func("gdk_pixbuf_animation_is_static_image",{P},{ani}) then
			ani = create(GdkPixbuf,icon,x*6,y*6,z) 
			img = create(GtkImage,ani) 
	else
		img = create(GtkImage)
		set(img,"from animation",ani)
	end if
	return img
	end if

	return 0
	end function

---------------------------------------------------------
export function icon_info(object name, integer size=6) -- breaks info into fields;
---------------------------------------------------------
 atom theme = gtk_func("gtk_icon_theme_get_default")
 atom err = allocate(8,1) err = 0

 atom icon_info = gtk_func("gtk_icon_theme_lookup_icon",{P,P,I,I},
	{theme,name,size,GTK_ICON_LOOKUP_USE_BUILTIN})

 object results = repeat(0,5)
	results = {
	gtk_func("gtk_icon_info_load_icon",{P,P},{icon_info,err}),
	gtk_func("gtk_icon_info_get_display_name",{P},{icon_info}),
	gtk_str_func("gtk_icon_info_get_filename",{P},{icon_info}),
	gtk_func("gtk_icon_info_get_base_size",{P},{icon_info}),
	gtk_func("gtk_icon_info_get_base_scale",{P},{icon_info})
	}
 return results
-- returns {p1,s2,s3,n4,n5}, where
-- p1 = pointer to icon_info structure, 
-- s2 = display name or null,
-- s3 = full path to icon file, 
-- n4 = base size, 
-- n5 = base scale
-- (some entries are missing in some cases)
end function

---------------------------------------------------------------------------------------
-- See demos/examples/xpm_to_eu_include.ex which is a conversion program 
-- to format an xpm so that it can easily be included as a euphoria .e file. 
-- It calls the following function:
---------------------------------------------------------------------------------------
export function xpm_to_pixbuf(object xpm, integer w=0, integer h=0, integer interp=2)
---------------------------------------------------------------------------------------
atom x = gtk_func("gdk_pixbuf_new_from_xpm_data",{P},
		{allocate_string_pointer_array(xpm)})
if w + h > 0 then
   x = gtk_func("gdk_pixbuf_scale_simple",{P,I,I,I},{x,w,h,interp})
end if
register(x,GdkPixbuf)
return x
end function

------------------------------------------------------------------------
-- Following 3 functions simplify method calls; used mostly internally,
-- but can also be called by the programmer to execute any GTK, GDK or
-- GLib function which has not been implemented in EuGTK.
-------------------------------------------------------------------------
export function gtk_func(object name, object params={}, object values={})
-------------------------------------------------------------------------
	name = prepend(name,'+')

	for i = 1 to length(params) do
		if string(values[i]) then
			values[i] = allocate_string(values[i],1)
		end if
	end for 

	if atom(values) then
	   values = {values}
	end if

	atom fn = define_func(name,params,P)

	if fn > 0 then
		return c_func(fn,values)
	else 
		return -1
	end if
	
end function

-----------------------------------------------------------------------------
export function gtk_str_func(object name, object params={}, object values={})
-----------------------------------------------------------------------------
-- syntax: same as above, except a string result is returned
		
	name = prepend(name,'+')

	for i = 1 to length(params) do
		if string(values[i]) then
			values[i] = allocate_string(values[i],1)
		end if
	end for

	atom fn = define_func(name,params,P)
	object result

	if fn > 0 then
		if length(params) > 0 then
			result = c_func(fn,values) 
		else
			result = c_func(fn,{})
		end if
		if result > 0 then
			return peek_string(result)
		end if
	end if
	
 return 0
end function

--------------------------------------------------------------------------
export function gtk_proc(object name, object params={}, object values={})
--------------------------------------------------------------------------
-- syntax: same as above, but no value is returned, used to call GTK procs
atom fn

	name = prepend(name,'+') 

	if string(values) then values = {values} end if

	for i = 1 to length(params) do
		if sequence(values) and string(values[i]) then 
			values[i] = allocate_string(values[i]) -- keep
		end if
	end for

	if length(params) = 0 then 
		fn = define_proc(name) 
		if fn > 0 then
			c_proc(fn,{})
		end if
	else
		fn = define_proc(name,params) 
		if fn > 0 then
			if atom(values) then values = {values} end if
			c_proc(fn,values)
		end if
	end if
return values
end function
  
-- The following 2 functions had to be added for Windows, so that we could search 
-- a list of dlls until we find the function name requested. I'm not sure the '+'
-- is necessary for 32-bit Windows, since I don't have a 32-bit computer anymore. 

--------------------------------------------------------------------------------
export function define_proc(object name, object params={})
----------------------------------------------------------------------------------
atom x
	for i = 1 to length(LIBS) do
		if atom(LIBS[i]) and LIBS[i] > 0 then
			x = define_c_proc(LIBS[i],name,params)
			if x > 0 then
				return x 
			end if
		end if
	end for
	ifdef PROC then printf(1,"Procedure not found %s\n",{name}) end ifdef
 return -1
end function

---------------------------------------------------------------------------
export function define_func(object name, object params={}, object values=P)
---------------------------------------------------------------------------
atom x
	for i = 1 to length(LIBS) do
		if atom(LIBS[i]) and LIBS[i] > 0 then
			x = define_c_func(LIBS[i],name,params,values)
			if x > 0  then 
				return x 
			end if
		end if
	end for
	ifdef FUNC then printf(1,"Function not found %s\n",{name}) end ifdef
 return -1
end function

------------
-- COLORS --
------------

----------------------------------------
export function to_rgba(object color) -- converts a color description to rgba ptr; 
----------------------------------------
 atom rgba = allocate(32) -- keep;
 object c = color
 if string(c) then c = allocate_string(c,1) end if
 if gtk_func("gdk_rgba_parse",{P,P},{rgba,c}) then
	return rgba
 else
	printf(1,"\nError: invalid color '%s'\n******\n",{color})
	return 0
 end if
return rgba
end function

-------------------------------------------------------
export function from_rgba(object rgba, object fmt=0) -- converts rgba ptr to description;
-------------------------------------------------------
object result = gtk_str_func("gdk_rgba_to_string",{P},{rgba})
 if fmt=0 then return result 
 else return fmt_color(result,fmt) 
 end if
end function

----------------------------------------------
function fmt_color(object s, integer fmt=0) -- Convert color to various formats;
----------------------------------------------
 if atom(s) then
	if string(peek_string(s)) then
		s = peek_string(s)
	end if
  end if
object w
	w = split_any(s,"(,)")
	if length(w[1]) = 3 then
		w[5] = "1"
	end if
	for i = 2 to 5 do
		w[i] = to_number(w[i])
	end for
	if atom(w[5]) then
		w[5] = round(w[5],100)
	end if
	switch fmt do
		case 0 then return w[1..length(w[1])+1] -- rgb(255,0,0) = red (string) default
		case 1 then return sprintf("#%02x%02x%02x",w[2..4]) -- #FF0000 (hex string)
		case 2 then return (256*256*w[2])+(256*w[3])+ w[4]  -- 16711680 (atom)
		case 3 then return {w[2],w[3],w[4]} -- {255,0,0}  r,g,b (sequence)
		case 4 then return {w[2],w[3],w[4],w[5]} -- {255,0,0,1} r,g,b,a (sequence)
		case 5 then return {w[2],w[3],w[4],256*w[5]} -- {255,0,0,256} r,g,b,a (sequence)
		case 6 then return sprintf("rgb(%d,%d,%d)",w[2..$]) -- rgb(255,0,0) (string)
		case 7 then return sprintf("rgba(%d,%d,%d,%2.2f)",w[2..$]) -- rgba(255,0,0,1) (string)
		case 8 then return {w[2]/255,w[3]/255,w[4]/255,w[5]} -- {1,0,0,1} (sequence)
		case 9 then return sprintf("r=#%x, g=#%x, b=#%x, alpha=#%x",w[2..5]) -- r=#FF, g=#0, b=#0, alpha=#1
		case else -- do nothing
	end switch
return s
end function

-----------------------------------------------------------------------
-- BUILT-IN DIALOGS
-----------------------------------------------------------------------
-- Following are 5 pre-built, easy to use popup dialogs 
-- which save you the trouble of writing tons of code!
-- Refer to documentation/dialogs.html for details.
-- Rewritten for 4.8.8 to preserve images on dialog buttons despite
-- GTK developers' bland, boring preferences :P
------------------------------------------------------------------------

public function Info(
	object parent=0, 
	object title="Info",
	object pri_txt="", 
	object sec_txt="",
	object btns=GTK_BUTTONS_OK,
	object image="dialog-information", 
	object icon=0,
	object bkgnd=0,
	integer modal=1,
	object addon=0,
	integer x=-1,
	integer y=-1,
	sequence name="Info")
	return Custom(parent,title,pri_txt,sec_txt,btns,image,icon,bkgnd,modal,addon,x,y,name)
end function

public function Warn(
	object parent=0, 
	object title="Warning",
	object pri_txt="", 
	object sec_txt="",
	object btns=GTK_BUTTONS_CLOSE,
	object image="dialog-warning", 
	object icon=0,
	object bkgnd=0,
	integer modal=1,
	object addon=0,
	integer x=-1,
	integer y=-1,
	sequence name="Warn")
	return Custom(parent,title,pri_txt,sec_txt,btns,image,icon,bkgnd,modal,addon,x,y,name)
end function

public function Error(
	object parent=0, 
	object title="Error",
	object pri_txt="", 
	object sec_txt="",
	object btns=GTK_BUTTONS_OK_CANCEL,
	object image="dialog-error", 
	object icon=0,
	object bkgnd=0,
	integer modal=1,
	object addon=0,
	integer x=-1,
	integer y=-1,
	sequence name="Error")
	return Custom(parent,title,pri_txt,sec_txt,btns,image,icon,bkgnd,modal,addon,x,y,name)
end function

public function Question(
	object parent=0, 
	object title="Question",
	object pri_txt="", 
	object sec_txt="",
	object btns=GTK_BUTTONS_YES_NO,
	object image="dialog-question", 
	object icon=0,	
	object bkgnd=0,
	integer modal=1,
	object addon=0,
	integer x=-1,
	integer y=-1,
	sequence name="Question")
	return Custom(parent,title,pri_txt,sec_txt,btns,image,icon,bkgnd,modal,addon,x,y,name)
end function

-------------------
-- CUSTOM DIALOG -- 
-------------------

public function Custom(
	object parent=0,
	object title="Dialog", 
	object pri_txt="",  
	object sec_txt="",
	object btns=GTK_BUTTONS_OK,
	object image=0,
	object icon=0,
	object bkgnd=0,
	integer modal=GTK_DIALOG_MODAL,
	object addon=0,
	integer x=-1,
	integer y=-1, 
	object name="Dialog") 
------------------------------------------------------------------
object size = 0
integer deletable = 1

atom lbl1 = create(GtkLabel)

	if string(parent) and match("=",parent) then -- parse params:
		parent = keyvalues(parent,";",,,"\r")
		for i = 1 to length(parent) do
		   switch parent[i][1] do
		       case "pri","primary","1" then pri_txt = parent[i][2]
		       case "sec","secondary","2" then sec_txt = parent[i][2]
		       case "title" then title = parent[i][2]
		       case "btn","btns","buttons" then btns = to_number(parent[i][2])
		       case "img","image"  then image = parent[i][2]
		       case "ico","icon" then icon = parent[i][2]
		       case "bkgnd" then bkgnd = parent[i][2]
		       case "mod","modal" then modal = to_number(parent[i][2])
		       case "addon" then addon = pointer(parent[i][2])
		       case "x" then x = to_number(parent[i][2])
		       case "y" then y = to_number(parent[i][2])
		       case "name" then name = parent[i][2]
		       case "size" then size = parent[i][2]
			   case "deletable" then deletable = to_number(parent[i][2])

		       case "pos","position" then parent[i][2] = split(parent[i][2],",")
					x = to_number(parent[i][2][1])
					y = to_number(parent[i][2][2])
					
		       case else -- do nothing
		   end switch
		end for
	end if
	 
	set(lbl1,"markup",text:format("<b>[]</b>\n[]",{pri_txt,sec_txt}))
	 
	atom dlg = create(GtkDialog) 
	set(dlg,"name",name)
	set(dlg,"deletable",deletable)
	if not atom(size) then set(dlg,"size",size) end if
	atom btnbox = create(GtkButtonBox) 
	set(btnbox,"name",name & ".buttonbox")
	object btn = {0,0,0}
	atom ca = 0 
	atom top = 0, left = 0, right = 0
	atom capanel = create(GtkBox,VERTICAL) 
	set(capanel,"name",name & ".panel")
	atom p2 = 0
	
	if atom(bkgnd) and bkgnd > 0 then set(dlg,"background",bkgnd) end if
	if sequence(bkgnd) then set(dlg,"background",bkgnd) end if
	
	if string(parent) then 
		parent = pointer(parent)
	end if
	
	if atom(parent) and parent > 0 and atom(icon) and icon = 0 then
		icon = get(parent,"icon name") 
	end if

	if atom(pri_txt) and pri_txt > 0 then pri_txt = unpack(pri_txt) end if
	if atom(sec_txt) and sec_txt > 0 then sec_txt = unpack(sec_txt) end if
	
	if atom(addon) and addon > 0 and class_id(addon) = GdkPixbuf then 
		addon = create(GtkImage,addon) 
		set(addon,"name",name & ".icon")
	end if

	if atom(addon) and addon > 0 and class_id(addon) = GtkImage then
		set(addon,"name",name & ".icon")
	end if
	
	if atom(parent) and parent > 0 then set(dlg,"transient for",parent) end if
	set(dlg,{
		{"title"," " & title},
		{"border width",5},
		{"icon",icon},
		{"position",GTK_WIN_POS_CENTER}})
		
	if string(name) then
		set(dlg,"name",name)
	end if
	
	ca = get(dlg,"content area")
	set(ca,"name",name & ".content area")
	add(ca,capanel)

	top = create(GtkBox,HORIZONTAL,2)
	set(top,"name",name & ".top")
	add(capanel,top)
	
	left = create(GtkBox,VERTICAL,5) set(left,"name",name & ".left")	
	right = create(GtkBox,VERTICAL,5) set(right,"name",name & ".right")
	add(top,{left,right})
	
	-- add an icon to the dialog;
	if string(image) then 
		image = create(GtkImage,image,GTK_ICON_SIZE_DIALOG)
		set(image,"name",name & ".image")
		add(left,image)
		
	elsif image > 0 then 
		if class_id(image) = GdkPixbuf
		or class_id(image) = GIcon then
			image = create(GtkImage,image)
		end if
		set(image,"name",name & ".image")
		add(left,image)
	end if

	add(right,lbl1)

	if atom(addon) and addon > 0 then
		p2 = create(GtkBox,VERTICAL)
		set(p2,"name",name & ".addon")
		add(capanel,p2)
		if get(addon,"parent") != 0 then
		  set(addon,"reparent",p2)
		else
		  add(p2,addon)
		end if
	end if

	show_all(capanel)

	if integer(btns) then
	
	switch btns do	

		case GTK_BUTTONS_NONE then break

		case GTK_BUTTONS_OK then
			btn[1] = create(GtkButton,"gtk-ok")
			set(btn[1],"name",name & ".ok_button")
			set(dlg,"add action widget",btn[1],MB_OK)
			show(btn[1])
			
		case GTK_BUTTONS_CANCEL then
		        btn[1] = create(GtkButton,"gtk-cancel")
		        set(btn[1],"name",name & ".cancel_button")
		        set(dlg,"add action widget",btn[1],MB_CANCEL)
		        show(btn[1])
		        
		case GTK_BUTTONS_OK_CANCEL then
			btn[1] = create(GtkButton,"gtk-cancel")
			set(btn[1],"name",name & ".cancel_button")
			btn[2] = create(GtkButton,"gtk-ok")
			set(btn[2],"name",name & ".ok_button")
			set(dlg,"add action widget",btn[1],MB_CANCEL)
			set(dlg,"add action widget",btn[2],MB_OK)
			show(btn[1]) show(btn[2])

		case GTK_BUTTONS_CLOSE then
			btn[1] = create(GtkButton,"gtk-close")
			set(btn[1],"name",name & ".close_button")
			set(btn[1],"can default",TRUE)
			set(dlg,"add action widget",btn[1],MB_CLOSE)
			show(btn[1])

		case GTK_BUTTONS_YES_NO then
			btn[1] = create(GtkButton,"gtk-yes")
			set(btn[1],"name",name & ".yes_button")
			set(dlg,"add action widget",btn[1],MB_YES)
			btn[2] = create(GtkButton,"gtk-no")
			set(btn[2],"name",name & ".no_button")
			set(dlg,"add action widget",btn[2],MB_NO)
			show(btn[1]) show(btn[2])

		case else btn[1] = create(GtkButton,"gtk-ok")
			set(btn[1],"can default",TRUE)
			set(btn[1],"name",name & ".ok_button")
			set(dlg,"add action widget",btn[1],MB_OK)
			show(btn[1])

		end switch
	end if

	if sequence(btns) and not atom(btns[1]) then
	   set(btnbox,"margin top",5)
	   pack(capanel,-btnbox)
		for i = 1 to length(btns) do
			while length(btns[i]) < 3 do btns[i] &= 0 end while
			if atom(btns[i][3]) and btns[i][3] = 0 then 
				btns[i][3] = {dlg,MB_CANCEL} 
			end if
			btns[i] = create(GtkButton,btns[i][1],btns[i][2],btns[i][3])
		end for
		add(btnbox,btns)
		show_all(btnbox)
	end if

	if x+y > 0 then 
		set(dlg,"move",x,y)
	end if

	atom result = 0
	set(dlg,"modal",modal)
	if modal = GTK_DIALOG_NON_MODAL then
		show_all(dlg) -- show and leave on screen;
		return 1
	else -- run and clean up;
		result = run(dlg)
		destroy(dlg)
		deregister(dlg)
		deregister(btn[1])
		deregister(btn[2])
		deregister(btn[3])
		deregister(icon)
		deregister(image)
		deregister(addon)
		deregister(top)
		deregister(left)
		deregister(right)
		deregister(lbl1)
		deregister(ca)
		deregister(p2)
		deregister(btnbox)
		deregister(capanel)
	end if
	 
 return result
end function

----------------------------------
export function run(object dlg) -- what it says;
----------------------------------
  if string(dlg) then
	  dlg = pointer(dlg)
  end if
return get(dlg,"run")
end function

constant settings = create(GtkSettings) -- init so we can check user's WinMgr preferences;

export function current_desktop(atom s = gtk_func("gdk_screen_get_default"))
return gtk_func("gdk_x11_screen_get_current_desktop",{P},{s})
end function

export function is_composited(atom s = gtk_func("gdk_screen_get_default"))
return gtk_func("gdk_screen_is_composited",{P},{s})
end function

--=============================================================--
-- Nifty shortcut - thanks to Greg Haberek
-- usage: _("MyFunk")
-- allows using local functions without call_back(routine_id()) 
-- and scope issues.
--=============================================================--
export function _(sequence name, atom rid = routine_id(name))
 if rid > 0 then
    return call_back(rid)
 end if
 return 0
end function

--====================================================--
-- following 2 functions supply popup error reporting
-- for Eu errors when using the BEAR to edit eu source
--====================================================--

global object syntax_error_message = 0

---------------------------------------------------------------------
function log_err(atom domain, integer level, object msg, object data)
---------------------------------------------------------------------
  msg = peek_string(msg) 
  if match(":",msg) then
	msg = split(msg,':')
  else msg = {"Log",msg,log_err_name(level)} 
  end if
  
  if level = 16 then 
	ifdef LOG_WARNING then
		display("[] level [] [] []\n[]",{log_err_name(level),level,msg[1],msg[3],msg[$]})
	end ifdef
  return 1
  end if 
  
  msg[1] = transmute(msg[1],{{},'<','>','&'},{{},"&lt;","&gt;","&amp;"})
  msg[2] = transmute(msg[2],{{},'<','>','&'},{{},"&lt;","&gt;","&amp;"})
  
  if level > 8 and level < 128 and level != 32  then 
	Error(,sprintf("%s %d",{log_err_name(level),level}),msg[1],msg[2]) 
  end if
  
  ifdef DEBUG then
  if level >= 128 then 
     Info(,,text:format("Error level [] []",{level,log_err_name(level)}))
     display("Error level [] []",
	{level,log_err_name(level)})
     return 1
  end if
  end ifdef

return 0
end function

gtk_func("g_log_set_default_handler",{P,P},{call_back(routine_id("log_err")),0})

without warning
------------------------------------------------------
export function ParseErrorFile(object erf = "ex.err") 
------------------------------------------------------
object file_name
object file_lines
object temp_line
object err_line = 0
object err_msg =  "?"
object err_hdr = "?"
integer err_col = 1
integer i

    if not file_exists(erf) then
        return 0
    end if
    
    file_lines = read_lines(erf)
    if atom(file_lines) then  -- ex.err was empty
	return 0
    end if

    object x = split(file_lines[1])
    
    err_hdr = x[1]

    for n = 1 to length(file_lines)  do
        if match("^^^ call-back from external source",file_lines[n]) = 1 then
            file_lines = file_lines[1..n-1] -- get rid of non-useful part of ex.err listing;
            exit
        end if
    end for
 
    -- trap & process GTK signal 11 errors;
        for n = length(file_lines) to 2 by -1 do
            -- start at end of ex.err, to find last (topmost) error line #;
            if match("... called from /", file_lines[n]) then 
                i = find(':', file_lines[n]) 
                file_name = file_lines[n][17..i-1]
                err_line = file_lines[n][i+1..$]
                i = find(' ',err_line)
                err_line = err_line[1..i-1]
                err_line = to_integer(err_line)
            end if
        end for

    -- trap & process euphoria error report;
        for n = 1 to length(file_lines) do
            -- start at top of ex.err, to find first syntax error;
            if find('^', file_lines[n]) then
                i = find(':',file_lines[1])
                file_name = file_lines[1][1..i-1]
                err_line = to_integer(file_lines[1][i+1..$])
            end if 
        end for

    for n = 1 to length(file_lines) do
	if match("...",file_lines[n]) = 1 then
	        err_hdr = file_lines[n]
	end if

    end for
            
err_msg = file_lines[2..6]
err_msg = {err_hdr} & err_msg
err_msg = join(err_msg,'\n')

return {err_msg,err_line-1,err_col}
end function

--------------------------------------------------
-- copyright 2005-2019 by Irv Mullins
--------------------------------------------------
