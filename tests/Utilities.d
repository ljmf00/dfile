import utils;

import std.stdio;

unittest
{
    {
        ushort s = 0xFFAA;
        assert(bswap(s) == 0xAAFF);
        s = 0x6600;
        assert(bswap(s) == 0x66);
        s = 0x66;
        assert(bswap(s) == 0x6600);

        uint i = 0xFFBBCCAA;
        assert(bswap(i) == 0xAACCBBFF);
        i = 0x12340000;
        assert(bswap(i) == 0x3412);
        i = 0x1234;
        assert(bswap(i) == 0x34120000);

        ulong l = 0xAABBCCDD_EEFF1122;
        assert(bswap(l) == 0x2211FFEE_DDCCBBAA);
        l = 0xAABBCCDD_00000000;
        assert(bswap(l) == 0xDDCCBBAA);
        l = 0xAABBCCDD;
        assert(bswap(l) == 0xDDCCBBAA_00000000);
    }

    {
        ubyte[] a = [1];
        bswap(&a[0], a.length);
        assert(a == [1]);

        a = [1, 2];
        bswap(&a[0], a.length);
        assert(a == [2, 1]);

        a = [1, 2, 3, 4];
        bswap(&a[0], a.length);
        assert(a == [4, 3, 2, 1]);

        a = [1, 2, 3, 4, 5, 6, 7, 8];
        bswap(&a[0], a.length);
        assert(a == [8, 7, 6, 5, 4, 3, 2, 1]);

        a = [1, 2, 3];
        bswap(&a[0], a.length);
        assert(a == [3, 2, 1]);

        a = [1, 2, 3, 4, 5];
        bswap(&a[0], a.length);
        assert(a == [5, 4, 3, 2, 1]);

        a = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
        bswap(&a[0], a.length);
        assert(a == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

        File f = File.tmpfile();
        f.rawWrite(a);
        struct s1 { // Generic header
            uint magic;
            ushort version_;
            ubyte[4] type;
        }
        s1 h1;
        scpy(f, &h1, h1.sizeof, true);
        writeln(h1.type);
        assert(h1.magic == 0x0403_0201);
        assert(h1.version_ == 0x0605);
        assert(h1.type  == [7, 8, 9, 10]);

        struct s2 { // Generic header
            uint magic;
            ushort version_;
            ushort type1;
            ushort type2;
        }
        s2 h2;
        scpy(f, &h2, h2.sizeof, true);
        assert(h2.magic == 0x0403_0201);
        assert(h2.version_ == 0x0605);
        assert(h2.type1 == 0x0807);
        assert(h2.type2 == 0x0A09);

        struct s3 { // Generic header
            uint magic;
            ushort version_;
            uint type;
        }
        s3 h3;
        scpy(f, &h3, h3.sizeof, true);
        writeln("S_SIZE : ", s3.sizeof);
        writeln("S_INT  : ", uint.sizeof);
        writeln("S_SHORT: ", ushort.sizeof);
        writefln("%X", h3.magic);
        writefln("%X", h3.version_);
        writefln("%X", h3.type);
        assert(h3.magic == 0x0403_0201);
        assert(h3.version_ == 0x0605);
        assert(h3.type == 0x0A09_0807);
        f.close();
    }
}