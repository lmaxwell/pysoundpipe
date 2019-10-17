"""
pysoundpipe
"""
from __future__ import with_statement, print_function, absolute_import

from setuptools import setup, find_packages, Extension
from distutils.version import LooseVersion
from distutils.command.build_py import build_py as _build_py

import os
from glob import glob
from os.path import join

from setuptools.command.build_ext import build_ext as _build_ext
from distutils.command.clean import clean as _clean


import subprocess


DOCLINES = __doc__.split('\n')
_VERSION = '0.2.9'

class clean(_clean):
    def run(self):
        os.chdir("thirdparty/Soundpipe")
        command=['make','clean']
        subprocess.call(command)
        os.chdir("../..")
        super().run()




class build_ext(_build_ext):
    def finalize_options(self):
        _build_ext.finalize_options(self)
        # Prevent numpy from thinking it is still in its setup process:
        __builtins__.__NUMPY_SETUP__ = False
        import numpy
        self.include_dirs.append(numpy.get_include())
    def run(self):
        os.chdir("thirdparty/Soundpipe")
        command=['make']
        subprocess.call(command)
        os.chdir("../..")
        super().run()

world_src_top = "../modules"
world_sources = glob(join(world_src_top, "*.c"))

ext_modules = [
    Extension(
        name="pysoundpipe",
        sources=["pysoundpipe/pysoundpipe.pyx"],
        libraries=["soundpipe","m","sndfile"],
        library_dirs=["thirdparty/Soundpipe"],
        include_dirs=["thirdparty/Soundpipe/h"],
        language="c")]

setup(
    name="pysoundpipe",
    description=DOCLINES,
    long_description='\n'.join(DOCLINES[2:]),
    ext_modules=ext_modules,
    cmdclass={
        'clean': clean,
        'build_ext': build_ext
    },
    version='0.1.0',
    packages=find_packages(),
    setup_requires=[
        'numpy',
    ],
    install_requires=[
        'numpy',
        'cython>=0.24.0',
    ],
    extras_require={
        'test': ['nose'],
        'sdist': ['numpy', 'cython'],
    },
    author="",
    author_email="",
    url="",
    keywords=[''],
    classifiers=[],
)