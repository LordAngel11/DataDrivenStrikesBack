# ---- Standard imports ----
import numpy as np
import tensorflow as tf

def mape_accuracy(y_true, y_pred):
    correct = tf.reduce_sum(tf.cast( tf.abs((y_true - y_pred)/y_pred) < 0.1, tf.int32), axis=1)
    total = y_true.shape[1]

    return (correct/total)*100

def mape_accuracy_log10(y_true, y_pred):
    correct = tf.reduce_sum(tf.cast(tf.abs(tf.divide(tf.subtract(tf.pow(tf.constant(10, dtype=tf.float32),y_true),tf.pow(tf.constant(10, dtype=tf.float32),y_pred)),tf.pow(tf.constant(10, dtype=tf.float32),y_true))) < 0.1, tf.int32), axis=1)
    total = y_true.shape[1]

    return (correct/total)*100

def mape_accuracy_p3(y_true, y_pred):
    correct = tf.reduce_sum(tf.cast(tf.abs(tf.divide(tf.subtract(tf.pow(y_true,tf.constant(3, dtype=tf.float32)),tf.pow(y_pred,tf.constant(3, dtype=tf.float32))),tf.pow(y_true,tf.constant(3, dtype=tf.float32)))) < 0.1, tf.int32), axis=1)
    total = y_true.shape[1]

    return (correct/total)*100

def her0_loss(y_true, y_pred):
    return tf.keras.losses.mean_absolute_error(y_true[:,:2], y_pred[:,:2]) + tf.keras.losses.mean_absolute_percentage_error(y_true[:,-1], y_pred[:,-1])
    
def her0_acc(y_true, y_pred):
    correct = tf.cast( tf.keras.losses.mean_absolute_percentage_error(y_true[:,-1], y_pred[:,-1]) < 10, tf.int32)
    return correct
    