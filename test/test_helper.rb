require 'test/unit'
require 'veritas'

DATA_DIR=File.expand_path(File.join('..','..','data'), __FILE__)

def data_file(f)
  File.expand_path(f, DATA_DIR)
end
