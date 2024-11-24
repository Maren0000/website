---
title: "First CTF Experience!"
description: "Trying out a CTF competition"
date: 2024-11-23T20:00:00-04:00
categories:
  - CTF
tags:
  - CTF
  - Crypto
  - Competition
  - Reverse Engineering
classes: wide
---

A few days ago, I was informed that HackTheBox would run a CTF specifically for university students in my college. I've never tried a CTF compeition beofre so I thought this would be a perfect opportunity to try it for the first time! I made my account just a few hours before the start of the CTF. Since I found out about this literally a day before it started, I didn't any time to prepare, but overall I'm happy with the performance I put up considering I was doing this (mostly) on my own vs. mostly teams of 2/3 members. Here's the flags that I was able to figure out on my own:

# First Category: Reversing
The first category had two reversing challenges.
## Spelunking:
For the first challenge, I was given a Linux executable. First thing that came to my mind is to analyze the executable in IDA to see what we were to working with. Loaded up the file and went to look at strings...
<img src="/assets/images/Pasted image 20241123165523.png" alt="">

Well that was easy lol. Can you get this flag through running the file? idk since I didn't even try lol
Anyways first flag got!

## Uncoding:
Just like the last challenge, all that was provided here was a single Linux executable. I looked at it in IDA for a bit but there wasn't an easy string to find this time around. I also tried running the executable:
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123172937.png" alt="">

Hmm well let's take a look at some of the functions in IDA.
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123173045.png" alt="">

So it seems that the messages themselves are encrypted using what seems like a XOR cipher.  Originally I thought to actually copy all the bytes manually from IDA and figure out the decryption manually, but when speaking with a few members from my college's cybersecurity club about this flag, I was told that Ghidra could actually be used to patch the if check. That seems like a much easier solution, so I looked up if something similar existed for IDA and it was pretty easy! Just had to find the value in the hex and edit it, then apply the patch and run the new executable.
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123173658.png" alt="">

Succuss! Second flag down!

# Second Category: Crypto
Another set of two challenges were in the crypto section. We were provided with Python scripts and output files for both.
## based0x:
First challenge was very simple. All the python script did was base64 encode the flag multiple times and output it as hex
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123175727.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123175913.png" alt="">

Done! Third flag found!

## Repeated Maleficence:
This one took me way too much time for how easy it should have been to be honest. 
The Python file gives us a hint that the chipertext file is XOR encoded:
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123180131.png" alt="">

The big issue is that the key is randomized, but we do have the key length which is useful for XOR. At first, I spent a ton of time just trying to use brute force tools to see if they could help, but none of the scripts I would find online would really help with cracking this one. Eventually, I had to find someone else's writeup for a different CTF where they mentioned having to manually get parts of the key using the known characters of the flag. Every flag has started with `HTB{` so far, so I went on to dcode to manually recover the first 4 characters of the key and used a random character for the last one.
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123180714.png" alt="">

Getting very close now...
At first I was doing something really dumb and manually guessing what the last character could be, but then I realized that the first character of the actual flag was supposed to be x
So I just used the same method to recover the last character of the key.
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123180904.png" alt="">

Wasted a bit more time than I would have wanted, but whatever. Fourth flag found!

# Third Category: Pwn
Just like the last two, there were also two pwn challenges to deal with. We were provided with the executables locally but with fake flags. The real flags were on hosted docker containers.
## Riddle
After learning how to connect to the dockers using netcat, it was pretty easy to figure this first pwn challenge. Simple int32 overflow problem:
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Screenshot 2024-11-23 152553.png" alt="">

Fifth flag found!

## Gate
I couldn't actually get this flag before the end of the CTF, but I still wanted to document what I found for another time since I felt that I got pretty close. For this one, the executable I got had a hidden function that would not be called through main at all. I did notice however that the fgets statement at line 38 had a maximum length bigger than the actual buffer (30 vs. 8). I'm sure you had to do buffer overflow to access the hidden function. Unfortunately I couldn't get a GDB setup working in time, so I couldn't really experiment much with this one. But once I have a proper setup working, I do want to come back to this challenge as I do want to learn runtime exploitation.
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123182421.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123182510.png" alt="">

# Fourth Category: Forensics
Both of the forensics challenges had Wireshark pcap files to go through.
## Capture 1:
Started from bottom to top since I thought that would be more efficient. I copied whatever seemed like it could have useful. There was an interesting base64 string in the last few packets that contained the flag.
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123183117.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123183132.png" alt="">

And then we just need to base64 decode the comment
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123183143.png" alt="">


Sixth flag found!

## Capture 2:
For the second capture, we had a file browser server to login into. I used the same strategy as before of just going through the pcap file to find anything useful.
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Screenshot 2024-11-23 152236.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123183523.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Screenshot 2024-11-23 152335.png" alt="">

Once we have the login details, we can just login to get our flag.
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Screenshot 2024-11-23 152406.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Screenshot 2024-11-23 152419.png" alt="">

Seventh flag found!

# Fifth Category: Web
The last category I focused on was the web category that were hosted in docker containers. Like the pwn challenges, we were given the source files with a dummy flag, while the real flag was on the hosted servers. There were 5 total challenges here but I only had time to look at 4 of them.

## Potent Quotes
This first page was just a simple login. Looking at the code, it was pretty easy to figure out that the admin account was what I needed to get into, and a bit of SQL injection would do the trick.
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Screenshot 2024-11-23 151708.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123184122.png" alt="">

Using ' or '1'='1 as the password would bypass the password check entirely
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Screenshot 2024-11-23 151726.png" alt="">

Eight flag found!
## Game Capsule
This one was similar to the last one of having to get into a specific account to show the flag, but this time it was with a JWT token. (and featuring bad AI images)
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Screenshot 2024-11-23 151757.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123184539.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123184605.png" alt="">

Simply copying the random cookie in my browser to Cyberchef and using the JWT modules to edit the username worked for this
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Screenshot 2024-11-23 151826.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Screenshot 2024-11-23 151849.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Screenshot 2024-11-23 151928.png" alt="">

Ninth flag found!

## Newsletter site
Honestly this one was a bit *too* easy. The site pretty much told you what you had to do right away
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Screenshot 2024-11-23 152109.png" alt="">
As the site says, just using an XSS alert showed the flag. One quick google search and I was able to get the flag.
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Screenshot 2024-11-23 152153.png" alt="">

I don't think I even downloaded the files for this one lol. Tenth flag found!

## Cupcake Magdalena
Another flag that I tried to get for a while but couldn't in time, but will still do a writeup on for future reference. I don't have screenshots for this one, but the site was a very simple shopping site with a review system. The source files show that there is a bot setup using puppeteer that would get triggered every time you add a review, and would contain a cookie with the flag. It turns out you had to XSS to be able to steal the cookie from that bot. I didn't actually realize that getting that cookie would be simple one line tbh.

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123185510.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/Pasted image 20241123185454.png" alt="">


# Conclusion
Out of the 15 flags, I was able to get 10 of them before the CTF ended. Although I wish I could have gotten the 2 flags that I was stumped on, I'm still quick happy with this first performance. I'm not a hyper competitive type, so I don't really care about being on top. Just learning these new skills alone was honestly a pretty fun experience. Hopefully I will be able to sign up to some more CTFs with a couple other people in my college in the future.