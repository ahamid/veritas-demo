require 'test/unit'
require 'veritas'
require 'csv'

class CSVFile
  attr_reader :header

  def initialize(file)
    raise "Invalid file" unless File.file?(file)
    @csv = CSV::new(File.open(file, 'r'), { :headers => :first_row, :return_headers => false })
    @csv.shift
    # read the header into Veritas::Relation header array
    @header = @csv.headers.map { |col|
      parts = col.split(':')
      # key, class
      [ parts[0], Kernel.const_get(parts[1]) ]
    }
  end

  def data
    @csv.enum_for(:shift)
  end
end

class JoinTest < Test::Unit::TestCase
  def test_joins
    owners = CSVFile.new("test/owners.csv")
    pets = CSVFile.new("test/pets.csv")

    owner_relation = Veritas::Relation.new(owners.header, owners.data)
    pet_relation = Veritas::Relation.new(pets.header, pets.data)

    #owner_relation.intersection
  end
end
