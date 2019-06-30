
----------------------------------------------------------------------------------
--# GtkTextView 'rich text' format 
----------------------------------------------------------------------------------
-- There seems to be little need for this sort of widget, since it's easy to use 
-- html to create basic 'styled' text in a universally understood format,
-- and tools such as LibreOffice are much better for creating more complex 
-- documents. Also, GtkSourceView widget offers automatic color-coding for 
-- most programming languages with no effort at all.
----------------------------------------------------------------------------------
 
include GtkEngine.e
include GtkPrinter.e
include std/wildcard.e
include std/io.e
include euphoria/keywords.e
   
object txt = read_file(locate_file("BEAR.ex"))

constant fontlist =  {"Courier","Arial","Sans","Serif","URW Chancery L","Purisa"}
object current_font = "Courier 12"
object range = 0

constant docs = `
<b><u>TextView</u></b> for viewing/editing 'rich text'. Does not <i><u>print</u></i> styled text.

`
-- create two special toolbuttons;
constant tux = create(GdkPixbuf,"thumbnails/BabyTux.png",20,20)
constant img1 = create(GtkImage,tux)

constant clown = create(GdkPixbuf,"thumbnails/clown.png",20,20)
constant img2 = create(GtkImage,clown)

constant win = create(GtkWindow,
    "size=300x500,border_width=10,position=1,icon_name=gtk-edit,$destroy=Quit")

constant panel = create(GtkBox,VERTICAL)
    add(win,panel)

constant lbl = create(GtkLabel)
    set(lbl,"markup",docs)
    pack(panel,lbl)

constant scrolwin = create(GtkScrolledWindow)
    pack(panel,scrolwin,1,1)

constant scroller = create(GtkViewport)
    add(scrolwin,scroller)

constant tv = create(GtkTextView,{
    {"wrap mode",GTK_WRAP_WORD_CHAR},
    {"font",current_font},
    {"left margin",10},
    {"right margin",10},
    {"border window size",GTK_TEXT_WINDOW_TOP,10},
    {"border window size",GTK_TEXT_WINDOW_BOTTOM,10},
    {"connect","button-release-event",_("SaveSelection")}})
    add(scroller,tv)

constant buffer = get(tv,"buffer") 
    set(buffer,"text",txt)
 
constant tag_tbl = get(buffer,"tag table") 

-- add a few generic tags that most any editing program would likely use;

constant tag_strike = create(GtkTextTag,"strike")
    set(tag_strike,"strikethrough=TRUE") 
    add(tag_tbl,tag_strike)

constant tag_ul = create(GtkTextTag,"underline")
    set(tag_ul,"underline=TRUE")
    add(tag_tbl,tag_ul)

constant tag_bold = create(GtkTextTag,"bold")
    set(tag_bold,"weight",PANGO_WEIGHT_BOLD)
    add(tag_tbl,tag_bold)

constant tag_ital = create(GtkTextTag,"italic")
    set(tag_ital,"style",PANGO_STYLE_ITALIC)
    add(tag_tbl,tag_ital)

constant tag_bi = create(GtkTextTag,"builtin")
    set(tag_bi,"foreground","green")
    set(tag_bi,"weight",PANGO_WEIGHT_BOLD)
    add(tag_tbl,tag_bi)

constant tag_kw = create(GtkTextTag,"keyword")
    set(tag_kw,"foreground","blue")
    set(tag_kw,"weight",PANGO_WEIGHT_BOLD)
    add(tag_tbl,tag_kw)
    
constant tag_gtk = create(GtkTextTag,"gtk")
    set(tag_gtk,"foreground","tomato")
    set(tag_gtk,"weight",PANGO_WEIGHT_BOLD)
    add(tag_tbl,tag_gtk)
 
constant tag_widget = create(GtkTextTag,"widget")
    set(tag_widget,"style",PANGO_STYLE_ITALIC)
    set(tag_widget,"weight",PANGO_WEIGHT_BOLD)
    add(tag_tbl,tag_widget)
    
