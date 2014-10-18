#!/usr/bin/perl

use strictures 1;

use Test::More;

eval "use Test::Compile";
Test::More->builder->BAIL_OUT(
	"Test::Compile required for testing compilation")
	if $@;

all_pl_files_ok();
