# Loads the Warden helpers so we can access login_as and logout methods.
include Warden::Test::Helpers

# Provides helper methods to Warden for testing, 
# such as Warden.test_reset and Warden.on_next_request
Warden.test_mode! 

# We need to reset Warden after each test in order to make it work, 
# so after every scenario a Warden.test_reset! should be called.
After { Warden.test_reset! }