require 'formula'

class Jpeg6bx8 < Formula
  homepage 'http://www.ijg.org'
  url 'http://www.ijg.org/files/jpegsrc.v6b.tar.gz'
  sha256 '75c3ec241e9996504fe02a9ed4d12f16b74ade713972f3db9e65ce95cd27e35d'
  version '6bx8'

  depends_on 'libtool' => :build

  patch do
    url 'https://distfiles.emsow.com/distfiles/ljpeg-6b.tar.gz'
    sha256 'aa48801c3c63577c091bbf6de72569fe011e5a08939870d024b40af211310cda'
  end

  def install
    bin.mkpath
    lib.mkpath
    include.mkpath
    man1.mkpath
    
    # bits per sample (8, 12 or 16)
    @bps = "#{version}".gsub(/^.*x/, '')

    # adding binsuffix variable
    system 'sed', '-i', '', '-E', "/^binprefix =/ a\\\nbinsuffix = #{@bps}\n", "makefile.cfg"
    # bug in original makefile
    system 'sed', '-i', '', '-E', "s/jclossy\\.o/jclossy.$(O)/", "makefile.cfg"
    # adding binsuffix to binary (exe/lib) files
    system 'sed', '-i', '', '-E', "s/(\\$\\(binprefix\\)[a-z]+)/\\1$(binsuffix)/", "makefile.cfg"
    # adding binsuffix to man files
    system 'sed', '-i', '', '-E', "s/(\\.\\$\\(manext\\))/$(binsuffix)\\1/", "makefile.cfg"
    # add libjpeg suffix
    system 'sed', '-i', '', '-E', "s/libjpeg\\./libjpeg#{@bps}./", "makefile.cfg"

    # we need to do something only if we change default value 8 to 12 or 16
    if @bps != "8"
         # define bits per sample based on formula version
        system 'sed', '-i', '', '-E', "s/^(\#define BITS_IN_JSAMPLE ).*/\\1#{@bps}/", "jmorecfg.h"
        # disable unsupported modules for other than 8 bits per samples builds
        system 'sed', '-i', '', '-E', "s/^\#define ((BMP|RLE|TARGA)_SUPPORTED)/#undef \\1/", "jconfig.cfg"
    end

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-static"
    
    system "mkdir", "#{include}/jpeg#{@bps}"
    
    system "make", "install", 
                   "install-lib", 
                   "install-headers",
                   "LIBTOOL=glibtool --tag=CC",
                   "mandir=#{man1}",
                   "includedir=#{include}/jpeg#{@bps}"
  end
end
