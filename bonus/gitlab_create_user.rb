u = User.new(username: 'erferf', email: 'iguu@fff.fr', name: 'Eterferfhan Delage', password: 'JeSuisPasLa1!', password_confirmation: 'JeSuisPasLa1!')
u.assign_personal_namespace(Organizations::Organization.default_organization)
u.skip_confirmation!
u.save!

token = u.personal_access_tokens.create(scopes: ['api', 'admin_mode'], name: 'personnal_token', expires_at: 365.days.from_now)
token.set_token('abcd1234')
token.save!
