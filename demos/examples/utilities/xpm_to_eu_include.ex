
--------------------------------------------------------------
--# Utility converts xpm image file to euphoria sequence
-- which is then converted and exported as a GdkPixbuf in
-- an include ... file.
--------------------------------------------------------------

include GtkEngine.e
include std/io.e

integer n 
object inputfile, outputfile
object xpm_name
object work = {"include GtkEngine.e\n"}

constant win = create(GtkWindow,"title=XPM to .e,border=10,size=200x200,position=1,sig.destroy=Quit")

constant panel = create(GtkBox,"orientation=VERTICAL,spacing=10")
    add(win,panel)

constant lbl1 = create(GtkLabel,"Enter name of xpm file")
    add(panel,lbl1)

constant fcb = create(GtkFileChooserButton,{
    {"title","Select a file"},
    {"action",GTK_FILE_CHOOSER_ACTION_OPEN},	
    {"current folder",canonical_path("~/demos/thumbnails")},
    {"tooltip text","Click to open a file chooser dialog"},
    {"signal","file-set","show_output_name"}})
    add(panel,fcb)

constant filter = create(GtkFileFilter,{{"add pattern","*.xpm"}})
    set(fcb,"filter",filter)

constant lbl2 = create(GtkLabel,"Output .e file or leave blank")
    add(panel,lbl2)

constant out = create(GtkEntry)
    add(panel,out)

constant img = create(GtkImage)
    add(panel,img)

constant box = create(GtkButtonBox)
    pack_end(panel,box)

    add(box,create(GtkButton,"gtk-quit","Quit"))
    add(box,create(GtkButton,"gtk-ok","xpm_convert"))

show_all(win)
main()

---------------------------------------------------------
function ProcessXPM(object line, integer ln, object data)
---------------------------------------------------------
integer i

    if ln = 1 then -- retain name in comment;
        i = match("/*",line)
        if i > 0  then
            line = line[i..$]
        end if
    end if
    
    if ln = 2 then -- convert to eu constant declaration;
	i = match("static char *",line) 
	if i > 0 then
	    xpm_name = line[i+14..$]
	    line = line[1..i-1] & "constant " & xpm_name
	end if
	i = match("[]",line) -- remove the brackets;
	if i > 0  then
	    line = line[1..i-1] & line[i+2..$]
	end if
    end if
    
	line = transmute(line,{{},'\t'},{' '}) -- convert tabs to spaces;
	work = append(work,line)
	
return 0
end function

---------------------------------------------
global function show_output_name(object ctl)
---------------------------------------------
    set(out,"text",filebase(get(ctl,"filename")) & ".e")
return 1
end function

-----------------------------------------------------
global function xpm_convert()
-----------------------------------------------------

    inputfile = get(fcb,"filename")
    if not file_exists(inputfile) then
	Error(,,inputfile,"does not exist",GTK_BUTTONS_CANCEL)
	return 0
    end if

    set(img,"from file",inputfile) -- preview;

    outputfile = get(out,"text")
    if length(outputfile) = 0 then
	outputfile = filebase(inputfile) & ".e"
	set(out,"text",outputfile)
    end if

    process_lines(inputfile,routine_id("ProcessXPM"))
    integer x = length(work)

    xpm_name = split(xpm_name,"[") xpm_name = xpm_name[1]

    work[$] = work[$][1..$-1] -- get rid of trailing semi-colon;
    
    object n = filebase(get(out,"text"))
    work = prepend(work,
    sprintf(
`namespace %s

-- exports %s:icon as a GdkPixbuf
`,
	{filebase(outputfile),n,n}))
	
    work = append(work,"------------------------------------------------------------------------------")
    work = append(work,sprintf("export constant icon = xpm_to_pixbuf(%s)",{xpm_name}))
    work = append(work,"------------------------------------------------------------------------------")
    
    write_lines(outputfile,work)

    Info(,,
	sprintf("include %s",{get(out,"text")}),
	sprintf("reference with namespace:\n\t<b>%s:icon</b>",{filebase(get(out,"text"))}))

return 1
end function








