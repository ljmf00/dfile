/*
 * utils.d : Utilities
 */

module utils;

import std.stdio;

/*
 * File utilities.
 */

/// Read file with a struct or array.
void scpy(File file, void* s, size_t size, bool rewind = false)
{
    import std.c.string : memcpy;
    if (rewind) file.rewind();
    ubyte[] buf = new ubyte[size];
    file.rawRead(buf);
    memcpy(s, buf.ptr, size);
    version (unittest)
    {
        import std.stdio : writeln;
        writeln("SCPY::BUF: ", buf);
    }
}

/*
 * String utilities.
 */

/// Get a null-terminated string.
string asciz(char[] str) pure
{
    if (str[0] == '\0') return null;
    char* p, ip; p = ip = &str[0];
    while (*++p != '\0') {}
    return str[0 .. p - ip].idup;
}

/// Get a Tar-like string ('0' padded).
string tarstr(char[] str) pure
{
    size_t p;
    while (str[p] == '0') ++p;
    return str[p .. $ - 1].idup;
}

/// Get a ISO-like string (' ' padded).
string isostr(char[] str) pure
{
    if (str[0] == ' ') return null;
    if (str[$ - 1] != ' ') return str.idup;
    size_t p = str.length - 1;
    while (str[p] == ' ') --p;
    return str[0 .. p + 1].idup;
}

/*
 * Number utilities.
 */

/// Get a formatted size.
string formatsize(long size) pure
{
    import std.format : format;

    enum : long {
        KB = 1024,
        MB = KB * 1024,
        GB = MB * 1024,
        TB = GB * 1024
    }

    if (size < KB)
        return format("%d B", size);
    else if (size < MB)
        return format("%d KB", size / KB);
    else if (size < GB)
        return format("%d MB", size / MB);
    else if (size < TB)
        return format("%d GB", size / GB);
    else
        return format("%d TB", size / TB);
}

/*
 * 16-bit swapping
 */

/// Swap 2 bytes.
ushort bswap(ushort num) pure
{
    version (X86)
    {
        asm pure { naked;
            xchg AH, AL;
            ret;
        }
    }
    else version (X86_64)
    {
        version (Windows)
        {
            asm pure { naked;
                mov AX, CX;
                xchg AL, AH;
                ret;
            }
        }
        else
        { // Should follow System V AMD64 ABI
            asm pure { naked;
                mov EAX, EDI;
                xchg AL, AH;
                ret;
            }
        }
    }
    else
    {
        version (LittleEndian)
        {
            if (num)
            {
                ubyte* p = cast(ubyte*)&num;
                return p[1] | p[0] << 8;
            }
        }

        return num;
    }
}

/*
 * 32-bit swapping
 */

/// Swap 4 bytes.
uint bswap(uint num) pure
{
    version (X86)
    {
        asm pure { naked;
            bswap EAX;
            ret;
        }
    }
    else version (X86_64)
    {
        version (Windows)
        {
            asm pure { naked;
                mov EAX, ECX;
                bswap EAX;
                ret;
            }
        }
        else
        { // Should follow System V AMD64 ABI
            asm pure { naked;
                mov RAX, RDI;
                bswap EAX;
                ret;
            }
        }
    }
    else
    {
        version (LittleEndian)
        {
            if (num)
            {
                ubyte* p = cast(ubyte*)&num;
                return p[3] | p[2] << 8 | p[1] << 16 | p[0] << 24;
            }
        }
        
        return num;
    }
}

/*
 * 64-bit swapping
 */

/// Swap 8 bytes.
ulong bswap(ulong num) pure
{
    version (X86)
    {
        asm pure { naked;
            xchg EAX, EDX;
            bswap EDX;
            bswap EAX;
            ret;
        }
    }
    else version (X86_64)
    {
        version (Windows)
        {
            asm pure { naked;
                mov RAX, RCX;
                bswap RAX;
                ret;
            }
        }
        else
        { // Should follow System V AMD64 ABI
            asm pure { naked;
                mov RAX, RDI;
                bswap RAX;
                ret;
            }
        }
    }
    else
    {
        version (LittleEndian)
        {
            if (num)
            {
                ubyte* p = cast(ubyte*)&num;
                ubyte c;
                for (int a, b = 7; a < 4; ++a, --b) {
                    c = *(p + b);
                    *(p + b) = *(p + a);
                    *(p + a) = c;
                }
                return num;
            }
        }

        return num;
    }
}

/// Swap an array of bytes.
void bswap(ubyte* a, size_t length) pure
{
    size_t l = length / 2;
    if (l)
    {
        ubyte* b = a + length - 1;
        ubyte c;
        while (l--)
        {
            c = *b;
            *b = *a;
            *a = c;
            --b; ++a;
        } 
    }
}

ushort make_ushort(char[] buf) pure
{
    return buf[0] | buf[1] << 8;
}
ushort make_ushort(ubyte[] buf) pure
{
    return buf[0] | buf[1] << 8;
}
uint make_uint(char[] buf) pure
{
    return buf[0] | buf[1] << 8 | buf[2] << 16 | buf[3] << 24;
}
uint make_uint(ubyte[] buf) pure
{
    return buf[0] | buf[1] << 8 | buf[2] << 16 | buf[3] << 24;
}

void print_array(void* arr, size_t length)
{
    ubyte* p = cast(ubyte*)arr;
    writef("%02X", p[--length]);
    do writef("-%02X", p[--length]); while (length);
}