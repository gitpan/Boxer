#!/usr/bin/perl

use strictures 1;

use Test::More tests => 3;
use App::Cmd::Tester;

use Boxer::CLI;

my $result = test_app( 'Boxer::CLI' => [qw(help)] );

like( $result->stdout, qr/Available commands:/, 'printed what we expected' );

is( $result->stderr, '', 'nothing sent to sderr' );

is( $result->error, undef, 'threw no exceptions' );
