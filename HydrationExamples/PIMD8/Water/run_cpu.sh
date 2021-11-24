#!/bin/bash

BIN="../../../BIN/ArbalestLight-FloatDoubleFixed.r3364"
ncores=8

conf="conf00.xml"
$BIN -C $conf --omp $ncores

conf="conf01.xml"
$BIN -C $conf --omp $ncores

conf="conf02.xml"
$BIN -C $conf --omp $ncores

conf="conf03.xml"
$BIN -C $conf --omp $ncores

conf="conf04.xml"
$BIN -C $conf --omp $ncores

conf="conf05.xml"
$BIN -C $conf --omp $ncores

conf="conf06.xml"
$BIN -C $conf --omp $ncores

conf="conf07.xml"
$BIN -C $conf --omp $ncores

conf="conf08.xml"
$BIN -C $conf --omp $ncores

conf="conf09.xml"
$BIN -C $conf --omp $ncores

conf="conf10.xml"
$BIN -C $conf --omp $ncores

conf="conf11.xml"
$BIN -C $conf --omp $ncores

conf="conf12.xml"
$BIN -C $conf --omp $ncores

conf="conf13.xml"
$BIN -C $conf --omp $ncores

conf="conf14.xml"
$BIN -C $conf --omp $ncores
