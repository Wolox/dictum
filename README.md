# Dictum - Document your Rails APIs
[![Gem Version](https://badge.fury.io/rb/dictum.svg)](https://badge.fury.io/rb/dictum)
[![Dependency Status](https://gemnasium.com/badges/github.com/alebian/dictum.svg)](https://gemnasium.com/github.com/alebian/dictum)
[![Build Status](https://travis-ci.org/alebian/dictum.svg)](https://travis-ci.org/alebian/dictum)
[![Code Climate](https://codeclimate.com/github/alebian/dictum/badges/gpa.svg)](https://codeclimate.com/github/alebian/dictum)
[![Test Coverage](https://codeclimate.com/github/alebian/dictum/badges/coverage.svg)](https://codeclimate.com/github/alebian/dictum/coverage)
[![Issue Count](https://codeclimate.com/github/alebian/dictum/badges/issue_count.svg)](https://codeclimate.com/github/alebian/dictum)
[![Inline docs](http://inch-ci.org/github/alebian/dictum.svg)](http://inch-ci.org/github/alebian/dictum)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dictum'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install dictum

## Basic usage

First you need to set a configuration file inside /config/initializers/dictum.rb

```ruby
# /config/initializers/dictum.rb
Dictum.configure do |config|
  config.output_path = Rails.root.join('docs')
  config.root_path = Rails.root
  config.output_filename = 'Documentation'
  config.output_format = :markdown
end
```

Then you can use Dictum in the most verbose and fully customizable way like this in your tests:

```ruby
# spec/controllers/my_resource_controller_spec.rb
require 'rails_helper'

describe V1::MyResourceController do
  Dictum.resource(
    name: 'MyResource',
    description: 'This is MyResource description.'
  )

  describe '#some_method' do
    context 'some context for my resource' do
      it 'returns status ok' do
        get :index
        Dictum.endpoint(
          resource: 'MyResource',
          endpoint: '/api/v1/my_resource/:id',
          http_verb: 'POST',
          description: 'Some description of the endpoint.',
          request_headers: { 'AUTHORIZATION' => 'user_token',
                             'Content-Type' => 'application/json',
                             'Accept' => 'application/json' },
          request_path_parameters: { id: 1, page: 1 },
          request_body_parameters: { some: 'parameter' },
          response_headers: { 'some_header' => 'some_header_value' },
          response_status: response.status,
          response_body: response_body
        )
        expect(response_status).to eq(200)
      end
    end
  end
end
```

Then execute:

    $ bundle exec rake dictum:document

And voilà, Dictum will create a document like this in '/docs/Documentation':

    # Index
    - MyResource

    # MyResource
    This is MyResource description.

    ## POST /api/v1/my_resource

    ### Description:
    Some description of the endpoint.

    ### Request headers:
    ```json
    {
      "AUTHORIZATION" : "user_token",
      "Content-Type" : "application/json",
      "Accept" : "application/json"
    }
    ```

    ### Path parameters:
    ```json
    { "id": 1, "page": 1 }
    ```

    ### Body parameters:
    ```json
    { "some": "parameter" }
    ```

    ### Response headers:
    ```json
    { "some_header": "some_header_value" }
    ```

    ### Response status:
    200

    ### Response body:
    ```json
    "no_content"
    ```

# Advanced usage

If you pay attention to the basic usage, you will notice that much code is needed if your API has a lot of endpoints, this is not DRY and adds unnecesary boilerplate. Luckily you can work around it using some Rspec tricks:

```ruby
# spec/controllers/my_resource_controller_spec.rb
require 'rails_helper'

describe V1::MyResourceController do
  Dictum.resource(
    name: 'MyResource',
    description: 'This is MyResource description.'
  )

  after(:each) do |test|
    if test.metadata[:dictum]
      Dictum.endpoint(
        resource: test.metadata[:described_class].to_s.gsub('V1::', '').gsub('Controller', ''),
        endpoint: request.fullpath,
        http_verb: request.env['REQUEST_METHOD'],
        description: test.metadata[:dictum_description],
        request_headers: { 'AUTHORIZATION' => 'user_token',
                           'Content-Type' => 'application/json',
                           'Accept' => 'application/json' },
        request_path_parameters: request.env['action_dispatch.request.path_parameters'].except(:controller, :action),
        request_body_parameters: request.env['action_dispatch.request.parameters'].except('controller', 'action'),
        response_headers: response.headers,
        response_status: response.status,
        response_body: response_body
    end
  end

  describe '#some_method' do
    context 'some context for my resource' do
      it 'returns status ok', dictum: true, dictum_description: 'Some description of the endpoint.' do
        get :index
        expect(response_status).to eq(200)
      end
    end
  end
end
```

This is much better, but it is not DRYed enough because you would have to repeat the after(:each) declaration on every controller spec you have, so you can still improve it a bit more:

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.after(:each) do |test|
    if test.metadata[:dictum]
      Dictum.endpoint(
        # All the parameters that you want
      )
    end
  end
end
end
```

```ruby
# spec/controllers/my_resource_controller_spec.rb
require 'rails_helper'

describe V1::MyResourceController do
  Dictum.resource(
    name: 'MyResource',
    description: 'This is MyResource description.'
  )

  describe '#some_method' do
    context 'some context for my resource' do
      it 'returns status ok', dictum: true, dictum_description: 'Some description of the endpoint.' do
        get :index
        expect(response_status).to eq(200)
      end
    end
  end
end
```

# Dynamic HTML documentation

So far so good, but your team needs to read the documentation everytime you update it, and sending the documentation file to them doesn't seem too practical. Instead you can use the HTML version of Dictum and generate static views with the content. Here is a very basic example of what you can do to generate the views and routes dynamycally:

```ruby
# /config/initializers/dictum.rb
Dictum.configure do |config|
  config.output_path = Rails.root.join('app', 'views')
  config.root_path = Rails.root
  config.output_filename = 'docs'
  config.output_format = :html
end
```

Here we are telling Dictum to generate the HTML documentation in 'app/views/docs', where it will put one HTML file per resource you have defined. Now that we have the files, lets create the routes for them:

```ruby
# config/routes.rb
YourApp::Application.routes.draw do
  #
  # Other routes defined
  #
  
  doc_paths = Dir["#{Rails.root.join('app', 'views', 'docs')}/*"].each do |path|
    resource = path.split('/').last.gsub('.html', '')
    get "/docs/#{resource}", to: "docs##{resource}"
  end
end
```

Of course you will need to have a controller for this, in this case one named 'docs_controller.rb'. And finally go to 'http://localhost:3000/docs/index.html'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Run rubocop lint (`rubocop -R --format simple`)
5. Run rspec tests (`bundle exec rspec`)
6. Push your branch (`git push origin my-new-feature`)
7. Create a new Pull Request

## License

**Dictum** is available under the MIT [license](https://raw.githubusercontent.com/alebian/dictum/master/LICENSE.md).

    Copyright (c) 2016 Alejandro Bezdjian, aka alebian

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
