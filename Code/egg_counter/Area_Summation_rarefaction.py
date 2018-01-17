# coding: utf-8

import os
import pandas as pd
import numpy as np
import cv2
import imutils
import matplotlib.pyplot as plt

from Area import thresholding, sum_area

write_images = False
coarse = False

rootDir = '../../../h2_fec_images/'

if coarse:
    outfile = '../../Data/Processed/area_summation_coarse.csv'
else:
    outfile = '../../Data/Processed/area_summation_fine.csv'

M = pd.read_excel('../../Data/Processed/feclife_with-image-ids.xlsx')

# Drop rows labeled 'missing'
M = M.loc[M.camera_id != 'missing']

# Drop rows without images
file_list = M.camera_id.dropna()

# Check for duplicated images names
if len(set(file_list)) < len(file_list):
    print('There are {} duplicate rows in feclife_with-image-ids.xlsx.'.format(len(file_list) - len(set(file_list))))
else:
    print('No duplicate image names in feclife_with-image-ids.xlsx')  

infiles = []

# Get list of files
for dirName, subdirList, fileList in os.walk(rootDir, topdown=False):
    for fname in fileList:
        if fname.endswith(('JPG', 'jpg')):
            infile = os.path.join(dirName, fname)
            infiles.append(infile)

filelist = [(x.split('/')[4]) for x in infiles]
print('{} image files'.format(len(filelist)))

##############################################################################
# Check the images not in the filelist and vice versa
# Keep only the rows in M that have files.
M_no_handcount = M.loc[M.handcounted != 'yes', ]
M_no_handcount = M_no_handcount.loc[M_no_handcount.visually_recheck != 'yes', ]
M_no_handcount = M_no_handcount.loc[M_no_handcount.test_case != 'yes', ]
missing_images = M_no_handcount.camera_id[~(M_no_handcount.camera_id.isin(filelist))]
print('Images that should be in h2_fec_images but are not:\n')
print(missing_images)

M = M.loc[M.camera_id.isin(filelist), ]
print('Using {} images.'.format(str(len(M))))

##############################################################################

if coarse:
    lower_threshes = np.arange(30, 85, 5)
else:
    lower_threshes = np.arange(40, 51, 1)

nrows = len(M) * len(lower_threshes)

print(str(nrows) + ' combinations to check')

areas = pd.DataFrame(index=list(range(nrows)),
                     columns=['camera_id', 'lower_thresh', 'area'])

ctr = 0

for index, row in M.iterrows():
    for lower_thresh in lower_threshes:
        area = sum_area(rootDir, row, lower_thresh, resize = False)
        areas.iloc[ctr] = [row.camera_id, lower_thresh, area]
        ctr += 1
        if ctr % 200 == 0:
            print(str(ctr) + " complete")

areas.to_csv(outfile, index=False)
