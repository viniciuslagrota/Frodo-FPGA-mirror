@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.1 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Mon Jan 13 21:23:01 -0300 2020
REM SW Build 2552052 on Fri May 24 14:49:42 MDT 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
echo "xelab -wto 804d6e98d5984fb3a5b4957ce1db6a1f --incr --debug typical --relax --mt 2 -L work -L secureip --snapshot testbench_behav work.testbench -log elaborate.log"
call xelab  -wto 804d6e98d5984fb3a5b4957ce1db6a1f --incr --debug typical --relax --mt 2 -L work -L secureip --snapshot testbench_behav work.testbench -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0