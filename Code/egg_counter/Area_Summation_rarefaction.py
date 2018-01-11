# coding: utf-8

import os
import pandas as pd
import numpy as np
import cv2
import imutils
import matplotlib.pyplot as plt

from Area import thresholding, sum_area

outfile = 'area_summation_fine.csv'

M = pd.read_excel('../hd_hand_counted/hd_hand_counted.xlsx')

if len(set(M.camera_id)) < len(M):
    print('There are {} duplicate rows in hd_hand_counted.xlsx.'.format(len(M) - len(set(M.camera_id))))

# Drop bad images
M = M[M.status != 'bad']

infiles = []

# FIXME
rootDir = 'hd_hand_counted_masked/'

for dirName, subdirList, fileList in os.walk(rootDir, topdown=False):
    for fname in fileList:
        if fname.endswith(('JPG', 'jpg')):
            infile = os.path.join(dirName, fname)
            infiles.append(infile)

filelist = [(x.split('/')[1]) for x in infiles]
print('{} files'.format(len(filelist)))

##############################################################################
# Check the images not in the filelist and vice versa
# Keep only the rows in M that have files.
df = M[M.camera_id.isin(filelist)]
print('Using {} images.'.format(str(len(M))))

##############################################################################

lower_threshes = np.arange(40, 51, 1)

nrows = len(df) * len(lower_threshes)

print(str(nrows) + ' combinations to check')

areas = pd.DataFrame(index=list(range(nrows)),
                     columns=['camera_id', 'lower_thresh', 'area'])

ctr = 0

for index, row in df.iterrows():
    for lower_thresh in lower_threshes:
        area = sum_area(rootDir, row, lower_thresh, resize = False)
        areas.iloc[ctr] = [row.camera_id, lower_thresh, area]
        ctr += 1
        if ctr % 200 == 0:
            print(str(ctr) + " complete")

areas.to_csv(os.path.join(rootDir, outfile), index=False)
