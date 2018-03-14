# coding: utf-8

import os
import pandas as pd
import numpy as np
import cv2
import imutils
import matplotlib.pyplot as plt

from Area import thresholding, sum_area

write_images = False

rootDir = '../../../hd_hand_counted_masked/'

# Do all thresholds from 30 to 85 by 1. Filter them later.
lower_threshes = np.arange(30, 86, 1)
outfile = '../../Data/Processed/area_summation_HC.csv'

# Get list of handcounted images from hd_hand_counted
M = pd.read_excel('../../Data/Processed/hd_hand_counted.xlsx')

# Get list of bad images
bad_images = pd.read_excel('../../Data/Processed/bad_images.xlsx')
bad_images = bad_images.loc[bad_images.status == 'bad']

# Drop rows from handcounted images that are bad
M = M.loc[~(M.camera_id.isin(bad_images.cameraid))]

# Drop rows without images
file_list = M.camera_id.dropna()

# Check for duplicated images names
if len(set(file_list)) < len(file_list):
    print('There are {} duplicate rows in feclife_with-image-ids.xlsx.'.format(len(file_list) - len(set(file_list))))
else:
    print('No duplicate image names in hd_hand_counted.xlsx')  

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
# M_no_handcount = M.loc[M.handcounted != 'yes', ]
# M_no_handcount = M_no_handcount.loc[M_no_handcount.visually_recheck != 'yes', ]
# M_no_handcount = M_no_handcount.loc[M_no_handcount.test_case != 'yes', ]
missing_images = M.camera_id[~(M.camera_id.isin(filelist))]
print('Images that should be in h2_fec_images but are not:\n')
print(missing_images)

M = M.loc[M.camera_id.isin(filelist), ]
print('Using {} images.'.format(str(len(M))))

##############################################################################

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
