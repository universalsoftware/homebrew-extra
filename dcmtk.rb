class Dcmtk < Formula
  desc "OFFIS DICOM toolkit command-line utilities"
  homepage "http://dicom.offis.de/dcmtk.php.en"
  
  # Current snapshot used for stable now.
  url "https://github.com/DCMTK/dcmtk/archive/DCMTK-3.6.5+_20191213.tar.gz"
  sha256 "2b707106032247e1d1832e918ec0e560b2e81af4ed0a1ee659f0803c4c172141"
  version "3.6.5-20191213"
  
  head "http://git.dcmtk.org/dcmtk.git"

  option "with-docs", "Install development libraries/headers and HTML docs"
  option "with-openssl", "Configure DCMTK with support for OpenSSL"
  option "with-libiconv", "Build with brewed libiconv. Dcmtk and system libiconv can have problems with utf8."

  depends_on "cmake" => :build
  depends_on "doxygen" => :build if build.with? "docs"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "openssl"
  depends_on "homebrew/dupes/libiconv" => :optional

  patch do
    url "file://" + File.dirname(__FILE__) + "/patches/dcmtk-3.6.4.patch"
    sha256 "0a1b2fbf6396e170d58cfd81c81f6a631f68b8bb5ee5f5534cbda740b65f1b60"
  end

  def install
#    ENV.m64 if MacOS.prefer_64_bit?

    args = std_cmake_args
    args << "-DDCMTK_WITH_DOXYGEN=YES" if build.with? "docs"
    args << "-DDCMTK_WITH_OPENSSL=YES" if build.with? "openssl"
    args << "-DDCMTK_WITH_ICONV=YES -DLIBICONV_DIR=#{Formula["libiconv"].opt_prefix}" if build.with? "libiconv"
    args << ".."

    mkdir "build" do
      system "cmake", *args
      system "make", "DOXYGEN" if build.with? "docs"
      system "make", "install"
    end
  end

  test do
    system bin/"pdf2dcm", "--verbose",
           test_fixtures("test.pdf"), testpath/"out.dcm"
    system bin/"dcmftest", testpath/"out.dcm"
  end
end