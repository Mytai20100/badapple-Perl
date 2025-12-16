#!/usr/bin/perl
use strict;
use warnings;
use Time::HiRes qw(sleep);

my $ASCII_CHARS = ' .:-=+*#%@';
my $WIDTH = 80;
my $HEIGHT = 40;

sub download_video {
    my ($url) = @_;
    print "Downloading video...\n";
    system("yt-dlp -f worst -o badapple.mp4 '$url'");
}

sub rgb_to_ascii {
    my ($r, $g, $b) = @_;
    my $brightness = ($r + $g + $b) / 3;
    my $index = int($brightness * (length($ASCII_CHARS) - 1) / 255);
    return substr($ASCII_CHARS, $index, 1);
}

sub extract_and_display_frame {
    my ($time) = @_;
    my $cmd = sprintf(
        "ffmpeg -ss %.2f -i badapple.mp4 -vframes 1 -vf scale=%d:%d -f rawvideo -pix_fmt rgb24 - 2>/dev/null",
        $time, $WIDTH, $HEIGHT
    );
    
    my $pixels = `$cmd`;
    
    if ($pixels) {
        print "\033[2J\033[H";
        
        for (my $y = 0; $y < $HEIGHT; $y++) {
            for (my $x = 0; $x < $WIDTH; $x++) {
                my $idx = ($y * $WIDTH + $x) * 3;
                if ($idx + 2 < length($pixels)) {
                    my $r = ord(substr($pixels, $idx, 1));
                    my $g = ord(substr($pixels, $idx + 1, 1));
                    my $b = ord(substr($pixels, $idx + 2, 1));
                    print rgb_to_ascii($r, $g, $b);
                }
            }
            print "\n";
        }
    }
}

my $url = $ARGV[0] || 'https://youtu.be/FtutLA63Cp8';
download_video($url);

my $fps = 10;
my $duration = 30;
my $time = 0;

while ($time < $duration) {
    extract_and_display_frame($time);
    sleep(1 / $fps);
    $time += 1 / $fps;
}
