
--------------------------------------------------------------------------
--# GtkExpander, widget data field (key/value pairs)
--------------------------------------------------------------------------
-- You delare various named variables and attach them to the control,
-- then access them later by name. All names and data MUST be strings.

-- This particular demo makes using these much more complicated that it 
-- needs to be, because I am 'encrypting' the answers,
-- and displaying them in a drop-down GtkExpander.

-- For an easier introduction to the use of data fields, please look at 
-- Passing Data in /documentation/HowItWorks.html and test18.ex
--------------------------------------------------------------------------

include GtkEngine.e 
include std/base64.e

include resources/mongoose.e -- for oeu_logo as pixbuf
include resources/clown.e -- for clown pixbuf (pixbufs are re-usable, unlike images)

constant docs = `
Widgets have a <b><u>Data</u></b> space
which you can use to declare and pass 
key/value pairs
`
constant -- answers encrypted to avoid spilling the beans;
 
q1 = "What is purple and conquered the world?",
a1 = "PGk+QWxleGFuZGVyIHRoZSBHcmFwZSE8L2k+",

q2 = "What lies at the bottom of the ocean and twitches?",
a2 = "PGk+QSBuZXJ2b3VzIHdyZWNrLjwvaT4=",

q3 = "Why is Christmas just like another day at the office?",
a3 = "WW91IGRvIGFsbCBvZiB0aGUgd29yayBhbmQgdGhlIGZhdCBndXkKaW4gdGhlIHN1aXQgZ2V0cyBhbGwgdGhlIGNyZWRpdC4="

constant Q = call_back(routine_id("Question")), -- allow for compiling w/o error
    win = create(GtkWindow,"title=`Data Passing`,border_width=10,position=1,icon=oeu_logo,$destroy=Quit"),
    panel = create(GtkBox,"orientation=vertical,spacing=10"),
    box = create(GtkButtonBox,"spacing=5"),
    lbl = create(GtkLabel,"markup=Widgets have a <b><u>Data</u></b> space\n" &
	"which you can use to declare and pass k/v pairs")

constant btn1 = add(box,create(GtkButton,"dialog-question#Question _1",Q))
    set(btn1,{
	{"tooltip text","World History"},
	{"data","question",q1},
	{"data","answer",a1}})

constant btn2 = add(box,create(GtkButton,"dialog-question#Question _2",Q))
    set(btn2,{
	{"tooltip text","Science"},
	{"data","question",q2},
	{"data","answer",a2}})

constant btn3 = add(box,create(GtkButton,"dialog-question#Question _3",Q))
    set(btn3,{
	{"tooltip text","Business"},
	{"data","question",q3},
	{"data","answer",a3}})

    add(win,panel)
    add(panel,lbl)
    pack_end(panel,box)
	
show_all(win)
main()

-----------------------------------------------------
function Question(atom ctl)
-----------------------------------------------------
object title = get(ctl,"tooltip text") 
object question = get(ctl,"data","question")
object ans = get(ctl,"data","answer")

ans = base64:decode(ans)

atom closebtn = create(GtkButton,"gtk-close")
    show(closebtn)
    
atom dlg = create(GtkDialog,{ -- we make our own custom dialog;
    {"title",title},
    {"icon",oeu_logo},
    {"border width",10},
    {"transient for",win},
    {"position",GTK_WIN_POS_MOUSE},
    {"add action widget",closebtn,MB_OK}})

atom ca = get(dlg,"content area")

atom lbl1 = add(ca,create(GtkLabel,{
    {"font","Comic Sans MS, Century Schoolbook L, URW Chancery L, Bold 12"},
    {"markup",question},
    {"show",1}}))
  
atom exp = add(ca,create(GtkExpander,"Click here for the answer:"))
    set(exp,{
	{"font","10"},
	{"color","blue"},
	{"background","skyblue"},
	{"resize toplevel",TRUE},
	{"show",1}})
	
atom box = create(GtkBox,VERTICAL)
  add(exp,box)
    
atom lbl2 = add(box,create(GtkLabel,{
    {"font","Segoe Print Normal, Purisa 24"},
    {"color","blue"},
    {"markup",ans}}))

atom img = create(GtkImage,clown)
    add(box,img)
    show_all(box)
   
run(dlg)
destroy(img) -- small memory leak if not destroyed.
destroy(dlg)

return 1
end function

