require 'bcrypt'
require 'securerandom'
require './helpers'
require './hashable'
module Updateable
  def update params
    self.members.each do |k|
      value = params.fetch(k.to_s, nil)
      next unless value
      p value
      self.send(:"#{k}=", value)
    end
  end
end
Program = {
  1 => 'Y'
}
AddressValues = Struct.new(:type, :address, :zip, :region)
class Address < AddressValues
  include Hashable
  include Updateable
  def initialize(params)
    params = params.map { |k, v| {k.to_sym => v} }.inject(&:merge)
    super(params[:type],
          params[:address],
          params[:zip],
          params[:region])
  end
end
PhoneValues = Struct.new(:type, :number)
class Phone < PhoneValues
  include Hashable
  include Updateable
  def initialize(params)
    params = params.map { |k, v| {k.to_sym => v} }.inject(&:merge)
    super(params[:type],
          params[:number])
  end
end
MeritValues = Struct.new(:type, :from, :to)
class Merit < MeritValues
  include Hashable
  include Updateable
  def initialize(params)
    params = params.map { |k, v| {k.to_sym => v} }.inject(&:merge)
    super(params[:type],
          params[:from],
          params[:to])
  end
end

UserValues = Struct.new(:username, :password_hash,
                        :old_password_hash, :email, :created_at, :uuid,
                        :first_name, :last_name, :nickname, :addresses_hash,
                        :phones, :merits, :contact, :program, :began_studies)
class User < UserValues
  include BCrypt
  include Hashable
  include Updateable
  def addresses_hash= new_addresses
    new_addresses.delete_if { |a| a.values.all? { |v| v.strip.empty? } }
    super
  end
  def addresses
    return [] if addresses_hash.nil?
    self.addresses_hash.map do |a|
      Address.new(a)
    end
  end
  def initialize params
    params = params.map { |k, v| {k.to_sym => v} }.inject(&:merge)
    params[:merits] ||= []
    params[:phones] ||= []
    params[:phones] = params[:phones].map {|p| Phone.new(p)}
    params[:merits] = params[:merits].map {|p| Merit.new(p)}
    super(params[:username],
          params[:password_hash],
          params[:old_password_hash],
          params[:email],
          params[:created_at],
          params[:uuid],
          params[:first_name],
          params[:last_name],
          params[:nickname],
          params[:addresses_hash],
          params[:phones],
          params[:merits],
          params[:contact],
          params[:program],
          params[:began_studies])
    @_id = params[:_id]
    self.uuid = SecureRandom.uuid if params[:uuid].to_s.empty?
    self.password = params[:password] if params[:password]
  end

  def full_name
    if nickname.empty?
      [first_name, last_name].join ' '
    else
      first_name + ' "' + nickname + '" ' + last_name
    end
  end
  def program_s
    Program[self.program.to_i]
  end

  def _id
    @_id
  end

  def password
    @password ||= Password.new(self.password_hash)
  end
  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
  def reset_password!
    self.old_password_hash = nil
    new_password =  SecureRandom.hex(16)
    self.password = new_password
    new_password
  end
  def authenticate(passwrd)
    if self.old_password_hash
      pwd_hashed = if self.old_password_hash.start_with? '*'
                     pwd_hashed_binary = [Digest::SHA1.hexdigest(passwrd)].pack('H*')
                     Digest::SHA1.hexdigest(pwd_hashed_binary)
                   else
                     OldPassword.hash(passwrd).downcase
                   end
      dup = old_password_hash.dup.delete '*'
      self.old_password_hash = nil
      self.password = passwrd
      #the old password hashes are truncated, it's a bitch
      return dup == pwd_hashed[0...dup.length]
    end
    self.password == passwrd
  end
end
