# ZSkate

![](Preview.gif)

Oh! A wild Zenly skateboard appears! 🛹⚡️

A quick POC on MKPointAnnotation moving using linear interpolation algorithms.

It contains two linear interpolation versions:

- a "naive" one which interpolates a fix number of points between a start and a destination point --> could be improved by computing the number of points to have a constant speed

- a "standard" one which interpolation is based on the time elapsed since the start and the destination time