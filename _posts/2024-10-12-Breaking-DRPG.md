---
title: "Breaking DP-RPG's Asset Encryption"
description: "Getting Disney Pixel RPG's asset encryption key"
date: 2024-10-12T22:00:00-04:00
categories:
  - Reverse Engineering
tags:
  - IDA
  - DP-RPG
  - IL2CPPDumper
  - Encryption
classes: wide
header:
  og_image: /assets/images/drpg-enc/Title_logo.jpg
---

Recently, a few of my programmer friends started getting into the new Disney Pixel RPG gacha game that came out. I personally don't care for gacha games that much nowadays, but I'm always just curious about how these games work behind the scenes. So, I did what I always do with these sort of games, and try to mitm the network traffic using [Mitmproxy](https://mitmproxy.org/). Little did I know this would cause me to break an encryption system on my own for the first time.

# Chapter 1: Setup

## Failing with Android

The game was available to download on Oct 6th, but the actual server would launch the next day. When it comes to analyzing mobile games, I look at the Android version first since I have more experience with tools for that platform. I downloaded the APK online to take a look at some of the assets. A friend that looked at it before me said that the game was using Unity with the IL2CPP runtime (pretty standard nowadays.) They also mentioned that there is a `Lib__6dba__.so` inside the binaries, which is apparently some version of CrackProof protection.

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011120745.png" alt="">

Well hmm that's annoying. CrackProof makes things like editing the APK really annoying, so using something like [apk-mitm](https://github.com/niklashigi/apk-mitm) was out of the window. Quite a few people also reported that the game would crash for as little as having USB Debugging enabled in Developer Settings (Apparently this was fixed in an update?). Either way, I decided just to look at the IL2CPP info first to see what I can get. Let's just see what [IL2CPPDumper](https://github.com/Perfare/Il2CppDumper) can do.

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011115603.png" alt="">

Well that's just wonderful. It seems that `libil2cpp.so` has been obfuscated in some way by CrackProof. Guess it might be worth trying to run this game in a emulator to runtime dump it...

I have a rooted WSA install on my PC. After wasting time formatting the emulator storage due to a corruption issue and setting up all my tools again, it turns out that the game just crashed. Is it a root detection issue? Emulator detection? WSA fault? I have no clue and gave up on this endeavor pretty quickly. I felt that trying to defeat the protection on the Android side would be a waste of time. So time to switch to my secondary plan: iOS.

## Progress with iOS

I have an iPad that's on iOS 16 with [TrollStore](https://github.com/opa334/TrollStore) on it. While TrollStore is not a full jailbreak, it still allows us to dump decrypted iOS executables for reverse engineering. I went to download the app from the App Store and...

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011131340.png" alt="">

Well wonderful. The developers made it so that you can't install the app on anything less that iOS 17, which seems strangely new. While there is TrollStore available on iOS 17, it's only for very specific versions and I didn't want to risk updating my iPad, so I decided to look for another solution for getting a decrypted executable. I remembered that there were Telegram channels that actually offered decryption services for iOS apps, and I was able to find @eeveedecrypterbot for getting an IPA with the decrypted IPA. With this, I would be able to use IL2CPPDumper this time and look at some of the classes and methods using [DnSpy](https://github.com/dnSpy/dnSpy).

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011144901.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011144814.png" alt="">

Perfect! Seems like there is no protections on the IL2CPP on iOS, so we can gather a lot of info from this.

But not only that, I could also sideload the decrypted IPA to make it work on my iPad. All I needed to do is edit the `MinimumOSVersion` entry in the `Info.plist` file, put it back into the IPA, then sideload the game using TrollStore. The game works perfectly on here, so I assume they only made the app iOS 17 just to avoid jailbreaks on older versions of iOS.

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011144338.png" alt="">

Nice! Now we are ready for when the game launches to use Mitmproxy on the iOS version. We just need to wait until the servers officially launch.

# Part 2: Man in the Middle

With Mitmproxy, it was very easy to see all the traffic that the game sent to the API server. The API used standard msgpack with keys still attached. There was no certificate pinning or encryption that can be seen here so that makes things quite a bit more simpler. One of the endpoints of interest to me was `api/init/get_version` which would return the addressable JSONs for the latest version.

{insert image of mitm packet}

I went to look at the file to find the download links that the game uses, but when I went to look at the bundle used for the master files of the game, it turns out it was encrypted as the UnityFS header was missing. Interestingly, only some of the bundles were actually encrypted. Some of them still had the standard Unity header and could be loaded in tools such as [AssetStudio](https://github.com/Perfare/AssetStudio), but assets for the characters, enemies, and master files were encrypted with some of them having `enc` in the file name.

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011151256.png" alt="">

But this gave me a new challenge to tackle for fun. Might as well try to break the assets while I'm at it with the MITM.

# Part 3: Actual RE time

While IL2CPPDumper's DummyDLLs are super helpful in terms of giving some basic info when it comes to functions names and arguments, that's all it really gives. No code is extracted so it can still be pretty limiting especially in this case as there was no simple "encrypt" or "decrypt" function. So I needed a bit more of a powerful tool to actually look at the code, and that's where IDA comes in. With the iOS executable loaded in IDA, I could run a python script that comes with IL2CPPDumper to add all the function and string info from the global-metadata.dat file. This is super useful as without this, I would need to go through an insane amount of functions with little info.

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011174215.png" alt="">

Now that we have both the function names and some pseudocode, time to get digging...
I first started looking at the `ALFramework` namespace as it had a `ALAddressableAssetLoader` class which seemed close to what I need. There are a lot of functions like `GetText`, `GetTexture2D`, etc. But I couldn't see any sort of code related to decryption. I also noticed that when looking at some of the raw assets, there was an encrypted config file for something called `Chronos` and I thought that my have something like the asset encryption key, but after a bit of looking in DnSpy, it didn't seem that config would contain what I need. Overall, I spent almost an entire day just looking at stuff that didn't help get anywhere closer to how the asset encryption actually worked.

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011174928.png" alt="">

After a while, I started to retrace my steps and went back to the addressable JSON to see if I could get more info from there. But then I saw something interesting...

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011175157.png" alt="">

`UnityEngine.ResourceManagement.ResourceProviders.AESStreamProcessor`?? Huh???
This is the first time I've ever seen some sort of AES encryption for assets in the `UnityEngine` namespace. Usually developers make their own functions in the normal Assembly-Csharp DLL, but this time, I actually had to look into some `UnityEngine` functions. I wonder if the developers have Unity's source code to be able to do something like this at a deep level. 🤔
But I digress, time to get back to RE. So now that we know where to look, I started to notice some interesting functions in two different areas: In `Assembly-Csharp.dll`, there is an `AddressableTangle` class, while in `Unity.ResourceManager`, there are also a few functions related to keys.

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/image.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/image-1.png" alt="">

I looked at the `.cctor` first and saw some interesting stuff. It seems that it loads a hardcoded string into the `data` byte by base64 decoding it first, and fills out `key`, `order`, and `IsPopulated` with some values. This is definitely the initialization for the key we need. The string that was loaded kind of looks like an AES key already, but I already tried to use it for AES decryption and it didn't work. I also tried just base64 decoding the string in [CyberChef](https://gchq.github.io/CyberChef/), but got some weird looking data. So more digging is needed.

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011181240.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011181506.png" alt="">
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011182124.png" alt="">

Let's look at the `Data` method next. Seems like this just calls the `DeObfuscate` method in the `UnityEngine` DLL once the info is filled out.
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011181443.png" alt="">

So what about that method then? Let's see...
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011181630.png" alt="">

Ah, well it seems like this method just does a lot of math and array movement to get the key...
I didn't understand what a lot of this was doing without spending a lot more time, and I wasn't sure if I wanted to to be honest, but I hopped on a call with a few of my programmer friends and showed them what I found. One of them suggested that the code could be some sort of XOR algorithm, which didn't seem to farfetched. So I tried using CyberChef's XOR Brute Force and got some results that looked like proper keys.
<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011182245.png" alt="">

Since there weren't many of these, I decided to just try brute forcing using what I already know. I know that it has to be AES encryption, and there is no reference to an IV, so I just started running through the brute forced keys, switching between different AES modes and...

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011182408.png" alt="">

Success! We got a perfect decryption! We can now look at the assets that they wanted to hide from us 😉

<img src="{{ site.url }}{{ site.baseurl }}/assets/images/drpg-enc/Pasted image 20241011183006.png" alt="">

Honestly I was really proud with this result. Even if it's not the most complex system in the world, I was happy that I was able to find and crack the encryption for this game almost entirely on my own, even if I did need to some help near the end 😅
I did feel myself getting a lot better at IDA with this though :>

Maybe I should try cracking the Chronos file next...