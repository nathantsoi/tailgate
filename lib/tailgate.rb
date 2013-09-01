require "tailgate/version"
require 'google/api_client'
require "google_drive"

module Tailgate
  class ArgumentError < Exception; end
  # Get an api client
  #  Required:
  #    opts[:keyfile] -- downloaded when you created an oauth 2 client id here: code.google.com/apis/console
  #      this can be a path or the contents of the file
  #    opts[:issuer] -- 'Email address' value found on the api access tab in your code.google.com/apis/console in the Service account section
  def self.client opts={}
    raise ArgumentError.new('please specify your keyfile') if (keyfile = opts[:keyfile]) == nil
    raise ArgumentError.new('please specify your issuer') if (issuer = opts[:issuer]) == nil
    return @client if @client != nil
    #https://github.com/google/google-api-ruby-client
    client = Google::APIClient.new(
      :application_name => 'Tailgate',
      :application_version => '1.0.0'
    )
    key = Google::APIClient::KeyUtils.load_from_pkcs12(keyfile, 'notasecret')
    client.authorization = Signet::OAuth2::Client.new(
      :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
      :audience => 'https://accounts.google.com/o/oauth2/token',
      :scope =>
        "https://docs.google.com/feeds/ " +
        "https://docs.googleusercontent.com/ " +
        "https://spreadsheets.google.com/feeds/",
      :issuer => issuer,
      :signing_key => key)
    client.authorization.fetch_access_token!
    @client = client
  end

  # Get a worksheet
  #  Required:
  #    opts[:key] -- open the spreadsheet in your browser and copy the [KEY] portion of the url. e.g. https://docs.google.com/a/mydomain.com/spreadsheet/ccc?key=[KEY]#gid=0
  #  Optional:
  #     opts[:sheet] (default is the first sheet)
  #     opts[:session] (default is GoogleDrive.login_with_oauth(client(opts).authorization.access_token))
  #  If not passed a session, one will be retrieved using options passed to client, which requires opts[:keyfile] and opts[:issuer]
  def self.worksheet opts={}
    raise ArgumentError.new('please specify your document key') if (key = opts[:key]) == nil
    sheet = opts[:sheet] || 0
    session =
      if opts[:session] != nil
        opts[:session]
      else
        GoogleDrive.login_with_oauth(client(opts).authorization.access_token)
      end
    session.spreadsheet_by_key(key).worksheets[sheet]
  end

  class UnknownColumnNameError < Exception; end
  # Append a row to the passed worksheet
  #  row_hash is a hash in the format { colname: :value1, anothercolname: value2 }
  #  where colname and anothercolname are values in the first row of the passed worksheet
  def self.append(worksheet, row_hash)
    # index columns by header
    headers = worksheet.rows[0].each_with_index.inject({}){|h, (v, i)|
      h[v.to_sym] = i+1
      h
    }
    row = worksheet.num_rows + 1
    row_hash.each do |k, v|
      col = headers[k.to_sym]
      raise UnknownColumnNameError.new("can't find a column named '#{k}', make sure it's in your spreadsheet") if col == nil
      #[row, col], 1 based index
      worksheet[row, col] = v
    end
    worksheet.save
  end

  module Helpers
    # Takes the filepath to your downloaded private key and returns a base 64 encoded string for embedding the key in your app
    #   The idea is to use this method in the rails console (or irb) to create an class like so:
    #  class GoogleOauth
    #    cattr_accessor :issuer
    #    self.issuer = 'copy your issuer (email and put it here)'
    #    def self.keyfile
    #      require 'base64'
    #      Base64.decode64 "paste the output from p12_to_b64 here"
    #    end
    #  end
    def self.p12_to_b64 filepath
      require 'base64'
      Base64.encode64(File.open(filepath, 'rb').read)
    end
  end
end
