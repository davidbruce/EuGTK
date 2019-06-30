
------------------------------------------------------------------------
--# Talk, requires <b>spd-say</b> 
------------------------------------------------------------------------

include GtkEngine.e
include GtkCairo.e

uses("spd-say")

object lang = "en", speaker = "male1", speed = 0, pitch = 0

constant win = create(GtkWindow,{
	{"border width",10},
	{"default size",550,300},
	{"position",GTK_WIN_POS_CENTER}})
	connect(win,"destroy","Quit")

constant panel = create(GtkBox,VERTICAL)
	add(win,panel)

constant input = create(GtkEntry)
	set(input,"text","The quick brown fox jumps over the lazy dog.")
	set(input,"tooltip text","Enter some text here to hear it spoken")
	add(panel,input)

	add(panel,create(GtkLabel,"- Languages - "))

constant box1 = create(GtkButtonBox),
	a1 = create(GtkRadioButton,0,"English",_("SelectLanguage"),1),
	a2 = create(GtkRadioButton,a1,"French",_("SelectLanguage"),2),
	a3 = create(GtkRadioButton,a2,"Spanish",_("SelectLanguage"),8),
	a4 = create(GtkRadioButton,a3,"German",_("SelectLanguage"),12),
	a5 = create(GtkRadioButton,a4,"Italian",_("SelectLanguage"),9)
	add(box1,{a1,a2,a3,a4,a5})
	add(panel,box1)

constant languages = {"en","fr","ru","af","sr","fi","pt","es","it","ur",
	"ko","de","is","ms","sk","sv","tr","pl","hi","oc","nn","fa","mk","ka"}
	
constant language = create(GtkComboBoxText)
	for i = 1 to length(languages) do
		set(language,"append text",languages[i])
	end for
	set(language,"active",1)
	set(language,"tooltip text","Drop down list of available languages/phrases")
	connect(language,"changed",_("SelectLanguage"))
	add(panel,language)

	add(panel,create(GtkSeparator))
	add(panel,create(GtkLabel,"- Voices -"))

constant box3 = create(GtkButtonBox), 
	box4 = create(GtkButtonBox), 
	box5 = create(GtkButtonBox),
	m1 = create(GtkRadioButton,0,"Male 1",_("Voice"),"male1"),
	m2 = create(GtkRadioButton,m1,"Male 2",_("Voice"),"male2"),
	m3 = create(GtkRadioButton,m2,"Male 3",_("Voice"),"male3"),
	f1 = create(GtkRadioButton,m3,"Female 1",_("Voice"),"female1"),
	f2 = create(GtkRadioButton,f1,"Female 2",_("Voice"),"female2"),
	f3 = create(GtkRadioButton,f2,"Female 3",_("Voice"),"female3"),
	c1 = create(GtkRadioButton,f3,"Male Child",_("Voice"),"child_male"),
	c2 = create(GtkRadioButton,c1,"Female Child",_("Voice"),"child_female")
	set(box3,"homogeneous",TRUE)
	set(box4,"homogeneous",TRUE)
	add(box3,{m1,m2,m3})
	add(box4,{f1,f2,f3})
	add(box5,{c1,c2})
	add(panel,{box3,box4,box5})
	
	add(panel,create(GtkSeparator))

constant lbl1 = create(GtkLabel,"- Speed -")
	add(panel,lbl1)
	
constant Speed = create(GtkScale,HORIZONTAL,-100,50,1)
	set(Speed,"value",-50)
	connect(Speed,"value-changed",_("SetSpeed"))
	add(panel,Speed)
	
constant lbl2 = create(GtkLabel,"- Pitch -")
	add(panel,lbl2)
	
constant Pitch = create(GtkScale,HORIZONTAL,-100,50,1)
	set(Pitch,"value",-50)
	connect(Pitch,"value-changed",_("SetPitch"))
	add(panel,Pitch)
	
constant box6 = create(GtkButtonBox),
	btn1 = create(GtkButton,"gtk-quit","Quit"),
	btn2 = create(GtkButton,"gtk-ok","Say")
	add(box6,{btn1,btn2})
	pack(panel,-box6)

show_all(win)

main()

----------------------------------------
function Voice(atom ctl, atom v)
----------------------------------------
	if get(ctl,"active") then speaker = unpack(v) 
		display(speaker)
	end if
return 1
end function

--------------------------------------------
function SelectLanguage(atom ctl, object l)
--------------------------------------------
	if ctl = language then
		l = get(ctl,"active")
	else
		set(language,"active",l)
	end if

	atom x = create(PangoLanguage,languages[l])
	object ls = get(x,"to string")
	object txt = get(x,"sample string")
	set(input,"text",txt)
return 1
end function

-----------------------------------
function SetSpeed(atom ctl)
-----------------------------------
	speed = get(ctl,"value")
return 1
end function

-----------------------------------
function SetPitch(atom ctl)
-----------------------------------
	pitch = get(ctl,"value")
return 1
end function

---------------------
global function Say()
---------------------
object txt = get(input,"text")
	system(sprintf(`spd-say -w -mnone -r%d -p%d -l%s -t%s "%s"`,
		{speed,pitch,lang,speaker,txt}),0)
return 1
end function
