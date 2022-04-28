# frozen_string_literal: true

module API
  module V2
    module Entities
      # Phone request response
      class Phone < API::V2::Entities::Base
        expose :number,
               documentation: {
                type: 'String',
                desc: 'Submasked phone number'
               } do |phone|
                Barong::App.config.api_data_masking_enabled ? phone.sub_masked_number : phone.number
               end

        expose :validated_at,
               documentation: {
                type: 'Datetime',
                desc: 'Phone validation date'
               } do |phone|
                phone.code.validated_at
               end
      end
    end
  end
end
