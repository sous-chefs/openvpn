require 'openssl'

# OpenVPN
module OpenVPN
  # Helpers for OpenVPN
  module Helper
    # Checks that the certificate is valid (not revoked, etc.)
    def self.cert_valid?(keydir, cert)
      store = OpenSSL::X509::Store.new
      store.purpose = OpenSSL::X509::PURPOSE_SSL_CLIENT
      store.flags = OpenSSL::X509::V_FLAG_CRL_CHECK | OpenSSL::X509::V_FLAG_CRL_CHECK_ALL
      store.add_file(File.join(keydir, 'ca.crt'))
      store.add_crl(OpenSSL::X509::CRL.new(File.open(File.join(keydir, 'crl.pem'))))

      store.verify(OpenSSL::X509::Certificate.new(File.open(File.join(keydir, cert))))
    end

    def self.chef_solo_search_installed?
      klass = ::Search.const_get('Helper')
      return klass.is_a?(Class)
    rescue NameError
      return false
    end
  end unless defined?(OpenVPN::Helper) # https://github.com/sethvargo/chefspec/issues/562#issuecomment-74120922
end
