# Area functions

import os
import pandas as pd
import numpy as np
import cv2
import imutils
import matplotlib.pyplot as plt
from skimage import io
import warnings

def thresholding(image, lower_thresh, upper_thresh=255):
    thresh = cv2.threshold(image, lower_thresh, upper_thresh, cv2.THRESH_BINARY)[1]
    return thresh

def resize_image(image, pix):
    image = cv2.resize(image, (pix, pix),
                       interpolation = cv2.INTER_CUBIC)
    return image

def gaussian_blur(image):
    image = cv2.GaussianBlur(image, (5, 5), 0)
    return image

def sum_area(rootDir, f, lower_thresh, resize,
             outdir=None, write_image=False):

    # Read in current file
    image = cv2.imread(f)
    
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Check dimensions (should be almost square)
    rows, cols, _ = image.shape
    if np.abs(rows - cols) > 150:
        print(f + ' is more than 150 pixels out of square')

    blurred = gaussian_blur(gray)

    thresh = thresholding(blurred, lower_thresh)
    
    if write_image:
      warnings.simplefilter('ignore', UserWarning)
      out_file = f[:-4] + "_" + str(lower_thresh) + ".JPG"
      io.imsave(os.path.join(outdir, out_file), thresh)

    area = np.sum(thresh == 255)
    return area
