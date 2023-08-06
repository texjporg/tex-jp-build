#!/usr/bin/env python3

import re
import sys

def cnf_to_paths(cnf, paths):
    preline = ""
    for line in cnf:
        line = preline + line
        preline = ""
        line = line.strip('\n')
        if line.endswith('\\'):
            preline = line[:-1]
            continue

        line = re.sub(r'%.*', '', line)
        line = re.sub(r'^[ \t]*', '', line)
        line = re.sub(r'[ \t]*$', '', line)

        if re.search(r'^[ \t]*[A-Z0-9_]+[ \t]*=', line):
            ident = line
            ident = re.sub(r'^[ \t]*', '', ident)
            ident = re.sub(r'[ \t]*=.*', '', ident)

            val = line
            val = re.sub(r'^.*=[ \t]*', '', val)
            val = re.sub(r'[ \t]*$', '', val)
            
            if re.search(r'\$SELFAUTO', val):
                val = re.sub(r';', ':', val)
            elif re.search(r'^/', val):
                val = re.sub(r';', ':', val)
            else:
                val = "/nonesuch"

            print('#ifndef DEFAULT_' + ident, file=paths)
            print('#define DEFAULT_' + ident + ' "' + val + '"', file=paths)
            print('#endif', file=paths)
            print('', file=paths)

def main():
    cnf = sys.stdin
    paths = sys.stdout
    try:
        if len(sys.argv) > 1 and sys.argv[1] != '-':
            cnf = open(sys.argv[1], 'r')
        if len(sys.argv) > 2 and sys.argv[2] != '-':
            paths = open(sys.argv[2], 'w')
        cnf_to_paths(cnf, paths)
    finally:
        if cnf != sys.stdin:
            cnf.close()
        if paths != sys.stdout:
            paths.close()

if __name__ == "__main__":
    main()
