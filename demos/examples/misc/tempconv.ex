include GtkEngine.e

constant
    win = create(GtkWindow,"title=TempConv;border=10,$destroy=Quit"),
    box = create(GtkBox,"spacing=5"),
    c  = create(GtkEntry,"$activate=Update"),
    l1 = create(GtkLabel,"Celsius"),
    f  = create(GtkEntry,"$activate=Update"),
    l2 = create(GtkLabel,"Fahrenheit")

    add(win,box)
    pack(box,{c,l1,f,l2})
    
show_all(win)
main()

global function Update(atom ctl)
atom val = get(ctl,"value") 
switch ctl do
    case c then set(f,"text",(val*1.8)+32)
    case else set(c,"text",(val-32)*5/9)
end switch
return 1
end function
