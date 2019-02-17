@echo off
set "PATH=C:\Program Files\MATLAB\R2016b\bin;%PATH%"
mex -I. -L. -lml64i4m mma.c