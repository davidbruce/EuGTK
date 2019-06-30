-- gneui.ex 1.0 
-- 
-- 2013 2013-03-21 
--# by Kenneth Rhodes wolfmanjacques@gmail.com>
-- 
-- This file wraps the Euphoria interpreter 
-- together with a routine which extracts 
-- ex.err file data and passes the name, 
-- path, line and column to the Geany editor 
-- 
-- usage: Geany run_cmd = eui gneui.ex ./%f 
-- Set run source code command to this as well, 
-- Execute your code from Geany; upon error, 
-- Geany will position the cursor at the line 
-- and column of the error. 

--* Heavily modified by Irv Mullins 
--* to try to handle signal 11 errors from GTK

include std/io.e 
include std/convert.e 
include std/error.e 
include std/filesys.e 
include std/console.e
include std/sequence.e

object file_name, command, err
integer exit_code = 0

sequence cl = command_line() 
system("clear",0)

if length(cl) >= 3 then 

    file_name = cl[3] 
    command = sprintf( "eui -D DEBUG \"%s\"", {file_name} ) 
    printf(1,
`-----------------------------------------------------------------------
/// Running %s with gneui 
------------------------------------------------------------------------
`,{file_name})
    
    -- look for old ex.err in current directory;
    err = canonical_path(file_name)
    err = pathname(err) & "/" & "ex.err"
    
    if  file_exists(err) then 
        delete_file(err) -- remove old ex.err if it exists;
    end if 
        
    exit_code = system_exec ( command, 0 ) -- call eui with debugging;
    if exit_code != 0 then -- on error
        ParseErrorFile() 
    end if 
    
end if 

--------------------------
procedure ParseErrorFile() 
--------------------------
object file_lines
object temp_line
object err_line
integer err_col = 0, i = 0

    if not file_exists("ex.err") then
        abort(exit_code) -- can't fine ex.err!
    end if
    
    file_lines = read_lines(err)
    if atom(file_lines) then  -- ex.err was empty
        crash("Cannot find ex.err!\n") 
    end if

    object x = split(file_lines[1])

    for n = 1 to length(file_lines) do
        if match("^^^ call-back from external source",file_lines[n]) = 1 then
            file_lines = file_lines[1..n-1] -- get rid of non-useful part of ex.err listing;
            exit
        end if
    end for
 
    -- trap & process GTK signal 11 errors;
        for n = length(file_lines) to 2 by -1 do
        -- start at end of ex.err, to find last (topmost) error line #;
            if match("... called from /", file_lines[n]) then 
                i = find(':', file_lines[n]) 
                file_name = file_lines[n][17..i-1]
                err_line = file_lines[n][i+1..$]
                i = find(' ',err_line)
                err_line = err_line[1..i-1]
                err_line = to_number(err_line)
             -- display the file and line #, then call geany to edit it;
                printf(1,"\nFile:%s - LINE:%d \n",{file_name,err_line})
                system( sprintf("geany \"%s:%d\"", {file_name,err_line} )) 
                abort(exit_code)
            end if
        end for

    -- trap & process euphoria error report;
        for n = 1 to length(file_lines) do
        -- start at top of ex.err, to find first syntax error;
            if find('^', file_lines[n]) then
                i = find(':',file_lines[1])
                err_col = match("^",file_lines[n])-1
                file_name = file_lines[1][1..i-1]
                err_line = to_number(file_lines[1][i+1..$])
             -- display the file and line #, then call geany to edit it;
                printf(1,"\nFILE:%s - LINE:%d COL:%d\n",{file_name,err_line,err_col})
                system( sprintf("geany \"%s:%d:%d\" & ", {file_name, err_line, err_col} )) 
                abort(exit_code)
            end if 
        end for

end procedure 
