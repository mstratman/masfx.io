#!/usr/bin/env perl
#
# Creates a bunch of HTML in the dist/ directory.
# Run build_assets.sh first to create dist/
#
use strict;
use warnings;
use 5.010001;

use Data::Dumper;
use Template;
use File::ChangeNotify;
use Text::MultiMarkdown;
use File::Slurp qw(read_file);
use JSON::PP;
use Date::Format qw(time2str);
use File::stat qw(stat);

my $file = shift;
my $watch = shift;
$watch = $watch && $watch eq '--watch' ? 1 : 0;

my $page_dir = './pages';
my $layout_dir = './templates';

my $json = JSON::PP->new->relaxed([1]);
my $json_txt = read_file($file);
my $site = $json->decode($json_txt);
die unless $site;

$site->{href} = '/' . $site->{directory} . '/';
$site->{chapters} = [ map {
    my $c = $_;
    my $cdir = $c->{directory} ? $c->{directory} . '/' : $c->{directory};
    $c->{href} = $site->{href} . $cdir;
    $c->{pages} = [ map {
        my $p = $_;
        my $md_path = $page_dir . '/' . $site->{directory} . '/' . $cdir . $p->{file} . '.md';
        my $html_path = $page_dir . '/' . $site->{directory} . '/' . $cdir . $p->{file} . '.html';
        if (-e $md_path) {
            $p->{md_path} = $md_path;
        } else {
            $p->{html_path} = $html_path;
        }

        $p->{href} = $c->{href} . $p->{file} . '.html';
        $p->{dist_path} = 'dist/' . $site->{directory} . '/' . $cdir . $p->{file} . '.html';
        $p;
    } @{ $c->{pages} } ];
    $c;
} @{ $site->{chapters} } ];


my $config = {
    INCLUDE_PATH => [$layout_dir, $page_dir],
    #POST_CHOMP   => 1,
};
my $tmpl = Template->new($config);
build_all();



unless ($watch) {
    say "FYI: remember you can pass --watch";
    exit;
}

my $mon = File::ChangeNotify->instantiate_watcher(
    directories => [ $layout_dir, $page_dir ],
    exclude => [ qr/\.swp/ ],
);
while ( my @events = $mon->wait_for_events ) {
    use Data::Dumper;
    say Dumper(\@events);
    print "BUILDING....";
    build_all();
    print "DONE\n";
}

# returns html of generated sidebar
sub generate_sidebar {
    my ($cur_page, $cur_chapter) = @_;
    my $menu = [];
    my $cur_id = 'sidebar_pageid_' . $site->{directory} . $cur_chapter->{directory} . '_' . $cur_page->{file};

    for my $ch (@{ $site->{chapters} }) {
        my %c = %$ch;
        my $is_current_ch = $c{directory} eq $cur_chapter->{directory} ? 1 : 0;
        $c{id} = 'sidebar_chid_' . $site->{directory} . $c{directory};

        my @pages = ();
        for my $pg (@{ $c{pages} }) {
            my %p = %$pg;
            $p{id} = 'sidebar_pageid_' . $site->{directory} . $c{directory} . '_' . $p{file};
            my $is_current_p = $p{id} eq $cur_id ? 1 : 0;
            my $sections = [];
            if ($is_current_p) {
                $sections = get_sections($cur_page, $cur_chapter);
            }
            $p{href} = $is_current_p ? '#' . _Header2Label($p{title}) : $p{href};
            $p{is_current} = $is_current_p;
            $p{sections} = $sections;
            push @pages, \%p;
        }

        $c{is_current} = $is_current_ch;
        $c{pages} = \@pages;
        push @$menu, \%c;
    }

    my $rv = '';
    $tmpl->process("sidebar.html", {
            current_page_id => $cur_id,
            chapters => $menu,
            chapters_json => $json->encode($menu),
        }, \$rv) or die $tmpl->error;
    return $rv;
}

