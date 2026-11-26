require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'stringio'
load File.expand_path('../config/templates/metasploit-framework-wrappers/retire-package-gems.rb.erb', __dir__)

class RetirePackageGemsTest < Minitest::Test
  OLD = 'embedded/lib/ruby/gems/3.4.0/specifications/example-1.0.gemspec'
  CURRENT = 'embedded/lib/ruby/gems/3.4.0/specifications/example-2.0.gemspec'
  USER = 'embedded/lib/ruby/gems/3.4.0/specifications/user-1.0.gemspec'

  def setup
    @directory = File.realpath(Dir.mktmpdir('package-gems-'))
    @root = File.join(@directory, 'root')
    @bom = File.join(@directory, 'previous.bom')
    @output = StringIO.new
    write(OLD, 'old specification')
    write('embedded/lib/ruby/gems/3.4.0/gems/example-1.0/lib.rb', 'original gem contents')
    write('embedded/framework/user-file', 'not a gem')
    write('embedded/lib/ruby/gems/3.4.0/specifications/default/default-1.0.gemspec', 'default gem')
    assert system('/usr/bin/mkbom', @root, @bom)
    write(CURRENT, 'current specification')
    write(USER, 'user specification')
    write('embedded/package-gem-specifications.json', JSON.generate([CURRENT]))
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def write(path, contents)
    absolute = File.join(@root, path)
    FileUtils.mkdir_p(File.dirname(absolute))
    File.write(absolute, contents)
  end

  def run_cleanup
    RetirePackageGems.new(@root, output: @output).run(@bom)
  end

  def test_retires_only_obsolete_package_registration
    run_cleanup
    refute File.exist?(File.join(@root, OLD))
    assert_equal 'current specification', File.read(File.join(@root, CURRENT))
    assert_equal 'user specification', File.read(File.join(@root, USER))
    assert_equal 'not a gem', File.read(File.join(@root, 'embedded/framework/user-file'))
    assert_equal 'default gem', File.read(File.join(@root, 'embedded/lib/ruby/gems/3.4.0/specifications/default/default-1.0.gemspec'))
    assert_includes @output.string, 'Retired obsolete package gem registration'
    run_cleanup
  end

  def test_preserves_same_size_edit
    write(OLD, 'new specification')
    run_cleanup
    assert_equal 'new specification', File.read(File.join(@root, OLD))
    assert_includes @output.string, 'Preserving modified'
  end

  def test_preserves_changed_permissions
    File.chmod(0600, File.join(@root, OLD))
    run_cleanup
    assert File.exist?(File.join(@root, OLD))
    assert_includes @output.string, 'Preserving modified'
  end

  def test_preserves_symbolic_link_and_target
    target = File.join(@directory, 'outside')
    File.write(target, 'old specification')
    File.unlink(File.join(@root, OLD))
    File.symlink(target, File.join(@root, OLD))
    run_cleanup
    assert File.symlink?(File.join(@root, OLD))
    assert_equal 'old specification', File.read(target)
  end

  def test_preserves_hard_link
    File.link(File.join(@root, OLD), File.join(@directory, 'outside'))
    run_cleanup
    assert File.exist?(File.join(@root, OLD))
  end

  def test_does_not_follow_parent_symlink
    specifications = File.dirname(File.join(@root, OLD))
    outside = File.join(@directory, 'outside')
    File.rename(specifications, outside)
    File.symlink(outside, specifications)
    run_cleanup
    assert File.exist?(File.join(@root, OLD))
    assert_includes @output.string, 'unsafe gem'
  end

  def test_preserves_files_in_writable_parent
    File.chmod(0777, File.dirname(File.join(@root, OLD)))
    run_cleanup
    assert File.exist?(File.join(@root, OLD))
    assert_includes @output.string, 'unsafe gem'
  end

  def test_empty_inventory_fails_before_deletion
    write('embedded/package-gem-specifications.json', '[]')
    assert_raises(RuntimeError) { run_cleanup }
    assert File.exist?(File.join(@root, OLD))
  end

  def test_invalid_inventory_fails_before_deletion
    write('embedded/package-gem-specifications.json', JSON.generate([CURRENT, '../../outside']))
    assert_raises(RuntimeError) { run_cleanup }
    assert File.exist?(File.join(@root, OLD))
  end

  def test_unreadable_bom_fails_before_deletion
    File.unlink(@bom)
    assert_raises(RuntimeError) { run_cleanup }
    assert File.exist?(File.join(@root, OLD))
  end

  def test_retains_old_version_still_present_in_new_package
    write('embedded/package-gem-specifications.json', JSON.generate([OLD, CURRENT]))
    run_cleanup
    assert File.exist?(File.join(@root, OLD))
  end

  def test_preserves_registration_for_modified_gem_contents
    write('embedded/lib/ruby/gems/3.4.0/gems/example-1.0/lib.rb', 'user modification')
    run_cleanup
    assert File.exist?(File.join(@root, OLD))
  end

  def test_preserves_registration_for_user_added_gem_file
    write('embedded/lib/ruby/gems/3.4.0/gems/example-1.0/user.rb', 'user addition')
    run_cleanup
    assert File.exist?(File.join(@root, OLD))
  end

  def test_preserves_registration_for_missing_gem_file
    File.unlink(File.join(@root, 'embedded/lib/ruby/gems/3.4.0/gems/example-1.0/lib.rb'))
    run_cleanup
    assert File.exist?(File.join(@root, OLD))
  end

  def test_retires_obsolete_normal_registration_when_version_becomes_default
    default = OLD.sub('/specifications/', '/specifications/default/')
    write(default, 'new default specification')
    write('embedded/package-gem-specifications.json', JSON.generate([default]))
    run_cleanup
    refute File.exist?(File.join(@root, OLD))
    assert_equal 'new default specification', File.read(File.join(@root, default))
    assert_equal 'original gem contents', File.read(File.join(@root, 'embedded/lib/ruby/gems/3.4.0/gems/example-1.0/lib.rb'))
  end

  def test_preserves_modified_normal_registration_when_version_becomes_default
    default = OLD.sub('/specifications/', '/specifications/default/')
    write(default, 'new default specification')
    write('embedded/package-gem-specifications.json', JSON.generate([default]))
    write(OLD, 'user modification')
    run_cleanup
    assert_equal 'user modification', File.read(File.join(@root, OLD))
    assert_equal 'new default specification', File.read(File.join(@root, default))
  end
end
