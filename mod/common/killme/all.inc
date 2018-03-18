#include "jeff.qc"

#include "crates.qh"
#ifdef SVQC
	#include "randomweapons.qc"
	#include "crates.qc"
#endif

#include "huntingrifle.qc"
#include "assaultrifle.qc"
#include "explosives.qc"

#define IMPLEMENTATION
#include "assaultrifle.qc"
#include "explosives.qc"
#undef IMPLEMENTATION
