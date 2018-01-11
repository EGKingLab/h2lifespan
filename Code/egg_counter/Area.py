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

def sum_area(rootDir, row, lower_thresh, resize,
             outdir=None, write_image=False):
    file = rootDir + row.camera_id

    # Read in current file
    image = cv2.imread(file)
    
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    if resize:
        # Resize to 4000,4000
        gray = resize_image(gray, 4000)

    # !!!! Check image size, if square then resize
    # Check dimensions (should be landscape), rotate if necessary
    # Use rotate_bound from imutils here to avoid cropping
    # rows, cols, _ = image.shape
    # if rows > cols:
    #     image = imutils.rotate_bound(image, -90)
    # 
    # if rows != 3456 or cols != 5184:
    #     raise ValueError('Bad image dimensions. Should be 3456 x 5184.')

    blurred = gaussian_blur(gray)

    thresh = thresholding(blurred, lower_thresh)
    
    if write_image:
      warnings.simplefilter('ignore', UserWarning)
      io.imsave(os.path.join(outdir, row.camera_id), thresh)

    area = np.sum(thresh == 255)
    return area