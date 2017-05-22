@echo off
set "PATH=C:\Program Files\MATLAB\MATLAB Production Server\R2015a\bin;%PATH%"
mex -I. -L. -lml64i4m mma.c