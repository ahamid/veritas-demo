require 'test/unit'
require 'veritas'
require 'veritas_demo/dsl'
require 'faker'

DATA_DIR=File.expand_path(File.join('..','..','data'), __FILE__)

RECORD_TYPES = {
  :owner => Records::DSL::StructDSL.build(182, "Owner") do
    pascal_string 'ca25', :firstname,  Faker::Name.method(:first_name)
    pascal_string 'ca10', :honorific,  Faker::Name.method(:prefix)
    pascal_string 'ca25', :lastname,   Faker::Name.method(:last_name)
    pascal_string 'ca60', :street,     Faker::Address.method(:street_name)
    pascal_string 'ca30', :city,       Faker::Address.method(:city)
    pascal_string 'ca2',  :state,      Faker::Address.method(:us_state)
    pascal_string 'ca10', :zipcode,    Faker::Address.method(:zip_code)
    pascal_string 'ca3',  :areacode,   lambda { Faker::Base.numerify('###') }
    pascal_string 'ca8',  :telephone,  lambda { Faker::Base.numerify('###-###') }
  end,
  :pet => Records::DSL::StructDSL.build(92, "Pet") do
    pascal_string 'ca25', :firstname,     Faker::Name.method(:first_name), 25
    pascal_string 'ca20', :rabies_number, lambda { Faker::Base.numerify('####') }
    pascal_string 'ca10', :breed,         Faker::Lorem.method(:sentence), 8
    pascal_string 'ca20', :species,       Faker::Lorem.method(:sentence), 19
    pascal_string 'ca10', :color,         Faker::Lorem.method(:sentence), 8
    field         'v',    :ownerid,      0
  end
}

def data_file(f)
  File.expand_path(f, DATA_DIR)
end

def generate_records(type, num)
  struct_class = RECORD_TYPES[type.to_sym]
  records = []
  num.times do
    records << struct_class.new.pack(true)
  end
  records
end

# generate binary test data
if __FILE__ == $0
  # FIXME: ya, option handling sucks on this command
  num_pets = ARGV[0].to_i
  num_owners = ARGV[1].to_i
  
  pets_file = ARGV[2]
  owners_file = ARGV[3]
  
  puts "Generating #{num_pets} pets into #{pets_file}"
  puts "Generating #{num_owners} owners into #{owners_file}"
  
  # generate some pets. ownerids are all 0
  pets = generate_records("pet", num_pets).map { |rec| RECORD_TYPES[:pet].parse(rec) }
  # generate some owners
  owners = generate_records("owner", num_owners).map { |rec| RECORD_TYPES[:owner].parse(rec) }
  # set random owners for all pets
  File.open(pets_file, "w") do |file|
    pets.each do |rec|
      idx = rand(owners.length)
      # set the index on owners since generated owners don't have indexes
      owner = owners[idx]
      p idx
      owner.index = idx + 1 # indexes start at one

      rec.ownerid = owner.index # set the owner id on the pet
      
      # write out pet
      file.write(rec.pack)
    end
  end
  File.open(owners_file, "w") do |file|
    # write out all the owners
    owners.each do |rec|
      file.write(rec.pack)
    end
  end
end