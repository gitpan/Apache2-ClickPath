package Apache2::ClickPath::_parse;

use strict;

sub MachineTable {
  my $conf=shift;
  my $t={};
  my $r={};
  my $i=0;
  foreach my $line (split /\r?\n/, $conf) {
    next if( $line=~/^\s*#/ ); 	# skip comments
    $i++;
    my @l=$line=~/\s*(\S+)(?:\s+(\w+)(?:\s+(.+))?)?/;
    $l[2]=~s/\s*$// if( defined $l[2] ); # strip trailing spaces
    if( @l ) {
      $l[1]=$i unless( defined $l[1] );
      if( $l[0]=~/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/ and
	  $1<256 and $2<256 and $3<256 and $4<256 ) {
	$t->{$l[0]}=[@l[1,2]];
	$r->{$l[1]}=[@l[0,2]];
      } else {
	my @ip;
	(undef, undef, undef, undef, @ip)=gethostbyname( $l[0] );
	warn "WARNING: Cannot resolve $l[0] -- ignoring\n" unless( @ip );
	$r->{$l[1]}=[sprintf( '%vd', $ip[0] ), $l[2]];
	foreach my $ip (@ip) {
	  $t->{sprintf '%vd', $ip}=[@l[1,2]];
	}
      }
    }
  }
  return $t, $r;
}

sub UAExceptions {
  my $conf=shift;
  my $a=[];
  foreach my $line (split /\r?\n/, $conf) {
    if( $line=~/^\s*(\w+):?\s+(.+?)\s*$/ ) {
      push @{$a}, [$1, qr/$2/];
    }
  }
  return $a;
}

sub FriendlySessions {
  my $conf=shift;
  my $t={};
  my $r={};

  foreach my $l (split /\r?\n/, $conf) {

    next unless( $l=~/^\s*(\S+)\s+	# $1: friendly REMOTE_HOST
                      (			# $2: list of "uri( number )" or
                       (?:		#     "param( name )" statements
		        (?:uri|param)\s*
		        \(
		          \s*\w+\s*
                        \)\s*
                       )+
                      )
                      (?:\s*(\w+))?	# $3: opt. name, default=REMOTE_HOST
                     /x );

    my ($rem_host, $stmt_list, $name)=($1, $2, $3);
    $name=$rem_host unless( defined $name );

    my @stmts;
    while( $stmt_list=~/(uri|param)\s*\(\s*(\w+)\s*\)/g ) {
      push @stmts, [$1, $2];
    }

    $t->{$rem_host}=[[@stmts], $name];
    $r->{$name}=$rem_host;
  }

  return $t, $r;
}

1;
