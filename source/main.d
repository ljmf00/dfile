

module main;

import std.stdio, dfile;
import std.file : exists, isDir;

enum {
    PROJECT_NAME = "dfile",
    PROJECT_VERSION = "0.5.0"
}

private static int main(string[] args)
{
    size_t l = args.length;
    
    if (l <= 1)
    {
        print_help;
        return 0;
    }

    for (int i = 0; i < l; ++i)
    {
        switch (args[i])
        {
        case "-d", "--debug", "/d", "/debug":
            Debugging = true;
            writeln("Debugging mode turned on");
            break;
        case "-s", "--showname", "/s", "/showname":
            ShowingName = true;
            break;
        case "-m", "--more", "/m", "/more":
            Informing = true;
            break;
        /*case "-t", "/t":

            break;*/
        case "-h":
            print_help;
            return 0;
        case "--help", "/?":
            print_help_full;
            return 0;
        case "-v", "--version", "/v":
            print_version;
            return 0;
        default:
        }
    }

    string filename = args[l - 1]; // Last argument, no exceptions!

    if (exists(filename))
    {
        if (isDir(filename))
        {
            report("Directory");
            return 0;
        }
        else
        {
            if (Debugging)
                writefln("L%04d: Opening file...", __LINE__);
            CurrentFile = File(filename, "rb");
            
            if (Debugging)
                writefln("L%04d: Scanning...", __LINE__);
            scan(CurrentFile);
            
            if (Debugging)
                writefln("L%04d: Closing file...", __LINE__);
            CurrentFile.close();
        }
    }
    else
    {
        report("File does not exist");
        return 1;
    }

    return 0;
}

static void print_help()
{
    writefln("  Usage: %s [<Options>] <File>", PROJECT_NAME);
    writefln("         %s {-h|--help|-v|--version}", PROJECT_NAME);
}

static void print_help_full()
{
    writeln("  Usage: ", PROJECT_NAME, " [<Options>] <File>");
    writeln("Determine the file type.");
    writeln("  Option           Description (Default value)\n");
    writeln("  -m, --more       Print all information if available. (False)");
    writeln("  -s, --showname   Show filename before result. (False)");
    writeln("  -d, --debug      Print debugging information. (False)");
    writeln();
    writeln("  -h, --help, /?   Print help and exit");
    writeln("  -v, --version    Print version and exit");
}

static void print_version()
{
    debug
    writeln(PROJECT_NAME, " ", PROJECT_VERSION, "-debug (", __TIMESTAMP__, ")");
    else
    writeln(PROJECT_NAME, " ", PROJECT_VERSION, "  (", __TIMESTAMP__, ")");
    writeln("MIT License: Copyright (c) 2016-2017 dd86k");
    writeln("Project page: <https://github.com/dd86k/dfile>");
    writefln("Compiled %s with %s v%s",
        __FILE__, __VENDOR__, __VERSION__);
}