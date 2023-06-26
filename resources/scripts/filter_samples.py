#!/usr/bin/env python

import sys
import argparse
from collections import Counter

parser = argparse.ArgumentParser()
parser.add_argument('--query', action='append', 
                    help='Filter criteria of the form "VARNAME=VALUE"')
parser.add_argument('infile', nargs='?', type=argparse.FileType('r'),
                    default=sys.stdin)
parser.add_argument('outfile', nargs='?', type=argparse.FileType('w'),
                    default=sys.stdout)

args = parser.parse_args()

qlist = []
for q in args.query:
    qlist.append(q.split('='))

def check_row(r):
    return all(r[varname] == val for varname, val in qlist)

lines = (l.strip('\n').split('\t') for l in args.infile)
header = next(lines)
rows = []
for l in lines:
    rows.append(dict(zip(header,l)))
    
# print('\n'.join('%s\t%d' % t for t in Counter(r['SMAFRZE'] for r in rows).most_common()))
# 
# rows = [r for r in rows if r['SMAFRZE'] == 'RNASEQ']
# 
# 
# print('\n'.join('%s\t%d' % t for t in Counter(r['SMTS'] for r in rows).most_common()))
# print('\n'.join('%s\t%d' % t for t in Counter(r['SMTSD'] for r in rows).most_common()))

sel = []
for r in rows:
    if check_row(r):
        sel.append(r)
        

print('\t'.join(header), file=args.outfile)
for r in sel:
    print('\t'.join(r[h] for h in header), file=args.outfile)
