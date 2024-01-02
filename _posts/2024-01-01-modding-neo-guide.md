---
title: "Guide for modding NEO TWEWY's assets"
date: 2024-01-02T15:34:30-04:00
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
1. This guide focuses on modding the base assets of the game. The steps here should theoretically work across all 3 versions on PS4, Switch, and PC. But for PS4 and Switch, you will need to figure out how to extract and modify the NSP and PKG files on your own. There are other guides for how to do this online.
2. This is a Windows based guide, so you'll need a PC to create your own mods.

# Pre-requisites
Before starting, you'll need to install a list of required and recommended programs:
1. [UABEA][UABEA] for modifing the Unity bundle files (Required)
2. [Scramble Save Editor][Scramble] (Required for PC)
3. [OpenSSL][OpenSSL] (Required for PC)
4. [AssetStudio][AssetStudio] (Not required but highly recommended)
5. [WannaCRI][WannaCRI] (For creating custom USM files)

# Modifing Unity AssetBundles
The .unity3d files in `NEO The World Ends with You_Data\StreamingAssets\Assets` contain the vast majority of assets the game uses, from models ot text files. Pretty much anything except pre-rendered cutscenes and audio can be changed from here.
## Step 0: Decrypt the AssetBundles (PC Only)

If you are modding the PS4 or Switch versions of the game, **you can skip this step** since those versions don't use encryption on the assets.
{: .notice--warning}

On PC, NEO's AssetBundles are encrypted using an AES key and IV. The good news is that the Scramble save editor can decrypt all the files in a few minutes.
1. After downloading the newest release from Github, extract and run `Scramble.exe`.
2. You will see a `asset decrypt & re-encrypt"` button. Click it and navigate to `NEO The World Ends with You_Data\StreamingAssets\Assets` folder. Select all the files in folder and click open.
3. You will be asked to select a new folder where Scramble will dump all the decrypted AssetBundles. Pick a folder of you choosing and wait until Scramble decrypts the files. (This can take a while if you selected a lot of files.
Once the decryption is finished, a prompt saying "Done." will appear.

## Step 1: Figure out which bundles to modify
Although AssetStudio is not required for this, it's highly recommended as it extracts all the assets to memory temporarily and gives you useful preview and filtering tools. This makes the process way of finding which files to change way quicker.
1. Download and extract the latest release of AssetStudio. Drag and drop your decrypted .unity3d files on AssetStudio's window after running the exe. Wait for a bit while AssetStudio extracts everything to memory.
2. Once AssetStudio shows a list of scenes, select `Asset List` and explore around for while to find what you want to change.
3. Once you know which files you want to modify, right click on the asset and select `Show original file`. Make note of the name of the .unity3d file for later.

As expected, NEO has a *bunch* of files. Use AssetStudio's search and Filter Type features to find the files you want to change quickly. The more you use it, the quicker you will learn.
{: .notice--success}

## Step 2: Modify the AssetBundles
Once you know which .unity3d files you need to edit, you will need to open them in UABEA.
1. Run `UABEAvalonia.exe` and drag the .unity3d files you want to modify on the window. UABEA will ask you if you want to decompress the file to a new file or memory. It's recommended to select memory if your PC can handle it.
2. Once the file is decompressed, select the `Info` button to see the list of files in the bundle. UABEA can let you edit some basic files using the `Edit Data` button, but for other files, you will need to extract a dump first, edit the file in other program, then reimport the file using UABEA.
3. After editing the bundle with new assets, save it by clicking `File->Save` or using Ctrl+S.
4. Close out of the asset info window, and `File->Save As` to a new unity3d file.

UABEA also supports compressing the AssetBundles. While this is not required to for the game to run modifed files, *it's recommended to save on space*. UABEA will tell you to open the new modified unity3d file before using the compress feature.
{: .notice--success}

## Step 2.5: Re-encrypt the modifed AssetBundles (PC Only)

As with step 0, this is only needed for the PC version. **Skip this step** if you are modding the console versions.
{: .notice--warning}

Although Scramble claims it supports re-encrypting NEO's files, this feature usually fails with modified files in my experience. You can try it on your own, but if it doesn't work then you will need to use OpenSSL.
{: .notice--danger}

For this step, we'll be using OpenSSL

[UABEA]: https://github.com/nesrak1/UABEA
[Scramble]: https://github.com/supremetakoyaki/Scramble
[WannaCRI]: https://github.com/donmai-me/WannaCRI
[AssetStudio]: https://github.com/Perfare/AssetStudio
[OpenSSL]: https://wiki.openssl.org/index.php/Binaries
[OpenSSL-Script]: 
