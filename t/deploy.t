#!/usr/bin/perl -w

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

BEGIN { unshift @INC, 'lib', 'lib/OpenQA/modules'; }

use strict;

use Test::More;

use openqa ();

unlink $openqa::dbfile;

my $schema = openqa::connect_db();

my $f = sprintf('Schema-%s-SQLite.sql', $Schema::VERSION);
my $d = 't/schema';

unlink("$d/$f");

$schema->create_ddl_dir(['SQLite'],
                        $Schema::VERSION,
                        $d,
                        );
ok(-e "$d/$f", "schema dumped");

ok($schema->deploy == 0, "deployed");

done_testing();