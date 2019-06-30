
--# <span color='blue'>USAGE:</span> $> eui on_broadway test0.ex <span color='red'>(run in terminal)</span> 

-- Run a EuGTK program in a web browser!
-- This starts the broadway server, runs eu program specified, 
-- and opens a firefox window with the program running in it.
-- e.g. eui on_broadway BEAR.ex [port]

constant BROWSER = "firefox"
integer PORT = 8085

include GtkEngine.e

uses("broadwayd")

object cmd = command_line()

if length(cmd) < 3 then
 puts(1,"USAGE:\n\t$ eui on_broadway test0.ex [8080]\n")
 abort(1)
end if

if system_exec("which broadwayd") != 0 then 
	display("ERROR: No broadway server found!\n******\n")
	abort(1) 
end if

if length(cmd) = 4 then
  PORT = to_number(cmd[4]) 
end if

system("killall broadwayd")
system(sprintf("broadwayd --port=%d &",PORT))
system(sprintf("GDK_BACKEND=broadway %s %s &",{cmd[1],cmd[3]}),0)
system(sprintf("%s http://localhost:%d",{BROWSER,PORT}),0)



