#! /usr/bin/env python
# -*- coding: utf-8 -*-

#read in the metadata, and pharse into sample 
META = pd.read_csv(config['metadata'],header = 0)
META.set_index(config['sample_id'],inplace = True, drop = False)
samples = META[config['sample_id']].unique().tolist()



