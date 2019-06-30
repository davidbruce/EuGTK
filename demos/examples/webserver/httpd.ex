--=======================================================================--
--# Modified <b>RDS's</b> httpd.ex <span color='red'>(terminal mode program!)</span>
---------------------------------------------------------------------------
-- Httpd.ex can be run stand-alone started from a command line: %>eui httpd
-- If needed parameters aren't supplied, a usage message will be printed.
-- It can also be called from an Eu program using system_exec() 
-- with parameters and flags included in the command line.
--=======================================================================--

--This library is free software; you can redistribute it 
--and/or modify it under the terms of the GNU Lesser General 
--Public License as published by the Free Software Foundation;
--either version 2 of the License, or (at your option) any later 
--version. 

--This library is distributed in the hope that it will be useful, 
--but WITHOUT ANY WARRANTY; without even the implied warranty of 
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
--See the GNU Lesser General Public License for more details. 

--You should have received a copy of the GNU Lesser General Public 
--License along with this library; if not, write to the Free Software 
--Foundation, Inc., 59 Temple Pl, Suite 330, Boston, MA  02111-1307 USA

include std/socket.e as sock
include std/text.e
include std/types.e
include std/sort.e
include std/convert.e
include std/sequence.e
include std/io.e
include std/os.e
include std/math.e
include std/net/url.e
include std/console.e
include std/filesys.e
include std/datetime.e
include std/map.e as m

-----------------------------------------------------------------------    
-- END STYLING
-----------------------------------------------------------------------
    
object server_log = 0, show_hidden = 0, sort_listing = 0, show_request = 0
object bind_addr = "127.0.0.1:8080"
object doc_root = "."
object image_width = "600px"

m:map mime_types = m:new()

sequence typs = { -- you may need to add additional types here;
    { "htm",  "text/html" },
    { "html", "text/html" },
    { "css",  "text/css" },
    { "png",  "image/png" },
    { "jpg",  "image/jpeg" },
    { "jpeg", "image/jpeg" },
    { "gif",  "image/gif" },
    { "bmp",  "image/bmp" },
    { "png",  "image/png" },
    { "svg",  "image/svg+xml" },
    { "xpm",  "image/x-xpixmap"},
    { "wma",  "audio/x-ms-wma"},
    { "wav",  "audio/x-wave"},
    { "ogg",  "audio/x-vorbis+ogg"},
    { "mov",  "video/quicktime"},
    { "vob",  "video/mpeg"},
    { "mp3",  "audio/mpeg"},
    { "mp4",  "video/mp4"},
    { "mpeg", "video/mpeg"},
    { "mpg",  "video/mpeg"},
    { "pdf",  "application/pdf"},
    { "zip",  "application/zip"},
    $
}

for i = 1 to length(typs) do
    m:put(mime_types, typs[i][1], typs[i][2])
end for

constant RESPONSE_STRING = """
HTTP/1.0 %d
Content-Type: %s
Connection: close
Content-length: %d


"""

constant ERROR_404 = """
<html>
<head><title>404 Not Found</title></head>
<body>
<h1>404 Not Found</h1>
<h3>Sorry!</h3>
<p>
%s was not found on this server.
</p>
</body>
</html>
"""
------------------------------------------------------------------------
function SortDirectoriesFirst(object a, object b)
------------------------------------------------------------------------
return compare(b[2],a[2])
end function
atom directories_first = routine_id("SortDirectoriesFirst")

------------------------------------------------------------------------
function SortIgnoreCase(object a, object b)
------------------------------------------------------------------------
return compare(upper(a),upper(b))
end function
atom ignore_case = routine_id("SortIgnoreCase")


-- Styled objects;
constant style_header = """<tr class="hdr"><th class="hdr" colspan="4">%s</th></tr>"""
constant style_listing = """<td class="list"><a href='%s'><button class="list">%s</button></a></td>"""
constant style_directory = """<td class="dir"><a href='%s/'><button class="dir">%s</button></a></td>"""
constant style_html = """<td class="html"><a href='%s'><button class="html">%s</button></a></td>"""

