
--------------------
namespace printer -- Utility to make printing easier
--------------------

export constant version = "4.15.0"

/*
 * --    FUNCTIONS:		        CALLBACKS:
 *       printer:PrintFile()    printer:print_file
 *       printer:PrintText()    printer:print_text
 *       printer:reset()
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

----------------------------------------------------------------------------------
-- This version handles most common printing needs, but it will not yet respect --
-- 'marked up' a.k.a. 'rich' text, i.e. text with colors and styles as produced --
-- by GTK3's TextView widget. It just prints them as plain text.                --
--                                                                              --
-- However, it DOES print text marked up with GTK's HTML subset, so you can use --
-- <b>, <i>, <u>, <span>, <font> ... etc. in your printouts!                    -- 
-- This includes various imbedded font styles and colors.                       --
--                                                                              --
-- EuGTK4.14.0: It can also now print Euphoria code with syntax coloration,     --
-- using syncolor.e!                                                            --
--                                                                              --
-- More documentation is found in ~/documentation/printing.html                 --
--                                                                              --
----------------------------------------------------------------------------------

include GtkEngine.e
include GtkCairo.e

include euphoria/tokenize.e
include euphoria/syncolor.e

include std/datetime.e
include std/text.e
include printer_icon.e

if not equal(version,gtk:version) then
    Error(,,"GtkPrinter version mismatch","should be version " & gtk:version)
end if

export atom
    GtkPrinter = 0, GtkPrintJob = 0, GtkPageRange = 0, GtkPrintSettings = 0,
    GtkPaperSize = 0, GtkPageSetup = 0, GtkPageSetupUnixDialog = 0,
    GtkPrintOperation = 0, GtkPrintContext = 0, GtkPrintUnixDialog = 0

object settings
InitializePrintFunctions()

constant default_header = "<big><b>[1]</b></big>\n\n"
constant default_subheader = "<b>[1]</b> page [5] of [6]\n\n"
constant default_footer = "<small>\n<i>Printed [8] from [9]'s computer.</i></small>"

-- The following exported variables can be modified before calling the  print routine:

export object header = default_header
export object subheader = default_subheader
export object footer = default_footer
export object print_operation
export object print_op_jobname
export atom progress = create(GtkProgressBar)

/*
-- Substitutes for use in header and footer formatting string [x], where x =

  1 = page title (for first page)
  2 = sub title (for subsequent pages - leave null to use page title (1) on all pgs)
  3 = file name
  4 = short name (file name w/o path)
  5 = current page number
  6 = n_pages printed e.g. pg 1 of n
  7 = n_copies requested
  8 = today's date in date_format
  9 = user name
 10 = user's real name
 11 = font name used for this print job
 12 = file length in bytes
 13 = file timestamp
 14 = exported filename, if any
 15 = printer name
 16 = job name
 17 = n_pages_to_print

*/

export integer -- all of these are available to change from your source code;
    n_pages = 0,  -- number of pages to print (0=all)
    n_copies = 1,
    collate = FALSE,
    duplex = 0,
    number_up = 1, -- refer to Gtk docs for these items;
    number_up_layout = 1,
    units = GTK_UNIT_INCH,
    use_line_numbers = FALSE,
    use_color = TRUE,
    use_syntax_color = TRUE,
    use_markup = TRUE,
    lines_per_page = 60,
    wrap_at = 0,
    track_status = TRUE,
    show_progress = TRUE, -- built-in progressbar
    embed_page_setup = TRUE,
    orientation = 0,
    order = 0,
    confirm = FALSE,
    sourcecode = TRUE,
    plaintext = FALSE,
    use_full_page = FALSE, -- ignore margins
    has_selection = FALSE,
    support_selection = FALSE,
    quality = GTK_PRINT_QUALITY_DRAFT,
    action = GTK_PRINT_OPERATION_ACTION_PRINT_DIALOG,
    auto_lpp = TRUE

export atom
    scale = 100,
    top_margin = 0.25, -- in inch units
    left_margin = 0.25,
    right_margin = 0.25,
    bottom_margin = 0.25,
    parent = 0

export object
    printername = 0,
    font = "Ubuntu Mono 8",
    settings_file = 0,
    setup_file = 0,
    export_file = 0,
    page_ranges = 0,
    page_set = GTK_PAGE_SET_ALL,
    custom_tab_hook = 0,
    custom_tab_label = 0,
    custom_tab_func = 0

