#   AUTHORSHIP
#       Stephen Meehan <swmeehan@stanford.edu>
#       Connor Meehan <connor.gw.meehan@gmail.com>
#
#   Provided by the Herzenberg Lab at Stanford University.
#   License: BSD 3 clause
#
try:
    import sys
    import argparse
    import h5py
    import os
    from xml.parsers.expat import model
    import pandas as pd
    import numpy as np
    import matplotlib.pyplot as plt
    from sklearn.model_selection import train_test_split
    from tensorflow.keras.layers import Dense, Dropout, Activation, Flatten
    from tensorflow.keras.layers import Input
    from tensorflow.keras.models import Model
    from tensorflow.keras import losses
    from tensorflow.keras import optimizers
    from sklearn.preprocessing import LabelEncoder
    try:
        from tensorflow.keras.utils import to_categorical
        from tensorflow.keras.models import load_model
    except:
        import tensorflow.keras as keras
        from keras.utils.np_utils import to_categorical
        from keras.models import load_model
    from sklearn.preprocessing import StandardScaler
    from pickle import dump, load
    from pathlib import Path
    print('All imports essential to mlp.py are found')
    exit(0)
except ImportError as exc:
    print(exc)
    exit(100)
