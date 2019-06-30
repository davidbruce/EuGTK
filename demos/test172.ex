
--------------------------------------------------------------------------
--# Locale Monetary symbols
--------------------------------------------------------------------------

include GtkEngine.e
include std/locale.e

ifdef WINDOWS then
    Warn(,,"Windows has trouble with locale currency chars.")
end ifdef

constant docs = `<b><u>Locale</u></b>
This demonstrates how to add local currency symbols to
your display. I don't know if all these are correct.
Hey, it's just a demo!
<span color='red'>Broken on Windows</span>
`
constant text = allocate_string("text")

constant win = create(GtkWindow,"size=450x360,border=10,position=1,$destroy=Quit") 

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)

constant lbl = create(GtkLabel)
    gtk:set(lbl,"markup",docs)
    add(panel,lbl)
	
constant scroller = create(GtkScrolledWindow)
    pack(panel,scroller,TRUE,TRUE)

object data = {
    {"Geo. Washington","Wash. DC",17.76},
    {"Dikka Khan","Madras, India",4549.30,"en_IN"},
    {"Char Shu","Hong Kong",45.67,"en_HK.utf8"},
    {"Bridget Murphy","Shannon, Ireland",48.54,"en_IE.utf8"},
    {"Randy Kruger","Cape Town, South Africa",49.22,"en_ZA.utf8"},
    {"Reginald Parsley","London, England",22.75,"en_GB.utf8"},
    {"Jean le Bloop","Paris, France",123.45,"en_IE.utf8"},
    {"Alphie Packer","Donner, CA",-30.00},
$}
    
constant
    rend1 = create(GtkCellRendererText),
    col1 = create(GtkTreeViewColumn)
    gtk:set(col1,"pack start",rend1)
    gtk:set(col1,"add attribute",rend1,"text",1)

constant
    rend2 = create(GtkCellRendererText),
    col2 = create(GtkTreeViewColumn)
    gtk:set(col2,"pack start",rend2)
    gtk:set(col2,"add attribute",rend2,"text",2)

constant
    rend3 = create(GtkCellRendererText),
    col3 = create(GtkTreeViewColumn)
    gtk:set(col3,"pack start",rend3)
    gtk:set(col3,"add attribute",rend3,"text",3)
    gtk:set(rend3,"xalign",0.9) -- money looks better when right aligned;
    gtk:set(col3,"cell data func",rend3,_("Money"))
  
constant
    rend4 = create(GtkCellRendererText),
    col4 = create(GtkTreeViewColumn)
    gtk:set(col4,"pack start",rend4)
    gtk:set(col4,"add attribute",rend4,"text",4)
   

constant store = create(GtkListStore,{gSTR,gSTR,gSTR,gSTR})

constant view = create(GtkTreeView)
    gtk:set(view,"model",store)
    add(scroller,view)
    add(view,{col1,col2,col3})
    gtk:set(store,"data",data)
    
show_all(win)
main()

---------------------------------------------------------------
function Money(atom layout, atom rend, atom mdl, atom iter)
---------------------------------------------------------------
object val = gtk:get(mdl,"col data from iter",iter,3) -- amount;
object loc = gtk:get(mdl,"col data from iter",iter,4) -- specified locale;

if atom(loc) then -- no locale was specified, fallback to local;
    locale:set(getenv("LANG")) 
else 
    locale:set(loc)
end if

gtk:set(rend,"property","text",locale:money(to_number(val))) -- note: must use 'property'; 

return 1
end function