------------------------------------------------------------------------
function create_index(sequence path) -- builds an html index on-the-fly 
------------------------------------------------------------------------
sequence data = sprintf("""
<!DOCTYPE html>
<html>
<head>
    <title>Eu Server</title>
    <style type = "text/css">
        button {width: 100%%;}
        button.dir {background-color: skyblue;}
        button.html {background-color: orange;}
        body {background-image: linear-gradient(180deg, yellow, blue); background-repeat: no-repeat;)
    </style>
    <link rel="stylesheet" type="text/css" href="%s.httpd.css" />
</head>
<body>
""",{path})

object files = dir(path), name, tmp

integer ct = 1

    if atom(files) then return 0 end if
    
    if sort_listing then 
        files = custom_sort(ignore_case,files) 
        files = custom_sort(directories_first,files)
    end if

    data &= "\n<table>\n"
    
    data &= sprintf(style_header,{path})
        
    for i = 1 to length(files) do
    
        name = files[i][D_NAME]
        
        if show_hidden = 0 then
            if name[1] = '.' then continue end if
        end if
        
        if find('d', files[i][D_ATTRIBUTES]) then
            data &= sprintf(style_directory,{name,name})
            data &= "\n\t"
        else        
            tmp = name
            tmp = split(tmp,'.') 
                if length(tmp) > 1 then
                    tmp = tmp[1]
                else
                    tmp = name
                end if
            -- try to deal with accented chars : ò, for example, in song titles
            for n = 1 to length(tmp) do
                if tmp[n] = 195 then
                    tmp = tmp[1..n-1] & sprintf("&#%d;",{tmp[n+1]+64}) & tmp[n+2..$]
                end if
            end for
            if match("htm",lower(fileext(name))) then
                data &= sprintf(style_html,{url:encode(name),name})
            else
                data &= sprintf(style_listing, {url:encode(name),name})
            end if
            data &= "\n\t"
        end if
        
        if remainder(ct,4)=0 then
            data &= "</tr>\n<tr>"
        end if
        ct += 1
        
    end for

    data &= "</table>\n</body></html>"
    
    return data
    
end function

------------------------------------------------------------------------------------
procedure handle_request(sock:socket server, sequence client, sequence doc_root=".")
------------------------------------------------------------------------------------
sock:socket client_sock = client[1]
sequence client_addr = client[2]
object command,path,content_type,fileinfo,data
object request = sock:receive(client_sock,0)
object req_time = datetime:format(datetime:now_gmt(),"%Y/%m/%d %H:%M:%S ")
integer fn, fo, len, fsize, result_code
object fname=0, t1 = 0, t2 = 0

    if atom(request) then
        return 
    else
        request = split(request,"\r\n")
        if show_request then 
            if string(server_log) then
                append_lines(server_log,request)
            else
                display(request)
            end if
        end if
    end if

    if length(request) >= 1 then
        command = request[1]
    end if
    
    if length(request) >= 2 then
        path = request[2] 
    end if
    
    t1 = split(command,' ') 
    t1 = url:decode(t1[2])

object a = split(doc_root,'/') 
object b = split(t1,'/')
object c = {}

for i = 1 to length(b) do
if i > length(a) then
    c = b[i..$]
    exit
end if

if equal(a[i],b[i]) then
else
    c = b[i..$]
    exit
end if
end for

fname = join(a,'/')  & '/' & join(c,'/')
if not file_exists(fname) then
        fname = join(a[1..$-1],'/') &  '/' & join(c,'/')
end if

-- for logging;
    fsize = file_length(fname)
  
    if string(server_log) then
        append_lines(server_log,
            {text:format("[] [] [] []",{req_time,client_addr,fname,fsize})})
    else
        display("[] [] [] []",{req_time,client_addr,fname,fsize})
    end if
    
