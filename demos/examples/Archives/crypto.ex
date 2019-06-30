
--------------------------------------------------------------------------
--# <b>Ricardo Forno</b>'s crypto routines with added GUI
--------------------------------------------------------------------------
--  uses Ricardo Forno's crypto routines from the RDS archives
--  please read his notes in crypto.e before running!

----------------------------
-- Added EuGTK GUI by
-- Irv Mullins Mar 14, 2018
-----------------------------

include GtkEngine.e
include GtkAboutDialog.e
include GtkFileSelector.e

include _crypto.e -- by Ricardo Forno [ricardoforno@tutopia.com] (modified)

constant aboutdlg = about:Dialog -- load and customize;
set(aboutdlg,"authors",{"Ricardo Forno (crypto code)","Irv Mullins (GUI)","*"})
set(aboutdlg,"version","Version 1.00")
set(aboutdlg,"add button","Help",99)
set(aboutdlg,"comments","Simple xor encryption by Ricardo Forno")
set(aboutdlg,"add credit section","Uses",
    {"crypto.e by Ricardo Forno [ricardoforno@tutopia.com]",
     "Click the Help button to see his help file"})
     
object input_file, output_file
object params = {0,0,0}

constant
    win = create(GtkWindow,"title=Crypto,border=10,$destroy=Quit"),
    pan = create(GtkBox,"orientation=VERTICAL,spacing=10"),
    grid = create(GtkGrid,"margin-left=20"),
    f1 = create(GtkEntry,"placeholder text=File to encrypt"),
    inp1 = create(GtkButton,"Open",_("OpenFile"),1),
    f2 = create(GtkEntry,"placeholder text=Save encrypted file"),
    inp2 = create(GtkButton,"Save",_("OpenFile"),2),
    inp3 = create(GtkEntry,"placeholder text=Encryption Key"),
    btnbox = create(GtkButtonBox),
    btn1 = create(GtkButton,"gtk-quit","Quit"),
    btn2 = create(GtkButton,"gtk-about",_("About")),
    btn3 = create(GtkButton,"gtk-ok",_("Activate"))

set(inp1,"tooltip text","Chose file to be encrypted")
set(inp2,"tooltip text","Enter name of new encrypted file")
set(inp3,"tooltip text","Enter a key phrase you can remember!")

add(win,pan)
add(pan,grid)
set(grid,"attach",f1,1,1,2,1)
set(grid,"attach",inp1,3,1,1,1)
set(grid,"attach",f2,1,2,2,1)
set(grid,"attach",inp2,3,2,1,1)
add(pan,inp3)
pack_end(pan,btnbox)
add(btnbox,{btn1,btn2,btn3})
set(btn1,"grab focus")
    
show_all(win)
main()

-------------------
function Activate()
-------------------
params = {get(f1,"text"),get(f2,"text"),get(inp3,"text")}
integer l1, l2
if length(params[1]) < 1 or file_exists(params[1]) = 0 then
    Warn(,,"Invalid filename","Please select a file to encrypt!")
    return 1
end if
if length(params[2]) < 1 then
    Warn(,,"Missing filename","Please enter a new name to save encrypted data")
    return 1
end if
if length(params[3]) < 1 then 
    Warn(,,"Missing key","Please enter an encription key string!") 
    return 1
end if
if length(params[1])
and length(params[2])
and length(params[3]) then crypto(params) -- do it!
end if
if file_exists(output_file) then 
    l1 = file_length(input_file)
    l2 = file_length(output_file) 
    if l1=l2 then
    Info(win,"Success",
        text:format("Output file: []",{output_file}),
        text:format("[] bytes read\n[] bytes written",
          {file_length(input_file),file_length(output_file)}))
    else
        Error(win,,"Error!","Cannot encrypt/save file.")
    end if
end if
return 1
end function

-------------------
function About()
-------------------

if run(aboutdlg) = 99 then ShowHelp() end if
hide(aboutdlg)
return 1
end function

---------------------
function ShowHelp()
---------------------
Info(win,"Help - Crypto.e",
"""
 Program to encrypt / decrypt files by means of a simple xor_bits method
 Author: R. M. Forno - Contact him at ricardoforno@tutopia.com
 Version 0.1 - 2006/12/30
 
""",
"""
 Usage is the same for both encrypting and decrypting.
 The key string should be the same for both tasks
 If the key string contains spaces, please use " to enclose it

 Modified to work with EuGTK and Eu 4.1
 Mar 10, 2018
 Irv Mullins
""")
return 1
end function

--------------------------------------------
function OpenFile(atom ctl, integer which)
--------------------------------------------
switch which do
    case 1 then 
        fileselector:filters = {"images","text","all"}
        input_file = fileselector:Open()
        set(f1,"text",input_file)
    case 2 then
        fileselector:filters = {"all"}
        output_file = fileselector:SaveAs()
        set(f2,"text",output_file)
end switch
return 1
end function


