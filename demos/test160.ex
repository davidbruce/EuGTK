
------------------------------------------------------------------------
--# OS Info -  uses in-line css
------------------------------------------------------------------------

include GtkEngine.e
include std/os.e

enum KERNEL,HOSTNAME,RELEASE,VERSION,MACHINE
    
ifdef WINDOWS then 
constant image = "thumbnails/bug-buddy.png"
elsedef
constant image = "emblem-system"
end ifdef

constant os = uname()
constant fmt = `
  <b>OS</b> = []
  <b>Kernel</b> = []
  <b>Version</b> = []
  <b>Process id</b> = []
  <small><i>using inline css for text styling</i></small>`

constant 
    css = create(GtkCssProvider,"GtkLabel {text-shadow: 4px 3px #101010;}"),
    win = create(GtkWindow,
	"title=`OS Info`,border=15,background=blue,icon=emblem-system,$destroy=Quit"),
    pan = create(GtkBox,"orientation=HORIZONTAL"),
    img = create(GtkImage,image,128),
    lbl = create(GtkLabel,"color=white,font=14")

    set(lbl,"markup",text:format(fmt,{os[KERNEL],os[MACHINE],os[VERSION],get_pid()}))

    add(win,pan)
    add(pan,{img,lbl})

show_all(win)
main()