-- we need to handle directories and files differently;
       
    switch file_type(fname) do
    
        case 0 then
            result_code = 404
            content_type = "text/html"
            data = sprintf(ERROR_404,{filename(fname)})
                            
            sock:send(client_sock, sprintf(RESPONSE_STRING, {
                result_code, content_type, length(data)}), 0)
            sock:send(client_sock, data, 0)
        
        case 1 then
            data = read_file(fname)
            content_type = m:get(mime_types,lower(fileext(fname)),"text/plain")
            result_code = 200
            
            if not equal("ex",fileext(fname)) then 
                sock:send(client_sock, sprintf(RESPONSE_STRING, {
                result_code, content_type, length(data)}), 0)
            end if
            
            sock:send(client_sock, data, 0)

        
        case 2 then
            data = create_index(fname)
            content_type = "text/html"
            result_code = 200
                            
            sock:send(client_sock, sprintf(RESPONSE_STRING, {
                result_code, content_type, length(data)}), 0)
            sock:send(client_sock, data, 0)
            
    end switch

    
end procedure

------------------------------------------------------------------------
function server()
------------------------------------------------------------------------
sequence args = command_line(), starttime

if length(args) < 3 then
    show_usage()  
end if
       
integer n_tries = 20

integer i = 3
    while i < length(args) do
        switch args[i] do
            case "-h" then show_hidden = 1
            case "-s" then sort_listing = 1
            case "-r" then show_request = 1
            case "-t" then n_tries = to_number(args[i+1])
            case "-bind" then bind_addr = args[i+1] i += 1
            case "-root" then doc_root = args[i+1] i += 1
            case "-log" then server_log = args[i+1] i += 1
  
            case else -- fail on invalid option;
                printf(1,"Unknown option: %s\n",{args[i]})
                show_usage()
                abort(1)
                
        end switch
        i += 1      
    end while
    
integer ct = 1
label "retry"
    
    chdir(doc_root)
    
    sock:socket server = sock:create(sock:AF_INET, sock:SOCK_STREAM, 0)
    
    if sock:bind(server,bind_addr) != sock:OK then -- retry a few times;
        printf(1,"Could not bind %s, error=%d try=%d\n", 
            {bind_addr, sock:error_code(),ct})
        sleep(2)
        ct += 1
        if ct >= n_tries then -- fail after too many tries;
            printf(1,"Failed to bind []\n",{bind_addr}) 
            if string(server_log) then
                append_lines(server_log,
                  {sprintf("Failed to bind %s\n",{bind_addr}),
                   sprintf("Tried %d times",ct)})
            end if
            abort(ct)
        end if
        goto "retry"
    end if
    
    starttime = datetime:format(datetime:now_gmt(),"%Y/%m/%d %H:%M:%S ")

    printf(1,"Listening for request on %s\n",{bind_addr})
    if string(server_log) then
        append_lines(server_log,
            {sprintf("-----SERVER STARTED %s",{starttime}),
             sprintf("-----Listening for request on %s",{bind_addr})})
    end if
    
    while sock:listen(server,10) = sock:OK do
        object client = sock:accept(server)
        if sequence(client) then
            handle_request(server,client,doc_root)
            sock:close(client[1])
        end if
    end while

    sock:close(server)
    
    return 1
end function

----------------------
procedure show_usage()
----------------------
puts(1, `

  Euphoria Web Server version 1.2
  
  Usage: eui httpd -bind 127.0.0.1:8080 -root /home/irv/docs
  
   Required parameters:
    -bind ip_address:port 
    -root document_root 

   Optional flags:
    -h show_hidden files
    -s sort listing
    -r show full request in log
    -t number of tries to obtain port
    -log name of log file

    `)
    
puts(1,"\n")   
abort(0)
end procedure

server() -- start
------------------------
--© 2014 by Irv Mullins
------------------------
