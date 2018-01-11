# coding: utf-8

import os
import pandas as pd
import numpy as np
import cv2
import imutils
import matplotlib.pyplot as plt

# Force matplotlib to not use any Xwindows backend.
plt.switch_backend('agg')

import Area


# Find images

rootDir = 'hd_hand_counted_masked_test/'

for dirName, subdirList, fileList in os.walk(rootDir, topdown=False):
    for fname in fileList:
        if fname.endswith(('JPG', 'jpg')):
            infile = os.path.join(dirName, fname)
            img = cv2.imread(infile)
            img_thresh = Area.thresholding(img, 44)
            img_resize = Area.resize_image(img, 1000)
            img_resize = Area.thresholding(img_resize, 44)
            
            fig, ax = plt.subplots(nrows=1, ncols=3)
            plt.subplot(1, 3, 1)
            plt.imshow(img, cmap=plt.cm.gray)

            plt.subplot(1, 3, 2)
            plt.imshow(img_thresh, cmap=plt.cm.gray)

            plt.subplot(1, 3, 3)
            plt.imshow(img_resize, cmap=plt.cm.gray)
            
            outfile = os.path.join(dirName, fname) + '_diag.jpg'
            plt.savefig(outfile)
            plt.close(fig)


# Threshold image

# Resize w/ new name

# output panel images

# If everything fails, perhaps we could use the size of the square to correct the area
