require 'test_helper'
require 'csv'

class CSVFile
  attr_reader :header

  def initialize(file)
    raise "Invalid file" unless File.file?(file)
    @file = file
    @header = csv_load(file).first
  end

  def data
    csv = csv_load(@file).last
    csv.read 
    #csv_enumerator(csv)
  end

  protected

  def csv_load(file)
    io = File.open(file, 'r')
    csv = CSV::new(io, { :converters => :numeric })
    # read the header into Veritas::Relation header array
    header = csv.shift.map { |col|
      parts = col.split(':')
      # key, class
      [ parts[0].downcase.to_sym, Kernel.const_get(parts[1]) ]
    }
    return header, csv
  end

  def csv_enumerator(csv)
    # cvs.enum_for(:shift) ??
    Enumerator.new do |y|
      loop {
        v = csv.shift 
        if v
          y << v
        else
          break
        end
      }
    end
  end
end

class JoinTest < Test::Unit::TestCase
  def test_joins
    owners = CSVFile.new(data_file('owners.csv'))
    pets = CSVFile.new(data_file('pets.csv'))

    owner_relation = Veritas::Relation.new(owners.header, owners.data)
    pet_relation = Veritas::Relation.new(pets.header, pets.data)

    p "theta join"
    renamed = pet_relation.rename(:name => :pet_name, :id => :pet_id)
    # select * from owner, pet where owner.id = pet.owner and pet.type = 'Cat'
    owner_relation.join(renamed, owner_relation[:id].eq(renamed[:owner])).restrict { |rel| rel[:type].eq('Cat') }.each do |r|
      p r
    end

    p "natural join"
    owner_relation.join(pet_relation.rename(:id => :pet_id, :name => :pet_name, :owner => :id)).restrict { |rel| rel[:type].eq('Cat') }.each do |r|
      p r
    end
  end
end
