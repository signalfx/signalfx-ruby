require 'openssl'
require 'tempfile'

class SelfSignedCertificate
  def initialize
    # This randomly fails sometimes, probably due to lack of system entropy
    begin
      @key = OpenSSL::PKey::RSA.new(4096)
    rescue OpenSSL::PKey::RSAError
      sleep 0.1
      retry
    end

    public_key = @key.public_key

    subject = "/C=BE/O=Test/OU=Test/CN=Test"

    @cert = OpenSSL::X509::Certificate.new
    @cert.subject = @cert.issuer = OpenSSL::X509::Name.parse(subject)
    @cert.not_before = Time.now
    @cert.not_after = Time.now + 365 * 24 * 60 * 60
    @cert.public_key = public_key
    @cert.serial = 0x0
    @cert.version = 2

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = @cert
    ef.issuer_certificate = @cert
    @cert.extensions = [
        ef.create_extension("basicConstraints","CA:TRUE", true),
        ef.create_extension("subjectKeyIdentifier", "hash"),
    # ef.create_extension("keyUsage", "cRLSign,keyCertSign", true),
    ]
    @cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                           "keyid:always,issuer:always")

    @cert.sign @key, OpenSSL::Digest::SHA1.new

    @key_file = Tempfile.new("signalfx_key")
    @key_file.write(@key)
    @key_file.close

    @cert_file = Tempfile.new("signalfx_cert")
    @cert_file.write(@cert.to_pem)
    @cert_file.close
  end

  def cert_path
    @cert_file.path
  end

  def key_path
    @key_file.path
  end

  def unlink_files
    @cert_file.unlink
    @key_file.unlink
  end
end
