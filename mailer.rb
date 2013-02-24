require 'mail'

Mail.defaults do
  delivery_method :smtp, { :address   => "smtp.sendgrid.net",
                           :port      => 587,
                           :domain    => "academian.se",
                           :user_name => ENV['SENDGRID_USERNAME'],
                           :password  => ENV['SENDGRID_PASSWORD'],
                           :authentication => 'plain',
                           :enable_starttls_auto => true }
end
class Mailer
  def self.send(to, subj, body)
    Mail.deliver do
      to to
      from 'Academian <info@academian.se>'
      subject subj
      html_part do
        content_type 'text/html; charset=UTF-8'
        body msg
      end
    end
  end
