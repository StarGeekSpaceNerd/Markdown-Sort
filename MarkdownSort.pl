# MarkdownSort.pl
#
# Attempts to sort sections of a markdown document by the header level

use strict;
use warnings;
use List::Util qw(min);
use Data::Dumper;

my $level=1;

my $markdown = do { local $/; <> };

# Make sure there's a trailing new line, otherwise something goes wrong with the sort
#	probably should look into this
$markdown.="\n";
my $res=HeaderSort($level,$markdown);
print $res;
exit;

sub HeaderSort {
	my ($level,$content) = @_;
	my $header='#'x$level;
	# have an array split on headers * level. 
	# 	$splt[0] is the intro
	#	$splt[1+] is each header section
	my @splt = split /^$header +/ms, $content;

	# Separate the intro from the header entries
	# @splt now only contains the intro and @slice
	# contains each header
	my @slice = splice(@splt, 1, $#splt);
	
	# now sort the slice
	@slice	= sort natcomp @slice;

	# reinsert the array
	splice(@splt, 1, 0, @slice);


	for my $i (0 .. $#splt) {
		if ($splt[$i]=~/^#+ /ms) {
			$splt[$i]=HeaderSort($level+1,$splt[$i]);
		}
	}
	
	$content=join "$header ", @splt;
	return $content;
}

# Natural Sorting
# https://www.perlmonks.org/?node_id=540890
# subroutine to use with Perl's sort funtion. Does a case insensitive sort and
# takes into account "natural" nubering, so 9 will come before 10, which would not
# happen in a normal sort
# some minor modifications to make it case insensitive

sub natcomp {
    my @a = split /(\d+)/, $a;
    my @b = split /(\d+)/, $b;
    my $last = min(scalar @a, scalar @b)-1;
    my $cmp;
    for my $i (0 .. $last) {
        unless($i & 1) {  # even
            $cmp = lc $a[$i] cmp lc $b[$i] and return $cmp;
        }else {  # odd
            $cmp = $a[$i] <=> $b[$i] and return $cmp;
        }
    }
    return scalar @a <=> scalar @b;  # shortest array comes first
}