-- use date and time formats in std/datetime.e;
export sequence date_format = "%A, %B %d %Y %l:%M %p"

export object
    line_number_format = "[:4] []\n",   -- controls line # format AND code line!
    paper_name = "na_letter",           -- 8.5x11.0"
    tabs = repeat(' ',4)               -- replace tab chars with spaces

object -- used internally;
    file_name = 0,
    short_name = 0,
    page_title ="",
    sub_title ="",

    -- don't mess with these:
    signal_status_changed = call_back(routine_id("show_status")),
    signal_begin_print = call_back(routine_id("begin_print")),
    signal_draw_page = call_back(routine_id("draw_page")),
    signal_end_print = call_back(routine_id("end_print")),
    signal_request_page_setup = 0,
    signal_done = 0,
    signal_ready = 0,
    signal_got_page_size = 0

sequence user = user_name

-- for local use;
atom fontdesc
integer filesize = 0
integer colored = 1
object jobname = 0
object timestamp = 0
object text
sequence today  = datetime:format(datetime:now(),date_format)

------------------------
export procedure reset()
------------------------
    n_pages = 0
    n_copies = 1
    collate = FALSE
    duplex = 0
    number_up = 1
    number_up_layout = 1
    units = GTK_UNIT_INCH
    use_line_numbers = FALSE
    use_color = TRUE
    use_syntax_color = FALSE
    use_markup = TRUE
    lines_per_page = 60
    wrap_at = 0
    track_status = TRUE
    show_progress = TRUE
    embed_page_setup = TRUE
    orientation = 0
    order = 0
    confirm = FALSE
    sourcecode = FALSE
    plaintext = FALSE
    use_full_page = FALSE
    has_selection = FALSE
    support_selection = FALSE
    quality = GTK_PRINT_QUALITY_DRAFT
    action = GTK_PRINT_OPERATION_ACTION_PRINT_DIALOG
    auto_lpp = TRUE

    scale = 100
    top_margin = 0.25
    left_margin = 0.25
    right_margin = 0.25
    bottom_margin = 0.25
    parent = 0

    paper_name = "na_letter"
    font = "Ubuntu Mono 8"
    header = default_header
    subheader = default_subheader
    page_title = ""
    footer = default_footer
    settings_file = 0
    setup_file = 0
    export_file = 0
    page_ranges = 0
    page_set = GTK_PAGE_SET_ALL
    custom_tab_hook = 0
    custom_tab_label = 0
    custom_tab_func = 0

end procedure

------------------------------------------------------------------------
export function PrintFile(object f=0, object x=0)
------------------------------------------------------------------------

if string(f) and string(x) then
    page_title = f
    file_name = canonical_path(x)
    timestamp = file_timestamp(file_name)
    filesize = file_length(file_name)
    short_name = filebase(file_name)
    text = read_file(file_name)
    setup_printer()
    return 1
end if

if string(f) and atom(x) and x = 0 then
    f = canonical_path(f)
    file_name = f
    timestamp = file_timestamp(f)
    filesize = file_length(f)
    short_name = filebase(f)
    page_title = filename(f)
    text = read_file(f)
    setup_printer()
    return 1
end if

if string(f) and atom(x) and x < 100 then
    page_title = f
    short_name = f
    file_name = f
    text = read_file(x)
    setup_printer()
    return 1
end if

if atom(f) and atom(x) and x < 101 then
    if atom(file_name) then
        file_name = ""
    end if
    if atom(short_name) then
        short_name = ""
    end if
    if atom(page_title) then
        page_title = ""
    end if
    text = read_file(x)
    setup_printer()
    return 1
end if

if atom(f) and atom(x) then
    x = unpack(x)
    x = canonical_path(x)
    file_name = x
    short_name = filebase(x)
    page_title = filename(x)
    timestamp = file_timestamp(x)
    filesize = file_length(x)
    text = read_file(x)
    setup_printer()
    return 1
end if

reset()

return 1
end function
export constant print_file = call_back(routine_id("PrintFile"))

------------------------------------------------------------------------
export function PrintText(object f=0, object x=0)
------------------------------------------------------------------------

