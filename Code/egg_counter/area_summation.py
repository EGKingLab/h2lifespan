# coding: utf-8

import os
import pandas as pd
import numpy as np
import cv2
import imutils
import matplotlib.pyplot as plt

from Area import thresholding, sum_area

write_images = False

rootDir = '../../../h2_fec_images/'

# Do all thresholds from 30 to 151 by 1. Filter them later in R code.
lower_threshes = np.arange(30, 151, 1)
outfile = '../../Data/Processed/area_summation.csv'

infiles = []

# Get list of files
for dirName, subdirList, fileList in os.walk(rootDir, topdown=False):
    for fname in fileList:
        if fname.endswith(('JPG', 'jpg')):
            infile = os.path.join(dirName, fname)
            infiles.append(infile)

nrows = len(infiles) * len(lower_threshes)
print(str(nrows) + ' combinations to check')

areas = pd.DataFrame(index=list(range(nrows)),
                     columns=['cameraid', 'lower_thresh', 'area'])

ctr = 0

for f in infiles:
    for lower_thresh in lower_threshes:
        area = sum_area(rootDir, f, lower_thresh, resize = False)
        areas.iloc[ctr] = [f.split('/')[4], lower_thresh, area]
        ctr += 1
        if ctr % 200 == 0:
            print(str(ctr) + " complete")

areas.to_csv(outfile, index=False)

# area_summation.csv is resaved as a compressed Rda in R.
