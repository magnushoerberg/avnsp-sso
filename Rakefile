require 'bundler/setup'
require './repositories'
require 'csv'
namespace :seed do
  task :users do
    users = CSV.read('../../avnsp-bak/old_db_files/csv/members.csv', quote_char: "'")
    members = CSV.read('../../avnsp-bak/old_db_files/csv/persons.csv')
    users.each do |row|
      member = members.select { |m| m[0] == row[0] }.first
      user = User.new(
        username: row[1],
        old_password_hash: row[2],
        created_at: row[4],
        email: member[5],
      )
      UserRepository.insert(user)
    end
  end
end
