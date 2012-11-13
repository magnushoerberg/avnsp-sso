require './models'
require './specs/factories'
describe User do
  let(:user) { CreateUser() }

  it 'has a password, that is hashed after it is set' do
    password = SecureRandom.hex(16)
    user.password = password
    user.password.should be_a BCrypt::Password
    user.password.should == password
    user.password_hash.should == password
  end
  it 'authenticates an old password, and then reset the old password hash' do
    user.old_password_hash = '*20f1875aba29acbbcda7360bf879936bd09c40d2'
    user.authenticate('old pass').should == true
    user.old_password_hash.should == nil
  end
  it 'authenticates an old password, and then reset the old password hash' do
    user.old_password_hash = '40ab4c571f90fb9c'
    user.authenticate('super secret').should == true
    user.old_password_hash.should == nil
  end
end
