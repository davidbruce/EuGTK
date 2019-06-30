-- PROJECT:  MATH_EVAL
-- VERSION:  1.1.0  3.12.2014   (created on LinuxMint 17, using Geany editor).
-- AUTHOR:   Shian Lee
-- LANGUAGE: Euphoria 4.1.0  <http://openeuphoria.org/>
-- LICENSE:  Free. Use at your own risk.
-- --------------------------------------------------------------------------
-- PURPOSE:  a function which evaluate Euphoria's math expressions,
--           and returns atom as result, or an error message string.
--           typically used to calculate math expressions entered by the user.
--           math_eval supports functions, operators, variables & constants.
--           read the attached "math_eval.doc" user manual for details.
-- NOTE:     * the code checks for errors so your program will not crash.
--           * expressions are evaluated in the same manner as Euphoria 4.1.
--           * sequences are not supported (it's used mainly in spreadsheets).
-- ==========================================================================



-- current version of math_eval, used by demo programs help:
public constant
    MATH_EVAL_VERSION = "Expression Calculator 1.1.0, 3.12.2014, Shian Lee."



-- include Euphoria 4.1.0 library files:
include std/types.e     -- useful types and constants, e.g. boolean().
include std/math.e      -- math functions and math constants, e.g. abs().
include std/get.e       -- value().
include std/convert.e   -- to_number(), set_decimal_mark().
include std/text.e      -- trim().
include std/sequence.e  -- remove_all().



-- EUPHORIA OPERATORS & CONSTANT & FUNCTIONS CONSTANTS ======================

-- NOTE: functions, constants, operators - are all INDEXED. if you can't
--       implement one of them then you MUST NOT REMOVE IT; it's there
--       to be implemented later. instead you should replace the calculation
--       of functions with: return err_msg(ER_NOT_IMPLEMENTED, "func-name").
--       - this note is especially important for converting the syntax to
--         Euphoria 3.1.1.
--       - new functions/constants/operators may be appended TO THE END of a
--         list though - this will not break the existing code.


constant
    -- parse_expr() keeps the index of functions, instead of the identifier
    -- name itself, i.e. {FUNC_ID, func_ix}, e.g. "power" --> {'@', 25};
    -- FUNC_ID must be integer, not part of the syntax, e.g. '@', 999, etc:
    FUNC_ID = '@',


    -- Euphoria 4 precedence lists (Euphoria 4.1 manual - 4.1.5 Precedence Chart):
    -- all items in precedence list must be of "string" type:
    PRECEDENCE_LISTS = {                    -- [index]  description:
        {}, -- (place holder)               -- [1]  parenthesis () (highest)
        {}, -- (place holder)               -- [2]  function calls
        {}, -- (place holder)               -- [3]  unary-  unary+  not
        {"*", "/"},                         -- [4]  *  /
        {"+", "-"},                         -- [5]  +  -
        {"<", ">", "<=", ">=", "=", "!="},  -- [6]  <  >  <=  >=  =  !=
        {"and", "or", "xor"}                -- [7]  and  or  xor
    },


    -- all items in unary operators list must be of "string" type:
    UNARY_OP_LIST = {"-", "+", "not"},


    -- Euphoria 4 operators list (Euphoria 4.1 manual - 4.1.4 Expressions);
    -- all items in op list must be of "string" type:
    OP_LIST = {     -- [index]      description:
        "*",        --  [1] *       PRECEDENCE_LISTS[4]
        "/",        --  [2] /
        "+",        --  [3] +       PRECEDENCE_LISTS[5]
        "-",        --  [4] -
        "<",        --  [5] <       PRECEDENCE_LISTS[6]
        ">",        --  [6] >
        "<=",       --  [7] <=
        ">=",       --  [8] >=
        "=",        --  [9] =
        "!=",       -- [10] !=
        "and",      -- [11] and     PRECEDENCE_LISTS[7]
        "or",       -- [12] or
        "xor",      -- [13] xor
        "not"       -- [14] not     PRECEDENCE_LISTS[3]
    },


    -- Euphoria 4 constants list (Euphoria 4.1 manual - 8.26.1 Math Constants);
    -- these are two paralleled lists: constants names & constants values:

    -- all items in const list must be of "string" type:
    CONST_LIST = {              -- [index]
        "PI",                   --  [1]
        "QUARTPI",              --  [2]
        "HALFPI",               --  [3]
        "TWOPI",                --  [4]
        "PISQR",                --  [5]
        "INVSQ2PI",             --  [6]
        "PHI",                  --  [7]
        "E",                    --  [8]
        "LN2",                  --  [9]
        "INVLN2",               -- [10]
        "LN10",                 -- [11]
        "INVLN10",              -- [12]
        "SQRT2",                -- [13]
        "HALFSQRT2",            -- [14]
        "SQRT3",                -- [15]
        "DEGREES_TO_RADIANS",   -- [16]
        "RADIANS_TO_DEGREES",   -- [17]
        "EULER_GAMMA",          -- [18]
        "SQRTE",                -- [19]
        "PINF",                 -- [20]
        "MINF",                 -- [21]
        "SQRT5"                 -- [22]
    },
    -- all items in const list values must be of atom type:
    CONST_LIST_VALUES = {       -- [index]
        PI,                     --  [1]
        QUARTPI,                --  [2]
        HALFPI,                 --  [3]
        TWOPI,                  --  [4]
        PISQR,                  --  [5]
        INVSQ2PI,               --  [6]
        PHI,                    --  [7]
        E,                      --  [8]
        LN2,                    --  [9]
        INVLN2,                 -- [10]
        LN10,                   -- [11]
        INVLN10,                -- [12]
        SQRT2,                  -- [13]
        HALFSQRT2,              -- [14]
        SQRT3,                  -- [15]
        DEGREES_TO_RADIANS,     -- [16]
        RADIANS_TO_DEGREES,     -- [17]
        EULER_GAMMA,            -- [18]
        SQRTE,                  -- [19]
        PINF,                   -- [20]
        MINF,                   -- [21]
        SQRT5                   -- [22]
    },


    -- Euphoria 4 functions list (+ your own documented functions...);
    -- all items in functions list must be of "string" type:
    FUNC_LIST = {       -- [index] description:
        "abs",          --  [1] Eu 4.1 manual - 8.25.1 Sign and Comparisons:
        "sign",         --  [2]
        "larger_of",    --  [3]
        "smaller_of",   --  [4]
        "remainder",    --  [5] Eu 4.1 manual - 8.25.2 Roundings and Remainders:
        "mod",          --  [6]
        "trunc",        --  [7]
        "frac",         --  [8]
        "intdiv",       --  [9]
        "floor",        -- [10]
        "ceil",         -- [11]
        "round",        -- [12]
        "arctan",       -- [13] Eu 4.1 manual - 8.25.3 Trigonometry:
        "tan",          -- [14]
        "cos",          -- [15]
        "sin",          -- [16]
        "arccos",       -- [17]
        "arcsin",       -- [18]
        "atan2",        -- [19]
        "rad2deg",      -- [20]
        "deg2rad",      -- [21]
        "log",          -- [22] Eu 4.1 manual - 8.25.4 Logarithms and Powers:
        "log10",        -- [23]
        "exp",          -- [24]
        "power",        -- [25]
        "sqrt",         -- [26]
        "fib",          -- [27]
        "cosh",         -- [28] Eu 4.1 manual - 8.25.5 Hyperbolic Trigonometry:
        "sinh",         -- [29]
        "tanh",         -- [30]
        "arcsinh",      -- [31]
        "arccosh",      -- [32]
        "arctanh",      -- [33]
        "and_bits",     -- [34] Eu 4.1 manual - 8.25.7 Bitwise Operations:
        "xor_bits",     -- [35]
        "or_bits",      -- [36]
        "not_bits",     -- [37]
        "shift_bits",   -- [38]
        "rotate_bits",  -- [39]
        "gcd",          -- [40]
        "approx",       -- [41]
        "powof2",       -- [42]
        "is_even",      -- [43]
        "rand",         -- [44] Eu 4.1 manual - 8.27 Random Numbers:
        "rand_range",   -- [45]
        "rnd",          -- [46]
        "rnd_1",        -- [47]
        "chance",       -- [48]
        "roll",         -- [49]
        "compare",      -- [50] Eu 4.1 manual - 8.15.1 Equality
        -- added in version 1.1.0:
        "time"          -- [51] Eu 4.1 manual - 8.4.5.1 time
    }



-- OTHER CONSTANTS ==========================================================

constant
    -- common error messages used by err_msg():
    ER_NOT_IMPLEMENTED  = "Sorry, function not implemented yet",
    ER_SYNTAX_ERROR     = "Syntax error in",
    ER_DEV_BY_ZERO      = "Division by zero in",
    ER_UNDEFINED_RES    = "Undefined result in",
    ER_ILLEGAL_ARG      = "Illegal argument in",
    ER_BUG_IN_CODE      = "Sorry... BUG in routine",

    -- nul (ASCII-0) can be used as end-of-string marker where needed:
    NUL = 0



-- TYPES & UTILITIES ========================================================

-- PURPOSE: test if s is a sequence of strings, e.g. {"xyz", "..."}.
-- NOTE:    string is byte-characters from 0 to 255.
type seq_of_strings(sequence s)
    for i = 1 to length(s) do
        if not string(s[i]) then
            return FALSE
        end if
    end for
    return TRUE
end type



-- PURPOSE: test if s is a sequence of atoms and/or strings, e.g. {"4", -1.5}.
type seq_of_values(sequence s)
    for i = 1 to length(s) do
        if not atom(s[i]) then
            if not string(s[i]) then
                return FALSE
            end if
        end if
    end for
    return TRUE
end type



-- PURPOSE: test if s is a sequence of two sequences of the same length.
type paralleled_seq(sequence s)
    if length(s) = 2 then
        if sequence(s[1]) and sequence(s[2]) then
            if length(s[1]) = length(s[2]) then
                return TRUE
            end if
        end if
    end if
    return FALSE
end type



-- PURPOSE: identical to std/sequence.e - remove_dups(s, RD_INPLACE); just
--          much shorter, since not using sort(). See help for remove_dups().
function remove_dups_inplace(sequence source_data)
    sequence lResult = {}

    for i = 1 to length(source_data) do
        if not find(source_data[i], lResult) then
            lResult = append(lResult, source_data[i])
        end if
    end for
    return lResult
end function



-- PURPOSE: construct a returned error message.
-- DETAILS: msg is the error text.
--          symbol is any element (function, operator, etc) to add. ""=none.
--          pos is position (column) of error. 0=none.
-- OUTPUT:  error_occurred
-- RETURN:  ascii_string; short error message.
-- EXAMPLE: st = err_msg("Arrays not supported in", "abs", 7)
--            --> st is "[Arrays not supported in 'abs' at position 7]"
-- SEEALSO: math_eval, parse_expr, set_local_variables, ER_ constants above.
constant
    -- start and end of error message must be a single char:
    ERR_MSG_HEAD = '[',
    ERR_MSG_TAIL = ']'
boolean
    error_occurred = FALSE -- reset for debug & also by set_local_variables().
function err_msg(ascii_string msg, ascii_string symbol = "", integer pos = 0)
    ascii_string pos_str = ""

    error_occurred = TRUE   -- set error flag

    if length(symbol) then
        symbol = " '" & symbol & "'"
    end if
    if pos then
        pos_str = sprintf(" at position %d", pos)
    end if

    return ERR_MSG_HEAD & msg & symbol & pos_str & ERR_MSG_TAIL
end function



-- PURPOSE: convert a string to number. supports binary, octal, decimal,
--          hexadecimal (0b, 0t, 0d, 0x, #) with decimal marker, and number
--          in scientific notation.
--          * eui supports decimal marker only for decimal, e.g. 1.2; 5.1e+2.
-- DETAILS: s is a *trimmed* string which represents a number.
-- RETURN:  object; meaningless sequence on error; result atom on success.
-- NOTE:    set_decimal_mark('.') is done by set_local_variables(), for
--          compatibility with 'eui' syntax.
-- EXAMPLE: x = string_to_number("0xFF")  -- x is 255
-- SEEALSO: parse_expr, set_local_variables
function string_to_number(string s)
    object  r
    integer len = length(s)

    -- value() don't support '_'; to_number() don't support 0b_11 case, etc:
    s = remove_all('_', s)


    -- # 16 = Hexadecimal (with lower a-f and decimal marker support):
    if len and s[1] = '#' then
        r = to_number(s, -1)

    -- 0b/0t/0d/0x Binary/Octal/Decimal/Hexadecimal numbers:
    elsif len >= 2 and s[1] = '0' and find(s[2], "btdx") then
        switch s[2] do
            case 'b' then       -- 0b  2 = Binary
                s[2] = '!'
            case 't' then       -- 0t  8 = Octal
                s[2] = '@'
            case 'd' then       -- 0d 10 = Decimal
                s[2] = 32
            case 'x' then       -- 0x 16 = Hexadecimal
                s[2] = '#'
        end switch

        r = to_number(tail(s), -1)    -- ! Euphoria 3: tail(s) is s[2..len].

    else -- Decimal or Number in scientific notation:
        r = value(s, 1, GET_LONG_ANSWER)
        if r[1] = GET_SUCCESS and r[3] = length(s) then
            r = r[2]
        end if
    end if

    return r
end function



-- PURPOSE: set on enter - or - reset on exit local variables.
-- DETAILS: see 'boolean reset constants' below.
-- OUTPUT:  error_occurred
-- SEEALSO: math_eval, get_identifiers, string_to_number, err_msg
constant
    -- boolean reset constants:
    ON_ENTER = FALSE,   -- set local variables
    ON_EXIT  = TRUE     -- reset local variables
integer
    prev_decimal_mark
procedure set_local_variables(boolean reset)
    if reset = ON_EXIT then
        -- restore previous decimal mark ('.' or ','):
        if prev_decimal_mark != '.' then
            if set_decimal_mark(prev_decimal_mark) then
            end if
        end if

    else -- reset = ON_ENTER:
        -- to_number() is using '.' for compatibility with 'eui' syntax:
        prev_decimal_mark = set_decimal_mark('.')

        -- error flag *must* be reset *ON_ENTER* (not on exit), since
        -- math_eval() is calling itself recursively and checks this flag:
        error_occurred = FALSE
    end if
end procedure



-- PURPOSE: convert sequence of comma-delimited-arguments to sequence of atoms.
-- DETAILS: e is sequence of comma-delimited-arguments, e.g. {5, ",", 20.1}
-- RETURN:  sequence; result sequence or err_msg() string.
-- EXAMPLE: s = arguments_to_sequence({10.4, ",", -3, ",", 401})
--            --> s is {10.4, -3, 401}
-- SEEALSO: calc_func
function arguments_to_sequence(sequence e)
    sequence atoms = {}
    integer  len = length(e)

    -- check for valid arguments, e.g. {}, {1.3}, {5, ",", 20, ",", 3.1}:
    if len = 0 then
        return atoms
    elsif remainder(len, 2) and atom(e[len]) then
        for i = 1 to len - 1 by 2 do
            if atom(e[i]) and equal(e[i + 1], ",") then
                atoms = append(atoms, e[i])
            else
                return err_msg(ER_ILLEGAL_ARG)
            end if
        end for

        return append(atoms, e[len])
    else
        return err_msg(ER_ILLEGAL_ARG)
    end if
end function



-- CHUNK CALCULATION ========================================================

-- PURPOSE: if use_degrees is FALSE then Radians are passed to trigonometry
--          functions as tan(); if is TRUE then Degrees are passed to these
--          functions (therefor must be converted to Radians before use).
-- SEEALSO: math_eval, calc_func_1
boolean
    use_degrees     -- output by math_eval().



-- FUNCTIONS: calc_func_0, calc_func_1, calc_func_2, calc_func_x.
-- PURPOSE:   calculate a function expression with 0 to 2 or 3+ arguments.
-- DETAILS:   name is name of function, e.g. "abs".
--            ix is the function index in FUNC_LIST, e.g. 1.
--            a1, a2 are the function's arguments, by standard order;
--             a is sequence of arguments in case of calc_func_x().
-- RETURN:    object; result atom or err_msg() string.
-- NOTE:      calc_func_# separated into few routines for easier debugging.
-- EXAMPLE:   x = calc_func_0("rnd"   , 46)       --> x might be 0.3343612548
--            x = calc_func_1("abs"   , 1 , -7)          --> x is 7
--            x = calc_func_2("power" , 25, 11, 3)       --> x is 1331
--            x = calc_func_x("approx", 41, {9, 8, 0.5}) --> x is 1
-- SEEALSO:   calc_func, calc_op, calc_unary_op, calc_expr
function calc_func_0(sequence name, integer ix)
    atom r

    switch ix do
        case 46 then    -- [46] "rnd"
            r = rnd()
        case 47 then    -- [47] "rnd_1"
            r = rnd_1()
        case 51 then    -- [51] "time"
            r = time()
        case else
            return err_msg(ER_ILLEGAL_ARG, name)
    end switch

    return r
end function



-- PURPOSE: see calc_func_0().
-- INPUT:   use_degrees
function calc_func_1(sequence name, integer ix, atom a1)
    atom r

    -- first convert degrees to radians for trigonometry functions:
    -- (see: Euphoria 4.1 Manual 8.25.3 Trigonometry).
    if use_degrees then
        switch ix do
            -- [13] "arctan", [14] "tan",    [15] "cos",
            -- [16] "sin",    [17] "arccos", [18] "arcsin",
            case 13, 14, 15, 16, 17, 18 then
                a1 = deg2rad(a1)
        end switch
    end if


    switch ix do
        case  1 then    --  [1] "abs"
            r = abs(a1)
        case  2 then    --  [2] "sign"
            r = sign(a1)
        case  7 then    --  [7] "trunc"
            r = trunc(a1)
        case  8 then    --  [8] "frac"
            r = frac(a1)
        case 10 then    -- [10] "floor"
            r = floor(a1)
        case 11 then    -- [11] "ceil"
            r = ceil(a1)
        case 13 then    -- [13] "arctan"
            r = arctan(a1)
        case 14 then    -- [14] "tan"
            -- PI is infinite so we don't get Error/Zero result when a1 is 0/
            -- 90/180/270/etc degrees; so convert a1 to degrees and round it:
            r = remainder(round(abs(rad2deg(a1)), 1000000000), 180)
            -- in case of 90, 270, 450 degrees, etc, then r is infinite:
            if r = 90 then
                return err_msg(ER_UNDEFINED_RES, name)
            -- in case of 0, 180, 360, 540 degrees, etc, then r is 0:
            elsif r != 0 then
                r = tan(a1)
            end if
        case 15 then    -- [15] "cos"
            r = cos(a1)
        case 16 then    -- [16] "sin"
            r = sin(a1)
        case 17 then    -- [17] "arccos"
            if a1 >= -1 and a1 <= 1 then
                r = arccos(a1)
            else
                return err_msg(ER_ILLEGAL_ARG, name)
            end if
        case 18 then    -- [18] "arcsin"
            if a1 >= -1 and a1 <= 1 then
                r = arcsin(a1)
            else
                return err_msg(ER_ILLEGAL_ARG, name)
            end if
        case 20 then    -- [20] "rad2deg"
            r = rad2deg(a1)
        case 21 then    -- [21] "deg2rad"
            r = deg2rad(a1)
        case 22 then    -- [22] "log"
            if a1 > 0 then
                r = log(a1)
            else
                return err_msg(ER_UNDEFINED_RES, name)
            end if
        case 23 then    -- [23] "log10"
            if a1 > 0 then
                r = log10(a1)
            else
                return err_msg(ER_UNDEFINED_RES, name)
            end if
        case 24 then    -- [24] "exp"
            r = exp(a1)
        case 26 then    -- [26] "sqrt"
            if a1 >= 0 then
                r = sqrt(a1)
            else
                return err_msg(ER_ILLEGAL_ARG, name)
            end if
        case 27 then    -- [27] "fib"
            if integer(a1) then
                r = fib(a1)
            else
                return err_msg(ER_ILLEGAL_ARG, name)
            end if
        case 28 then    -- [28] "cosh"
            r = cosh(a1)
        case 29 then    -- [29] "sinh"
            r = sinh(a1)
        case 30 then    -- [30] "tanh"
            r = tanh(a1)
        case 31 then    -- [31] "arcsinh"
            r = arcsinh(a1)
        case 32 then    -- [32] "arccosh"
            if a1 >= 1 then
                r = arccosh(a1)
            else
                return err_msg(ER_ILLEGAL_ARG, name)
            end if
        case 33 then    -- [33] "arctanh"
            if a1 > -1 and a1 < 1 then
                r = arctanh(a1)
            else
                return err_msg(ER_ILLEGAL_ARG, name)
            end if
        case 37 then    -- [37] "not_bits"
            r = not_bits(a1)
        case 42 then    -- [42] "powof2"
            r = powof2(a1)
        case 43 then    -- [43] "is_even"
            if integer(a1) then
                r = is_even(a1)
            else
                return err_msg(ER_ILLEGAL_ARG, name)
            end if
        case 44 then    -- [44] "rand"
            r = rand(a1)
        case else
            return err_msg(ER_ILLEGAL_ARG, name)
    end switch

    return r
end function



-- PURPOSE: see calc_func_0().
function calc_func_2(sequence name, integer ix, atom a1, atom a2)
    atom r

    -- first check for common errors:
    switch ix do
        -- [5] "remainder", [6] "mod", [9] "intdiv", [12] "round"
        case 5, 6, 9, 12 then
            if a2 = 0 then
                return err_msg(ER_DEV_BY_ZERO, name)
            end if

        -- [38] "shift_bits", [39] "rotate_bits",  [49] "roll"
        case 38, 39, 49 then
            if not integer(a2) then
                return err_msg(ER_ILLEGAL_ARG, name)
            end if
    end switch


    switch ix do
        case  3 then    --  [3] "larger_of"
            r = larger_of(a1, a2)
        case  4 then    --  [4] "smaller_of"
            r = smaller_of(a1, a2)
        case  5 then    --  [5] "remainder"
            r = remainder(a1, a2)
        case  6 then    --  [6] "mod"
            r = mod(a1, a2)
        case  9 then    --  [9] "intdiv"
            r = intdiv(a1, a2)
        case 12 then    -- [12] "round"
            r = round(a1, a2)
        case 19 then    -- [19] "atan2"
            r = atan2(a1, a2)
        case 25 then    -- [25] "power"
            if a1 < 0 and not integer(a2) then
                return err_msg(ER_UNDEFINED_RES, name)
            elsif a1 = 0 and a2 < 0 then
                return err_msg(ER_DEV_BY_ZERO, name)
            elsif a1 = 0 and a2 = 0 then
                return err_msg(ER_ILLEGAL_ARG, name)
            else
                r = power(a1, a2)
            end if
        case 34 then    -- [34] "and_bits"
            r = and_bits(a1, a2)
        case 35 then    -- [35] "xor_bits"
            r = xor_bits(a1, a2)
        case 36 then    -- [36] "or_bits"
            r = or_bits(a1, a2)
        case 38 then    -- [38] "shift_bits"
            r = shift_bits(a1, a2)
        case 39 then    -- [39] "rotate_bits"
            r = rotate_bits(a1, a2)
        case 40 then    -- [40] "gcd"
            r = gcd(a1, a2)
        case 45 then    -- [45] "rand_range"
            r = rand_range(a1, a2)
        case 48 then    -- [48] "chance"
            r = chance(a1, a2)
        case 49 then    -- [49] "roll"
            r = roll(a1, a2)
        case 50 then    -- [50] "compare"
            r = compare(a1, a2)
        case else
            return err_msg(ER_ILLEGAL_ARG, name)
    end switch

    return r
end function



-- PURPOSE: see calc_func_0().
function calc_func_x(sequence name, integer ix, sequence a)
    atom r
    integer len = length(a)

    if ix = 41 and len = 3 then     -- [41] "approx"
        r = approx(a[1], a[2], a[3])  -- (no error occurs if a[3] is negative)
    else
        return err_msg(ER_ILLEGAL_ARG, name)
    end if

    return r
end function



-- PURPOSE: calculate a function expression and return the result.
-- DETAILS: ix is the function index in FUNC_LIST.
--          'e' is arguments for function, separated by ",".
-- RETURN:  object; result atom or err_msg() string.
-- EXAMPLE: x = calc_func(25, {11, ",", 3})     --> x is 1331
-- SEEALSO: calc_func_0, calc_op, calc_unary_op, calc_expr
function calc_func(integer ix, sequence e)
    sequence name = FUNC_LIST[ix], a = arguments_to_sequence(e)

    if error_occurred then  -- arguments_to_sequence() error.
        return err_msg(ER_ILLEGAL_ARG, name)
    else
        switch length(a) do
            case 0 then
                return calc_func_0(name, ix)
            case 1 then
                return calc_func_1(name, ix, a[1])
            case 2 then
                return calc_func_2(name, ix, a[1], a[2])
            case else -- 3+ arguments:
                return calc_func_x(name, ix, a)
        end switch
    end if
end function



-- PURPOSE: calculate an operator expression and return the result.
-- DETAILS: 'e' is expression with two atoms & one operator, e.g. {5, "*", -1}.
-- RETURN:  object; result atom or err_msg() string.
-- EXAMPLE: x = calc_op({5, "*", -1.5})     --> x is -7.5
-- SEEALSO: calc_func, calc_unary_op, calc_expr
function calc_op(sequence e)
    sequence op = e[2]
    atom     r, a1, a2

    if atom(e[1]) and atom(e[3]) then
        a1 = e[1]
        a2 = e[3]
    else
        return err_msg(ER_SYNTAX_ERROR, op)
    end if


    -- calc operator and two atoms, e.g. {2, "*", 1.5}:
    switch find(op, OP_LIST) do -- [index] operator:
        case 1 then             --  [1] *
            r = a1 * a2
        case 2 then             --  [2] /
            if a2 = 0 then
                return err_msg(ER_DEV_BY_ZERO, op)
            else
                r = a1 / a2
            end if
        case 3 then             --  [3] +
            r = a1 + a2
        case 4 then             --  [4] -
            r = a1 - a2
        case 5 then             --  [5] <
            r = (a1 < a2)
        case 6 then             --  [6] >
            r = (a1 > a2)
        case 7 then             --  [7] <=
            r = (a1 <= a2)
        case 8 then             --  [8] >=
            r = (a1 >= a2)
        case 9 then             --  [9] =
            r = (a1 = a2)
        case 10 then            -- [10] !=
            r = (a1 != a2)
        case 11 then            -- [11] and
            r = (a1 and a2)
        case 12 then            -- [12] or
            r = (a1 or a2)
        case 13 then            -- [13] xor
            r = (a1 xor a2)
        case else
            return err_msg(ER_NOT_IMPLEMENTED, op)  -- helper for debug.
    end switch

    return r
end function



-- PURPOSE: calculate all cases of unary-/+ and "not" in expression, only if
--          the next item is an atom.
-- DETAILS: 'e' is expression, see example below.
-- RETURN:  sequence; modified expression.
-- NOTE:    cases such as -(...) or -func(...) are handled in calc_expr();
--          this function calculates atoms, e.g. '* - 15'; '( + 6'; etc.
-- EXAMPLE: s = calc_unary_op({"-", 5, "*", "-", "(", 6, "/", 2, ")"})
--            --> s is {-5, "*", "-", "(", 6, "/", 2, ")"}
-- SEEALSO: calc_expr, calc_op, calc_func
constant
    ST_CHRS = {"(", ","}
function calc_unary_op(sequence e)
    integer st, en,
            idx = 2,
            len = 1 + length(e)

    e = {"+"} & e       -- temporarily prepend an operator.

    -- calculate unary-/+/not and one atom each loop, e.g. {"*", "-", 15}:
    while idx < len do
        if sequence(e[idx]) then
            if find(e[idx], UNARY_OP_LIST) then
                st = idx - 1
                en = idx + 1

                if sequence(e[st]) and atom(e[en]) then
                    if find(e[st], OP_LIST & ST_CHRS) then
                        switch e[idx] do
                            case "-" then
                                e[en] = -e[en]
                            case "not" then
                                e[en] = not e[en]
                         -- case "+" then
                                -- just remove the sign.
                        end switch

                        -- remove the sign:
                        e = remove(e, idx)  -- ! Euphoria 3: e = e[1..st] & e[en..$]
                        len -= 1
                    end if
                end if
            end if
        end if

        idx += 1
    end while

    -- remove temporarily prepended operator:
    return tail(e)      -- ! Euphoria 3: return e[2..$].
end function



-- MAIN =====================================================================

-- PURPOSE: calculate a full expression and return the result.
-- DETAILS: 'e' sequence is returned by parse_expr().
-- RETURN:  sequence; result atom, e.g. {-2.5}; or err_msg() string.
-- NOTE:    expressions are evaluated from left-to-right, using Euphoria's
--          precedence order (see PRECEDENCE_LISTS constant).
-- EXAMPLE: s = calc_expr({1, "+", 2, "*", {FUNC_ID, 1}, "(", -11, ")"})
--            --> s is {23}
--                i.e. s is {1 + 2 * abs(-11)}
-- SEEALSO: parse_expr, math_eval, calc_op, calc_unary_op, calc_func
function calc_expr(sequence e)
    integer  st, en, idx
    object   obj


    -- make sure expression enclosed with parenthesis to get final result;
    e = {"("} & e & {")"}


    -- calculate all expressions found within parenthesis (precedence-1):
    while TRUE do

        -- find the most inner ")":
        en = find(")", e)
        if en = 0 then
            if find("(", e) then
                return err_msg("Missing ')'")
            else
                exit
            end if
        end if

        -- find the most inner "(":
        st = 0
        for i = en - 1 to 1 by -1 do
            if equal(e[i], "(") then
                st = i
                exit
            end if
        end for
        if st = 0 then
            return err_msg("Missing '('")
        end if


        -- calculate chunks of the expression according to precedence order;
        -- the idea is to shrink each chunk into atom, e.g. 5 * 10 --> 50:
        for precedence = 4 to 7 do
            idx = st + 1

            while idx < en do
                if atom(e[idx]) then    -- atom can't be operator...
                    idx += 1
                elsif find(e[idx], PRECEDENCE_LISTS[precedence]) then
                    obj = calc_op(e[idx - 1..idx + 1])

                    -- remove two atoms and operator; keep only new atom:
                    if atom(obj) then
                        -- ! Euphoria 3: e = e[1..idx - 2] & obj & e[idx + 2..$]
                        e = replace(e, obj, idx - 1, idx + 1)
                        en -= 2
                    else
                        return obj  -- return err_msg()
                    end if
                else
                    idx += 1
                end if
            end while
        end for -- precedence


        -- helper for debug:
        if not (equal(e[st], "(") and equal(e[en], ")")) then
            return err_msg(ER_BUG_IN_CODE, "calc_expr")

        -- first: calculate a function using the result atom(s), or
        --        calculate a function without arguments such as rnd():
        elsif st > 1 and sequence(e[st - 1]) and e[st - 1][1] = FUNC_ID then
            obj = calc_func(e[st - 1][2], e[st + 1..en - 1])

            -- remove the function-id and (); keep only result atom:
            if atom(obj) then
                -- ! Euphoria 3: e = e[1..st - 2] & obj & e[en + 1..$]
                e = replace(e, obj, st - 1, en)
            else
                return obj  -- return err_msg()
            end if

        -- then: operator result must be a single atom:
        elsif st + 2 = en and atom(e[st + 1]) then
            -- remove the () and keep only the result atom:
            -- ! Euphoria 3: e = e[1..st - 1] & e[st + 1] & e[en + 1..$]
            e = replace(e, e[st + 1], st, en)

        -- when only () remains:
        elsif st + 1 = en then
            return err_msg("Missing expression inside", "( )")

        -- invalid syntax returned inside ( ), e.g. "1not-2" or "(1not-2)":
        else
            if st = 1 then  -- the first '(' is prefixed to the expression.
                return err_msg(ER_SYNTAX_ERROR & " expression")
            else
                return err_msg(ER_SYNTAX_ERROR, "( )")
            end if
        end if


        -- finally, re-calc unary+/-/not for atoms, since the ( ) and
        -- function name removed, i.e. for -(1 + 2) or -abs(4), etc:
        e = calc_unary_op(e)

     end while  -- found expression within parenthesis

    return e
end function



-- PURPOSE: parse string expression into a sequence of initial arguments.
-- DETAILS: expr, var_names, var_values are same as in function math_eval().
--          get_id = TRUE used by get_identifiers() to keep identifier names.
-- RETURN:  sequence; sequence of arguments, or err_msg() string.
--           * if get_id = TRUE then arguments are only identifiers *names*.
-- EXAMPLE: s = parse_expr("( a + 5 * abs(c) )", {"a", "c"}, {11.2, -4})
--            --> s is {"(", 11.2, "+", 5, "*", {'@', 1}, "(", -4, ")", ")"}
-- SEEALSO: math_eval, get_identifiers, calc_unary_op, calc_expr,
--          string_to_number
function parse_expr(ascii_string expr, sequence var_names, sequence var_values,
                                                        boolean get_id = FALSE)
    integer  idx, chr, st, en, func_ix
    sequence str, e = {}, id = {}
    object   get_value
    atom     num


    -- NUL is end-of-string marker and placeholder for 'next-chr':
    expr &= NUL


    -- parse expression into sequence:
    idx = 1
    while TRUE do

        chr = expr[idx]

        -- first check for end-of-string marker:
        if chr = NUL then
            exit

        -- ignore and skip blanks and control characters ('\t', etc):
        elsif chr <= 32 or chr = 127 then
            idx += 1

        -- append parenthesis, comma, and symbolic operators:
        elsif find(chr, "(),*/+-=<>!") then
            if expr[idx + 1] = '=' and find(chr, "<>!") then
                -- append ambiguous operators "<=", ">=", "!=":
                e = append(e, chr & '=')
                idx += 2
            else
                e = append(e, {chr})
                idx += 1
            end if

        -- get and append number's value, e.g. 10.5 (# for hexadecimal):
        elsif (chr >= '0' and chr <= '9') or chr = '.' or chr = '#' then
            st = idx
            en = idx
            idx += 1
            while TRUE do
                chr = expr[idx]
                if (chr >= '0' and chr <= '9') or
                   (chr >= 'a' and chr <= 'z') or
                   (chr >= 'A' and chr <= 'Z') or chr = '.' or chr = '_' or
                   ((chr = '-' or chr = '+') and find(expr[idx - 1], "eE"))
                then
                    en = idx
                    idx += 1
                else
                    get_value = string_to_number(expr[st..en])
                    if atom(get_value) then
                        e = append(e, get_value)
                        exit
                    else
                        return err_msg("Invalid number", expr[st..en], st)
                    end if
                end if
            end while

        -- get and append variable's/constant's value, operator's string,
        -- and function's index:
        elsif (chr >= 'a' and chr <= 'z') or
              (chr >= 'A' and chr <= 'Z') or chr = '_'
        then
            st = idx
            en = idx
            idx += 1
            while TRUE do
                chr = expr[idx]
                if (chr >= 'a' and chr <= 'z') or
                   (chr >= 'A' and chr <= 'Z') or
                   (chr >= '0' and chr <= '9') or chr = '_'
                then
                    en = idx
                    idx += 1
                else
                    str = expr[st..en]

                    -- get_identifiers() keeps identifier name (not value):
                    if get_id then
                        id = append(id, str)

                    -- append the value of variable:
                    elsif find(str, var_names) then
                        num = var_values[find(str, var_names)]
                        e = append(e, num)

                    -- append the value of constant:
                    elsif find(str, CONST_LIST) then
                        num = CONST_LIST_VALUES[find(str, CONST_LIST)]
                        e = append(e, num)

                    -- append operator string ("and", "or", "xor", "not"):
                    elsif find(str, OP_LIST) then
                        e = append(e, str)

                    -- append the index of function, e.g. {'@', 15}:
                    else
                        func_ix = find(str, FUNC_LIST)
                        if func_ix then
                            e = append(e, {FUNC_ID, func_ix})
                        else
                            return err_msg("Invalid identifier", str, st)
                        end if
                    end if

                    exit
                end if
            end while

        -- unsupported character found, such as '&':
        else
            return err_msg("Invalid character", {chr}, idx)
        end if

    end while -- idx


    -- get_identifiers() needs only the identifiers names:
    if get_id then
        return id

    -- math_eval() needs the parsed expression:
    else
        -- do the initial unary+/-/not calculation for atoms, e.g. {"-", 15};
        -- note that -(1 + 2) or -abs(4), etc, is handled in calc_expr():
        e = calc_unary_op(e)

        return e
    end if
end function



-- PUBLIC FUNCTIONS =========================================================

-- PURPOSE: evaluate a math expression. see "math_eval.doc" user manual.
-- DETAILS: expr is any Euphoria math expression string - see example below.
--          use_deg is FALSE=Radians/TRUE=Degrees for trigonometry functions.
--          var is optional variables sequences {{...}, {...}}:
--           var[1] is var_names, it's the variable names;
--           var[2] is var_values, it's paralleled to var_names, as it is the
--           variable's value, which is an atom or a string-expression
--           representing an atom, e.g.:
--             var = { {"R", "Si"        , "tol", "fact"} --> [1] var_names
--                     {6  , "-(abs(-1))", 12.5 , ".3"} } --> [2] var_values
-- INPUT:   error_occurred
-- OUTPUT:  use_degrees
-- RETURN:  object; atom as result, or err_msg() string.
-- EXAMPLE: x = math_eval("( a + 5 * abs(c) )", 0, {{"a", "c"}, {11.2, -4}})
--           --> x is 31.2
--               i.e. x is (11.2 + 5 * abs(-4))
-- SEEALSO: get_identifiers, parse_expr, calc_expr, err_msg, set_local_variables
public function math_eval(ascii_string expr, boolean use_deg = FALSE,
                                            paralleled_seq var = {{}, {}})
    object e
    seq_of_strings var_names  = var[1]
    seq_of_values  var_values = var[2]

    set_local_variables(ON_ENTER)


    -- convert strings in 'var_values' to atoms, e.g. "-1.5*2" --> -3:
    for i = 1 to length(var_names) do
        var_names[i] = trim(var_names[i])   -- ( trim() works per *string* ).

        if find(var_names[i], FUNC_LIST & CONST_LIST & OP_LIST) then
            e = err_msg("Illegal variable name", var_names[i])
            exit

        elsif sequence(var_values[i]) then
            -- (this supports also previous variables in a string-expression):
            e = math_eval(var_values[i], use_deg, {
                head(var_names,  i - 1), -- ! Euphoria 3:  var_names[1..i - 1],
                head(var_values, i - 1)  -- ! Euphoria 3: var_values[1..i - 1]
            })

            if atom(e) then
                var_values[i] = e
            else -- e = err_msg(...):
                -- ! Euphoria 3: tail(e) is e[2..$]
                e = ERR_MSG_HEAD & "'" & var_names[i] & "': " & tail(e)
                exit
            end if
        end if
    end for


    if error_occurred then
        -- e = err_msg(...)

    -- parse 'expr' to its initial arguments:
    else
        e = parse_expr(expr, var_names, var_values)

        if error_occurred then
            -- e = err_msg(...)
        elsif length(e) = 0 then
            e = err_msg("Empty expression")

        -- calculate the expressions:
        else
            use_degrees = use_deg   -- output to local variable
            e = calc_expr(e)

            if error_occurred then
                -- e = err_msg(...)
            elsif length(e) = 1 then
                e = e[1]            -- the final result must be a single atom
            else
                e = err_msg(ER_BUG_IN_CODE, "math_eval")    -- helper for debug
            end if
        end if
    end if


    -- return atom as result; or error message string:
    set_local_variables(ON_EXIT)
    return e
end function



-- PURPOSE: extract alphanumeric identifiers from a string expression.
--          - it can be useful for getting variable names, which is the
--            default behavior, and prompt the user for their values.
-- DETAILS: expr is same as in function math_eval().
--          list is the identifier-list to return, or all of them.
-- INPUT:   error_occurred
-- RETURN:  sequence; A sequence of length two consisting of:
--             * an integer, the return status. This is any of:
--               GET_ID_SUCCESS   -- expression was read successfully
--               GET_ID_FAIL      -- expression is not syntactically correct
--
--             * - if GET_ID_SUCCESS: a sequence which contains 4 sub-sequences
--                 for each type of identifier; or a sequence which contains
--                 only one type of identifier. see public indexes below.
--               - if GET_ID_FAIL: err_msg() string.
-- EXAMPLE: s = get_identifiers("( PI / not a + 5 * abs(c) )", GET_ID_ALL)
--           --> s is {GET_ID_SUCCESS, {{"not"}, {"abs"}, {"PI"}, {"a", "c"}}}
-- SEEALSO: math_eval, parse_expr, set_local_variables
public constant
    -- return status integers:
    GET_ID_SUCCESS = 0,   -- expression was read successfully
    GET_ID_FAIL    = 1    -- expression is not syntactically correct
public constant
    -- return sequence indexes (list) - from 1 to 4:
    GET_ID_ALL       = 0,
    GET_ID_OPERATORS = 1,
    GET_ID_FUNCTIONS = 2,
    GET_ID_CONSTANTS = 3,
    GET_ID_VARIABLES = 4
public function get_identifiers(ascii_string expr, integer list = GET_ID_VARIABLES)
    sequence e, id = repeat({}, 4)
    object   str
    integer  idx

    set_local_variables(ON_ENTER)


    -- parse expression and keep the identifier names (not values):
    e = parse_expr(expr, {}, {}, TRUE)


    -- id is err_msg():
    if error_occurred then
        id = {GET_ID_FAIL, e}

    -- id is identifiers list(s):
    else
        e  = remove_dups_inplace(e)     -- remove duplicate identifiers

        -- store identifier names in 'id':
        for i = 1 to length(e) do
            str = e[i]

            if find(str, OP_LIST) then          -- operator name, e.g. "or"
                idx = GET_ID_OPERATORS
            elsif find(str, FUNC_LIST) then     -- function name, e.g. "abs"
                idx = GET_ID_FUNCTIONS
            elsif find(str, CONST_LIST) then    -- constant name, e.g. "PI"
                idx = GET_ID_CONSTANTS
            else                                -- variable name, e.g. "xyz"
                idx = GET_ID_VARIABLES
            end if

            id[idx] = append(id[idx], str)      -- append identifier to list
        end for

        -- id is all lists, or just a single list:
        if list != GET_ID_ALL then
            id = id[list]
        end if

        id = {GET_ID_SUCCESS, id}
    end if


    -- return success or fail sequence:
    set_local_variables(ON_EXIT)
    return id
end function



-- End of file.
