# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_reference_session',
  :secret      => 'aacf9a4506b796dec4951cc30013310ace77a8b6f42647cbba0e62f817447011ccec57b95500f8a71074bb919e101ef1675e63ffa5e4419873992e69a4c7a385'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
