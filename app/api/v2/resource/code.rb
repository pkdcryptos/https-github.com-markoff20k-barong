# frozen_string_literal: true

module API::V2
  module Resource
    # TOTP functionality API
    class Code < Grape::API

      resource :code do
        desc 'Request code',
          success: { code: 201, message: 'Send code' }
        params do
          requires :type,
                   type: String,
                   allow_blank: false,
                   values: { value: -> { Code::TYPES }, message: 'resource.user.invalid_type'},
                   desc: "Type of code"
          requires :category,
                   type: String,
                   allow_blank: false,
                   values: { value: -> { Code::CATEGORIES }, message: 'resource.user.invalid_category'},
                   desc: "Category of code"
        end
        post '/' do
          return status 201 if params[:type] == 'phone' && current_user.phone.nil?

          code = Code.pending.find_or_create_by(user: current_user, code_type: params[:type], category: params[:category])
          code.generate_code!

          status 201
        end
      end
    end
  end
end
