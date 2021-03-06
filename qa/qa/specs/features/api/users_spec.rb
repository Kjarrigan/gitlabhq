module QA
  feature 'API users', :core do
    before(:context) do
      @api_client = Runtime::API::Client.new(:gitlab)
    end

    context 'when authenticated' do
      let(:request) { Runtime::API::Request.new(@api_client, '/users') }

      scenario 'get list of users' do
        get request.url

        expect_status(200)
      end

      scenario 'submit request with a valid user name' do
        get request.url, { params: { username: Runtime::User.name } }

        expect_status(200)
        expect(json_body).to contain_exactly(
          a_hash_including(username: Runtime::User.name)
        )
      end

      scenario 'submit request with an invalid user name' do
        get request.url, { params: { username: SecureRandom.hex(10) } }

        expect_status(200)
        expect(json_body).to eq([])
      end
    end

    scenario 'submit request with an invalid token' do
      request = Runtime::API::Request.new(@api_client, '/users', personal_access_token: 'invalid')

      get request.url

      expect_status(401)
    end
  end
end
