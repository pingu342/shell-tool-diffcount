#!/usr/bin/env perl

use Getopt::Long qw(:config no_ignore_case permute);
use Pod::Usage;

# 変更量カウント対象ファイルの拡張子
my $file_types = "(m|c|h|java|cc|cpp)";

# 変更量カウントでコメント及び空行を無視するオプション (デフォルトoff)
my $opt_ignore_comment;

# 変更量カウント対象外ファイルの出力オプション (デフォルトoff)
my $opt_show_all;

# 変更前のディレクトリ
my $dir_old;

# 変更後のディレクトリ
my $dir_new;

GetOptions(
	'ignore_comments' => \$opt_ignore_comment,
	'show_all'        => \$opt_show_all
) or exit;

if ((@ARGV != 2) && (-t STDIN)) {
	pod2usage("$0: Please gibe two directories in order of modified from original.");
	exit;
}

$dir_old = $ARGV[0];
$dir_new = $ARGV[1];

if (-d $dir_old) {
} else {
	pod2usage("$0: $dir_old is not directory.");
	exit;
}
if (-d $dir_new) {
} else {
	pod2usage("$0: $dir_new is not directory.");
	exit;
}

if ($dir_old !~ /\/$/) {
	$dir_old = $dir_old . "/";
}
if ($dir_new !~ /\/$/) {
	$dir_new = $dir_new . "/";
}

my $add_file = 0;
my $del_file = 0;
my $mod_file = 0;
my $excluded_add_file = 0;
my $excluded_del_file = 0;
my $excluded_mod_file = 0;
my $add_line = 0;
my $del_line = 0;
my $mod_line = 0;
my $results = `./diff-q.pl $dir_old $dir_new`;
my @result_lines = split m{\n}, $results;
print "Processing...\n";
foreach my $line ( @result_lines ) {
	if ($line =~ /^\[...\]/) {
		my $type = $&;
		my $file = $line;
		$file =~ s/^\[...\]\s*//;
		if ($type =~ /^\[mod\]/) {
			if ($file =~ /\.${file_types}$/) {
				$mod_file++;
				
				# 変更行数をカウント
				my $path_old = $dir_old . $file;
				my $path_new = $dir_new . $file;
				my $result;
				if ($opt_ignore_comment) {
					$result = `./diff-c.sh -i $path_old $path_new`;
				} else {
					$result = `./diff-c.sh $path_old $path_new`;
				}
				my @vals = split m{\s}, $result;
				print " $line $vals[2] $vals[3] $vals[4]\n";
				$add_line += $vals[2];
				$del_line += $vals[3];
				$mod_line += $vals[4];
			} else {
				$excluded_mod_file++;

				if ($opt_show_all) {
					print " $line 0 0 0 (excluded)\n";
				}
			}
		} elsif ($type =~ /^\[del\]/) {
			if ($file =~ /\.${file_types}$/) {
				$del_file++;

				# 削除行数としてカウント
				my $numoflines = get_numoflines($dir_old . $file, $opt_ignore_comment);
				print " $line 0 $numoflines 0\n";
				$del_line += $numoflines;
			} else {
				$excluded_del_file++;

				if ($opt_show_all) {
					print " $line 0 0 0 (excluded)\n";
				}
			}
		} elsif ($type =~ /^\[add\]/) {
			if ($file =~ /\.${file_types}$/) {
				$add_file++;

				# 追加行数としてカウント
				my $numoflines = get_numoflines($dir_new . $file, $opt_ignore_comment);
				print " $line $numoflines 0 0\n";
				$add_line += $numoflines;
			} else {
				$excluded_add_file++;

				if ($opt_show_all) {
					print " $line 0 0 0 (excluded)\n";
				}
			}
		}
	}
}

print "\nTotal file count:\n [add] $add_file files (exclude $excluded_add_file files)\n [del] $del_file files (exclude $excluded_del_file files)\n [mod] $mod_file files (exclude $excluded_mod_file files)\n\n";
print "Total line count:\n [add] $add_line lines\n [del] $del_line lines\n [mod] $mod_line lines\n";

# 行数をカウント
sub get_numoflines {
	my $path = shift;
	my $opt_ignore_comment = shift;
	if (-f $path) {
		my $result;
		if ($opt_ignore_comment) {
			# コメント及び空行を含まない行数
			$result = `./rm_comment.pl $path | wc -l`;
		} else {
			# コメント及び空行を含めた行数
			$result = `wc -l $path`;
		}
		if ($result =~ /\s*\d+/) {
			$result = $&;
			$result =~ s/\s*//;
			return $result;
		} else {
			return 0;
		}
	}
	return 0;
}
