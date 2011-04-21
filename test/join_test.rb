require 'test/unit'
require 'veritas'
require 'csv'

class CSVFile
  attr_reader :header

  def initialize(file)
    raise "Invalid file" unless File.file?(file)
    @io = File.open(file, 'r')
    @csv = CSV::new(@io, { :converters => :numeric })
    # read the header into Veritas::Relation header array
    @header = @csv.shift.map { |col|
      parts = col.split(':')
      # key, class
      [ parts[0].downcase.to_sym, Kernel.const_get(parts[1]) ]
    }
    @data = @csv.read
  end

  def data
    # @csv.enum_for(:shift) # doesn't work???
    #Enumerator.new do |y|
    #  loop {
    #    v = @csv.shift 
    #    if v
    #      y << v
    #    else
    #      break
    #    end
    #  }
    #end
    @data
  end
end

class JoinTest < Test::Unit::TestCase
  def test_joins
    owners = CSVFile.new("test/owners.csv")
    pets = CSVFile.new("test/pets.csv")

    owner_relation = Veritas::Relation.new(owners.header, owners.data)
    pet_relation = Veritas::Relation.new(pets.header, pets.data)

    p "theta join"
    renamed = pet_relation.rename(:name => :pet_name, :id => :pet_id)
    # select * from owner, pet where owner.id = pet.owner and pet.type = 'Cat'
    owner_relation.join(renamed, owner_relation[:id].eq(renamed[:owner])).restrict(renamed[:type].eq('Cat')).each do |r|
      p r
    end

    p "natural join"
    owner_relation.join(pet_relation.rename(:id => :pet_id, :name => :pet_name, :owner => :id)).restrict(pet_relation[:type].eq('Cat')).each do |r|
      p r
    end
  end
end
