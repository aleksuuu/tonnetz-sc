/* ————————————————— test Tonnetz here ————————————————— */
a = Tonnetz([0, 4, 7], [0, 4, 7]); // initialize a Tonnetz with a C major triad
a;

// available transform keywords are: \p (parallel), \r (relative), \l (leading tone), and \h (home) or any combination of the above (e.g., \pr would output a chord after both parallel and then relative transformations) (combination currently doesn't work for some reason)
b = a.transform(\p); // this works
b;
c = a.transform(\rp); // and this also works now!
c;

/* ————————————————— here are the two ~evolve related functions ————————————————— */
(
~initEvolve = { // initializes the Tonnetz class and ~dir according to the sentiment value and sets ~numOfChanges to 0. execute this function once at the very beginning of the installation/performance
	| sentiment |
	var chord; // if sentiment increases, dir = 1; if it decreases, dir = 0. init assumes that if Twitter starts a day happy, it will keep getting happier (dir=1), and vice versa
	chord = case
	{ sentiment > 0.8 } { [0, 5, 9] } // F/C
	{ sentiment > 0.6 } { [1, 4, 9] } // A/C# (also ChordFunc.toChord apparently doesn't work with this chord??)
	{ sentiment > 0.5 } { [0, 4, 7] } // C
	{ sentiment > 0.4 } { [0, 3, 7] } // Cm
	{ sentiment > 0.2 } { [-2, 3, 6] } // Ebm/Bb
	{ [-4, 0, 5] }; // Fm/C
	chord = chord + 60; // assuming we want to make the chord start somewhere around middle C
	~tntz = Tonnetz(chord, chord);
	~dir = if (sentiment > 0.5, { 1 }, { 0 });
	~numOfChanges = 0;
	"~evolve initialized";
};
~evolve = { // transforms the current chord according to change in sentiment value
	| change = 0.2 |
	var dir, transform, changeAbs;
	dir = case
	{ change > 0 } { 1 } // if increase, dir = 1
	{ 0 }; // if decrease or no change, dir = 0
	changeAbs = change.abs;
	if (change == 0, // if no change, do nothing
		{ "no change".postln },
		{
			if (dir == ~dir, // if direction did not change
				{
					~numOfChanges = ~numOfChanges + 1;
					transform = if ( ~numOfChanges % 2 == 1, { \rp }, { \pl });
				},
				{
					~dir = dir;
					transform = case
					{ changeAbs > 0.8 } { \p }
					{ changeAbs > 0.4 } { \r }
					{ \l };
				}
			);
			~tntz.transform(transform);
		}
	);
};
)

/* ————————————————— test ~evolve here ————————————————— */
~initEvolve.value(0.1); // initializes an Ebm/Bb chord
~evolve.value(0); // returns "no change"
~evolve.value(0.3); // execute 1x: returns Db/Ab; 2x: returns Bb; 3x: returns Gb/Bb (chords slowly get higher)
~evolve.value(-0.3); // starting from the Ebm/Bb chord - execute 1x: returns Abm; 2x: returns Cm/G; 3x: returns Ebm/Gb (chords slowly get lower)