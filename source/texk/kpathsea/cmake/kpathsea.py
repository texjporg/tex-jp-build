#!/usr/bin/env python3

import sys

def gen_kpathsea_h(kpathsea_h, headers):
    print('/* This is a generated file */', file=kpathsea_h)
    print('/* collecting all public kpathsea headers. */', file=kpathsea_h)
    for f in headers:
        print(f'#include <kpathsea/{f}>', file=kpathsea_h)

def main():
    kpathsea_h = sys.stdout
    try:
        if len(sys.argv) > 1 and sys.argv[1] != '-':
            kpathsea_h = open(sys.argv[1], 'w')
        gen_kpathsea_h(kpathsea_h, sys.argv[2:])
    finally:
        if kpathsea_h != sys.stdout:
            kpathsea_h.close()

if __name__ == "__main__":
    main()
