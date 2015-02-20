class DeviseCreateUsers < ActiveRecord::Migration
  def change

    # may need to add permissions
    # http://stackoverflow.com/questions/22135792/permission-denied-to-create-extension-uuid-ossp
    # psql > alter user foodfeedback with superuser;
    enable_extension 'uuid-ossp'

    create_table :users, id: :uuid do |t|

      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: true, default: ""
      t.string :authentication_token

      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :description

      t.integer :role

      t.string :twitter_name
      t.string :twitter_avatar
      t.string :twitter_address
      t.string :twitter_oauth_token
      t.string :twitter_oauth_secret
      t.float :twitter_latitude, {:precision=>10, :scale=>6}
      t.float :twitter_longitude, {:precision=>10, :scale=>6}


      ## avatar attachment with paperclip and aws
      t.attachment :avatar

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      ## Invitable
      t.string     :invitation_token
      t.datetime   :invitation_created_at
      t.datetime   :invitation_sent_at
      t.datetime   :invitation_accepted_at
      t.integer    :invitation_limit
      t.uuid       :invited_by_id
      t.integer    :invitations_count, default: 0
      t.index      :invitations_count
      t.index      :invitation_token, :unique => true # for invitable
      t.index      :invited_by_id

      t.timestamps
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :authentication_token,   unique: true
    add_index :users, :unlock_token,         unique: true
  end
end