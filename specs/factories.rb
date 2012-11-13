#encoding: utf-8
require 'bcrypt'
require 'securerandom'
def CreateAddress(params = {})
  values = {
    type: [:home, :work].sample,
    address: 'Storgatan 1',
    zip: 12345,
    region: 'Linköping'
  }.merge(params)
  Address.new(values)
end
def  CreatePhone(params = {})
  values = {
    type: [:home, :work, :mobile].sample,
    number: '12345678'
  }.merge(params)
  Phone.new(values)
end
def CreateMerit(params = {})
  values = {
    type: ['Vänsterfot', 'Chef', 'Volontär'].sample,
    from: DateTime.new - 10,
    to: [DateTime.new - 9, nil].sample
  }.merge(params)
  Merit.new(values)
end
def CreateUser(params = {})
  values = {
    username: 'username',
    #BCrypt::Password.create('old pass')
    password_hash: "$2a$10$bXrhyP684A82Ga3RrQLBmOUMVhLYWkPKbSa0kVrhYYTtbI3sOi5EG",
    old_password_hash: nil,
    email: 'test@example.com',
    created_at: Date.today,
    uuid: SecureRandom.uuid,
    first_name: 'John',
    last_name: 'Smith',
    nickname: 'Smitty',
    addresses: 2.times.map { CreateAddress() },
    phones: 2.times.map { CreatePhone() },
    merits: 2.times.map { CreateMerit() },
    contac: {mail: 'aldrig', email: 'ofta'}
  }.merge(params)
  User.new(values)
end
