include GtkEngine.e 
 
constant --[1] create the widgets; 
     
    win = create(GtkWindow,"border width=10,$destroy=Quit"), 
    pan = create(GtkBox,"orientation=vertical"),  
    box = create(GtkButtonBox), 
    btn = create(GtkButton,"gtk-quit", "Quit"), 
    lbl = create(GtkLabel,"color=blue") 
 
    --[2] style the label; 

    set(lbl,"markup", -- style the text using basic html; 
    "<span color='red' font='24'>こんにちは世界</span>\n(Kon'nichiwa sekai)\n\n" & 
    "これは、ラベルと終了ボタンを持つ単純なウィンドウをデモします。\n") 
 
    --[3] add widgets to containers; 
     
    add(win,pan) 
    add(pan,lbl) 
    add(box,btn) 
    pack(pan,-box) 
  
show_all(win) --[4] instantiate widgets; 
main()        --[5] enter main processing loop; 