if string(f) and string(x) then
    page_title = f
    text = x
    setup_printer()
    return 1
end if

if atom(f) and string(x) then
    setup_printer()
    text = x
    return 1
end if

if atom(f) and  atom(x) then
    text = unpack(x)
    setup_printer()
    return 1
end if

return 0
end function
export constant print_text = call_back(routine_id("PrintText"))

integer status_code
sequence status_string

-----------------------------------------------
export function show_status(atom op)
-----------------------------------------------
atom
    fn1 = define_func("gtk_print_operation_get_status",{P},I),
    fn2 = define_func("gtk_print_operation_get_status_string",{P},S)

status_code = c_func(fn1,{op})
status_string = peek_string(c_func(fn2,{op}))

ifdef PRINT then display("Status [] []",{status_code,status_string}) end ifdef

if show_progress then
    set(progress,"text",status_string)
end if

return 1
end function

------------------------------------------------------
export function begin_print(atom op, atom context)
------------------------------------------------------
ifdef PRINT then display("Begin printing [] pages ",length(text)) end ifdef

object fsize
fontdesc = create(PangoFontDescription,font)

if auto_lpp then -- try to compute proper # lines;
atom setup = get(op,"default page setup")
    atom pght = get(setup,"page height",GTK_UNIT_POINTS)
    pght -= get(setup,"top margin",GTK_UNIT_POINTS)
    pght -= get(setup,"bottom margin",GTK_UNIT_POINTS)

    atom fs
    fs = get(fontdesc,"size")  / 1024
    fs = fs * (96/72)

    ifdef WINDOWS then
		fs = get(fontdesc,"size") / 1024
		fs = fs * (96/56)
	end ifdef

    integer lpp = 0
    while ((fs*lpp)) < pght do
        lpp += 1
    end while
    lines_per_page = lpp - 3

    ifdef PRINT then
	   display("Font size [], Page height [] Lines per pg: []",
		{floor(fs),floor(pght),lpp-3})
    end ifdef

end if

text = process_text(text)

set(op,"n pages",n_pages)
-- important, as a new value for n_pages is computed
-- based on the length of the file being read, unless a set number
-- has been provided from the calling program.

if show_progress then -- turn on the progress dialog in the calling program
    show_all(progress)
end if

return 1
end function

----------------------------------------------------------------------------
export function draw_page(atom op, atom context, integer pg, atom data)
----------------------------------------------------------------------------
atom fn6 = define_func("gtk_print_context_get_cairo_context",{P},P)

atom cr = c_func(fn6,{context})
atom pl = create(PangoCairoLayout,cr)

    set(pl,"font description",fontdesc)

pg += 1
if pg > length(text) then
    set(progress,"text","Printing complete")
    return 0
end if

if show_progress then
    set(progress,"text",sprintf("Printing page %d",pg))
    set(progress,"fraction",pg/n_pages)
end if

object details = {
    page_title, --1
    sub_title,	--2
    file_name,	--3
    short_name, --4
    pg,			--5
    n_pages,	--6
    n_copies,	--7
    today,		--8
    user,		--9
    real_name,  --10
    font,		--11
    filesize,	--12
    timestamp,	--13
    export_file,--14
    printername,--15
    jobname	   -- 16
    }

object page
integer lines = length(text[pg])

if atom(header) then header = "<b><u>[1]</u> page [5] of [6]</b>\n\n" end if

if pg = 1 or atom(subheader) then
    page = text:format(header,details)
    & flatten(text[pg])
    & text:format(footer,details)
else
    page = text:format(subheader,details)
    & flatten(text[pg])
    & text:format(footer,details)
end if

if plaintext then
    set(pl,"text",page,length(page))
end if
if use_markup then
    set(pl,"markup",page,length(page))
end if

set(pl,"update layout",cr)
set(pl,"show layout",cr)

ifdef PRINT then printf(1,"Page %d: %d lines\n",{pg,lines}) end ifdef

return 1
end function

------------------------------------------------------------------------
function process_text(object txt)
------------------------------------------------------------------------
integer a,b

object color
object line

txt = split(txt,'\n')
colored = 1

