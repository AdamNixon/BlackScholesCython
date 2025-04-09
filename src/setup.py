from setuptools import setup, Extension
from Cython.Build import cythonize

# Define the extension module
ext_modules = [
    Extension(
        "monte_carlo_wrapper",                  # Module name
        sources=["monte_carlo_wrapper.pyx", "monte_carlo.cpp"],  # Source files
        language="c++",                 # Specify C++ language
        extra_compile_args=["-std=c++20"],  # C++11 for threading
    )
]

# Setup configuration
setup(
    name="monte_carlo_option_pricer",
    ext_modules=cythonize(ext_modules, language_level="3"),
)