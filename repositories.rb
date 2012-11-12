require './models'

require 'mongo'
if mongo_url = ENV['MONGOHQ_URL']
  conn_string = URI.parse(mongo_url)
  db_name = conn_string.path.gsub(/^\//, '')

  DB = Mongo::Connection.new(conn_string.host, conn_string.port).db(db_name)
  DB.authenticate(conn_string.user, conn_string.password) unless (conn_string.user.nil? || conn_string.password.nil?)
else
  DB = Mongo::Connection.new.db("avnsp_db")
end
class Repository
  def self.find_one(params)
    entity = collection.find_one(params)
    klass.new(entity) if entity
  end
  def self.save(entity)
    collection.update({_id: entity._id}, entity.to_h)
  end
  def self.insert(entity)
    hash = entity.to_h
    collection.insert(hash)
  end
end
class UserRepository < Repository
  def self.klass
    User
  end
  def self.collection
    DB.collection(klass.name)
  end
end
#require 'bcrypt'
#require 'perpetuity'

#mongodb = Perpetuity::MongoDB.new host: 'localhost', db: 'avnsp_db'
#Perpetuity.configure do 
  #data_source mongodb
#end
#Perpetuity.generate_mapper_for User do
  #attribute :email, String
  #attribute :username, String
  #attribute :old_password_hash, String
  #attribute :password_hash, BCrypt::Password
  #attribute :created_at, DateTime
  #attribute :uuid, String
#end
#Perpetuity.generate_mapper_for Login do
  #attribute :user, User
  #attribute :return_url, String
  #attribute :login_time, DateTime
#end
#
#UserRepository = Perpetuity[User]
#LoginRepository = Perpetuity[Login]
