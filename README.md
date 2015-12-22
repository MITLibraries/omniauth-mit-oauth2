# MIT OpenID Connect OmniAuth Strategy

This gem provides an OmniAuth strategy for authenticating users through [MIT OpenID Connect](https://oidc.mit.edu/).

[![Gem Version](https://badge.fury.io/rb/omniauth-mit-oauth2.svg)](https://badge.fury.io/rb/omniauth-mit-oauth2)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-mit-oauth2'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-mit-oauth2

## Usage

This can be used by configuring OmniAuth in `config/initializers/omniauth.rb` (if using Devise, see instructions below instead):

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :mit_oauth2, "MIT_OAUTH2_API_KEY", "MIT_OAUTH2_API_SECRET", {
    scope: "openid,name,email"
  }
end
```

Replace `MIT_OAUTH2_API_KEY` and `MIT_OAUTH2_API_SECRET` with the values obtained from registering your service through MIT OIDC. You generally want to keep those out of version control so populate the values however you are handling secrets in your app.

## Devise

The following instructions provide an example of how this could be used with Devise to add MIT authentication to your site.

### Registering Your Client

The first thing you will need to do is register your client with MIT OIDC. Once you have created the client, under the `Main` tab, find the `Redirect URI(s)` field. You need to add the callback URL `https://example.com/users/auth/mit_oauth2/callback` here replacing `example.com` with wherever your application will be deployed.

### Configuring Your App

Make sure Devise and this gem are included in your Gemfile:

```ruby
gem 'devise'
gem 'omniauth-mit-oauth2'
```

Install the gems:

```
bundle install
```

Create the user model:

```
rails generate devise:install
rails generate devise User
```

We don't want to provide account registration since users will just be using their MIT account to log in. Modify `app/models/user.rb` to only use the `:omniauthable` module, and add a method to create the user from the OAuth token:

```ruby
class User < ActiveRecord::Base
  devise :omniauthable, :omniauth_providers => [:mit_oauth2]

  def self.from_omniauth(auth)
    where(uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
    end
  end
end
```

Next edit the migration created by devise:

```ruby
class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.string :email
      t.string :uid, null: false

      t.timestamps null: false
    end
    add_index :users, :uid, unique: true
  end
end
```

Run the migration:

```
rake db:migrate
```

Configure OmniAuth to use our provider in `config/initializers/devise.rb`:

```ruby
Devise.setup do |config|
  # ...
  config.omniauth :mit_oauth2, "MIT_OAUTH2_API_KEY", "MIT_OAUTH2_API_SECRET", {
    scope: "openid,email,profile"
  }
end
```

Replace `MIT_OAUTH2_API_KEY` and `MIT_OAUTH2_API_SECRET` with the values obtained by registering your site through MIT OIDC. You generally want to keep those out of version control so populate the values however you are handling secrets in your app.

Now we need to set up the routes:

```ruby
Rails.application.routes.draw do
  devise_for :users, :controllers => {
    :omniauth_callbacks => 'users/omniauth_callbacks'
  }

  devise_scope :user do
    get 'sign_in', to: 'devise/sessions#new', as: :new_user_session
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end
  # ...
end
```

Next create a new controller for the OAuth callback in `app/controllers/users/omniauth_callbacks_controller.rb`:

```ruby
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def mit_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])
    sign_in_and_redirect @user, event: :authentication
  end
end
```

Since we are not using `:database_authenticatable` we need to define a helper method to be used in case of authentication failures. Add this to `app/controllers/application_controller.rb`:

```ruby
class ApplicationController < ActionController::Base
  # ...
  def new_session_path(scope)
    new_user_session_path
  end
end
```

Finally, we need to add the necessary views. A sign in link can be generated by using the following:

```ruby
<%= link_to("Sign in", user_omniauth_authorize_path(:mit_oauth2)) %>
```

Depending on your application, you might want to put this in a nav bar along with a sign out link. For example:

```ruby
<% if user_signed_in? %>
  <%= link_to("Sign out", destroy_user_session_path, method: :delete) %>
<% else %>
  <%= link_to("Sign in", user_omniauth_authorize_path(:mit_oauth2)) %>
<% end %>
```

You should also create a view to handle cases where authentication has failed, for example, if the user has not allowed the required scopes. This should go in `app/views/devise/sessions/new.html.erb`.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MITLibraries/omniauth-mit-oauth2.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
