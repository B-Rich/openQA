# Copyright (C) 2014 SUSE Linux Products GmbH
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

BEGIN {
  unshift @INC, 'lib', 'lib/OpenQA/modules';
}

use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use OpenQA::Test::Case;
use OpenQA::API::V1::Client;

OpenQA::Test::Case->new->init_data;

my $t = Test::Mojo->new('OpenQA');
my $client = OpenQA::API::V1::Client->new('PERCIVALKEY02', 'PERCIVALSECRET02');

my $ret;

my $iso = 'openSUSE-13.1-DVD-i586-Build0091-Media.iso';

$ret = $client->call('get_ok', Mojo::URL->new('/api/v1/jobs/99927'), {}, $t)->status_is(200);
is($ret->tx->res->json->{job}->{state}, 'scheduled', 'job 99927 is scheduled');
$ret = $client->call('get_ok', Mojo::URL->new('/api/v1/jobs/99928'), {}, $t)->status_is(200);
is($ret->tx->res->json->{job}->{state}, 'scheduled', 'job 99928 is scheduled');
$ret = $client->call('get_ok', Mojo::URL->new('/api/v1/jobs/99963'), {}, $t)->status_is(200);
is($ret->tx->res->json->{job}->{state}, 'running', 'job 99963 is running');

# schedule the iso, this should not actually be possible. Only isos
# with different name should result in new tests...
$ret = $client->call('post_ok', Mojo::URL->new('/api/v1/isos'), { iso => $iso}, $t)->status_is(200);

# check that the old tests are cancelled
$ret = $client->call('get_ok', Mojo::URL->new('/api/v1/jobs/99927'), {}, $t)->status_is(200);
is($ret->tx->res->json->{job}->{state}, 'cancelled', 'job 99927 is cancelled');
$ret = $client->call('get_ok', Mojo::URL->new('/api/v1/jobs/99928'), {}, $t)->status_is(200);
is($ret->tx->res->json->{job}->{state}, 'cancelled', 'job 99928 is cancelled');
$ret = $client->call('get_ok', Mojo::URL->new('/api/v1/jobs/99963'), {}, $t)->status_is(200);
is($ret->tx->res->json->{job}->{state}, 'running', 'job 99963 is running');

# ... and we have a new test
$ret = $client->call('get_ok', Mojo::URL->new('/api/v1/jobs/99982'), {}, $t)->status_is(200);
is($ret->tx->res->json->{job}->{state}, 'scheduled', 'new job 99982 is scheduled');

# cancel the iso
$ret = $client->call('post_ok', Mojo::URL->new("/api/v1/isos/$iso/cancel"), {}, $t)->status_is(200);

$ret = $client->call('get_ok', Mojo::URL->new('/api/v1/jobs/99982'), {}, $t)->status_is(200);
is($ret->tx->res->json->{job}->{state}, 'cancelled', 'job 99982 is cancelled');

TODO: {
    local $TODO = 'iso delete doesnt seem to work';

    # delete the iso
    $ret = $client->call('delete_ok', Mojo::URL->new("/api/v1/isos/$iso"), {}, $t)->status_is(200);
    # now the jobs should be gone
    $ret = $client->call('get_ok', Mojo::URL->new('/api/v1/jobs/99982'), {}, $t)->status_is(404);
}

done_testing();