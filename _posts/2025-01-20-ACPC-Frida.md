---
title: "Getting encryption keys during runtime using Frida"
description: "Tutorial and showcase of Frida on non-jailbroken iOS devices"
date: 2025-01-19T18:00:00-04:00
last_modified_at: 2025-01-20T12:33:00-04:00
categories:
  - Reverse Engineering
tags:
  - IDA
  - ACPC
  - IL2CPPDumper
  - Encryption
  - iOS
  - Frida
classes: wide
header:
  og_image: /assets/images/acpc-frida/1200px-PC_Logo_English.png
---

Back in December, Nintendo released an offline version of their mobile game Animal Crossing Pocket Camp. Since the game no longer relied on servers or an IAP system, people in the Animal Crossing community started looking into modding the game. One of the first things that people wanted was a save editor, mainly to get items that were no longer accessible in the offline version in the game.
People quickly figured out that the game had two files that were related to the player save by swapping files from different players on the Android version. But the saves themselves looked to be encrypted, so I started looking into how the save system for the game works to see how to find this key.

## IDA Reversing

I looked into [how you can use il2cppdumper and IDA to get decompiled psudocode for Unity games before](https://maren0000.github.io/website/reverse%20engineering/Breaking-DRPG/), so I won't go over this that process again here. After looking through a bunch of the game's classes in DnSpy, I eventually found a class named `CmpsLocalPlayerStorage` that seemed to be exactly what I was looking for as it has two save file paths and a nested `XorCryptor` class.
{% include figure popup=true image_path="/assets/images/acpc-frida/Pasted image 20250117143112.png" alt="" caption="DnSpy screenshot of CmpsLocalPlayerStorage class." %}

Seems like there is a handy `GenerateKey` function we can take a look at! Let's see what it looks like in IDA.

{% include figure popup=true image_path="/assets/images/acpc-frida/Pasted image 20250117144204.png" alt="" caption="IDA decomp of GenerateKey method" %}

Ah, well this is annoying. Unlike Pixel RPG which stored it's key as a string in Unity, ACPC seems to create a 1000 byte key at runtime using a set of Randomness functions inside the `RandomCore` class. The `Initialize` function has a set seed (`0x8A91F2BE48CCLL`) so that the final output will always be consistent every time the game is booted up, and then the game does `get_Int` from the randomness class until the 1000 byte array is filled out.
Now, it is possible to recreate the Random functions used here by looking at the psudocode and making your own code based on that. The first person who got the key did end up doing exactly that, but since I'm not *that* good at interpreting psudocode, I decided to see if there was another possible method to getting the key. This is where Frida and the il2cpp-Frida-Bridge projects come in.

## Frida setup on non-jailbroken iOS

First thing to do is get [Frida](https://frida.re/) working on either an Android or iOS device. Most guides online are usually for Android/Android emulators, but when I tried both an Android emulator and a real Pixel device, there was always some issues like Frida not finding the Unity executable or the game crashing a few seconds after being hooked, so your milage on Android seems to heavily vary depending on your devices and setup.

Since Frida on Android was failing for my use case, I ended up seeing if it was possible to use Frida on my iPad. Since it was not jailbroken, I couldn't use frida-server, but I eventually found [this tutorial on using Frida on non-jailbroken devices](https://infosecwriteups.com/unlocking-potential-exploring-frida-objection-on-non-jailbroken-devices-without-application-ed0367a84f07). I followed all the steps, and to my surprise it actually worked! Frida could hook into the game without issue!

{% include figure popup=true image_path="/assets/images/acpc-frida/Pasted image 20250119171502.png" alt="" caption="Frida is alive!" %}

There is an issue with this method however, and that is you must sideload the game using [Sideloadly](https://sideloadly.io/) for Frida to work properly. There are a few downsides to this such as being able to only have 3 apps installed at once and a 7 day expiry date with a free Apple developer account, but the biggest issue is that you must have a decrypted IPA for Sideloadly to be able to install the IPA. Now although I don't have a jailbreak on my iPad, I do have the [TrollStore](https://ios.cfw.guide/installing-trollstore/) app installed which allows me to use an app like AppsDump2 to get a decrypted version of ACPC right from my device. So while this wasn't a huge issue for me, it could be harder to find a decrypted version of the app you want to hook into if you can't dump it yourself.

There was one thing I found interesting is that Frida would only work on apps installed using Sideloadly. It still wouldn't work even if I installed the app through TrollStore instead, so that begs the question of why does the Sideloadly method work? After doing a bit of research, I actually found that the answer lied with the apps entitlements. IPAs can have an entitlement named `get-task-allow` which is used to allow hooking with debuggers into apps. This entitlement is only meant for dev versions of apps built in Xcode, but Sideloadly adds it to apps it installs so it can enable JIT for sideloaded apps that support it. This entitlement is what also allows Frida to hook into the app perfectly, which isn't possible with apps installed normally through the App Store.
I eventually was able to find a TrollStore app called `TrollSign` which allowed you to change the entitlements of IPAs before you install them through TrollStore. Adding this `get-task-allow` entitlement to the ACPC IPA I dumped and installing it through TrollStore made the game work with Frida again. So now I didn't need to deal with the normal sideloading restrictions that come with using a free Apple developer account :>

## frida-il2cpp-bridge

Now that we finally have a Frida setup working, we can look at the second piece of the puzzle to get it working with Unity games. [frida-il2cpp-bridge](https://github.com/vfsfitvnm/frida-il2cpp-bridge) allows us to interface with il2cpp built games with typescript code. We'll first need to setup a development folder to write our TS scripts in and then convert them to Frida JS scripts. We can do this by running these commands in Powershell.

{% highlight powershell linenos %}
git clone https://github.com/oleavr/frida-agent-example.git #Download Agent Example
cd .\frida-agent-example #Change directory
npm install -g typescript #Install typescript
npm install #Install deps
npm install --save-dev frida-il2cpp-bridge #Install frida-il2cpp-bridge
npm install -g esbuild #Install esbuild
echo "import 'frida-il2cpp-bridge';`nconsole.log('Rebuilded')`nIl2Cpp.perform(() => { Il2Cpp.dump() });" | Set-Content -Path .\agent\index.ts -Encoding utf8 #Create index.ts file
esbuild agent/index.ts --bundle --outfile=il2cpp_bridge.js #Build ts to js
{% endhighlight %}

If you want to have intellisense in something like VS Code, you will need to add this to your `tsconfig.json`:

{% highlight json linenos %}
{
  "compilerOptions": {
    "target": "es2020",
    "lib": ["es2020"],
    "allowJs": true,
    "noEmit": true,
    "strict": true,
    "esModuleInterop": true
  },
    "include": [
        "./node_modules"
    ]
}
{% endhighlight %}

Now we are ready to start writing code in the `index.ts` file. For example, we can write code to invoke the `GenerateKey` method that we found already:

{% highlight typescript linenos %}
import 'frida-il2cpp-bridge';
console.log('Frida works! Il2CPP hooking next...');

(globalThis as any).IL2CPP_UNITY_VERSION = "2022.3.28f1"; //Set Unity Version since the bridge can't find it automatically
Process.getModuleByName("UnityFramework"); //Find the Unity executable

Il2Cpp.perform(() => {
    console.log(Il2Cpp.unityVersion);
    const AssemblyCSharp = Il2Cpp.domain.assembly("Assembly-CSharp").image //Assembly-CSharp.dll
    const LocalPlayerStorageClass = AssemblyCSharp.class("NDcube.Cmps.Sys.CmpsLocalPlayerStorage") //Find CmpsLocalPlayerStorage class
    const XorClass = LocalPlayerStorageClass.nested("XorCryptor");
    const key = XorClass.method("GenerateKey").invoke(); //Invoke GenerateKey method and store returned byte
    console.log("key: ", key); //Print byte
});
{% endhighlight %}

Then we can build the Frida script using `esbuild` command shown previously. Once we have the .js file, we can run it with Frida using this command: `frida -U -f <app_name> -l <script_name>.js`. You might need to use `%reload` command in the Frida console since `UnityFramework` might not be found on boot, but after that your script should run, and you should start seeing an output in the console log!

{% include figure popup=true image_path="/assets/images/acpc-frida/Pasted image 20250118125712.png" alt="" caption="Screenshot of the TS code and console output" %}

We can then convert this byte array to a hex key and then be able to decrypt the save file!

{% include figure popup=true image_path="/assets/images/acpc-frida/Pasted image 20250118130201.png" alt="" caption="The key in hex" %}
{% include figure popup=true image_path="/assets/images/acpc-frida/Pasted image 20250118130648.png" alt="" caption="Cyberchef screenshot of the save file after XOR decrypting with the key" %}

The file has be successfully decrypted. But that's not the only thing we can do with the il2cpp-bridge. I won't go too much into it here and I would recommend you check the [code snippets page](https://github.com/vfsfitvnm/frida-il2cpp-bridge/wiki/Snippets) and the issues/discussions pages on the GitHub page as there is plenty of more info to be found there, but here are a few interesting screenshots of my own code snippets and console logs to show a bit of what's possible.

{% include figure popup=true image_path="/assets/images/acpc-frida/Pasted image 20250118134144.png" alt="" caption="Tracing a bunch of function calls with arguments and returns" %}

{% include figure popup=true image_path="/assets/images/acpc-frida/Pasted image 20250118134230.png" alt="" caption="Backtracing a method" %}

{% include figure popup=true image_path="/assets/images/acpc-frida/Pasted image 20250118134406.png" alt="" caption="Invoking a method with custom values" %}

{% include figure popup=true image_path="/assets/images/acpc-frida/Pasted image 20250118134824.png" alt="" caption="Creating a new instance of a class and using a custom method implementation to print a values in a struct each time the method is called" %}

## Conclusion

As you can probably see, there is *a lot* you can do with Frida + il2cpp bridge for Unity games. This setup using an unjailbroken iOS device has been fairly stable considering what's being done here. Since there is no jailbreak involved, most games should still run fine, but the sideloading trick does cause an issue for some games. For example, NIKKE fails to boot if sideloaded using Sideloadly at all, and a game like Blue Archive still boots, but something in the NEXON Login SDK fails and the game will quit after not being able to login into an account. So it's still not a perfect method, but for any single player games or games with less protections, this method should still work great.