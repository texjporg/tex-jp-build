#!/usr/bin/env python3
import argparse
import os.path
import re

option_verbose = False

def grep_version(file):
    pattern = re.compile("^.*'-([^']*)'.*$")
    with open(source, "r") as f:
        for l in f:
            m = pattern.match(l)
            if m:
                return m.group(1)
    return None

def main():
    global option_verbose

    parser = argparse.ArgumentParser()
    parser.add_argument("source")
    parser.add_argument("-o", "--output")
    parser.add_argument("-v", "--verbose", action="store_true")
    args = parser.parse_args()

    option_verbose = args.verbose

    source = args.source
    output = args.output

    try:
        version = grep_version(source)
        with open(output, "w") as f:
            write(f"#define UPTEX_VERSION \"{version}\"\n")
    except:
        os.unlink(output)

if __name__ == "__main__":
    main()
