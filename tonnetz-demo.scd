/* ————————————————— test Tonnetz here ————————————————— */
a = Tonnetz([0, 4, 7], [0, 4, 7]); // first initialize a Tonnetz with a C major triad
a;

// available transform keywords are: \p (parallel), \r (relative), \l (leading tone), and \h (home) or any combination of the above (e.g., \pr would output a chord after both parallel and then relative transformations)
b = a.transform(\p); // basic transformation
b;
c = a.transform(\rp); // compound transformation
c;

/* ————————————————— if you'd like to hear a semimusical application ————————————————— */
(
// 1. initialize the functions here
~tonnetz = Tonnetz([60, 64, 67], [60, 64, 67]); // init Tonnetz w/ midinotes
SynthDef(\fmSynthDemo,{ |out=0, freq=100, fmMult=2, aAmt=0.3, fmAmt=1, aAtk=4, aDec=4, aSus=0.5, aRel=4, fmAtk=2, fmDec=2, fmSus=0.5, fmRel=0.5, pan=0, panDev=0.5, mVol=1.0, gate=1, lpFreq=2500, lpRes=2|
	var osc, ampEnv, fmEnv, sig, lfFmVib, noise, brownGen, trig, actualPan;
	lfFmVib = LFPar.kr(3+LFClipNoise.kr(20)*2) * (0.02+LFClipNoise.kr(20)*0.01);
	ampEnv = EnvGen.kr(Env.new([0,aAmt,0], [aAtk,aDec]), gate, doneAction: 2);
	fmEnv = EnvGen.kr(Env.new([0,1,0], fmAtk, fmDec), gate);
	osc = SinOsc.ar(freq, SinOsc.ar((freq * (fmMult+lfFmVib)), 0, fmAmt), ampEnv * mVol);
	osc = MoogFF.ar(osc, lpFreq, lpRes);
	noise = Crackle.ar(LFClipNoise.kr(Rand(2,6))*0.1+1.5, 0.005);
	sig = osc + noise; // adding noise post filter
	brownGen = Dbrown(pan-panDev, pan+panDev);
	trig = Impulse.kr(Rand(0.1, 1.0));
	actualPan = Demand.kr(trig, 0, brownGen);
	Out.ar(out, Pan2.ar(sig, actualPan));
}).add;
~tonnetzPlay = {
	| transform, lpFreq=2000, lpRes=1.5 |
	var chord;
	chord = ~tonnetz.transform(transform);
	Pdef(\evo1, Pbind(
		\instrument, \fmSynthDemo,
		\midinote, chord[0],
		\mVol, 0.1,
		\lpFreq, lpFreq,
		\lpRes, lpRes
	)).play;
	Pdef(\evo2, Pbind(
		\instrument, \fmSynthDemo,
		\midinote, chord[1],
		\mVol, 0.1,
		\lpFreq, lpFreq,
		\lpRes, lpRes
	)).play;
	Pdef(\evo3, Pbind(
		\instrument, \fmSynthDemo,
		\midinote, chord[2],
		\mVol, 0.1,
		\lpFreq, lpFreq,
		\lpRes, lpRes
	)).play;
};
)

// 2. execute this line of code with transform keyword (\p (parallel), \r (relative), \l (leading tone), and \h (home) or any combination of the above), low pass frequency, and LPF resonance
~tonnetzPlay.value(\lrlp, 3000, 3);

