module SagePay
  module Direct
    class Response

      class_attribute :key_converter, :value_converter, :match_converter, :instance_writer => false

      self.key_converter = {
        "VPSProtocol"  => :vps_protocol,
        "Status"       => :status,
        "StatusDetail" => :status_detail,
        "TxAuthNo"     => :tx_auth_no,
        "MD"           => :md,
        "ACSURL"       => :acs_url,
        "PAReq"        => :par_eq,
        "AVSCV2"       => :avscv2,
        "AddressResult"       => :address_result,
        "PostCodeResult"       => :post_code_result,
        "CV2Result"       => :cv2_result,
        "3DSecureStatus"       => :three_d_secure_status,
        "CAVV"         => :cavv
      }

      self.value_converter = {
        :status => {
          "OK"            => :ok,
          "MALFORMED"     => :malformed,
          "INVALID"       => :invalid,
          "NOTAUTHED"     => :notauthed,
          "REJECTED"      => :rejected,
          "3DAUTH"        => :three_d_auth,
          "PPREDIRECT"    => :pp_redirect,
          "AUTHENTICATED" => :authenticated,
          "REGISTERED"    => :registered,
          "ERROR"         => :error
        },
        :avscv2 => {
          "ALL MATCH"                => :all_match,
          "SECURITY CODE MATCH ONLY" => :security_code_match_only,
          "ADDRESS MATCH ONLY"       => :address_match_only,
          "NO DATA MATCHES"          => :no_data_matches,
          "DATA NOT CHECKED"         => :data_not_checked
        },
        :address_result => {
          "NOTPROVIDED" => :not_provided,
          "NOTCHECKED"  => :not_checked,
          "MATCHED"     => :matched,
          "NOTMATCHED"  => :not_matched
        },
        :post_code_result => {
          "NOTPROVIDED" => :not_provided,
          "NOTCHECKED"  => :not_checked,
          "MATCHED"     => :matched,
          "NOTMATCHED"  => :not_matched
        },
        :cv2_result => {
          "NOTPROVIDED" => :not_provided,
          "NOTCHECKED"  => :not_checked,
          "MATCHED"     => :matched,
          "NOTMATCHED"  => :not_matched
        },
        :three_d_secure_status => {
          "OK"          => :ok,
          "NOAUTH"      => :no_auth,
          "CANTAUTH"    => :cant_auth,
          "NOTAUTHED"   => :not_authed,
          "ATTEMPTONLY" => :attempt_only,
          "NOTCHECKED"  => :not_checked,
          "INCOMPLETE"  => :incomplete,
          "MALFORMED"   => :malformed,
          "INVALID"     => :invalid,
          "ERROR"       => :error
        }
      }

      self.match_converter = {
        "NOTPROVIDED" => :not_provided,
        "NOTCHECKED"  => :not_checked,
        "MATCHED"     => :matched,
        "NOTMATCHED"  => :not_matched
      }

      attr_reader :vps_protocol, :status, :status_detail

      def self.attr_accessor_if_ok(*attrs)
        attrs.each do |attr|
          define_method(attr) do
            if ok?
              instance_variable_get("@#{attr}")
            else
              raise RuntimeError, "Unable to retrieve #{attr} as the status was #{status} (not OK)."
            end
          end
        end
      end

      def self.from_response_body(response_body)
        attributes = {}

        response_body.each_line do |line|
          key, value = line.split('=', 2)
          unless key.nil? || value.nil?
            value = value.chomp

            converted_key = key_converter[key]
            converted_value = value_converter[converted_key].nil? ? value : value_converter[converted_key][value]

            attributes[converted_key] = converted_value
          end
        end

        new(attributes)
      end

      def initialize(attributes = {})
        attributes.each do |k, v|
          # We're only providing readers, not writers, so we have to directly
          # set the instance variable.
          instance_variable_set("@#{k}", v)
        end
      end

      def ok?
        status == :ok
      end

      def failed?
        !ok?
      end

      def invalid?
        status == :invalid
      end

      def malformed?
        status == :malformed
      end

      def error?
        status == :error
      end
    end
  end
end
