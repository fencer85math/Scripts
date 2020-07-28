#!/usr/bin/env python
# converts JSON file into a csv format.
# By: Adrian Steffen

from __future__ import (print_function)
from collections import namedtuple
import csv
import fileinput
import json
import sys

def attributerowgeneration(stuff)
    newrow = []
    newrow.append(stuff['UUID'])
    newrow.append(stuff['attributename'])
    newrow.append(stuff['attributetimestamp'])
    newrow.append(stuff['attributevalue'])
    newrow.append(stuff['attributeunit'])
    newrow.append(stuff['attributefeatureSource'])
    newrow.append(stuff['attributeinputType'])

    return newrow

def segmentrowgeneration(stuff)
    newrow = []
    newrow.append(stuff['ntname'])
    newrow.append(stuff['timestamp'])
    newrow.append(stuff['value'])
    newrow.append(stuff['expires'])
    newrow.append(stuff['segmentfeatureSource'])
    
    return newrow
    

def process(filetoprocess):
    data = json.load(filetoprocess)
    print("this is the json loaded")
    print(data)

    # get user headers
    user1 = data['user']
    userheader = ['identifier']
    userdatarow = [user1['identifier']]

    # get metadata headers
    metadata1 = data['metadata']
    metadataheader = ['timestamp']
    metadatadatarow = [metadata1['timestamp']]

    # get attribute headers
    attribute1 = data['attributes']
    attributeheader = headerlist(attribute1, 'attribute')
    attributedatarow = sectionlist(attribute1)

    # get segments headers
    segment1 = data['segments']
    segmentheader = headerlist(segment1, 'segment')
    segmentdatarow = sectionlist(segment1)

    # get error headers
    errors1 = data['errors']
    errorheader = errors1

    headerrowlist = generaterow(metadataheader,userheader,attributeheader,segmentheader,errorheader)
    print("this is the header list")
    print(headerrowlist)
    print(len(headerrowlist))
    datarowlist = generaterow(metadatadatarow,userdatarow,attributedatarow,segmentdatarow,errors1)
    print("this is a row of data")
    print(datarowlist)
    print(len(datarowlist))

    with open('output.csv','w') as f:
        f_csv=csv.DictWriter(f,headerrowlist)
        f_csv.writeheader()
#        f_csv.writerows(datarowlist)

if '__main__' == __name__:
    if 2 != len(sys.argv):
        print('usage: program <jsonfile>', file=sys.stderr)
        sys.exit(1)
    else:
        if '-' == sys.argv[1]:
            process(sys.stdin)
        else:
            with open(sys.argv[1]) as f:
                process(f)
        sys.exit(0)
