# BlackScholesCython

Example repo to run a threaded Black-Scholes pricing evaluation in C++ and call it in python via cython.

# install

Required packages
pip install cython python setuptools Pyside6

# Build

```
python setup.py build_ext --inplace
```
To create the cython and required `.so` or `.pyd` (aka windows DLL) file for the cpp.

Then to run the Gui
```
python gui.py
```

or to use the python directly
```
python test.py
```
