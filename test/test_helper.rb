require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'minitest/autorun'

$VERBOSE = true

# Returns the project root (src).
#
def project_root
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

# Returns the test root.
#
def test_root
  File.dirname(__FILE__)
end

# Returns the absolute path to a subdirectory in '../lib'.
#
def get_lib_dir(name)
  File.join(project_root(), 'lib', name)
end

def require_lib(name)
  require_relative get_lib_dir(name)
end

# Add a library to the load path.
#
def load_path(name)
  $LOAD_PATH.unshift(get_lib_dir(name))
end

# Returns the filename of a fixture file.
#
# fn    -- fixture filename
# local -- local test file -- just pass __FILE__ to it
#
def get_fixture(fn, local = '')
  if local
    File.join(test_root(), File.basename(File.dirname(local)), 'fixtures', fn)
  else
    File.join(test_root(), 'fixtures', fn)
  end
end

require 'simplecov'
SimpleCov.start
