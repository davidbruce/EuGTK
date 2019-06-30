
------------------------------------------------------------------------
--# Password generator, requires <b>apg</b>
------------------------------------------------------------------------

include GtkEngine.e
include std/io.e

uses("apg")

constant docs = `markup=
<u><b>Password Generator</b></u>
Generates random passwords with pronunciation.
Hit the Generate <small>(alt-G)</small> button to generate a new list.`

constant 
    win = create(GtkWindow,"size=200x100,border=10,icon=thumbnails/passred.png,$destroy=Quit"), 
    pan = create(GtkBox,"orientation=vertical,spacing=10"),
    lbl = create(GtkLabel,docs),
    bkg = create(GtkEventBox,"border=10,background=black"),
    list = create(GtkLabel,"color=#18F424"),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"stock_repeat#_Generate","GeneratePW"),
    box = create(GtkButtonBox)

    set(btn2,"tooltip text","Click to generate six new passwords")

    add(win,pan)
    add(pan,{bkg,lbl})
    add(bkg,list)
    add(box,{btn1,btn2})
    pack(pan,-box)
    
show_all(win)

GeneratePW() -- create some before showing window;

main()

------------------------------
global function GeneratePW() -- call apg, format and display results;
------------------------------
system("apg > pw.list -a 0 -M Ncl -t",0) -- see apg --help for these params;
object results = read_lines("pw.list")
object words = "<span color='lightgreen'>  <b><u>Password</u></b> </span><span color='yellow'> <b><u> Pronunciation</u></b> \n\n</span>"
    for i = 1 to length(results) do
        words &= format("  <b>[1]</b>   <span color='yellow'>[2]</span>  \n",split(results[i],' '))
    end for
    set(list,"markup",words)
    set(list,"selectable",TRUE)
    delete_file("pw.list")
return 1
end function
  

