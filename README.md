# Tailgate

## Usage

### Spreadsheet permission

  must be set to "Anyone who has the link can edit"

### Enable the google drive api

  * Open https://code.google.com/apis/console/
  * Select the Services tab in your API project, and enable the Drive API.
  * Select the API Access tab in your API project, and click Create an OAuth 2.0 client ID.
  * In the Branding Information section, provide a name for your application (e.g. "Drive Quickstart Sample"), and click Next. Providing a product logo is optional.
  * In the Client ID Settings section, do the following:
    * Select "Service account" for the Application type
    * Download the Private Key

  per the instructions here:
    https://developers.google.com/drive/quickstart-ruby
    https://developers.google.com/accounts/docs/OAuth2#serviceaccount
    https://code.google.com/p/google-api-ruby-client/#Authorization

### Put your private key in the code (if the source isn't public)

  * open a console and run ```Tailgate::Helpers.p12_to_b64('/path/to/my/downloaded/privatekey.p12')```
  * create a class like so, if you're on rails, put it in ```config/initializers```:
```
  class GoogleOauth
    cattr_accessor :issuer
    self.issuer = 'copy your issuer (email and put it here)'
    def self.keyfile
      require 'base64'
      Base64.decode64 "paste the output from p12_to_b64 here"
    end
  end
```

### Append some data to your spreadsheet
  * open the target spreadsheet in your browser and copy the [KEY] portion of the url. e.g. https://docs.google.com/a/mydomain.com/spreadsheet/ccc?key=[KEY]#gid=0
  * while your spreadsheet is open, make sure row 1 contains your column names, which are set to 'user' and 'awesome' in the example. note that column names are case sensitive
  * grab the worksheet in your code
```ws = Tailgate.worksheet keyfile: GoogleOauth.keyfile, issuer: GoogleOauth.issuer, key: 'paste your spreadsheet key here'```
  * append your data
```
  form_data = { user: 'Nathan', awesome: 'yes please' }
  Tailgate.append(ws, form_data)
```


## Installation

Add this line to your application's Gemfile:

    gem 'tailgate'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tailgate

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
