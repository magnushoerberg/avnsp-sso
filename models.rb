require 'bcrypt'
require 'securerandom'
require './helpers'
module Hashable
  def to_h
    self.class.superclass.new(*self.values).each_pair.map do |k, v|
      value = if v.is_a?(Array)
                 v.map { |elem| elem.to_h }
               elsif v.respond_to?(:to_h)
                 v.to_h
               else
                 v
               end
      { k => value }
    end.inject(&:merge)
  end
end
AddressValues = Struct.new(:type, :address, :zip, :region)
class Address < AddressValues
  include Hashable
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
  def initialize(params)
    params = params.map { |k, v| {k.to_sym => v} }.inject(&:merge)
    super(params[:type],
          params[:number])
  end
end
MeritValues = Struct.new(:type, :from, :to)
class Merit < MeritValues
  include Hashable
  def initialize(params)
    params = params.map { |k, v| {k.to_sym => v} }.inject(&:merge)
    super(params[:type],
          params[:from],
          params[:to])
  end
end

UserValues = Struct.new(:username, :password_hash,
                        :old_password_hash, :email, :created_at, :uuid,
                        :first_name, :last_name, :nickname, :addresses,
                        :phones, :merits, :contact, :program, :began_studies)
class User < UserValues
  include BCrypt
  include Hashable
  def initialize params
    params = params.map { |k, v| {k.to_sym => v} }.inject(&:merge)
    params[:phones] = params[:phones].map {|p| Phone.new(p)}
    params[:merits] = params[:merits].map {|p| Merit.new(p)}
    params[:addresses] = params[:addresses].map {|p| Address.new(p)}
    super(params[:username],
          params[:password_hash],
          params[:old_password_hash],
          params[:email],
          params[:created_at],
          params[:uuid],
          params[:first_name],
          params[:last_name],
          params[:nickname],
          params[:addresses],
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
    [first_name, nickname, last_name].compact.join(' ')
  end

  def _id
    @_id
  end

  def password
    @password ||= Password.new(password_hash)
  end
  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = password
  end
  def reset_password!
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