for i = 1 to length(txt) do -- replace chars which will confuse markup

    txt[i] = join(split(txt[i],'&'),"&amp;")
    txt[i] = join(split(txt[i],"&amp;amp;"),"&amp;")

    if sourcecode then -- modify special characters;
        txt[i] = join(split(txt[i],'<'),"&lt;")
        txt[i] = join(split(txt[i],'>'),"&gt;")
    end if

    if use_syntax_color then  -- color code the comments;
       line = SyntaxColor(txt[i])           

        for n = 1 to length(line) do

           if match("/*",trim_head(line[n][2]))=1 then colored = 0 end if
           if match("*/",line[n][2]) then colored = 1 end if

          if colored then
           switch line[n][1] do
			case 10040115 then line[n] = text:format("<span color='purple'>[2]</span>",line[n])-- brackets
			case 16711765 then line[n] = text:format("<span color='red'>[2]</span>",line[n]) -- comment color
			case 255 then line[n] = text:format("<span color='blue'>[2]</span>",line[n]) -- keyword color
			case 3342387 then line[n] = text:format("<span color='black'>[2]</span>",line[n]) -- normal text
			case 41011 then  line[n] = text:format("<span color='green'>[2]</span>",line[n])-- string color
			case 5570815 then line[n] = text:format("<span color='purple'>[2]</span>",line[n]) -- brackets 1
			case 65280 then line[n] = text:format("<span color='brown'>[2]</span>",line[n]) -- brackets 2
			case else line[n] = text:format("<b>[2]</b>",line[n])
           end switch
          else
			line[n] = text:format("<i>[2]</i>",line[n])
          end if

		   if line[n][1] != 16711765 then line[n] = colorize(line[n]) end if

           a = match("/*",line[n]) -- fix formatting problem with start ml comment;
           if a > 0 then
		   line[n] = remove_all(10,line[n])
           end if

        end for
        txt[i] = flatten(line)
    end if

    if use_line_numbers then
        txt[i] =  text:format(line_number_format,{i,txt[i]})
    else
        txt[i] &= '\n'
    end if

end for

txt = breakup(txt,lines_per_page)
n_pages = length(txt)

return txt
end function

constant KW = {
"create","add","set","get","pack_end","pack_start","pack","show_all","show","main","run",
"requires","Info","Warn","Error","Question","gtk_func","gtk_proc","gtk_str_func","connect",
"destroy","Quit",
$}
constant EW = {"call_back"}

function colorize(object x)
integer a = 0, b = 0
for i = 1 to length(KW) do
    a = match(KW[i],x)
    if a > 0 then
       ifdef CC then display(x) end ifdef
        b = a + length(KW[i])-1
		if length(x[a..b]) != length(KW[i]) then return x end if
	    if colored then
            x = replace(x,text:format("<span color='magenta'>[]</span>",{KW[i]}),a,b)
        end if
    end if
end for
for i = 1 to length(EW) do
    a = match(EW[i],x)
    if a > 0 then
        b = a + length(EW[i])-1
        if a > 1 and t_alnum(x[a-1]) then return x end if
	    if b < length(x) and t_alnum(x[b+1]) then return x end if
	    if colored then
            x = replace(x,text:format("<span color='orange'>[]</span>",{EW[i]}),a,b)
        end if
    end if
end for
return x
end function

------------------------------------------------------------------------
export function end_print()
------------------------------------------------------------------------
status_string  = "Printing complete"
ifdef PRINT then display(status_string) end ifdef
return 1
end function

---------------------------------------------------------------
export function setup_printer()
---------------------------------------------------------------
atom _size = create(GtkPaperSize,paper_name)
atom err = allocate(16) err = 0
object results = 0

atom fn7 = define_func("gtk_print_operation_run",{P,I,P,P},I)
atom fn8 = define_func("gtk_print_run_page_setup_dialog",{P,P,P},P)

    set(settings,"paper size",_size,units)
    set(settings,"n copies",n_copies)
    set(settings,"collate",collate)
    set(settings,"duplex",duplex)
    set(settings,"reverse",order)
    set(settings,"scale",scale)
    set(settings,"quality",quality)
    set(settings,"number up",number_up)
    set(settings,"number up layout",number_up_layout)

atom setup = create(GtkPageSetup)
    set(setup,"paper size",_size)
    set(setup,"orientation",orientation)
    set(setup,"left margin",left_margin,units)
    set(setup,"right margin",right_margin,units)
    set(setup,"top margin",top_margin,units)
    set(setup,"bottom margin",bottom_margin,units)

