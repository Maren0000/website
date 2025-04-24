---
title: "Guide for modding NEO TWEWY's assets"
description: "Short guide for modifing NEO's Unity3d and USM files"
date: 2024-01-01T15:34:30-04:00
last_modified_at: 2024-01-05T16:16:00-04:00
categories:
  - Tutorial
tags:
  - NEO TWEWY
  - TWEWY
  - Modding
toc: true
toc_label: "NEO Modding"
toc_icon: "cog"
header:
  og_image: /assets/images/neo-modding-guide/neo_logo.jpg
gallery:
  - url: /assets/images/neo-modding-guide/text_example.png
    image_path: /assets/images/neo-modding-guide/text_example.png
    title: "Text replacement"
  - url: /assets/images/neo-modding-guide/texture_example.png
    image_path: /assets/images/neo-modding-guide/texture_example.png
    title: "Texture replacement"
  - url: /assets/images/neo-modding-guide/map_example.png
    image_path: /assets/images/neo-modding-guide/map_example.png
    title: "MasterData replacement"  
---

It seems no one has made any good documentaion on how to mod NEO yet, so I decided to make a guide myself for the rest of the community. Hopefully this will lower the barrier of entry and more people get interested in modding NEO.

{% capture notice-text %}
* This guide focuses on modding the base assets of the game. The steps here should theoretically work across all 3 versions on PS4, Switch, and PC. But for PS4 and Switch, you will need to figure out how to extract and modify the NSP and PKG files on your own. There are other guides for how to do this online.
* This is a Windows based guide, so you'll need a PC to create your own mods.
{% endcapture %}

<div class="notice--info">
  <h4 class="no_toc">A few things to note:</h4>
  {{ notice-text | markdownify }}
</div>

{% include gallery id="gallery" layout="half" caption="A few examples of what can be done with asset replacements." %}

# Pre-requisites
Before starting, you'll need to install a list of required and recommended programs:
1. [UABEA][UABEA] for modifing the Unity bundle files (Required)
2. [Scramble Save Editor][Scramble] (Required for PC)
3. [OpenSSL][OpenSSL] (Required for PC)
4. [AssetStudio][AssetStudio] (Not required but highly recommended)
5. [WannaCRI][WannaCRI] (For creating custom USM files)

# Modifing Unity AssetBundles
The .unity3d files in `NEO The World Ends with You_Data\StreamingAssets\Assets` contain the vast majority of assets the game uses, from models to text files. Pretty much anything except pre-rendered cutscenes and audio can be changed from here.
## Step 0: Decrypt the AssetBundles (PC Only)

If you are modding the PS4 or Switch versions of the game, **you can skip this step** since those versions don't use encryption on the assets.
{: .notice--warning}

On PC, NEO's AssetBundles are encrypted using an AES key and IV. The good news is that the Scramble save editor can decrypt all the files in a few minutes.
1. After downloading the newest release from Github, extract and run `Scramble.exe`.
2. You will see a `asset decrypt & re-encrypt` button. Click it and navigate to `NEO The World Ends with You_Data\StreamingAssets\Assets` folder. Select all the files in folder and click open.
3. You will be asked to select a new folder where Scramble will dump all the decrypted AssetBundles. Pick a folder of your choosing and wait until Scramble decrypts the files. (This can take a while if you selected a lot of files.)
Once the decryption is finished, a prompt saying "Done." will appear.

## Step 1: Figure out which bundles to modify
Although AssetStudio is not required for this, it's highly recommended as it extracts all the assets to memory temporarily and gives you useful preview and filtering tools. This makes the process way of finding which files to edit way quicker.
1. Download and extract the latest release of AssetStudio. Drag and drop your decrypted .unity3d files on AssetStudio's window after running the exe. Wait for a bit while AssetStudio extracts everything to memory.
2. Once AssetStudio shows a list of scenes, select `Asset List` and explore around for while to find what you want to change.
3. Once you know which files you want to modify, right click on the asset and select `Show original file`. Make note of the name of the .unity3d file for later.

