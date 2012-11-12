require './models'
describe User do
  let(:email) { "test@example.com" }
  let(:user) { User.new(email: email) }

  it 'responds to email and uuid' do
    user.email.should == email
    user.uuid.should_not be_nil
  end
  it 'has a password, that is hashed after it is set' do
    password = SecureRandom.hex(16)
    user.password = password
    user.password.should be_a BCrypt::Password
    user.password.should == password
    user.password_hash.should == password
  end
  it 'authenticates an old password, and then reset the old password hash' do
    old_hash = [Digest::SHA1.hexdigest('old pass')].pack('H*')
    user.old_password_hash = '*' + Digest::SHA1.hexdigest(old_hash)
    user.authenticate('old pass').should == true
    user.old_password_hash.should == nil
  end
  it 'authenticates an old password, and then reset the old password hash' do
    user.old_password_hash = '40ab4c571f90fb9c'
    user.authenticate('super secret').should == true
    user.old_password_hash.should == nil
  end
end
