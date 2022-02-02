# frozen_string_literal: true

module API
  module V2
    module Management
      class Code < Grape::API

        desc 'Code related routes'
        resource :code do
          desc 'Create code' do
            @settings[:scope] = :write_codes
            success API::V2::Management::Entities::Code
          end
          params do
            requires :user_uid, type: String, allow_blank: false, desc: 'Account UID'
            requires :type,
                     type: String,
                     allow_blank: false,
                     values: { value: -> { Code::TYPES }, message: 'management.codes.invalid_type'},
                     desc: 'Type of code'
            requires :category,
                     type: String,
                     allow_blank: false,
                     values: { value: -> { Code::CATEGORIES }, message: 'management.codes.invalid_category'},
                     desc: 'Category of code'
            optional :phone_number, type: String, desc: 'Phone number', allow_blank: false
            optional :email, type: String, desc: 'Email', allow_blank: false
          end
          post '/create' do
            declared_params = declared(params)
            user = User.active.find_by!(uid: declared_params[:user_uid])
            code = Code.find_or_create_by(
              user: user,
              code_type: declared_params[:type],
              category: declared_params[:category],
              phone_number: declared_params[:phone_number],
              email: declared_params[:email]
            )

            code.generate_code!

            present code, with: API::V2::Management::Entities::Code
          end
          
          desc 'Read code' do
            @settings[:scope] = :read_codes
            success API::V2::Management::Entities::Code
          end
          params do
            requires :code_id,
                     type: Integer,
                     allow_blank: false,
                     desc: 'Code ID'
          end
          post '/get' do
            declared_params = declared(params)
            code = Code.find_by!(id: declared_params[:code_id])

            present code, with: API::V2::Management::Entities::Code
          end

          desc 'Verify code' do
            @settings[:scope] = :write_codes
            success API::V2::Management::Entities::Code
          end
          params do
            requires :code_id,
                     type: Integer,
                     allow_blank: false,
                     desc: 'Code ID'
            requires :verification_code,
                     type: String,
                     allow_blank: false,
                     desc: 'Code verification code'
          end
          post '/verify_code' do
            declared_params = declared(params)
            code = Code.find_by!(id: declared_params[:code_id])

            error!({ errors: ['management.code.code_expired']}, 422) if code.expired?
            error!({ errors: ['management.code.code_out_attempt']}, 422) if code.out_attempt?
            error!({ errors: ['management.code.verification_invalid'] }, 422) unless code.verify_code!(declared_params[:verification_code])

            status(200)
          end
        end

      end
    end
  end
end
