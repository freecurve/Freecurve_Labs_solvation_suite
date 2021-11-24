#!/bin/bash

BIN_GPU="../../../BIN/ArbalestLight-FloatDoubleFixed-Cuda.r3364"
gpu_yes=1

conf="conf00.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf01.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf02.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf03.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf04.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf05.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf06.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf07.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf08.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf09.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf10.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf11.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf12.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf13.xml"
$BIN_GPU -C $conf --gpu $gpu_yes

conf="conf14.xml"
$BIN_GPU -C $conf --gpu $gpu_yes
