# OpenVPN
module OpenVPN
  # Helpers for OpenVPN
  module Helper
    require 'openssl'
    def cert_valid?(keydir, cert)
      store = OpenSSL::X509::Store.new
      store.purpose = OpenSSL::X509::PURPOSE_SSL_CLIENT
      store.flags = OpenSSL::X509::V_FLAG_CRL_CHECK | OpenSSL::X509::V_FLAG_CRL_CHECK_ALL
      store.add_file(File.join(keydir, 'ca.crt'))
      store.add_crl(OpenSSL::X509::CRL.new(File.open(File.join(keydir, 'crl.pem'))))

      store.verify(OpenSSL::X509::Certificate.new(File.open(File.join(keydir, cert))))
    end
  end
end
