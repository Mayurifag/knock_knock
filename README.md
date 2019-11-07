# knock_knock

[![Gem Version](https://badge.fury.io/rb/knock_knock.svg)](http://badge.fury.io/rb/knock_knock)
[![Build Status](https://travis-ci.com/Mayurifag/knock_knock.svg)](https://travis-ci.com/Mayurifag/knock_knock)


## Description

`knock_knock` is an authentication solution for Rails API-only application based
on JSON Web Tokens.

This gem is a re-implementation of `Knock` gem to work with Rails 6 (and
zeitwerk) with some major and minor changes, i.e. 422 on wrong password instead
of 404.

I'm trying so stay with asame interface on this gem.

## Why should I use this?

- It's lightweight.
- It's tailored for Rails API-only application.
- It's [stateless](https://en.wikipedia.org/wiki/Representational_state_transfer#Stateless).
- It works out of the box with [Auth0](https://auth0.com/docs/server-apis/rails).

## Getting Started

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'knock_knock'
```

Then execute:

    $ bundle install

Finally, run the install generator:

    $ rails generate knock_knock:install

It will create the following initializer `config/initializers/knock_knock.rb`.
This file contains all of the existing configuration options.

If you don't use an external authentication solution like Auth0, you also need
to provide a way for users to sign in:

    $ rails generate knock_knock:token_controller user

This will generate the controller `user_token_controller.rb` and add the
required route to your `config/routes.rb` file.

You can also provide another entity instead of `user`. E.g. `admin`

### Requirements

`knock_knock` makes one assumption about your user model:

It must have an `authenticate` method, similar to the one added by [has_secure_password](http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password).

```ruby
class User < ActiveRecord::Base
  has_secure_password
end
```

Using `has_secure_password` is recommended, but you don't have to as long as
your user model implements an `authenticate` instance method with the same
behavior.

### Usage

Include the `KnockKnock::Authenticable` module in your `ApplicationController`

```ruby
class ApplicationController < ActionController::API
  include KnockKnock::Authenticable
end
```

You can now protect your resources by calling `authenticate_user` as a before_action
inside your controllers:

```ruby
class SecuredController < ApplicationController
  before_action :authenticate_user

  def index
    # etc...
  end

  # etc...
end
```

You can access the current user in your controller with `current_user`.

If no valid token is passed with the request, KnockKnock will respond with:

```
head :unauthorized
```

You can modify this behaviour by overriding `unauthorized_entity` in your controller.

You also have access directly to `current_user` which will try to authenticate
or return `nil`:

```ruby
def index
  if current_user
    # do something
  else
    # do something else
  end
end
```

_Note: the `authenticate_user` method uses the `current_user` method. Overwriting `current_user` may cause unexpected behaviour._

You can do the exact same thing for any entity. E.g. for `Admin`, use `authenticate_admin` and `current_admin` instead.

If you're using a namespaced model, KnockKnock won't be able to infer it
automatically from the method name. Instead you can use `authenticate_for`
directly like this:

```ruby
class ApplicationController < ActionController::Base
  include KnockKnock::Authenticable

  private

  def authenticate_v1_user
    authenticate_for V1::User
  end
end
```

```ruby
class SecuredController < ApplicationController
  before_action :authenticate_v1_user
end
```

Then you get the current user by calling `current_v1_user` instead of `current_user`.

### Customization

#### Via the entity model

The entity model (e.g. `User`) can implement specific methods to provide
customization over different parts of the authentication process.

- **Find the entity when creating the token (when signing in)**

By default, KnockKnock tries to find the entity by email. If you want to modify this
behaviour, implement within your entity model a class method `from_token_request`
that takes the request in argument.

E.g.

```ruby
class User < ActiveRecord::Base
  def self.from_token_request request
    # Returns a valid user, `nil` or raise `KnockKnock.not_found_exception_class_name`
    # e.g.
    #   email = request.params["email"]
    #   self.find_by email: email
  end
end
```

- **Find the authenticated entity from the token payload (when authenticating a request)**

By default, KnockKnock assumes the payload as a subject (`sub`) claim containing the entity's id
and calls `find` on the model. If you want to modify this behaviour, implement within
your entity model a class method `from_token_payload` that takes the
payload in argument.

E.g.

```ruby
class User < ActiveRecord::Base
  def self.from_token_payload payload
    # Returns a valid user, `nil` or raise
    # e.g.
    #   self.find payload["sub"]
  end
end
```

- **Modify the token payload**

By default the token payload contains the entity's id inside the subject (`sub`) claim.
If you want to modify this behaviour, implement within your entity model an instance method
`to_token_payload` that returns a hash representing the payload.

E.g.

```ruby
class User < ActiveRecord::Base
  def to_token_payload
    # Returns the payload as a hash
  end
end
```

#### Via the initializer

The initializer [config/initializers/knock_knock.rb](https://github.com/Mayurifag/knock_knock/blob/master/lib/generators/knock_knock/templates/knock_knock.rb)
is generated when `rails g knock_knock:install` is executed. Each configuration
variable is documented with comments in the initializer itself.

### Authenticating from a web or mobile application

Example request to get a token from your API:
```
POST /user_token
{"auth": {"email": "foo@bar.com", "password": "secret"}}
```

Example response from the API:
```
201 Created
{"jwt": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9"}
```

To make an authenticated request to your API, you need to pass the token via the
request header:
```
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9
GET /my_resources
```

KnockKnock responds with a `422 Unauthorized` when the user cannot be found or
the password is invalid. This is a security best practice to avoid giving away
information about the existence or not of a particular user.

**NB:** HTTPS should always be enabled when sending a password or token in your
request.

### Authenticated tests

To authenticate within your tests:

1. Create a valid token
2. Pass it in your request

e.g.

```ruby
class SecuredResourcesControllerTest < ActionDispatch::IntegrationTest
  def authenticated_header
    token = KnockKnock::AuthToken.new(payload: { sub: users(:one).id }).token

    {
      'Authorization': "Bearer #{token}"
    }
  end

  it 'responds successfully' do
    get secured_resources_url, headers: authenticated_header

    assert_response :success
  end
end
```

#### Without ActiveRecord

If no ActiveRecord is used, then you will need to specify what Exception will be
used when the user is not found with the given credentials.

```ruby
KnockKnock.setup do |config|

  # Exception Class
  # ---------------
  #
  # Configure the Exception to be used (raised and rescued) for User Not Found.
  # note: change this if ActiveRecord is not being used.
  #
  # Default:
  config.not_found_exception_class_name = 'MyCustomException'
end
```

### Algorithms

The JWT spec supports different kind of cryptographic signing algorithms.
You can set `token_signature_algorithm` to use the one you want in the
initializer or do nothing and use the default one (HS256).

You can specify any of the algorithms supported by the
[jwt](https://github.com/jwt/ruby-jwt) gem.

If the algorithm you use requires a public key, you also need to set
`token_public_key` in the initializer.

## Migrate from Knock

To migrate from `knock` you just need replace all things in your code from `knock`
to `knock_knock` and from `Knock` to `KnockKnock`.

You may look at [this commit](https://github.com/Mayurifag/bets_accounting/commit/8da1f3897457d497612c542f25531d9abc891397)
for a reference.

## CORS

To enable cross-origin resource sharing, check out the [rack-cors](https://github.com/cyu/rack-cors) gem.

## Related links

- [10 things you should know about tokens](https://auth0.com/blog/2014/01/27/ten-things-you-should-know-about-tokens-and-cookies/)


## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## TODO:

[] Readme and gemspec summaries etc +badges +ci beautify
[] changelog
[] COC
