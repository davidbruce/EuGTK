
--# Flightgear Control

-- Purpose:
-- Provide an easy-to use interface to flightgear

-- Version 1.0 (c)2019 by Irv Mullins

include GtkEngine.e
include GtkSettings.e
include std/io.e

constant
    ini = ".flightgear.ini",
    disp = create(GdkDisplay),
    scrn = get(disp,"default screen"),
    win = create(GtkWindow,"name=main,title=FlightGear,size=600x500,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=vertical,spacing=5"),
    top = create(GtkBox,"orientation=horizontal,spacing=10"),
    left = create(GtkBox,"orientation=vertical"),
    mid = create(GtkBox,"orientation=vertical,spacing=10,margin top=5"),
    L0 = create(GtkLabel,"Callsign"),
    L1 = create(GtkLabel,"Airport"),
    L2 = create(GtkLabel,"Runway"),
    L3 = create(GtkLabel,"COM1"),
    L4 = create(GtkLabel,"NAV1"),
    L5 = create(GtkLabel,"ADF"),
    L6 = create(GtkLabel,"COM2"),
    L7 = create(GtkLabel,"COM2"),
    L8 = create(GtkLabel,"DME"),
    L9 = create(GtkLabel,"VOR"),
    L10 = create(GtkLabel,"VOR Freq"),
    L11 = create(GtkLabel,"ILS LOC"),
    L12 = create(GtkLabel,"Time of day"),
    right = create(GtkBox,"orientation=vertical"),
    tv1 = create(GtkTreeView),
    scr = create(GtkScrolledWindow),
    sto = create(GtkListStore,{gSTR,gSTR}),
    col1 = create(GtkColumn,"title=Name,type=text,text=1,sort=1"),
    col2 = create(GtkColumn,"title=Description,type=text,text=2,sort=2"),
    sel = get(tv1,"selection"),
    box1 = create(GtkButtonBox),  
    callsign = create(GtkEntry,"name=callsign,text=N4JYZ"), 
    apt = create(GtkEntry,"name=airport,text=KATL"),
    rwy = create(GtkEntry,"name=runway,text=26L"),
    com1 = create(GtkEntry,"name=com1,text=119.65"),
    nav1 = create(GtkEntry,"name=nav1,text=116.90"),
    adf1 = create(GtkEntry,"name=adf,text=415"),
    com2 = create(GtkEntry,"name=com2,text=125.55"),
    nav2 = create(GtkEntry,"name=nav2,text=118.0"),
    dme1 = create(GtkEntry,"name=dme,text=116.9"),
    vorid = create(GtkEntry,"name=VORID,text=ATL"),
    vorf = create(GtkEntry,"name=vor-frequency,text=116.9"),
    ils = create(GtkEntry,"name=ils-frequency,text=109.9"),
    tod = create(GtkComboBoxText,"name=timeofday"), 
    box2 = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-ok","Run")

constant times = {"clock","dawn","morning","noon","afternoon","dusk","Evening","midnight"}
    add(tod,times)
    set(tod,"active",1)
    
    set(tv1,"model",sto)
    set(left,"width-request",300)
    add(win,pan)
    pack(pan,top,1,1)
    pack(top,{left,mid,right},1,1)
    pack(left,scr,1,1)
    add(scr,tv1)
    add(tv1,{col1,col2})
    add(mid,{L0,L1,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12})
    add(right,{callsign,apt,rwy,com1,nav1,adf1,com2,nav2,dme1,vorid,vorf,ils,tod})
    pack_end(top,box1)
    add(box2,{btn1,btn2})
    pack_end(pan,box2)
    
    -- obtain currently installed aircraft;
    system_exec("fgfs --show-aircraft > fgaircraft") 
    object acdata = read_lines("fgaircraft")
    acdata = acdata[2..$]
    for i = 1 to length(acdata) do
        acdata[i] = {trim(acdata[i][1..25]),trim(acdata[i][25..$])}    
    end for
    set(sto,"data",acdata) -- put into aircraft list;
    
show_all(win)
settings:Load(ini)
main()
    
------------------------
global function Run() --
------------------------
object craft = get(sel,"selected row data") craft = craft[1]
object geometry = sprintf("%dx%d",{get(scrn,"width"),get(scrn,"height")})

object command = 
  format("fgfs --aircraft=[] --airport=[] --runway=[] --callsign=[] "
    &"--com1=[] --nav1=[] --adf=[] --com2=[] --nav2=[] --dme=[] "
    &"--timeofday=[] --geometry=[] "
    &"--httpd=8080 --disable-real-weather-fetch --disable-terrasync --disable-fgcom "
    &"--enable-ai-traffic --enable-auto-coordination --enable-fullscreen "
    &"--disable-hud-3d --enable-clouds3d --log-level=none \n",
    {craft, 
     get(apt,"text"),
     get(rwy,"text"),
     get(callsign,"text"),
     get(com1,"text"),
     get(nav1,"text"),
     get(adf1,"text"),
     get(com2,"text"),
     get(nav2,"text"),
     get(dme1,"text"),
     get(tod,"text"),
     geometry,
     $})
     
display(split(command," "))

system_exec(command)

settings:Save(ini,{win,callsign,apt,rwy,com1,nav1,com2,nav2,adf1,dme1,tod})

return 1
end function


    
    
