class Wrk2 < Formula
  desc "Constant throughput, correct latency recording variant of wrk"
  homepage "https://github.com/olshansk/wrk2"
  head "https://github.com/olshansk/wrk2.git"

  depends_on "openssl"

  def install
    # Per https://luajit.org/install.html: If MACOSX_DEPLOYMENT_TARGET
    # is not set then it's forced to 10.4, which breaks compile on Mojave.
    ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version

    # Build LuaJIT first
    system "make", "clean"
    system "make", "deps/luajit/src/libluajit.a"

    # Create obj directory and generate bytecode properly
    mkdir "obj" unless File.exist?("obj")
    cd "deps/luajit/src" do
      system "./luajit", "-b", "-n", "wrk", "-t", "c",
             buildpath/"src/wrk.lua", buildpath/"obj/bytecode.c"
    end

    # Compile bytecode
    system ENV.cc, "-c", "-o", "obj/bytecode.o", "obj/bytecode.c"

    # Build wrk2
    system "make"

    # Rename and install
    mv "wrk", "wrk2"
    bin.install "wrk2"
  end

  test do
    system "#{bin}/wrk2", "--version"
  end
end