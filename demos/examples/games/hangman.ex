
------------------------------------------------------------------------
--# Turn over the letters and guess the word game.
------------------------------------------------------------------------
-- This demo uses Junko Miura's words.txt file

include GtkEngine.e
include GtkEvents.e
include std/io.e

------------------------------------------------------------------------
-- variables;
------------------------------------------------------------------------
integer max_tries, ct = 0

sequence words = read_lines(locate_file("resources/words.txt"))

object avail, blanks, current_word

------------------------------------------------------------------------
-- interface;
------------------------------------------------------------------------
constant win = create(GtkWindow, -- the main window;
    "border=10,position=1,$destroy=Quit,$key-press-event=LetterSelected")

constant panel = create(GtkBox,1)
	add(win,panel)

constant display = create(GtkLabel) -- for word being guessed;
	set(display,"font","bold 24")
	add(panel,display)

constant lbl1 = create(GtkLabel,"Guess the word") -- for status;
	set(lbl1,"font","8")
	add(panel,lbl1)

constant grid = create(GtkGrid) -- to display button set;
    add(panel,grid)
    set(grid,"row spacing",2)
    set(grid,"column spacing",1)

object letters = series('a',1,26) -- build an array of buttons;
integer x = 1, y = 3, z = 0

    for i = 1 to length(letters) do -- load the letter button grid;
        letters[i] = create(GtkButton,sprintf("_%s",letters[i]),"LetterSelected",letters[i])
        set(letters[i],"border",0) set(letters[i],"margin",0)
        set(grid,"attach",letters[i],x,y,1,1)
        x += 1 
        if x > 13 then -- move to next line;
            x = 1 y += 1 
        end if 
    end for

new_word()  -- on startup, get a random word and initialize counters;

show_all(win)
main()

------------------------------------------------------------------------
procedure new_word() -- selects a random word, resets available letters;
------------------------------------------------------------------------
    current_word = words[rand(length(words))] 
    avail = series('a',1,32,'+')        -- set of {'a'...'z'}
    blanks = repeat('_',length(avail))  -- to hide unguessed letters;
    ct = 0                              -- number of tries;
    max_tries = 2 * length(current_word)-- number of tries allowed;

    set(display,"markup",FormatWord(current_word)) 

    for i = 1 to length(letters) do         -- reset colors;
        set(letters[i],"background","white")
        set(letters[i],"sensitive",TRUE) 
    end for
    
end procedure

------------------------------------------------------------------------
global function LetterSelected(atom ctl, atom event) -- event handler;
------------------------------------------------------------------------
integer key

-- this function is linked to both keypresses and button clicks, 
-- so we first need to determine which happened;

    if is_in_range(event,{'a','z'}) then key = event -- button was clicked;
    else  key = events:key(event)                    -- was keyboard input;
    end if

    if is_in_list(key,avail) then -- if in set of unused letters
        ct += 1                 -- new guess counts;
        set(letters[key-'a'+1],"sensitive",FALSE) -- used

        if find(key,current_word) > 0 then
            set(letters[key-'a'+1],"background","green") -- used in word
            Beep()
        else  
            set(letters[key-'a'+1],"background","yellow")-- not in word
        end if

        avail = remove_all(key,avail) -- remove the letter from available set;

        set(display,"markup",FormatWord(current_word))

        if ct > max_tries then -- too many tries, give up;
            if Question(win,"Sorry",
                sprintf("The word was <span color='red'>%s</span>",{current_word}),
                "Play again?") = MB_YES then
                new_word()
            else abort(0)
            end if
        end if

    end if

return 1
end function

---------------------------------------------------------------------------
function FormatWord(object word) -- handles display and testing for a win;
---------------------------------------------------------------------------
object result = ""

    set(lbl1,"text",sprintf("%d letter word,\n%d guesses left.",
        {length(current_word),max_tries-ct}))

-- change 'unguessed' letters to underscores,       
-- using the still un-tried letters remaining;
    word = transmute(word,avail,blanks) 

-- add spaces between letters (looks better!);
    for i = 1 to length(word) do
        result &= word[i]  & ' '
    end for

-- if no hidden letters are left, the puzzle is solved!
    if not find('_',word) then          
        set(display,"markup",sprintf("<span color='green'>%s</span>",{result})) 

        if Question(win,"Congratulations!",current_word,
            sprintf("You guessed it in %d tries!\nYou get <b>%d</b> points!\nPlay again?",
            {ct,100*(length(current_word)/ct)})) = MB_YES then
                new_word()
                return FormatWord(current_word)
        else
            Info(win,"Thanks!","Thanks","Please play again sometime")
            abort(0)
        end if

    end if

return result
end function