atom printop = create(GtkPrintOperation)
    set(printop,"print settings",settings)
    set(printop,"default page setup",setup)
    set(printop,"show progress",show_progress)
    set(printop,"track print status",track_status)
    set(printop,"embed page setup",embed_page_setup)
    set(printop,"support selection",support_selection)
    set(printop,"has selection",has_selection)
    set(printop,"use full page",use_full_page)
    
    if action = GTK_PRINT_OPERATION_ACTION_EXPORT then
        export_file = canonical_path(export_file)
        set(printop,"export filename",export_file)
    end if

    if custom_tab_hook != 0 then
        set(printop,"custom tab label",custom_tab_label)
        connect(printop,"create-custom-widget",custom_tab_func,printop)
        connect(printop,"custom-widget-apply",custom_tab_hook)
    end if

    if string(jobname) then
        set(printop,"job name",jobname)
    end if

    if string(printername) then
        set(settings,"printer",printername)
    end if

    connect(printop,"status-changed",signal_status_changed)
    connect(printop,"begin-print",signal_begin_print)
    connect(printop,"draw-page",signal_draw_page)
    connect(printop,"end-print",signal_end_print)
    connect(printop,"request-page-setup",signal_request_page_setup)
    connect(printop,"done",signal_done)
    connect(printop,"ready",signal_ready)
    connect(printop,"got-page-size",signal_got_page_size)

    if string(setup_file) and file_exists(canonical_path(setup_file)) then
          get(setup,"to file",canonical_path(setup_file))
    end if

    c_func(fn7,{printop,action,parent,err}) -- start the print process;
    
    if confirm then
        if action =  GTK_PRINT_OPERATION_ACTION_EXPORT then
            if Question(0,"PDF Written",
                sprintf("%s\n<small>Folder: %s</small>",
                    {filename(export_file),pathname(export_file)}),
                sprintf("%s\nStatus: %d\n%s\nClick Yes to view",
                {jobname,printername,status_string}),,,"printer") = MB_YES then
                 show_uri("file://" & export_file)
            end if
        end if
    end if

return 1
end function

header = "<b><u>[1]</u></b>\n\n"

------------------------------------------------
-- PRINTER FUNCTIONS
------------------------------------------------

procedure InitializePrintFunctions()

widget = append(widget, {"gtk_page_range",
{0},
"GtkPageRange"})
 GtkPageRange = length(widget)

widget = append(widget, {"gtk_print_settings",
{GObject},
	{"new",{P,P},-routine_id("newPrintSettings")},
	{"load_file",{P,S,P},B},
	{"to_file",{P,S,P},B},
	{"load_key_file",{P,P,S,P},B},
	{"to_key_file",{P,P,S}},
	{"copy",{P},P},
	{"has_key",{P,S},B},
	{"get",{P,S},S},
	{"set",{P,S,S}},
	{"unset",{P,S}},
	{"foreach",{P,P,P}},
	{"get_bool",{P,S},B},
	{"set_bool",{P,S,B}},
	{"get_double",{P,S},D},
	{"get_double_with_default",{P,S,D},D},
	{"set_double",{P,S,D}},
	{"get_length",{P,S,I},D},
	{"set_length",{P,S,D,I}},
	{"get_int",{P,S},I},
	{"get_int_with_default",{P,S,I},I},
	{"set_int",{P,S,I}},
	{"get_printer",{P},S},
	{"set_printer",{P,S}},
	{"get_orientation",{P},I},
	{"set_orientation",{P,I}},
	{"get_paper_size",{P},P},
	{"set_paper_size",{P,P}},
	{"get_paper_width",{P,I},D},
	{"set_paper_width",{P,D,I}},
	{"get_paper_height",{P,I},D},
	{"set_paper_height",{P,D,I}},
	{"get_use_color",{P},B},
	{"set_use_color",{P,B}},
	{"get_collate",{P},B},
	{"set_collate",{P,B}},
	{"get_reverse",{P},B},
	{"set_reverse",{P,B}},
	{"get_duplex",{P},I},
	{"set_duplex",{P,I}},
	{"get_quality",{P},I},
	{"set_quality",{P,I}},
	{"get_n_copies",{P},I},
	{"set_n_copies",{P,I}},
	{"get_number_up",{P},I},
	{"set_number_up",{P,I}},
	{"get_number_up_layout",{P},I},
	{"set_number_up_layout",{P,I}},
	{"get_resolution",{P},I},
	{"set_resolution",{P,I}},
	{"get_resolution_x",{P},I},
	{"get_resolution_y",{P},I},
	{"get_printer_lpi",{P},D},
	{"set_printer_lpi",{P,D}},
	{"get_scale",{P},D},
	{"set_scale",{P,D}},
	{"get_print_pages",{P},I},
	{"set_print_pages",{P,I}},
	{"get_page_ranges",{P,I},P,0,GtkPageRange},
	{"set_page_ranges",{P,P},-routine_id("ps_set_page_ranges")},
	{"get_page_set",{P},I},
	{"set_page_set",{P,I}},
	{"get_default_source",{P},S},
	{"set_default_source",{P,S}},
	{"get_media_type",{P},S},
	{"set_media_type",{P,S}},
	{"get_dither",{P},S},
	{"set_dither",{P,S}},
	{"get_finishings",{P},S},
	{"set_finishings",{P,S}},
	{"get_output_bin",{P},S},
	{"set_output_bin",{P,S}},
"GtkPrintSettings"})
 GtkPrintSettings = length(widget)
 settings = create(GtkPrintSettings)

