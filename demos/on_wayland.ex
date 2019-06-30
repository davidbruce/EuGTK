
--# <span color='blue'>USAGE:</span> $> eui on_wayland test0 <span color='red'>(run in terminal)</span>

-- This starts the wayland server, runs eu program test0.ex, 
-- and opens a firefox window with test0 running in it.
-- Replace test0 with the EuGTK program of your choice,
-- e.g. eui on_wayland WEE-master/wee.ex

-- Note: wayland server may not be installed with your distro.

include GtkEngine.e
uses("weston")

object cmd = command_line()

if length(cmd) < 3 then
 display("USAGE:\n\t$ eui on_wayland test0.ex")
 abort(1)
end if

if system_exec("which weston") != 0 then 
	display("ERROR: No wayland (weston) server found!\n******\n")
	abort(2) 
end if

system("killall weston")
system("weston --fullscreen &",0) 
system(sprintf("GDK_BACKEND=wayland %s %s &",{cmd[1],cmd[3]}),0)


