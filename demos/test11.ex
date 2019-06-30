
-----------------------------------------------------------------------------------
--# Label justification 
-- justifies lines within multi-line labels, not single line labels.
-----------------------------------------------------------------------------------

include GtkEngine.e

constant justify = _("Justify"), -- create a link to local function below;
  win = create(GtkWindow,"title=Justification,border=10,size=400x300,position=1,$destroy=Quit"),
  panel = add(win,create(GtkBox,VERTICAL)),
  lbl = add(panel,create(GtkLabel,{{"markup",Twain()}})), -- Markup Twain?
  box = pack_end(panel,create(GtkButtonBox)),
  btn1 = add(box,create(GtkButton,"gtk-justify-left",justify,GTK_JUSTIFY_LEFT)),
  btn2 = add(box,create(GtkButton,"gtk-justify-center",justify,GTK_JUSTIFY_CENTER)),
  btn3 = add(box,create(GtkButton,"gtk-justify-right",justify,GTK_JUSTIFY_RIGHT)),
  btn4 = add(box,create(GtkButton,"gtk-quit","Quit"))
  
show_all(win)
main()

------------------------------------------------
function Justify(atom ctl, atom j) 
------------------------------------------------
    set(lbl,"justify",j)
return 1
end function

------------------------
function Twain() -- a function so quoted text can be at end of program;
------------------------
return remove_all("\n\n",
"""<b>In the space</b> of one hundred and seventy-six years the 
Mississippi has shortened itself two hundred and forty-two miles.
 
<b>Therefore</b> ... in the Old Silurian Period the Mississippi River 
was upward of one million three hundred thousand miles long ... 
 
<b>Seven hundred and forty-two years</b> from now the Mississippi 
will be only a mile and three-quarters long. ... 
 
<b>There is something fascinating about science.</b>
One gets such wholesome returns of conjecture out of such a 
trifling investment of fact.

 -- <b><i>Mark Twain</i></b> 
""")
end function

