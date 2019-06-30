# For complete documentation of this file, please see Geany's main documentation

# Geany Color Syntax support for Euphoria 4.1

# Make backups of any file that you edit!

# This is filetypes.lua edited to support the Euphoria Programming Language
# Make a backup copy of the stock filetypes.lua file, to make sure you never
# over write the original.

# Copy this file into the directory: ~/.config/geany/filedefs/ 

# Edit the filetype_extensions.conf file
# located in ~/.config/geany/ directory as follows:
# substituting euphoria file extensions for those
# assigned to the language, Lua.
# Lua=*.e;*.eu;*.exu;*.exw;*.ex;

# 0xE6E6FA = white
# 0xE5E5E5 = light grey
# 0x2FCD2F = light green
# 0xD78821 = Brown

[styling]
# foreground;background;bold;italic
default=0x000000;0xffffff;false;false
comment=0xd00000;0xffffff;false;false
commentline=0xd00000;0xffffff;false;true
commentdoc=0xd00000;0xffffff;true;false
number=0x007f00;0xffffff;false;false
word=0x00007f;0xffffff;true;false
string=0x315139;0xFFFFFF;false;false
character=0x008000;0xffffff;false;false
literalstring=0x008020;0xffffff;true;false
preprocessor=0x007f7f;0xffffff;false;false
operator=0x301010;0xffffff;false;false
identifier=0x000000;0xffffff;false;false
stringeol=0x000000;0xe0c0e0;false;false
function_basic=0x991111;0xffffff;false;false
function_other=0x1126ED;0xffffff;true;true

[keywords]
# all items must be in one line
keywords=and as break by case constant continue do else elsedef elsif elsifdef end entry equal export fallthru for function global goto if ifdef include label loop namespace not or override procedure public retry return routine switch then to type until while with without xor

# Basic functions
function_basic=? abort and_bits append arctan atom c_func c_proc call call_func call_proc clear_screen close command_line compare cos date delete delete_routine find floor get_key getc getenv gets hash head include_paths insert integer length log machine_func machine_proc match mem_copy mem_set not_bits object open option_switches or_bits peek peek2s peek2u peek4s peek4u peek_string peeks pixel platform position power prepend print printf puts rand remainder remove repeat replace sequence sin splice sprintf sqrt system system_exec tail tan task_clock_start task_clock_stop task_create task_list task_schedule task_self task_status task_suspend task_yield time trace xor_bits Widget Container Button Label Adjustment Printer PrintContext PaperSize PrintSetup KeyMap StyleContext Signal FontFamily FontFace FontDescr Settings Combo TreeModel TreeSelection TreePath TreeRowReference SelectionData SourceLanguage PixBuf IconSet TreeView TreeStore ListStore Object Window Dialog AboutDialog Assistant Box Grid Revealer ListBox FlowBox Stack StackSwitcher Sidebar ActionBar HeaderBar Overlay ButtonBox Paned Layout Notebook Expander AspectFrame Image Spinner InfoBar ProgressBar LevelBar Statusbar AccelLabel CheckButton ToggleButton RadioButton LinkButton MenuButton Switch ScaleButton VolumeButton LockButton Entry EntryBuffer EntryCompletion Scale SpinButton SearchEntry SearchBar Editable TextMark TextTag TextTagTable TextView TextBuffer TreeViewColumn IconView CellRendererText CellRendererPixbuf CellRendererProgress CellRendererAccel CellRendererCombo CellRendererToggle CellRendererSpin CellRendererSpinner ComboBox ComboBoxText Menu MenuBar MenuItem RadioMenuItem CheckMenuItem SeparatorMenuItem Toolbar ToolItem ToolPalette ToolButton MenuToolButton ToggleToolButton RadioToolButton Popover PopoverMenu ColorChooser ColorButton ColorChooserWidget ColorChooserDialog FileFilter FileChooser FileChooserButton FileChooserDialog FileChooserWidget PlacesSidebar Frame Scrollbar ScrolledWindow Calendar GLArea Tooltip Viewport FontChooser FontButton FontChooserWidget FontChooserDialog Bin Range ListBoxRow FontDescription AppChooser  AppChooserDialog TreeModelSort RecentChooser RecentChooserWidget RecentChooserDialog RecentChooserMenu RecentFilter DrawingArea ImageMenuItem EventBox TreeModelFilter Application ApplicationWindow Pixbuf IconTheme

