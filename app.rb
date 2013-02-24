#encoding: utf-8

require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'
require './mailer'
require 'sinatra/flash'

set :haml, format: :html5, escape_html: true
before do
  content_type :html, charset: 'utf-8'
end

get '/' do
  sign_and_return(params[:return_url]) if session[:email]
  haml :login
end

post '/' do
  username = params[:username].downcase
  user = UserRepository.find_one(username: username)
  if user && user.authenticate(params[:password])
    UserRepository.save(user)
    session[:uuid] = user.uuid
    session[:email] = user.email
    session[:first_name] = user.first_name
    session[:last_name] = user.last_name
    session[:nickname] = user.nickname
    sign_and_return(params[:return_url])
  end
  flash.now[:error] = "Användarnamn eller lösenord matchade inte"
  haml :login
end
get '/reset' do
  haml :reset
end
post '/reset' do
  user = UserRepository.find_one(email: params[:email])
  @password = user.reset_password!
  Mailer.send(self.email, "Nytt lösenord", haml(:'mail/reset_password'))
  UserRepository.save(user)
  redirect '/'
end
get '/logout' do
  haml :logout
end
post '/logout' do
  session[:email] = nil
  session[:uuid] = nil
  redirect url('/')
end

get '/continue' do
  @user = UserRepository.find_one(uuid: session[:uuid])
  haml :details
end

helpers do
  def protect! 
    halt redirect url '/' unless session[:email]
  end

  def sign_and_return(return_url)
    halt redirect url('/continue') if return_url.nil? or return_url.empty?
    raise "SSO key is missing" unless ENV['SHARED_SSO_KEY']
    user = UserRepository.find_one(uuid: session[:uuid])

    uuid              = session[:uuid]
    email             = session[:email]
    first_name        = session[:first_name]
    last_name         = session[:last_name]
    nickname          = session[:nickname]

    time = Time.now.to_i
    msg = [uuid, time, email, first_name, last_name, nickname].map(&:to_s).join(":")
    sha1 = OpenSSL::Digest::Digest.new('sha1')
    token = OpenSSL::HMAC.hexdigest(sha1, ENV['SHARED_SSO_KEY'], msg)
    return_host = return_url.split('/')[0..2].join('/')
    return_path = ["", return_url.split('/')[3..-1]].join('/')
    data = { uuid: uuid, time: time, token: token,
      email: email, return_url: return_path}
    query = data.map { |k, v| "#{k}=#{URI.encode_www_form_component(v)}" }.join('&')
    halt redirect "#{return_host}/sso?#{query}"
  end
end
