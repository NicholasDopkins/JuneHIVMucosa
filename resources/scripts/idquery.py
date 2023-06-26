#!/usr/bin/env python
import json
from collections import defaultdict
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--manifest', type=argparse.FileType('r'),
                    default='file-manifest.json',
                    help='GTEX manifest file')
parser.add_argument('infile', nargs='?', type=argparse.FileType('r'),
                    default=sys.stdin)
parser.add_argument('outfile', nargs='?', type=argparse.FileType('w'),
                    default=sys.stdout)

args = parser.parse_args()
samples = [l.strip() for l in args.infile]


# Load the manifest
manifest = json.load(args.manifest)
by_sampid = defaultdict(list)
for r in manifest:
    sampid = r['file_name'].split('.')[0]
    by_sampid[sampid].append(r)


print('\t'.join(['sample_id', 'file_name', 'md5sum', 'file_size', 'object_id']), file=args.outfile)
for q in samples:
    assert q in by_sampid, 'ERROR: could not find %s' % q
    bams = [f for f in by_sampid[q] if f['file_name'].split('.')[-1] == 'bam']
    if len(bams) == 1:
        print('\t'.join([q, bams[0]['file_name'], bams[0]['md5sum'], str(bams[0]['file_size']), bams[0]['object_id']]), file=args.outfile)
    else:
        print('ERROR: %d BAM files for %s' % (len(bams), q), file=sys.stderr)

