package Apache2::ClickPath::StoreClient;

use 5.008;
use strict;
use warnings;
no warnings qw(uninitialized);
use Storable ();
use LWP::UserAgent;
use LWP::ConnCache;
use Class::Member qw{session store store_is_local ua lasterror _r};

my $MOD_PERL;

BEGIN {
  $MOD_PERL=0;
  if( exists $ENV{MOD_PERL} and $ENV{MOD_PERL_API_VERSION}==2 ) {
    $MOD_PERL=2;
    require Apache2::RequestRec;
    require Apache2::RequestUtil;
  }
}

sub new {
  my $class=shift;
  my $I=bless {}=>ref($class)||$class;

  if( $MOD_PERL ) {
    $I->_r=Apache2::RequestUtil->request;
    $I->session=$I->_r->subprocess_env('SESSION');
    $I->store=$I->_r->subprocess_env('ClickPathMachineStore');

    #$I->store_is_local=$I->store=~m!^/!;
    if( $I->store=~m!^/! ) {
      my $https=($I->_r->subprocess_env('HTTPS')=~/on/i ? 'https' : 'http');
      $I->store=("$https://".$I->_r->get_server_name.":".
		 $I->_r->get_server_port.$I->store);
    }
  } else {
    $I->session=$ENV{SESSION};
    $I->store=$ENV{ClickPathMachineStore};
    if( $I->store=~m!^/! ) {
      my $https=($ENV{HTTPS}=~/on/i ? 'https' : 'http');
      if( length $ENV{HTTP_HOST} ) {
	my $host=$ENV{HTTP_HOST};
	$host=~s/:\d+$//;
	$I->store="$https://$host:$ENV{SERVER_PORT}".$I->store;
      } else {
	$I->store="$https://$ENV{SERVER_ADDR}:$ENV{SERVER_PORT}".$I->store;
      }
    }
  }

  return unless( length $I->store );

  #unless( $I->store_is_local ) {
    $I->ua=LWP::UserAgent->new( timeout=>5,
				keep_alive=>3 );
  #}

  return $I;
}

sub _get {
  my ($I,$k)=@_;

#  if( $I->store_is_local ) {
#  } else {
    my $res=$I->ua->post( $I->store, {'a'=>'get',
				      's'=>$I->session,
				      'k'=>$k} );
    $I->lasterror=$res->code;
    return $res->content if( $res->code==200 );
    return;
#  }
}

sub _set {
  my ($I,$k,$v)=@_;

#  if( $I->store_is_local ) {
#  } else {
    my $res=$I->ua->post( $I->store, {'a'=>'set',
				      's'=>$I->session,
				      'k'=>$k,
				      'v'=>$v} );
    $I->lasterror=$res->code;
    return 1 if( $res->code==200 );
    return;
#  }
}

sub get {
  my $I=shift;
  my $k=shift;

  my $res=Storable::thaw($I->_get( $k ))||[];
  if( wantarray ) {
    return @{$res};
  } else {
    return $res->[0];
  }
}

sub set {
  my $I=shift;
  my $k=shift;
  return $I->_set( $k, Storable::nfreeze( \@_ ) );
}

1;

__END__

=head1 NAME

Apache2::ClickPath::StoreClient - an Apache2::ClickPath::Store client

=head1 SYNOPSIS

 use Apache2::ClickPath::StoreClient;

 my $store=Apache2::ClickPath::StoreClient->new;
 my $val=$store->get( 'val' );
 unless( $store->set( val=>$v ) ) {
   my $code=$store->lasterror;
   ...
 }

=head1 DESCRIPTION

C<Apache2::ClickPath::Store> and C<Apache2::ClickPath::StoreClient> can
be used in conjunction with C<Apache2::ClickPath> to store arbitrary
information for a session. The information itself is stored on a WEB
server and accessed via HTTP. C<Apache2::ClickPath::Store> implements the
server side and C<Apache2::ClickPath::StoreClient> the client side.

For more information see the L<Apache2::ClickPath::Store> manpage.

C<Apache2::ClickPath::StoreClient> provides a OO interface to the data
stored in an C<Apache2::ClickPath::Store>. It uses the information exported
by C<Apache2::ClickPath> to find the correct store.

C<Apache2::ClickPath::StoreClient> can be used from within a mod_perl handler
or a CGI script.

If called from a mod_perl handler it requires the GlobalRequest to be set.
See L<Apache2::RequestUtil> for more information.

For communication with the store an L<LWP::UserAgent> is used. It is
configured to use keep-alive requests.

=head1 METHODS

=over 4

=item B<< Apache2::ClickPath::StoreClient->new >>

the constructor. It uses the environment variables C<SESSION> and
C<ClickPathMachineStore> to initiate itself. These variables are exported
from L<Apache2::ClickPath>. The store address is given as the 3rd column
of a C<ClickPathMachineTable>. It can be either an absolute URL like
C<http://server.com/store> or a URI without the server part (C</store>).
In the second case the store is assumed to be located on the same WEB server
(in terms of Hostname or IP address, port and protocol (HTTP or HTTPS)).

=item B<< $store->set( name => $value1, $value2, ... ) >>

The C<set> method is used to write a data item.

On success 1 is returned on failure undef. If there was an error the HTTP
response code of the last store operation can be fetched using C<lasterror()>.

=item B<< @list=$store->get( 'name' ) >>

returns a previously stored data item. In scalar context the first data
element is returned.

On error undef is returned. The reason can be examined via C<lasterror()>.

=item B<< $code=$store->lasterror >>

returns the HTTP status code of the last store operation. See
L<Apache2::ClickPath::Store> for a list of possible codes.

=item B<< $ua=$store->ua >> or B<< $store->ua=$ua >>

provides access to the internal L<LWP::UserAgent>. In case the store is
behind a proxy this can be useful.

=back

=head1 SEE ALSO

L<Apache2::ClickPath>
L<Apache2::ClickPath::Store>
L<LWP::UserAgent>
L<http://perl.apache.org>,
L<http://httpd.apache.org>

=head1 AUTHOR

Torsten Foertsch, E<lt>torsten.foertsch@gmx.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004-2005 by Torsten Foertsch

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
