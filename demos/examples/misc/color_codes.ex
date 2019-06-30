
---------------------------------------------------------------------------
--# Resistor color codes;
-- Note: some GTK themes have a bug which adds space around images,
-- so the resistor image may appear to be 'sliced up'.
-- This can be fixed by using css to set image padding to 0.
---------------------------------------------------------------------------

include GtkEngine.e
include std/locale.e
include std/convert.e

object resistor -- an array of images

object valdisp = create(GtkLabel)

constant colors1 = { -- color bands;
    "Black","Brown","Red","Orange","Yellow",
    "Green","Blue","Violet","Gray","White"
    },
 -- multipliers;
 colors2 = colors1 & {"Silver","Gold"},
 
 -- tolerance;
 colors3 = {"Gold","Silver","None"},
 
 -- formatting string for value display;
 tolerance = {" +/- 5%"," +/- 10%"," +/- 20%"},
 
 -- location of the color band images;
 wp = canonical_path("~/demos/resources/colorcode/")

constant tens = create(GtkComboBoxText)
    for i = 2 to length(colors1) do
        gtk:set(tens,"append text",colors1[i])
    end for

constant ones = create(GtkComboBoxText)
    for i = 1 to length(colors1) do
        gtk:set(ones,"append text",colors1[i])
    end for

constant mult = create(GtkComboBoxText)
    for i = 1 to length(colors2) do
        gtk:set(mult,"append text",colors2[i])
    end for

constant tol = create(GtkComboBoxText)
    for i = 1 to length(colors3) do
        gtk:set(tol,"append text",colors3[i])
    end for
    gtk:set(tol,"active",1)

constant update = call_back(routine_id("Update"))

    connect(tens,"changed",update)
    connect(ones,"changed",update)
    connect(mult,"changed",update)
    connect(tol,"changed",update)

constant win = create(GtkWindow,{
    {"title","Resistor Color Codes"},
    {"position",GTK_WIN_POS_CENTER},
    {"border width",10},
    {"resizable",FALSE},
    {"icon","~/demos/thumbnails/mongoose.png"},
    {"connect","destroy","Quit"}})

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)

-- this creates a composite image of a resistor;
resistor = repeat(0,5)
    resistor[1] = create(GtkImage,wp & "leftend.jpg")
    resistor[2] = create(GtkImage,wp & "bar.jpg")
    resistor[3] = create(GtkImage,wp & "bar.jpg")
    resistor[4] = create(GtkImage,wp & "bar.jpg")
    resistor[5] = create(GtkImage,wp & "end1.jpg")

constant top = create(GtkBox)
    add(panel,top)
    add(top,resistor)
    
constant bot = create(GtkBox)
    add(panel,bot)
    pack(bot,{tens,ones,mult,tol})

constant css = create(GtkCssProvider,"GtkImage {padding:0;}")

valdisp = create(GtkEntry)
    add(panel,valdisp)

show_all(win)
main()

-----------------------------------------------------------
function Format(integer t, integer o, integer m, integer p)
-----------------------------------------------------------
-- a utility to correctly format the value displayed;
object vs
atom v = 0
object prec = "", fmt = "[1] [2] [3]  ([4] ~ [5] [2])"

integer i
object min_v, max_v, var, suffix

     vs = sprintf("%d%d",{t,o}) 

     if m < 1 then
        v = to_number(vs) 
     end if

     if m > 0 and m < 10 then
        vs &= repeat('0',m)
        v = to_number(vs)/10 
     end if

     if m = 11 then --silver
       v = to_number(vs)
       v = v / 100
     end if
     
     if m = 12 then --gold
       v = to_number(vs)
       v =  v / 10
     end if
     
    if p > -1 then
     prec = tolerance[p]
     switch p do
      case 3 then var = v * 0.20 
      case 2 then var = v * 0.10 
      case 1 then var = v * 0.05 
      end switch
     min_v = v - var
     max_v = v + var
    end if

    if v >= 1e6 then
       return format(fmt,{v/1e6,"Meg Ω",prec,number(min_v/1e6),number(max_v/1e6)})
       
    elsif v >= 1000 then
      return format(fmt,{v/1000,"K Ω",prec,number(min_v/1000),number(max_v/1000)})
       
    else
      return format(fmt,{v,"Ω",prec,number(min_v),number(max_v)})
       
    end if
     
end function

--------------------------------------------------
function Update() -- called when values chg
--------------------------------------------------
integer t,o,m,p

-- get selections from combo boxes,
    t = gtk:get(tens,"active") 
    o = gtk:get(ones,"active") -1
    m = gtk:get(mult,"active") 
    p = gtk:get(tol,"active")

-- set resistor color bands to match entered values;
    if t > 0 then
     gtk:set(resistor[2],"from file",sprintf(wp & "bar%d.jpg",t))
    end if

    if o >= 0 then
     gtk:set(resistor[3],"from file",sprintf(wp & "bar%d.jpg",o))
    end if

    if m > 0 then
     gtk:set(resistor[4],"from file",sprintf(wp & "bar%d.jpg",m-1))
    end if

    if p > 0 then
     gtk:set(resistor[5],"from file",sprintf(wp & "end%d.jpg",p))
    end if

-- display value in text form;
    if t >= 0 and o >= 0 and m >= 0 then
     gtk:set(valdisp,"text",Format(t,o,m,p))
    end if

return 0
end function
