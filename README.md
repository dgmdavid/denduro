# Denduro
An Enduro clone written in D.

It's a small side project I was wanting to do since my childhood. Why didn't I do it earlier? I don't know.
I'm using this opportunity to learn more about the D language.

![Screenshot as of now.](https://raw.githubusercontent.com/dgmdavid/denduro/master/ref_images/denduro_screenshot.png)

# How to Build (on Windows and Linux)

## D compiler
You will need to download Digital Mars D Compiler from [here](http://dlang.org/download.html#dmd).

I did't test it with GDC or LDC yet.

## Dub - the D's package manager
Optionally, you can download DUB [here](https://code.dlang.org/download).

It will automatically download and setup the project's dependency, [Derelict-SDL2](https://github.com/DerelictOrg/DerelictSDL2), effectively making your life easier.

## Bulding and running
Be sure to have dmd and dub on your path if you are on Windows.

Just run "dub" on the project's folder (containing the dub.json file). It will automatically download the dependencies, compile and run the game.
