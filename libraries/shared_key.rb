module OpenVPN
  module Keys

    # Checks for an encrypted data bag that stores a shared secret for openvpn p2p mode.
    # If it can't find a shared key, creates it and stores it in the encrypted data bag.
    class SharedKey
      attr_reader :key, :id

      def initialize(id)
        @id = id
        @key = key_from_databag
        create_key unless @key
      end

      private

      def key_from_databag
          load rescue nil
      end

      def create_key
        @key = create_key_contents
        save
      end

      def create_key_contents
        Mixlib::ShellOut.new("openvpn --genkey --secret /tmp/#{@id}.key").run_command
        File.open("/tmp/#{@id}.key", 'r').read
      end

      def load
        if Chef::Config[:solo]
          bag = Chef::DataBag.load('openvpn')
          decrypt bag[@id]['key']
        else
          Chef::EncryptedDataBagItem.load('openvpn', @id, load_secret)['key']
        end
      end

      def save
        item = Chef::DataBagItem.new
        item.data_bag 'openvpn'
        item.raw_data = create_key_hash

        if Chef::Config[:solo]
          FileUtils.mkdir_p(dbpath)
          dbfile = File.open(File.join(dbpath, "#{@id}.json"), 'w')
          dbfile.write(item.raw_data.to_json)
          dbfile.close
        else
          create_data_bag_if_missing
          item.save
        end
      end

      def create_key_hash
        {
          'id' => @id,
          'key' => encrypt(@key)
        }
      end

      def create_data_bag_if_missing
        bag = Chef::DataBag.new
        bag.name 'openvpn'
        begin
          bag.create
        rescue Net::HTTPServerException => e
          return if e.message.match(/409/)
          raise e
        end
      end

      def load_secret
        Chef::EncryptedDataBagItem.load_secret(Chef::Config[:knife][:secret_file])
      end

      def encrypt(value)
        data = Chef::EncryptedDataBagItem::Encryptor.new(value, load_secret)
        data.for_encrypted_item
      end

      def decrypt(value)
        data = Chef::EncryptedDataBagItem::Decryptor.for(value, load_secret).for_decrypted_item
        data
      end

      def dbpath
        File.join(Chef::Config['data_bag_path'],'openvpn')
      end
    end
  end
end

