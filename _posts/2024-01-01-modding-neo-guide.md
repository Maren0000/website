---
title: "Guide for modding NEO TWEWY"
date: 2024-01-01T15:34:30-04:00
categories:
  - Tutorial
tags:
  - NEO TWEWY
  - TWEWY
  - Modding
toc: true
toc_label: "NEO Modding"
toc_icon: "cog"
---

For a long while, no one has made a good documentaion on how to mod NEO. I decided that I should make one so that hopefully more people get the chance to make some new and interesting content for the game.
A few things to note:
1. This guide focuses on modding the base assets of the game. The steps here should theoretically work across all 3 versions on PS4, Switch, and PC. But for PS4 and Switch, you will need to figure out how to modify the NSP and PKG files on your own. There are other guides for how to do this.
2. This is a Windows based guide, so you'll need a PC to create your own mods.

# Prerequisites
Before starting, you'll need to install a list of required and recommended programs:
1. UABEA for modifing the Unity bundle files (Required)
2. Scramble Save Editor (Required for PC)
3. OpenSSL (Required for PC)
4. AssetStudio (Not required but highly recommended)
5. WannaCRI (For creating custom USM files)

# Modifing Unity AssetBundles
The Unity AssetBundles in the `NEO The World Ends with You_Data\StreamingAssets\Assets` contain the vast majority of files the game uses, from models ot text files. Pretty much anything except pre-rendered cutscenes and audio can be changed from here.
## Step 0: Decrypt the AssetBundles (PC Only)


[UABEA]: https://github.com/nesrak1/UABEA
[Scramble]:   https://github.com/supremetakoyaki/Scramble
[WannaCRI]: https://github.com/donmai-me/WannaCRI
