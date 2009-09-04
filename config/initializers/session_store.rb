# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_NewSamLown.com_session',
  :secret      => 'd9ecc9752ca856c82b844310226fd36e7aee2832189a6822092ff73b1131d7f027d305c84d04cd5963161177f19ca1d3b50257697e93f5175aaa01428d370db1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
