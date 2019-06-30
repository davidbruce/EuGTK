
----------------------------------------------------------------------------
--# GtkScaleButton displaying variable icons depending upon value
----------------------------------------------------------------------------

include GtkEngine.e
include std/math.e

constant docs = `
    <b><u>GtkScaleButton</u></b>

    A slider control with icons 
    which can vary depending upon 
    the value of the control's 
    current setting. 
    Icons are chosen
    from a list you supply.
        
    Click on the button on the right =>
    to pop up a slider.
`
constant icon_list = {
    "weather-clear",    
    "weather-few-clouds", 
    "weather-overcast", 
    "weather-showers-scattered",
    "weather-showers",
    "weather-storm",
    "weather-severe-alert"
}

constant win = create(GtkWindow,
    "size=300x200,border_width=10,position=1,$destroy=Quit")

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)

constant top = create(GtkBox,HORIZONTAL)
    add(panel,top)
    
constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    add(top,lbl)

constant 
    ib = create(GtkInfoBar), 
    ca = get(ib,"content area"),
    img = create(GtkImage), txt = create(GtkLabel)
    add(ca,{img,txt})
    pack(panel,ib)
    
constant btn = create(GtkScaleButton,GTK_ICON_SIZE_DND,1,7,.1)
-- must re-order icons here, because GTK expects highest-value icon
-- to be second on list, lowest value to be first. More weirdness.
    set(btn,"icons",extract(icon_list,{1,7,2,3,4,5,6}))
    set(btn,"relief",1)
    add(top,btn)
    connect(btn,"value-changed",_("Update"))
    Update(btn)
	
show_all(win)
main()

------------------------------------------------------------------------
function Update(atom ctl)
------------------------------------------------------------------------
atom val = get(ctl,"value") 
    printf(1,"%d\n",val)
    val = floor(val) 
    set(img,"from icon name",icon_list[val],6)
    set(txt,"markup",icon_list[val])
return 0
end function

