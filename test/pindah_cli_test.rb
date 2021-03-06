require 'test/unit'
require 'tmpdir'
require 'fileutils'
require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'pindah_cli'))

class PindahCLITest < Test::Unit::TestCase
  PWD = File.expand_path(File.dirname(__FILE__))

  def fixture(name)
    File.read(File.join(PWD, 'fixtures', name))
  end

  def setup
    @temp = Dir.mktmpdir("pindah-")
    @project_path = "#{@temp}/testapp"
    FileUtils.mkdir_p File.dirname(@temp)
    Dir.chdir File.dirname(@temp)
    PindahCLI.create('tld.pindah.testapp', @project_path, 'HelloWorld')
  end

  def teardown
    FileUtils.rm_rf @temp
  end

  def test_create_should_create_basic_project_structure
    PindahCLI.create('tld.pindah.testapp', '.')
    assert File.directory?(File.join(@project_path, 'src', 'tld', 'pindah', 'testapp'))

    directories = %w{ src/tld/pindah/testapp bin libs res
                      res/drawable-hdpi res/drawable-ldpi
                      res/drawable-mdpi res/layout res/values }

    directories.each do |d|
      expected = File.join(@project_path, d)
      assert File.directory?(expected), "Expected #{expected.inspect} to be a directory."
    end
  end

  def test_create_should_create_rakefile
    rake_path = File.join(@project_path, 'Rakefile')

    assert File.exists?(rake_path)
    assert_equal fixture("Rakefile"), File.read(rake_path)
  end

  def test_create_should_create_an_activity_if_desired
    actual = File.read(File.join(@project_path, 'src',
                                 'tld', 'pindah',
                                 'testapp', 'HelloWorld.mirah'))
    assert_equal fixture('HelloWorld.mirah'), actual
  end

  def test_create_should_create_manifest
    manifest_path = File.join(@project_path, 'AndroidManifest.xml')

    assert File.exists?(manifest_path)
    assert_equal fixture("AndroidManifest.xml").gsub(/\s+/, ' '), File.read(manifest_path).gsub(/\s+/, ' ')
  end

  def test_create_should_create_manifest_without_activity
    @temp = Dir.mktmpdir("pindah-")
    @project_path = "#{@temp}/testapp"
    FileUtils.mkdir_p File.dirname(@temp)
    Dir.chdir File.dirname(@temp)
    PindahCLI.create('tld.pindah.testapp', @project_path)

    manifest_path = File.join(@project_path, 'AndroidManifest.xml')

    assert File.exists?(manifest_path)
    assert_equal fixture("AndroidManifest.xml.no-activity").gsub(/\s+/, ' '), File.read(manifest_path).gsub(/\s+/, ' ')
  end

  def test_create_should_create_strings
    path = File.join(@project_path, 'res', 'values', 'strings.xml')
    assert File.exists?(path)
    assert_equal fixture("strings.xml").strip, File.read(path).strip
  end
  
  def test_create_should_create_layout
    path = File.join(@project_path, 'res', 'layout', 'main.xml')
    assert File.exists?(path)
    assert_equal fixture("main.xml").strip, File.read(path).strip
  end
end