As expected, NEO has a *bunch* of files. Use AssetStudio's search and Filter Type features to find the files you want to change quickly. The more you use it, the quicker you will learn how to look for specific files.
{: .notice--success}

## Step 2: Modify the AssetBundles
Once you know which .unity3d files you need to edit, you will need to open them in UABEA.
1. Run `UABEAvalonia.exe` and drag the .unity3d files you want to modify on the window. UABEA will ask you if you want to decompress the file to a new file or memory. It's recommended to select memory if your PC can handle it.
2. Once the file is decompressed, select the `Info` button to see the list of files in the bundle. UABEA can let you edit some basic files using the `Edit Data` button, but for other files, you will need to extract the file through `Plugins` first, edit it in other program, then reimport the file using `Plugins` again.
3. After editing the bundle with new assets, save it by clicking `File->Save` or using Ctrl+S.
4. Close out of the asset info window, and `File->Save As` to a new unity3d file.

UABEA also supports compressing the AssetBundles. While this is not required to for the game to run modifed files, *it's recommended to save on space*. UABEA will tell you to open the new modified unity3d file before using the compress feature.
{: .notice--success}

## Step 2.5: Re-encrypt the modifed AssetBundles (PC Only)

As with step 0, this is only needed for the PC version. **Skip this step** if you are modding the console versions.
{: .notice--warning}

Although Scramble claims it supports re-encrypting unity3d files, this feature usually fails with modified files in my experience. You can try it on your own, but if it doesn't work then you will need to use OpenSSL.
{: .notice--danger}

For this step, we'll be using OpenSSL. You can use this command to re-encrypt any of the Unity files with the key and IV:
```openssl.exe aes-128-cbc -e -in <input_file> -out <output_file> -K 6d6b3a39747a785752467d4a707a7732 -iv 4e46586a6571286e3a33672738263d3b```

If you have multiple files you want to encrypt, you can use [this batch script][OpenSSL-Script]. Just drag and drop the files on the script and a new folder named "encrypted" will be made with all the encrypted files.
{: .notice--success}

## Step 3: Replace with the modifed AssetBundles
Once you are done with all of the above, you can finally replace the files in `NEO The World Ends with You_Data\StreamingAssets\Assets`. Be sure to use the same names and extension so the game can still recognize the bundles.

# Modifing the USM files
NEO uses USM CriWare files for all the pre-rendered cutscenes in the game. You can create new USM files using WannaCRI.

**NOTE:** WannaCRI currently only supports video formats. It ***does not*** support making USMs with audio, so keep that in mind.
{: .notice--warning}

## Step 1: Get/Create a video file that WannaCRI supports
WannaCRI only supports 2 video codecs, either H.264 or VP9. NEO should support either one, so pick the one that's easier for you. VP9 video must be in `.ivf` format.

## Step 2: Create the encrypted USM
Once you have a video that WannaCRI supports, you can create a new USM file using the following command:
```wannacri createusm <path_to_video_file> --key 0xBD86C0EE8C7342```

## Step 3: Replace with the modifed USM
Once WannaCRI finishes creating the video file, you can then replace any of the USMs in `NEO The World Ends with You_Data\StreamingAssets\Assets\cri\movie`.

{% capture usm-guide %}
1. MOV_PSI_XXXX: The mini videos that play when you are selecting different pins.
2. OP_wXdX and ED_wXdX: Title cards used at the start and end of each day.
3. S109EpXX: Pre-rendered cutscenes.
4. STAFROLLXX: Credit videos.
{% endcapture %}

<div class="notice--success">
  <h4 class="no_toc">Here's a mini guide on NEO's USMs:</h4>
  {{ usm-guide | markdownify }}
</div>

[UABEA]: https://github.com/nesrak1/UABEA
[Scramble]: https://github.com/supremetakoyaki/Scramble
[WannaCRI]: https://github.com/donmai-me/WannaCRI
[AssetStudio]: https://github.com/Perfare/AssetStudio
[OpenSSL]: https://wiki.openssl.org/index.php/Binaries
[OpenSSL-Script]: https://maren0000.github.io/website/assets/tools/NEO_enc.bat
