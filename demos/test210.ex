
------------------------------------------------------------------------
--# generates a sample text string in the designated language
------------------------------------------------------------------------

include GtkEngine.e
include GtkCairo.e
include std/localeconv.e

constant docs = `<u><b>Languages</b></u>
Enter a language code in the entry box,
and click 'OK', or select one below:
`
constant cb = _("SelectLanguage"), -- link to function;
	win = create(GtkWindow,"border=10,$destroy=Quit"),
	panel = create(GtkBox,"orientation=vertical"),
	lbl = create(GtkLabel),
	box = create(GtkBox,"orientation=vertical,margin-bottom=10"),
	inp = create(GtkEntry,"text=en_US,activates default=TRUE"),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-about","About"),
	btn3 = create(GtkButton,"gtk-ok","DisplayLanguage"),
	btnbox = create(GtkButtonBox,"margin-top=10")

sequence flags = {"united_states","mexico","denmark","south_africa",
	"egypt","india","czech_republic","united_kingdom","finland",
	"greece","russia","republic_of_china","japan"}
	
sequence op = {0}
	op &= create(GtkRadioButton,0,"English/USA",cb,"en_US")
	op &= create(GtkRadioButton,op,"Spanish/Mexico",cb,"es_MX")
	op &= create(GtkRadioButton,op,"Danish/Denmark",cb,"de_DK")
	op &= create(GtkRadioButton,op,"Afrikaans/SA",cb,"af_ZA")
	op &= create(GtkRadioButton,op,"Arabic/Egypt",cb,"ar_EG")	
	op &= create(GtkRadioButton,op,"Bengali/India",cb,"bn_IN")
	op &= create(GtkRadioButton,op,"Czech",cb,"cs_CZ")
	op &= create(GtkRadioButton,op,"Welsh/GB",cb,"cy_GB")
	op &= create(GtkRadioButton,op,"Finnish/Finland",cb,"fi_FI")
	op &= create(GtkRadioButton,op,"Greek/Greece",cb,"el_GR")
	op &= create(GtkRadioButton,op,"Russian/Russia",cb,"ru_RU")
	op &= create(GtkRadioButton,op,"Chinese/Peoples Republic of China",cb,"zh_CN")
	op &= create(GtkRadioButton,op,"Japan",cb,"ja_JP")
	
	op = op[2..$]
	add(box,op)

	add(win,panel)
	add(panel,{lbl,box,inp})
	pack_end(panel,btnbox)
	add(btnbox,{btn1,btn2,btn3})
	set(btn3,"can default",TRUE)
	set(win,"default",btn3)
	set(lbl,"markup",docs)

show_all(win)
main()

-------------------------------------------------------
global function SelectLanguage(atom ctl, object lang)
-------------------------------------------------------  
if get(ctl,"active") then  
	lang = unpack(lang)
	set(inp,"text",lang)
return DisplayLanguage(ctl,get(ctl,"label"))
else return 0
end if
end function

---------------------------------------------------------
global function DisplayLanguage(atom ctl, object name) --
---------------------------------------------------------
atom x = create(PangoLanguage,get(inp,"text"))
object lang = get(x,"to string")
object text = get(x,"sample string")
x = find(ctl,op)
object flag = 0
if x > 0 then 
	flag = sprintf("~/demos/resources/flags/flags-%s.png",{flags[x]})
else
	name = lang
end if
set(lbl,"selectable",TRUE)
set(lbl,"text","\n" & text)
return Info(win,lang,name,text,,flag)
end function

--------------------------
global function About() --
--------------------------
sequence txt = `

Get a string that is representative of the characters 
needed to render a particular language.

The sample text may be a pangram, but is not necessarily. 
It is chosen to be demonstrative of normal text in the language, 
as well as exposing font feature requirements unique to the language. 
It is suitable for use as sample text in a font selection dialog.

If Pango does not have a sample string for language , the classic 
"The quick brown fox..." is returned.

(For fun, try copying some of the phrases and pasting into Google
translate.)
`
return Info(win,"About","pango_language_get_sample_string",txt)
end function
