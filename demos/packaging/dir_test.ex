#! /usr/bin/eui

with define BUILDER

include GtkEngine.e

  if not equal(prog_dir,curr_dir) then 
     chdir(prog_dir) 
  end if

add(builder,"dir_test.glade")

set("label1","markup","<b>Terminal</b> " & os_term)
set("label2","markup","<b>Prog dir:</b> " & prog_dir)
set("label3","markup","<b>Curr dir:</b> " & curr_dir)
set("window1","icon","thumbnails/colors.png")

main()
