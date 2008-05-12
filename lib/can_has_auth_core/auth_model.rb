module AuthModel   
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend,  ClassMethods)
  end
  
  module InstanceMethods
    def authenticated?(password)
      crypted_password == encrypt(password)
    end      

    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    # Encrypts the password with the user salt
    def encrypt(password)
      self.class.encrypt(password, salt)
    end
    
    def remember_token?
      remember_token_expires_at && DateTime.now < DateTime.parse(remember_token_expires_at.to_s)
    end

    def remember_me_until(time)
      token = encrypt("#{email}--#{remember_token_expires_at}")
      update_attributes(:remember_token_expires_at => time, :remember_token =>  token)
      save
    end

    def remember_me_for(time)
      remember_me_until(DateTime.now + time)
    end

    # These create and unset the fields required for remembering users between browser closes
    # Default of 2 weeks 
    def remember_me
      remember_me_for(14)
    end

    def forget_me
      update_attributes(:remember_token_expires_at => nil, :remember_token => nil)
      save
    end
    
    def forgot_password
     @forgotten_password = true
     make_password_reset_code
    end

    def reset_password
     # First update the password_reset_code before setting the 
     # reset_password flag to avoid duplicate email notifications.
     update_attributes(:password_reset_code => nil)
     save
     @reset_password = true
    end

    def recently_reset_password?
     @reset_password
    end

    def recently_forgot_password?
     @forgotten_password
    end

    def make_password_reset_code
      code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by{rand}.join)
      update_attributes(:password_reset_code => code)
      save
    end
    
    # Returns true if the user has just been activated.
    def recently_activated?
      @activated
    end
    
    def recently_created?
      @created
    end

    def activated?
     return false if self.new_record?
     activation_code.nil? && !activated_at.nil?
    end

    def active?
      # the existence of an activation code means they have not activated yet
      activation_code.nil?
    end
    
    
    protected
      def make_activation_code
        if new_record?
          @created = true
          self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
        end
      end
    
      def password_required?
        crypted_password.blank? || !password.blank?
      end            
  end
    
  module ClassMethods
    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end
    
    # Authenticates a user by their email name and unencrypted password.  Returns the user or nil.
    def authenticate(email, password)
      u = first(:email => email)
      u && u.activated? && u.authenticated?(password) ? u : nil
    end
  end
end