function_other=add connect create destroy disconnect Error Quit get hide hide_all idle Info key_pressed main  pack Question run set show show_all timeout Warn UNIX ADD ADDRESS_LENGTH ADDR_ADDRESS ADDR_FAMILY ADDR_FLAGS ADDR_PROTOCOL ADDR_TYPE ADD_APPEND ADD_PREPEND ADD_SORT_DOWN ADD_SORT_UP ADLER32 AF_APPLETALK AF_BTH AF_INET AF_INET6 AF_UNIX AF_UNSPEC ANCHORED APPEND ASCENDING AS_IS AT_EXPANSION AUTO_CALLOUT AVERAGE_BUCKET Accessing Accessor Accumulation Adding Allocating Answer Automatic BAD_FILE BAD_RECNO BAD_SEEK BGSET BINARY_MODE BK_LEN BK_PIECES BLACK BLINKING BLOCK_CURSOR BLUE BMP_INVALID_MODE BMP_OPEN_FAILED BMP_SUCCESS BMP_UNEXPECTED_EOF BMP_UNSUPPORTED_FORMAT BRIGHT_BLUE BRIGHT_CYAN BRIGHT_GREEN BRIGHT_MAGENTA BRIGHT_RED BRIGHT_WHITE BROWN BSR_ANYCRLF BSR_UNICODE BYTES_PER_CHAR BYTES_PER_SECTOR Background BadSig: Base Basic Bitmap Bitwise Building C CASELESS CHILD CMD_SWITCHES COMBINE_SORTED COMBINE_UNSORTED CONCAT CONNECTION CONNECT_FREE CONNECT_LOCK CONNECT_TABLES CORRECT COUNT_DIRS COUNT_FILES COUNT_SIZE COUNT_TYPES CS_ASCII CS_Alphabetic CS_Alphanumeric CS_Boolean CS_Bytes CS_Consonant CS_Control CS_Digit CS_Displayable CS_FIRST CS_Graphic CS_Hexadecimal CS_Identifier CS_LAST CS_Lowercase CS_Printable CS_Punctuation CS_SpecWord CS_Uppercase CS_Vowel CS_Whitespace CYAN C_BOOL C_BYTE C_CHAR C_DOUBLE C_DWORD C_DWORDLONG C_FLOAT C_HANDLE C_HRESULT C_HWND C_INT C_LONG C_LONGLONG C_LPARAM C_POINTER C_SHORT C_SIZE_T C_UBYTE C_UCHAR C_UINT C_ULONG C_USHORT C_WORD C_WPARAM Calling Changing Client Colors Command Common Compile Configuration Console Constants Core Create Cross Cursor DATE DAY DAYS DB_BAD_NAME DB_EXISTS_ALREADY DB_FATAL_FAIL DB_LOCK_EXCLUSIVE DB_LOCK_FAIL DB_LOCK_NO DB_LOCK_READ_ONLY DB_LOCK_SHARED DB_OK DB_OPEN_FAIL DEFAULT DEGREES_TO_RADIANS DESCENDING DFA_RESTART DFA_SHORTEST DISCONNECT DISPLAY_ASCII DIVIDE DNS DNS_QUERY_ACCEPT_TRUNCATED_RESPONSE DNS_QUERY_BYPASS_CACHE DNS_QUERY_DONT_RESET_TTL_VALUES DNS_QUERY_NO_HOSTS_FILE DNS_QUERY_NO_LOCAL_NAME DNS_QUERY_NO_NETBT DNS_QUERY_NO_RECURSION DNS_QUERY_NO_WIRE_QUERY DNS_QUERY_RESERVED DNS_QUERY_RETURN_MESSAGE DNS_QUERY_STANDARD DNS_QUERY_TREAT_AS_FQDN DNS_QUERY_USE_TCP_ONLY DNS_QUERY_WIRE_ONLY DOLLAR_ENDONLY DOS_TEXT DOTALL DUPNAMES DUP_TABLE D_ALTNAME D_ATTRIBUTES D_DAY D_HOUR D_MILLISECOND D_MINUTE D_MONTH D_NAME D_SECOND D_SIZE D_YEAR Data Database Date Directory Dynamic E EAF_APPLETALK EAF_BTH EAF_INET EAF_INET6 EAF_UNIX EAF_UNSPEC ENCODE_BASE64 ENCODE_NONE EOF EOL EOLSEP ERROR_BADCOUNT ERROR_BADMAGIC ERROR_BADNEWLINE ERROR_BADOPTION ERROR_BADPARTIAL ERROR_BADUTF8 ERROR_BADUTF8_OFFSET ERROR_CALLOUT ERROR_DFA_RECURSE ERROR_DFA_UCOND ERROR_DFA_UITEM ERROR_DFA_UMLIMIT ERROR_DFA_WSSIZE ERROR_INTERNAL ERROR_MATCHLIMIT ERROR_NOMATCH ERROR_NOMEMORY ERROR_NOSUBSTRING ERROR_NULL ERROR_NULLWSLIMIT ERROR_PARTIAL ERROR_RECURSIONLIMIT ERROR_UNKNOWN_NODE ERROR_UNKNOWN_OPCODE ERR_ACCESS ERR_ADDRINUSE ERR_ADDRNOTAVAIL ERR_AFNOSUPPORT ERR_AGAIN ERR_ALREADY ERR_CONNABORTED ERR_CONNECT_FAILED ERR_CONNREFUSED ERR_CONNRESET ERR_DESTADDRREQ ERR_FAULT ERR_HOSTUNREACH ERR_HOST_LOOKUP_FAILED ERR_INPROGRESS ERR_INTR ERR_INVAL ERR_INVALID_DATA ERR_INVALID_DATA_ENCODING ERR_INVALID_PROTOCOL ERR_IO ERR_ISCONN ERR_ISDIR ERR_LOOP ERR_MALFORMED_URL ERR_MFILE ERR_MSGSIZE ERR_NAMETOOLONG ERR_NETDOWN ERR_NETRESET ERR_NETUNREACH ERR_NFILE ERR_NOBUFS ERR_NOENT ERR_NOTCONN ERR_NOTDIR ERR_NOTINITIALISED ERR_NOTSOCK ERR_OPNOTSUPP ERR_PROTONOSUPPORT ERR_PROTOTYPE ERR_RECEIVE_FAILED ERR_ROFS ERR_SEND_FAILED ERR_SHUTDOWN ERR_SOCKTNOSUPPORT ERR_TIMEDOUT ERR_WOULDBLOCK ESOCK_DGRAM ESOCK_RAW ESOCK_RDM ESOCK_SEQPACKET ESOCK_STREAM ESOCK_TYPE_AF ESOCK_TYPE_OPTION ESOCK_TYPE_TYPE ESOCK_UNDEFINED_VALUE ESOCK_UNKNOWN_FLAG EULER_GAMMA EXTENDED EXTRA EXTRAS EXT_COUNT EXT_NAME EXT_SIZE E_ATOM E_INTEGER E_OBJECT E_SEQUENCE Environment Equality Errors EuDist Euphoria Executable External Extracting, FALSE FGSET FIFO FILETYPE_DIRECTORY FILETYPE_FILE FILETYPE_NOT_FOUND FILETYPE_UNDEFINED FILO FIRSTLINE FLETCHER32 FORM_URLENCODED FP_FORMAT FREEBSD FREE_BYTES File Finding Flags Floating GET_EOF GET_FAIL GET_LONG_ANSWER GET_NOTHING GET_SHORT_ANSWER GET_SUCCESS GRAY GREEN General Get/Post Graphics HALFPI HALFSQRT2 HALF_BLOCK_CURSOR HAS_CASE HAS_PARAMETER HEADER HELP HELP_RID HOST_ALIASES HOST_IPS HOST_OFFICIAL_NAME HOST_TYPE HOUR HOURS HSIEH30 HSIEH32 HTTP Hashing Hyperbolic I/O IDABORT IDCANCEL IDIGNORE IDNO IDOK IDRETRY IDYES INDENT INIT_FREE INIT_TABLES INSERT_FAILED INT_FORMAT INVALID_ROUTINE_ID INVLN10 INVLN2 INVSQ2PI IP Indexes Indirect Information Input Interacting Intervals Introduction KC_LBUTTON Key Keyboard LARGEMAP LARGEST_BUCKET LAST_ERROR_CODE LEAVE LINE_BREAKS LINUX LN10 LN2 LOCK_EXCLUSIVE LOCK_METHOD LOCK_SHARED Locale Localized Lock Logarithms Low MAGENTA MANDATORY MAP_ANONYMOUS MAP_FAILED MAX_ASCII MAX_LINES MB_ABORTRETRYIGNORE MB_APPLMODAL MB_DEFAULT_DESKTOP_ONLY MD5 MINF MINUTE MINUTES MIN_ASCII MISSING_END MONTH MONTHS MSG_CONFIRM MSG_CTRUNC MSG_DONTROUTE MSG_DONTWAIT MSG_EOR MSG_ERRQUEUE MSG_FIN MSG_MORE MSG_NOSIGNAL MSG_OOB MSG_PEEK MSG_PROXY MSG_RST MSG_SYN MSG_TRUNC MSG_TRYHARD MSG_WAITALL MULTILINE MULTIPART_FORM_DATA MULTIPLE MULTIPLY Machine Managing Map Marchine Match Matching Math Memory Message Microsoft Miscellaneous Multi-Tasking NESTED_ALL NESTED_ANY NESTED_BACKWARD NESTED_INDEX NETBSD NEWLINE_ANY NEWLINE_ANYCRLF NEWLINE_CR NEWLINE_CRLF NEWLINE_LF NORMAL_ORDER NOTBOL NOTEMPTY NOTEOL NO_AT_EXPANSION NO_AUTO_CAPTURE NO_CASE NO_CURSOR NO_DATABASE NO_HELP NO_HELP_ON_ERROR NO_PARAMETER NO_ROUTINE_ID NO_TABLE NO_UTF8_CHECK NO_VALIDATION NO_VALIDATION_AFTER_FIRST_EXTRA NS_C_ANY NS_C_IN NS_KT_DH NS_KT_DSA NS_KT_PRIVATE NS_KT_RSA NS_T_A NS_T_A6 NS_T_AAAA NS_T_ANY NS_T_MX NS_T_NS NS_T_PTR NULL NULLDEVICE NUMBER_OF_FREE_CLUSTERS NUM_BUCKETS NUM_ENTRIES NUM_IN_USE Notes OBJ_ATOM OBJ_INTEGER OBJ_SEQUENCE OBJ_UNASSIGNED OK ONCE OPENBSD OPTIONAL OPT_CNT OPT_IDX OPT_REV OPT_VAL OSX Opening Operating Operation Option PAGE_EXECUTE PAGE_EXECUTE_READ PAGE_EXECUTE_READWRITE PAGE_EXECUTE_WRITECOPY PAGE_NOACCESS PAGE_NONE PAGE_READ PAGE_READONLY PAGE_READWRITE PAGE_READ_EXECUTE PAGE_READ_WRITE PAGE_READ_WRITE_EXECUTE PAGE_SIZE PAGE_WRITECOPY PAGE_WRITE_COPY PAGE_WRITE_EXECUTE_COPY PARENT PARTIAL PATHSEP PATH_BASENAME PATH_DIR PATH_DRIVEID PATH_FILEEXT PATH_FILENAME PAUSE_MSG PHI PI PID PINF PISQR PRETTY_DEFAULT PUT Parsing Pipe Predefined Pretty Prime Pseudo QUARTPI RADIANS_TO_DEGREES RD_INPLACE RD_PRESORTED RD_SORT RED REVERSE_ORDER ROTATE_LEFT ROTATE_RIGHT Random Read Reading Regular Replacement Reporting Return Roundings Routines SCM_TIMESTAMP SCM_TIMESTAMPING SCM_TIMESTAMPNS SCREEN SD_BOTH SD_RECEIVE SD_SEND SECOND SECONDS SECTORS_PER_CLUSTER SELECT_IS_ERROR SELECT_IS_READABLE SELECT_IS_WRITABLE SELECT_SOCKET SEQ_NOALT SHA256 SHARED_LIB_EXT SHOW_ONLY_OPTIONS SLASH SLASHES SMALLEST_BUCKET SMALLMAP SM_RAW SM_TEXT SND_ASTERISK SND_DEFAULT SND_EXCLAMATION SND_QUESTION SND_STOP SOCKET_SOCKADDR_IN SOCKET_SOCKET SOCK_DGRAM SOCK_RAW SOCK_RDM SOCK_SEQPACKET SOCK_STREAM SOL_SOCKET SO_ACCEPTCONN SO_ATTACH_FILTER SO_BINDTODEVICE SO_BROADCAST SO_BSDCOMPAT SO_CONNDATA SO_CONNDATALEN SO_CONNOPT SO_CONNOPTLEN SO_DEBUG SO_DETACH_FILTER SO_DISCDATA SO_DISCDATALEN SO_DISCOPT SO_DISCOPTLEN SO_DOMAIN SO_DONTLINGER SO_DONTROUTE SO_ERROR SO_KEEPALIVE SO_LINGER SO_MARK SO_MAXDG SO_MAXPATHDG SO_NO_CHECK SO_OOBINLINE SO_OPENTYPE SO_PASSCRED SO_PASSSEC SO_PEERCRED SO_PEERNAME SO_PEERSEC SO_PRIORITY SO_PROTOCOL SO_RCVBUF SO_RCVBUFFORCE SO_RCVLOWAT SO_RCVTIMEO SO_REUSEADDR SO_REUSEPORT SO_RXQ_OVFL SO_SECURITY_AUTHENTICATION SO_SECURITY_ENCRYPTION_NETWORK SO_SECURITY_ENCRYPTION_TRANSPORT SO_SNDBUF SO_SNDBUFFORCE SO_SNDLOWAT SO_SNDTIMEO SO_SYNCHRONOUS_ALTERT SO_SYNCHRONOUS_NONALERT SO_TIMESTAMP SO_TIMESTAMPING SO_TIMESTAMPNS SO_TYPE SO_USELOOPBACK SQRT2 SQRT3 SQRT5 SQRTE START_COLUMN STDERR STDEV_BUCKET STDFLTR_ALPHA STDIN STDOUT STRING_OFFSETS ST_ALLNUM ST_FULLPOP ST_IGNSTR ST_SAMPLE ST_ZEROSTR SUBTRACT Safe Scientific Searching Select Send Sequence Serialization Server Setup Shutdown Sign Socket Sorting Splitting Stack Standard Statistics Style Support TEST_QUIET TEST_SHOW_ALL TEST_SHOW_FAILED_ONLY TEXT_MODE THICK_UNDERLINE_CURSOR TOTAL_BYTES TOTAL_NUMBER_OF_CLUSTERS TO_LOWER TO_SHORT TRUE TWOPI Tests Text Time Trigonometry Type Types UDP UNDERLINE_CURSOR UNGREEDY UNIX_TEXT URL URL_ENTIRE URL_HOSTNAME URL_HTTP_DOMAIN URL_HTTP_PATH URL_HTTP_QUERY URL_MAIL_ADDRESS URL_MAIL_DOMAIN URL_MAIL_QUERY URL_MAIL_USER URL_PASSWORD URL_PATH URL_PORT URL_PROTOCOL URL_QUERY_STRING URL_USER USED_BYTES UTF8 Unit Using Utilities Utility VALIDATE_ALL VC_COLOR VC_COLUMNS VC_LINES VC_MODE VC_NCOLORS VC_PAGES VC_SCRNCOLS VC_SCRNLINES VC_XPIXELS VC_YPIXELS VERSIONING Variables WEEKS WHITE WIN32 WINDOWS WRAP Warning Wildcard Windows Writing YEAR YEARS YELLOW abbreviate_path abort abs absolute_path accept add_item all_matches allocate allocate_code allocate_data allocate_pointer_array allocate_protect allocate_string allocate_string_pointer_array allocate_wstring allow_break ampm and_bits any_key append append_lines apply approx arccos arccosh arcsin arcsinh arctan arctanh ascii_string assert at atan2 atom atom_to_float32 atom_to_float64 atom_to_float80 attr_to_colors avedev average begins binary_search bind binop_ok bits_to_bytes bits_to_int bk_color boolean breakup build_commandline build_list byte_range bytes_to_bits bytes_to_int c_func c_proc calc_hash calc_primes call call_back call_func call_proc canon2win canonical canonical_path case_flagset_type ceil central_moment chance char_test chdir check_all_blocks check_break check_calls check_free_list checksum clear clear_directory clear_screen close cmd_parse color colors_to_attr columnize combine command_line compare console_colors copy copy_file cos cosh count crash crash_file crash_message crash_routine create_directory create_file cstring curdir current_dir cursor custom_sort date datetime day_abbrs day_names days_in_month days_in_year db_cache_clear db_clear_table db_close db_compress db_connect db_create db_create_table db_current db_current_table db_delete_record db_delete_table db_dump db_fatal_id db_fetch_record db_find_key db_get_errors db_get_recid db_insert db_open db_record_data db_record_key db_record_recid db_rename_table db_replace_data db_replace_recid db_select db_select_table db_set_caching db_table_list db_table_size decanonical decode defaulted_value defaultext define_c_func define_c_proc define_c_var deg2rad delete delete_file delete_routine dequote deserialize diff dir dir_size dirname disk_metrics disk_size display display_text_image driveid dump dup edges_only emovavg encode ends ensure_in_list ensure_in_range error_code error_message error_names error_no error_to_string escape exec exp extract fetch fib file_exists file_length file_number file_position file_timestamp file_type filebase fileext filename filter find find_all find_all_but find_any find_each find_from find_nested find_replace find_replace_callback find_replace_limit flags_to_string flatten float32_to_atom float64_to_atom float80_to_atom floor flush for_each format frac free free_code free_console free_pointer_array from_date from_unix gcd geomean  get_bytes get_charsets get_def_lang get_dstring get_encoding_properties get_integer16 get_integer32 get_key get_lang_path get_option get_ovector_size get_pid get_position get_rand get_screen_char get_text getc getenv gets graphics_mode graphics_point harmean has has_console has_match hash head hex_text host_by_addr host_by_name http_get http_post iif info init_curdir insert insertion_sort instance int_to_bits int_to_bytes intdiv integer integer_array is_empty is_even is_even_obj is_in_list is_in_range is_inetaddr is_leap_year is_match is_win_nt join join_path key_codes keys keyvalues kill kurtosis lang_load larger_of largest last length listen load load_map locale_canonical locate_file lock_file lock_type log log10 lookup lower machine_addr machine_func machine_proc malloc map mapping match match_all match_any match_from match_replace matches max maybe_any_key median mem_copy mem_set merge message_box mid min minsize mixture mod mode money month_abbrs month_names movavg move_file my_dir nested_get nested_put new new_extra new_from_kvpairs new_from_string new_time next_prime not_bits now now_gmt number number_array object open open_dll optimize option_spec option_spec_to_string option_switches or_all or_bits pad_head pad_tail pairs parse parse_commandline parse_ip_address parse_querystring parse_url patch pathinfo pathname peek peek2s peek2u peek4s peek4u peek8s peek8u peek_end peek_longs peek_longu peek_string peek_top peek_wstring peeks pivot platform platform_locale poke poke2 poke4 poke8 poke_long poke_string poke_wstring pop position positive_int posix_names power powof2 prepend pretty_print pretty_sprint prime_list print printf process process_lines product project prompt_number prompt_string proper push put put_integer16 put_integer32 put_screen_char puts quote rad2deg ram_space rand rand_range range raw_frequency read read_bitmap read_file read_lines receive receive_from regex register_block rehash remainder remove remove_all remove_directory remove_dups remove_item remove_subseq rename_file repeat repeat_pattern replace retain_all reverse rfind rmatch rnd rnd_1 roll rotate rotate_bits round routine_id safe_address sample save_bitmap save_map save_text_image scientific_to_atom scientific_to_float scroll seek select send send_to sequence sequence_array serialize series service_by_name service_by_port set set_accumulate_summary set_charsets set_decimal_mark set_def_lang set_default_charsets set_encoding_properties set_keycodes set_lang_path set_option set_proxy_server set_rand set_test_abort set_test_verbosity set_wait_on_summary setenv shift_bits show_help shuffle shutdown sign sim_index sin sinh size skewness sleep slice small smaller_of smallest socket sort sort_columns sound splice split split_any split_limit split_path sprint sprintf sqrt stack statistics std_library_address stdev store string subtract sum sum_central_moments swap system system_exec t_alnum t_alpha t_ascii t_boolean t_bytearray t_cntrl t_consonant t_digit t_display t_graph t_identifier t_integer32 t_lower t_print t_punct t_space t_specword t_text t_upper t_vowel t_xdigit tail tan tanh task_clock_start task_clock_stop task_create task_delay task_list task_schedule task_self task_status task_suspend task_yield temp_file test_equal test_fail test_false test_not_equal test_pass test_report test_true text_color text_rows threshold time to_integer to_number to_string to_unix top transform translate transmute trim trim_head trim_tail trsprintf true_bgcolor true_fgcolor trunc type type_of uname unlock_file unregister_block unsetenv upper using valid valid_index valid_memory_protection_constant value values video_config vlookup vslice w32_name_canonical w32_names wait_key walk_dir warning warning_file weeks_day where which_bit wrap write write_file write_lines writef writefln xor_bits years_day gslist_to_sequence unpack register pack_start pack_end NonModalDialog

