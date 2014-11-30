
I.   Introduction

I have been wanting to create a 2D sprite game for OS X for some time.  A few weeks ago, I created WCSpritemanager and the drawRect function in WCView.  This was enough to make it so I can make a game.

I remembered reading that Eugene Jarvis was to receive IGDA's Lifetime Achievement Award.  Eugene is perhaps best known for his work on Defender and Robotron: 2084 so with that, I decided to make Defender.  What I didn't realize is just how hard Defender is (to play) and I couldn't make it to the 3rd wave, never mind stay alive long enough to study the AI.  But, I made this game anyway. 

This isn't really a remake of the original, although I did match things as closely as I could.  I think of it more as a version in homage to the original as, like I said, I don't even know what happens after the 3rd wave in the original.

II.  Use and keys

The keyboard and Joystick controls are configurable from within the game.  These can be changed in the Preferences.  The game will also run in full-screen mode.  I only tested this on a MacBook Air at 1366x768 and on a Mac Mini at 1080p.

III. Technical

The game uses NSImage for drawing and there really is no sophistication here, but that's more than good enough to run the game at 30 FPS even on an 11" 1.4GHz Late 2010 MacBook Air. For Audio I captured the sounds from the original game using Mame and I play it back using NSSound.

The Joystick handling isn't great.  I really wanted to work on this game only in November and now my time is up.  I didn't get to build the IOHID stuff out beyond making it work with my 360 controller using the driver from http://tattiebogle.net/.  Even then, the triggers aren't usable because I quite arbitrarily assume a dead zone of 16,384 and the triggers generate values between 0 and 255.  To make it work I would need to figure out how to enumerate buttons and axis and what ranges these use.  Hopefully I'll have some time and can then come back to this.

IV.  Credits

The original game is Copyright 1980 by Williams Electronics Inc.  All credit to Eugene Jarvis, Larry DeMar, Sam Dicker and whoever else created that original game.  I am amazed by how much people did with so little back in the day.

V.   Video

A video of the game is on YouTube at http://youtu.be/YVFdiUXgYPg

VI.  Contact

Feel free to send me an email if you have any comments.

swessels@email.com

Thank you!