widget = append(widget, {"gtk_printer",
{GObject},
	{"new",{S,P,B},P},
	{"get_backend",{P},P},
	{"get_name",{P},S},
	{"get_state_message",{P},S},
	{"get_description",{P},S},
	{"get_location",{P},S},
	{"get_icon_name",{P},S},
	{"get_job_count",{P},I},
	{"is_active",{P},B},
	{"is_paused",{P},B},
	{"is_accepting_jobs",{P},B},
	{"is_virtual",{P},B},
	{"is_default",{P},B},
	{"accepts_ps",{P},B},
	{"accepts_pdf",{P},B},
	--{"list_papers",{P},X,0,GList}, -- buggy!
	{"compare",{P,P},I},
	{"has_details",{P},B},
	{"request_details",{P}},
	{"get_capabilities",{P},I},
	{"get_default_page_size",{P},P,0,GtkPageSetup},
	{"get_hard_margins",{P,D,D,D,D},B},
"GtkPrinter"})
 GtkPrinter = length(widget)

widget = append(widget, {"gtk_print_job",
{GObject},
	{"new",{S,P,P,P},P},
	{"get_settings",{P},P,0,GtkPrintSettings},
	{"get_printer",{P},P,0,GtkPrinter},
	{"get_title",{P},S},
	{"get_status",{P},I},
	{"set_source_file",{P,S,P},B},
	{"get_surface",{P,P},P,0,CairoSurface_t},
	{"send",{P,P,P,P}},
	{"set_track_print_status",{P,B}},
	{"get_track_print_status",{P},B},
	{"get_pages",{P},I},
	{"set_pages",{P,I}},
	{"get_page_ranges",{P,I},P,0,GtkPageRange},
	{"set_page_ranges",{P,P},-routine_id("setPageRanges")},
	{"get_page_set",{P},I},
	{"set_page_set",{P,I}},
	{"get_num_copies",{P},I},
	{"set_num_copies",{P,I}},
	{"get_scale",{P},D},
	{"set_scale",{P,D}},
	{"get_n_up",{P},I},
	{"set_n_up",{P,I}},
	{"get_n_up_layout",{P},I},
	{"set_n_up_layout",{P,I}},
	{"get_rotate",{P},B},
	{"set_rotate",{P,B}},
	{"get_collate",{P},B},
	{"set_collate",{P,B}},
	{"get_reverse",{P},B},
	{"set_reverse",{P,B}},
"GtkPrintJob"})
 GtkPrintJob = length(widget)