[settings]
# default extension used when saving files
extension=ex

# if only single comment char is supported like # in this file, leave comment_close blank
comment_open=--
comment_close=
# this is an alternative way, so multiline comments are used
comment_open=/*
comment_close=*/
# set to false if a comment character/string should start at column 0 of a line, true uses any
# indentation of the line, e.g. setting to true causes the following on pressing CTRL+d
    #command_example();
# setting to false would generate this
#   command_example();
# This setting works only for single line comments
comment_use_indent=FALSE

# Put the location of your GTK documentation in the context_action_cmd line
# so that you can pop up docs on whatever GtkWidget you highlight in 
# your Euphoria source code, then right-click and choose context action.
# You could also set up a geany keybinding for this, such as alt-i.
# You may prefer to use -new-window instead of -new-tab, 
# and/or -search in order to use your default search engine;
context_action_cmd=firefox -new-tab file:///home/irv/gtk3/%s.html

[build_settings]
# %f will be replaced by the complete filename
# %e will be replaced by the filename without extension
# (use only one of it at one time)

[build-menu]
EX_00_LB=Run Source File with Euphoria Interpreter
EX_00_CM=\seui ~/demos/gneui  %f 
EX_00_WD=
FT_00_LB=Translate source to C code & Compile
FT_00_CM=euc "%e"
FT_00_WD=
FT_01_LB=Bind source code with interpreter
FT_01_CM=eubind "%e"
FT_01_WD=
FT_02_LB=Gather files into Eudist directory
FT_02_CM=eudist "%f"
FT_02_WD=
EX_01_LB=Execute Compiled or Bound Code File
EX_01_CM=\s./%e
EX_01_WD=