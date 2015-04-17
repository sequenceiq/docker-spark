#!/bin/bash
PYSPARK_DRIVER_PYTHON=ipython PYSPARK_DRIVER_PYTHON_OPTS="notebook --ip=0.0.0.0 --no-browser --notebook-dir=/ipython" pyspark
