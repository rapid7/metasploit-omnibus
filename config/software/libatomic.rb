#
# On 32-bit platforms (especially ARM), GCC's libatomic is required for
# 64-bit atomic operations used by OpenSSL 3.x and other libraries.
# This definition copies the system's libatomic into the embedded dir
# so it ships with the package and satisfies the omnibus health check.
#

name "libatomic"
description "GCC runtime library for atomic operations"
license "GPL-3.0 (with GCC Runtime Library Exception)"
skip_transitive_dependency_licensing true

build do
  block "Copy libatomic if needed" do
    libatomic_path = shellout("gcc -print-file-name=libatomic.so.1 2>/dev/null").stdout.strip
    if !libatomic_path.empty? && libatomic_path != "libatomic.so.1" && File.exist?(libatomic_path)
      copy libatomic_path, "#{install_dir}/embedded/lib/libatomic.so.1"
      link "#{install_dir}/embedded/lib/libatomic.so.1", "#{install_dir}/embedded/lib/libatomic.so"
    end
  end
end
