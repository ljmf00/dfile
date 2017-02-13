/*
 * s_ne.d : New Executable format scanner
 */

module s_ne;

import std.stdio;
import dfile;

// New .EXE header, found in newexe.h in the Word 1.1a source.
private struct ne_hdr
{
    char[2]  ne_magic;       /* Magic number NE_MAGIC */
	char     ne_ver;         /* Version number */
	char     ne_rev;         /* Revision number */
	ushort   ne_enttab;      /* Offset of Entry Table */
	ushort   ne_cbenttab;    /* Number of bytes in Entry Table */
	uint     ne_crc;         /* Checksum of whole file */
	ushort   ne_flags;       /* Flag word */
	ushort   ne_autodata;    /* Automatic data segment number */
	ushort   ne_heap;        /* Initial heap allocation */
	ushort   ne_stack;       /* Initial stack allocation */
	uint     ne_csip;        /* Initial CS:IP setting */
	uint     ne_sssp;        /* Initial SS:SP setting */
	ushort   ne_cseg;        /* Count of file segments */
	ushort   ne_cmod;        /* Entries in Module Reference Table */
	ushort   ne_cbnrestab;   /* Size of non-resident name table */
	ushort   ne_segtab;      /* Offset of Segment Table */
	ushort   ne_rsrctab;     /* Offset of Resource Table */
	ushort   ne_restab;      /* Offset of resident name table */
	ushort   ne_modtab;      /* Offset of Module Reference Table */
	ushort   ne_imptab;      /* Offset of Imported Names Table */
	uint     ne_nrestab;     /* Offset of Non-resident Names Table */
	ushort   ne_cmovent;     /* Count of movable entries */
	ushort   ne_align;       /* Segment alignment shift count */
	ushort   ne_cres;        /* Count of resource segments */
	ushort   ne_psegcsum;    /* offset to segment chksums */
	ushort   ne_pretthunks;  /* offset to return thunks */
	ushort   ne_psegrefbytes;/* offset to segment ref. bytes */
	ushort   ne_swaparea;    /* Minimum code swap area size */
    ubyte[2] ne_expver;      /* Expected Windows version number */
}

private const ushort
    NENOTP = 0x8000, /* Not a process */
    NENONC = 0x4000, /* Non-conforming program */
    NEIERR = 0x2000, /* Errors in image */
    NEPROT = 0x0008, /* Runs in protected mode */
    NEREAL = 0x0004, /* Runs in real mode */
    NEINST = 0x0002, /* Instance data */
    NESOLO = 0x0001; /* Solo data */

static void scan_ne(File file)
{
    ne_hdr h;
    {
        import core.stdc.string;
        ubyte[ne_hdr.sizeof] buf;
        file.rawRead(buf);
        memcpy(&h, &buf, ne_hdr.sizeof);
    }

    if (Debugging || Informing)
    {
        writefln("NE ne_magic       : %s", h.ne_magic);
        writefln("NE ne_ver         : %Xh", h.ne_ver);
        writefln("NE ne_rev         : %Xh", h.ne_rev);
        writefln("NE ne_enttab      : %Xh", h.ne_enttab);
        writefln("NE ne_cbenttab    : %Xh", h.ne_cbenttab);
        writefln("NE ne_crc         : %Xh", h.ne_crc);
        writefln("NE ne_flags       : %Xh", h.ne_flags);
        writefln("NE ne_autodata    : %Xh", h.ne_autodata);
        writefln("NE ne_heap        : %Xh", h.ne_heap);
        writefln("NE ne_stack       : %Xh", h.ne_stack);
        writefln("NE ne_csip        : %Xh", h.ne_csip);
        writefln("NE ne_sssp        : %Xh", h.ne_sssp);
        writefln("NE ne_cseg        : %Xh", h.ne_cseg);
        writefln("NE ne_cmod        : %Xh", h.ne_cmod);
        writefln("NE ne_cbnrestab   : %Xh", h.ne_cbnrestab);
        writefln("NE ne_segtab      : %Xh", h.ne_segtab);
        writefln("NE ne_rsrctab     : %Xh", h.ne_rsrctab);
        writefln("NE ne_restab      : %Xh", h.ne_restab);
        writefln("NE ne_modtab      : %Xh", h.ne_modtab);
        writefln("NE ne_imptab      : %Xh", h.ne_imptab);
        writefln("NE ne_nrestab     : %Xh", h.ne_nrestab);
        writefln("NE ne_cmovent     : %Xh", h.ne_cmovent);
        writefln("NE ne_align       : %Xh", h.ne_align);
        writefln("NE ne_cres        : %Xh", h.ne_cres);
        writefln("NE ne_psegcsum    : %Xh", h.ne_psegcsum);
        writefln("NE ne_pretthunks  : %Xh", h.ne_pretthunks);
        writefln("NE ne_psegrefbytes: %Xh", h.ne_psegrefbytes);
        writefln("NE ne_swaparea    : %Xh", h.ne_swaparea);
        write("NE ne_expver      : ");
        foreach (b; h.ne_expver)
            writef("%X ", b);
        writeln();
    }

    if (ShowingName)
        writef("%s: ", file.name);

    write("NE ");

    if (h.ne_flags & NENOTP)
        write("DLL or driver");
    else
        write("Executable");

    write(" file");

    if (h.ne_expver[0])
        writef(", Windows %d.%d expected", h.ne_expver[1], h.ne_expver[0]);

    if (h.ne_flags)
    {
        if (h.ne_flags & NENONC)
            write(", non-conforming program");
        if (h.ne_flags & NEIERR)
            write(", errors in image");
        if (h.ne_flags & NEPROT)
            write(", runs in protected mode");
        if (h.ne_flags & NEREAL)
            write(", runs in real mode");
        if (h.ne_flags & NEINST)
            write(", instance data");
        if (h.ne_flags & NESOLO)
            write(", solo data");
    }

    writeln();
}
