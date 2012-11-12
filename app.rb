#encoding: utf-8

require 'sinatra'
require 'sinatra/reloader' if development?
require 'haml'

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
    session[:email] = user.email
    session[:uuid] = user.uuid
    sign_and_return(params[:return_url])
  end
  @error = "Användarnamn eller lösenord matchade inte"
  haml :login
end

helpers do
  def protect! 
    halt redirect url '/' unless session[:email]
  end

  def sign_and_return(return_url)
    halt redirect url('/continue') if return_url.nil? or return_url.empty?
    raise "SSO key is missing" unless ENV['SHARED_SSO_KEY']
    user = UserRepository.find session[:id]

    login = Login.new(user: user, return_url: return_url) if user

    uuid        = session[:uuid]
    email       = session[:email]

    time        = Time.now.to_i
    msg         = "#{uuid}:#{time}:#{email}:#{name}:#{roles}"
    sha1        = OpenSSL::Digest::Digest.new('sha1')
    token       = OpenSSL::HMAC.hexdigest(sha1, ENV['SHARED_SSO_KEY'], msg)
    return_host = return_url.split('/')[0..2].join('/')
    return_path = ["", return_url.split('/')[3..-1]].join('/')
    data = { uuid: uuid, time: time, token: token,
      email: email, return_url: return_path}
    query = data.
      map { |k,v| k + "=" + URI.encode_www_form_component(v) }.join('&')
    halt redirect "#{return_host}/sso?#{query}"
  end
end
