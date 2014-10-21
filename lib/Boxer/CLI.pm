package Boxer::CLI;

use 5.01;
use strictures 1;
use utf8;

use App::Cmd::Setup -app;

use Role::Commons -all;

our $AUTHORITY = 'cpan:JONASS';
our $VERSION   = '0.003';

1;

__END__

=head1 NAME

Boxer::CLI - boxer command line utils

=head1 SYNOPSIS

 use Boxer::CLI;
 BOXER::CLI->run;

=head1 DESCRIPTION

Support library for the L<boxer> command-line tool.

=head1 SEE ALSO

L<boxer>, L<Boxer>.

=head1 AUTHOR

Jonas Smedegaard E<lt>dr@jones.dkE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013-2014 by Jonas Smedegaard.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
