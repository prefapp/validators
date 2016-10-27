class Validator

  VERSION = 0.1

  attr_accessor :error

  def get_validations

    {"int"=>{"regexp"=>/\/^\d+$\//}, "signed_int"=>{"regexp"=>/\/^[-+]?\d+$\//}, "float"=>{"regexp"=>/\/\A[+-]?\d+\.?\d+(e[+-]?\d+)?\z\/i/}, "text"=>{"regexp"=>/\/^[@%\s\w\-]+$\/i/}, "multiline_text"=>{"regexp"=>/\/^[\w\-\_\@\s\.\,]+\/i/}, "word"=>{"regexp"=>/\/\A[\w\-]+\z\/i/}, "email"=>{"regexp"=>/\/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z\/i/}, "username"=>{"regexp"=>/\/\A[\w\-]+\z\/i/}, "password"=>{"regexp"=>/\/^.{6,64}$\//}, "domain"=>{"regexp"=>/\/^(default|[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,}))$\//}, "server_name"=>{"regexp"=>/\/^(localhost|([a-z0-9-]+|\*)(\.([a-z0-9-]+|\*))*(\.([a-z]{2,}|\*)))$\//}, "host"=>{"regexp"=>/\/\A(localhost|[a-z\d\-.]+\.[a-z]+)\z\/i/}, "ipv4"=>{"regexp"=>/\/\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\z\//}, "url"=>{"regexp"=>/\/^(http(s)?|ftp|ssh):\/\/(([\w\-\:]+)\@)?(([A-Za-z0-9-]+\.)*([A-Za-z0-9-]+\.[A-Za-z0-9]+))+((\/?)(([A-Za-z0-9\._\-]+)(\/){0,1}[A-Za-z0-9.-\/]*)){0,1}\//}, "smtp_user"=>{"regexp"=>/\/ ^( ([\w+\-.]+@[a-z\d\-.]+\.[a-z]+)| # email ([\w\-\_]+)                        # username )$\/x/}, "revision"=>{"regexp"=>/\/\A[\w.\-_]+\z\//}, "unix_path"=>{"regexp"=>/\/^[\w\s.\/\-_+%]+$\/i/}, "unix_command"=>{"regexp"=>/\/\A[\w\s.\-_+><:]+\z\/i/}, "tcp_port"=>{"range"=>"1..65535"}, "mysql_dbname"=>{"regexp"=>/\/\A[a-z0-9_]{2,63}\z\/i/}, "mysql_dbuser"=>{"regexp"=>/\/\A[a-z0-9_]{2,16}\z\/i/}, "mysql_dbpassword"=>{"regexp"=>/\/\A.{6,64}\z\/i/}, "db_password"=>{"regexp"=>/\/^.{6,64}$\/i/}, "postgresql_identifier"=>{"regexp"=>/\/\A[a-z0-9_]{2,63}\z\/i/}, "postgresql_extra_privileges"=>{"regexp"=>/\/^ ( SUPERUSER | NOSUPERUSER | CREATEDB | NOCREATEDB | CREATEROLE | NOCREATEROLE | CREATEUSER | NOCREATEUSER | INHERIT | NOINHERIT | LOGIN | NOLOGIN | CONNECTION LIMIT \d{1,4} | PASSWORD .{6,64} | VALID UNTIL \d{10,16} )$\/x/}, "version"=>{"regexp"=>/\/\A\w+\.\w+(\.\w+)?(\.\w+)?\z\//}, "package_name"=>{"regexp"=>/\/^[a-z0-9+-.=]+$\//}, "checksum"=>{"regexp"=>/\/^[a-z0-9]{16,64}$\/i/}, "command_line_option"=>{"regexp"=>/\/^[\w\-\:\.\/]*$\//}, "perl_module"=>{"regexp"=>/\/^\w+(\:\:\w+)*(\@[0-9.-_]+)?$\//}, "node_module"=>{"regexp"=>/\/^[\w\.-]+$\//}, "ruby_gem"=>{"regexp"=>/\/^[\w\-\.#]+$\//}, "python_package"=>{"regexp"=>/\/^[\w\-\.#]+$\//}, "socket_address"=>{"regexp"=>/\/^(unix|tcp|udp)?(\:\/\/)?[\/\w\.\d\:_-]+?\:?\d{0,5}$\//}, "git_bundle"=>{"regexp"=>/\/^ [\w\s.\/\-_+%]+ # unix_path \| ([a-z\-_]+\:\/\/)?[a-z\d\-.@]+\.[a-z\d\-.:]+\/[^\|]+  #url \| [\w.\-_]+  # revision (\|[\w\s.\/\-_+%,]+)? # file list (optional) $\/x/}, "apache_module"=>{"fixed_values"=>["alias", "apreq2", "auth_basic", "auth_digest", "authn_file", "authn_core", "authnz_ldap", "auth_openid", "authz_default", "authz_groupfile", "authz_host", "authz_user", "autoindex", "cgi", "dav_fs", "dav", "dav_svn", "deflate", "dir", "env", "expires", "fcgid", "headers", "ldap", "log_config", "logio", "mime", "negotiation", "perl", "php5", "proxy_ajp", "proxy_balancer", "proxy_connect", "proxy_http", "proxy", "python", "rewrite", "setenvif", "ssl", "status", "wsgi", "xsendfile", "access_compat"]}, "iso639-1"=>{"regexp"=>/\/^[a-z]{2}$\/i/}, "ssh_public_key"=>{"regexp"=>/\/^[@%\s\w\/\-\.]+$\/i/}}
    
  end

  def initialize

    @validations = get_validations
    @error = nil

  end

  def validate(type, value)

    unless validations = @validations[type]
      raise "Validation to type #{type} not exists!"
    end

    validations.each do |validation_class, validation|

      begin
        if validation_class =~ /regex/
          
          validation = /#{validation}/ unless validation.is_a?(Regexp)

          unless value =~ validation
            raise "validation of #{type} not match pattern" 
          end

        elsif validation_class == "range"
          # si a validacion e unha string, construimos o Range
          unless validation.is_a?(Range)
            validation =~ /\A([+-]?\d+)\.\.([+-]?\d+)\z/
            validation = $1.to_i..$2.to_i 

            unless(value =~ /^[+-]?\d+$/)
              raise "Value #{value} not valid" 
            end
            
            ## convertimos os strings a int, senon non se dan comparao
            value = value.to_i if value.is_a?(String)
          end

          raise "#{validation} isn't Range" unless validation.is_a?(Range)

          unless validation.include?(value)
            raise "Value #{value} not in range #{validation}"
          end

        elsif validation_class == "fixed_values"
          raise "#{validation} isn't Array" unless validation.is_a?(Array)
          
          unless validation.include?(value)
            raise "Value #{value} not valid in fixed values list: #{validation}"
          end
        end
      rescue Exception => e
        @error = e.message
        return false

      end

    end

    return true

  end

end
