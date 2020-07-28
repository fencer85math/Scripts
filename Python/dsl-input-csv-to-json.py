#!/usr/bin/env python
# Uses a designated csv file to create individual JSON files.
# By: Adrian Steffen

from __future__ import (print_function)
from collections import namedtuple
import csv
import fileinput
import json
import sys
import os.path

def process(filetoprocess):
        f_csv = csv.reader(filetoprocess)
        headings = next(f_csv)
        Row = namedtuple('Row', headings)
        for r in f_csv:
            row = Row(*r)
            # Get file name to look for
            jsonFileName = 'input-' + row.UUID + '.json'
            # if file exists, open and append new attribute
            if os.path.isfile(jsonFileName):
                with open(jsonFileName) as fp:
                    data = json.load(fp)
                    # process: add new attribute
                newAttribute = {
                    'name': row.name,
                    'timestamp': row.timestamp,
                    'value': row.value,
                    'unit': row.unit,
                    'featureSource': 'HRA',
                    'inputType': 'Self_Entered'
                    }
                data['attributes'].append(newAttribute)
                with open(jsonFileName, 'w') as fp:
                    json.dump(data, fp)
            # Else, create new json file with uuid
            else:
            #process row
                model = {
                  "metadata": {
                    "fingerprint": None,
                    "timestamp": row.timestamp
                  },
                  "user": {
                    "identifier": row.UUID
                  },
                  'attributes': [{
                    'name': row.name,
                    'timestamp': row.timestamp,
                    'value': row.value,
                    'unit': row.unit,
                    'featureSource': 'HRA',
                    'inputType': 'Self_Entered'
                  }]
                }
            
                with open(jsonFileName, 'w') as g:
                    json.dump(model, g, indent=2)

if '__main__' == __name__:
    if 2 != len(sys.argv):
        print('usage: program <file>', file=sys.stderr)
        sys.exit(1)
    else:
        if '-' == sys.argv[1]:
            process(sys.stdin)
        else:
            with open(sys.argv[1]) as f:
                process(f)
        sys.exit(0)
