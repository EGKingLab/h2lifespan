import os
import pandas as pd
import numpy as np
import cv2
import imutils
import matplotlib.pyplot as plt

def thresholding(image, lower_thresh, upper_thresh=255):
    thresh = cv2.threshold(image, lower_thresh, upper_thresh, cv2.THRESH_BINARY)[1]
    return thresh

def resize_sq_resize_first(file):
  image = cv2.imread(file)
  image = cv2.resize(image, (4000, 4000), interpolation = cv2.INTER_CUBIC)
  gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
  blurred = cv2.GaussianBlur(gray, (5, 5), 0)
  thresh = thresholding(blurred, 45)
  outfile = os.path.split(file)[1] + "_scaled.JPG"
  cv2.imwrite(outfile, thresh)

def resize_sq_resize_last(file):
  image = cv2.imread(file)
  gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
  blurred = cv2.GaussianBlur(gray, (5, 5), 0)
  thresh = thresholding(blurred, 45)
  thresh = cv2.resize(thresh, (4000, 4000), interpolation = cv2.INTER_CUBIC)
  outfile = os.path.split(file)[1] + "_scaled.JPG"
  cv2.imwrite(outfile, thresh)

def resize_rect(file):
  image = cv2.imread(file)
  gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
  blurred = cv2.GaussianBlur(gray, (5, 5), 0)
  thresh = thresholding(blurred, 45)
  outfile = os.path.split(file)[1] + "_rect_thresh.JPG"
  cv2.imwrite(outfile, thresh)

file = 'hd_hand_counted_masked/IMG_2521.JPG'
resize_sq(file)

file = 'hd_hand_counted_masked/IMG_2221.JPG'
resize_sq(file)

file = 'hd_hand_counted_masked_rect/IMG_2521.JPG'
resize_rect(file)

file = 'hd_hand_counted_masked_rect/IMG_2221.JPG'
resize_rect(file)

