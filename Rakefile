require 'bundler/setup'
require './repositories'
require 'csv'
class Merits
  def initialize
    @merits = CSV.read('../../avnsp-bak/old_db_files/csv/merits.csv').map do |row|
      {
        member_id: row[1],
        from: row[2],
        to: row[3],
        appointment: row[4],
      }
    end
  end
  def for(member_id)
    @merits.select { |m| m[:member_id] == member_id }.map do |m|
      m.delete 'member_id'
      m
    end
  end
end
class Addresses
  def initialize
    lines = CSV.read('../../avnsp-bak/old_db_files/csv/addresses.csv', quote_char: "'")
    @addresses = lines.map do |row|
      old_address = row.last.force_encoding('utf-8').split('\n')
      postaladdress = old_address.first
      zipcode = old_address.last[0..5].strip.delete(' ').to_i
      location = old_address.last[6..-1]
      location = location && location.strip
      {
        member_id: row[1],
        type: row[2],
        address: postaladdress,
        zip: zipcode,
        region: location
      }
    end
  end
  def for(member_id)
    @addresses.select { |a| a[:member_id] == member_id }.map do |a|
      a.delete 'member_id'
      a
    end
  end
end
namespace :seed do
  task :users do
    users = CSV.read('../../avnsp-bak/old_db_files/csv/members.csv', quote_char: "'")
    members = CSV.read('../../avnsp-bak/old_db_files/csv/persons.csv')
    addresses = Addresses.new
    merits = Merits.new
    #phones = Phones.new
    users.each do |row|
      member = members.select { |m| m[0] == row[0] }.first
      user = User.new(
        username: row[1],
        old_password_hash: row[2],
        email: member[5],
        created_at: row[4],
        first_name: member[2],
        last_name: member[3],
        nickname: member[4],
        program: member[7],
        began_studies: member[8],
        addresses: addresses.for(row[0]),
        merits: merits.for(row[0]),
        phones: []
      )
      UserRepository.insert(user)
    end
  end
end
