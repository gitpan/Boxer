package Boxer::Task;

use 5.010;
use autodie;
use strictures 1;
use utf8;

use Moo;
with 'MooX::Log::Any', 'Boxer::Role::Interact';

use Role::Commons -all;

our $AUTHORITY = 'cpan:JONASS';
our $VERSION   = '0.003';

1;