# returns either scalar body, or array of lines.
sub get_article {
    my $page = shift;
    my @lines;
    if ($page->{md_path}) {
        return read_file($page->{md_path});
    } else {
        return read_file($page->{html_path});
    }
}

sub get_sections {
    my ($page, $chapter) = @_;

    my @lines = get_article($page);

    my @rv = ();
    for my $l (@lines) {
        if ($l =~ /^##[^#]/) {
            my $header = $l;
            $header =~ s/^##\s+//;
            my $id = _Header2Label($header);
            push @rv, { title => $header, href => "#$id" };
        } elsif ($l =~ /<h2[^>]+id=["']([^'"]+)["'][^>]*>([^<]+)<\//) {
            my $id = $1;
            my $title = $2;
            push @rv, { title => $title, href => "#$id" };
        }
    }
    return \@rv;
}

# This is ripped directly from Text::MultiMarkdown, to generate the same heading IDs.
sub _Header2Label {
    #my ($self, $header) = @_;
    my $header = shift;
    my $label = lc $header;
    $label =~ s/[^A-Za-z0-9:_.-]//g;        # Strip illegal characters
    while ($label =~ s/^[^A-Za-z]//g)
        {};     # Strip illegal leading characters
    return $label;
}

sub build_all {

    # build a list of pages to use for next/prev buttons in the template. Note that 
    # we're not navigating between sites.
    my @nav_pages = ();
    for my $chapter (@{ $site->{chapters} }) {
        for my $page (@{ $chapter->{pages} }) {
            push @nav_pages, { href => $page->{href}, title => $page->{title}, quick => $page->{quick}, comprehensive => $page->{comprehensive} };
        }
    }

    my $i = 0;
    for my $chapter (@{ $site->{chapters} }) {
        for my $page (@{ $chapter->{pages} }) {
            ##(my $i = 0; $i < scalar(@{ $chapter->{pages} }); $i++) {
                #my $page = $chapter->{pages}->[$i];

            my @prev = ();
            my @next = ();
            if ($i > 0) {
                push @prev, $nav_pages[$i-1];
                for my $w ((['quick','comprehensive'], ['comprehensive','quick'])) {
                    if ($prev[0]->{$w->[0]}) {
                        for (my $j = $i-2; $j >=0; $j--) {
                            my %pg = %{ $nav_pages[$j] };
                            if (! $pg{$w->[0]}) {
                                $pg{$w->[1]} = 1;
                                push @prev, \%pg;
                                last;
                            }
                        }
                    }
                }
            }
            if ($i < $#nav_pages) {
                push @next, $nav_pages[$i + 1];
                for my $w ((['quick','comprehensive'], ['comprehensive','quick'])) {
                    if ($next[0]->{$w->[0]}) {
                        for (my $j = $i+2; $j <= $#nav_pages; $j++) {
                            my %pg = %{ $nav_pages[$j] };
                            if (! $pg{$w->[0]}) {
                                $pg{$w->[1]} = 1;
                                push @next, \%pg;
                                last;
                            }
                        }
                    }
                }
            }

            $i++;

            my $fn = $page->{md_path} ? $page->{md_path} : $page->{html_path};
            my %vars = (
                %$page,
                h1_id => _Header2Label($page->{title}),
                last_updated => time2str("%Y-%m-%d", stat($fn)->mtime),
                sidebar => generate_sidebar($page, $chapter),
                site_title => $site->{title},
                chapter_title => $chapter->{title},
                meta_description => $site->{meta_desc},
                pages_prev => \@prev,
                pages_next => \@next,
            );

            my $article = get_article($page);
            my $contents = '';
            if ($page->{md_path}) {
                my $md = Text::MultiMarkdown->new();
                $contents = $md->markdown($article);
            } else {
                $contents = $article;
            }
            my $html = qq([% WRAPPER article.html %]) . $contents . '[% END %]';

            $tmpl->process(\$html, \%vars, $page->{dist_path}) or die $tmpl->error;
        }
    }
}


