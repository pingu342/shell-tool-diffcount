#!/usr/bin/env perl

# 変更前のディレクトリ
my $dir_old = $ARGV[0];

# 変更後のディレクトリ
my $dir_new = $ARGV[1];

if (-e $dir_old) {
} else {
	exit;
}
if (-e $dir_new) {
} else {
	exit;
}

if ($dir_old !~ /^~\//) {
	$dir_old =~ s/^~\//$ENV{'HOME'}/;
}
if ($dir_new !~ /^~\//) {
	$dir_new =~ s/^~\//$ENV{'HOME'}/;
}

if ($dir_old !~ /\/$/) {
	$dir_old = $dir_old . "/";
}
if ($dir_new !~ /\/$/) {
	$dir_new = $dir_new . "/";
}

print "difference between $dir_old and $dir_new\n";

my $diff_result = `diff -q -r $dir_old $dir_new`;
my @diff_result_lines = split m{\n}, $diff_result;
foreach my $line ( @diff_result_lines ) {
	#print $line, "\n";
	if ($line =~ /^Files/) {
		# ファイルの内容が変更された
		$line =~ s/^Files\s//;
		$line =~ s/\sdiffer$//;
		my @files = split m{\sand\s}, $line;
		my $file = $files[0];
		$file =~ s/^${dir_old}//;
		print "[mod] " . $file . "\n";
	} elsif ($line =~ /^Only in/) {
		# ファイルが追加または削除された
		$line =~ s/^Only in\s//;
		my $only_in;
		my $mark;
		if ($line =~ /^${dir_old}/) {
			# 削除
			$only_in = $dir_old;
			$mark = "[del]";
		} elsif ($line =~ /^${dir_new}/) {
			# 追加
			$only_in = $dir_new;
			$mark = "[add]";
		}
		$line =~ /:\s(.*)$/;
		$file = $&;
		$file =~ s/:\s//;
		$path = $line;
		$path =~ s/:\s(.*)$//;
		if ($path !~ /\/$/) {
			$path = $path . "/" . $file;
		} else {
			$path = $path . $file;
		}
		my $tmp = $path;
		$tmp =~ s/${only_in}//;
		if (-f $path) {
			# ファイル
			print "$mark $tmp\n";
		} elsif (-d $path) {
			# ディレクトリ
			print "$mark $tmp/\n";
			my $files = &get_files($path);
			foreach (@$files) {
				$_ =~ s/${only_in}//;
				print "$mark $_\n";
			}
		} else {
			print "[err] $path\n";
		}
	}
}

# ディレクトリ内のファイル一覧を取得
sub get_files {
	my $dir = shift;
	my $file_list = shift;
	opendir (DIR, "$dir");
	my @list = grep /^[^\.]/, readdir DIR;
	closedir DIR;
	foreach my $file (@list) {
		if (-d "$dir/$file"){
			$file_list = &get_files("$dir/$file", $file_list);
		} else {
			push @$file_list, "$dir/$file";
		}
	}
	return $file_list;
}
