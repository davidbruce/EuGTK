
-- Simple example program in Euphoria language to create a html
-- page with all the picture files in the current directory.

-- Marco Achury, 2008
-- Released to public domain.  Feel free to use and modify.

-- Updated for Eu 4.1b2 by Irv Mullins
-- Added EuGTK interface Mar 21, 2019

constant docs  = "Open a folder containing images and select files to add"

include GtkEngine.e
include GtkFileSelector.e
include std/filesys.e
include std/datetime.e
include std/net/url.e

integer FN -- File number for output
sequence input = sprintf("~/%s/*",{user_name}) -- default home
sequence output = canonical_path("~/output.html") -- default in home

constant
    win = create(GtkWindow,"title=Gallery Maker,size=300x200,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,docs),
    box = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-open","SelectFolder"),
    btn3 = create(GtkButton, "gtk-ok","ViewHTML")

    gtk:add(win,pan)
    gtk:add(pan,lbl)
    gtk:add(box,{btn1,btn2,btn3})
    pack_end(pan,box)

    show_all(win)
    main()

----------------------------------------------------------------------------------
global function SelectFolder()
----------------------------------------------------------------------------------
ifdef UNIX then fileselector:filters = {"images"} end ifdef
ifdef WINDOWS then fileselector:filters = {"all"} end ifdef
fileselector:preview_size = 400
fileselector:show_preview = TRUE
fileselector:select_multiple = TRUE
input = fileselector:Open()

GenerateHTML()

return 1
end function

----------------------------------------------------------------------------------
global function GenerateHTML()
----------------------------------------------------------------------------------
object fname, fdate, fpath = pathname(input[1])

object fpix, fsize

FN = open (output, "w")
if FN =-1 then Error(,,"Cannot open output file!")
    abort(1)
end if

puts (FN, "<HTML>\n")
puts (FN, " <HEAD>\n")
puts (FN, sprintf("  <TITLE>Images in %s</TITLE> ",{fpath}))

puts (FN, "<style>\n")
puts (FN, """
    
    body {background:#7A7A7A;}
    
    div.hint {
        display: block; 
        border: thin solid black; 
        padding: 8px; 
        font-size: small;
        border-radius: 20px; 
        margin-left: 20px; 
        margin-right: 20px; 
        background-color: #DACOCD;
	}

    div.quote {
        display: block;
        border: 1px solid black;
        padding: 15px;
        background: #D0D0D0;
        margin: 5px;}
        
    .boxshadow {
        -moz-box-shadow : #888888 4px 4px 6px;
        -webkit-box-shadow: $888888 4px 4px 6px;
        box-shadow: #888888 4px 4px 6px;
    filter: progid:DXImageTransform.Microsoft.Shadow (color='#888888', Direction=135, Strength=6);
} """)   
        
puts (FN, "</style>\n")

puts (FN, " </HEAD>\n\n")
puts (FN, "<BODY>\n")

puts (FN, "<div class='hint quote boxshadow'>\n")
puts (FN, "<big><b>Euphoria Image Gallery  </b></big>")
puts (FN, sprintf("<small>%d Files from %s in %s\n<br>\n<br></small>",{length(input),fpath,output}))
puts (FN, "</div>\n")

puts (FN, "<table border='0'\n")
puts (FN, "<tr>\n")

for i=1  to length(input) do

    fname = url:decode(input[i])
    fpix = create(GdkPixbuf,fname)
    fsize = get(fpix,"size")
    fdate = file_timestamp(fname)

    puts(FN,"<td width='25%'>\n")
    printf(FN,"<a href='%s'>\n",{fname})
	printf(FN,"<center><img src='%s'",{fname})
	puts(FN," height='250px'></a></center>\n")
    puts(FN,"<br clear='all' />")
    printf(FN,"<div class='quote hint boxshadow' width='%d' align='bottom'>\n",fsize[1])
    printf(FN,"<small><b>Path:</b> %s </small><br />\n",{fpath})
    printf(FN,"<small><b>Name:</b> %s </small><br />\n",{filename(fname)})

    puts(FN,text:format("<small><b>File&nbsp;Size:</b> [,,] bytes</small><br>\n",file_length(fname)))
    puts(FN,text:format("<small><b>Date:</b> []/[]/[] Time: []:[]:[]</small>\n</td>\n\n",fdate))

    if remainder(i,3)=0 then
    puts (FN, "</div></tr>\n\n<tr>\n")
    end if

end for
puts (FN, "</table>\n")

printf(FN, "<address><b>Page generated: %s</b>",{datetime:format(now())})
puts (FN, " by a Euphoria powered script.</address>")
puts (FN, "</BODY>\n</HTML>\n")
close(FN)

if Info(,,text:format("<b>Input folder:</b> []\n<b>Output file:</b> [] has <b>[]</b> images.",
        {fpath,output,length(input)}),,GTK_BUTTONS_OK_CANCEL) = MB_OK then
   show_uri("file://" & output)
end if
return 1
end function

-----------------------------
global function ViewHTML() -- when OK button clicked
-----------------------------
    show_uri("file://" & output)
return 1
end function

------------- END ------------