constant tag_str = create(GtkTextTag,"string")
    set(tag_str,"foreground=lightgreen,background=black")
    add(tag_tbl,tag_str)
    
constant tag_dlg = create(GtkTextTag,"dialog")
    set(tag_dlg,"foreground=yellow,background=black,underline=TRUE")
    set(tag_dlg,"weight",PANGO_WEIGHT_BOLD)
    add(tag_tbl,tag_dlg)
    
constant tag_comment = create(GtkTextTag,"comment")
    set(tag_comment,"foreground=red")
    set(tag_comment,"weight",PANGO_WEIGHT_BOLD)
    add(tag_tbl,tag_comment)
     
atom 
    getiter = define_proc("gtk_text_buffer_get_iter_at_offset",{P,P,I}),
    mrk = define_func("gtk_text_mark_new",{S,B},P),
    amrk = define_proc("gtk_text_buffer_add_mark",{P,P,P}),
    fwdsrch = define_func("gtk_text_iter_forward_search",{P,S,I,P,P,P},B),
    fwdct = define_func("gtk_text_iter_forward_chars",{P,I},B),
    fwdline = define_func("gtk_text_iter_forward_line",{P},B),
    startsword = define_func("gtk_text_iter_starts_word",{P},B),
    offset = define_func("gtk_text_iter_get_offset",{P},I),
    getchar = define_func("gtk_text_iter_get_char",{P},P)

object widgetnames = {"GtkEngine.e","GtkPrinter.e","GtkFileSelector.e","GtkFontSelector.e"}
for i = 1 to length(widget) do
    if not atom(widget[i]) then widgetnames = append(widgetnames,widget[i][$]) end if
end for 

Remark()

global function Remark()
    markup(buffer,builtins,tag_bi)
    markup(buffer,{"create","set","get","add","connect","pack","show","show_all","main"},tag_gtk)
    markup(buffer,{"Info","Warn","Question","Error"},tag_dlg)
    markup(buffer,widgetnames,tag_widget)
    markup(buffer,{"--"},tag_comment)
    markup(buffer,keywords,tag_kw)
    markup(buffer,{"constant","boolean"},tag_dlg)
    return 1
end function

procedure markup(atom buffer,object words,object tag)
-- apply some basic eu keyword formatting;

atom a = allocate(128,1), b = allocate(128,1), c = allocate(128,1)
atom iter = allocate(128,1) 
atom werd
atom mk
integer firstchar, nextchar
integer comment = FALSE

for n = 1 to length(words) do
    
    comment = equal("--",words[n])
  
    werd = allocate_string(words[n])
  
    c_proc(getiter,{buffer,iter,0})

        while c_func(fwdsrch,{iter,werd,0,a,b,0}) = 1 do
            firstchar = c_func(getchar,{a})
            nextchar = c_func(getchar,{b})
                mk = c_func(mrk,{0,0})
                c_proc(amrk,{buffer,mk,a})
                iter = b
                c = b
              
            if comment then 
                c_func(fwdline,{c})
            else
                c_func(fwdct,{c,0})
            end if
            
            if comment then set(buffer,"apply tag",tag,a,c)
            end if
            
            if find(nextchar," {}()[].,/\n") 
            and c_func(startsword,{a}) then
                set(buffer,"apply tag",tag,a,c)
            end if

        end while
        
end for  
     
end procedure

constant btnbox1 = create(GtkButtonBox,{
    {"layout",GTK_BUTTONBOX_CENTER},
    {"homogeneous",FALSE}})
    pack(panel,btnbox1)

