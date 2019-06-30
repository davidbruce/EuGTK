
--# lc.ex - count non-blank lines of code <span color='red'>(run in terminal!)</span>
-- USAGE: eui lc test0

include std/io.e
include std/console.e
integer ct = 0 
object cmd = command_line()
object file = cmd[3]
object lines = read_lines(file)
for i = 1 to length(lines)  do
    ct += length(lines[i])>0
end for
display("[] contains [] total lines, [] with content",{file,length(lines),ct})
