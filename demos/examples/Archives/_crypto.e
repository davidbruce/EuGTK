
--# crypto.e

-- Program to encrypt / decrypt files by means of a simple xor_bits method
-- Author: R. M. Forno - Contact him at ricardoforno@tutopia.com
-- Version 0.1 - 2006/12/30

-- Usage is the same for both encrypting and decrypting.
-- The key string should be the same for both tasks
-- If the key string contains spaces, please use " to enclose it

-- Modified to work with EuGTK and Eu 4.1
-- Mar 10, 2018
-- Irv Mullins

include std/rand.e

constant MAX = 16777215 -- 2^24 - 1

sequence Bytes

---------------------------------------
function OneCyclePermutation(integer n)
---------------------------------------
    sequence s, p
    integer r, h, m
    s = repeat(0, n)
    p = s
    for i = 1 to n do
	s[i] = i
    end for
    r = 1
    h = 1
    while n do
	s[r] = s[n]
	n -= 1
	if n = 0 then
	    exit
	end if
	r = rand(n)
	m = s[r]
	p[h] = m
	h = m
    end while
    p[h] = 1
    return p
end function

--------------------------------
function scramble(sequence s) -- Scrambles s as to be unrecognizable
--------------------------------
    integer len, a, b, k, h
    a = 0
    b = 0
    len = length(s)
    for i = 1 to len do
	a += s[i]
	a = and_bits(a, MAX)
	b += a
	b = and_bits(b, MAX)
    end for
    set_rand(b + 1)
    Bytes = OneCyclePermutation(256)
    for i = 1 to len do
	s[i] = Bytes[s[i] + 1]
    end for
    for i = 1 to len * (10 + rand(10)) do
	k = remainder(i + rand(len), len) + 1
	h = remainder(i, len) + 1
	s[k] = Bytes[s[h]]
    end for
    return s
end function

-----------------------------------------
export procedure crypto(object data) -- Main procedure
-----------------------------------------
    sequence table
    integer fo, fi, k, len, c, code, t
    fi = open(data[1],"rb")
    fo = open(data[2],"wb")
    data = scramble(data[3])
    table = repeat(0, 32)
    for i = 1 to 32 do
	table[i] = rand(255)
    end for
    len = length(data)
    k = 1
    code = 0
    t = 0
    while 1 do
	c = getc(fi)
	if c < 0 then
	    exit
	end if
	code = data[k]
	t = and_bits(t, 31) + 1
	table[t] = Bytes[and_bits(code + table[and_bits(t + rand(255), 31) + 1], 255) + 1] 
	data[k] = table[t]
	c = xor_bits(c, code)
	puts(fo, c)
	k += 1
	if k > len then
	    k = 1
	end if
    end while
    close(fo)
    close(fi)
end procedure
