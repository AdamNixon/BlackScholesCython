from setuptools import setup
from Cython.Build import cythonize

setup(
    ext_modules=cythonize("stock_simulator_wrapper.pyx", language_level="3"),
)