widget = append(widget,{"gtk_paper_size",
{0},
	{"new",{P,P,D,D},-routine_id("newPaperSize")},
	{"new_from_ppd",{S,S,D,D},P,0,length(widget)+1},
	{"new_from_ipp",{S,D,D},P,0,length(widget)+1}, -- 3.16
	{"new_custom",{S,S,D,D,I},P,0,length(widget)+1},
	{"copy",{P},P,0,length(widget)+1},
	{"is_equal",{P,P},B},
	{"get_name",{P},S},
	{"get_display_name",{P},S},
	{"get_ppd_name",{P},S},
	{"get_width",{P,I},D},
	{"get_height",{P,I},D},
	{"is_custom",{P},B},
	{"set_size",{P,D,D,I}},
	{"get_default_top_margin",{P,I},D},
	{"get_default_bottom_margin",{P,I},D},
	{"get_default_left_margin",{P,I},D},
	{"get_default_right_margin",{P,I},D},
"GtkPaperSize"})
 GtkPaperSize = length(widget)

widget = append(widget, {"gtk_page_setup",
{GObject},
	{"new",{},P},
	{"copy",{P},P},
	{"get_orientation",{P},I},
	{"set_orientation",{P,I}},
	{"get_paper_size",{P},P,0,GtkPaperSize},
	{"set_paper_size",{P,P}},
	{"get_top_margin",{P,I},D},
	{"set_top_margin",{P,D,I}},
	{"get_bottom_margin",{P,I},D},
	{"set_bottom_margin",{P,D,I}},
	{"get_left_margin",{P,I},D},
	{"set_left_margin",{P,D,I}},
	{"get_right_margin",{P,I},D},
	{"set_right_margin",{P,D,I}},
	{"set_paper_size_and_default_margins",{P,P}},
	{"get_paper_width",{P,I},D},
	{"get_paper_height",{P,I},D},
	{"get_page_width",{P,I},D},
	{"get_page_height",{P,I},D},
	{"new_from_file",{S,P},P,0,GtkPaperSize},
	{"load_file",{P,S,P},B},
	{"to_file",{P,S},-routine_id("ps_to_file")},
"GtkPageSetup"})
 GtkPageSetup = length(widget)

widget = append(widget,{"gtk_print_operation",
{GObject},
	{"new",{},P},
	{"set_allow_async",{P,B}},
	{"get_error",{P,P}},
	{"set_default_page_setup",{P,P}},
	{"get_default_page_setup",{P},P,0,GtkPageSetup},
	{"set_print_settings",{P,P}},
	{"get_print_settings",{P},P,0,GtkPrintSettings},
	{"set_job_name",{P,S}},
	{"get_job_name",{P},-routine_id("getPrintOpJobName")},
	{"set_n_pages",{P,I}},
	{"get_n_pages_to_print",{P},I},
	{"set_current_page",{P,I}},
	{"set_use_full_page",{P,B}},
	{"set_unit",{P,I}},
	{"set_export_filename",{P,S}},
	{"set_show_progress",{P,B}},
	{"set_track_print_status",{P,B}},
	{"set_custom_tab_label",{P,S}},
	{"run",{P,P,P,P},I},
	{"cancel",{P}},
	{"draw_page_finish",{P}},
	{"set_defer_drawing",{P}},
	{"get_status",{P},I},
	{"get_status_string",{P},S},
	{"is_finished",{P},B},
	{"set_support_selection",{P,B}},
	{"get_support_selection",{P},B},
	{"set_has_selection",{P,B}},
	{"get_has_selection",{P},B},
	{"set_embed_page_setup",{P,B}},
	{"get_embed_page_setup",{P},B},
"GtkPrintOperation"})
 GtkPrintOperation = length(widget)

widget = append(widget, {"gtk_print_context",
{GObject},
	{"get_cairo_context",{P},P},
	{"set_cairo_context",{P,P,D,D}},
	{"get_page_setup",{P},P,0,GtkPageSetup},
	{"get_width",{P},D},
	{"get_height",{P},D},
	{"get_dpi_x",{P},D},
	{"get_dpi_y",{P},D},
	{"get_pango_fontmap",{P},P,0,PangoFontMap},
	{"create_pango_context",{P},P,0,PangoContext},
	{"create_pango_layout",{P},P,0,PangoLayout},
	{"get_hard_margins",{P,D,D,D,D},B},
"GtkPrintContext"})
 GtkPrintContext = length(widget)

