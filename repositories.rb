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
  def self.find(params)
    collection.find(params).map do |entity|
      klass.new(entity)
    end
  end
  def self.find_one(params)
    entity = collection.find_one(params)
    klass.new(entity) if entity
  end
  def self.update(selector, params)
    collection.update(selector, params)
    find_one(selector)
  end
  def self.save(entity)
    collection.update({_id: entity._id}, entity.to_h)
  end
  def self.insert(entity)
    if entity.is_a? Hash
      collection.insert(entity)
    else
      collection.insert(entity.to_h)
    end
  end
  def self.collection
    DB.collection(klass.name)
  end
end
class UserRepository < Repository
  def self.klass; User end
end
class ConversionRepository < Repository
  def self.klass; Conversion end
end
