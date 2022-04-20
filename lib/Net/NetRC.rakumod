unit module Net::NetRC;

=begin pod

=head1 NAME

Net::NetRC - parse `.netrc` files

=head1 SYNOPSIS

=begin code :lang<raku>

use Net::NetRC;

my $x = netrc;

say $x<google.com><login>;

my $y = netrc 'machine azul.example.com login massa password j4k3';

say $y<azul.com><password>;

my $z = netrc '/home/myname/.netrc.alternate';

=end code

=head1 DESCRIPTION

Net::NetRC is a basic parser for the `.netrc` file format.

I made it as a simple way of obtaining logins and passwords for many other projects.

=head1 AUTHOR

Humberto Massa <humbertomassa@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright © 2022 Humberto Massa

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

my grammar NetRC {
    token TOP { ^ <ws> <macdef>*? [ <machine-definition> <ws> ]* $ }

    token machine-definition {
        [ <default-def> || <machine-def> ]
        [ <login-def> || <passwd-def> || <account-def> || <macdef> ]*
    }

    rule default-def { default }
    rule machine-def { machine (\S*) }
    rule login-def   { login (\S+) }
    rule passwd-def  { password (\S+) }
    rule account-def { account (\S+) }
    rule macdef      { macdef (\S+) <macline>* }

    token macline    { <!before [ default || machine || macdef ]> <content> \n \s* }

    token ws         { <!ww> \s*! [ '#' \s*! <content> \n \s* ]* }
    token content    { \N* }
}

my class Actions {
    use Hash::Agnostic;
    my class DefaultableHash does Hash::Agnostic {
        has %!storage;
        has $!default;
        method keys() { %!storage ?? ( '', %!storage.keys.sort.Slip, ) !! () }
        method AT-KEY($k) is raw { %!storage{$k} :exists ?? %!storage{$k} !! $!default }
        method ASSIGN-KEY($k, Mu \v) is raw { ( $k ?? %!storage{$k} !! $!default ) = v }
        method DELETE-KEY($k) is raw { $k ?? ( %!storage{$k}:delete ) !! ( $!default = Nil ) }
    }
    method TOP($/) {
        my @x = $/<machine-definition>.map({
            .<default-def machine-def>.Slip,
            .<login-def passwd-def account-def>».first(:end).Slip
        })».made».grep(*.so)».Hash;
        my DefaultableHash $h .= new;
        $h{ .<name> :delete } = $_ for @x;
        make $h
    }
    method default-def($/)  { make ( name => ''         ) }
    method machine-def($/)  { make ( name => ~$/[0]     ) }
    method login-def($/)    { make ( login => ~$/[0]    ) }
    method passwd-def($/)   { make ( password => ~$/[0] ) }
    method account-def($/)  { make ( account => ~$/[0]  ) }
}

multi sub netrc() is export {
    state $netrc = netrc "%*ENV<HOME>/.netrc".IO
}

multi sub netrc(IO() $handle) is export {
    netrc $handle.slurp
}

multi sub netrc(Str() $s) is export {
    return netrc $s.IO if $s.IO.r;
    my Actions $actions .= new;
    my $x = NetRC.parse( $s, :$actions ).made
}

