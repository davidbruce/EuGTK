
---------------------------------------------------------------------
--# <b>EuGTK Info</b> display all sorts of system info
---------------------------------------------------------------------
-- Displays a lot of data gathered by EuGTK about the platform.
-- Don't be concerned that this looks complex. Go on to test1, etc.
-- to see how easy EuGTK can be!
---------------------------------------------------------------------

include GtkEngine.e

----------------------------------------------------
-- Interface:
-- This uses std/format to allow [{named}]
-- parameters. This makes it easy to move things
-- around, add or delete items. Labels use markup
-- to style the text.
----------------------------------------------------

constant fmt1 = -- stuff for left side;

`<b><u>EuGTK</u></b> <small> 
  <b>Version:</b> [{version}]
  <b>Date:</b> [{release}]
  [{copyright}]</small>

<b><u>GTK</u></b><small>
  <b>Lib version:</b> [{lib_version}]</small>
  
<b><u>Euphoria</u></b><small>
  <b>Version:</b> [{eu_version}]
  <b>Revision:</b> [{eu_revision}]
  <b>Platform:</b> [{eu_platform}]
  <b>Bits:</b> [{eu_arch_bits}]
  <b>Date:</b> [{eu_date}]
  <b>EUINC:</b> [{eu_inc}]
  <b>EUDIR:</b> [{eu_dir}]</small>
 
<b><u>User</u></b><small>
  <b>User name:</b> [{user_name}]
  <b>Full name:</b> [{real_name}]
  <b>Home Dir:</b> [{home_dir}]
  <b>Terminal:</b> [{os_term}]
  <b>Shell:</b> [{os_shell}]
  <b>Locale:</b> [{locale}]
  <b>Language:</b> [{usr_lang}]
  </small>
  `
constant fmt2 = -- stuff for right side;
`<b><u>Platform</u></b><small>
  <b>OS:</b> [{os_name}]
  <b>Distro:</b> [{os_distro}]
  <b>Version:</b> [{os_vers}]
  <b>Architecture</b> [{os_arch}]</small>
 
<b><u>Application</u></b><small>
  <b>Prog name:</b> [{prg_name}]
  <b>Process ID:</b> [{os_pid}]
  <b>Prog Dir:</b> [{prog_dir}]
  <b>Init Dir:</b> [{init_dir}]
  <b>Curr Dir:</b> [{curr_dir}]
  <b>Temp Dir:</b> [{temp_dir}]
  <b>Data Dir:</b> [{data_dir}]
  <b>Config Dir:</b> [{conf_dir}]
</small>  
<b><u>Other</u></b><small>
  <b>Host Name:</b> [{host_name}]     
  <b>Host Addr:</b> [{host_addr}]
  <b>Codeset:</b> [{codeset}]
  <b>Desktop:</b> [{desktop}]
  <b>Documents:</b>[{documents}]
  <b>CMD1:</b> [{CMD1}]
  <b>CMD2:</b> [{CMD2}]
  <b>CMD3:</b> [{CMD3}]
</small>
`
-------------------------------------------------------------------------
-- Main Window 
-------------------------------------------------------------------------

constant 
  win = create(GtkWindow,"size=250x-1,border=5,position=1,$destroy=Quit"),
  grid = create(GtkGrid),
  img = create(GtkImage,"thumbnails/eugtk.png"),
  lbl_left = create(GtkLabel),
  lbl_right = create(GtkLabel),
  box = create(GtkButtonBox),
  btn = create(GtkButton,"gtk-quit","Quit")
  
  set(lbl_left,"markup",format(fmt1,info)) 
  set(lbl_right,"markup",format(fmt2,info)) 
  set(grid,"attach",img,1,1,2,1)
  set(grid,"attach",lbl_left,1,2,1,1) 
  set(grid,"attach",lbl_right,2,2,1,1) 
  set(grid,"attach",box,1,4,2,1) 

  add(win,grid)
  add(box,btn)

show_all(win) 
main()
