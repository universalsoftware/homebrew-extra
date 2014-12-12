require File.join(File.dirname(__FILE__), '../../homebrew/homebrew-php/Abstract/abstract-php-extension')

class Php55V8js < AbstractPhp55Extension
  init
  homepage 'https://github.com/preillyme/v8js'
  url 'https://github.com/preillyme/v8js.git', :revision => 'af58f4ec9ec1e0fa47ce4205b380ef58f5ef1bcf'
  version '20141211'
  head 'https://github.com/preillyme/v8js.git'

  depends_on 'v8'

  def install
    inreplace "config.m4", "-Wl,--rpath=", "-L"

    ENV.universal_binary if build.universal?

    safe_phpize
    system "./configure", "--prefix=#{prefix}",
                          phpconfig,
                          "--with-v8js=#{Formula['v8'].opt_prefix}"
    system "make", "CXXFLAGS=-Wno-narrowing"
    prefix.install "modules/v8js.so"
    write_config_file if build.with? "config-file"
  end
end
