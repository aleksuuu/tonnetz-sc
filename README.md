# Tonnetz in SuperCollider

## Installing `ChordFunc.sc` and `Tonnetz.sc`

`ChordFunc.sc` and `Tonnetz.sc` should be placed in the folder where SuperCollider looks for classes. Use one of the following commands to find the path:

`Platform.userExtensionDir;   // Extensions available only to your user account`

`Platform.systemExtensionDir; // Extensions available to all users on the machine`


## What is `ChordFunc`?

`ChordFunc` is a companion class that has to be installed along with `Tonnetz` in order for `Tonnetz` to function properly. `ChordFunc` is capable of generating a pitch class set based on a chord symbol, and identifying a chord based on an array of integers representing pitch classes or MIDI note numbers. Currently, only triads are supported.

## What is `Tonnetz`?

`Tonnetz` is a SuperCollider class designed to perform neo-Riemannian transformations (NRT) on any given triad. To use `Tonnetz`, first initialize it by executing `Tonnetz(homeChord, currChord, voiceLeading)` where `homeChord` is a chord `Tonnetz` remembers and can recall later, `currChord` is the chord on which NRT will be performed, and `voiceLeading` turns smooth voice-leading on and off (1 = on, 0 = off; it is on by default). Chords in `Tonnetz` are represented by pitch classes or MIDI note numbers (for instance, [0, 4, 7] and [60, 67, 76] are both a C major chord).

To perform a NRT, use `Tonnetz.transform(transform)`, which can take one or more transformation keywords as its argument. Four transformation keywords are available: `\p` (parallel), `\r` (relative), `\l` (leading-tone), and `\h` (home). Home recalls the home chord specified in the initialization. To learn more about parallel, relative, and leading-tone transformations, see the Wikipedia [article](https://en.wikipedia.org/wiki/Neo-Riemannian_theory#Triadic_transformations_and_voice_leading) for NRT. Adding multiple keywords after the backslash in the argument (e.g., `\lpr`) produces a compound transformation, consecutively performing NRTs on the current chord, outputting a single resultant chord. After each transformation, a new chord is returned (again as an array of integers) and the new chord name is posted to the console.

## Testing

You can test both `ChordFunc` and `Tonnetz` in `tonnetz-demo.scd`.