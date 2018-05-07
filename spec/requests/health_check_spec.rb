# frozen_string_literal: true

describe 'GET /health_check', type: :request do
  let(:url) { '/health_check' }

  let(:params) do
    { health_check_security_token: ENV.fetch('HEALTH_CHECK_SECURITY_TOKEN') }
  end

  context 'success' do
    specify do
      get url, params: params
      expect(response).to have_http_status(200)
    end
  end

  context 'forbidden' do
    let(:params) { {} }

    specify do
      get url, params: params
      expect(response).to have_http_status(403)
    end
  end
end
