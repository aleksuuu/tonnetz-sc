ChordFunc {
	var <>chord;

	*analyze { |chordTones| // toSymbol = chord to analysis; major/minor triads only
		var mod12, sortedMod, bassNote, chordQuality, intvl1, intvl2, root, analysis;
		mod12 = chordTones % 12; // make sure everything is in the same octave
		bassNote = mod12[0];
		sortedMod = mod12.as(Set).as(Array).sort; // filter out repeats and sort again so that the lowest note in the octave between C and C is at index 0
		intvl1 = sortedMod[1] - sortedMod[0];
		intvl2 = sortedMod[2] - sortedMod[0];
		root = nil;
		chordQuality = nil;
		analysis = [root, chordQuality];
		analysis = case // comments show what the chords would be if sortedMod[0] == 0
		{ intvl1 == 4 && intvl2 == 7 } { [sortedMod[0], "Major"] } // C
		{ intvl1 == 3 && intvl2 == 7 } { [sortedMod[0], "Minor"] } // Cm
		{ intvl1 == 3 && intvl2 == 8 } { [sortedMod[2], "Major"] } // Am
		{ intvl1 == 4 && intvl2 == 9 } { [sortedMod[2], "Minor"] } // Am
		{ intvl1 == 5 && intvl2 == 9 } { [sortedMod[1], "Major"] } // F
		{ intvl1 == 5 && intvl2 == 8 } { [sortedMod[1], "Minor"] }; // Fm
		analysis.add(bassNote);
		^analysis; // analysis is an array of root, chordQuality, bassNote; both root and bassNote are expressed as integers
	}

	*ats { |analysis| // ats (analysis to symbol) translates the output of nts (an array) to an actual chord symbol
		var root, chordQuality, bassNote, chordSym, scale;
		scale = [\C, \Db, \D, \Eb, \E, \F, \Gb, \G, \Ab, \A, \Bb, \B];
		root = analysis[0];
		root = scale[root];
		chordQuality = switch (analysis[1],
			"Major", { "" },
			"Minor", { "m" }
		);
		bassNote = if (analysis[2] == analysis[0], { "" }, {  "/"  ++ scale[analysis[2]] });
		chordSym = root ++ chordQuality ++ bassNote;
		^chordSym;
	}

	*toSymbol { |chordTones|
		^this.ats(this.analyze(chordTones));
	}

	*noteNameToInt { |noteName|
		noteName = noteName ++ ""; // make sure root is a string (not a char or int)
		^switch (noteName,
			"C", { 0 },
			"C#", { 1 },
			"Db", { 1 },
			"D", { 2 },
			"D#", { 3 },
			"Eb", { 3 },
			"E", { 4 },
			"Fb", { 4 },
			"E#", { 5 },
			"F", { 5 },
			"F#", { 6 },
			"Gb", { 6 },
			"G", { 7 },
			"G#", { 8 },
			"Ab", { 8 },
			"A", { 9 },
			"A#", { 10 },
			"Bb", { 10 },
			"B", { 11 },
			"Cb", { 11 },
			"B#", { 0 }
		);
	}

	*toChord { |chordSymbol| // would turn Bb to [10, 14, 17] (thus not necessarily PC)
		var root, bassNote, chord;
		root = if (chordSymbol.contains("#") || chordSymbol.contains("b"),
			{ chordSymbol[0..1] },
			{ chordSymbol[0] }
		);
		root = this.noteNameToInt(root);
		chord = if (chordSymbol.contains("m"),
			{ [root, root+3, root+7] }, // if minor
			{ [root, root+4, root+7] } // if major [more chord qualities to come]
		);
		if (chordSymbol.contains("/"),
			{ bassNote = chordSymbol[chordSymbol.find("/")+1..chordSymbol.size-1];
				bassNote = this.noteNameToInt(bassNote);
				if (chord.includes(bassNote),
					{ bassNote = chord.indexOf(bassNote);
						chord = chord.wrapAt((bassNote..bassNote+chord.size-1)) // returns the chord starting from bass
					},
					{ chord = chord.insert(0, bassNote) }
				);
			}
		);
		^chord;
	}


	*inversion { |chordTones|
		var analysis, root, bassNote, interval;
		analysis = this.analyze(chordTones);
		root = analysis[0];
		bassNote = analysis[2];
		interval = root - bassNote;
		if (interval < 0, { interval = interval + 12 });
		^switch (interval,
			0, { 0 },
			8, { 1 },
			9, { 1 },
			5, { 2 }
		);
	}

	*pc { |chordTones|
		^this.toChord(this.toSymbol(chordTones));
	}

	*rootPosPC { |chordTones|
		var rootPosSym;
		rootPosSym = this.toSymbol(chordTones);
		if (rootPosSym.contains("/"),
			{ rootPosSym = rootPosSym[0..rootPosSym.find("/")-1] }
		);
		^this.toChord(rootPosSym) % 12; // so that Bb becomes [10, 2, 5] and not [10, 14, 17]
	}

	*findIndices { |chordTones, chordMember| // returns actual pitches and not pitch classes; returns an array of all instances of that chord member (0 = root, 1 = 3rd, 2 = 5th) in the voicing
		var pc, indices;
		// slice before slash if slash exists
		pc = this.rootPosPC(chordTones)[chordMember];
		indices = List.newClear(0);
		for (0, chordTones.size - 1, { |i|
			if (chordTones[i] % 12 == pc, { indices.add(i) })
		});
		^indices.asArray;
	}
}