widget = append(widget, {"gtk_print_unix_dialog",
{GtkDialog,GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{S,P},P},
	{"set_page_setup",{P,P}},
	{"get_page_setup",{P},P,0,GtkPageSetup},
	{"set_current_page",{P,I}},
	{"get_current_page",{P},I},
	{"set_settings",{P,P}},
	{"get_settings",{P},P,0,GtkPrintSettings},
	{"get_selected_printer",{P},P,0,GtkPrinter},
	{"add_custom_tab",{P,P,P}},
	{"set_support_selection",{P,B}},
	{"get_support_selection",{P},B},
	{"get_has_selection",{P},B},
	{"set_embed_page_setup",{P,B}},
	{"get_embed_page_setup",{P},B},
	{"set_manual_capabilities",{P,I}},
	{"get_manual_capabilities",{P},I},
"GtkPrintUnixDialog"})
 GtkPrintUnixDialog = length(widget)

widget = append(widget, {"gtk_page_setup_unix_dialog",
{GtkDialog,GtkWindow,GtkBin,GtkContainer,GtkWidget,GtkBuildable,GObject},
	{"new",{S,P},P},
	{"set_page_setup",{P,P}},
	{"get_page_setup",{P},P,0,GtkPageSetup},
	{"set_print_settings",{P,P}},
	{"get_print_settings",{P},P,0,GtkPrintSettings},
"GtkPageSetupUnixDialog"})
 GtkPageSetupUnixDialog = length(widget)

end procedure
 ----------------------------------------------------------------------

	function newPrintSettings(object x=0, object y=0)
	  atom err=allocate(8,1)
	  if atom(x) and x = 0 then
		return gtk_func("gtk_print_settings_new")
	  end if
	  if class_id(x) = GKeyFile then
		y = allocate_string(y,1)
		return gtk_func("gtk_print_settings_new_from_key_file",{P,P,P},{x,y,err})
	  end if
	  if string(x) and file_exists(canonical_path(x)) then
		x = allocate_string(canonical_path(x),1)
		return gtk_func("gtk_print_settings_new_from_file",{P,P},{x,err})
	  end if
	end function

	function ps_set_page_ranges(atom x, object r)
	  atom m = allocate_data(8)
	  poke(m,r[1])
	  poke(m+4,r[2])
	  gtk_proc("gtk_print_settings_set_pages_ranges",{P,P,I},{x,m,2})
	 return 1
	end function

    export function getPrintOpJobName(atom op)
	 object job = allocate(32,1), err = allocate(32,1) err = 0
	 gtk_func("g_object_get",{P,P,P,P},{op,"job name",job,err})
	 ifdef BITS64 then -- thanks Pete Eberlein;
		print_op_jobname = peek8u(job)
	 elsedef
		print_op_jobname = peek4u(job)
	 end ifdef
	 if print_op_jobname > 0 then
		print_op_jobname = peek_string(print_op_jobname)
	 end if
	 return print_op_jobname
	end function

	function ps_to_file(atom setup, object filename)
	 atom err = allocate(8,1) err = 0
	 return gtk_func("gtk_page_setup_to_file",{P,P,P},{setup,filename,err})
	end function

	function newPaperSize(object a=0, object b=0, atom c=0, atom d=0)
	  if string(a) and atom(b) and b = 0 and c = 0 and d = 0 then
		a = allocate_string(a,1)
		return gtk_func("gtk_paper_size_new",{P},{a})
	  end if
	  if string(a) and atom(b) and b > 0 and c > 0 then
		a = allocate_string(a,1)
		return gtk_func("gtk_paper_size_new_from_ipp",{P,D,D},{a,b,c})
	  end if
	  if string(a) and string(b) and c > 0 and d > 0 then
		a = allocate_string(a,1)
		b = allocate_string(b,1)
	  return gtk_func("gtk_paper_size_new_from_ppd",{P,P,D,D},{a,b,c,d})
	  end if
	end function

export function get_paper_sizes(integer cust=0)
   object ps = gtk_func("gtk_paper_size_get_paper_sizes",{P},{cust})
   ps = unpack_gs_atom_list(ps)
 return ps
end function

export function get_paper_size_names(integer cust=0)
   object ps = get_paper_sizes(cust)
   for i = 1 to length(ps) do
	ps[i] = gtk_str_func("gtk_paper_size_get_name",{P},{ps[i]})
   end for
 return ps
end function

-------------------------------------
-- copyright 2005-2019 by Irv Mullins
-------------------------------------

