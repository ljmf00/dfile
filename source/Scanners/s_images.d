/*
 * s_images.d : Image scanner
 */

module s_images;

import dfile, std.stdio, utils;

void scan_png(File file) // Big Endian
{ // https://www.w3.org/TR/PNG-Chunks.html
    report("Portable Network Graphics image (PNG)");

    if (More)
    {
        struct ihdr_chunk_full { // Yeah.. Blame PNG
            uint length;
            uint type;
            uint width;        // START IHDR
            uint height;
            ubyte depth;       // bit depth
            ubyte color;       // color type
            ubyte compression;
            ubyte filter;
            ubyte interlace;   // END IHDR
            uint crc;
        }

        /*struct png_chunk {
            uint length;
            uint type;
            ubyte[] data;
            uint crc;
        }
        enum { // Types
            IHDR = 0x52444849,
            pHYs = 0x73594870
        }*/

        ihdr_chunk_full h;
        scpy(file, &h, h.sizeof);

        with (h) {
            write(bswap(width), " x ", bswap(height), " pixels, ");

            switch (color)
            {
                case 0:
                    switch (depth)
                    {
                        case 1, 2, 4, 8, 16:
                            write(depth, "-bit ");
                            break;
                        default: break;
                    }
                    write("Grayscale");
                    break;
                case 2:
                    switch (depth)
                    {
                        case 8, 16:
                            write(depth, "-bit ");
                            break;
                        default: break;
                    }
                    write("RGB");
                    break;
                case 3:
                    switch (depth)
                    {
                        case 1, 2, 4, 8:
                            write("8-bit ");
                            break;
                        default: break;
                    }
                    write("PLTE Palette");
                    break;
                case 4:
                    switch (depth)
                    {
                        case 8, 16:
                            write(depth, "-bit ");
                            break;
                        default: break;
                    }
                    write("Grayscale+Alpha");
                    break;
                case 6:
                    switch (depth)
                    {
                        case 8, 16:
                            write(depth, "-bit ");
                            break;
                        default: break;
                    }
                    write("RGBA");
                    break;
                default: write("Invalid color type"); break;
            }

            write(", ");

            switch (compression)
            {
                case 0: write("Default compression"); break;
                default: write("Invalid compression"); break;
            }

            write(", ");

            switch (filter)
            {
                case 0: write("Default filtering"); break;
                default: write("Invalid filtering"); break;
            }

            write(", ");

            switch (interlace)
            {
                case 0: write("No interlacing"); break;
                case 1: write("Adam7 interlacing"); break;
                default: write("Invalid interlacing"); break;
            }

            writeln();
        }
    }
}

void scan_gif(File file)
{ // http://www.fileformat.info/format/gif/egff.htm
    struct gif_header {
        char[3] magic;
        char[3] version_;
        ushort width;
        ushort height;
        ubyte packed;
        ubyte bgcolor;
        ubyte aspect; // ratio
    }

    gif_header h;
    scpy(file, &h, h.sizeof, true);

    switch (h.version_[1])
    { // 87a, 89a
        case '7', '9':
            report("GIF", false);
            writeln(h.version_, " image");
            break;
        default: writeln("GIF with invalid version"); return;
    }

    if (More)
    {
        enum {
            GLOBAL_COLOR_TABLE = 0x80,
            SORT_FLAG = 8,
        }

        with (h) {
            write(width, " x ", height, " pixels");
            if (packed & GLOBAL_COLOR_TABLE) {
                write(", Global Color Table");
                if (packed & 3)
                    write(" of ", 2 ^^ ((packed & 3) + 1), " bytes");
                if (packed & SORT_FLAG)
                    write(", Sorted");
                if (bgcolor)
                    write(", BG Index of ", bgcolor);
            }
            write(", ", ((packed >> 4) & 3) + 1, "-bit");
            if (aspect) {
                write(", ", (cast(float)aspect + 15) / 64, " pixel ratio (reported)");
            }
        }
    }

    writeln();
}