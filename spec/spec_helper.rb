PROJECT_ROOT = Pathname.new(File.dirname(__dir__))

Dir[PROJECT_ROOT.join('spec/support/**/*.rb')].each { |f| require f }
