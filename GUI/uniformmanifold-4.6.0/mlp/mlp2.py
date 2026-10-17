#   AUTHORSHIP
#       Jonathan Ebrahimian <jebrahimian@mail.smu.edu>:  
#       Connor Meehan <connor.gw.meehan@gmail.com>: 
#       Stephen Meehan <swmeehan@stanford.edu>
#
#   Provided by the Herzenberg Lab at Stanford University.
#   License: BSD 3 clause
#
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


def mlp_train(csv_file_name, model_file_name, max_epochs):

    df = pd.read_csv(csv_file_name)

    columns = df.columns
    #get the element in columns that contains the string "Unnamed" and drop them
    unnamed_cols = [col for col in columns if 'Unnamed' in col]
    df = df.drop(unnamed_cols, axis=1)

    df.rename(columns={df.columns[-1]: 'target'}, inplace=True)

    # We are going to change the target variable to be values from 0-x.
    replace_dict = {}
    unreplace_dict = {}
    x = 0
    for val in np.sort(df.target.unique()):
        replace_dict[val] = x
        unreplace_dict[x] = val
        x += 1

    unique_classes = len(df.target.unique())


    # ML imports


    X = df.drop(['target'], axis=1)
    y = df.target

    # encode class values as integers
    encoder = LabelEncoder()
    encoder.fit(y)
    encoded_Y = encoder.transform(y)
    # convert integers to dummy variables (i.e. one hot encoded)
    dummy_y = to_categorical(encoded_Y)


    #apply standard scaler
    scaler = StandardScaler()
    X = scaler.fit_transform(X)


    input = Input(shape=(X.shape[1],), name='numeric')
    x_dense = Dense(units=100, activation='relu',name='dense1')(input)
    #add dropout
    x_dense = Dropout(0.25)(x_dense)
    x_dense = Dense(units=50, activation='relu',name='dense2')(x_dense)
    x_dense = Dense(units=25, activation='relu',name='dense3')(x_dense)
    x_dense = Dense(units=unique_classes, activation='softmax',name='dense4')(x_dense)


    dense_model = Model(inputs=input,
                    outputs=x_dense)

    dense_model.compile(optimizer=optimizers.Adam(),
                loss=losses.KLDivergence(),
                metrics=['accuracy'])

    history = dense_model.fit(X,
                        dummy_y,
                        epochs=max_epochs,
                        batch_size=128,
                        verbose=1
                        )
    if not os.path.dirname(model_file_name):

        # save this model to a file
        dense_model.save('./Models/' + model_file_name + '.h5')

        # save standard scaler
        dump(scaler, open('./Scalers/' + model_file_name + '.pkl', 'wb'))

        # save unreplace_dict
        dump(unreplace_dict, open('./Dicts/' + model_file_name + '.pkl', 'wb'))

    else:
        mfn = model_file_name.replace('~', str(Path.home()))
        dense_model.save(mfn + '.h5')
        dump(scaler, open(mfn + '_scale.pkl', 'wb'))
        dump(unreplace_dict, open(mfn + '_dict.pkl', 'wb'))

    return history.history["accuracy"][-1]


def mlp_predict(csv_file_name,model_file_name,csv_result_file_name,predictions_file_name):
    if not os.path.dirname(model_file_name):
        # load model
        model = safeLoadModel('./Models/' + model_file_name + '.h5')

        # load scaler
        scaler = load(open('./Scalers/' + model_file_name + '.pkl', 'rb'))

        # load unreplace_dict
        unreplace_dict = load(open('./Dicts/' + model_file_name + '.pkl', 'rb'))
    else:
        mfn = model_file_name.replace('~', str(Path.home()))
        model = safeLoadModel(mfn + '.h5')
        scaler = load(open(mfn + '_scale.pkl', 'rb'))
        unreplace_dict = load(open(mfn + '_dict.pkl', 'rb'))


    df = pd.read_csv(csv_file_name)

    X_test = scaler.transform(df)

    predictions_mat = model.predict(X_test)

    predictions = np.argmax(predictions_mat, axis=1)

    predictions_df = pd.DataFrame(predictions_mat)

    predictions_df.rename(columns=unreplace_dict, inplace=True)

    predictions_df.to_csv(predictions_file_name, index=False)

    
    #replace a value in a numpy array
    def replace_value(array, old_value, new_value):
        array[array == old_value] = new_value
        return array

    for key in unreplace_dict:
        replace_value(predictions, key, unreplace_dict[key])

    df['target'] = predictions

    df.to_csv(csv_result_file_name, index=False)

    return True

def mlp_predict2(input_data,model_file_name):
    if not os.path.dirname(model_file_name):
        # load model
        model = safeLoadModel('./Models/' + model_file_name + '.h5')

        # load scaler
        scaler = load(open('./Scalers/' + model_file_name + '.pkl', 'rb'))

        # load unreplace_dict
        unreplace_dict = load(open('./Dicts/' + model_file_name + '.pkl', 'rb'))
    else:
        mfn = model_file_name.replace('~', str(Path.home()))
        model = safeLoadModel(mfn + '.h5')
        scaler = load(open(mfn + '_scale.pkl', 'rb'))
        unreplace_dict = load(open(mfn + '_dict.pkl', 'rb'))

    X_test = scaler.transform(input_data)

    predictions_mat = model.predict(X_test)

    predictions = np.argmax(predictions_mat, axis=1)

    def replace_value(array, old_value, new_value):
        array[array == old_value] = new_value
        return array

    for key in unreplace_dict:
        replace_value(predictions, key, unreplace_dict[key])

    return predictions, predictions_mat

def safeLoadModel(modelNameWithExt):
    try:
        return load_model(modelNameWithExt)
    except:
        return load_model(modelNameWithExt, compile=False)


#main
if __name__ == "__main__":

    model_file_name = 'omip69'
    X = np.random.normal(0, 1, (8129, 29))
    model = 'C:/Users/conno/Documents/run_umap/examples/ustSamusikS1MlpPy'
    
    mlp_train('~/Documents/run_umap/examples/omip69Labeled.csv', 'omip69',1)
    #mlp_predict('~/Documents/run_umap/examples/omip69.csv',model_file_name,'~/Documents/run_umap/examples/omip69_mlp.csv','Predictions/omip69_predictions.csv')
    mlp_predict2(X, model)