constant btn = {
  create(GtkToolButton,img2,"Clown"),
  create(GtkToolButton,"gtk-cut",0,"DeleteText"),
  create(GtkToolButton,"gtk-print",0,"PrintSelectedText"),
  create(GtkFontButton,current_font,"SelectFont"),
  create(GtkColorButton,"red","SelectColor"),
  create(GtkToolButton,"gtk-strikethrough",0,"ApplyTag",tag_strike),
  create(GtkToolButton,"gtk-underline",0,"ApplyTag",tag_ul),
  create(GtkToolButton,"gtk-bold",0,"ApplyTag",tag_bold),
  create(GtkToolButton,"gtk-italic",0,"ApplyTag",tag_ital),
  create(GtkToolButton,"gtk-clear",0,"RemoveTags"),
  create(GtkToolButton,img1,"Tux") 
  }
    
 set(btn[1],"tooltip text","Insert a Clown at the cursor")
 set(btn[2],"tooltip text","Delete selected text")
 set(btn[3],"tooltip text","Print selected text")
 set(btn[4],"use font",TRUE)
 set(btn[4],"filter func",_("FontFilter"))
 set(btn[4],"tooltip markup","Change <span font='Courier bold'>font</span> for selected text")
 set(btn[5],"tooltip markup","Change selected text <span color='red'>color</span>")
 set(btn[6],"tooltip markup","<s>Strikethrough</s> selected text")
 set(btn[7],"tooltip markup","<u>Underline</u> selected text")
 set(btn[8],"tooltip markup","<b>Boldface</b> selected text")
 set(btn[9],"tooltip markup","<i>Italicize</i> selected text")     
 set(btn[10],"tooltip markup","Remove <i>all</i> tags for selected text")
 set(btn[11],"tooltip text","Insert a Tux at the cursor")
 
 connect(btn[1],"clicked","InsertImage",clown)
 connect(btn[11],"clicked","InsertImage",tux)
 
 add(btnbox1,btn)

connect(buffer,"changed","Remark")

show_all(win)
main()

------------------------------------------------------------------------
global function SaveSelection()
------------------------------------------------------------------------
    range = get(buffer,"selection bounds")
return 0
end function 

------------------------------------------------------------------------
global function ApplyTag(atom ctl, atom data)
------------------------------------------------------------------------
if sequence(range) then
    set(buffer,"apply tag",data,range[1],range[2])
end if
return 1
end function

------------------------------------------------------------------------
global function RemoveTags(atom ctl)
------------------------------------------------------------------------
if sequence(range) then
    set(buffer,"remove all tags",range[1],range[2])
end if
return 1
end function

------------------------------------------------------------------------
global function FontFilter(atom family, atom face, atom data)
------------------------------------------------------------------------
object name = gtk_str_func("pango_font_family_get_name",{P},{family})
return find(name,fontlist)
end function

------------------------------------------------------------------------
global function ApplyFont()
------------------------------------------------------------------------
if sequence(range) then
atom anon = create(GtkTextTag) 
    set(tag_tbl,"add",anon)
    set(anon,"font",current_font) 
    set(buffer,"apply tag",anon,range[1],range[2])
end if
range = 0
return 1
end function 

------------------------------------------------------------------------
global function SelectFont(atom ctl)
------------------------------------------------------------------------
    current_font = get(ctl,"font name") 
    ApplyFont()
return 1
end function

------------------------------------------------------------------------
global function SelectColor(atom ctl)
------------------------------------------------------------------------
if sequence(range) then
    object color = get(ctl,"rgba") 
    atom anon = create(GtkTextTag)
    set(tag_tbl,"add",anon)
    set(anon,"foreground",color)
    ApplyTag(buffer,anon)
end if
return 1
end function

------------------------------------------------------------------------
global function InsertImage(atom ctl, atom img)
------------------------------------------------------------------------
if sequence(range) then
    set(buffer,"insert pixbuf",range[1],img)
end if
return 1
end function

------------------------------------------------------------------------
global function DeleteText()
------------------------------------------------------------------------
if sequence(range) then 
    set(buffer,"delete",range[1],range[2])
end if
return 1
end function

------------------------------------------------------------------------
global function PrintSelectedText()
------------------------------------------------------------------------
object text = ""

if sequence(range) and range[1]!=range[2] then 
    printer:sourcecode = FALSE
    printer:use_line_numbers = FALSE
    text = get(buffer,"slice",range[1],range[2])
    printer:PrintText("Selected text",text)
else 
    text = get(buffer,"text")
    if length(text) > 0 then
	printer:PrintText("Test59 Buffer",text)
    end if
end if

return 1
end function



