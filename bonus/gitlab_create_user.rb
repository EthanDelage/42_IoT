# Retrieve environment variable values
username = ENV['GITLAB_USERNAME']
email = ENV['GITLAB_EMAIL']
name = ENV['GITLAB_NAME']
password = ENV['GITLAB_PASSWORD']
personal_access_token = ENV['GITLAB_PERSONAL_ACCESS_TOKEN']

# Create a new user with environment variable values
u = User.new(
  username: username,
  email: email,
  name: name,
  password: password,
  password_confirmation: password
)

# Assign the default personal namespace
u.assign_personal_namespace(Organizations::Organization.default_organization)

# Skip user confirmation
u.skip_confirmation!
# Save the user
u.save!

# Create a personal access token
token = u.personal_access_tokens.create(scopes: ['api', 'admin_mode'], name: 'personal_token', expires_at: 365.days.from_now)
token.set_token(personal_access_token)
token.save!
